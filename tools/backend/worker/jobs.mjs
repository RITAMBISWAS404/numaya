// Worker jobs. Each is safe to run concurrently (SKIP LOCKED claims) and to re-run (idempotent
// completion), and recovers jobs a crashed worker left behind (10-minute reclaim).
// `db` is a pg.Pool on the database owner connection; `storage` is supabase-js `.storage` with
// the secret key. Never logs message bodies, phone numbers, tokens or coordinates.
import { MediaRejected, processImage, validateVoice } from './media.mjs';
import { buildPushMessage, createFcmClient, loadFcmConfig } from './fcm.mjs';
import { processDeletions } from '../scripts/privacy_worker.mjs';

const toBuffer = async (blob) => Buffer.from(await blob.arrayBuffer());

/** Photos: quarantine object -> validated, re-encoded object at <uid>/processed/<photo id>.jpg. */
export async function processPhotoJobs({ db, storage, log = () => {}, limit = 10 }) {
  const { rows } = await db.query('select * from private.claim_photo_jobs($1)', [limit]);
  let ready = 0; let rejected = 0; let retried = 0;
  for (const ph of rows) {
    try {
      const dl = await storage.from('photos').download(ph.object_path);
      if (dl.error) throw Object.assign(new Error('download_failed'), { retryable: true });
      const out = await processImage(await toBuffer(dl.data));
      const path = `${ph.user_id}/processed/${ph.id}.jpg`;
      const up = await storage.from('photos').upload(path, out.buffer, { contentType: 'image/jpeg', upsert: true });
      if (up.error) throw Object.assign(new Error('upload_failed'), { retryable: true });
      await db.query('select private.complete_photo_job($1, $2, $3, $4)', [ph.id, path, out.width, out.height]);
      ready++;
    } catch (e) {
      const retryable = !(e instanceof MediaRejected) && e.retryable !== false;
      await db.query('select private.fail_photo_job($1, $2, $3)', [ph.id, e.reason ?? e.message, retryable]);
      if (retryable) retried++; else rejected++;
      log(`photo ${ph.id.slice(0, 8)}: ${e.reason ?? e.message}`);
    }
  }
  return { claimed: rows.length, ready, rejected, retried };
}

/** Chat media: images re-encoded like photos; voice notes container-checked and copied. */
export async function processAttachmentJobs({ db, storage, log = () => {}, limit = 10 }) {
  const { rows } = await db.query('select * from private.claim_attachment_jobs($1)', [limit]);
  let ready = 0; let failed = 0;
  for (const at of rows) {
    try {
      const dl = await storage.from('chat-media').download(at.object_path);
      if (dl.error) throw Object.assign(new Error('download_failed'), { retryable: true });
      const bytes = await toBuffer(dl.data);
      const base = `${at.conversation_id}/${at.uploader_id}/processed-${at.id}`;
      let path; let body; let type;
      if (at.kind === 'image') {
        const out = await processImage(bytes, { minEdge: 16 });
        path = `${base}.jpg`; body = out.buffer; type = 'image/jpeg';
      } else {
        const v = validateVoice(bytes, at.mime);
        path = `${base}.${v.kind === 'mp4' ? 'm4a' : v.kind}`; body = bytes; type = v.mime;
      }
      const up = await storage.from('chat-media').upload(path, body, { contentType: type, upsert: true });
      if (up.error) throw Object.assign(new Error('upload_failed'), { retryable: true });
      await db.query('select private.complete_attachment_job($1, $2)', [at.id, path]);
      ready++;
    } catch (e) {
      const retryable = !(e instanceof MediaRejected) && e.retryable !== false;
      await db.query('select private.fail_attachment_job($1, $2, $3)', [at.id, e.reason ?? e.message, retryable]);
      failed++;
      log(`attachment ${at.id.slice(0, 8)}: ${e.reason ?? e.message}`);
    }
  }
  return { claimed: rows.length, ready, failed };
}

/**
 * Push: one outbox row -> every active device of the recipient that allows the category.
 * Disabled (rows stay pending) until FCM is configured; invalid tokens are revoked; provider
 * errors retry with backoff and dead-letter after 8 attempts.
 */
export async function deliverPush({ db, env, fcm = null, log = () => {}, limit = 50, fetchImpl }) {
  const cfg = fcm ? { enabled: true } : loadFcmConfig(env);
  if (!cfg.enabled) return { disabled: cfg.reason };
  const client = fcm ?? createFcmClient(cfg, fetchImpl ? { fetchImpl } : {});
  const { rows } = await db.query(`select * from private.claim_outbox(array['match', 'message', 'compliment'], $1)`, [limit]);
  let sent = 0; let retried = 0; let skipped = 0; let revoked = 0;
  for (const o of rows) {
    const targets = (await db.query('select * from private.push_targets($1)', [o.id])).rows;
    if (!targets.length) {
      await db.query(`select private.finish_outbox($1, 'skipped', 'no eligible device')`, [o.id]);
      skipped++;
      continue;
    }
    let needRetry = false; let error = null; let anySent = false;
    for (const t of targets) {
      const r = await client.send(t.push_token, buildPushMessage(t.category, o.payload));
      if (r.outcome === 'sent') anySent = true;
      else if (r.outcome === 'invalid_token') { await db.query('select private.revoke_device($1)', [t.device_id]); revoked++; }
      else { needRetry = true; error = r.error ?? r.outcome; }
    }
    // Retrying re-sends to every device: delivery is at-least-once; the app dedupes by data.
    if (needRetry && !anySent) { await db.query(`select private.finish_outbox($1, 'retry', $2)`, [o.id, error]); retried++; }
    else { await db.query(`select private.finish_outbox($1, 'sent', $2)`, [o.id, error]); sent++; }
  }
  log(`push: ${sent} sent, ${retried} retry, ${skipped} skipped, ${revoked} tokens revoked`);
  return { claimed: rows.length, sent, retried, skipped, revoked };
}

/** Privacy exports: build the member's own JSON, store privately, 7-day download. */
export async function processExports({ db, storage, log = () => {}, limit = 5 }) {
  const { rows } = await db.query(`select * from private.claim_outbox(array['privacy_export'], $1)`, [limit]);
  let done = 0;
  for (const o of rows) {
    try {
      const rid = o.payload.request_id;
      const { rows: [req] } = await db.query(`select user_id from public.privacy_requests where id = $1 and status = 'pending'`, [rid]);
      if (!req) { await db.query(`select private.finish_outbox($1, 'skipped', 'request gone')`, [o.id]); continue; }
      const { rows: [{ e }] } = await db.query('select private.build_export($1) as e', [req.user_id]);
      const path = `${req.user_id}/${rid}.json`;
      const up = await storage.from('exports').upload(path, Buffer.from(JSON.stringify(e, null, 2)), { contentType: 'application/json', upsert: true });
      if (up.error) throw new Error('upload_failed');
      await db.query('select private.complete_export($1, $2)', [rid, path]);
      await db.query(`select private.finish_outbox($1, 'sent')`, [o.id]);
      done++;
    } catch (e) {
      await db.query(`select private.finish_outbox($1, 'retry', $2)`, [o.id, e.message]);
      log(`export retry: ${e.message}`);
    }
  }
  return { claimed: rows.length, done };
}

/** Housekeeping that needs storage access: expired exports, orphaned chat media, stale rows. */
export async function sweep({ db, storage, log = () => {} }) {
  const out = { exportsRemoved: 0, orphansRemoved: 0, obsoleteOutbox: 0 };
  const { rows: expired } = await db.query(`select id, object_path from public.privacy_requests
    where kind = 'export' and object_path is not null and expires_at < now()`);
  for (const r of expired) {
    await storage.from('exports').remove([r.object_path]);
    await db.query('update public.privacy_requests set object_path = null where id = $1', [r.id]);
    out.exportsRemoved++;
  }
  // Chat media whose attachment row is gone (conversation or member deleted) for a day.
  const { rows: orphans } = await db.query(`select o.name from storage.objects o
    where o.bucket_id = 'chat-media' and o.created_at < now() - interval '1 day'
      and not exists (select 1 from public.attachments a where a.object_path = o.name or a.processed_path = o.name)
    limit 500`);
  if (orphans.length) {
    await storage.from('chat-media').remove(orphans.map((o) => o.name));
    out.orphansRemoved = orphans.length;
  }
  // Rows without a consumer (moderation queues read tables directly).
  const r = await db.query(`update private.outbox set status = 'skipped'
    where status = 'pending' and kind in ('photo_review', 'report_triage')`);
  out.obsoleteOutbox = r.rowCount;
  log(`sweep: ${JSON.stringify(out)}`);
  return out;
}

export async function purge({ log = () => {} }) {
  return processDeletions({ log });
}

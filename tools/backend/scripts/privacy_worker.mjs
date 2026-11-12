// Completes account deletions requested through request_account_deletion().
// Server-side only (secret key + database URL). Safe to re-run: every step is idempotent.
// Order: storage objects -> auth user (cascades rows and revokes refresh tokens) -> tombstone.
// Report evidence copied at report time is kept (retention period: DECISIONS_REQUIRED).
import { createClient } from '@supabase/supabase-js';
import pg from 'pg';
import { loadEnv } from '../lib/env.mjs';

export async function processDeletions({ only = null, log = () => {} } = {}) {
  const env = loadEnv();
  const admin = createClient(env.SUPABASE_URL, env.SUPABASE_SECRET_KEY, { auth: { persistSession: false } });
  const pool = new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 2, ssl: { rejectUnauthorized: false } });
  let completed = 0;
  let failed = 0;
  try {
    const { rows } = await pool.query(
      `select user_id from private.deletion_tombstones where completed_at is null
       and ($1::uuid[] is null or user_id = any($1::uuid[])) order by requested_at limit 100`, [only]);
    for (const { user_id: id } of rows) {
      try {
        for (;;) {
          const { data, error } = await admin.storage.from('photos').list(id, { limit: 100 });
          if (error) throw error;
          if (!data.length) break;
          const rm = await admin.storage.from('photos').remove(data.map((o) => `${id}/${o.name}`));
          if (rm.error) throw rm.error;
        }
        const del = await admin.auth.admin.deleteUser(id);
        if (del.error && !/not found/i.test(del.error.message)) throw del.error;
        await pool.query(`update private.deletion_tombstones set completed_at = now() where user_id = $1`, [id]);
        await pool.query(`update public.privacy_requests set status = 'completed', completed_at = now()
                          where user_id = $1 and kind = 'delete' and status = 'pending'`, [id]);
        await pool.query(`insert into private.audit_log (actor, action, subject) values (null, 'account_deletion_completed', $1)`, [id]);
        completed++;
        log(`deleted ${id.slice(0, 8)}…`);
      } catch (e) {
        failed++;
        log(`failed ${id.slice(0, 8)}…: ${e.message}`);
      }
    }
  } finally {
    await pool.end();
  }
  return { completed, failed };
}

if (import.meta.url === `file://${process.argv[1].replace(/\\/g, '/')}` || process.argv[1]?.endsWith('privacy_worker.mjs')) {
  processDeletions({ log: console.log }).then((r) => console.log(JSON.stringify(r)));
}

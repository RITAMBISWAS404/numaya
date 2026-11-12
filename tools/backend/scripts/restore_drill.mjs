// Isolated restore drill: decrypts a backup, restores every table into a throwaway schema
// `restore_drill_<n>` (structure copied from the live tables, no grants, not exposed by the API),
// checks row counts and plaintext checksums, verifies every photo object decrypts to its
// recorded hash, then REPLAYS DELETION TOMBSTONES (rows of members whose deletion completed are
// removed from the restored copy) and proves none remain, before dropping the schema.
// It never writes to the live tables. A full environment restore (new project) is documented in
// docs/backend/BACKUP_RESTORE.md.
import { createDecipheriv, createHash } from 'node:crypto';
import { readFileSync, readdirSync } from 'node:fs';
import { resolve } from 'node:path';
import pg from 'pg';
import { loadEnv, repoRoot } from '../lib/env.mjs';
import { keyFrom } from './backup.mjs';

export function decrypt(key, blob) {
  const d = createDecipheriv('aes-256-gcm', key, blob.subarray(0, 12));
  d.setAuthTag(blob.subarray(12, 28));
  return Buffer.concat([d.update(blob.subarray(28)), d.final()]);
}
const sha = (b) => createHash('sha256').update(b).digest('hex');

// Columns that identify a member, per table, for tombstone replay.
const MEMBER_COLUMNS = {
  'private.accounts': ['user_id'], 'private.locations': ['user_id'], 'private.credit_ledger': ['user_id'],
  'private.daily_usage': ['user_id'], 'private.entitlements': ['user_id'], 'private.staff_members': ['user_id'],
  'public.profiles': ['user_id'], 'public.preferences': ['user_id'], 'public.prompts': ['user_id'],
  'public.photos': ['user_id'], 'public.decisions': ['actor_id', 'target_id'],
  'public.conversations': ['user_a', 'user_b'], 'public.messages': ['sender_id'],
  'public.compliments': ['sender_id', 'recipient_id'], 'public.blocks': ['blocker_id', 'blocked_id'],
  'public.consents': ['user_id'], 'public.devices': ['user_id'], 'public.conversation_reads': ['user_id'],
};

export async function restoreDrill(backupDir, { log = console.log } = {}) {
  const env = loadEnv();
  const key = keyFrom(env);
  const dir = resolve(repoRoot, 'backups', backupDir);
  const manifest = JSON.parse(readFileSync(resolve(dir, 'manifest.json'), 'utf8'));
  const schema = `restore_drill_${Date.now()}`;
  const pool = new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 2, ssl: { rejectUnauthorized: false } });
  const report = { schema, tables: 0, rows: 0, mismatches: [], objectsVerified: 0, tombstonesReplayed: 0, leftoverAfterReplay: 0 };
  const client = await pool.connect();
  try {
    await client.query(`create schema ${schema}`);
    await client.query(`revoke all on schema ${schema} from public, anon, authenticated`);
    for (const [name, meta] of Object.entries(manifest.tables)) {
      if (!name.includes('.') || name.startsWith('auth.')) continue;
      const plain = decrypt(key, readFileSync(resolve(dir, `${name}.jsonl.enc`)));
      if (sha(plain) !== meta.sha256) report.mismatches.push(`${name}: checksum`);
      const rows = plain.length ? plain.toString('utf8').split('\n').map((l) => JSON.parse(l)) : [];
      const [s, t] = name.split('.');
      const target = `${schema}."${s}__${t}"`;
      await client.query(`create table ${target} (like "${s}"."${t}" including defaults)`);
      // Identity columns: copy values as-is.
      await client.query(`alter table ${target} alter column id drop identity if exists`).catch(() => {});
      for (const r of rows) {
        const cols = Object.keys(r);
        await client.query(
          `insert into ${target} (${cols.map((c) => `"${c}"`).join(',')})
           select * from json_populate_record(null::${target}, $1::json)`, [JSON.stringify(r)]);
      }
      const { rows: [{ n }] } = await client.query(`select count(*)::int as n from ${target}`);
      if (n !== meta.rows) report.mismatches.push(`${name}: ${n} restored vs ${meta.rows}`);
      report.tables++;
      report.rows += n;
    }
    for (const o of manifest.objects) {
      const bytes = decrypt(key, readFileSync(resolve(dir, 'objects', o.file)));
      if (sha(bytes) !== o.sha256) report.mismatches.push(`object ${o.name}`);
      else report.objectsVerified++;
    }
    // Deletion replay: members whose deletion completed must not come back with a restore.
    const tombstoneRows = (await client.query(
      `select user_id from ${schema}."private__deletion_tombstones" where completed_at is not null`)).rows;
    const live = (await client.query(
      `select user_id from private.deletion_tombstones where completed_at is not null`)).rows;
    const ids = [...new Set([...tombstoneRows, ...live].map((r) => r.user_id))];
    report.tombstonesReplayed = ids.length;
    if (ids.length) {
      for (const [name, cols] of Object.entries(MEMBER_COLUMNS)) {
        const [s, t] = name.split('.');
        const target = `${schema}."${s}__${t}"`;
        await client.query(`delete from ${target} where ${cols.map((c) => `"${c}" = any($1::uuid[])`).join(' or ')}`, [ids]);
        const { rows: [{ n }] } = await client.query(
          `select count(*)::int as n from ${target} where ${cols.map((c) => `"${c}" = any($1::uuid[])`).join(' or ')}`, [ids]);
        report.leftoverAfterReplay += n;
      }
    }
  } finally {
    await client.query(`drop schema if exists ${schema} cascade`).catch(() => {});
    client.release();
    await pool.end();
  }
  report.ok = report.mismatches.length === 0 && report.leftoverAfterReplay === 0;
  log(JSON.stringify(report, null, 2));
  return report;
}

if (process.argv[1]?.endsWith('restore_drill.mjs')) {
  const dirs = readdirSync(resolve(repoRoot, 'backups')).sort();
  restoreDrill(process.argv[2] ?? dirs.at(-1)).then((r) => process.exit(r.ok ? 0 : 1))
    .catch((e) => { console.error(e.message); process.exit(1); });
}

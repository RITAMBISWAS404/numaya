// Encrypted logical backup of the development project: every table in schemas public and
// private, the auth user ids/timestamps needed to re-link rows (no phone numbers), and every
// object in the private `photos` bucket. AES-256-GCM per file with NUMAYA_BACKUP_KEY (32 bytes,
// base64), which the owner keeps outside Git and outside this machine's repo.
// Output: backups/<timestamp>/ (git-ignored) with manifest.json (counts + SHA-256 of plaintext).
// This is a manual, tested procedure, not automated production recovery (see BACKUP_RESTORE.md).
import { createCipheriv, createHash, randomBytes } from 'node:crypto';
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import pg from 'pg';
import { createClient } from '@supabase/supabase-js';
import { loadEnv, repoRoot, describeTarget } from '../lib/env.mjs';

export function keyFrom(env) {
  const raw = env.NUMAYA_BACKUP_KEY ? Buffer.from(env.NUMAYA_BACKUP_KEY, 'base64') : null;
  if (!raw || raw.length !== 32) {
    throw new Error('NUMAYA_BACKUP_KEY must be 32 random bytes, base64 (supabase/.env.local).');
  }
  return raw;
}

export function encrypt(key, plain) {
  const iv = randomBytes(12);
  const c = createCipheriv('aes-256-gcm', key, iv);
  const body = Buffer.concat([c.update(plain), c.final()]);
  return Buffer.concat([iv, c.getAuthTag(), body]); // 12 | 16 | ciphertext
}

const sha = (b) => createHash('sha256').update(b).digest('hex');

export async function backup({ log = console.log } = {}) {
  const env = loadEnv();
  const key = keyFrom(env);
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const dir = resolve(repoRoot, 'backups', stamp);
  mkdirSync(resolve(dir, 'objects'), { recursive: true });
  const pool = new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 2, ssl: { rejectUnauthorized: false } });
  const manifest = { createdAt: new Date().toISOString(), target: describeTarget(env), tables: {}, objects: [] };
  try {
    const { rows: tables } = await pool.query(`select table_schema as s, table_name as t
      from information_schema.tables where table_schema in ('public', 'private') and table_type = 'BASE TABLE'
      order by 1, 2`);
    for (const { s, t } of tables) {
      const { rows } = await pool.query(`select * from "${s}"."${t}"`);
      const plain = Buffer.from(rows.map((r) => JSON.stringify(r)).join('\n'));
      writeFileSync(resolve(dir, `${s}.${t}.jsonl.enc`), encrypt(key, plain));
      manifest.tables[`${s}.${t}`] = { rows: rows.length, sha256: sha(plain) };
    }
    const { rows: users } = await pool.query(`select id, created_at from auth.users order by created_at`);
    const up = Buffer.from(users.map((r) => JSON.stringify(r)).join('\n'));
    writeFileSync(resolve(dir, 'auth.users.ids.jsonl.enc'), encrypt(key, up));
    manifest.tables['auth.users(ids)'] = { rows: users.length, sha256: sha(up) };

    const admin = createClient(env.SUPABASE_URL, env.SUPABASE_SECRET_KEY, { auth: { persistSession: false } });
    const { rows: objs } = await pool.query(`select name from storage.objects where bucket_id = 'photos' order by name`);
    for (const { name } of objs) {
      const { data, error } = await admin.storage.from('photos').download(name);
      if (error) throw error;
      const bytes = Buffer.from(await data.arrayBuffer());
      const file = `${sha(Buffer.from(name)).slice(0, 32)}.enc`;
      writeFileSync(resolve(dir, 'objects', file), encrypt(key, bytes));
      manifest.objects.push({ name, file, bytes: bytes.length, sha256: sha(bytes) });
    }
  } finally {
    await pool.end();
  }
  writeFileSync(resolve(dir, 'manifest.json'), JSON.stringify(manifest, null, 2));
  log(`Backup written: backups/${stamp} (${Object.keys(manifest.tables).length} tables, ${manifest.objects.length} objects)`);
  return { dir, manifest };
}

if (process.argv[1]?.endsWith('backup.mjs')) backup().catch((e) => { console.error(e.message); process.exit(1); });

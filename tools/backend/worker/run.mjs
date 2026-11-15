// Worker entry point. `node worker/run.mjs --once` runs every job once (for cron / Task Scheduler
// / a scheduled CI job); `--loop` repeats every 30 s with backoff on errors. `--jobs=a,b` limits
// the set. Exits non-zero if any job threw, so schedulers can alert.
import pg from 'pg';
import { createClient } from '@supabase/supabase-js';
import { loadEnv, describeTarget } from '../lib/env.mjs';
import { deliverPush, processAttachmentJobs, processExports, processPhotoJobs, purge, sweep } from './jobs.mjs';

const ALL = ['photos', 'attachments', 'push', 'exports', 'purge', 'sweep'];

export async function runOnce({ jobs = ALL, log = console.log } = {}) {
  const env = loadEnv();
  const db = new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 3, ssl: { rejectUnauthorized: false } });
  const storage = createClient(env.SUPABASE_URL, env.SUPABASE_SECRET_KEY, { auth: { persistSession: false } }).storage;
  const results = {};
  let failed = false;
  try {
    for (const job of jobs) {
      try {
        results[job] = await ({
          photos: () => processPhotoJobs({ db, storage, log }),
          attachments: () => processAttachmentJobs({ db, storage, log }),
          push: () => deliverPush({ db, env, log }),
          exports: () => processExports({ db, storage, log }),
          purge: () => purge({ log }),
          sweep: () => sweep({ db, storage, log }),
        })[job]();
      } catch (e) {
        failed = true;
        results[job] = { error: e.message };
      }
    }
  } finally {
    await db.end();
  }
  log(JSON.stringify({ target: describeTarget(env).projectRef, at: new Date().toISOString(), results }));
  return { results, failed };
}

if (process.argv[1]?.endsWith('run.mjs')) {
  const arg = process.argv.find((a) => a.startsWith('--jobs='));
  const jobs = arg ? arg.slice(7).split(',').filter((j) => ALL.includes(j)) : ALL;
  if (process.argv.includes('--loop')) {
    let delay = 30_000;
    for (;;) {
      const { failed } = await runOnce({ jobs }).catch((e) => { console.error(e.message); return { failed: true }; });
      delay = failed ? Math.min(delay * 2, 600_000) : 30_000;
      await new Promise((r) => setTimeout(r, delay));
    }
  } else {
    const { failed } = await runOnce({ jobs });
    process.exit(failed ? 1 : 0);
  }
}

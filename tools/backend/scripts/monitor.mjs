// Operational monitor: reads queue ages and backlogs (no personal data) and exits 1 with a list
// of alerts when a threshold is crossed, so a scheduler (CI cron, Task Scheduler) can notify the
// on-call owner. Thresholds are starting points for the beta (DECISIONS_REQUIRED P10).
import pg from 'pg';
import { loadEnv, describeTarget } from '../lib/env.mjs';

const THRESHOLDS = {
  oldest_review_minutes: 240,       // photos waiting for a moderator
  oldest_report_hours: 24,          // open safety reports
  outbox_dead: 0,                   // undeliverable notifications or exports
  deletions_overdue: 0,             // purge must run daily
  photos_failed_24h: 50,            // pipeline health
  exports_pending: 10,
};

export async function checkHealth() {
  const env = loadEnv();
  const db = new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 1, ssl: { rejectUnauthorized: false } });
  try {
    // The owner connection reads the same figures staff_ops_health shows (no auth.uid() here).
    const { rows: [h] } = await db.query(`select
      (select extract(epoch from now() - min(created_at)) / 60 from public.photos where status = 'pending' and processing = 'ready') as oldest_review_minutes,
      (select extract(epoch from now() - min(created_at)) / 3600 from public.reports where status = 'open') as oldest_report_hours,
      (select count(*) from private.outbox where status = 'dead')::int as outbox_dead,
      (select count(*) from private.deletion_tombstones where completed_at is null and purge_after < now() - interval '1 day')::int as deletions_overdue,
      (select count(*) from public.photos where processing = 'failed' and created_at > now() - interval '1 day')::int as photos_failed_24h,
      (select count(*) from public.privacy_requests where kind = 'export' and status = 'pending')::int as exports_pending`);
    const alerts = Object.entries(THRESHOLDS)
      .filter(([k, max]) => h[k] !== null && Number(h[k]) > max)
      .map(([k, max]) => `${k}=${Math.round(Number(h[k]))} (threshold ${max})`);
    return { target: describeTarget(env).projectRef, health: h, alerts };
  } finally {
    await db.end();
  }
}

if (process.argv[1]?.endsWith('monitor.mjs')) {
  const r = await checkHealth();
  console.log(JSON.stringify(r, null, 2));
  process.exit(r.alerts.length ? 1 : 0);
}

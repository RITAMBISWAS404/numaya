// Repeatable activation of the Numaya DEVELOPMENT backend (docs/backend/ACTIVATION_RUNBOOK.md).
//
//   node scripts/activate.mjs --confirm-project=<ref>            all steps, in order
//   node scripts/activate.mjs --confirm-project=<ref> --from=tests  resume from a step
//   node scripts/activate.mjs --confirm-project=<ref> --only=schema run one step
//   node scripts/activate.mjs --check                              config validation only (no network)
//
// Options: --plan-only (migrations dry run, nothing applied) · --store-env=sandbox (let sandbox
// purchases grant benefits on THIS dev project) · --with-function-secrets (push the store/FCM
// function secrets found in supabase/.env.local; never STORE_VERIFICATION_ENABLED) ·
// --attachments (build the APK with live chat media on) · --skip-apk.
//
// Safety: refuses anything not marked development; never resets, drops, prunes or deletes; never
// enables a paid feature; never prints a secret. Network steps retry with backoff; a failed step
// stops the run and prints the exact `--from=` command to resume. A redacted report is written to
// docs/backend/evidence/activation-<time>.json.
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import pg from 'pg';
import { loadEnv, repoRoot, describeTarget } from '../lib/env.mjs';

const STEPS = ['config', 'confirm', 'connect', 'auth', 'migrate', 'schema', 'store-env',
  'secrets', 'functions', 'schedules', 'worker', 'monitor', 'tests', 'apk'];

const args = Object.fromEntries(process.argv.slice(2).map((a) => {
  const [k, ...v] = a.replace(/^--/, '').split('=');
  return [k, v.length ? v.join('=') : true];
}));

class StepError extends Error {
  constructor(message, { retry = false, hint } = {}) { super(message); this.retry = retry; this.hint = hint; }
}

// ------------------------------------------------------------------------------------------------
// Configuration validation (shapes only; values are never printed).
export function validateConfig(env) {
  const errors = [], warnings = [], enabled = {};
  const need = (k, ok, why) => { if (!env[k]) errors.push(`${k} is empty`); else if (!ok(env[k])) errors.push(`${k}: ${why}`); };
  need('SUPABASE_URL', (v) => /^https:\/\/[a-z0-9]{20}\.supabase\.co\/?$/.test(v), 'expected https://<20-char ref>.supabase.co');
  need('SUPABASE_PUBLISHABLE_KEY', (v) => v.startsWith('sb_publishable_'), 'expected an sb_publishable_ key (Settings > API Keys)');
  need('SUPABASE_SECRET_KEY', (v) => v.startsWith('sb_secret_'), 'expected an sb_secret_ key');
  need('SUPABASE_DB_URL', (v) => /^postgres(ql)?:\/\/[^:]+:[^@]+@[^/]+\/\w+/.test(v), 'expected postgresql://user:password@host:port/postgres (Session pooler)');
  if (env.SUPABASE_PUBLISHABLE_KEY && env.SUPABASE_PUBLISHABLE_KEY === env.SUPABASE_SECRET_KEY) errors.push('publishable and secret keys are identical');
  const ref = env.SUPABASE_PROJECT_REF;
  if (!ref) errors.push('SUPABASE_PROJECT_REF is empty');
  if (ref && env.SUPABASE_URL && !env.SUPABASE_URL.includes(`${ref}.supabase.co`)) errors.push('SUPABASE_PROJECT_REF does not match SUPABASE_URL');
  if (ref && env.SUPABASE_DB_URL && !env.SUPABASE_DB_URL.includes(ref)) errors.push('SUPABASE_DB_URL does not belong to SUPABASE_PROJECT_REF');
  if ((env.NUMAYA_ENVIRONMENT || 'development') !== 'development') errors.push('NUMAYA_ENVIRONMENT must be "development" for this workflow');
  if (env.SUPABASE_DB_URL && /db\.[a-z0-9]{20}\.supabase\.co/.test(env.SUPABASE_DB_URL)) {
    warnings.push('SUPABASE_DB_URL is the direct (IPv6-only) host; use the Session pooler string if connections fail');
  }
  // Optional groups: each is all-or-nothing.
  const pair = (a, b, label) => {
    if (!!env[a] !== !!env[b]) errors.push(`${label}: set both ${a} and ${b}, or neither`);
    return !!(env[a] && env[b]);
  };
  enabled.phoneTestA = pair('NUMAYA_TEST_PHONE_A', 'NUMAYA_TEST_OTP_A', 'test phone A');
  enabled.phoneTestB = pair('NUMAYA_TEST_PHONE_B', 'NUMAYA_TEST_OTP_B', 'test phone B');
  for (const k of ['NUMAYA_TEST_PHONE_A', 'NUMAYA_TEST_PHONE_B']) {
    if (env[k] && !/^\d{8,15}$/.test(env[k])) errors.push(`${k}: digits only, country code first, no +`);
  }
  enabled.staff = pair('NUMAYA_STAFF_EMAIL', 'NUMAYA_STAFF_PASSWORD', 'staff account');
  if (env.NUMAYA_BACKUP_KEY) {
    const len = Buffer.from(env.NUMAYA_BACKUP_KEY, 'base64').length;
    if (len !== 32) errors.push('NUMAYA_BACKUP_KEY must be 32 random bytes, base64');
    enabled.backup = len === 32;
  }
  if (env.FCM_SERVICE_ACCOUNT_JSON) {
    try {
      const sa = JSON.parse(Buffer.from(env.FCM_SERVICE_ACCOUNT_JSON, 'base64').toString('utf8'));
      if (sa.type !== 'service_account' || !sa.private_key || !sa.client_email || !sa.project_id) throw new Error();
      enabled.push = true;
    } catch { errors.push('FCM_SERVICE_ACCOUNT_JSON must be a base64-encoded service-account key JSON'); }
  }
  if (env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON) {
    for (const k of ['GOOGLE_PLAY_PACKAGE_NAME', 'GOOGLE_PUBSUB_PUSH_AUDIENCE', 'GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT']) {
      if (!env[k]) errors.push(`Google Play: ${k} is required with GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`);
    }
    try { JSON.parse(Buffer.from(env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON, 'base64').toString('utf8')); enabled.googlePlay = true; }
    catch { errors.push('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON must be base64 JSON'); }
  }
  if (env.APPLE_BUNDLE_ID) {
    if (!/^[0-9a-f:]{64,95}$/i.test(env.APPLE_ROOT_CA_G3_SHA256 || '')) errors.push('APPLE_ROOT_CA_G3_SHA256 must be the SHA-256 fingerprint of Apple Root CA - G3');
    else enabled.apple = true;
  }
  if (env.STORE_VERIFICATION_ENABLED) warnings.push('STORE_VERIFICATION_ENABLED in .env.local is ignored: enabling it is a manual step (runbook)');
  return { errors, warnings, enabled };
}

// ------------------------------------------------------------------------------------------------
async function withRetry(label, fn, { attempts = 4, baseMs = 1500 } = {}) {
  for (let i = 1; ; i++) {
    try { return await fn(); } catch (e) {
      const transient = e.retry || /ECONNRESET|ETIMEDOUT|ENOTFOUND|EAI_AGAIN|ECONNREFUSED|fetch failed|timeout|503|502|504/i.test(String(e.message || e.code));
      if (!transient || i >= attempts) throw e;
      const wait = baseMs * 2 ** (i - 1);
      console.log(`  ${label}: transient failure (${e.code || e.message}); retry ${i}/${attempts - 1} in ${wait / 1000}s`);
      await new Promise((r) => setTimeout(r, wait));
    }
  }
}

let env, target, redact;
const cliEntry = resolve(repoRoot, 'tools', 'backend', 'node_modules', 'supabase', 'dist', 'supabase.js');
function runCli(cliArgs, extraEnv = {}) {
  const r = spawnSync(process.execPath, [cliEntry, ...cliArgs], {
    cwd: repoRoot, encoding: 'utf8', shell: false, input: '',
    env: { ...process.env, SUPABASE_YES: '1', ...extraEnv },
  });
  return { status: r.status ?? 1, out: redact(`${r.stdout || ''}${r.stderr || ''}`) };
}
const pool = () => new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 2, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 15000 });
async function sql(text, params) {
  const db = pool();
  try { return (await db.query(text, params)).rows; } finally { await db.end(); }
}

const report = { startedAt: new Date().toISOString(), steps: {} };

const steps = {
  async config() {
    const { errors, warnings, enabled } = validateConfig(env);
    warnings.forEach((w) => console.log(`  warning: ${w}`));
    if (errors.length) throw new StepError(`configuration invalid:\n    - ${errors.join('\n    - ')}`, { hint: 'Fix supabase/.env.local (see supabase/.env.example and MANUAL_SETUP.md).' });
    return { optionalEnabled: enabled };
  },

  async confirm() {
    if (args['confirm-project'] !== target.projectRef) {
      throw new StepError(`target not confirmed: this would act on project "${target.projectRef}" (${target.host})`,
        { hint: `Re-run with --confirm-project=${target.projectRef} if that is your DEVELOPMENT project.` });
    }
    return { projectRef: target.projectRef };
  },

  async connect() {
    const health = await withRetry('REST', async () => {
      const r = await fetch(`${env.SUPABASE_URL}/auth/v1/health`, { headers: { apikey: env.SUPABASE_PUBLISHABLE_KEY } });
      if (r.status === 401 || r.status === 403) throw new StepError('publishable key rejected (401/403)');
      if (!r.ok) throw new StepError(`auth health HTTP ${r.status}`, { retry: r.status >= 500 });
      return r.status;
    });
    const [db] = await withRetry('database', () => sql('select current_setting(\'server_version\') as version, current_user as role'));
    if (!db.version.startsWith('17') && !db.version.startsWith('15')) console.log(`  note: Postgres ${db.version}`);
    // The secret key must work against the Admin API (tests and workers use it).
    await withRetry('secret key', async () => {
      const r = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users?per_page=1`, { headers: { apikey: env.SUPABASE_SECRET_KEY, authorization: `Bearer ${env.SUPABASE_SECRET_KEY}` } });
      if (r.status === 401 || r.status === 403) throw new StepError('secret key rejected by the Admin API');
      if (!r.ok) throw new StepError(`admin API HTTP ${r.status}`, { retry: r.status >= 500 });
    });
    return { authHealth: health, postgres: db.version, dbRole: db.role };
  },

  async auth() {
    const s = await withRetry('auth settings', async () => {
      const r = await fetch(`${env.SUPABASE_URL}/auth/v1/settings`, { headers: { apikey: env.SUPABASE_PUBLISHABLE_KEY } });
      if (!r.ok) throw new StepError(`auth settings HTTP ${r.status}`, { retry: r.status >= 500 });
      return r.json();
    });
    const phone = !!s.external?.phone, email = !!s.external?.email;
    if (!email) throw new StepError('Email provider is disabled; the test harness signs test users in with email/password', { hint: 'Authentication > Sign In / Providers > Email: enable (confirmations can stay on; tests create confirmed users).' });
    if (!phone) console.log('  warning: Phone provider disabled: the app cannot sign in and the phone OTP test will fail (MANUAL_SETUP T2).');
    return { phone, email, signupDisabled: !!s.disable_signup };
  },

  async migrate() {
    const plan = runCli(['db', 'push', `--remote=${env.SUPABASE_DB_URL}`, '--include-all', '--dry-run', '--yes']);
    console.log(plan.out.split('\n').map((l) => `  | ${l}`).join('\n'));
    if (plan.status !== 0) throw new StepError('migration dry run failed', { retry: /timeout|connect/i.test(plan.out) });
    if (args['plan-only']) return { applied: false, planOnly: true };
    const run = await withRetry('db push', async () => {
      const r = runCli(['db', 'push', `--remote=${env.SUPABASE_DB_URL}`, '--include-all', '--yes']);
      if (r.status !== 0) throw new StepError(`db push failed:\n${r.out}`, { retry: /timeout|connect|reset/i.test(r.out) });
      return r;
    }, { attempts: 3 });
    console.log(run.out.split('\n').map((l) => `  | ${l}`).join('\n'));
    return { applied: true };
  },

  async schema() {
    const local = readdirSync(resolve(repoRoot, 'supabase', 'migrations')).filter((f) => f.endsWith('.sql')).map((f) => f.split('_')[0]).sort();
    const remote = (await sql('select version from supabase_migrations.schema_migrations order by version')).map((r) => r.version);
    const missing = local.filter((v) => !remote.includes(v));
    if (missing.length) throw new StepError(`migrations not applied: ${missing.join(', ')}`, { hint: 'Run --from=migrate.' });
    const noRls = (await sql(`select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity`)).map((r) => r.relname);
    if (noRls.length) throw new StepError(`RLS is off on public tables: ${noRls.join(', ')}`);
    const buckets = await sql(`select id, public from storage.buckets where id in ('photos', 'chat-media', 'exports')`);
    if (buckets.length !== 3 || buckets.some((b) => b.public)) throw new StepError('storage buckets missing or public');
    // The private schema must not be reachable through the Data API.
    const r = await fetch(`${env.SUPABASE_URL}/rest/v1/accounts?select=user_id&limit=1`, { headers: { apikey: env.SUPABASE_PUBLISHABLE_KEY, 'accept-profile': 'private' } });
    if (r.ok) throw new StepError('the private schema is exposed through the Data API', { hint: 'Settings > Data API > Exposed schemas: keep only public (and graphql_public).' });
    // An anonymous caller sees no member rows.
    const anon = await fetch(`${env.SUPABASE_URL}/rest/v1/profiles?select=user_id&limit=1`, { headers: { apikey: env.SUPABASE_PUBLISHABLE_KEY } });
    const anonRows = anon.ok ? await anon.json() : [];
    if (anonRows.length) throw new StepError('anonymous callers can read profiles');
    const [{ n }] = await sql(`select count(*)::int as n from pg_proc p join pg_namespace s on s.oid = p.pronamespace
      where s.nspname = 'public' and p.proname in ('decide','send_message','send_compliment','register_attachment','request_export','staff_ops_health')`);
    if (n < 6) throw new StepError('expected RPCs are missing');
    const [store] = await sql(`select value from private.settings where key = 'store_environment'`);
    return { migrations: remote.length, buckets: buckets.map((b) => b.id), storeEnvironment: store?.value };
  },

  async 'store-env'() {
    const want = args['store-env'];
    if (!want) return { skipped: 'no --store-env given (store_environment unchanged)' };
    if (!['sandbox', 'production'].includes(want)) throw new StepError('--store-env must be sandbox or production');
    await sql(`update private.settings set value = $1 where key = 'store_environment'`, [want]);
    await sql(`insert into private.audit_log (actor, action, subject, detail) values (null, 'settings.store_environment', null, jsonb_build_object('value', $1::text, 'via', 'activate.mjs'))`, [want]);
    return { storeEnvironment: want };
  },

  async secrets() {
    if (!args['with-function-secrets']) return { skipped: 'no --with-function-secrets' };
    if (!env.SUPABASE_ACCESS_TOKEN) throw new StepError('SUPABASE_ACCESS_TOKEN is required to set function secrets');
    const allow = ['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', 'GOOGLE_PLAY_PACKAGE_NAME', 'GOOGLE_PUBSUB_PUSH_AUDIENCE',
      'GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT', 'APPLE_BUNDLE_ID', 'APPLE_ROOT_CA_G3_SHA256'];
    const present = allow.filter((k) => env[k]);
    if (!present.length) return { skipped: 'no store secrets in .env.local' };
    const dir = resolve(repoRoot, 'tools', 'backend', '.out');
    mkdirSync(dir, { recursive: true });
    const file = resolve(dir, `fn-secrets-${process.pid}.env`);
    writeFileSync(file, present.map((k) => `${k}=${env[k]}`).join('\n') + '\n', { mode: 0o600 });
    try {
      const r = await withRetry('secrets set', async () => {
        const x = runCli(['secrets', 'set', `--remote=${target.projectRef}`, '--env-file', file, '--yes'], { SUPABASE_ACCESS_TOKEN: env.SUPABASE_ACCESS_TOKEN });
        if (x.status !== 0) throw new StepError(`secrets set failed:\n${x.out}`, { retry: /timeout|5\d\d/i.test(x.out) });
        return x;
      });
      return { set: present, output: r.out.trim().slice(0, 200) };
    } finally { rmSync(file, { force: true }); }
  },

  async functions() {
    if (!env.SUPABASE_ACCESS_TOKEN) return { skipped: 'SUPABASE_ACCESS_TOKEN not set (store functions stay undeployed; purchases are disabled anyway)' };
    const out = {};
    for (const [name, extra] of [['verify-purchase', []], ['store-notifications', ['--no-verify-jwt']]]) {
      await withRetry(`deploy ${name}`, async () => {
        const r = runCli(['functions', 'deploy', name, `--remote=${target.projectRef}`, '--use-api', '--yes', ...extra], { SUPABASE_ACCESS_TOKEN: env.SUPABASE_ACCESS_TOKEN });
        if (r.status !== 0) throw new StepError(`deploy ${name} failed:\n${r.out}`, { retry: /timeout|5\d\d|reset/i.test(r.out) });
      }, { attempts: 3 });
      // Deployed but disabled: without STORE_VERIFICATION_ENABLED the function must answer 503.
      const r = await fetch(`${env.SUPABASE_URL}/functions/v1/${name}${name === 'store-notifications' ? '/google' : ''}`, {
        method: 'POST', headers: { apikey: env.SUPABASE_PUBLISHABLE_KEY, 'content-type': 'application/json' }, body: '{}',
      });
      out[name] = r.status;
    }
    return { deployed: Object.keys(out), probeStatus: out };
  },

  async schedules() {
    const jobs = await sql(`select jobid, jobname, schedule, active from cron.job where jobname = 'numaya-housekeeping'`)
      .catch((e) => { throw new StepError(`pg_cron not readable: ${e.message}`, { hint: 'Database > Extensions: enable pg_cron, then --from=migrate.' }); });
    if (!jobs.length || !jobs[0].active) throw new StepError('pg_cron job numaya-housekeeping missing or inactive');
    const [last] = await sql(`select status, start_time from cron.job_run_details where jobid = $1 order by start_time desc limit 1`, [jobs[0].jobid]).catch(() => []);
    // Run the same function once now so a broken housekeeping shows up immediately.
    await sql('select private.housekeeping()');
    return { cron: jobs[0].schedule, lastRun: last ? { status: last.status, at: last.start_time } : 'not yet run (hourly at :17)' };
  },

  async worker() {
    const { runOnce } = await import('../worker/run.mjs');
    const { results, failed } = await runOnce({ log: () => {} });
    if (failed) throw new StepError(`worker job failed: ${JSON.stringify(results)}`);
    return results;
  },

  async monitor() {
    const { checkHealth } = await import('./monitor.mjs');
    const r = await checkHealth();
    if (r.alerts.length) console.log(`  monitor alerts: ${r.alerts.join('; ')}`);
    return { alerts: r.alerts };
  },

  async tests() {
    const dir = resolve(repoRoot, 'tools', 'backend');
    const r = spawnSync(process.execPath, ['--test', '--test-concurrency=1', '--test-reporter=tap', 'tests/*.test.mjs'], { cwd: dir, encoding: 'utf8', shell: false, timeout: 20 * 60_000 });
    const out = redact(`${r.stdout || ''}${r.stderr || ''}`);
    mkdirSync(resolve(dir, '.out'), { recursive: true });
    const logFile = resolve(dir, '.out', `real-tests-${stamp}.tap`);
    writeFileSync(logFile, out);
    const count = (k) => Number((out.match(new RegExp(`^# ${k} (\\d+)`, 'm')) || [])[1] || 0);
    const res = { pass: count('pass'), fail: count('fail'), skipped: count('skipped'), log: logFile.replace(repoRoot, '.') };
    if (r.status !== 0 || res.fail) {
      const firsts = out.split('\n').filter((l) => /^\s*not ok/.test(l)).slice(0, 10).join('\n');
      throw new StepError(`real-service tests failed (${res.fail} failing):\n${firsts}`, { hint: `Full TAP log: ${res.log}` });
    }
    return res;
  },

  async apk() {
    if (args['skip-apk']) return { skipped: '--skip-apk' };
    const app = resolve(repoRoot, 'apps', 'numaya_mobile');
    const dir = resolve(repoRoot, 'tools', 'backend', '.out');
    mkdirSync(dir, { recursive: true });
    const defines = resolve(dir, 'dart-defines.dev.json');
    // Only the URL and the PUBLISHABLE key are bundled (both are public by design).
    writeFileSync(defines, JSON.stringify({
      NUMAYA_SUPABASE_URL: env.SUPABASE_URL.replace(/\/$/, ''),
      NUMAYA_SUPABASE_PUBLISHABLE_KEY: env.SUPABASE_PUBLISHABLE_KEY,
      NUMAYA_BACKEND_LABEL: 'development',
      ...(args.attachments ? { NUMAYA_LIVE_ATTACHMENTS: 'true' } : {}),
    }, null, 2));
    const flutter = process.platform === 'win32' ? 'flutter.bat' : 'flutter';
    // Debug build: the release guard forbids a development backend in release builds.
    const r = spawnSync(flutter, ['build', 'apk', '--debug', `--dart-define-from-file=${defines}`], { cwd: app, encoding: 'utf8', shell: process.platform === 'win32', timeout: 30 * 60_000 });
    if (r.status !== 0) throw new StepError(`flutter build failed:\n${redact((r.stdout || '') + (r.stderr || '')).split('\n').slice(-25).join('\n')}`);
    const apk = resolve(app, 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk');
    if (!existsSync(apk)) throw new StepError('APK not found after build');
    const sha256 = createHash('sha256').update(readFileSync(apk)).digest('hex');
    const commit = spawnSync('git', ['rev-parse', 'HEAD'], { cwd: repoRoot, encoding: 'utf8' }).stdout.trim();
    return { apk: apk.replace(repoRoot, '.'), sha256, commit, attachments: !!args.attachments,
      note: 'Private development build: contains local-only demo assets if installed. Do not upload publicly.' };
  },
};

// ------------------------------------------------------------------------------------------------
const stamp = new Date().toISOString().replace(/[:.]/g, '-');

async function main() {
  try { env = loadEnv(); } catch (e) {
    console.error(`config: ${e.message}`);
    process.exit(2);
  }
  redact = (s) => [env.SUPABASE_DB_URL, env.SUPABASE_DB_PASSWORD, env.SUPABASE_SECRET_KEY, env.SUPABASE_ACCESS_TOKEN,
    env.FCM_SERVICE_ACCOUNT_JSON, env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON, env.NUMAYA_STAFF_PASSWORD, env.NUMAYA_BACKUP_KEY]
    .filter((v) => v && v.length > 6).reduce((acc, v) => acc.split(v).join('<redacted>'), s || '');
  try { target = describeTarget(env); } catch { target = { projectRef: '?', host: '?' }; }

  if (args.check) {
    const r = await steps.config().catch((e) => { console.error(e.message); process.exit(1); });
    console.log(`config ok for ${target.projectRef}; optional: ${JSON.stringify(r.optionalEnabled)}`);
    return;
  }
  let order = STEPS;
  if (args.only) order = [args.only];
  else if (args.from) order = STEPS.slice(STEPS.indexOf(args.from));
  if (order.some((s) => !STEPS.includes(s))) { console.error(`Unknown step. Steps: ${STEPS.join(', ')}`); process.exit(2); }
  // config and confirm always run first, even when resuming.
  order = [...new Set(['config', 'confirm', ...order])];

  console.log(`Numaya development activation -> ${target.projectRef} (${target.host})`);
  let failed = null;
  for (const name of order) {
    process.stdout.write(`\n[${name}]\n`);
    const t0 = Date.now();
    try {
      const res = await steps[name]();
      report.steps[name] = { ok: true, ms: Date.now() - t0, ...res };
      console.log(`  ok ${JSON.stringify(res)}`);
    } catch (e) {
      report.steps[name] = { ok: false, ms: Date.now() - t0, error: redact(e.message) };
      console.error(`  FAILED: ${redact(e.message)}`);
      if (e.hint) console.error(`  hint: ${e.hint}`);
      console.error(`  resume: node scripts/activate.mjs --confirm-project=${target.projectRef} --from=${name}${args['plan-only'] ? ' --plan-only' : ''}`);
      failed = name;
      break;
    }
  }
  report.finishedAt = new Date().toISOString();
  report.target = target;
  report.commit = spawnSync('git', ['rev-parse', 'HEAD'], { cwd: repoRoot, encoding: 'utf8' }).stdout.trim();
  const evidence = resolve(repoRoot, 'docs', 'backend', 'evidence');
  mkdirSync(evidence, { recursive: true });
  const file = resolve(evidence, `activation-${stamp}.json`);
  writeFileSync(file, redact(JSON.stringify(report, null, 2)) + '\n');
  console.log(`\nReport: ${file.replace(repoRoot, '.')}`);
  process.exit(failed ? 1 : 0);
}

if (process.argv[1]?.endsWith('activate.mjs')) await main();

// Applies supabase/migrations to the configured DEVELOPMENT project with the official CLI.
// Never prints the connection string. Refuses to run against a project marked production.
import { spawnSync } from 'node:child_process';
import { resolve } from 'node:path';
import { loadEnv, repoRoot, describeTarget } from '../lib/env.mjs';

const env = loadEnv();
if ((env.NUMAYA_ENVIRONMENT || 'development') !== 'development') {
  console.error('Refusing: NUMAYA_ENVIRONMENT is not "development". Production migrations need explicit owner approval.');
  process.exit(2);
}
const target = describeTarget(env);
console.log(`Applying migrations to development project ${target.projectRef} (${target.host})`);
// The CLI's Node entry point, run without a shell so the URL is never re-parsed.
const cli = process.execPath;
const cliEntry = resolve(repoRoot, 'tools', 'backend', 'node_modules', 'supabase', 'dist', 'supabase.js');
const args = [cliEntry, 'db', 'push', `--remote=${env.SUPABASE_DB_URL}`, '--include-all', '--yes'];
if (process.argv.includes('--dry-run')) args.push('--dry-run');
const r = spawnSync(cli, args, {
  cwd: repoRoot, encoding: 'utf8', shell: false,
  input: 'y\n', env: { ...process.env, SUPABASE_YES: '1' },
});
const redact = (s) => (s || '').split(env.SUPABASE_DB_URL).join('<db-url>')
  .split(env.SUPABASE_DB_PASSWORD || '\u0000').join('<password>');
process.stdout.write(redact(r.stdout));
process.stderr.write(redact(r.stderr));
process.exit(r.status ?? 1);

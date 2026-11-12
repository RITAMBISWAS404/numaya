// Loads supabase/.env.local without printing values. Fails loudly if the backend is not configured:
// tests never fall back to fixtures.
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
export const repoRoot = resolve(here, '..', '..', '..');
const envPath = resolve(repoRoot, 'supabase', '.env.local');

export function loadEnv() {
  if (!existsSync(envPath)) {
    throw new Error(`Backend not configured: ${envPath} is missing (see supabase/.env.example).`);
  }
  const env = {};
  for (const line of readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith('#') || !t.includes('=')) continue;
    const i = t.indexOf('=');
    env[t.slice(0, i).trim()] = t.slice(i + 1).trim();
  }
  for (const k of ['SUPABASE_URL', 'SUPABASE_PUBLISHABLE_KEY', 'SUPABASE_SECRET_KEY', 'SUPABASE_DB_URL']) {
    if (!env[k]) throw new Error(`Backend not configured: ${k} is empty in supabase/.env.local.`);
  }
  return env;
}

/** A redacted description of the target, safe for logs and evidence. */
export function describeTarget(env) {
  const host = new URL(env.SUPABASE_URL).host;
  return { host, projectRef: env.SUPABASE_PROJECT_REF || host.split('.')[0] };
}

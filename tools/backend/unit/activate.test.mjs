// Contract tests for the activation workflow's configuration validation (FIXTURE values only:
// no network, no real project). The live steps are exercised by running activate.mjs itself.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { validateConfig } from '../scripts/activate.mjs';

const ref = 'abcdefghijklmnopqrst'; // FIXTURE ref (20 chars)
const base = {
  SUPABASE_PROJECT_REF: ref,
  SUPABASE_URL: `https://${ref}.supabase.co`,
  SUPABASE_PUBLISHABLE_KEY: 'sb_publishable_FIXTURE',
  SUPABASE_SECRET_KEY: 'sb_secret_FIXTURE',
  SUPABASE_DB_URL: `postgresql://postgres.${ref}:pw@aws-0-ap-south-1.pooler.supabase.com:5432/postgres`,
};

test('a complete minimal configuration validates', () => {
  const r = validateConfig(base);
  assert.deepEqual(r.errors, []);
});

test('wrong key types, mismatched project and production label are refused', () => {
  const r = validateConfig({ ...base, SUPABASE_PUBLISHABLE_KEY: 'sb_secret_x', SUPABASE_PROJECT_REF: 'zzzzzzzzzzzzzzzzzzzz', NUMAYA_ENVIRONMENT: 'production' });
  assert.ok(r.errors.some((e) => e.includes('SUPABASE_PUBLISHABLE_KEY')));
  assert.ok(r.errors.some((e) => e.includes('does not match')));
  assert.ok(r.errors.some((e) => e.includes('NUMAYA_ENVIRONMENT')));
});

test('optional groups are all-or-nothing and shape-checked', () => {
  const r = validateConfig({ ...base, NUMAYA_TEST_PHONE_A: '+91 900', NUMAYA_STAFF_EMAIL: 'staff@example.invalid', NUMAYA_BACKUP_KEY: 'c2hvcnQ=', FCM_SERVICE_ACCOUNT_JSON: 'bm90IGpzb24=', APPLE_BUNDLE_ID: 'com.example' });
  for (const k of ['test phone A', 'staff account', 'NUMAYA_BACKUP_KEY', 'FCM_SERVICE_ACCOUNT_JSON', 'APPLE_ROOT_CA_G3_SHA256', 'digits only']) {
    assert.ok(r.errors.some((e) => e.includes(k)), k);
  }
  const ok = validateConfig({ ...base, NUMAYA_BACKUP_KEY: randomBytes(32).toString('base64'), NUMAYA_TEST_PHONE_A: '919000000001', NUMAYA_TEST_OTP_A: '123456' });
  assert.deepEqual(ok.errors, []);
  assert.equal(ok.enabled.backup, true);
  assert.equal(ok.enabled.phoneTestA, true);
});

test('STORE_VERIFICATION_ENABLED is never taken from the env file', () => {
  const r = validateConfig({ ...base, STORE_VERIFICATION_ENABLED: 'true' });
  assert.ok(r.warnings.some((w) => w.includes('manual step')));
});

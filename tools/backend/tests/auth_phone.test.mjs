// Phone OTP through Supabase Auth with the project's configured TEST numbers (no SMS is sent).
// This exercises the same auth path the Flutter app uses. Real SMS delivery is a separate,
// provider-dependent check (PROVIDER_STATUS: blocked until an SMS provider and budget exist).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createClient } from '@supabase/supabase-js';
import { env } from '../lib/harness.mjs';

const phone = env.NUMAYA_TEST_PHONE_A;
const otp = env.NUMAYA_TEST_OTP_A;
const opts = { auth: { persistSession: false, autoRefreshToken: false } };

test('phone OTP sign-in with a configured test number', { skip: !phone || !otp ? 'NUMAYA_TEST_PHONE_A/OTP_A not set in supabase/.env.local' : false }, async () => {
  const client = createClient(env.SUPABASE_URL, env.SUPABASE_PUBLISHABLE_KEY, opts);
  const send = await client.auth.signInWithOtp({ phone: `+${phone}` });
  assert.equal(send.error, null, send.error?.message);
  const wrong = await client.auth.verifyOtp({ phone: `+${phone}`, token: otp === '000000' ? '111111' : '000000', type: 'sms' });
  assert.ok(wrong.error, 'a wrong code is refused');
  const ok = await client.auth.verifyOtp({ phone: `+${phone}`, token: otp, type: 'sms' });
  assert.equal(ok.error, null, ok.error?.message);
  assert.ok(ok.data.session?.access_token, 'a session is issued');
  // The sign-up bootstrap created the private account and the empty profile.
  const prof = await client.from('profiles').select('user_id, onboarding_complete').eq('user_id', ok.data.user.id);
  assert.equal(prof.data.length, 1);
  await client.auth.signOut();
});

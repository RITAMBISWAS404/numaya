// Moderation and support CLI. Signs in as a STAFF account (provisioned out of band; role in
// private.staff_members) and uses only the audited staff_* RPCs: no direct table access, no
// chat browsing. Usage:
//   node scripts/staff.mjs health
//   node scripts/staff.mjs photos                 (pending review, with 5-minute preview links)
//   node scripts/staff.mjs approve <photo id> | reject <photo id> "<reason>"
//   node scripts/staff.mjs reports
//   node scripts/staff.mjs resolve <report id> dismiss|suspend "<note>"
//   node scripts/staff.mjs clear-hold <user id> "<note>"
// Needs NUMAYA_STAFF_EMAIL and NUMAYA_STAFF_PASSWORD in supabase/.env.local (a staff account
// with MFA is a launch requirement; this CLI is for the controlled beta).
import { createClient } from '@supabase/supabase-js';
import { loadEnv } from '../lib/env.mjs';

const env = loadEnv();
if (!env.NUMAYA_STAFF_EMAIL || !env.NUMAYA_STAFF_PASSWORD) {
  console.error('Set NUMAYA_STAFF_EMAIL and NUMAYA_STAFF_PASSWORD (a provisioned staff account).');
  process.exit(2);
}
const client = createClient(env.SUPABASE_URL, env.SUPABASE_PUBLISHABLE_KEY, { auth: { persistSession: false } });
const signIn = await client.auth.signInWithPassword({ email: env.NUMAYA_STAFF_EMAIL, password: env.NUMAYA_STAFF_PASSWORD });
if (signIn.error) { console.error(`Sign-in failed: ${signIn.error.message}`); process.exit(2); }

const call = async (fn, args = {}) => {
  const { data, error } = await client.rpc(fn, args);
  if (error) { console.error(`${fn}: ${error.message}`); process.exit(1); }
  return data;
};

const [cmd, a1, a2, a3] = process.argv.slice(2);
switch (cmd) {
  case 'health':
    console.log(JSON.stringify(await call('staff_ops_health'), null, 2));
    break;
  case 'photos': {
    for (const p of await call('staff_photo_queue', { p_limit: 20 })) {
      const { data } = await client.storage.from('photos').createSignedUrl(p.object_path, 300);
      console.log(`${p.photo_id}  ${p.width}x${p.height}  ${p.created_at}  ${data?.signedUrl ?? '(no preview access)'}`);
    }
    break;
  }
  case 'approve': await call('staff_decide_photo', { p_photo: a1, p_approve: true }); console.log('approved'); break;
  case 'reject': await call('staff_decide_photo', { p_photo: a1, p_approve: false, p_reason: a2 ?? 'Does not meet the photo rules' }); console.log('rejected'); break;
  case 'reports':
    for (const r of await call('staff_report_queue', { p_limit: 20 })) {
      console.log(`${r.report_id}  ${r.category}  subject ${r.subject_id}  ${r.created_at}\n  note: ${r.note ?? ''}\n  evidence messages: ${r.evidence?.messages?.length ?? 0}`);
    }
    break;
  case 'resolve': await call('staff_resolve_report', { p_report: a1, p_action: a2, p_note: a3 ?? null }); console.log('resolved'); break;
  case 'clear-hold': await call('staff_clear_hold', { p_user: a1, p_note: a2 ?? '' }); console.log('hold cleared'); break;
  default:
    console.log('Commands: health | photos | approve <id> | reject <id> "<reason>" | reports | resolve <id> dismiss|suspend "<note>" | clear-hold <user> "<note>"');
}
await client.auth.signOut();

// Compliments (pending conversation before a match), the credit ledger and streak rewards.
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { member, rpc, rpcError, cleanup, key, sql } from '../lib/harness.mjs';

after(cleanup);

const promptOf = async (u) =>
  (await sql('select id from public.prompts where user_id = $1 order by position limit 1', [u.id]))[0].id;
const setEarned = (u, n) => sql(`insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
  select $1, 'earned', $2 - coalesce(sum(delta), 0), 'reversal', 'test-set:' || gen_random_uuid()
  from private.credit_ledger where user_id = $1 and bucket = 'earned'
  having $2 - coalesce(sum(delta), 0) <> 0`, [u.id, n]);

test('welcome credits: 3 earned, granted once', async () => {
  const a = await member('welcome', { gender: 'woman', openTo: ['man'] });
  const w = await rpc(a, 'my_wallet');
  assert.equal(w.earned, 3);
  await rpc(a, 'complete_onboarding', { p_birth_date: '1995-06-15', p_terms_version: '2026-11',
    p_privacy_version: '2026-11', p_community_version: '2026-11' });
  assert.equal((await rpc(a, 'my_wallet')).earned, 3, 'repeating onboarding grants nothing');
});

test('a Compliment opens a pending conversation; only the recipient can reply; reply unlocks chat', async () => {
  const s = await member('cSender', { gender: 'man', openTo: ['woman'] });
  const r = await member('cRecipient', { gender: 'woman', openTo: ['man'] });
  const sent = await rpc(s, 'send_compliment', { p_target: r.id, p_target_kind: 'prompt',
    p_target_ref: await promptOf(r), p_body: 'Love this answer!', p_key: key() });
  assert.equal(sent.result, 'sent');
  const conv = sent.conversation_id;
  assert.equal((await rpc(s, 'my_wallet')).total, 2, 'one credit spent');

  const listR = await rpc(r, 'list_conversations');
  const rowR = listR.find((x) => x.conversation_id === conv);
  assert.equal(rowR.state, 'pending_incoming');
  const listS = await rpc(s, 'list_conversations');
  assert.equal(listS.find((x) => x.conversation_id === conv).state, 'pending_outgoing');

  assert.equal(await rpcError(s, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'hi?' }),
    'awaiting_reply', 'the sender cannot write before the reply');
  assert.equal(await rpcError(s, 'reply_compliment', { p_conversation: conv, p_client_message_id: key(), p_body: 'x' }),
    'forbidden', 'the sender cannot accept for the recipient');
  assert.equal(await rpcError(s, 'send_compliment', { p_target: r.id, p_target_kind: 'prompt',
    p_target_ref: await promptOf(r), p_body: 'Again', p_key: key() }), 'already_sent', 'one per pair');

  const replyKey = key();
  await rpc(r, 'reply_compliment', { p_conversation: conv, p_client_message_id: replyKey, p_body: 'Thank you!' });
  const replay = await rpc(r, 'reply_compliment', { p_conversation: conv, p_client_message_id: replyKey, p_body: 'Thank you!' });
  assert.equal(replay.replayed, true);
  await rpc(s, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'Coffee sometime?' });
  const msgs = await r.client.from('messages').select('seq,kind,body').eq('conversation_id', conv).order('seq');
  assert.deepEqual(msgs.data.map((m) => [m.seq, m.kind]), [[1, 'compliment'], [2, 'text'], [3, 'text']]);
  const n = await sql(`select count(*)::int as n from public.conversations
    where user_a = least($1::uuid,$2::uuid) and user_b = greatest($1::uuid,$2::uuid)`, [s.id, r.id]);
  assert.equal(n[0].n, 1, 'one thread per pair');
});

test('with exactly one credit, concurrent Compliments spend at most one', async () => {
  const s = await member('oneCredit', { gender: 'man', openTo: ['woman'] });
  const targets = [];
  for (let i = 0; i < 4; i++) targets.push(await member(`ocT${i}`, { gender: 'woman', openTo: ['man'] }));
  await setEarned(s, 1);
  const out = await Promise.allSettled(await Promise.all(targets.map(async (t) =>
    rpc(s, 'send_compliment', { p_target: t.id, p_target_kind: 'prompt', p_target_ref: await promptOf(t),
      p_body: 'Hello there', p_key: key() }))));
  const sent = out.filter((o) => o.status === 'fulfilled');
  const refused = out.filter((o) => o.status === 'rejected').map((o) => o.reason.message);
  assert.equal(sent.length, 1);
  assert.deepEqual([...new Set(refused)], ['no_credits']);
  const bal = await sql(`select coalesce(sum(delta),0)::int as b from private.credit_ledger where user_id = $1`, [s.id]);
  assert.equal(bal[0].b, 0, 'balance never negative');
  const convs = await sql(`select count(*)::int as n from public.conversations where $1 in (user_a, user_b)`, [s.id]);
  assert.equal(convs[0].n, 1, 'failed sends leave no conversation behind');
});

test('Compliment retry with the same key spends once; a changed payload is refused', async () => {
  const s = await member('cRetry', { gender: 'man', openTo: ['woman'] });
  const r = await member('cRetryR', { gender: 'woman', openTo: ['man'] });
  const k = key();
  const args = { p_target: r.id, p_target_kind: 'prompt', p_target_ref: await promptOf(r), p_body: 'Same words', p_key: k };
  const [x, y] = await Promise.allSettled([rpc(s, 'send_compliment', args), rpc(s, 'send_compliment', args)]);
  const ok = [x, y].filter((o) => o.status === 'fulfilled');
  assert.ok(ok.length >= 1);
  assert.equal((await rpc(s, 'my_wallet')).total, 2, 'charged once');
  assert.equal(await rpcError(s, 'send_compliment', { ...args, p_body: 'Different words' }), 'idempotency_conflict');
});

test('Compliments target only an approved photo or a prompt of that member (never the bio)', async () => {
  const s = await member('cTarget', { gender: 'man', openTo: ['woman'] });
  const r = await member('cTargetR', { gender: 'woman', openTo: ['man'] });
  assert.equal(await rpcError(s, 'send_compliment', { p_target: r.id, p_target_kind: 'bio', p_target_ref: r.id,
    p_body: 'hi', p_key: key() }), 'target_invalid');
  assert.equal(await rpcError(s, 'send_compliment', { p_target: r.id, p_target_kind: 'photo',
    p_target_ref: s.photos[0].photoId, p_body: 'hi', p_key: key() }), 'target_unavailable');
  assert.equal((await rpc(s, 'my_wallet')).total, 3, 'nothing spent on refused sends');
});

test('dismissing gives no refund and the sender still sees "pending"', async () => {
  const s = await member('dSender', { gender: 'man', openTo: ['woman'] });
  const r = await member('dRecipient', { gender: 'woman', openTo: ['man'] });
  const { conversation_id: conv } = await rpc(s, 'send_compliment', { p_target: r.id, p_target_kind: 'photo',
    p_target_ref: r.photos[0].photoId, p_body: 'Great photo', p_key: key() });
  await rpc(r, 'dismiss_compliment', { p_conversation: conv });
  assert.ok(!(await rpc(r, 'list_conversations')).some((x) => x.conversation_id === conv), 'hidden for the recipient');
  const row = (await rpc(s, 'list_conversations')).find((x) => x.conversation_id === conv);
  assert.equal(row.compliment.status, 'pending', 'dismissal is not disclosed to the sender');
  assert.equal((await rpc(s, 'my_wallet')).total, 2);
});

test('liking someone whose Compliment is pending matches, with the Compliment as message one', async () => {
  const s = await member('lmSender', { gender: 'man', openTo: ['woman'] });
  const r = await member('lmRecipient', { gender: 'woman', openTo: ['man'] });
  const { conversation_id: conv } = await rpc(s, 'send_compliment', { p_target: r.id, p_target_kind: 'prompt',
    p_target_ref: await promptOf(r), p_body: 'Nice', p_key: key() });
  const like = await rpc(r, 'decide', { p_target: s.id, p_kind: 'like', p_key: key() });
  assert.equal(like.result, 'matched');
  assert.equal(like.conversation_id, conv);
  const row = (await rpc(s, 'list_conversations')).find((x) => x.conversation_id === conv);
  assert.equal(row.state, 'active');
});

test('the earned bucket caps at 5: an award at the cap is skipped', async () => {
  const a = await member('cap', { gender: 'woman', openTo: ['man'] });
  await setEarned(a, 5);
  // Seven qualifying days ending today (server-observed rows, back-dated for the test).
  await sql(`insert into private.daily_usage (user_id, day, qualified)
             select $1, private.ist_day() - g, true from generate_series(1, 6) g`, [a.id]);
  const targets = [];
  for (let i = 0; i < 3; i++) targets.push(await member(`capT${i}`, { gender: 'man', openTo: ['woman'] }));
  for (const t of targets) await rpc(a, 'decide', { p_target: t.id, p_kind: 'pass', p_key: key() });
  const w = await rpc(a, 'my_wallet');
  assert.equal(w.earned, 5, 'no award above the cap');
  assert.equal(w.streak.run, 7);
  const skipped = await sql(`select count(*)::int as n from private.audit_log
    where subject = $1 and action = 'credit_award_skipped_at_cap'`, [a.id]);
  assert.equal(skipped[0].n, 1);
});

test('a seven-day streak awards one credit, once, even if qualifying activity repeats', async () => {
  const a = await member('streak', { gender: 'woman', openTo: ['man'] });
  await setEarned(a, 0);
  await sql(`insert into private.daily_usage (user_id, day, qualified)
             select $1, private.ist_day() - g, true from generate_series(1, 6) g`, [a.id]);
  const targets = [];
  for (let i = 0; i < 5; i++) targets.push(await member(`stT${i}`, { gender: 'man', openTo: ['woman'] }));
  await Promise.all(targets.map((t) => rpc(a, 'decide', { p_target: t.id, p_kind: 'pass', p_key: key() })));
  const w = await rpc(a, 'my_wallet');
  assert.equal(w.earned, 1, 'exactly one award for the cycle');
  const awards = await sql(`select count(*)::int as n from private.credit_ledger
    where user_id = $1 and reason = 'streak'`, [a.id]);
  assert.equal(awards[0].n, 1);
});

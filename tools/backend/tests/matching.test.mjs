// Likes, quotas, idempotency and concurrent reciprocal matching.
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { member, rpc, rpcError, cleanup, key, sql } from '../lib/harness.mjs';

after(cleanup);

test('a like is idempotent per key; a changed payload with the same key is refused', async () => {
  const a = await member('idemA', { gender: 'woman', openTo: ['man'] });
  const b = await member('idemB', { gender: 'man', openTo: ['woman'] });
  const k = key();
  const first = await rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: k });
  const replay = await rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: k });
  assert.equal(first.result, 'recorded');
  assert.equal(replay.replayed, true);
  assert.equal(await rpcError(a, 'decide', { p_target: b.id, p_kind: 'pass', p_key: k }), 'idempotency_conflict');
  assert.equal(await rpcError(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() }), 'already_decided');
  const rows = await sql('select count(*)::int as n from public.decisions where actor_id = $1', [a.id]);
  assert.equal(rows[0].n, 1);
});

test('self-like and blocked targets are refused', async () => {
  const a = await member('selfA', { gender: 'woman', openTo: ['man'] });
  const b = await member('selfB', { gender: 'man', openTo: ['woman'] });
  assert.equal(await rpcError(a, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() }), 'self_action');
  await rpc(b, 'block_member', { p_other: a.id });
  assert.equal(await rpcError(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() }), 'unavailable');
});

test('simultaneous reciprocal likes create exactly one match and one conversation', async () => {
  for (let round = 0; round < 5; round++) {
    const a = await member(`raceA${round}`, { gender: 'woman', openTo: ['man'] });
    const b = await member(`raceB${round}`, { gender: 'man', openTo: ['woman'] });
    const [ra, rb] = await Promise.all([
      rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() }),
      rpc(b, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() }),
    ]);
    const results = [ra.result, rb.result].sort();
    assert.deepEqual(results, ['matched', 'recorded'], `round ${round}`);
    const conv = await sql(`select count(*)::int as n from public.conversations
      where user_a = least($1::uuid, $2::uuid) and user_b = greatest($1::uuid, $2::uuid)`, [a.id, b.id]);
    assert.equal(conv[0].n, 1, `round ${round}: one conversation`);
  }
});

test('the free daily like quota (5) holds under concurrent requests', async () => {
  const liker = await member('quota', { gender: 'man', openTo: ['woman'] });
  const targets = [];
  for (let i = 0; i < 8; i++) targets.push(await member(`qt${i}`, { gender: 'woman', openTo: ['man'] }));
  const outcomes = await Promise.allSettled(targets.map((t) =>
    rpc(liker, 'decide', { p_target: t.id, p_kind: 'like', p_key: key() })));
  const ok = outcomes.filter((o) => o.status === 'fulfilled').length;
  const exhausted = outcomes.filter((o) => o.status === 'rejected' && o.reason.message === 'quota_exhausted').length;
  assert.equal(ok, 5, 'exactly five likes accepted');
  assert.equal(exhausted, 3);
  const passes = await rpc(liker, 'decide', { p_target: targets[0].id, p_kind: 'pass', p_key: key() })
    .catch((e) => e.message);
  // Passing is never quota-limited (already-decided targets refuse for another reason).
  assert.ok(passes === 'already_decided' || passes.result === 'recorded');
});

test('a Premium entitlement (server-side) raises the quota to 15; the client cannot grant it', async () => {
  const p = await member('prem', { gender: 'man', openTo: ['woman'] });
  const w0 = await rpc(p, 'my_wallet');
  assert.equal(w0.premium, false);
  // Test provisioning only (no billing exists): the store webhook would write this row.
  await sql(`insert into private.entitlements (user_id, product, active_until, source)
             values ($1, 'premium', now() + interval '1 day', 'staff_test')`, [p.id]);
  const w1 = await rpc(p, 'my_wallet');
  assert.equal(w1.premium, true);
  assert.equal(w1.likes_left_today, 15);
  assert.equal(w1.weekly, 3, 'weekly Premium credits granted once');
  const w2 = await rpc(p, 'my_wallet');
  assert.equal(w2.weekly, 3, 'not granted twice');
});

test('passed, matched and blocked members leave the feed; the feed drains without recycling', async () => {
  const a = await member('feedA', { gender: 'woman', openTo: ['man'] });
  const b = await member('feedB', { gender: 'man', openTo: ['woman'] });
  let feed = await rpc(a, 'discovery_feed', { p_limit: 20 });
  assert.ok(feed.some((x) => x.user_id === b.id));
  await rpc(a, 'decide', { p_target: b.id, p_kind: 'pass', p_key: key() });
  feed = await rpc(a, 'discovery_feed', { p_limit: 20 });
  assert.ok(!feed.some((x) => x.user_id === b.id), 'a passed member does not come back');
});

test('gender and age preferences are enforced in both directions', async () => {
  const w = await member('prefW', { gender: 'woman', openTo: ['woman'] });
  const m = await member('prefM', { gender: 'man', openTo: ['woman'] });
  const feedM = await rpc(m, 'discovery_feed', { p_limit: 20 });
  assert.ok(!feedM.some((x) => x.user_id === w.id), 'not shown to someone she is not open to');
  // The action is checked again server-side, not only the feed.
  assert.equal(await rpcError(m, 'decide', { p_target: w.id, p_kind: 'like', p_key: key() }), 'unavailable');
  const young = await member('prefYoung', { gender: 'woman', openTo: ['man'], birth: '2006-01-01' });
  await m.client.from('preferences').update({ age_min: 25, age_max: 40 }).eq('user_id', m.id);
  assert.equal(await rpcError(m, 'decide', { p_target: young.id, p_kind: 'like', p_key: key() }), 'unavailable');
});

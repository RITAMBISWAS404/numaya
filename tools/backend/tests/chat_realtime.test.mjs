// Chat ordering, idempotent retries, realtime authorization, block/unmatch revocation, reports.
import { test, after, before } from 'node:test';
import assert from 'node:assert/strict';
import { member, rpc, rpcError, cleanup, key, sql, staff } from '../lib/harness.mjs';

after(cleanup);

async function matchedPair(label) {
  const a = await member(`${label}A`, { gender: 'woman', openTo: ['man'] });
  const b = await member(`${label}B`, { gender: 'man', openTo: ['woman'] });
  await rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() });
  const m = await rpc(b, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() });
  assert.equal(m.result, 'matched');
  return { a, b, conv: m.conversation_id };
}

test('concurrent sends get contiguous sequence numbers; retries never duplicate', async () => {
  const { a, b, conv } = await matchedPair('seq');
  const ids = Array.from({ length: 12 }, () => key());
  const sends = ids.flatMap((id, i) => [
    rpc(i % 2 ? a : b, 'send_message', { p_conversation: conv, p_client_message_id: id, p_body: `m${i}` }),
    // The same client id sent again (a retry after a lost response).
    rpc(i % 2 ? a : b, 'send_message', { p_conversation: conv, p_client_message_id: id, p_body: `m${i}` }),
  ]);
  const results = await Promise.allSettled(sends);
  assert.ok(results.every((r) => r.status === 'fulfilled'), JSON.stringify(results.filter((r) => r.status === 'rejected').map((r) => r.reason.message)));
  const rows = await sql('select seq, client_message_id from public.messages where conversation_id = $1 order by seq', [conv]);
  assert.equal(rows.length, 12, 'one row per client message id');
  assert.deepEqual(rows.map((r) => Number(r.seq)), Array.from({ length: 12 }, (_, i) => i + 1), 'no gaps, no duplicates');
});

test('history is cursor-paginated and readable only by the two members', async () => {
  const { a, b, conv } = await matchedPair('page');
  for (let i = 0; i < 7; i++) await rpc(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: `p${i}` });
  const first = await b.client.from('messages').select('seq').eq('conversation_id', conv).order('seq', { ascending: false }).limit(3);
  const before = first.data.at(-1).seq;
  const next = await b.client.from('messages').select('seq').eq('conversation_id', conv).lt('seq', before)
    .order('seq', { ascending: false }).limit(3);
  assert.deepEqual(first.data.map((x) => x.seq), [7, 6, 5]);
  assert.deepEqual(next.data.map((x) => x.seq), [4, 3, 2]);
  const outsider = await member('pageC', { gender: 'man', openTo: ['woman'] });
  const peek = await outsider.client.from('messages').select('*').eq('conversation_id', conv);
  assert.equal(peek.data.length, 0);
  assert.equal(await rpcError(outsider, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'hey' }), 'not_found');
  assert.equal(await rpcError(outsider, 'mark_read', { p_conversation: conv, p_seq: 3 }), 'not_found');
});

test('realtime delivers to the member and not to an outsider', async () => {
  const { a, b, conv } = await matchedPair('rt');
  const outsider = await member('rtC', { gender: 'man', openTo: ['woman'] });
  const got = { b: [], c: [] };
  const subscribe = (user, sink) => new Promise((resolve, reject) => {
    const ch = user.client.channel(`m-${user.id}`)
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'messages' }, (p) => sink.push(p.new))
      .subscribe((status, err) => {
        if (status === 'SUBSCRIBED') resolve(ch);
        if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') reject(err ?? new Error(status));
      });
  });
  await b.client.realtime.setAuth((await b.client.auth.getSession()).data.session.access_token);
  await outsider.client.realtime.setAuth((await outsider.client.auth.getSession()).data.session.access_token);
  const chB = await subscribe(b, got.b);
  const chC = await subscribe(outsider, got.c);
  await new Promise((r) => setTimeout(r, 1500));
  await rpc(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'realtime hello' });
  for (let i = 0; i < 20 && got.b.length === 0; i++) await new Promise((r) => setTimeout(r, 500));
  await new Promise((r) => setTimeout(r, 1500));
  await b.client.removeChannel(chB);
  await outsider.client.removeChannel(chC);
  assert.equal(got.b.length, 1, 'member receives the insert');
  assert.equal(got.b[0].conversation_id, conv);
  assert.equal(got.c.length, 0, 'outsider receives nothing');
});

test('unmatch revokes reading and sending for both members', async () => {
  const { a, b, conv } = await matchedPair('unm');
  await rpc(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'before' });
  await rpc(b, 'unmatch', { p_conversation: conv });
  for (const u of [a, b]) {
    const r = await u.client.from('messages').select('*').eq('conversation_id', conv);
    assert.equal(r.data.length, 0, 'history no longer readable');
    assert.equal(await rpcError(u, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'after' }), 'unavailable');
  }
  assert.ok(!(await rpc(a, 'list_conversations')).some((x) => x.conversation_id === conv));
  const feed = await rpc(a, 'discovery_feed', { p_limit: 20 });
  assert.ok(!feed.some((x) => x.user_id === b.id), 'no rematch through discovery');
});

test('block revokes the chat, the profile and photo access; unblocking never reopens it', async () => {
  const { a, b, conv } = await matchedPair('blk');
  await rpc(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'hello' });
  const before = await b.client.from('profiles').select('user_id').eq('user_id', a.id);
  assert.equal(before.data.length, 1, 'counterpart profile visible while matched');
  await rpc(b, 'block_member', { p_other: a.id });
  const after = await b.client.from('profiles').select('user_id').eq('user_id', a.id);
  assert.equal(after.data.length, 0);
  assert.equal(await rpcError(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'x' }), 'unavailable');
  const url = await a.client.storage.from('photos').createSignedUrl(b.photos[0].path, 60);
  assert.ok(url.error, 'blocked: no new signed URL for their photos');
  await rpc(b, 'unblock_member', { p_other: a.id });
  assert.equal(await rpcError(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'y' }), 'unavailable');
});

test('a match expires without a first message after 24 h; one extension adds 24 h', async () => {
  const { a, b, conv } = await matchedPair('exp');
  const ext = await rpc(a, 'extend_match', { p_conversation: conv });
  assert.equal(ext.result, 'extended');
  assert.equal(await rpcError(b, 'extend_match', { p_conversation: conv }), 'already_extended');
  await sql(`update public.conversations set match_deadline = now() - interval '1 minute' where id = $1`, [conv]);
  assert.equal(await rpcError(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'late' }), 'match_expired');
  assert.equal((await rpc(a, 'list_conversations')).find((x) => x.conversation_id === conv).state, 'expired');
});

test('seven quiet days archive a conversation; a new message revives it', async () => {
  const { a, b, conv } = await matchedPair('arc');
  await rpc(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'hi' });
  await sql(`update public.conversations set last_message_at = now() - interval '8 days' where id = $1`, [conv]);
  assert.equal((await rpc(b, 'list_conversations')).find((x) => x.conversation_id === conv).state, 'archived');
  await rpc(b, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'back' });
  assert.equal((await rpc(b, 'list_conversations')).find((x) => x.conversation_id === conv).state, 'active');
});

test('reports keep evidence for moderators; staff resolution is audited', async () => {
  const { a, b, conv } = await matchedPair('rep');
  await rpc(b, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'abusive text (fixture)' });
  const r = await rpc(a, 'report_member', { p_subject: b.id, p_category: 'harassment', p_note: 'test', p_conversation: conv });
  await rpc(a, 'block_member', { p_other: b.id });
  const s = await staff();
  const queue = await rpc(s, 'staff_report_queue', {});
  const item = queue.find((x) => x.report_id === r.report_id);
  assert.ok(item, 'report is in the queue');
  assert.equal(item.evidence.messages[0].body, 'abusive text (fixture)', 'evidence survives the block');
  await rpc(s, 'staff_resolve_report', { p_report: r.report_id, p_action: 'suspend', p_note: 'test' });
  assert.equal(await rpcError(b, 'discovery_feed', { p_limit: 5 }), 'account_restricted');
  const audit = await sql(`select action from private.audit_log where subject = $1 and actor = $2`, [b.id, s.id]);
  assert.ok(audit.some((x) => x.action === 'report_suspend'));
  assert.equal(await rpcError(a, 'report_member', { p_subject: b.id, p_category: 'other', p_note: 'x',
    p_conversation: '00000000-0000-0000-0000-000000000000' }), 'not_found', 'cannot attach someone else\'s conversation');
});

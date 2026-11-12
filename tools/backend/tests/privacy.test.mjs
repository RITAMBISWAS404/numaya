// Privacy rights: export contains only the member's own data; deletion hides at once and the
// worker completes it (sessions, storage, auth user).
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { member, rpc, rpcError, cleanup, key, sql, admin } from '../lib/harness.mjs';
import { processDeletions } from '../scripts/privacy_worker.mjs';

after(cleanup);

test('export returns own data and none of the counterpart\'s words', async () => {
  const a = await member('expA', { gender: 'woman', openTo: ['man'] });
  const b = await member('expB', { gender: 'man', openTo: ['woman'] });
  await rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() });
  const { conversation_id: conv } = await rpc(b, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() });
  await rpc(a, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'mine' });
  await rpc(b, 'send_message', { p_conversation: conv, p_client_message_id: key(), p_body: 'theirs secret' });
  const ex = await rpc(a, 'request_export');
  const text = JSON.stringify(ex);
  assert.ok(text.includes('mine'));
  assert.ok(!text.includes('theirs secret'));
  assert.equal(ex.account.birth_date, '1995-06-15');
});

test('deletion hides the member immediately, closes chats and the worker completes it', async () => {
  const a = await member('delA', { gender: 'woman', openTo: ['man'] });
  const b = await member('delB', { gender: 'man', openTo: ['woman'] });
  await rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() });
  const { conversation_id: conv } = await rpc(b, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() });
  assert.ok((await rpc(b, 'list_conversations')).some((x) => x.conversation_id === conv));

  await rpc(a, 'request_account_deletion');
  assert.equal(await rpcError(a, 'discovery_feed', { p_limit: 5 }), 'account_deleted', 'API refused at once');
  assert.ok(!(await rpc(b, 'list_conversations')).some((x) => x.conversation_id === conv), 'chat closed for the other member');
  const third = await member('delC', { gender: 'man', openTo: ['woman'] });
  assert.ok(!(await rpc(third, 'discovery_feed', { p_limit: 20 })).some((x) => x.user_id === a.id), 'gone from discovery');

  const done = await processDeletions({ only: [a.id] });
  assert.equal(done.completed, 1);
  const { data } = await admin.auth.admin.getUserById(a.id);
  assert.equal(data.user, null, 'auth user deleted');
  const objs = await admin.storage.from('photos').list(a.id);
  assert.equal(objs.data.length, 0, 'storage objects deleted');
  const tomb = await sql('select completed_at from private.deletion_tombstones where user_id = $1', [a.id]);
  assert.ok(tomb[0].completed_at, 'tombstone kept for backup-restore replay');
});

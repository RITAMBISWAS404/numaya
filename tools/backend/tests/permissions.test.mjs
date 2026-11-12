// Direct Data API, RPC and Storage permission tests (OWASP API1: object-level authorization).
import { test, after, before } from 'node:test';
import assert from 'node:assert/strict';
import { anon, member, newUser, rpc, rpcError, cleanup, staff, uploadPhoto, tinyJpeg, key } from '../lib/harness.mjs';

let a, b, c;
before(async () => {
  a = await member('permA', { gender: 'woman', openTo: ['man'] });
  b = await member('permB', { gender: 'man', openTo: ['woman'] });
  c = await member('permC', { gender: 'man', openTo: ['woman'] });
});
after(cleanup);

const tables = ['profiles', 'preferences', 'prompts', 'photos', 'decisions', 'conversations', 'messages',
  'conversation_reads', 'compliments', 'blocks', 'reports', 'consents', 'devices', 'privacy_requests'];

test('anonymous key reads nothing and calls no RPC', async () => {
  const client = anon();
  for (const t of tables) {
    const { data, error } = await client.from(t).select('*').limit(1);
    assert.ok(error || (data ?? []).length === 0, `anon read ${t}`);
  }
  const { error } = await client.rpc('discovery_feed', { p_limit: 5 });
  assert.ok(error, 'anon discovery_feed must fail');
  const up = await client.storage.from('photos').upload(`${a.id}/x.jpg`, tinyJpeg, { contentType: 'image/jpeg' });
  assert.ok(up.error, 'anon upload must fail');
});

test('a member cannot read another member\'s profile, prompts or photos rows before a match', async () => {
  for (const t of ['profiles', 'prompts', 'photos', 'preferences', 'consents']) {
    const { data, error } = await a.client.from(t).select('*').eq('user_id', b.id);
    assert.equal(error, null);
    assert.equal(data.length, 0, `${t} of another member must be invisible`);
  }
  const own = await a.client.from('profiles').select('*').eq('user_id', a.id);
  assert.equal(own.data.length, 1);
});

test('decisions, compliments and reports have no client read path', async () => {
  for (const t of ['decisions', 'compliments', 'reports']) {
    const { data, error } = await a.client.from(t).select('*').limit(5);
    assert.ok(error || data.length === 0, `${t} must not be readable`);
  }
});

test('server-owned columns cannot be written by the client', async () => {
  for (const patch of [{ verified: true }, { onboarding_complete: false }]) {
    const { error } = await a.client.from('profiles').update(patch).eq('user_id', a.id);
    assert.ok(error, `update ${Object.keys(patch)[0]} must be refused`);
  }
  const { data } = await a.client.from('profiles').select('verified').eq('user_id', a.id).single();
  assert.equal(data.verified, false);
});

test('a member cannot write another member\'s rows', async () => {
  const p = await a.client.from('profiles').update({ bio: 'hijacked' }).eq('user_id', b.id).select();
  assert.equal(p.data?.length ?? 0, 0);
  const pr = await a.client.from('prompts').insert({ user_id: b.id, position: 2, question: 'Q', answer: 'A' });
  assert.ok(pr.error, 'inserting a prompt for another member must fail');
  const ph = await a.client.from('photos').insert({ user_id: a.id, object_path: `${a.id}/x.jpg`, position: 3 });
  assert.ok(ph.error, 'photos rows are created only by register_photo');
  const dec = await a.client.from('decisions').insert({ actor_id: a.id, target_id: b.id, kind: 'like',
    idempotency_key: key(), result: 'matched' });
  assert.ok(dec.error, 'decisions are created only by decide()');
});

test('the private schema is not reachable through the Data API', async () => {
  const { error } = await a.client.schema('private').from('accounts').select('*').limit(1);
  assert.ok(error, 'private schema must not be exposed');
});

test('discovery never returns birth dates, coordinates or private fields', async () => {
  const feed = await rpc(a, 'discovery_feed', { p_limit: 20 });
  const text = JSON.stringify(feed);
  for (const forbidden of ['birth_date', 'point', 'latitude', 'longitude', 'phone', 'email']) {
    assert.ok(!text.includes(`"${forbidden}"`), `feed must not include ${forbidden}`);
  }
  assert.ok(feed.every((card) => card.user_id !== a.id), 'feed excludes self');
  const ids = feed.map((x) => x.user_id);
  assert.ok(ids.includes(b.id), 'compatible member appears');
});

test('storage: own-folder uploads only; pending photos private; approved photos readable; block revokes', async () => {
  const intoOther = await a.client.storage.from('photos').upload(`${b.id}/evil.jpg`, tinyJpeg, { contentType: 'image/jpeg' });
  assert.ok(intoOther.error, 'upload into another member\'s folder must fail');

  const pending = await uploadPhoto(b, 3); // not approved yet
  const s1 = await c.client.storage.from('photos').createSignedUrl(pending.path, 60);
  assert.ok(s1.error, 'pending photo must not be readable by others');
  const own = await b.client.storage.from('photos').createSignedUrl(pending.path, 60);
  assert.equal(own.error, null, 'owner can read own pending photo');

  const approved = b.photos[0].path;
  const s2 = await c.client.storage.from('photos').createSignedUrl(approved, 60);
  assert.equal(s2.error, null, 'approved photo of a discoverable member is readable');

  await rpc(b, 'block_member', { p_other: c.id });
  const s3 = await c.client.storage.from('photos').createSignedUrl(approved, 60);
  assert.ok(s3.error, 'blocked member can no longer get a signed URL');
  const feed = await rpc(c, 'discovery_feed', { p_limit: 20 });
  assert.ok(!feed.some((x) => x.user_id === b.id), 'blocked member disappears from discovery');
});

test('register_photo rejects someone else\'s object path and non-image types', async () => {
  assert.equal(await rpcError(a, 'register_photo', { p_object_path: `${b.id}/whatever.jpg`, p_position: 4 }), 'forbidden');
  const path = `${a.id}/note.txt`;
  const up = await a.client.storage.from('photos').upload(path, Buffer.from('hello'), { contentType: 'text/plain' });
  assert.ok(up.error, 'bucket refuses non-image MIME types');
});

test('staff entry points are refused to members', async () => {
  for (const [fn, args] of [['staff_photo_queue', {}], ['staff_report_queue', {}],
    ['staff_decide_photo', { p_photo: a.photos[0].photoId, p_approve: false }],
    ['staff_resolve_report', { p_report: a.id, p_action: 'suspend' }]]) {
    assert.equal(await rpcError(a, fn, args), 'forbidden', fn);
  }
  const s = await staff();
  const q = await rpc(s, 'staff_photo_queue', {});
  assert.ok(Array.isArray(q));
});

test('an onboarding (incomplete) member cannot use member endpoints', async () => {
  const fresh = await newUser('fresh');
  assert.equal(await rpcError(fresh, 'discovery_feed', { p_limit: 5 }), 'onboarding_incomplete');
  assert.equal(await rpcError(fresh, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() }), 'onboarding_incomplete');
});

test('under-18 birth dates are refused and the account is restricted', async () => {
  const kid = await newUser('minor');
  await kid.client.from('profiles').update({ first_name: 'Kid', gender: 'man', bio: 'x' }).eq('user_id', kid.id);
  const res = await rpc(kid, 'complete_onboarding', { p_birth_date: '2012-01-01', p_terms_version: '2026-11',
    p_privacy_version: '2026-11', p_community_version: '2026-11' });
  assert.equal(res.result, 'underage');
  assert.equal(await rpcError(kid, 'discovery_feed', { p_limit: 5 }), 'account_restricted');
});

// CONTRACT / FIXTURE TESTS (no network, no real provider). Labelled as such in VALIDATION.
// - Media: real images processed by sharp (fixtures generated here).
// - FCM: a locally generated RSA key stands in for a service account; a fake fetch plays the
//   documented FCM v1 responses. This proves our request shape and error handling, not delivery.
// - Push worker: runs against the real migrations on PGlite (local stand-in database).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { generateKeyPairSync, createVerify } from 'node:crypto';
import sharp from 'sharp';
import { processImage, validateVoice, MediaRejected } from '../worker/media.mjs';
import { createFcmClient, loadFcmConfig, serviceAccountAssertion, buildPushMessage } from '../worker/fcm.mjs';
import { deliverPush } from '../worker/jobs.mjs';
import { buildLocalDb } from '../local_semantic/run.mjs';

test('photos: EXIF/GPS removed, orientation applied, long side capped, JPEG out', async () => {
  const input = await sharp({ create: { width: 3000, height: 2000, channels: 3, background: '#4060a0' } })
    .withExif({ IFD0: { Make: 'FixtureCam', Model: 'X' }, IFD3: { GPSLatitudeRef: 'N', GPSLongitudeRef: 'E' } })
    .jpeg().toBuffer();
  const before = await sharp(input).metadata();
  assert.ok(before.exif, 'fixture carries EXIF');
  const out = await processImage(input);
  const after = await sharp(out.buffer).metadata();
  assert.equal(after.exif, undefined, 'no EXIF in the processed file');
  assert.equal(after.xmp, undefined);
  assert.equal(after.format, 'jpeg');
  assert.equal(Math.max(after.width, after.height), 1600);
});

test('photos: PNG accepted; text, tiny and oversized-decode inputs rejected (never approved)', async () => {
  const png = await sharp({ create: { width: 800, height: 600, channels: 4, background: '#fff' } }).png().toBuffer();
  assert.equal((await processImage(png)).mime, 'image/jpeg');
  await assert.rejects(processImage(Buffer.from('not an image at all, just some text bytes padded out to length......')), MediaRejected);
  const tiny = await sharp({ create: { width: 50, height: 50, channels: 3, background: '#000' } }).jpeg().toBuffer();
  await assert.rejects(processImage(tiny), (e) => e.reason === 'too_small');
  const huge = await sharp({ create: { width: 9000, height: 9000, channels: 3, background: '#000' } }).png({ compressionLevel: 9 }).toBuffer();
  await assert.rejects(processImage(huge), MediaRejected, 'decoder pixel limit');
});

test('voice notes: container checked from bytes, MIME must agree', () => {
  const m4a = Buffer.concat([Buffer.from([0, 0, 0, 0x20]), Buffer.from('ftypM4A '), Buffer.alloc(32)]);
  assert.equal(validateVoice(m4a, 'audio/mp4').kind, 'mp4');
  assert.throws(() => validateVoice(m4a, 'audio/ogg'), (e) => e.reason === 'type_mismatch');
  assert.throws(() => validateVoice(Buffer.from('<html>hello there friend</html>'), 'audio/mp4'), (e) => e.reason === 'not_audio');
});

function fixtureServiceAccount() {
  const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
  const json = { type: 'service_account', project_id: 'fixture-project', client_email: 'fixture@fixture.iam.gserviceaccount.com',
    private_key: privateKey.export({ type: 'pkcs8', format: 'pem' }), token_uri: 'https://oauth2.googleapis.com/token' };
  return { env: { FCM_SERVICE_ACCOUNT_JSON: Buffer.from(JSON.stringify(json)).toString('base64') }, publicKey };
}

test('FCM config: disabled when absent; malformed keys are configuration errors', () => {
  assert.equal(loadFcmConfig({}).enabled, false);
  assert.throws(() => loadFcmConfig({ FCM_SERVICE_ACCOUNT_JSON: Buffer.from('{"type":"service_account"}').toString('base64') }));
});

test('FCM: signed RS256 assertion, v1 request shape, documented error handling', async () => {
  const { env, publicKey } = fixtureServiceAccount();
  const cfg = loadFcmConfig(env);
  const jwt = serviceAccountAssertion(cfg, 'https://www.googleapis.com/auth/firebase.messaging', 1_800_000_000);
  const [h, c, sig] = jwt.split('.');
  const v = createVerify('RSA-SHA256'); v.update(`${h}.${c}`);
  assert.ok(v.verify(publicKey, Buffer.from(sig, 'base64url')), 'assertion verifies with the key');
  assert.equal(JSON.parse(Buffer.from(c, 'base64url')).scope, 'https://www.googleapis.com/auth/firebase.messaging');

  const calls = [];
  const responses = { 'tok-ok': [200, {}], 'tok-gone': [404, { error: { status: 'NOT_FOUND', details: [{ errorCode: 'UNREGISTERED' }] } }],
    'tok-busy': [429, { error: { status: 'RESOURCE_EXHAUSTED' } }], 'tok-auth': [401, { error: { status: 'UNAUTHENTICATED' } }] };
  const fetchImpl = async (url, init) => {
    calls.push({ url, init });
    if (url.includes('oauth2')) return new Response(JSON.stringify({ access_token: 'fixture-access', expires_in: 3600 }), { status: 200 });
    const token = JSON.parse(init.body).message.token;
    const [status, body] = responses[token];
    return new Response(JSON.stringify(body), { status, headers: status === 429 ? { 'retry-after': '30' } : {} });
  };
  const client = createFcmClient(cfg, { fetchImpl });
  assert.equal((await client.send('tok-ok', buildPushMessage('messages', { conversation_id: 'c1' }))).outcome, 'sent');
  assert.equal((await client.send('tok-gone', {})).outcome, 'invalid_token');
  const busy = await client.send('tok-busy', {});
  assert.equal(busy.outcome, 'retry'); assert.equal(busy.retryAfterSec, 30);
  assert.equal((await client.send('tok-auth', {})).outcome, 'config_error');
  const send = calls.find((x) => x.url.includes('messages:send'));
  assert.equal(send.url, 'https://fcm.googleapis.com/v1/projects/fixture-project/messages:send');
  assert.equal(send.init.headers.authorization, 'Bearer fixture-access');
  assert.equal(calls.filter((x) => x.url.includes('oauth2')).length, 1, 'access token cached');
  const msg = buildPushMessage('messages', { conversation_id: 'c1' });
  assert.ok(!JSON.stringify(msg).match(/body":"[^"]*(hi|hello)/i), 'no message text in pushes');
});

test('push worker on the real migrations (PGlite): sends, revokes dead tokens, retries, skips', async () => {
  const db = await buildLocalDb();
  const u = (await db.query(`insert into auth.users (email) values ('p@example.invalid') returning id`)).rows[0].id;
  await db.query(`update private.accounts set status = 'active' where user_id = $1`, [u]);
  for (const t of ['tok-ok', 'tok-gone']) {
    await db.query(`insert into public.devices (user_id, platform, push_token) values ($1, 'android', $2)`, [u, t]);
  }
  await db.query(`insert into private.outbox (kind, recipient, payload, dedupe_key) values ('match', $1, '{"conversation_id":"c"}', 'm1')`, [u]);
  const sent = [];
  const fake = { send: async (token) => { sent.push(token); return token === 'tok-ok' ? { outcome: 'sent' } : { outcome: 'invalid_token' }; } };
  const r1 = await deliverPush({ db, env: {}, fcm: fake });
  assert.equal(r1.sent, 1); assert.equal(r1.revoked, 1);
  assert.equal((await db.query(`select revoked from public.devices where push_token = 'tok-gone'`)).rows[0].revoked, true);
  await db.query(`insert into private.outbox (kind, recipient, payload, dedupe_key) values ('message', $1, '{}', 'm2')`, [u]);
  const r2 = await deliverPush({ db, env: {}, fcm: { send: async () => ({ outcome: 'retry', error: '503' }) } });
  assert.equal(r2.retried, 1);
  assert.equal((await db.query(`select status from private.outbox where dedupe_key = 'm2'`)).rows[0].status, 'pending');
  assert.equal((await deliverPush({ db, env: {} })).disabled, 'FCM_SERVICE_ACCOUNT_JSON not set', 'disabled without credentials');
  await db.close();
});

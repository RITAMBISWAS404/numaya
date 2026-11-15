// Real-service media tests (development project): server pipeline strips metadata; chat media is
// readable only by the two members, only after processing, and never after a block.
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import sharp from 'sharp';
import { member, rpc, rpcError, cleanup, key, runWorker, admin, sql } from '../lib/harness.mjs';

after(cleanup);

test('profile photos: the processed object has no EXIF; the original stays private', async () => {
  const a = await member('mediaA', { gender: 'woman', openTo: ['man'] });
  const processed = await admin.storage.from('photos').download(a.photos[0].processed);
  const meta = await sharp(Buffer.from(await processed.data.arrayBuffer())).metadata();
  assert.equal(meta.exif, undefined, 'metadata removed server-side');
  const original = await admin.storage.from('photos').download(a.photos[0].path);
  assert.ok((await sharp(Buffer.from(await original.data.arrayBuffer())).metadata()).exif, 'fixture original had EXIF');
});

test('chat image: upload into own open conversation, process, send, member-only access', async () => {
  const a = await member('chatImgA', { gender: 'woman', openTo: ['man'] });
  const b = await member('chatImgB', { gender: 'man', openTo: ['woman'] });
  const c = await member('chatImgC', { gender: 'man', openTo: ['woman'] });
  await rpc(a, 'decide', { p_target: b.id, p_kind: 'like', p_key: key() });
  const conv = (await rpc(b, 'decide', { p_target: a.id, p_kind: 'like', p_key: key() })).conversation_id;
  const img = await sharp({ create: { width: 640, height: 480, channels: 3, background: '#123456' } })
    .withExif({ IFD3: { GPSLatitudeRef: 'N' } }).jpeg().toBuffer();
  const path = `${conv}/${a.id}/${randomUUID()}.jpg`;
  const intrude = await c.client.storage.from('chat-media').upload(`${conv}/${c.id}/x.jpg`, img, { contentType: 'image/jpeg' });
  assert.ok(intrude.error, 'outsider cannot upload into the conversation');
  const up = await a.client.storage.from('chat-media').upload(path, img, { contentType: 'image/jpeg' });
  assert.equal(up.error, null);
  const att = (await rpc(a, 'register_attachment', { p_conversation: conv, p_object_path: path, p_kind: 'image' })).attachment_id;
  assert.equal(await rpcError(a, 'send_attachment', { p_conversation: conv, p_client_message_id: key(), p_attachment: att }), 'attachment_not_ready');
  await runWorker('attachments');
  const sent = await rpc(a, 'send_attachment', { p_conversation: conv, p_client_message_id: key(), p_attachment: att, p_caption: 'view' });
  assert.ok(sent.seq);
  const [{ processed_path: out }] = await sql('select processed_path from public.attachments where id = $1', [att]);
  assert.equal((await b.client.storage.from('chat-media').createSignedUrl(out, 60)).error, null, 'the other member can view');
  assert.ok((await b.client.storage.from('chat-media').createSignedUrl(path, 60)).error, 'never the original');
  assert.ok((await c.client.storage.from('chat-media').createSignedUrl(out, 60)).error, 'outsiders cannot');
  const dl = await b.client.storage.from('chat-media').download(out);
  assert.equal((await sharp(Buffer.from(await dl.data.arrayBuffer())).metadata()).exif, undefined, 'GPS removed');
  await rpc(b, 'block_member', { p_other: a.id });
  assert.ok((await b.client.storage.from('chat-media').createSignedUrl(out, 60)).error, 'a block revokes access to media');
});

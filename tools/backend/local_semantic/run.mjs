// LOCAL SEMANTIC CHECK, NOT SUPABASE VERIFICATION.
// Runs the real migrations on PGlite (PostgreSQL 17 in WebAssembly) with a small stand-in for the
// parts Supabase provides (roles anon/authenticated, auth.users + auth.uid(), storage.objects +
// storage.foldername(), the realtime publication) and SQL stand-ins for the four PostGIS
// functions used. Then it calls every RPC as different signed-in members under real RLS and
// asserts the business rules. It catches wrong names, types and logic before the dev project
// exists; it cannot prove concurrency, PostgREST, Storage, Realtime or Auth behaviour, which the
// tests/ suite checks against the real project.
import { readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import assert from 'node:assert/strict';
import { PGlite } from '@electric-sql/pglite';
import { repoRoot } from '../lib/env.mjs';

const SHIM = `
create role anon nologin; create role authenticated nologin; create role service_role nologin bypassrls;
create schema auth;
create table auth.users (id uuid primary key default gen_random_uuid(), email text, phone text,
  created_at timestamptz default now());
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
grant usage on schema auth to anon, authenticated;
create schema storage;
create table storage.buckets (id text primary key, name text, public boolean, file_size_limit bigint,
  allowed_mime_types text[]);
create table storage.objects (id uuid primary key default gen_random_uuid(), bucket_id text, name text,
  owner uuid, metadata jsonb, unique (bucket_id, name));
alter table storage.objects enable row level security;
create function storage.foldername(name text) returns text[] language sql immutable as $$
  select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'), 1) - 1] $$;
grant usage on schema storage to authenticated;
grant select, insert, delete on storage.objects to authenticated;
create schema extensions;
create type extensions.geography as (lat double precision, lng double precision);
create function extensions.st_makepoint(x double precision, y double precision) returns extensions.geography
  language sql immutable as $$ select row(y, x)::extensions.geography $$;
create function extensions.st_setsrid(g extensions.geography, srid int) returns extensions.geography
  language sql immutable as $$ select g $$;
create function extensions.st_distance(a extensions.geography, b extensions.geography) returns double precision
  language sql immutable as $$ select 2 * 6371000 * asin(sqrt(power(sin(radians((b).lat - (a).lat) / 2), 2)
    + cos(radians((a).lat)) * cos(radians((b).lat)) * power(sin(radians((b).lng - (a).lng) / 2), 2))) $$;
create function extensions.st_dwithin(a extensions.geography, b extensions.geography, d double precision)
  returns boolean language sql immutable as $$ select extensions.st_distance(a, b) <= d $$;
grant usage on schema extensions to authenticated;
create publication supabase_realtime;
grant usage on schema public to anon, authenticated;
`;

function adapt(sql) {
  return sql
    .replace(/create extension if not exists postgis with schema extensions;/g, '-- postgis: stand-in')
    .replace(/extensions\.geography\(point, 4326\)/g, 'extensions.geography')
    .replace(/create index locations_point_idx[^;]*;/g, '-- gist index: n/a in stand-in');
}

export async function runLocalSemanticCheck({ log = console.log } = {}) {
  const db = new PGlite();
  await db.exec(SHIM);
  const dir = resolve(repoRoot, 'supabase', 'migrations');
  for (const f of readdirSync(dir).filter((x) => x.endsWith('.sql')).sort()) {
    try {
      await db.exec(adapt(readFileSync(resolve(dir, f), 'utf8')));
      log(`applied ${f}`);
    } catch (e) {
      throw new Error(`${f}: ${e.message}`);
    }
  }

  const users = {};
  for (const n of ['A', 'B', 'C', 'S', 'K']) {
    users[n] = (await db.query(`insert into auth.users (email) values ($1) returning id`, [`${n}@example.invalid`])).rows[0].id;
  }
  await db.query(`insert into private.staff_members (user_id, role, granted_by) values ($1, 'moderator', 'local')`, [users.S]);

  const as = async (who, sql, params = []) => {
    await db.exec(`reset role; select set_config('request.jwt.claim.sub', '${users[who] ?? ''}', false); set role authenticated;`);
    try {
      return (await db.query(sql, params)).rows;
    } finally {
      await db.exec('reset role;');
    }
  };
  const rpc = async (who, fn, args = {}) => {
    const names = Object.keys(args);
    const r = await as(who, `select public.${fn}(${names.map((n, i) => `${n} => $${i + 1}`).join(', ')}) as r`, Object.values(args));
    return r[0]?.r;
  };
  const err = async (who, fn, args = {}) => {
    try { await rpc(who, fn, args); return null; } catch (e) { return e.message; }
  };
  const results = [];
  const check = async (name, body) => {
    try { await body(); results.push(['ok', name]); } catch (e) { results.push(['FAIL', `${name}: ${e.message}`]); }
  };

  async function onboard(who, gender, openTo, birth = '1995-06-15', lat = 19.07) {
    const id = users[who];
    await as(who, `update public.profiles set first_name = $2, gender = $3, open_to = $4::public.gender[], bio = 'bio',
      looking_for = '{longTerm}' where user_id = $1`, [id, who, gender, `{${openTo.join(',')}}`]);
    await as(who, `insert into public.prompts (user_id, position, question, answer) values ($1, 1, 'Q', 'A')`, [id]);
    const photos = [];
    for (const pos of [1, 2]) {
      const path = `${id}/${pos}.jpg`;
      await as(who, `insert into storage.objects (bucket_id, name, owner, metadata) values ('photos', $1, $2,
        '{"mimetype":"image/jpeg","size":1234}')`, [path, id]);
      photos.push((await rpc(who, 'register_photo', { p_object_path: path, p_position: pos })).photo_id);
    }
    const res = await rpc(who, 'complete_onboarding', { p_birth_date: birth, p_terms_version: 'v',
      p_privacy_version: 'v', p_community_version: 'v' });
    await rpc(who, 'set_location', { p_lat: lat, p_lng: 72.88, p_city: 'Mumbai' });
    for (const p of photos) await rpc('S', 'staff_decide_photo', { p_photo: p, p_approve: true });
    return { res, photos };
  }

  let a, b;
  await check('onboarding: profile, prompt, photos, 18+, consents, welcome credits', async () => {
    a = await onboard('A', 'woman', ['man']);
    b = await onboard('B', 'man', ['woman']);
    await onboard('C', 'man', ['woman']);
    assert.equal(a.res.result, 'active');
    assert.equal((await rpc('A', 'my_wallet')).earned, 3);
  });
  await check('under-18 is refused and restricted', async () => {
    await as('K', `update public.profiles set first_name = 'K', gender = 'man', bio = 'x' where user_id = $1`, [users.K]);
    assert.equal((await rpc('K', 'complete_onboarding', { p_birth_date: '2013-01-01', p_terms_version: 'v',
      p_privacy_version: 'v', p_community_version: 'v' })).result, 'underage');
    assert.equal(await err('K', 'discovery_feed', { p_limit: 5 }), 'account_restricted');
  });
  await check('RLS: other profiles, private schema, server columns', async () => {
    assert.equal((await as('A', `select * from public.profiles where user_id = $1`, [users.B])).length, 0);
    assert.ok(await as('A', `select * from private.accounts`).then(() => false, () => true), 'private schema denied');
    assert.ok(await as('A', `update public.profiles set verified = true where user_id = $1`, [users.A]).then(() => false, () => true));
    assert.equal((await as('A', `select * from public.decisions`).catch(() => [])).length, 0);
  });
  await check('storage: own folder only; pending photo unreadable by others', async () => {
    assert.ok(await as('A', `insert into storage.objects (bucket_id, name, metadata) values ('photos', $1, '{}')`,
      [`${users.B}/x.jpg`]).then(() => false, () => true));
    const path = `${users.B}/3.jpg`;
    await as('B', `insert into storage.objects (bucket_id, name, owner, metadata) values ('photos', $1, $2, '{"mimetype":"image/jpeg","size":10}')`, [path, users.B]);
    await rpc('B', 'register_photo', { p_object_path: path, p_position: 3 });
    assert.equal((await as('C', `select name from storage.objects where name = $1`, [path])).length, 0);
    assert.equal((await as('C', `select name from storage.objects where name = $1`, [`${users.B}/1.jpg`])).length, 1);
  });
  await check('six-photo limit and type checks', async () => {
    for (const pos of [4, 5, 6]) {
      const path = `${users.B}/${pos}.jpg`;
      await as('B', `insert into storage.objects (bucket_id, name, owner, metadata) values ('photos', $1, $2, '{"mimetype":"image/jpeg","size":10}')`, [path, users.B]);
      await rpc('B', 'register_photo', { p_object_path: path, p_position: pos });
    }
    const extra = `${users.B}/7.jpg`;
    await as('B', `insert into storage.objects (bucket_id, name, owner, metadata) values ('photos', $1, $2, '{"mimetype":"image/jpeg","size":10}')`, [extra, users.B]);
    assert.equal(await err('B', 'register_photo', { p_object_path: extra, p_position: 1 }), 'photo_limit');
    const txt = `${users.B}/n.txt`;
    await as('B', `insert into storage.objects (bucket_id, name, owner, metadata) values ('photos', $1, $2, '{"mimetype":"text/plain","size":10}')`, [txt, users.B]);
    await rpc('B', 'remove_photo', { p_photo: (await as('B', `select id from public.photos where position = 6 and user_id = $1`, [users.B]))[0].id });
    assert.equal(await err('B', 'register_photo', { p_object_path: txt, p_position: 6 }), 'type_not_allowed');
  });
  await check('reorder photos (deferred position constraint)', async () => {
    const ids = (await as('A', `select id from public.photos where user_id = $1 and status in ('pending','approved') order by position`, [users.A])).map((r) => r.id);
    await rpc('A', 'reorder_photos', { p_photo_ids: [...ids].reverse() });
    const after = (await as('A', `select id from public.photos where user_id = $1 order by position`, [users.A])).map((r) => r.id);
    assert.deepEqual(after, [...ids].reverse());
  });
  let conv;
  await check('discovery: compatible members, no private fields', async () => {
    const feed = await rpc('A', 'discovery_feed', { p_limit: 20 });
    const ids = feed.map((x) => x.user_id);
    assert.ok(ids.includes(users.B) && ids.includes(users.C) && !ids.includes(users.A));
    assert.ok(!JSON.stringify(feed).includes('birth_date'));
    assert.ok(['under_5_km', 'under_10_km'].includes(feed[0].distance_bucket));
  });
  await check('likes: idempotent, quota, reciprocal match', async () => {
    const r1 = await rpc('A', 'decide', { p_target: users.B, p_kind: 'like', p_key: 'key-a-b-0001' });
    assert.equal(r1.result, 'recorded');
    assert.equal((await rpc('A', 'decide', { p_target: users.B, p_kind: 'like', p_key: 'key-a-b-0001' })).replayed, true);
    assert.equal(await err('A', 'decide', { p_target: users.B, p_kind: 'pass', p_key: 'key-a-b-0001' }), 'idempotency_conflict');
    const r2 = await rpc('B', 'decide', { p_target: users.A, p_kind: 'like', p_key: 'key-b-a-0001' });
    assert.equal(r2.result, 'matched');
    conv = r2.conversation_id;
    assert.equal((await rpc('A', 'list_conversations')).find((x) => x.conversation_id === conv).state, 'new_match');
  });
  await check('chat: ordered, idempotent, outsiders denied', async () => {
    const m1 = await rpc('A', 'send_message', { p_conversation: conv, p_client_message_id: '00000000-0000-4000-8000-000000000001', p_body: 'hi' });
    const m1b = await rpc('A', 'send_message', { p_conversation: conv, p_client_message_id: '00000000-0000-4000-8000-000000000001', p_body: 'hi' });
    const m2 = await rpc('B', 'send_message', { p_conversation: conv, p_client_message_id: '00000000-0000-4000-8000-000000000002', p_body: 'hey' });
    assert.equal(m1.seq, 1); assert.equal(m1b.replayed, true); assert.equal(m2.seq, 2);
    assert.equal((await as('C', `select * from public.messages where conversation_id = $1`, [conv])).length, 0);
    assert.equal(await err('C', 'send_message', { p_conversation: conv, p_client_message_id: '00000000-0000-4000-8000-000000000003', p_body: 'x' }), 'not_found');
    await rpc('B', 'mark_read', { p_conversation: conv, p_seq: 1 });
    assert.equal((await rpc('B', 'list_conversations')).find((x) => x.conversation_id === conv).state, 'active');
    assert.equal((await as('B', `select * from public.profiles where user_id = $1`, [users.A])).length, 1, 'counterpart profile visible');
    assert.ok((await rpc('B', 'member_card', { p_user: users.A })).first_name);
  });
  await check('Compliments: debit, pending, sender cannot write, reply unlocks, no refund on dismiss', async () => {
    const promptB = (await as('A', `select id from public.prompts where user_id = $1`, [users.C]));
    assert.equal(promptB.length, 0, 'prompts of non-counterparts are not readable directly');
    const card = (await rpc('A', 'discovery_feed', { p_limit: 20 })).find((x) => x.user_id === users.C);
    const s = await rpc('A', 'send_compliment', { p_target: users.C, p_target_kind: 'prompt', p_target_ref: card.prompts[0].id,
      p_body: 'Nice answer', p_key: 'comp-a-c-0001' });
    assert.equal(s.result, 'sent');
    assert.equal((await rpc('A', 'my_wallet')).total, 2);
    assert.equal(await err('A', 'send_message', { p_conversation: s.conversation_id, p_client_message_id: '00000000-0000-4000-8000-000000000010', p_body: 'x' }), 'awaiting_reply');
    assert.equal((await rpc('C', 'list_conversations')).find((x) => x.conversation_id === s.conversation_id).state, 'pending_incoming');
    const r = await rpc('C', 'reply_compliment', { p_conversation: s.conversation_id, p_client_message_id: '00000000-0000-4000-8000-000000000011', p_body: 'Thanks!' });
    assert.equal(r.seq, 2);
    await rpc('A', 'send_message', { p_conversation: s.conversation_id, p_client_message_id: '00000000-0000-4000-8000-000000000012', p_body: 'Coffee?' });
    assert.equal(await err('A', 'send_compliment', { p_target: users.C, p_target_kind: 'prompt', p_target_ref: card.prompts[0].id,
      p_body: 'again', p_key: 'comp-a-c-0002' }), 'already_matched');
  });
  await check('credits: no_credits and no negative balance', async () => {
    await db.query(`insert into private.credit_ledger (user_id, bucket, delta, reason, source_key)
      values ($1, 'earned', -2, 'reversal', 'local-zero')`, [users.A]);
    assert.equal((await rpc('A', 'my_wallet')).total, 0);
    const d = (await db.query(`insert into auth.users (email) values ('D@example.invalid') returning id`)).rows[0].id;
    users.D = d;
    await onboard('D', 'man', ['woman']);
    const card = (await rpc('A', 'discovery_feed', { p_limit: 20 })).find((x) => x.user_id === d);
    assert.equal(await err('A', 'send_compliment', { p_target: d, p_target_kind: 'photo', p_target_ref: card.photos[0].id,
      p_body: 'hi', p_key: 'comp-a-d-0001' }), 'no_credits');
    assert.equal((await db.query(`select count(*)::int n from public.conversations where $1 in (user_a, user_b) and $2 in (user_a, user_b)`, [users.A, d])).rows[0].n, 0);
  });
  await check('streak: seventh qualifying day awards one earned credit', async () => {
    await db.query(`insert into private.daily_usage (user_id, day, qualified)
      select $1, private.ist_day() - g, true from generate_series(1, 6) g`, [users.D]);
    const before = (await rpc('D', 'my_wallet')).earned;
    await rpc('D', 'send_message', { p_conversation: (await rpc('D', 'list_conversations'))[0]?.conversation_id ?? conv, p_client_message_id: '00000000-0000-4000-8000-000000000020', p_body: 'x' })
      .catch(() => {});
    await db.query(`select private.record_activity($1, 'message')`, [users.D]);
    const w = await rpc('D', 'my_wallet');
    assert.equal(w.streak.run, 7);
    assert.equal(w.earned, Math.min(5, before + 1));
  });
  await check('extend once; expiry blocks sends', async () => {
    const e = (await db.query(`insert into auth.users (email) values ('E@example.invalid') returning id`)).rows[0].id;
    users.E = e;
    await onboard('E', 'man', ['woman']);
    await rpc('E', 'decide', { p_target: users.A, p_kind: 'like', p_key: 'key-e-a-0001' });
    const m = await rpc('A', 'decide', { p_target: e, p_kind: 'like', p_key: 'key-a-e-0001' });
    assert.equal((await rpc('A', 'extend_match', { p_conversation: m.conversation_id })).result, 'extended');
    assert.equal(await err('E', 'extend_match', { p_conversation: m.conversation_id }), 'already_extended');
    await db.query(`update public.conversations set match_deadline = now() - interval '1 minute' where id = $1`, [m.conversation_id]);
    assert.equal(await err('A', 'send_message', { p_conversation: m.conversation_id, p_client_message_id: '00000000-0000-4000-8000-000000000030', p_body: 'late' }), 'match_expired');
  });
  await check('block closes the chat, hides the profile, survives unblock', async () => {
    await rpc('B', 'block_member', { p_other: users.A });
    assert.equal((await as('B', `select * from public.messages where conversation_id = $1`, [conv])).length, 0);
    assert.equal((await as('B', `select * from public.profiles where user_id = $1`, [users.A])).length, 0);
    assert.equal(await err('A', 'send_message', { p_conversation: conv, p_client_message_id: '00000000-0000-4000-8000-000000000040', p_body: 'x' }), 'unavailable');
    await rpc('B', 'unblock_member', { p_other: users.A });
    assert.equal(await err('B', 'send_message', { p_conversation: conv, p_client_message_id: '00000000-0000-4000-8000-000000000041', p_body: 'x' }), 'unavailable');
  });
  await check('report keeps evidence; staff resolves and is audited; members cannot moderate', async () => {
    const cid = (await rpc('C', 'list_conversations')).find((x) => x.other_id === users.A).conversation_id;
    const rep = await rpc('C', 'report_member', { p_subject: users.A, p_category: 'harassment', p_note: 'n', p_conversation: cid });
    assert.equal(await err('C', 'staff_report_queue'), 'forbidden');
    const q = await rpc('S', 'staff_report_queue');
    assert.ok(q.find((x) => x.report_id === rep.report_id).evidence.messages.length >= 1);
    await rpc('S', 'staff_resolve_report', { p_report: rep.report_id, p_action: 'dismiss', p_note: 'ok' });
    assert.ok((await db.query(`select 1 from private.audit_log where action = 'report_dismiss'`)).rows.length === 1);
  });
  await check('Premium: weekly credits once, 15 likes, likes list only with entitlement', async () => {
    assert.equal((await rpc('C', 'likes_summary')).people, null);
    await db.query(`insert into private.entitlements (user_id, product, active_until, source) values ($1, 'premium', now() + interval '1 day', 'staff_test')`, [users.C]);
    const w1 = await rpc('C', 'my_wallet');
    const w2 = await rpc('C', 'my_wallet');
    assert.equal(w1.weekly, 3); assert.equal(w2.weekly, 3); assert.equal(w1.likes_left_today, 15);
    assert.ok(Array.isArray((await rpc('C', 'likes_summary')).people));
  });
  await check('export: own data only; deletion hides, restore within window, purge scheduling', async () => {
    const ex = await rpc('C', 'request_export');
    assert.ok(ex.profile && Array.isArray(ex.messages_sent));
    assert.ok(!JSON.stringify(ex.messages_sent).includes('Coffee?'), 'another member\'s words are not exported');
    await rpc('C', 'request_account_deletion');
    assert.equal(await err('C', 'discovery_feed', { p_limit: 5 }), 'account_deleted');
    assert.ok(!(await rpc('D', 'discovery_feed', { p_limit: 20 })).some((x) => x.user_id === users.C));
    assert.ok((await rpc('C', 'account_state')).restorable_until);
    await rpc('C', 'restore_account');
    assert.ok(Array.isArray(await rpc('C', 'discovery_feed', { p_limit: 5 })));
    await rpc('C', 'request_account_deletion');
    await rpc('C', 'purge_account');
    assert.equal((await db.query(`select count(*)::int n from private.deletion_tombstones where user_id = $1 and purge_after <= now()`, [users.C])).rows[0].n, 1);
  });
  await check('anon role has no access', async () => {
    await db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false); set role anon;`);
    const denied = await db.query(`select * from public.profiles limit 1`).then(() => false, () => true);
    const rpcDenied = await db.query(`select public.discovery_feed(5)`).then(() => false, () => true);
    await db.exec('reset role;');
    assert.ok(denied && rpcDenied);
  });

  await db.close();
  for (const [s, n] of results) log(`${s.padEnd(4)} ${n}`);
  const failed = results.filter(([s]) => s !== 'ok').length;
  log(`${results.length - failed}/${results.length} local semantic checks passed`);
  return failed;
}

if (process.argv[1]?.endsWith('run.mjs')) {
  runLocalSemanticCheck().then((f) => process.exit(f ? 1 : 0)).catch((e) => { console.error(e.message); process.exit(1); });
}

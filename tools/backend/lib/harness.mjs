// Test harness: synthetic users on the real development backend.
// - Accounts are created with the secret key (server side only) as email+password test users
//   on the reserved example.invalid domain. The app itself signs in with phone OTP; that path has
//   its own test (auth_phone.test.mjs) using the project's configured test numbers.
// - Owner-level setup that has no client path (staff role, Premium entitlement for tests, clock
//   back-dating) uses a direct database connection and is labelled as test provisioning.
import { createClient } from '@supabase/supabase-js';
import pg from 'pg';
import { randomUUID, randomBytes } from 'node:crypto';
import { loadEnv } from './env.mjs';

export const env = loadEnv();
export const runId = `t${Date.now().toString(36)}${randomBytes(2).toString('hex')}`;

const clientOptions = { auth: { persistSession: false, autoRefreshToken: false } };
export const admin = createClient(env.SUPABASE_URL, env.SUPABASE_SECRET_KEY, clientOptions);
export const anon = () => createClient(env.SUPABASE_URL, env.SUPABASE_PUBLISHABLE_KEY, clientOptions);

let pool;
export function db() {
  pool ??= new pg.Pool({ connectionString: env.SUPABASE_DB_URL, max: 4, ssl: { rejectUnauthorized: false } });
  return pool;
}
export async function sql(text, params = []) {
  return (await db().query(text, params)).rows;
}

const created = [];

/** Creates and signs in a synthetic member. Returns { id, client, email }. */
export async function newUser(label) {
  const email = `numaya-${runId}-${label}-${randomBytes(3).toString('hex')}@example.invalid`;
  const password = randomBytes(18).toString('base64url');
  const { data, error } = await admin.auth.admin.createUser({ email, password, email_confirm: true });
  if (error) throw error;
  created.push(data.user.id);
  const client = createClient(env.SUPABASE_URL, env.SUPABASE_PUBLISHABLE_KEY, clientOptions);
  const s = await client.auth.signInWithPassword({ email, password });
  if (s.error) throw s.error;
  return { id: data.user.id, client, email, label };
}

/** A 1x1 JPEG (valid file signature; harmless fixture). */
export const tinyJpeg = Buffer.from(
  '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP////////////////////////////////////////////////////////////' +
  '//////////////////////////////////////////////////////////////////////////////wAALCAABAAEBAREA/8QA' +
  'FAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q==', 'base64');

export async function uploadPhoto(user, position) {
  const path = `${user.id}/${randomUUID()}.jpg`;
  const up = await user.client.storage.from('photos').upload(path, tinyJpeg, { contentType: 'image/jpeg' });
  if (up.error) throw up.error;
  const reg = await rpc(user, 'register_photo', { p_object_path: path, p_position: position });
  return { path, photoId: reg.photo_id };
}

/** Calls an RPC; throws an Error whose message is the backend's stable code. */
export async function rpc(user, fn, args = {}) {
  const { data, error } = await user.client.rpc(fn, args);
  if (error) {
    const e = new Error(error.message);
    e.code = error.code;
    throw e;
  }
  return data;
}

export async function rpcError(user, fn, args = {}) {
  try {
    await rpc(user, fn, args);
  } catch (e) {
    return e.message;
  }
  return null;
}

let staffUser;
/** A moderator, provisioned out of band (direct SQL), as the owner would. */
export async function staff() {
  if (staffUser) return staffUser;
  staffUser = await newUser('staff');
  await sql(`insert into private.staff_members (user_id, role, granted_by) values ($1, 'moderator', 'test-harness')`,
    [staffUser.id]);
  return staffUser;
}

/**
 * A fully onboarded, discoverable member: profile, prompt, two photos approved by the moderator,
 * birth date and consents, approximate location.
 */
export async function member(label, {
  gender = 'woman', openTo = [], birth = '1995-06-15', lat = 19.07, lng = 72.88, approve = true,
} = {}) {
  const u = await newUser(label);
  let r = await u.client.from('profiles').update({
    first_name: label.slice(0, 20), gender, open_to: openTo, bio: `Test bio for ${label}.`,
    looking_for: ['longTerm'], interests: ['Hiking', 'Coffee', 'Books'],
  }).eq('user_id', u.id);
  if (r.error) throw r.error;
  r = await u.client.from('prompts').insert({ user_id: u.id, position: 1,
    question: 'A perfect first date', answer: `Answer from ${label}` });
  if (r.error) throw r.error;
  u.photos = [await uploadPhoto(u, 1), await uploadPhoto(u, 2)];
  await rpc(u, 'complete_onboarding', { p_birth_date: birth, p_terms_version: '2026-11',
    p_privacy_version: '2026-11', p_community_version: '2026-11' });
  await rpc(u, 'set_location', { p_lat: lat, p_lng: lng, p_city: 'Mumbai' });
  if (approve) {
    const s = await staff();
    for (const p of u.photos) await rpc(s, 'staff_decide_photo', { p_photo: p.photoId, p_approve: true });
  }
  return u;
}

export const key = () => randomUUID();

/** Removes every synthetic user this run created (cascades their rows); storage objects too. */
export async function cleanup() {
  for (const id of created) {
    const { data } = await admin.storage.from('photos').list(id);
    if (data?.length) await admin.storage.from('photos').remove(data.map((o) => `${id}/${o.name}`));
    await admin.auth.admin.deleteUser(id);
  }
  created.length = 0;
  await pool?.end();
  pool = undefined;
}

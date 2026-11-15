// Firebase Cloud Messaging HTTP v1 adapter (https://firebase.google.com/docs/cloud-messaging).
// Auth: a service-account JWT exchanged at https://oauth2.googleapis.com/token for an access
// token with scope https://www.googleapis.com/auth/firebase.messaging. Send:
// POST https://fcm.googleapis.com/v1/projects/<project_id>/messages:send.
// Disabled unless FCM_SERVICE_ACCOUNT_JSON (base64 of the JSON key file) is configured.
import { createSign } from 'node:crypto';

export class FcmConfigError extends Error {}

export function loadFcmConfig(env) {
  const raw = env.FCM_SERVICE_ACCOUNT_JSON;
  if (!raw) return { enabled: false, reason: 'FCM_SERVICE_ACCOUNT_JSON not set' };
  let sa;
  try {
    sa = JSON.parse(Buffer.from(raw, 'base64').toString('utf8'));
  } catch {
    throw new FcmConfigError('FCM_SERVICE_ACCOUNT_JSON is not base64 JSON');
  }
  for (const k of ['project_id', 'client_email', 'private_key', 'token_uri']) {
    if (!sa[k]) throw new FcmConfigError(`service account is missing ${k}`);
  }
  if (sa.type !== 'service_account') throw new FcmConfigError('not a service account key');
  return { enabled: true, projectId: sa.project_id, clientEmail: sa.client_email, privateKey: sa.private_key, tokenUri: sa.token_uri };
}

const b64url = (b) => Buffer.from(b).toString('base64url');

export function serviceAccountAssertion(cfg, scope, nowSec = Math.floor(Date.now() / 1000)) {
  const header = b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claims = b64url(JSON.stringify({ iss: cfg.clientEmail, scope, aud: cfg.tokenUri, iat: nowSec, exp: nowSec + 3600 }));
  const signer = createSign('RSA-SHA256');
  signer.update(`${header}.${claims}`);
  return `${header}.${claims}.${b64url(signer.sign(cfg.privateKey))}`;
}

export function createFcmClient(cfg, { fetchImpl = fetch, now = () => Date.now() } = {}) {
  let cached = null;
  async function accessToken() {
    if (cached && cached.expiresAt - 60_000 > now()) return cached.token;
    const res = await fetchImpl(cfg.tokenUri, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: serviceAccountAssertion(cfg, 'https://www.googleapis.com/auth/firebase.messaging', Math.floor(now() / 1000)),
      }),
    });
    if (!res.ok) throw new FcmConfigError(`token exchange failed (${res.status})`);
    const body = await res.json();
    cached = { token: body.access_token, expiresAt: now() + body.expires_in * 1000 };
    return cached.token;
  }

  /** Sends one message. Returns {outcome: 'sent'|'invalid_token'|'retry'|'config_error', retryAfterSec?}. */
  async function send(token, message) {
    let res;
    try {
      res = await fetchImpl(`https://fcm.googleapis.com/v1/projects/${cfg.projectId}/messages:send`, {
        method: 'POST',
        headers: { authorization: `Bearer ${await accessToken()}`, 'content-type': 'application/json' },
        body: JSON.stringify({ message: { ...message, token } }),
      });
    } catch (e) {
      if (e instanceof FcmConfigError) return { outcome: 'config_error', error: e.message };
      return { outcome: 'retry', error: 'network' };
    }
    if (res.ok) return { outcome: 'sent' };
    let status = '';
    try {
      const err = (await res.json())?.error;
      status = err?.details?.find((d) => d.errorCode)?.errorCode ?? err?.status ?? '';
    } catch { /* no body */ }
    // Per the FCM v1 error codes: UNREGISTERED (404) and an INVALID_ARGUMENT token mean the token
    // is gone; 429/500/503 are retryable (honour Retry-After); 401/403 are configuration errors.
    if (res.status === 404 || status === 'UNREGISTERED') return { outcome: 'invalid_token' };
    if (res.status === 400 && (status === 'INVALID_ARGUMENT' || status === '')) return { outcome: 'invalid_token' };
    if ([429, 500, 503].includes(res.status)) {
      return { outcome: 'retry', retryAfterSec: Number(res.headers.get('retry-after')) || undefined, error: String(res.status) };
    }
    if (res.status === 401 || res.status === 403) return { outcome: 'config_error', error: String(res.status) };
    return { outcome: 'retry', error: String(res.status) };
  }
  return { send, accessToken };
}

/** Private by default: no names, no message text. A tap opens the app, which re-checks access. */
export function buildPushMessage(category, payload) {
  const text = {
    matches: { title: 'New match', body: 'You have a new match on Numaya.' },
    messages: { title: 'New message', body: 'You have a new message.' },
    compliments: { title: 'New Compliment', body: 'Someone sent you a Compliment.' },
  }[category];
  return {
    notification: text,
    data: { type: category, conversation_id: String(payload?.conversation_id ?? '') },
    android: { priority: 'HIGH', notification: { channel_id: 'numaya_default' } },
    apns: { payload: { aps: { sound: 'default' } } },
  };
}

// Shared by Edge Functions (Deno) and Node contract tests (type stripping): WebCrypto + fetch only.

export type Store = 'google_play' | 'app_store';
export type PurchaseStatus = 'active' | 'grace' | 'pending' | 'expired' | 'refunded' | 'revoked';

/** A store-verified purchase state, ready for private.apply_purchase_state. */
export interface VerifiedPurchase {
  store: Store;
  userId: string;
  productId: string;
  purchaseKey: string;
  environment: 'production' | 'sandbox';
  state: PurchaseStatus;
  expiresAt: string | null;
  eventAt: string;
}

export class StoreError extends Error {
  code: string;
  retryable: boolean;
  constructor(code: string, retryable = false) {
    super(code);
    this.code = code;
    this.retryable = retryable;
  }
}

export const KNOWN_PRODUCTS = ['numaya_premium_weekly', 'numaya_premium_monthly', 'numaya_premium_yearly', 'numaya_compliments_3'];

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
export function requireAccountBinding(value: unknown, expectedUserId?: string): string {
  if (typeof value !== 'string' || !UUID.test(value)) throw new StoreError('account_binding_missing');
  if (expectedUserId && value.toLowerCase() !== expectedUserId.toLowerCase()) throw new StoreError('account_mismatch');
  return value.toLowerCase();
}

export function b64url(bytes: ArrayBuffer | Uint8Array): string {
  const b = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  let s = '';
  for (const x of b) s += String.fromCharCode(x);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export function b64urlDecode(s: string): Uint8Array {
  const pad = s.replace(/-/g, '+').replace(/_/g, '/') + '==='.slice((s.length + 3) % 4);
  return Uint8Array.from(atob(pad), (c) => c.charCodeAt(0));
}

export async function sha256Hex(text: string): Promise<string> {
  const d = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
  return [...new Uint8Array(d)].map((x) => x.toString(16).padStart(2, '0')).join('');
}

function pemToDer(pem: string): ArrayBuffer {
  const body = pem.replace(/-----[^-]+-----/g, '').replace(/\s+/g, '');
  return Uint8Array.from(atob(body), (c) => c.charCodeAt(0)).buffer;
}

export interface ServiceAccount { client_email: string; private_key: string; token_uri: string }

/** OAuth access token for a Google service account (RS256 JWT bearer grant). */
export async function googleAccessToken(sa: ServiceAccount, scope: string, fetchImpl: typeof fetch = fetch,
  nowSec = Math.floor(Date.now() / 1000)): Promise<string> {
  const key = await crypto.subtle.importKey('pkcs8', pemToDer(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
  const enc = (o: unknown) => b64url(new TextEncoder().encode(JSON.stringify(o)));
  const unsigned = `${enc({ alg: 'RS256', typ: 'JWT' })}.${enc({ iss: sa.client_email, scope, aud: sa.token_uri, iat: nowSec, exp: nowSec + 3600 })}`;
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(unsigned));
  const res = await fetchImpl(sa.token_uri, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: `${unsigned}.${b64url(sig)}` }),
  });
  if (!res.ok) throw new StoreError('google_auth_failed', res.status >= 500);
  return (await res.json()).access_token;
}

/**
 * Verifies the OIDC token Pub/Sub push attaches (Authorization: Bearer <JWT>): RS256 against
 * Google's published keys, issuer, audience (this endpoint) and the configured push service
 * account e-mail. https://cloud.google.com/pubsub/docs/authenticate-push-subscriptions
 */
export async function verifyGoogleOidc(authorization: string | null, opts: { audience: string; email: string },
  fetchImpl: typeof fetch = fetch, nowSec = Math.floor(Date.now() / 1000)): Promise<void> {
  const token = authorization?.startsWith('Bearer ') ? authorization.slice(7) : null;
  if (!token) throw new StoreError('missing_push_auth');
  const [h, p, s] = token.split('.');
  if (!h || !p || !s) throw new StoreError('bad_push_auth');
  const header = JSON.parse(new TextDecoder().decode(b64urlDecode(h)));
  const claims = JSON.parse(new TextDecoder().decode(b64urlDecode(p)));
  if (header.alg !== 'RS256') throw new StoreError('bad_push_auth');
  const jwks = await (await fetchImpl('https://www.googleapis.com/oauth2/v3/certs')).json();
  const jwk = jwks.keys?.find((k: { kid: string }) => k.kid === header.kid);
  if (!jwk) throw new StoreError('bad_push_auth');
  const key = await crypto.subtle.importKey('jwk', jwk, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']);
  const ok = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key, b64urlDecode(s), new TextEncoder().encode(`${h}.${p}`));
  if (!ok) throw new StoreError('bad_push_auth');
  if (!['accounts.google.com', 'https://accounts.google.com'].includes(claims.iss)) throw new StoreError('bad_push_auth');
  if (claims.aud !== opts.audience || claims.email !== opts.email || claims.email_verified !== true) throw new StoreError('bad_push_auth');
  if (typeof claims.exp !== 'number' || claims.exp < nowSec) throw new StoreError('push_auth_expired');
}

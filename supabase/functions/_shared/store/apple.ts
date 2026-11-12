// App Store Server Notifications V2 and signed transactions (JWS, ES256, x5c chain).
// Verification: the x5c chain must be leaf <- Apple WWDR intermediate <- Apple Root CA - G3, the
// root must match the PINNED fingerprint (configuration; confirm it against
// https://www.apple.com/certificateauthority/ during activation), each certificate must be
// valid at the signing time, the leaf must carry Apple's receipt-signing marker OID
// 1.2.840.113635.100.6.11.1 and the intermediate 1.2.840.113635.100.6.2.1, and the JWS signature
// must verify with the leaf key. The X.509 library is injected (Deno: npm:@peculiar/x509;
// Node tests: @peculiar/x509) so this module stays runtime-neutral.
import { KNOWN_PRODUCTS, StoreError, b64urlDecode, requireAccountBinding, type VerifiedPurchase } from './common.ts';

const LEAF_OID = '1.2.840.113635.100.6.11.1';
const INTERMEDIATE_OID = '1.2.840.113635.100.6.2.1';

export interface AppleVerifyOptions {
  rootSha256: string;      // hex, colons optional
  now?: Date;
}

// deno-lint-ignore no-explicit-any
type X509Lib = any;

function hex(buf: ArrayBuffer) {
  return [...new Uint8Array(buf)].map((x) => x.toString(16).padStart(2, '0')).join('');
}

/** Raw r||s (JWS) to DER is not needed: WebCrypto ECDSA verify takes the raw IEEE P1363 form. */
export async function verifyAppleJws(jws: string, opts: AppleVerifyOptions, x509: X509Lib) {
  const parts = jws.split('.');
  if (parts.length !== 3) throw new StoreError('bad_jws');
  const header = JSON.parse(new TextDecoder().decode(b64urlDecode(parts[0])));
  if (header.alg !== 'ES256' || !Array.isArray(header.x5c) || header.x5c.length !== 3) throw new StoreError('bad_jws');
  const [leaf, intermediate, root] = header.x5c.map((c: string) => new x509.X509Certificate(c));
  const pinned = opts.rootSha256.replace(/:/g, '').toLowerCase();
  const rootHash = hex(await crypto.subtle.digest('SHA-256', root.rawData));
  if (rootHash !== pinned) throw new StoreError('untrusted_root');
  const payload = JSON.parse(new TextDecoder().decode(b64urlDecode(parts[1])));
  const at = opts.now ?? new Date(payload.signedDate ?? Date.now());
  for (const c of [leaf, intermediate, root]) {
    if (c.notBefore > at || c.notAfter < at) throw new StoreError('certificate_expired');
  }
  if (!leaf.getExtension(LEAF_OID)) throw new StoreError('not_apple_leaf');
  if (!intermediate.getExtension(INTERMEDIATE_OID)) throw new StoreError('not_apple_intermediate');
  if (!(await leaf.verify({ publicKey: intermediate.publicKey, signatureOnly: true }))) throw new StoreError('bad_chain');
  if (!(await intermediate.verify({ publicKey: root.publicKey, signatureOnly: true }))) throw new StoreError('bad_chain');
  if (!(await root.verify({ publicKey: root.publicKey, signatureOnly: true }))) throw new StoreError('bad_chain');
  const key = await leaf.publicKey.export({ name: 'ECDSA', namedCurve: 'P-256' }, ['verify']);
  const ok = await crypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, key, b64urlDecode(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`));
  if (!ok) throw new StoreError('bad_signature');
  return payload;
}

/**
 * Maps a verified JWSTransactionDecodedPayload to our state. appAccountToken must be the
 * member's id (set by the app when it starts the purchase).
 */
// deno-lint-ignore no-explicit-any
export function mapAppleTransaction(tx: any, expected: { bundleId: string; userId?: string }, now = new Date()): VerifiedPurchase {
  if (tx.bundleId !== expected.bundleId) throw new StoreError('wrong_bundle');
  if (!KNOWN_PRODUCTS.includes(tx.productId)) throw new StoreError('unknown_product');
  const userId = requireAccountBinding(tx.appAccountToken, expected.userId);
  const expiresAt = tx.expiresDate ? new Date(tx.expiresDate).toISOString() : null;
  const state: VerifiedPurchase['state'] = tx.revocationDate ? (tx.revocationReason === 1 || tx.revocationReason === 0 ? 'refunded' : 'revoked')
    : expiresAt && new Date(expiresAt) <= now ? 'expired' : 'active';
  return {
    store: 'app_store', userId, productId: tx.productId,
    purchaseKey: String(tx.originalTransactionId ?? tx.transactionId),
    environment: tx.environment === 'Production' ? 'production' : 'sandbox',
    state, expiresAt, eventAt: new Date(tx.signedDate ?? now).toISOString(),
  };
}

/** Decodes and verifies an App Store Server Notification V2 body ({signedPayload}). */
export async function parseAppleNotification(body: { signedPayload?: string }, opts: AppleVerifyOptions, x509: X509Lib) {
  if (!body?.signedPayload) throw new StoreError('bad_notification');
  const n = await verifyAppleJws(body.signedPayload, opts, x509);
  const signedTx = n.data?.signedTransactionInfo;
  const tx = signedTx ? await verifyAppleJws(signedTx, opts, x509) : null;
  return { notificationUUID: n.notificationUUID as string, notificationType: n.notificationType as string,
    subtype: n.subtype as string | undefined, environment: n.data?.environment as string, transaction: tx };
}

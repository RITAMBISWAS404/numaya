// CONTRACT / FIXTURE TESTS for store verification (the same TypeScript the Edge Functions run).
// Keys, certificates and API responses are generated here following the documented shapes;
// nothing contacts Google or Apple. Real sandbox verification is pending (PROVIDER_STATUS).
import 'reflect-metadata';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { webcrypto, generateKeyPairSync, createVerify, randomUUID } from 'node:crypto';
import * as x509 from '@peculiar/x509';
import { googleAccessToken, verifyGoogleOidc, b64url } from '../../../supabase/functions/_shared/store/common.ts';
import { mapSubscriptionV2, mapProductPurchase, parseRtdn } from '../../../supabase/functions/_shared/store/google_play.ts';
import { verifyAppleJws, mapAppleTransaction } from '../../../supabase/functions/_shared/store/apple.ts';
import { loadStoreConfig } from '../../../supabase/functions/_shared/store/config.ts';

x509.cryptoProvider.set(webcrypto);
const user = randomUUID();

test('Play subscriptionsv2: states, expiry, sandbox flag and account binding', async () => {
  const body = { subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE', testPurchase: {},
    lineItems: [{ productId: 'numaya_premium_monthly', expiryTime: '2099-01-01T00:00:00Z' }],
    externalAccountIdentifiers: { obfuscatedExternalAccountId: user } };
  const v = await mapSubscriptionV2(body, 'token-1', new Date(), user);
  assert.equal(v.state, 'active'); assert.equal(v.environment, 'sandbox'); assert.equal(v.userId, user);
  assert.equal(v.purchaseKey.length, 64, 'only a hash of the purchase token is stored');
  const cancelled = await mapSubscriptionV2({ ...body, subscriptionState: 'SUBSCRIPTION_STATE_CANCELED', testPurchase: undefined }, 't', new Date());
  assert.equal(cancelled.state, 'active', 'cancelled renewal stays valid until expiry'); assert.equal(cancelled.environment, 'production');
  assert.equal((await mapSubscriptionV2({ ...body, subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED' }, 't', new Date())).state, 'expired');
  await assert.rejects(mapSubscriptionV2({ ...body, externalAccountIdentifiers: {} }, 't', new Date()), /account_binding_missing/);
  await assert.rejects(mapSubscriptionV2(body, 't', new Date(), randomUUID()), /account_mismatch/);
  await assert.rejects(mapSubscriptionV2({ ...body, lineItems: [{ productId: 'other_app_sub' }] }, 't', new Date()), /unknown_product/);
});

test('Play one-time product: purchased, pending, voided -> refunded', async () => {
  const p = { purchaseState: 0, obfuscatedExternalAccountId: user };
  assert.equal((await mapProductPurchase(p, 'numaya_compliments_3', 't', new Date())).state, 'active');
  assert.equal((await mapProductPurchase({ ...p, purchaseState: 2 }, 'numaya_compliments_3', 't', new Date())).state, 'pending');
  assert.equal((await mapProductPurchase(p, 'numaya_compliments_3', 't', new Date(), { voided: true })).state, 'refunded');
  assert.equal((await mapProductPurchase({ ...p, purchaseType: 0 }, 'numaya_compliments_3', 't', new Date())).environment, 'sandbox');
});

test('RTDN parsing: subscription, voided, test; wrong package refused', () => {
  const push = (n) => ({ message: { messageId: 'm1', data: Buffer.from(JSON.stringify({ version: '1.0', packageName: 'com.numaya.numaya_mobile', eventTimeMillis: '1800000000000', ...n })).toString('base64') } });
  assert.equal(parseRtdn(push({ subscriptionNotification: { notificationType: 4, purchaseToken: 'pt' } }), 'com.numaya.numaya_mobile').kind, 'subscription');
  assert.equal(parseRtdn(push({ voidedPurchaseNotification: { purchaseToken: 'pt', productType: 2 } }), 'com.numaya.numaya_mobile').kind, 'voided');
  assert.equal(parseRtdn(push({ testNotification: { version: '1.0' } }), 'com.numaya.numaya_mobile').kind, 'test');
  assert.throws(() => parseRtdn(push({ subscriptionNotification: {} }), 'com.other.app'), /wrong_package/);
});

test('Google service-account auth: RS256 assertion signed with the configured key', async () => {
  const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
  let assertion;
  const fetchImpl = async (url, init) => { assertion = new URLSearchParams(init.body).get('assertion'); return new Response(JSON.stringify({ access_token: 'at' })); };
  const tok = await googleAccessToken({ client_email: 'svc@x.iam.gserviceaccount.com', private_key: privateKey.export({ type: 'pkcs8', format: 'pem' }), token_uri: 'https://oauth2.googleapis.com/token' },
    'https://www.googleapis.com/auth/androidpublisher', fetchImpl);
  assert.equal(tok, 'at');
  const [h, c, s] = assertion.split('.');
  const v = createVerify('RSA-SHA256'); v.update(`${h}.${c}`);
  assert.ok(v.verify(publicKey, Buffer.from(s, 'base64url')));
});

test('Pub/Sub push OIDC: valid token accepted; wrong audience, expiry or signature refused', async () => {
  const kp = await webcrypto.subtle.generateKey({ name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' }, true, ['sign', 'verify']);
  const jwk = { ...(await webcrypto.subtle.exportKey('jwk', kp.publicKey)), kid: 'k1', alg: 'RS256', use: 'sig' };
  const jwks = async () => new Response(JSON.stringify({ keys: [jwk] }));
  const sign = async (claims) => {
    const enc = (o) => b64url(new TextEncoder().encode(JSON.stringify(o)));
    const u = `${enc({ alg: 'RS256', kid: 'k1', typ: 'JWT' })}.${enc(claims)}`;
    return `Bearer ${u}.${b64url(await webcrypto.subtle.sign('RSASSA-PKCS1-v1_5', kp.privateKey, new TextEncoder().encode(u)))}`;
  };
  const now = Math.floor(Date.now() / 1000);
  const good = { iss: 'https://accounts.google.com', aud: 'https://x.supabase.co/functions/v1/store-notifications/google', email: 'push@x.iam.gserviceaccount.com', email_verified: true, exp: now + 300 };
  const opts = { audience: good.aud, email: good.email };
  await verifyGoogleOidc(await sign(good), opts, jwks);
  await assert.rejects(verifyGoogleOidc(await sign({ ...good, aud: 'https://evil' }), opts, jwks), /bad_push_auth/);
  await assert.rejects(verifyGoogleOidc(await sign({ ...good, exp: now - 10 }), opts, jwks), /push_auth_expired/);
  const t = await sign(good);
  await assert.rejects(verifyGoogleOidc(t.slice(0, -4) + 'AAAA', opts, jwks), /bad_push_auth/);
  await assert.rejects(verifyGoogleOidc(null, opts, jwks), /missing_push_auth/);
});

async function appleFixtureChain({ leafOid = true } = {}) {
  const alg = { name: 'ECDSA', namedCurve: 'P-256', hash: 'SHA-256' };
  const now = new Date();
  const notBefore = new Date(now.getTime() - 86400000);
  const notAfter = new Date(now.getTime() + 86400000 * 365);
  const rootKeys = await webcrypto.subtle.generateKey(alg, true, ['sign', 'verify']);
  const intKeys = await webcrypto.subtle.generateKey(alg, true, ['sign', 'verify']);
  const leafKeys = await webcrypto.subtle.generateKey(alg, true, ['sign', 'verify']);
  const nullExt = (oid) => new x509.Extension(oid, false, new Uint8Array([5, 0]));
  const root = await x509.X509CertificateGenerator.createSelfSigned({ serialNumber: '01', name: 'CN=Fixture Root (not Apple)', notBefore, notAfter, signingAlgorithm: alg, keys: rootKeys,
    extensions: [new x509.BasicConstraintsExtension(true, undefined, true)] });
  const inter = await x509.X509CertificateGenerator.create({ serialNumber: '02', subject: 'CN=Fixture Intermediate', issuer: root.subject, notBefore, notAfter,
    signingAlgorithm: alg, publicKey: intKeys.publicKey, signingKey: rootKeys.privateKey,
    extensions: [new x509.BasicConstraintsExtension(true, 0, true), nullExt('1.2.840.113635.100.6.2.1')] });
  const leaf = await x509.X509CertificateGenerator.create({ serialNumber: '03', subject: 'CN=Fixture Leaf', issuer: inter.subject, notBefore, notAfter,
    signingAlgorithm: alg, publicKey: leafKeys.publicKey, signingKey: intKeys.privateKey,
    extensions: leafOid ? [nullExt('1.2.840.113635.100.6.11.1')] : [] });
  const rootSha256 = Buffer.from(await webcrypto.subtle.digest('SHA-256', root.rawData)).toString('hex');
  const x5c = [leaf, inter, root].map((c) => Buffer.from(c.rawData).toString('base64'));
  const sign = async (payload) => {
    const enc = (o) => b64url(new TextEncoder().encode(JSON.stringify(o)));
    const u = `${enc({ alg: 'ES256', x5c })}.${enc(payload)}`;
    return `${u}.${b64url(await webcrypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, leafKeys.privateKey, new TextEncoder().encode(u)))}`;
  };
  return { rootSha256, sign };
}

test('App Store JWS: pinned root, chain, marker OIDs and ES256 signature all enforced', async () => {
  const { rootSha256, sign } = await appleFixtureChain();
  const tx = { bundleId: 'com.numaya.app', productId: 'numaya_premium_monthly', appAccountToken: user, originalTransactionId: '2000000123',
    environment: 'Sandbox', expiresDate: Date.now() + 86400000, signedDate: Date.now() };
  const jws = await sign(tx);
  const payload = await verifyAppleJws(jws, { rootSha256 }, x509);
  assert.equal(payload.productId, 'numaya_premium_monthly');
  await assert.rejects(verifyAppleJws(jws, { rootSha256: 'ab'.repeat(32) }, x509), /untrusted_root/);
  const [h, , s] = jws.split('.');
  const forged = `${h}.${b64url(new TextEncoder().encode(JSON.stringify({ ...tx, productId: 'numaya_premium_yearly' })))}.${s}`;
  await assert.rejects(verifyAppleJws(forged, { rootSha256 }, x509), /bad_signature/);
  const noOid = await appleFixtureChain({ leafOid: false });
  await assert.rejects(verifyAppleJws(await noOid.sign(tx), { rootSha256: noOid.rootSha256 }, x509), /not_apple_leaf/);
  await assert.rejects(verifyAppleJws(jws, { rootSha256, now: new Date(Date.now() + 86400000 * 400) }, x509), /certificate_expired/);

  const v = mapAppleTransaction(payload, { bundleId: 'com.numaya.app', userId: user });
  assert.equal(v.environment, 'sandbox'); assert.equal(v.state, 'active'); assert.equal(v.purchaseKey, '2000000123');
  assert.equal(mapAppleTransaction({ ...payload, revocationDate: Date.now(), revocationReason: 1 }, { bundleId: 'com.numaya.app' }).state, 'refunded');
  assert.throws(() => mapAppleTransaction(payload, { bundleId: 'com.other' }), /wrong_bundle/);
  assert.throws(() => mapAppleTransaction(payload, { bundleId: 'com.numaya.app', userId: randomUUID() }), /account_mismatch/);
});

test('store config: disabled unless explicitly enabled and complete', () => {
  assert.throws(() => loadStoreConfig(() => undefined), /store_not_configured/);
  assert.throws(() => loadStoreConfig((k) => ({ STORE_VERIFICATION_ENABLED: 'true', APPLE_BUNDLE_ID: 'com.numaya.app' })[k]), /apple_root_fingerprint_missing/);
});

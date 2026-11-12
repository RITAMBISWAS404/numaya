// Google Play Developer API verification (androidpublisher v3) and Real-time Developer
// Notifications (Pub/Sub push). Shapes follow the documented resources:
// - purchases.subscriptionsv2.get -> SubscriptionPurchaseV2 (subscriptionState, lineItems[].expiryTime,
//   externalAccountIdentifiers.obfuscatedExternalAccountId, testPurchase)
// - purchases.products.get -> ProductPurchase (purchaseState, purchaseType, obfuscatedExternalAccountId)
// - RTDN data: {version, packageName, eventTimeMillis, subscriptionNotification |
//   oneTimeProductNotification | voidedPurchaseNotification | testNotification}
import { KNOWN_PRODUCTS, StoreError, requireAccountBinding, sha256Hex, type VerifiedPurchase } from './common.ts';

const API = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications';
export const ANDROID_PUBLISHER_SCOPE = 'https://www.googleapis.com/auth/androidpublisher';

const SUBSCRIPTION_STATES: Record<string, VerifiedPurchase['state']> = {
  SUBSCRIPTION_STATE_ACTIVE: 'active',
  SUBSCRIPTION_STATE_IN_GRACE_PERIOD: 'grace',
  SUBSCRIPTION_STATE_CANCELED: 'active', // cancelled renewal: valid until expiry
  SUBSCRIPTION_STATE_ON_HOLD: 'expired',
  SUBSCRIPTION_STATE_PAUSED: 'expired',
  SUBSCRIPTION_STATE_EXPIRED: 'expired',
  SUBSCRIPTION_STATE_PENDING: 'pending',
  SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED: 'revoked',
};

// deno-lint-ignore no-explicit-any
export async function mapSubscriptionV2(body: any, purchaseToken: string, eventAt: Date, expectedUserId?: string): Promise<VerifiedPurchase> {
  const state = SUBSCRIPTION_STATES[body?.subscriptionState];
  if (!state) throw new StoreError('unknown_subscription_state');
  const line = body.lineItems?.[0];
  const productId = line?.productId;
  if (!KNOWN_PRODUCTS.includes(productId) || !productId.startsWith('numaya_premium_')) throw new StoreError('unknown_product');
  const userId = requireAccountBinding(body.externalAccountIdentifiers?.obfuscatedExternalAccountId, expectedUserId);
  const expiresAt = line?.expiryTime ? new Date(line.expiryTime).toISOString() : null;
  return {
    store: 'google_play', userId, productId, purchaseKey: await sha256Hex(purchaseToken),
    environment: body.testPurchase ? 'sandbox' : 'production',
    state: state === 'active' && expiresAt && new Date(expiresAt) < eventAt ? 'expired' : state,
    expiresAt, eventAt: eventAt.toISOString(),
  };
}

// deno-lint-ignore no-explicit-any
export async function mapProductPurchase(body: any, productId: string, purchaseToken: string, eventAt: Date,
  opts: { voided?: boolean; expectedUserId?: string } = {}): Promise<VerifiedPurchase> {
  if (productId !== 'numaya_compliments_3') throw new StoreError('unknown_product');
  const userId = requireAccountBinding(body?.obfuscatedExternalAccountId, opts.expectedUserId);
  // purchaseState: 0 purchased, 1 canceled, 2 pending. purchaseType 0 = test (licence tester).
  const state: VerifiedPurchase['state'] = opts.voided ? 'refunded'
    : body.purchaseState === 0 ? 'active' : body.purchaseState === 2 ? 'pending' : 'revoked';
  return {
    store: 'google_play', userId, productId, purchaseKey: await sha256Hex(purchaseToken),
    environment: body.purchaseType === 0 ? 'sandbox' : 'production',
    state, expiresAt: null, eventAt: eventAt.toISOString(),
  };
}

async function get(url: string, accessToken: string, fetchImpl: typeof fetch) {
  const res = await fetchImpl(url, { headers: { authorization: `Bearer ${accessToken}` } });
  if (res.status === 404 || res.status === 410) throw new StoreError('purchase_not_found');
  if (res.status === 401 || res.status === 403) throw new StoreError('google_not_authorized');
  if (!res.ok) throw new StoreError('google_unavailable', true);
  return res.json();
}

export function fetchSubscriptionV2(pkg: string, token: string, accessToken: string, fetchImpl: typeof fetch = fetch) {
  return get(`${API}/${encodeURIComponent(pkg)}/purchases/subscriptionsv2/tokens/${encodeURIComponent(token)}`, accessToken, fetchImpl);
}

export function fetchProductPurchase(pkg: string, productId: string, token: string, accessToken: string, fetchImpl: typeof fetch = fetch) {
  return get(`${API}/${encodeURIComponent(pkg)}/purchases/products/${encodeURIComponent(productId)}/tokens/${encodeURIComponent(token)}`, accessToken, fetchImpl);
}

export interface RtdnEvent {
  messageId: string;
  packageName: string;
  eventAt: Date;
  kind: 'subscription' | 'product' | 'voided' | 'test';
  purchaseToken?: string;
  productId?: string;
}

/** Decodes a Pub/Sub push body carrying a Real-time Developer Notification. */
// deno-lint-ignore no-explicit-any
export function parseRtdn(push: any, expectedPackage: string): RtdnEvent {
  const messageId = push?.message?.messageId ?? push?.message?.message_id;
  const data = push?.message?.data;
  if (!messageId || !data) throw new StoreError('bad_notification');
  const n = JSON.parse(atob(data));
  if (n.packageName !== expectedPackage) throw new StoreError('wrong_package');
  const eventAt = new Date(Number(n.eventTimeMillis));
  if (n.testNotification) return { messageId, packageName: n.packageName, eventAt, kind: 'test' };
  if (n.subscriptionNotification) {
    return { messageId, packageName: n.packageName, eventAt, kind: 'subscription', purchaseToken: n.subscriptionNotification.purchaseToken };
  }
  if (n.oneTimeProductNotification) {
    return { messageId, packageName: n.packageName, eventAt, kind: 'product',
      purchaseToken: n.oneTimeProductNotification.purchaseToken, productId: n.oneTimeProductNotification.sku };
  }
  if (n.voidedPurchaseNotification) {
    return { messageId, packageName: n.packageName, eventAt, kind: 'voided', purchaseToken: n.voidedPurchaseNotification.purchaseToken };
  }
  throw new StoreError('unknown_notification');
}

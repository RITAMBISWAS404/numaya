// POST /functions/v1/verify-purchase  (member JWT required)
// Body: {store: 'google_play', product_id, purchase_token} | {store: 'app_store', signed_transaction}
// Verifies with the store, binds the purchase to the caller (obfuscatedExternalAccountId /
// appAccountToken must equal the member id) and applies it with service_apply_purchase_state.
// Never trusts the client's success callback. Disabled (503) until configured and enabled.
import { createClient } from 'npm:@supabase/supabase-js@2.119.0';
import 'npm:reflect-metadata@0.2.2';
import * as x509 from 'npm:@peculiar/x509@3.1.0';
import { StoreError, googleAccessToken, type VerifiedPurchase } from '../_shared/store/common.ts';
import { ANDROID_PUBLISHER_SCOPE, fetchProductPurchase, fetchSubscriptionV2, mapProductPurchase, mapSubscriptionV2 } from '../_shared/store/google_play.ts';
import { mapAppleTransaction, verifyAppleJws } from '../_shared/store/apple.ts';
import { loadStoreConfig } from '../_shared/store/config.ts';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json(405, { error: 'method_not_allowed' });
  let cfg;
  try {
    cfg = loadStoreConfig((k) => Deno.env.get(k));
  } catch (e) {
    return json(503, { error: (e as StoreError).code ?? 'store_not_configured' });
  }
  const url = Deno.env.get('SUPABASE_URL')!;
  const service = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { persistSession: false } });
  const { data: who } = await service.auth.getUser(req.headers.get('authorization')?.replace('Bearer ', '') ?? '');
  if (!who?.user) return json(401, { error: 'not_authenticated' });
  try {
    const body = await req.json();
    let v: VerifiedPurchase;
    if (body.store === 'google_play' && cfg.google) {
      const token = await googleAccessToken(cfg.google.serviceAccount, ANDROID_PUBLISHER_SCOPE);
      v = String(body.product_id).startsWith('numaya_premium_')
        ? await mapSubscriptionV2(await fetchSubscriptionV2(cfg.google.packageName, body.purchase_token, token), body.purchase_token, new Date(), who.user.id)
        : await mapProductPurchase(await fetchProductPurchase(cfg.google.packageName, body.product_id, body.purchase_token, token),
          body.product_id, body.purchase_token, new Date(), { expectedUserId: who.user.id });
    } else if (body.store === 'app_store' && cfg.apple) {
      const tx = await verifyAppleJws(body.signed_transaction, { rootSha256: cfg.apple.rootSha256 }, x509);
      v = mapAppleTransaction(tx, { bundleId: cfg.apple.bundleId, userId: who.user.id });
    } else {
      return json(400, { error: 'store_not_supported' });
    }
    const { data, error } = await service.rpc('service_apply_purchase_state', {
      p_user: v.userId, p_store: v.store, p_key: v.purchaseKey, p_product: v.productId, p_env: v.environment,
      p_state: v.state, p_expires: v.expiresAt, p_event_at: v.eventAt,
    });
    if (error) return json(500, { error: 'apply_failed' });
    return json(200, { result: data, state: v.state, environment: v.environment });
  } catch (e) {
    const err = e as StoreError;
    return json(err.retryable ? 503 : 400, { error: err.code ?? 'verification_failed' });
  }
});

// POST /functions/v1/store-notifications/google  (Pub/Sub push, OIDC-authenticated)
// POST /functions/v1/store-notifications/apple   (App Store Server Notifications V2, signed)
// Deploy with --no-verify-jwt: these callers are the stores, authenticated by their own
// signatures. Replays are harmless: applying is idempotent, ids are recorded after success, older events never overwrite newer
// state; the latest state is always re-read from the store (never trusted from the payload alone).
import { createClient } from 'npm:@supabase/supabase-js@2.119.0';
import 'npm:reflect-metadata@0.2.2';
import * as x509 from 'npm:@peculiar/x509@3.1.0';
import { StoreError, googleAccessToken, sha256Hex, verifyGoogleOidc, type VerifiedPurchase } from '../_shared/store/common.ts';
import { ANDROID_PUBLISHER_SCOPE, fetchProductPurchase, fetchSubscriptionV2, mapProductPurchase, mapSubscriptionV2, parseRtdn } from '../_shared/store/google_play.ts';
import { mapAppleTransaction, parseAppleNotification } from '../_shared/store/apple.ts';
import { loadStoreConfig } from '../_shared/store/config.ts';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });

Deno.serve(async (req) => {
  let cfg;
  try {
    cfg = loadStoreConfig((k) => Deno.env.get(k));
  } catch (e) {
    return json(503, { error: (e as StoreError).code ?? 'store_not_configured' });
  }
  const service = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { persistSession: false } });
  const apply = async (v: VerifiedPurchase) => {
    const { error } = await service.rpc('service_apply_purchase_state', {
      p_user: v.userId, p_store: v.store, p_key: v.purchaseKey, p_product: v.productId, p_env: v.environment,
      p_state: v.state, p_expires: v.expiresAt, p_event_at: v.eventAt,
    });
    if (error) throw new StoreError('apply_failed', true);
  };
  const path = new URL(req.url).pathname;
  try {
    if (path.endsWith('/google') && cfg.google) {
      await verifyGoogleOidc(req.headers.get('authorization'), { audience: cfg.google.pushAudience, email: cfg.google.pushServiceAccount });
      const ev = parseRtdn(await req.json(), cfg.google.packageName);
      if (ev.kind === 'test') return json(200, { result: 'ignored' });
      const token = await googleAccessToken(cfg.google.serviceAccount, ANDROID_PUBLISHER_SCOPE);
      if (ev.kind === 'subscription') {
        await apply(await mapSubscriptionV2(await fetchSubscriptionV2(cfg.google.packageName, ev.purchaseToken!, token), ev.purchaseToken!, ev.eventAt));
      } else if (ev.kind === 'product') {
        await apply(await mapProductPurchase(await fetchProductPurchase(cfg.google.packageName, ev.productId!, ev.purchaseToken!, token),
          ev.productId!, ev.purchaseToken!, ev.eventAt));
      } else {
        const { data: known } = await service.rpc('service_purchase_by_key', { p_store: 'google_play', p_key: await sha256Hex(ev.purchaseToken!) });
        if (known) {
          await apply({ store: 'google_play', userId: known.user_id, productId: known.product_id, purchaseKey: await sha256Hex(ev.purchaseToken!),
            environment: known.environment, state: 'refunded', expiresAt: null, eventAt: ev.eventAt.toISOString() });
        }
      }
      // Recorded only after a successful apply: a failed attempt is redelivered and re-applied
      // (applying is idempotent and ignores older events).
      await service.rpc('service_record_store_event', { p_store: 'google_play', p_event_id: ev.messageId });
      return json(200, { result: 'applied' });
    }
    if (path.endsWith('/apple') && cfg.apple) {
      const n = await parseAppleNotification(await req.json(), { rootSha256: cfg.apple.rootSha256 }, x509);
      if (!n.transaction) return json(200, { result: 'ignored' });
      await apply(mapAppleTransaction(n.transaction, { bundleId: cfg.apple.bundleId }));
      await service.rpc('service_record_store_event', { p_store: 'app_store', p_event_id: n.notificationUUID });
      return json(200, { result: 'applied' });
    }
    return json(404, { error: 'unknown_route' });
  } catch (e) {
    const err = e as StoreError;
    // Retryable failures return 5xx so the store redelivers; authentication failures 401.
    if (['missing_push_auth', 'bad_push_auth', 'push_auth_expired', 'untrusted_root', 'bad_signature', 'bad_chain'].includes(err.code)) {
      return json(401, { error: err.code });
    }
    return json(err.retryable ? 503 : 400, { error: err.code ?? 'failed' });
  }
});

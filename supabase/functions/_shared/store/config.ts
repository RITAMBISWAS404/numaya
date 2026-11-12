// Store configuration from function secrets. Verification stays DISABLED (HTTP 503
// "store_not_configured") until STORE_VERIFICATION_ENABLED=true and the store's settings validate.
import { StoreError, type ServiceAccount } from './common.ts';

export interface StoreConfig {
  google?: { packageName: string; serviceAccount: ServiceAccount; pushAudience: string; pushServiceAccount: string };
  apple?: { bundleId: string; rootSha256: string };
}

export function loadStoreConfig(get: (k: string) => string | undefined): StoreConfig {
  if (get('STORE_VERIFICATION_ENABLED') !== 'true') throw new StoreError('store_not_configured');
  const cfg: StoreConfig = {};
  const sa = get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON');
  if (sa) {
    const json = JSON.parse(atob(sa));
    for (const k of ['client_email', 'private_key', 'token_uri']) if (!json[k]) throw new StoreError(`google_config_missing_${k}`);
    const packageName = get('GOOGLE_PLAY_PACKAGE_NAME');
    const pushAudience = get('GOOGLE_PUBSUB_PUSH_AUDIENCE');
    const pushServiceAccount = get('GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT');
    if (!packageName || !pushAudience || !pushServiceAccount) throw new StoreError('google_config_incomplete');
    cfg.google = { packageName, serviceAccount: json, pushAudience, pushServiceAccount };
  }
  const bundleId = get('APPLE_BUNDLE_ID');
  if (bundleId) {
    const rootSha256 = get('APPLE_ROOT_CA_G3_SHA256');
    if (!rootSha256 || !/^[0-9a-f:]{64,95}$/i.test(rootSha256)) throw new StoreError('apple_root_fingerprint_missing');
    cfg.apple = { bundleId, rootSha256 };
  }
  if (!cfg.google && !cfg.apple) throw new StoreError('store_not_configured');
  return cfg;
}

# Provider and feature status

**Statuses:** local verified (lint + PGlite + contract fixtures) · provider sandbox verified · dev-project verified · production approved · blocked · deferred.
An adapter that passes contract tests with fixtures is **not** a verified integration. Every row below is still unverified on a real Supabase project, because none exists yet (MANUAL_SETUP A1).

| Capability | Status | Evidence | To verify / still missing |
|---|---|---|---|
| Schema, RLS, RPCs, grants | local verified | 27/27 PGlite checks; Postgres-parser lint, 7 files | `activate` → `schema` + `tests` on the dev project (A1). |
| Phone OTP (Supabase Auth, test numbers) | adapter written; **blocked** | `auth_phone.test.mjs` | A3: Phone provider + test numbers. |
| Real SMS delivery | **blocked** | — | SMS budget + India DLT registration (Parts B and D). |
| Photo pipeline: quarantine → server re-encode (EXIF/GPS/XMP stripped, ≤1600 px, decoder pixel limit) → human review | local verified (SQL + sharp fixtures) | PGlite "photo pipeline"; `unit/workers.test.mjs` | Worker against real Storage (A1, A6). The device strip remains, but the server is now authoritative. |
| Photo moderation | manual staff queue + CLI (`npm run staff`) | PGlite; `staff.mjs` | A5 staff account; Part C staffing. **No automated CSAM or nudity scanning vendor** (public-launch blocker). |
| Chat photos and voice notes | local verified; **app flag off** (`NUMAYA_LIVE_ATTACHMENTS`) | PGlite "chat media"; workers fixtures; `tests/media.test.mjs` (real, not run) | Real-project run, then build with `--attachments`. Video stays unsupported (`kind_not_supported`). |
| Realtime chat | written; **blocked** | `chat_realtime.test.mjs` | A1. |
| Push (FCM HTTP v1) sender + device-token lifecycle | contract-tested with fixtures; **disabled** without a key | `unit/workers.test.mjs` (JWT assertion, UNREGISTERED → revoke, 429/5xx retry, 401/403 config error) | A7 key. **App-side token capture (`firebase_messaging`) is not built**, so no device receives push yet. APNs not started. |
| Outbox retries / dead letter | local verified | PGlite "outbox" | Monitor alert `outbox_dead > 0`. |
| Privacy export (async, re-auth within 15 min, 7-day signed object) | local verified | PGlite; `privacy.test.mjs` (real, not run) | A1. **No app entry point** (V8 UI has none). |
| Deletion: 28-day restore, purge, tombstone replay on restore | local verified | PGlite; `backup_restore.test.mjs` | A1 + A6 schedule. |
| Backups (AES-256-GCM) + isolated restore drill | scripts written; **blocked** | `backup.mjs`, `restore_drill.mjs` | A1 + A4. |
| Rate limits and abuse controls (per-action limits, report-threshold review hold, unanswered-message cap) | local verified; values are FIXTURES | PGlite "abuse" | Owner approves values (DECISIONS P1, P11). Not load-tested. |
| Google Play verification (subscriptionsv2, products, RTDN with Pub/Sub OIDC) | contract-tested with fixtures; **disabled** | `unit/store.test.mjs` | A8 (paid Play account) + sandbox purchase. **No billing client in the app.** |
| App Store verification (JWS x5c chain to a pinned root, ES256, marker OIDs) | contract-tested with fixtures; **disabled** | `unit/store.test.mjs` (self-generated test chain, labelled) | A8 (paid Apple account); confirm the root fingerprint. No billing client. |
| Entitlement lifecycle (grant, renew, expire, refund reversal, stale events, sandbox isolation) | local verified | PGlite "store" | Real store events. |
| Ops health + monitor thresholds | local verified (SQL); script written | PGlite "ops"; `monitor.mjs` | A1; thresholds DECISIONS P10. |
| Scheduling | pg_cron housekeeping in a migration; worker via GitHub Actions (variable-gated) or Task Scheduler | `activate` → `schedules` | A6. |
| CI | workflow written (local checks + Flutter on push; real tests on manual dispatch; worker on schedule) | `.github/workflows/backend.yml` | First run happens on push; real jobs need the `NUMAYA_DEV_ENV_LOCAL` secret. |
| Selfie / liveness verification | **deferred** | — | Not MVP. |
| Calls, Events, Health, biometrics | **deferred** | — | Not MVP. |

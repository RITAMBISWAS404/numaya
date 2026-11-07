# MVP PRD v1: implementation report (2026-11-07)

**Branch** `experiment/numaya-mvp-prd-20261107` (from `c56e36b`, tag `checkpoint/pre-mvp-prd-20261107`).
**Commit** implementation `f6c4d8b` (handoff docs follow it).
**APK** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-MVP-PRD-20261107-f6c4d8b.apk`, debug,
222,135,345 bytes, SHA-256 `2e3d2aaddbb7a5ff4842d5661dd027d6b789cf03ad7d2877197e55a54b87e1b5`, demo
environment, local demo photos installed (git-ignored).
**Tests** `flutter analyze` no issues; `flutter test` 564 passed, 21 skipped, 0 failed.
**Screens** `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\MVP PRD 2026-11-07\`
(`index.tsv`: file → S-ID → state). Real `adb screencap` from the Pixel 10 emulator (API 36,
1080×2424), driven by `integration_test/mvp_gallery_test.dart` with the deterministic demo world;
harness-driven navigation, not hand-tapped.

## Implemented (demo, all 46 S-IDs reachable)
See [TRACEABILITY.md](TRACEABILITY.md) for the per-screen map. New: Compliments (composer, Requests,
reply, dismiss, conversion on match), like allowance with IST reset and S17, match lifecycle (one
extension, 7-day check-in, 14-day expiry, free reconnection with acceptance), credit ledger and
wallet, streak with recovery, Profile Health v1 and explanation, Insights (7 free; 28/90 Premium,
low-sample), Premium with provisional INR and full renewal terms, Compliment pack, recovery
purchase, purchase outcomes, legal (signed out too), support requests, text-only chat, mute,
spam guard, notification categories. Decisions: [DECISIONS.md](DECISIONS.md).

## Contracts (not live)
`backend/` schema with RLS, transactional SQL functions, Edge Function contracts for purchase and
recovery verification, jobs, rate limits, pgTAP cross-user denial tests (not run: no database).
`lib/app/backend/numaya_api.dart`: live API contract with an unconfigured implementation.

## Deferred (PRD 01)
Events (gated off), SuperSwipe, calls, attachments (gated off), boosts, Incognito, photo analytics.

## Not done / blockers
[LIVE_BLOCKERS.md](LIVE_BLOCKERS.md). Nothing here is live: no backend, OTP, billing, moderation,
push, analytics or crash reporting. The debug APK is for review, not a public release.

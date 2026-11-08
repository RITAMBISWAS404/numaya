# Numaya backend (MVP contracts)

**Status (2026-11-07, lifecycle amended 2026-11-08): designed, not provisioned.** No backend project, database, SMS provider,
store products or credentials exist for Numaya. Nothing in this folder has been applied or run.

| Path | What |
|---|---|
| `migrations/0001_mvp_schema.sql` | Tables, constraints and row-level security (PRD 05 list) |
| `migrations/0002_mvp_functions.sql` | Transactional endpoints: like, Compliment, reply, message (revives archived chats), extend |
| `functions/CONTRACTS.md` | Request/response contracts, purchase and recovery verification, jobs, rate limits |
| `tests/rls_cross_user.sql` | pgTAP cross-user denial tests to run once a local stack exists |

Candidate stack: Supabase (Postgres + Auth phone OTP + Storage + Realtime + Edge Functions),
chosen only if compatible with the co-founder's partner stack (PRD 05 "confirm existing backend
before selecting provider"; no existing backend was found in this repository).

The Flutter app's demo implementation mirrors these rules in pure Dart
(`apps/numaya_mobile/lib/features/{commerce,likes,matches,compliments,streaks,health}/domain`), with
unit tests in `apps/numaya_mobile/test/unit/mvp_rules_test.dart`. The live build must call the
endpoints instead; `ApiConfig` in `lib/app/backend/numaya_api.dart` reports "not configured".

Setup needed before any live use: see `docs/product/mvp-prd-v1/LIVE_BLOCKERS.md`.

# Validation ledger

Evidence is listed by level. Local, fixture and contract results are never reported as Supabase, provider or device verification.

| Level | What | Command | Result | Commit |
|---|---|---|---|---|
| Syntax | All migrations and every PL/pgSQL body, through the real Postgres parser (libpg-query 18) | `npm run check:local` (lint part) | 7 files, 220 statements, 93 functions: ok | continuation (see WORK_LOG) |
| Local semantic (PGlite with a labelled Supabase stand-in) | Earlier 18 checks, plus photo pipeline, chat media, outbox retry and dead letter, push targets and preferences, report-threshold hold, unanswered cap, store state machine (grant, stale, sandbox, refund), ops health, service-only store functions | `node local_semantic/run.mjs` | **27/27 pass** | continuation |
| Contract (fixtures, labelled) | Workers: image re-encode strips EXIF/GPS, decoder limit, voice magic bytes, FCM JWT and error mapping, push payload has no names or bodies | `npm run test:unit` | **17/17** (workers 6, store 7, activation config 4) | continuation |
| Contract (fixtures, labelled) | Store: Google subscription/product mapping, account binding, RTDN parse, Pub/Sub OIDC; Apple JWS chain against a self-made test root, wrong root refused, marker OIDs | same | included above | continuation |
| Flutter unit | Photo sanitiser | `flutter test test/unit/live_photo_sanitize_test.dart` | 2/2 | `d6f626a` |
| Flutter regression (demo mode; live layer compiled in but off) | Full suite after session restore, live attachments and voice URLs | `flutter test` | **648 passed, 42 skipped, 0 failed** (skips are the base branch's superseded tests). `flutter analyze` on the changed live files: no issues | `1af5e31` |
| Real-service guard | The suite refuses to run without configuration (no silent pass) | `npm test` with no `.env.local` | 8/8 files fail with "Backend not configured" (expected) | continuation |
| Supabase (real) | `tools/backend/tests/*.test.mjs`: permissions, matching races, credit concurrency, chat and realtime, privacy and export, phone OTP, backup and restore, media | `npm run activate -- --confirm-project=<ref>` | **not run: no dev project yet** (MANUAL_SETUP A1) | — |
| Provider sandbox | FCM, Google Play, App Store | — | **not run: no accounts** (A7, A8) | — |
| Device | Two-user journey on the emulator or a phone against the dev project | ACTIVATION_RUNBOOK §2 | **not run: blocked** | — |

**Not verifiable locally:**
- True concurrency: PGlite is single-connection.
- PostgREST exposure and grants as Supabase applies them.
- Storage signed URLs, bucket limits and object metadata.
- Realtime RLS filtering.
- Supabase Auth OTP and the `amr` claim used for re-authentication.
- pg_cron execution.
- PostGIS (stand-in functions were used).
- Real FCM, Google and Apple responses.

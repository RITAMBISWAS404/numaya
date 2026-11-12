# Validation ledger

Evidence is listed by level. Unit and local results are never reported as Supabase or device verification.

| Level | What | Command | Result | Commit |
|---|---|---|---|---|
| Syntax | All migrations and every PL/pgSQL body, with the real Postgres parser. Proven to catch a broken body. | `npm run check:local` (lint part) | 4 files, 152 statements, 56 functions: ok | `d98f247` |
| Local semantic (PGlite, Supabase stand-in) | Onboarding/18+, RLS denials, private schema, server columns, storage folders and visibility, 6-photo cap, type check, reorder, discovery fields, idempotent likes, reciprocal match, ordered and idempotent chat, outsider denial, Compliment debit/pending/reply/no-credit rollback, streak award, extension and expiry, block/unblock, report evidence and staff audit, Premium weekly/likes, export, deletion/restore/purge, anon denial | `node local_semantic/run.mjs` | **18/18 pass** (first run found a real `decide()` defect, fixed) | `d98f247` |
| Flutter unit | Photo sanitiser strips EXIF/GPS, caps 1600 px, refuses non-images | `flutter test test/unit/live_photo_sanitize_test.dart` | 2/2 | `d6f626a` |
| Flutter regression (demo mode) | Existing suite with the whole live layer compiled in but off | `flutter test` | **648 passed, 42 skipped, 0 failed** (the 42 are the base branch's superseded tests; none added). `flutter analyze`: 1 pre-existing info in frontend-owned `test/widget/ente_alignment_test.dart` (deprecated `containsSemantics`), left for the frontend session | `d98f247` |
| Supabase (real) | `tools/backend/tests/*.test.mjs`: permissions, matching races, credits concurrency, chat/realtime, privacy, phone OTP, backup/restore | `npm test` | **not run: blocked on credentials** | — |
| Device | Two-user journey on the emulator or a phone against the dev project | — | **not run: blocked** | — |

**Not verifiable locally:**
- True concurrency: PGlite is single-connection.
- PostgREST exposure and grants as Supabase applies them.
- Storage signed URLs and bucket limits.
- Realtime RLS filtering.
- Supabase Auth OTP.
- PostGIS (stand-in functions were used).

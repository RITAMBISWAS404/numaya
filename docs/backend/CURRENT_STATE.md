# Backend current state

**2026-11-13, early hours (IST): gates 0–1 done; gates 2–10 written and checked locally; real-backend verification blocked on the owner's dev project credentials.**

- **Worktree:** `C:\Users\biswa\Projects\Numaya-backend`.
- **Branch:** `experiment/numaya-backend-20261112-2255` (base `c890d02` = replacement V8, origin-verified). The latest pushed commit is in WORK_LOG.
- **Target database:** none yet. `supabase/.env.local` is missing, so no migration has been applied to Supabase and the `tools/backend/tests` suite has not run.

| Gate | Status | Evidence |
|---|---|---|
| 0 Handoff and isolation | local verified | Separate worktree. UI checkout untouched. FILE_OWNERSHIP checkpoint 0. |
| 1 Contracts and security | done (docs) | API_CONTRACT, PERMISSIONS, THREAT_MODEL, RETENTION_AND_LEGAL, SCOPE_MATRIX, COST_MODEL. |
| 2 Foundation (schema, RLS, auth bootstrap) | **local semantic verified only** | `npm run check:local`: Postgres parser lint plus 18/18 PGlite checks. **Blocked** on Supabase verification. |
| 3 Two-user vertical slice | app layer written; **blocked** | Live auth, profile, discovery, match, chat and realtime need the dev project. |
| 4 Profiles and discovery | server written + local verified; app wired | Photo cap, type, folder and visibility checked locally. |
| 5 Compliments, credits, streaks | server written + local verified; app wired | Concurrency only provable on Supabase (tests written). |
| 6 Chat, media, push | text chat written + local verified | Attachments deferred (hidden live). Push blocked (no FCM). |
| 7 Safety, admin, privacy | server written + local verified | Staff RPCs with audit. No staff UI (SQL/RPC only). Deletion worker written. |
| 8 Providers and entitlements | not started / blocked | No SMS, push or store credentials. Billing not built. |
| 9 Hardening | partial | Device EXIF strip (unit-tested). Server-side image worker, load tests and CI are pending. |
| 10 Delivery (dev APK on the real backend) | **blocked** | Needs the dev project URL and publishable key. |

**Next action when credentials arrive:**
1. `cd tools/backend && npm run db:push`.
2. `npm test`.
3. Fix anything the real platform reveals.
4. Build the APK with the dev-defines (DELIVERY below).
5. Run the two-phone/emulator journey.
6. Record evidence in VALIDATION.

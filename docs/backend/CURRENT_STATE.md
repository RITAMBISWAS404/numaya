# Backend current state

**2026-11-13 (IST):** Backend V1 and the continuation are implemented and locally verified.
**Real-service verification is waiting on owner setup** ([MANUAL_SETUP.md](MANUAL_SETUP.md)), deliberately deferred by the owner.
**This is not production-ready**, and adding credentials alone will not make it so (MANUAL_SETUP Parts B–D).

- **Worktree:** `C:\Users\biswa\Projects\Numaya-backend`.
- **Branch:** `experiment/numaya-backend-20261112-2255` (base `c890d02`). The latest pushed commit is in WORK_LOG.
- **Target database:** none. `supabase/.env.local` does not exist; no migration has been applied anywhere.
- **Next action:** owner completes MANUAL_SETUP Part A (at least A1, A3, A5), then sends [RESUME_AFTER_SETUP.txt](RESUME_AFTER_SETUP.txt). The agent then runs [ACTIVATION_RUNBOOK.md](ACTIVATION_RUNBOOK.md).

| Gate | Status | Evidence |
|---|---|---|
| 0 Handoff and isolation | local verified | Separate worktree; UI checkout untouched. |
| 1 Contracts and security | done (docs) | API_CONTRACT, PERMISSIONS, THREAT_MODEL, RETENTION_AND_LEGAL, SCOPE_MATRIX, COST_MODEL. |
| 2 Foundation | local verified | Lint 7 files; PGlite 27/27. |
| 3 Two-user slice | app wired; **blocked** on the dev project | — |
| 4 Profiles, discovery, photo pipeline | local verified | Server re-encode worker + human review; staff CLI. |
| 5 Compliments, credits, streaks | local verified | Concurrency provable only on Supabase (tests written). |
| 6 Chat, media, push | local verified; attachments flag off in the app; push sender disabled | Missing: device push-token capture. |
| 7 Safety, admin, privacy | local verified | Report-threshold hold, unanswered cap, async export, 28-day restore, purge, staff CLI, monitor. |
| 8 Providers and entitlements | contract-tested with fixtures; disabled | Missing: billing client in the app; store accounts (paid). |
| 9 Hardening | partial | CI workflow, activation workflow, backups. Missing: load tests, secret scanning, staff MFA. |
| 10 Delivery (dev APK on the real backend) | **blocked** | `activate` → `apk` builds it once A1 exists. |

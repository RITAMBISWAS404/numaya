# Backend current state

**2026-11-12 23:30 IST: Phase 0 done; Phase 1–2 written, not yet applied.**

| Gate | Status | Evidence |
|---|---|---|
| 0 Handoff and isolation | local verified | Worktree `C:\Users\biswa\Projects\Numaya-backend`, branch `experiment/numaya-backend-20261112-2255` from `c890d02` (= origin). UI checkout untouched. |
| 1 Contracts and security | in progress | Migrations `supabase/migrations/2026111300010x_*.sql` (schema, RLS, RPCs, storage, realtime); tests in `tools/backend/tests/`. |
| 2 Foundation on a real backend | **blocked** | Waiting for the dev project credentials (DECISIONS_REQUIRED). Nothing has been applied to any database yet. |
| 3 Two-user vertical slice | not started | Needs gate 2. |

Target database: none yet (`supabase/.env.local` missing). No migration has run, so no test has
run against a database. Do not read the written tests as passing.

Tooling: Supabase CLI 3.1.0, supabase-js 2.119.0, pg 8.23.1 (`tools/backend/package.json`, pinned).
No Docker on this machine (local stack unavailable; owner chose a hosted free dev project).

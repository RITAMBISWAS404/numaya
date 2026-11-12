# Backend work log

## 2026-11-12/13 · Backend execution V1 (Windows, Claude desktop)
- **Verified the baseline.** UI checkout on `experiment/numaya-v8-premium-rebuild-20261112-1945` at `c890d02`, equal to origin, untracked `.claude/launch.json` only. No emulator or capture running.
- **Created the worktree and branch.** Worktree `C:\Users\biswa\Projects\Numaya-backend`, branch `experiment/numaya-backend-20261112-2255` from `c890d02`, pushed. The UI checkout was never edited, switched or committed.
- **Local stack decision (owner).** No Docker or WSL on this PC, so the owner chose a hosted free Supabase dev project. Credentials were requested into a git-ignored `supabase/.env.local`. **Not yet provided at the end of this run.**
- **Commits:**
  - `191f384`: schema, RLS, RPCs, storage, realtime, test suite.
  - `e35ad57`: Flutter live layer (auth, profile, discovery, matches, chat, realtime, Compliments, wallet).
  - `d6f626a`: backup and restore drill, EXIF strip, contract docs.
  - `d98f247`: SQL lint and PGlite local semantic check; fixed ambiguous `kind` in `decide()`.
- **Reconciliations:**
  - 28-day restore window (the approved UI) instead of immediate purge.
  - Action-time compatibility checks (not only in the feed).
  - Streak qualification recount after the row lock (race fix).
  - Own birth date from `account_state` (a placeholder date was removed before commit).
  - Real gender on cards.
  - Chat attachments hidden in live builds.
  - No demo sign-in in live builds.
- **Tooling** (pinned in `tools/backend/package.json`): Supabase CLI 3.1.0, supabase-js 2.119.0, pg 8.23.1, libpg-query 18.2.2, PGlite 0.5.16. Flutter: `supabase_flutter ^2.18.3`, `image ^4.12.0`.
- **Skills:** the repo already has the relevant Flutter and design skills; the official `supabase/agent-skills` Postgres skill was **not installed** in this run (see DECISIONS / next steps).

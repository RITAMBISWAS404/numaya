# Numaya backend: start here

Backend work runs in its **own worktree**, separate from UI work.

- **Worktree:** `C:\Users\biswa\Projects\Numaya-backend`
- **Branch:** `experiment/numaya-backend-20261112-2255`
- **Base:** `c890d02` (replacement V8 delivery; app source `ee87648`), verified equal to origin on 2026-11-12.
- **UI checkout:** `C:\Users\biswa\Projects\Numaya` on `experiment/numaya-v8-premium-rebuild-20261112-1945`. Never edit, switch or commit it from here.

**Owner setup and activation:** [MANUAL_SETUP.md](MANUAL_SETUP.md) (owner actions only) · [ACTIVATION_RUNBOOK.md](ACTIVATION_RUNBOOK.md) (`npm run activate`) · [RESUME_AFTER_SETUP.txt](RESUME_AFTER_SETUP.txt) (copy-ready prompt).

Read in order:
1. [CURRENT_STATE.md](CURRENT_STATE.md): what works, against which backend, at which commit.
2. [DECISIONS_REQUIRED.md](DECISIONS_REQUIRED.md): the single owner checklist (credentials, policies, people).
3. [FILE_OWNERSHIP.md](FILE_OWNERSHIP.md): who edits what; integration checkpoints.
4. [SCOPE_MATRIX.md](SCOPE_MATRIX.md): every active screen action mapped to API, permission, data and test.
5. [API_CONTRACT.md](API_CONTRACT.md), [DATA_DICTIONARY.md](DATA_DICTIONARY.md), [PERMISSIONS.md](PERMISSIONS.md), [THREAT_MODEL.md](THREAT_MODEL.md).
6. [PROVIDER_STATUS.md](PROVIDER_STATUS.md), [VALIDATION.md](VALIDATION.md), [WORK_LOG.md](WORK_LOG.md).

Resume rule: verify `git status`, the remote SHA and the target database (`supabase/.env.local`
`SUPABASE_PROJECT_REF`), then continue at the first incomplete gate in CURRENT_STATE.
Secrets live only in `supabase/.env.local` (git-ignored). Never paste them into chat or commit them.

# Start here: agent handoff

> **2026-11-14, V8 UI review applied. Read this first.**
> - **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (a worktree). **Branch:** `experiment/numaya-v8-review-20261114-0321`, from `7cd7aa4` (tag `checkpoint/selected-20261114-0321`). App source `fe44b27`.
> - **What it is:** the owner's V8 review register (UI-001 to UI-086) applied with the execution companion; a persisted 14/15 body-size toggle plus display and UI font selectors (Prototype tools > Typography); alternatives for Premium, statistics cards, Match and Profile in the gallery and the Design Lab (choices kept across relaunches).
> - **Records:** [docs/v8-review](../v8-review/FINAL_REVIEW.md): FINAL_REVIEW, ISSUE_LEDGER.csv, OPEN_DECISIONS, ARTWORK_SLOTS.csv, RUN_STATE.
> - **Review folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f`.
> - **Real backend:** BLOCKED (no Supabase project, OTP, billing or push). The backend branch is not merged here.
> - **Other checkouts:** `C:\Users\biswa\Projects\Numaya` and `C:\Users\biswa\Projects\Numaya-backend` are separate work. Do not switch or edit them from here.

> **2026-11-13, selected designs applied. Read this first.**
> - **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (a worktree). **Branch:** `experiment/numaya-selected-20261113-0232`, from the Fable lab `c6a31a4` (tag `checkpoint/fable-lab-20261113-0232`). App source `ae10663`.
> - **What it is:** the owner's export `fx-da197b7-2026-11-13` applied as the app defaults, with every note (Discover O with notes, Profile A, Messages A, Received Compliment A, Credits O and Streak O on one summary card), plus a labelled Explore the demo entry on Welcome.
> - **Records:** [docs/design/selections](../design/selections/FINAL_REVIEW.md): FINAL_REVIEW, JOURNEY_EVIDENCE.csv, BACKEND_BOUNDARY.
> - **Real backend:** BLOCKED (no Supabase project, OTP not configured, no billing or push). The backend branch is not merged here.
> - **Other checkouts:** `C:\Users\biswa\Projects\Numaya` and `C:\Users\biswa\Projects\Numaya-backend` are separate work. Do not switch or edit them from here.

> **2026-11-13, Fable design lab. Read this first.**
> - **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (a worktree). **Branch:** `experiment/numaya-fable-design-20261113-0048`, based on the replacement V8 `c890d02`. App source `da197b7`.
> - **What it is:** six experiment groups with real alternatives (Discover, Profile, Messages, Received Compliment, Credits, Streak). The app default is still the owner's baseline (O) in every group.
> - **Records:** [docs/design/fable-lab](../design/fable-lab/EXPERIMENTS.md): EXPERIMENTS, COVERAGE.csv, QA_HANDOFF.
> - **Next:** the owner reviews the gallery and exports choices. Then follow QA_HANDOFF. Do not pick options for the owner.
> - **Other checkouts:** `C:\Users\biswa\Projects\Numaya` (replacement V8) and `C:\Users\biswa\Projects\Numaya-backend` are separate work. Do not switch or edit them from here.

> **2026-11-12, replacement V8 delivered (premium candidate). Read this first.**
> - **Branch:** `experiment/numaya-v8-premium-rebuild-20261112-1945`, from the selected V7 `b5e5245` (all 36 owner selections kept). App source `ee87648`.
> - **Brief:** `NUMAYA_V8_REPLACEMENT_PREMIUM.zip`. Records are in [docs/v8-replacement](../v8-replacement/DECISIONS.md).
> - **Superseded:** the earlier V8 and V9 are archived on `archive/superseded-v8-v9-20261112` and `archive/superseded-v8-20261112`; do not use them as the direction.
> - **Next:** the owner reviews the gallery and the phone folder, then exports choices. The quirky direction is deferred to a later branch. No new work until the owner replies.

This folder carries Numaya work across Claude sessions and accounts. A new session reads it before
doing anything else, and the session that stops updates it before it ends.

> **Latest work (2026-11-08):** Visual Lab V2 on `experiment/numaya-visual-lab-20261108`; read
> CURRENT_STATE first. New laptop: [NEW_MACHINE_SETUP.md](NEW_MACHINE_SETUP.md). The account-switch
> note below is historical.

> **Latest handoff (2026-11-09): read [ACCOUNT_HANDOFF.md](ACCOUNT_HANDOFF.md) first.**

> **Account switch (2026-11-07):** read [`NUMAYA_ACCOUNT_HANDOFF.md`](../../NUMAYA_ACCOUNT_HANDOFF.md)
> at the repo root first: working branch `experiment/numaya-15px-icons-20261107` (the approved
> 15px design baseline), local-only files, tools, and the next task (revised PRD).

## Read in this order
1. [CURRENT_STATE.md](CURRENT_STATE.md): branch, commit, what is built, environment.
2. [ACTIVE_TASK.md](ACTIVE_TASK.md): the one task in progress and its acceptance criteria.
3. [DECISIONS.md](DECISIONS.md): handoff-level decisions. Design decisions live in
   [the premium refinement log](../design-experiments/monochrome-meetup-premium/DECISIONS.md).
4. [VALIDATION.md](VALIDATION.md): the commands that must pass, and the last results.
5. [NEXT_STEPS.md](NEXT_STEPS.md): the queue after the active task.
6. [WORK_LOG.md](WORK_LOG.md): what each session did, newest first.

[HANDOFF_PROMPT.md](HANDOFF_PROMPT.md) is the message to paste into a new account to resume.

## Verify before working
```sh
git fetch origin
git status                      # must be clean, or explained in WORK_LOG
git rev-parse --abbrev-ref HEAD # must match CURRENT_STATE
git log --oneline -1            # must match, or be newer than, CURRENT_STATE
```
If any of these disagree with CURRENT_STATE, stop and report the difference before you change
anything.

## Before you stop
- Append a WORK_LOG entry: date, account or session, what changed, commits.
- Update CURRENT_STATE (branch, commit, state), ACTIVE_TASK (progress) and VALIDATION (results).
- Commit the handoff files with the work and push.

## Ground rules
- `CLAUDE.md` comes first. These files never override it.
- Do not change the approved Monochrome Premium design without a recorded decision.
- Do not touch `experiment/numaya-android12-compat` or `design/apple-impeccable-full-app`.
- Record facts you checked, not assumptions. Say "not verified" when it wasn't.

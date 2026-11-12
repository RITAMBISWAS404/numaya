# Start here: agent handoff

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

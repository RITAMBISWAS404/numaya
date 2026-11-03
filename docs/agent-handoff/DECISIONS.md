# Handoff decisions

Process and branch decisions. Design decisions belong in
[the premium refinement log](../design-experiments/monochrome-meetup-premium/DECISIONS.md)
(PR-01 to PR-16); add new design decisions there as PR-17 onwards, or here as FP-xx if they are
specific to the final polish.

| # | Date | Decision | Why |
|---|---|---|---|
| H-01 | 2026-11-04 | Final polish happens on `experiment/numaya-final-ux-polish`, branched from `e70135c` | Isolates the work; the approved baseline stays recoverable |
| H-02 | 2026-11-04 | `experiment/numaya-android12-compat` and `design/apple-impeccable-full-app` are not touched | Owner's instruction; the Android 12 work is already in the baseline |
| H-03 | 2026-11-04 | `docs/agent-handoff/` is the cross-session record, and `CLAUDE.md` points to it | Work moves between Claude accounts; context must survive in the repo |
| H-04 | 2026-11-04 | No system-wide environment changes (no `ANDROID_HOME`, no `PATH` edits) | Flutter already finds the SDK; adb works by full path |

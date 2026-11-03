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
| H-05 | 2026-11-04 | Design decisions of the polish are FP-01 to FP-14 in `docs/design-experiments/numaya-final-ux-polish/DECISIONS.md` | Keeps design rationale beside the design docs |
| H-06 | 2026-11-04 | Before/after evidence is rendered on one machine for both sides (baseline from `git archive e70135c`, in the session scratchpad) | The committed goldens were Linux renders; comparing across platforms is misleading |
| H-07 | 2026-11-04 | No system-wide Android changes; the emulator was started from the SDK path with `-gpu swiftshader_indirect` | Only the `Pixel_10` AVD has an installed system image; the hardware GPU path left it offline |

# Account handoff

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `experiment/numaya-v7-selected-20261110`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-v7-selected-20261110`.
- **Checkpoint before selections:** tag `checkpoint/pre-v7-selection-20261110` (`2fb12f9`), the unselected V7 lab.
- **App source:** `014ac35`. Later commits change only records. Not merged anywhere.
- **Selections:** [SELECTIONS.md](../design/creative-lab-v7/SELECTIONS.md), export `v7-71564be-2026-11-10`. Each is the group's `proposed` value.
- **Scope:** Events and Health deferred. Consent, safety, privacy, payment amounts, awards, eligibility and messaging permissions unchanged.
- **Development controls:** off by default. Build with `--dart-define=NUMAYA_DEV_TOOLS=true` to get the Demo Hub, labs and alternatives back.
- **Next action:** the owner tests on a phone. Remaining items: [REMAINING_WORK.md](REMAINING_WORK.md).
- **Phone folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya V7 Selected Screenshots\2026-11-10 014ac35` (204 PNGs).
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-MVP-V7-Selected-20261110-014ac35.apk` (debug, 0.1.0+1, SHA-256 `ced6dde61513d682c42fe94772258f4d7dc6db4d062011f352a1f840d319dde5`).
- **Earlier gallery, kept for recovery:** `C:\Users\biswa\OneDrive\Desktop\Numaya MVP V7 Review\2026-11-10 1305\index.html`.
- **Capture warning:** check for leftover capture jobs before using the emulator. Two runs force-stop each other with only "did not complete".
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics\`, `apps/numaya_mobile/assets/demo/photos/` (only its README is tracked), APKs, review folders, `.claude/launch.json`. They show private photos. **No private backup exists.**
- **Known baseline failures:** web token and icon checks and one token test fail on CRLF only; browser e2e needs Playwright's browser.
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

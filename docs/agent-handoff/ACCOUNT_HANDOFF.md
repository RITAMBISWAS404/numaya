# Account handoff

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `experiment/numaya-creative-lab-v7-20261110-0236`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-creative-lab-v7-20261110-0236`.
- **Checkpoint before V7:** tag `checkpoint/pre-v7-20261110-0236` (`45b3872`).
- **App source:** `71564be`. Later commits change only records and tooling. Not merged anywhere.
- **Scope:** Events and Health deferred. Consent, safety, privacy, payment amounts, awards, eligibility and messaging permissions unchanged.
- **Default:** baseline plus V6. No experiment is selected. Recommendations are gallery notes only.
- **Next action:** the owner chooses in the gallery, exports JSON and sends it back. Apply it in a separate pass.
- **Remaining work:** [REMAINING_WORK.md](REMAINING_WORK.md).
- **Phone folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya MVP V7 Screenshots\2026-11-10 1305` (203 PNGs).
- **Selection gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya MVP V7 Review\2026-11-10 1305\index.html`
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-MVP-V7-20261110-71564be.apk` (debug, 0.1.0+1, SHA-256 `ca677391ea5cc2b472d68ba6666ea6dcd097b27ee82f61d07d5662c7cb0653ab`).
- **Records:** `docs/design/creative-lab-v7/` (README, `experiments.json`, ledger, references).
- **Capture warning:** check for leftover capture jobs before using the emulator. Two runs force-stop each other with only "did not complete".
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics\`, `apps/numaya_mobile/assets/demo/photos/` (only its README is tracked), APKs, review folders, `.claude/launch.json`. They show private photos. **No private backup exists.**
- **Known baseline failures:** web token and icon checks and one token test fail on CRLF only; browser e2e needs Playwright's browser.
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

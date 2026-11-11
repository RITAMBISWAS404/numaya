# Account handoff

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `version-8`. Verify with `git status -sb` and `git ls-remote origin version-8`.
- **Protected V7:** tag `checkpoint/v7-selected-baseline-20261111` (`b5e5245`), on `experiment/numaya-v7-selected-20261110`. Do not modify it.
- **App source:** `45eadc1`, plus a later import-order cleanup with no change in behaviour.
- **V8 records:** [DESIGN_SYSTEM.md](../design/v8/DESIGN_SYSTEM.md), [TYPOGRAPHY.md](../design/v8/TYPOGRAPHY.md).
- **Scope:** Events and Health deferred. Consent, safety, privacy, payment amounts, awards, eligibility and messaging permissions unchanged.
- **Development controls:** off by default; build with `--dart-define=NUMAYA_DEV_TOOLS=true`.
- **Next action:** the owner tests the APK on a phone. Remaining items: [REMAINING_WORK.md](REMAINING_WORK.md).
- **Phone folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Screenshots\2026-11-11 45eadc1` (206 PNGs).
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-V8-20261111-45eadc1.apk` (debug, 0.1.0+1, SHA-256 `7311df79879936029386c3b010cabb4abfe67907109c8a455a384bac79709fff`).
- **Fonts:** Google Sans and Bree Serif from google/fonts (OFL); licences in `apps/numaya_mobile/assets/fonts/`.
- **Capture warning:** check for leftover capture jobs before using the emulator. Two runs force-stop each other with only "did not complete". The emulator also sometimes closes between runs.
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics\`, `apps/numaya_mobile/assets/demo/photos/` (only its README is tracked), APKs, review folders, `.claude/launch.json`. They show private photos. **No private backup exists.**
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

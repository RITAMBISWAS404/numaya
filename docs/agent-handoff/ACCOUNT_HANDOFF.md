# Account handoff

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `version-9`. Verify with `git status -sb` and `git ls-remote origin version-9`.
- **Protected:** V8 is `version-8` and tag `checkpoint/v8-baseline-20261112` (`47ba247`). V7 is tag `checkpoint/v7-selected-baseline-20261111` (`b5e5245`). Modify neither.
- **App source:** `fb9e5cb`.
- **V9 records:** [docs/v9](../v9/design-decisions.md): research, decisions, implementation report, the design gallery HTML, and the screenshot index.
- **Scope:** Events and Health stay deferred. Consent, safety, privacy, payment amounts, awards and messaging permissions are unchanged.
- **Development controls:** off by default. Build with `--dart-define=NUMAYA_DEV_TOOLS=true` to turn them on.
- **APK:** `build/v9/namaya-v9.apk` (release mode, debug-key signed, 0.1.0+1, SHA-256 `127c802c90c472264c4b58c29f860937c27eee1e19cfb60a54e02fc44623536f`).
- **Screenshots:** `docs/v9/screenshots/` (206 PNGs, local only).
- **Capture warning:** check for leftover capture jobs before using the emulator. The emulator also sometimes closes between runs.
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics/`, `apps/numaya_mobile/assets/demo/photos/` (only its README is tracked), `build/`, the `docs/v9/screenshots/*.png` files, review folders and `.claude/launch.json`. They show private photos. **No private backup exists.**
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

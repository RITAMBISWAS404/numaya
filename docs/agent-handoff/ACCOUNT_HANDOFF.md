# Account handoff

> **2026-11-12, replacement V8 delivered (premium candidate). Read this first.**
> - **Branch:** `experiment/numaya-v8-premium-rebuild-20261112-1945`, from the selected V7 `b5e5245` (all 36 owner selections kept). App source `ee87648`.
> - **Brief:** `NUMAYA_V8_REPLACEMENT_PREMIUM.zip`. Records are in [docs/v8-replacement](../v8-replacement/DECISIONS.md).
> - **Superseded:** the earlier V8 and V9 are archived on `archive/superseded-v8-v9-20261112` and `archive/superseded-v8-20261112`; do not use them as the direction.
> - **Next:** the owner reviews the gallery and the phone folder, then exports choices. The quirky direction is deferred to a later branch. No new work until the owner replies.

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `experiment/numaya-v8-premium-rebuild-20261112-1945`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-v8-premium-rebuild-20261112-1945`.
- **Baseline:** the selected V7 `b5e5245` (tag `checkpoint/v7-selected-baseline-20261111`). The export `v7-71564be-2026-11-10` decisions are all kept.
- **App source:** `ee87648`. Later commits change only records.
- **Archived, superseded:** `archive/superseded-v8-v9-20261112` (`eb38d9f`) and `archive/superseded-v8-20261112` (`47ba247`). Local-only V9 outputs are in `C:\Users\biswa\OneDrive\Desktop\Numaya V8-V9 Superseded (local only)`.
- **Records:** [docs/v8-replacement](../v8-replacement/DECISIONS.md): DECISIONS, DESIGN_CONTRACT, REFERENCE_LOG, FONT_ASSET_INVENTORY, CONVERSATION_CONTRACT, SCREEN_LEDGER, REQUIREMENTS_REGISTER, IMPLEMENTATION_REPORT.
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Replacement-V8-20261112-ee87648.apk` (release mode, debug-key signed, 0.1.0+1, SHA-256 `021c74a57402ed89109ab1ddaf49af4343f12c8d67c278aa30aee4c8599a8394`).
- **Phone folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya Replacement V8 Screenshots\2026-11-12 ee87648` (206 PNGs, SCREEN_LIST.txt, CAPTURE_MANIFEST.md, SCREEN_INDEX.md, COVERAGE.md).
- **Gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya Replacement V8 Review\2026-11-12 ee87648\index.html`. Review ID `r8-ee87648-2026-11-12`. The `.claude/launch.json` entry `r8-gallery` serves it on port 8772 if a server is wanted.
- **Development controls:** off by default. Build with `--dart-define=NUMAYA_DEV_TOOLS=true` to switch comparisons in the Design Lab. The editorial type needs `--dart-define=NUMAYA_EDITORIAL_TYPE=true`.
- **Capture tooling:**
  - Use one emulator job at a time. A stopped bash script can leave its `capture_visual_lab.sh` child running, so check `ps -ef` before starting another.
  - The `cap` passes rebuild from the working tree, so do not edit `lib` while they run.
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics/`, `apps/numaya_mobile/assets/demo/photos/` (only its README is tracked), APKs, screenshot and review folders, `.claude/launch.json`. They show private photos. **No private backup exists.**
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

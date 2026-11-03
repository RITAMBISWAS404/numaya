# Work log

Newest first. One entry per session: date, who, what changed, commits, what was left.

## 2026-11-04: universal APK and system bars
- **Verified:**
  - `85f46d1` clean;
  - SDKs 24 / 36 / 36; both Android plugins declare `minSdk` 24;
  - no ABI filters or `<uses-feature>` entries.
- **System bars:**
  - edge to edge on all versions, with transparent bars and dark icons (`AppSystemUi`);
  - themes per API level (`values`, `-v26`, `-v27`, `-v29`), canvas window and splash background;
  - removed the black `values-night` themes;
  - replaced `SystemUiOverlayStyle.dark`, which made the navigation bar black.
- **Found on device:** under three-button navigation, the sheet bottoms sat under the system
  buttons. Fixed and covered by tests.
- **Built:** universal debug APK, copied to `C:\Users\biswa\Desktop\Numaya\Numaya-final-debug.apk` (checksums match).
- **Tested:** Pixel 10 emulator, API 36, gesture and three-button navigation.
- **Left:** physical-phone test (Samsung, Android 12).

## 2026-11-04: final UX polish (same account, Claude Code desktop)
- **Verified:**
  - branch `experiment/numaya-final-ux-polish` at `93d5ce7`, clean, tracking `origin`;
  - baseline `flutter test` on Windows: 266 passed, 11 skipped.
- **Implemented**, see `docs/design-experiments/numaya-final-ux-polish/`:
  - semantic `AccentTone` colours;
  - `IconTile` in `ListRow`;
  - inset list dividers;
  - Account Health status tiles;
  - Settings tiles on every row;
  - Discover swipe stamp, plus cancel, fling-back and double-decision fixes;
  - the single-photo Match;
  - `AppRadii.nested`, the concentric tab indicator and the RSVP bar corner;
  - four copy fixes;
  - named illustration slot ratios.
- **Tests:**
  - added `test/widget/final_polish_test.dart` (22);
  - added `/match/amara` to the route matrix;
  - fixed a 320pt / 200% overflow that the matrix caught.
- **Goldens:** all 187 regenerated after review. They are now Windows renders (FP-14).
- **Docs:** polish README, DECISIONS, VISUAL_REVIEW_REPORT and ILLUSTRATION_ASSET_BACKLOG.
  TOKENS, COMPONENT_RULES, LAYOUT_GUIDELINES, NAVIGATION_SPEC and `contrast_check.py` updated.
- **Built and smoke-tested:** debug APK on the Pixel 10 emulator. Real swipes work.
- **Left:**
  - owner review;
  - web checks blocked by CRLF and the missing Playwright browser;
  - physical-device pass.

## 2026-11-04: handoff setup (new Claude account, Claude Code desktop)
- **Verified:**
  - the repo, the remote and `gh` admin auth;
  - Mobbin MCP;
  - the 34 skills;
  - the toolchain (`flutter doctor -v`).
- **Branches:**
  - Created a local `experiment/numaya-monochrome-premium-refinement` tracking `origin`, at
    `e70135c`.
  - Created `experiment/numaya-final-ux-polish` from it.
  - Left `experiment/numaya-android12-compat` (`e5184e1`) unchanged.
- **Added:** `docs/agent-handoff/` (this folder), plus the handoff protocol in `CLAUDE.md`.
- **Android:** the SDK is healthy. adb isn't on `PATH`, and that is harmless. No system changes
  were made.
- **No product code changed.**
- **Left:** the owner to confirm the scope of the final UX polish ([ACTIVE_TASK.md](ACTIVE_TASK.md)).

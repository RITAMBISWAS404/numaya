# UI-087 to UI-102 review phase: implementation and QA report

2026-11-15. Worktree `C:\Users\biswa\Projects\Numaya-fable-lab`, branch `experiment/numaya-ui087-102-20261115-0309`.

| Item | Value |
| --- | --- |
| Baseline | `96c7872` (V8 review build, app source `fe44b27`); tag `checkpoint/pre-ui087-102-20261115-0309` (pushed) |
| App source for the APK and all after-evidence | `e3c50cd` |
| APK | `C:\Users\biswa\OneDrive\Desktop\Numaya UI-087-102 Review\2026-11-15 e3c50cd\apk\Numaya-UI087-102-Review-20261115-e3c50cd-debug.apk` |
| APK SHA-256 | `e851a6ffa7a088a9593fdf7bc0f360613b8116fed706fc2958749d38c28ec155` (248,399,925 bytes) |
| Build | `flutter build apk --debug --dart-define=NUMAYA_DEV_TOOLS=true`, Flutter 3.47.8; package `com.numaya.numaya_mobile` 0.1.0 (1); arm64, armv7, x86_64 |
| Screenshots | same folder, `screenshots\` (153 PNGs, `INDEX.csv`) |

Scope: [ACTIVE_SCOPE.md](ACTIVE_SCOPE.md). Criterion tracker: [IMPLEMENTATION_TRACKER.csv](IMPLEMENTATION_TRACKER.csv).
Dev Mode: [DEV_MODE.md](DEV_MODE.md). Type, colour and icon catalog: [TYPOGRAPHY_CATALOG.md](TYPOGRAPHY_CATALOG.md).
What was inspected: [REFERENCE_LOG.md](REFERENCE_LOG.md).

## Status by issue

| Status | Issues |
| --- | --- |
| Implemented and verified | UI-010, UI-026, UI-033, UI-060, UI-067, UI-068, UI-072, UI-073, UI-085, UI-086, UI-087, UI-088, UI-089, UI-090, UI-092, UI-093, UI-095, UI-096, UI-097, UI-098, UI-101, UI-102 |
| Implemented, verification partial | UI-049 (person photo card only), UI-070 (voice playing state not rendered), UI-091 (Compliments verified; Chat photo reply not rendered), UI-094 (four supplied states verified; five comparable screens not migrated) |
| Implemented in part, audit outstanding | UI-012 (roles and colours done; no per-screen override sweep), UI-074 (catalog published; gradient, spacing and whole-app passes not run) |
| Blocked | UI-099 (no updated PRD), UI-100 (no approved ranking or visibility rules) |
| Decisions blocked | UI-095 contrast of white on the two new seeds; UI-096 third shape; UI-026 Figma values (connector not authorised); production font, body size, palette, shape, surface and status-surface choices |

## What changed (by batch)

1. **Foundations.** Three text-colour roles: primary #000, secondary #4D4D4D, tertiary #666 for metadata. Metadata (`caption`, `micro`) moves to tertiary. A category icon rule: menu and list rows and Premium benefits are outline; compact preview and media glyphs are filled. Photo overlays use the 16pt card padding, and the photo corner follows the nested rule (12 + 16 = 28).
2. **Components.**
   - Capsule identity and information pills (`AppRadii.infoPill`).
   - Birthday placeholders with hidden labels that keep their accessible names.
   - `SliderBlock`: 8pt above and below every 48pt slider control.
   - One white informational card (`InfoCardLayout`) with the icon on the heading's first line.
   - A larger capsule tab bar (44×60 tiles, same 24pt glyphs, 12pt above the safe area).
   - A centred status template (`EmptyState` with actions and links, plus `StatusLayout`) on the purchase outcomes, chat-ended, contact-sent and already-Premium screens; the white-card option is in the Design Lab.
   - A continuous header progress track.
   - No scroll stroke under top bars.
3. **Dev Mode.**
   - One `TypeSettings` model and one `DevModeStyles.apply` for: four fixed font pairs, the existing 14/15 body size, three brand options, two button shapes, two secondary surfaces, and Reset all.
   - Fonts are bundled offline under the OFL. The old independent font selectors and the `r8-secondary-button` lab group are retired, so there is one control per setting.
   - Settings → Prototype tools now links to Dev Mode.
4. **Messages.**
   - New matches are circular photos at the 56pt conversation-avatar size, in a deadline ring that refreshes each minute.
   - Unread is an avatar dot; "Your move" sits at the trailing edge, and under the preview at large text.
   - Media glyphs are filled. The new-match countdown is one inline line under the name.
   - Composer:
     - The field and reply preview use the page token.
     - The reply thumbnail fills the panel, and Dismiss sits outside it.
     - Credits sit at the leading edge, the counter at the trailing edge.
     - Send is brand-filled and centred on the field.
5. **Onboarding.** Only UI-101's track; the UI-099 split is blocked.
6. **Discovery.** UI-100 is blocked; nothing was changed.

## QA (separate pass after implementation)

- **Static analysis:** `flutter analyze` reports 2 infos, both present at baseline (a deprecated test matcher and an `if` without braces in a test file).
- **Tests:** `flutter test` 693 passed, 47 skipped, 0 failed (baseline: 674 passed, 45 skipped).
  - 12 new phase tests (`test/widget/ui087_102_test.dart`) and 10 Dev Mode tests (`type_settings_test.dart`, `v8_review_test.dart`).
  - 14 older tests asserted superseded designs: square match tiles, grey callouts, centred alert icons, the 38×48 nav, the 20/12 corners, two text greys, and the neutral composer fill. Each was updated to the newer documented decision, with the reason in the test. None was a functional regression.
- **Equivalent before/after renders:** the real app widget tree with the full demo world and the local demo photos, at 393×852 @3x (1179×2556), on the same scenes and data.
  - The before set was rendered from a throwaway checkout of the checkpoint, now removed.
  - The after set: 37 scenes, 42 Dev Mode renders (every preset), and all 37 scenes again at 320pt with 200% text. All 116 after renders pass with no layout overflow.
- **Defects found and fixed in QA:**
  - DEF-01: a full-resolution photo overflowed the reply preview.
  - DEF-02: the "Your move" pill squeezed names at 200% text.
- **Not run:**
  - On-device and emulator checks: no emulator was attached, and the user's last instruction was not to start one. That covers keyboard behaviour, relaunch persistence of Dev Mode and slider drag on a device.
  - Integration tests (`integration_test/`), which need a device.
  - iOS.
  - The repo's web `npm run check` and `test:e2e`: no web files changed.

## Demo versus real backend

Unchanged. The APK runs the on-device demo world ("Explore the demo" on Welcome; the phone sign-in reaches the demo code screen). Purchases are demo outcomes; no store, OTP, Supabase or push is connected. Dev Mode settings are stored only on the phone. Reset never touches account, profile, chats, credits or Design Lab choices.

## Private material

The screenshots and APK contain the private demo photos and stay outside Git (`test/screenshots/ui087/` is git-ignored). Only code, fonts (OFL) and records are committed.

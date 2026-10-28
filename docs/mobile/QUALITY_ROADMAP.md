# Quality roadmap: motion, polish and coverage

Working record for the quality pass on the Flutter app (`apps/numaya_mobile/`). Update it after every batch.
On a restart, check the actual Git state first (`git log --oneline -5`, `git status`), then continue from
**Next task**.

| | |
|---|---|
| Branch | `experiment/numaya-quality-motion` (from `experiment/numaya-flutter-full-app` @ `84481d5`) |
| Baseline checks (before any change) | format clean (104 files) · `flutter analyze` no issues · `flutter test` **115 passed, 2 skipped** |
| Android | SDK download still refused: `curl https://dl.google.com/android/repository/repository2-3.xml` → `CONNECT tunnel failed, response 403`. No `adb`, no emulator, no APK. Nothing in this pass was run on a device |
| Web prototype | Not touched (no edits outside `apps/numaya_mobile/`, `docs/mobile/` and `.claude/skills/`) |

## Phases

| Phase | Status | Output |
|---|---|---|
| 0 Baseline | Done | Checks above; branch created; tree was clean |
| 1 Skills | Done | 24 skills in `.claude/skills/` (see below) |
| 2 Backlog | Done | [MOTION_DESIGN_AUDIT.md](MOTION_DESIGN_AUDIT.md), [UI_POLISH_BACKLOG.md](UI_POLISH_BACKLOG.md); quality matrix in [FULL_APP_SCREEN_INVENTORY.md](FULL_APP_SCREEN_INVENTORY.md) (batch 5) |
| 3 Motion system | See batch log | `AppMotion` roles, `AppHaptics`, transitions |
| 4 Shared components | See batch log | |
| 5 Batches A–H | See batch log | |
| 7 QA | See batch log | [UI_POLISH_QA.md](UI_POLISH_QA.md), [MOTION_QA_REPORT.md](MOTION_QA_REPORT.md) |
| 9 Android | Blocked | Network policy denies `dl.google.com` |

## Skills

Installed with `npx skills@latest add … -a claude-code -y` into `.claude/skills/` (recorded in `skills-lock.json`):

- **Emil Kowalski (8):** emil-design-eng, animate, find-animation-opportunities, improve-animations,
  review-animations, animation-performance, animation-vocabulary, break-ui.
- **zakariaf/Flutter-Skills (16):** flutter-conventions-index, state-management-riverpod, widget-composition,
  navigation-and-routing, forms-and-input, ui-states-and-feedback, motion-and-haptics, flutter-performance,
  accessibility-as-code, widget-golden-and-a11y-testing, testing-strategy, adaptive-layout,
  design-system-structure, dependency-hygiene, async-safety, design-review-workflow.

The CLI installed 14 of the 16 Flutter skills. It skipped `async-safety` and `design-review-workflow`
because their front matter does not parse as YAML upstream (an unquoted `: ` in `description`). They were
copied from a clone of `github.com/zakariaf/Flutter-Skills` and their `description` line was quoted; the
body is unchanged. They are not in `skills-lock.json`.

How they were applied: the Emil skills set the gate (should it animate, how often is it seen), the curves
and the durations. Their CSS and Motion code was not copied. The Flutter skills set the implementation
(`motion-and-haptics` moment catalogue and haptic map, `design-system-structure` reduced-motion collapse,
`navigation-and-routing` transitions, `async-safety` mounted checks). Where they conflict with V16 (for
example a `ThemeExtension` for every token, or a dark theme), V16 and the existing architecture win.

## Batch log

| Batch | What changed | Tests | Commit |
|---|---|---|---|
| 0 | Skills installed; roadmap and motion audit | baseline only | with batch 1 |
| 1 Motion foundation | `AppMotion` roles (press, state, exit, sheetIn/Out, reject, progress, celebrate, stagger, caretBlink) and `AppMotion.sheet()`; `AppHaptics` with one gate (`HapticsScope`, Settings → App → *Vibration*); selection haptics on switches, chips, options, plan cards and view tabs; reject haptic on a wrong code. **Found and fixed:** the app had no page transitions at all, because go_router 18 looks for `material_ui`'s `MaterialApp` and fell back to zero-duration pages. Every route now builds a `MaterialPage` with a token-driven slide on Android; the match, paywall, Premium and verification rise in as modals. Sheets use the drawer curve. The caret and toast dots stop under reduced motion. Demo Hub → *Reduce motion* switch | `motion_test.dart` (6 new). Existing tests: tap helpers now pump one frame before waiting, because a transition starts on the frame after the tap (no assertion changed). 121 passed, 2 skipped; captures 4 passed; `02`, `05` (caret phase), `f25` (spinner phase) and `d113` (new App group) re-captured | see git log |
| 2 Discovery and match (C, D) | Decisions no longer swap the profile in the same frame: the profile leaves right (like), left (pass) or up (SuperSwipe) over 200 ms, then the next settles in (220 ms); one commit haptic; taps during the exit are ignored; the paywall check happens before any motion. The swipe card leaves from where the finger let go instead of snapping back first, a firm flick (≥ 800 pt/s, ≥ 24 pt) decides short of the line, and crossing the line ticks. The match screen has a one-time staged entrance (title, portrait from 92%, text) over 560 ms with one success haptic; any touch finishes it; under reduced motion it appears complete | 5 new in `motion_test.dart`; 126 passed, 2 skipped | see git log |
| 3 Messaging, profile, payments (E, F, G) | **Found and fixed:** a chat opened at its *oldest* message (the list scrolled from the top), and on send the list jumped before the new bubble was laid out, stopping short of it. The chat list is now anchored to the newest message (`reverse`), so it opens at the latest and stays there when the keyboard opens; sending brings it back only if the person had scrolled up, after layout, on the `state` role (instant under reduced motion). A sent bubble rises 8 pt and fades in; one commit haptic per send. The completion ring's arc fills from its old value. Success haptic on a simulated purchase and on a verified photo; a light reject haptic on a declined payment or rejected photo | 1 new chat test (375 × 667 at 130% text); 127 passed, 2 skipped | see git log |
| 4 Worst case and large text (Phase 7) | Worst-case member data and 200% text through the real screens found 9 layout breaks: `ListRow` values overflowing by up to 302 pt, Welcome overflowing at 200% text, badges and the distance line on profile cards, and the preview card's name band squeezing the photo. All fixed (UI_POLISH_BACKLOG U-05–U-09). Tappable list rows now read their value and detail to screen readers. Three regressions from the first fixes were caught in the capture comparison and corrected before commit | `break_ui_test.dart` (3 sizes × scales); worst-case captures `w01`–`w06`; 130 passed, 3 skipped; captures 5 passed | see git log |
| 5 Shell, inventory, motion QA (A, H) | Android back on Likes, Messages or Profile now returns to Home instead of leaving the app; a pushed page still closes first. Country picks tick. Quality matrix added to the screen inventory (motion, A11y, tests, device per route). B-31 re-checked and kept deferred with its reason. Idle check: settled screens schedule no frames. [MOTION_QA_REPORT.md](MOTION_QA_REPORT.md), [UI_POLISH_QA.md](UI_POLISH_QA.md), `screenshots/worst-case.png` | 2 new (back navigation, idle); 132 passed, 3 skipped | see git log |
| 7 Complete onboarding | Branch `experiment/numaya-onboarding-complete` (from `experiment/numaya-android12-compat` @ `e5184e1`). Mobbin research on Bumble, Hinge and happn; 13 setup steps in four sections, review, All set, under-18 lock, permission stand-ins, Demo Hub rows for every step. See [ONBOARDING_IMPLEMENTATION_REPORT.md](ONBOARDING_IMPLEMENTATION_REPORT.md) | 152 passed, 4 skipped; captures 6 passed (`o01`–`o39`) | see git log |
| 8 Complete Discovery | Branch `experiment/numaya-discovery-complete` (from `experiment/numaya-onboarding-complete` @ `e4f0f5f`). Mobbin research on Bumble, Hinge and happn; photo viewer, floating actions and progress while reading, first-visit tip, undo to the front, show-again keeps likes, filters reset to sign-up preferences, end-of-profile report link, toasts under the header. See [DISCOVERY_QA_REPORT.md](DISCOVERY_QA_REPORT.md) | 167 passed, 5 skipped; captures 7 passed (`x01`–`x12`) | see git log |
| 6 Docs and final checks | Windows guide (this branch, "Motion and feel" things to try), README, project structure, implementation report | format clean · analyze clean · tokens OK · `flutter test` 132 passed, 3 skipped · captures 5 passed · `npm run check` passes · `npm run test:e2e` 143/144: the failing check ("no squircle or superellipse corner-shape anywhere", 2275 elements) is in the web prototype, whose files are identical to `84481d5`, so it is not from this pass | see git log |

## Next task

Nothing high-value is left that can be done safely without a device or a product decision:

1. **Needs a phone or emulator:** run on a device and check the open items O-04 and O-05 in
   [UI_POLISH_BACKLOG.md](UI_POLISH_BACKLOG.md): haptic strength, gesture velocity, the spring on release,
   TalkBack during transitions, keyboard insets and frame timing in profile mode.
2. **Onboarding on a device:** permission dialogs, camera and photo picker (needs plugins), keyboard insets on the date fields, TalkBack through the 13 steps.
3. **Web e2e:** the corner-shape check fails on the unchanged web prototype; it belongs to the web project.

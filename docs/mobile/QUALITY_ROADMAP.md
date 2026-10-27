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
| 2 Backlog | Done | [MOTION_DESIGN_AUDIT.md](MOTION_DESIGN_AUDIT.md), [UI_POLISH_BACKLOG.md](UI_POLISH_BACKLOG.md), quality matrix in [FULL_APP_SCREEN_INVENTORY.md](FULL_APP_SCREEN_INVENTORY.md) |
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

## Next task

Batch 1: the motion foundation (`AppMotion` roles, `AppHaptics`, page and sheet transitions, reduced-motion
switch in the Demo Hub) and its tests.

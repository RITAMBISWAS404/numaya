# QA report: Monochrome Meetup

**Run:** 2026-11-03, in a cloud Linux container.
- **SDK:** Flutter 3.47.8 stable and Dart 3.13.7, as documented in `docs/mobile/TECH_STACK.md`,
  installed from `storage.googleapis.com`.
- **Working directory:** `apps/numaya_mobile/`.

## Automated results (final state of the branch)
| Check | Command | Result |
|---|---|---|
| Formatting | `dart format --set-exit-if-changed lib test` | clean (exit 0) |
| Static analysis | `flutter analyze` | **No issues found** |
| Token generator up to date | `node tool/generate_tokens.mjs --check` | "Dart tokens are up to date" |
| Unit and widget tests | `flutter test` | **254 passed, 11 skipped** (the 11 are the opt-in screenshot captures), 0 failed |
| Screenshot captures | `flutter test --tags screenshots --run-skipped --update-goldens test/screenshots` | **17 passed**; 187 goldens written (186 existing screens plus the new `m01-design-lab`) |
| Baseline, before any change (`61de076`) | `flutter analyze`; `flutter test` | no issues; 249 passed, 10 skipped |

### Test changes, all deliberate
**Rewritten**
- `test/unit/foundation_test.dart`: the "V16 design tokens" group is replaced by "Monochrome Meetup
  design tokens".
  - It pins the canonical purple, the neutral (non-warm) page, the type and the geometry.
  - It asserts AA contrast for ink, secondary, muted and purple text on **every surface** (white,
    canvas, fill, brand subtle).
  - It asserts 3:1 for control boundaries.
  - It asserts that white text on the photo panel stays above 4.5:1 over a white photo.
  - This is stricter than the group it replaces: it covers more pairs.

**Updated**
- Four widget tests (`events`, `discovery`, `visibility`, `v16_screens`) now find modal titles in
  sentence case ("Edit event", "Maya’s photos", "Profile & visibility", "Your prompt") rather than
  the old upper case, matching what the screens now render. The behaviour checked is unchanged.

**Added**
- `test/widget/design_lab_test.dart`:
  - the Design Lab opens from the Demo Hub;
  - illustration slots are excluded from semantics;
  - **the route is refused when demo sign-in is unavailable**, as in release;
  - the slot keeps its aspect ratio.
- `test/screenshots/capture_monochrome_test.dart` captures the whole Design Lab.

**Not weakened:** no test was deleted or skipped. Goldens were regenerated only after reviewing every
family (DESIGN_REVIEW_REPORT.md). The baseline goldens remain on `experiment/numaya-overnight-completion`.

## Journeys covered by the suite (unchanged tests, all passing)
- **Onboarding to Discovery:** sign-up through every step, including large text and a small phone.
- **Discovery to match to conversation:** like, match, first message, Messages, Likes, Like back.
- **Profile:** editing, then preview; Opening Moves; photo picking.
- **Events:** explore, RSVP, waitlist, leave; host create (errors first, then publish), edit, draft,
  cancel, manage attendees.
- **Account Health:** visibility states (visible, paused, restricted, can't check); completeness
  recalculating after an edit; a suggestion opening the editor.
- **Settings and safety:** snooze, notifications, privacy, report and block, delete account, recovery
  email, sign-in again.
- **Accessibility:** tap-target guidelines (Android 48dp, labelled targets) on onboarding, dating and
  full-app routes; layout without overflow at 375 × 667 with 130% text; sign-up at 200% text and on a
  small phone at 150% (`accessibility_test.dart`, worst-case tests).

## Accessibility and contrast
**Text contrast:** every text role meets 4.5:1 on every surface it is used on. The table is in
[TOKENS.md](TOKENS.md#contrast-computed-wcag-2x-relative-luminance), and unit tests enforce it.

**Purple as text:** brand purple `#7262C7` is 4.46:1 on the grey page. So purple text, links and
icons use `#5B4BB0` (≥ 5.79:1), and `#7262C7` is used only as a fill under white text (4.90:1).

**Boundaries:**
- Field outlines and unselected radio and checkbox rings are `#8B8B94`: 3.38:1 on white, 3.07:1 on
  the page.
- The switch's off state keeps a 1.5pt outline and a grey thumb, so it reads as a control without
  colour.

**Targets:** every `Pressable` enforces a 44pt minimum hit area. Icon buttons are 42pt visible, inside
44.

**Reduced motion:** all motion runs through `AppMotion.duration`, which is unchanged; new components
add no motion types.

**Semantics:**
- Illustration slots are decorative.
- Metric tiles read as one sentence ("Profile views, Not measured").
- The tab bar keeps selected state and badge labels.

### Flutter's pixel-sampling contrast guideline
`textContrastGuideline` was tried over the full-app routes, as an extra test. It failed on **both** the
baseline and this branch, on text whose colours compute far above the threshold:

| Run | Text | Reported ratio | Computed ratio |
|---|---|---|---|
| Baseline | 11pt tab label "Home" | 1.80:1 | above the threshold |
| This branch | 13pt Demo Hub caption | 1.12:1 | 7.98:1 (`#4A4A53` on `#F4F4F6`) |

It samples rendered pixels and misreads anti-aliased glyphs in this headless harness, so it was not
kept as a gate. Contrast is enforced on the token pairs instead.

## Known defects and limits
- **Very long names at 200% text:** a single 11-letter word in a name cannot fit the photo card on a
  375pt phone and breaks inside the word. The baseline did the same, one letter later. Improved
  (panel tightened, 32pt name) but not eliminated without capping text size, which was rejected.
- **Discover over grey placeholders:** the dark photo panel reads heavy against a grey placeholder.
  With real photos it reads as intended. The demo has no person photography.
- **Account Health** remains long and row-heavy (rubric 3 for hierarchy); proposals are in
  DESIGN_REVIEW_REPORT.md.
- **Web prototype not themed:** the web prototype intentionally keeps its own tokens.
- **Not run on a device or emulator:** this environment has no Android SDK (`flutter doctor`: "Unable
  to locate Android SDK"), and no APK was built. Everything above is from the Flutter test renderer.
  Physical-device performance, real font hinting and system-bar behaviour are **not verified**.

## Build and install the experimental APK (on a machine with the Android SDK)
```sh
git fetch origin
git switch experiment/numaya-monochrome-meetup
cd apps/numaya_mobile
flutter pub get
flutter build apk --debug          # build/app/outputs/flutter-apk/app-debug.apk (arm, arm64, x86_64)
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```
**Opening the Design Lab:** in a debug build, open the Demo Hub (Welcome › Demo build, or Settings ›
Prototype tools), then Design › Design Lab.

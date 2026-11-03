# Visual QA report: premium refinement

**Run:** 2026-11-03, in a cloud Linux container, with Flutter 3.47.8 and Dart 3.13.7. Working
directory: `apps/numaya_mobile/`.

## Automated results (final state of the branch)
| Check | Command | Result |
|---|---|---|
| Formatting | `dart format --set-exit-if-changed lib test` | clean (exit 0) |
| Static analysis | `flutter analyze` | **No issues found** |
| Token mirror | `node tool/generate_tokens.mjs --check` | "Dart tokens are up to date" |
| Unit and widget tests | `flutter test` | **266 passed, 11 skipped** (the opt-in screenshot captures), 0 failed |
| Screenshot captures | `flutter test --tags screenshots --run-skipped --update-goldens test/screenshots` | **17 passed**; 187 goldens regenerated after review |
| Base for comparison (`0003d17`) | `flutter test` | 254 passed, 11 skipped |

**Web checks (`CLAUDE.md`):** this branch changes **no file outside `apps/numaya_mobile/` and this
folder** (`git diff --stat 0003d17 -- . ':!apps/numaya_mobile' ':!docs/design-experiments/monochrome-meetup-premium'`
is empty).

`npm run check` was run with the only available `node_modules`, borrowed from another branch's
checkout:
- **Its unit tests passed** (8 files, 122 tests).
- **Its Vite build failed:** `@fontsource-variable/hanken-grotesk` is not installed in that
  `node_modules`. That package belongs to this branch's (unchanged) web code; the failure is an
  environment mismatch.
- `npm run test:e2e` was **not run**, for the same reason (no matching install and no browser
  build).

## Test changes, all deliberate
**Added:** `test/widget/size_matrix_test.dart` (12 tests). It runs every full-app route (34,
shared with `accessibility_test.dart`) at each of these widths and text sizes. Any layout exception
fails the test.

| Width | Height |
|---|---|
| 320pt | 568 |
| 375pt | 667 |
| 390pt | 844 |
| 430pt | 932 |

Text sizes: 100%, 130% and 200%.

**Strengthened:** `test/unit/foundation_test.dart`.
- **Font roles:** it asserts Jakarta for headings and Figtree for body.
- **Geometry:** the new radii and sizes, `tabItem` ≥ 48 and `iconButton` ≥ 44.
- **Contrast:** muted and ink text on the field fill; the purple icon on the tint ≥ 3:1; state
  colours on their tints ≥ 4.5:1.

**Updated to match new behaviour** (the behaviour checked is the same):
- Tabs are found by tooltip, because icon-only tabs have no visible text:
  - `journeys.dart` (`openTab`);
  - `capture_screens_test`;
  - `onboarding_flow_test`;
  - `v16_screens_test`.
- `signUpToSetup` unfocuses the field before Next: at 320pt and 150% text the text-selection handle
  covered the button.
- `profile_photos_test` reads the avatar size from `AppSizes.avatarProfile` instead of a literal 176.

**Not weakened:** no test was deleted, skipped or loosened.

## Adversarial size and text matrix
| Width | 100% | 130% | 200% |
|---|---|---|---|
| 320pt | pass | pass | pass (failed before the fixes below) |
| 375pt | pass | pass | pass |
| 390pt | pass | pass | pass |
| 430pt | pass | pass | pass |

**The 320pt / 200% failure on `/paywall`** was a 15px RenderFlex overflow. It was traced to three
shared-component defects, all fixed:
1. The `IllustrationSlot` caption outgrew its fixed-ratio box. It now scales down inside the box.
2. The pinned footer (button plus legal text) took most of the 568pt height. On short screens with
   text above 160%, it now scrolls with the content.
3. The top-bar title ran under the close button. It is now padded clear of the side buttons.

**Also from visual review** (rendered, not exception-based): at 200% the Discover name
"Maximiliana-Josephine" broke inside a word. It now steps down to 24pt, wraps at the hyphen, and
keeps the job icon on its first line.

## Accessibility
- **Contrast:** every rendered text pair is ≥ 4.5:1 and every non-text mark ≥ 3:1. The
  machine-generated table is in [TOKENS.md](TOKENS.md#contrast-computed-wcag-2x-relative-luminance)
  (`evidence/contrast_check.py`), and unit tests enforce it.
  - **Exception:** filled fields against the page, by design (decision PR-07).
- **Targets:** `androidTapTargetGuideline` (48dp) and `labeledTapTargetGuideline` pass on the
  onboarding, dating and 34 full-app routes.
- **Tab pill:** each item has a tooltip, button and selected semantics, and a badge label.
- **Reduced motion:** all new motion uses `AppMotion`, which is zero under `disableAnimations`.
- **Haptics:** unchanged and gated.
- **Text scaling:** never capped. The two step-downs (the Discover name; footer placement) keep
  text growing.

## Known defects and limits
- **No demo photography.** Discover, Likes and event covers show grey placeholders with a glyph.
  The image-first card is designed for real photos.
- **Jakarta punctuation.** The comma and apostrophe sit loose ("Bo, 22", "Let’s"). This is a
  property of the face.
- **Account Health below the hero** is still a parts list. It is clearer than before, but not yet
  visual.
- **Top-bar titles at 200% text** are truncated with an ellipsis on 320pt screens. The page heading
  below repeats the full text.
- **Filled-field boundary** is below 3:1 (PR-07). Revisit if user testing shows fields are missed.
- **Not run on a device or emulator.** This environment has no Android SDK (`flutter doctor`:
  "Unable to locate Android SDK"), and **no APK was built**. Everything above is from the Flutter
  test renderer. Physical-device font hinting, the tab pill above the Android gesture bar, haptics
  and performance are **not verified**.

## Build and install the experimental APK (on a machine with the Android SDK)
```sh
git fetch origin
git switch experiment/numaya-monochrome-premium-refinement
cd apps/numaya_mobile
flutter pub get
flutter build apk --debug    # build/app/outputs/flutter-apk/app-debug.apk
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

**Opening the Design Lab:** in a debug build, open the Demo Hub (Welcome › Demo build, or Settings ›
Prototype tools), then Design › Design Lab. It shows the navigation variants.

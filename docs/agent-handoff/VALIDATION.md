# Validation

## Required before each commit
**Flutter** (in `apps/numaya_mobile/`):
```sh
dart format --set-exit-if-changed lib test
flutter analyze
node tool/generate_tokens.mjs --check
flutter test
```
Screenshot goldens, after review only:
```sh
flutter test --tags screenshots --run-skipped --update-goldens test/screenshots
```

**Web** (repository root, from `CLAUDE.md`):
```sh
npm ci                          # installed on 2026-11-04
npm run check                   # see the CRLF note below
npx playwright install chromium # once, before e2e
npm run test:e2e
```
**CRLF note:** this checkout has `core.autocrlf=true`, so the generated web files are checked out
with CRLF. `tokens:check`, `icons:check` and `tests/unit/tokens.test.js` compare them against LF
output and fail even though nothing changed. Run the web checks in a checkout with
`core.autocrlf input` (or in CI or WSL) for a true result.

**On a device** (owner's machine), when UI changes:
```sh
flutter build apk --debug
# Only the Pixel_10 AVD has an installed system image (Pixel_8/9 point at a missing android-36 image).
"$LOCALAPPDATA/Android/sdk/emulator/emulator.exe" -avd Pixel_10 -no-snapshot -gpu swiftshader_indirect
"$LOCALAPPDATA/Android/sdk/platform-tools/adb.exe" install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Frosted-navigation experiment (2026-11-04, worktree `..\numaya-frosted-navigation`, uncommitted)
| Stage | Command / check | Result |
|---|---|---|
| A (`eb0b37b`) | `flutter analyze`; `flutter test` | No issues; 292 passed, 11 skipped |
| B | `flutter test` (full) | 292 passed, 11 skipped (before B's own tests were added) |
| B+C | `flutter test test/widget/frosted_navigation_experiment_test.dart` | 10 passed |
| B+C | `dart format --output=none --set-exit-if-changed lib test` | 0 changed |
| B+C | `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| B+C | `flutter analyze` | No issues found (2 lint infos in the new test, fixed) |
| B+C | `flutter test` (full, includes the 4-width × 3-text-size matrix and tap-target guidelines on every route) | **302 passed, 12 skipped, 0 failed** |
| B+C | screenshot captures `--update-goldens` | 18 passed. 51 goldens changed (tab-root screens show the new bar; chip screens), plus 1 new (`fn01`). Spot-checked against HEAD |
| C | `flutter build apk --debug` | built; SHA-256 `6b3250d6de6829c2ab4c0728c32145550807111c97daca9ace653859ca9e4f6c` |
| C | Rendered glass contrast (pixels from `fn01`) | idle icon ≥ 5.46:1 (black), 6.39 (busy), 6.78 (purple), 8.77 (white); selected 6.00 |
| C | Emulator: Pixel 10, API 36, 390dp and 320dp, gesture navigation | the journey ran, no crash |
| C | Emulator: font scale 2.0 | Discover, the profile scroll and Profile lay out; chips wrap; the wordmark falls back to the mark |
| C | Emulator: three-button navigation | First run: content behind the system buttons, so a strip was added. Re-check: buttons on the strip; Filters Reset clears them |
| C | Keyboard over tab screens on device | **not verified** (the search field scrolled off-screen) |
| — | TalkBack / VoiceOver | **not verified**. Semantics checked by widget tests (selected and button flags, labels) |
| — | iOS | **not tested** (Windows host) |
| — | Physical-device performance | **not verified** (emulator software GPU) |

**What is in git vs local (handoff, branch `wip/frosted-navigation-handoff`):**
- **In git:**
  - all source and test changes;
  - the 52 goldens;
  - the report and these handoff files.
- **Local only**, in `C:\Users\biswa\Downloads\numaya\numaya-frosted-navigation\artifacts\frosted-navigation-experiment\`
  (about 13 MB, left out as bulky evidence):
  - device screenshots `A-baseline/`, `B-refined/`, `C-frosted/`;
  - `comparisons/`;
  - `patches/`.
- **Local only:** the APKs (scratchpad).
- **Rendered-glass measurements** are reproducible from the committed golden
  `fn01-glass-backgrounds.png`.

**Re-check after checkout (another machine):**
```sh
flutter pub get
flutter analyze
flutter test   # expected: 302 passed, 12 skipped
```
Goldens were rendered on Windows; on Linux or macOS they will differ by font rasterising.

## Last results
| Date | Branch @ commit | Check | Result |
|---|---|---|---|
| 2026-11-03 | premium-refinement @ `e70135c` | `flutter test` | 266 passed, 11 skipped, 0 failed (cloud Linux) |
| 2026-11-03 | premium-refinement @ `e70135c` | `flutter analyze` | No issues (cloud Linux) |
| 2026-11-03 | premium-refinement @ `e70135c` | size matrix, 4 widths × 3 text sizes | all pass |
| 2026-11-03 | premium-refinement @ `e70135c` | `npm run test:e2e` | not run |
| 2026-11-04 | final-ux-polish (setup) | `flutter doctor -v` | Android toolchain ✓, Chrome ✓; Visual Studio ✗ (not needed) |
| 2026-11-04 | final-ux-polish (setup) | Flutter and web suites | not run: docs-only change |
| 2026-11-04 | final-ux-polish @ `93d5ce7` (before work) | `flutter test` (Windows) | 266 passed, 11 skipped, 0 failed |
| 2026-11-04 | final-ux-polish (polish commit) | `dart format --set-exit-if-changed` | clean |
| 2026-11-04 | final-ux-polish (polish commit) | `flutter analyze` | No issues found |
| 2026-11-04 | final-ux-polish (polish commit) | `node tool/generate_tokens.mjs --check` | up to date |
| 2026-11-04 | final-ux-polish (polish commit) | `flutter test` | **288 passed, 11 skipped, 0 failed** (+22 in `final_polish_test.dart`) |
| 2026-11-04 | final-ux-polish (polish commit) | screenshot captures `--update-goldens` | 17 passed; 187 goldens regenerated after review (now Windows renders) |
| 2026-11-04 | final-ux-polish (polish commit) | `flutter build apk --debug` | built |
| 2026-11-04 | final-ux-polish (polish commit) | Emulator smoke, Pixel 10 API 36.1 | launch, quick start, Discover, real left and right swipes: pass |
| 2026-11-04 | final-ux-polish (polish commit) | `npm test` (web, untouched) | 121 passed, 1 failed (CRLF artefact, see note) |
| 2026-11-04 | final-ux-polish (polish commit) | `vite build` | built |
| 2026-11-04 | final-ux-polish (polish commit) | `npm run check` / `npm run test:e2e` | check fails on the CRLF artefact; e2e not run (no Playwright browser) |

| 2026-11-04 | final-ux-polish (system bars) | `flutter analyze` / format / tokens | clean / 0 changed / up to date |
| 2026-11-04 | final-ux-polish (system bars) | `flutter test` | **292 passed, 11 skipped, 0 failed** (+4: system-bar style, root region, two sheet-inset tests) |
| 2026-11-04 | final-ux-polish (system bars) | `flutter build apk --debug` | universal APK: arm64-v8a, armeabi-v7a, x86_64; min 24, target 36, compile 36; v2 signature verifies; 220,344,688 bytes; SHA-256 `2eb261386d8d8c7405e9850d73b1ade26e5727515af611713300eff2342b43ee` |
| 2026-11-04 | final-ux-polish (system bars) | Pixel 10 emulator, API 36, gesture and three-button | install, launch, Demo Hub, quick start, swipes, all tabs, Settings, Account Health, sheets, keyboard: pass after the sheet-inset fix |
| 2026-11-04 | final-ux-polish (system bars) | Physical phones, API ≤ 35 | **not tested**: no device connected, no older system image installed |

**APK on the Desktop:** `C:\Users\biswa\Desktop\Numaya\Numaya-final-debug.apk` (same SHA-256 as the build). This PC's visible Desktop is
OneDrive-redirected (`C:\Users\biswa\OneDrive\Desktop`), so that folder is not shown on the desktop itself.

The app has run on an emulator (Pixel 10, Android 16). It has **not** run on a physical phone or on
Android ≤ 15.

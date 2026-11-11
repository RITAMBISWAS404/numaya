# Validation

> **V9 (`fb9e5cb`):** `flutter analyze`: one older deprecation info in a test. `flutter test`: 639 passed, 42 skipped (the same skips as V8), 0 failed, with no skips added. Five tests encoded replaced decisions (the fixed scrim widget, the Profile Settings row, the hub prompt card, the bar's Help button, the arrow disc) and were updated; one new test covers the adaptive scrim range. Emulator (Pixel 10 AVD): 210 captures in the full harness, 0 skipped; 19 key screens each at font 1.5, font 2.0 and 360 dp, 0 skipped. Release-mode APK built (signed with the debug key; no release keystore exists), installed with `-r`, and launched to Welcome with no crash in logcat. The deeper journeys were exercised on the debug build by the harness, not by hand on the release build. Not run: `npm run check` and the web e2e (no web change), physical phone, iOS, screen reader.


> **V8 (`45eadc1`, router import order fixed later):** `flutter test` 638 passed, 42 skipped, 0 failed, with no skips added. 24 tests encoded replaced decisions (fonts, radii, grey buttons, row cards without hairlines, hidden message times, the Compliments tab) and were updated to the V8 behaviour. Analyzer: one older deprecation info. New tests cover the Compliment conversation (reply opens the chat in place) and the Not now confirmation. Emulator: 208 captures plus 2 re-shot states (the conversation menu and Not now sheet, harness fixed), 19 key screens each at font 1.5, font 2.0 and 360 dp, all 0 skipped. APK installed with `-r` and launched. Not run: web checks (no web change), physical phone, screen reader.


> **V7 selected candidate (`014ac35`):** `flutter test` 638 passed, 42 skipped (no new skips), 0 failed; analyzer has only the older deprecation info. `selected_candidate_test.dart` asserts all 36 decisions and that development controls are absent; the Compliment sheet regression passes. Emulator: 208 captures, 0 skipped, all from `014ac35`, with real taps through chat keyboard, quoted replies, voice controls, Compliment send and failure, filters, wallet and profile; 15 key screens each at font 1.5, font 2.0 and 360 dp with 0 skipped. APK installed with `-r` and launched. 43 screens changed by the selections were inspected at phone size; the rest as contact sheets. Tests that encoded replaced looks were updated: banner fill and icon alignment, squircle match avatar, card tap to open. Not run: web `npm run check` and e2e (no web change), physical phone, screen reader, live Figma comparison.


> **Creative Lab V7 (`71564be`):** `flutter test` 635 passed, 42 skipped, 0 failed. `flutter analyze` 1 older info, no errors or warnings. `creative_lab_v7_test.dart` includes the Compliment sheet failed-send regression, which passes and caught a real overflow. Commit `759fbfe` was pushed with that test failing, and `71564be` fixed it. Emulator: 207 default captures with 0 skips, 243 Lab captures with 4 skipped journey steps. Gallery tested in the built-in browser over local HTTP: 432 of 432 images loaded, choices and notes survived a reload, JSON export and re-import matched, and bad JSON, a stale review ID, unknown group or variant and a direction mix were all refused. APK installed with `-r` and launched to Welcome. Not run: web `npm run check` and e2e (no web change; baseline failures unchanged from the start of V7), V7 at font 1.5 or 2.0 or 360 dp on a device, physical phone, screen reader.


> **MVP Focus V5 (`36407b3`):** register in `docs/product/mvp-focus-v5/REQUIREMENTS_REGISTER.md`. `flutter test` 600 passed, 42 skipped (none added), 0 failed; analyze 1 older info; 193 emulator captures, 0 skipped; font 1.5, 2.0 and 360 dp on 11 screens; gallery round trip verified; APK installs over the existing app and launches. Web: no files changed; `npm test` 121/122 and token and icon checks fail on CRLF only. Not checked: physical phone, iOS, screen reader, blur profiling.

> **Final screenshots (app `269de9d`):** 223 of 223 `adb screencap` PNGs, 1080 x 2424, font scale 1.0, reviewed visually; 223 index links resolve; harness analyzes clean. Emulator only. No app or web file changed, so the test suites were not re-run.

> **Ente Refinement V4 (`25e145f`):** full register in `docs/design/ente-refinement-v4/REQUIREMENTS_REGISTER.md`. `flutter test` 586 passed, 42 skipped (none added), 0 failed; analyze 1 pre-existing info; emulator 91/91 captures plus font 1.5, 2.0 and 360 dp; gallery round trip verified; APK installs and launches on the emulator. Web: no files changed; `npm test` 121/122 and the token and icon checks fail on CRLF only, as before; `test:e2e` cannot run (Playwright browser missing). Not checked: physical phone, iOS, blur profiling, keyboard on device.

> **Ente Alignment V3 (`ba3a6fc`):** analyze clean; `flutter test` 575 passed, 42 skipped (none added), 0 failed; emulator 38/38 captures; gallery export/import/zero-selection verified in the in-app browser; APK installs and launches. Unverified: physical phone, iOS, dark mode, toast/action-sheet fidelity, full dating-screen re-audit. Details: docs/design/ente-alignment/VALIDATION.md.

> **Events MVP + selected UI (2026-11-08, app code `ebf3623`, APK at `6a12b91`):** `flutter analyze`
> **no issues**; `flutter test` **566 passed, 42 skipped, 0 failed** (new `events_mvp_controller_test`
> and `events_mvp_test`; skips are superseded old-Events/visibility/"no Events in MVP" tests, each with
> a reason). Before fixes: 37 failures, all from the intended changes (five tabs, removed screens,
> selected variants); no pre-existing failures found. Pixel 10 AVD: `events_review_test` 34/34
> captures, 0 skipped steps; APK `adb install -r` Success, launches to Welcome. Web (no web
> files changed on this branch): `npm test` 121/122, `vite build` OK; `tokens:check`, `icons:check` and
> the token unit test fail on CRLF only, as before; `test:e2e` not run (Playwright Chromium missing). Not checked: physical phone, iOS, large text on the new Events screens on device,
> backend (none for Events).

> **Selections pass (2026-11-08, commit `010fe8f`):** `flutter analyze` no issues; `flutter test`
> **579 passed, 27 skipped, 0 failed** after removing `requestReconnect`/`respondReconnect` from
> `NumayaApi`. Backend SQL edited, not executed (no database). Emulator (Pixel 10 AVD): 8 Heart
> direction screenshots as Premium (`ONLY=screen-heart`). No new APK: no UI change since `8510778`.

> **Visual Lab V2 (2026-11-08, app commit `8510778`):** `dart format` clean; `flutter analyze` **no
> issues**; `flutter test` **579 passed, 27 skipped, 0 failed** (new `visual_lab_v2_test`: registry
> integrity, release ignores Lab choices, every component variant in isolation and in its real screen
> and every screen direction at 320dp/200% text, Archive/expired/Heart/Compliments flows, Compliment
> action geometry, badge placement, sheet close, insights honesty and funnel cohort, large-title
> collapse, motion presets; superseded EXP-002 C and EXP-004 tests skipped with reasons; obsolete
> reconnect/check-in tests rewritten to R01/R02). Web: `npm test` 121/122 and `vite build` OK;
> `tokens:check` and its unit test fail only on CRLF (no web files changed); `test:e2e` not run
> (Playwright Chromium not installed). Device: Pixel 10 AVD (API 36) ran
> `integration_test/visual_lab_gallery_test.dart` (237 stills, 12 screenrecord clips, 0 missing items);
> the installed APK launched to Welcome and applied a Visual Lab direction. Gallery JS verified in the
> in-app browser over HTTP: two choices + note exported, storage cleared, imported back identical;
> corrupt JSON, unknown variant, changed reviewId and path-like IDs refused; reset confirm; empty
> export; all 237 images and 12 clips load; no autoplay. Not checked: physical phone, iOS,
> profile-mode frame timing, backend (contracts still PRD v1).

> **MVP PRD v1 (2026-11-07, app commit `f6c4d8b`):** `dart format` clean; `flutter analyze` **no
> issues**; `flutter test` **564 passed, 21 skipped, 0 failed** (507 before; new `mvp_rules_test`,
> `mvp_controllers_test`, `mvp_screens_test`: every MVP route at 320/360/411 dp x 100/200% text plus
> tap-target and label guidelines). Repo root: `npm ci` run (node_modules was absent); `npm test`
> 121/122, `vite build` OK; `tokens:check`, `icons:check` and the tokens unit test fail only on CRLF
> (`core.autocrlf=true`; no web files changed); `test:e2e` not run (Playwright Chromium not
> installed). Backend SQL not executed (no database). Device: Pixel 10 AVD (API 36) ran the
> 79-image gallery harness (`tool/capture_mvp_gallery.sh`) and the installed APK launched to
> Welcome. **APK** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-MVP-PRD-20261107-f6c4d8b.apk`,
> debug, 222,135,345 bytes, SHA-256 `2e3d2aaddbb7a5ff4842d5661dd027d6b789cf03ad7d2877197e55a54b87e1b5`,
> local demo photos installed. **Gallery** `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\MVP PRD 2026-11-07\`
> (README.md + index.tsv; all 46 S-IDs). Not checked: physical phone, iOS, font 2.0 on a device.

> **Account-switch handoff (2026-11-07):** docs only, no app-code change since `4d713e3` (format,
> analyze and 507-test results there stand). Re-checked: `git status` clean apart from the handoff
> files, `gh auth status` logged in as RITAMBISWAS404, remote branch equals local HEAD after push.

> **X15 experiment (2026-11-07):** `dart format` clean; `flutter analyze` no issues; `flutter test`
> **507 passed, 21 skipped, 0 failed**; `sync_tabler_icons.py` run against the official 3.50.0 package
> (110 files, content identical; `--check` flags CRLF only). Pixel 10 AVD before/after at font 1.0
> (16 screens), 1.3 and 320dp (5 screens each); no clipping found.

> **SW-01 off switch (2026-11-07):** `dart format` clean; `flutter analyze` no issues; `flutter test`
> **506 passed, 21 skipped, 0 failed**. Pixel 10 AVD: Settings (Snooze, Incognito, notifications,
> Simulate connection problems) and the Filters sheet, before and after; harness render of
> off/on/disabled on a white card and on the grey page at DPR 2.625.

> **Local demo photos (2026-11-07):** `flutter analyze` no issues; `dart format` clean;
> `flutter test` **506 passed, 21 skipped, 0 failed** (+4 in `demo_photos_test`; the suite runs with
> no photo set loaded). Debug APK with the local set installed on the Pixel 10 AVD (`-r`, data
> kept): Discover, photo viewer, gallery, Likes, Messages, chat header, match screen, Profile and
> Edit profile checked on the device. `git check-ignore` confirms the photos are excluded.

> **Figma type and icons pass (2026-11-07, Windows, Flutter 3.47.8 / Dart 3.13.7):**
> - `dart format --set-exit-if-changed lib test`: exit 0.
> - `flutter analyze`: no issues.
> - `node tool/generate_tokens.mjs --check` (app): Dart tokens up to date.
> - `flutter test`: **507 passed, 21 skipped, 0 failed** (494 + 13 new in `figma_type_icons_test`).
> - Repo root `npm run check`: fails at `tokens:check` on line endings only (as in the UI consistency pass; no token source changed).
> - `npm run test:e2e`: not run, `playwright` is not installed.
> - `sync_tabler_icons.py --check`: not run (npm `@tabler/icons` absent); `git status` shows no asset change.
> - Pixel 10 AVD (API 36, 1080×2424, density 420, font scale 1.0): debug APK `57539e55…de72c476e4` installed with `-r` over the UI-consistency build (same debug key, data kept). 16 before + 16 after + 8 sweep captures.
> - Harness renders (flutter test, DPR 2.625): switch pairs at 1.0 and 2.0 text, icon board.
> - Not run: 2.0 system font and 320pt on the device, three-button navigation, iOS, physical phone, goldens.

> **UI consistency pass (2026-11-07, Windows, Flutter 3.47.8 / Dart 3.13.7):**
> - `dart format --set-exit-if-changed lib test`: exit 0.
> - `flutter analyze`: no issues.
> - `node tool/generate_tokens.mjs --check`: up to date.
> - `flutter test`: **489 passed, 21 skipped, 0 failed** (484 + 5 new in `ui_consistency_test`).
> - Repo root `npm run check`: fails at `tokens:check` on line endings only. Regenerating gave no content diff, and the files were restored. No web file changed.
> - `npm run test:e2e`: not run, because the `playwright` package is not installed.
> - `sync_tabler_icons.py --check`: not applicable (no icon assets changed; the `@tabler/icons` package is not installed here).
> - Pixel 10 AVD (API 36, 1080×2424, density 420): debug APK `59618d05…881b2ab5a` installed with `-r`. Captured 18 before and 18 after (1.0 and 2.0 text) plus 7 boards.
> - One ANR on the first launch after install: an input-focus timeout under emulator CPU pressure right after the Gradle build, with no Flutter errors in logcat. The relaunch was clean.
> - Not run: 320pt on the device, three-button navigation, the keyboard over the bar, Figma re-read, iOS, physical phone.

> **Device screenshots (2026-11-07, Windows, Flutter 3.47.8):**
> - `flutter build apk --debug` at `f6614fa`: OK, sha256 `c0c2d8ed…fec84da41`. `adb install -r`: Success.
> - Pixel 10 AVD (`emulator-5554`, API 36, 1080×2424, density 420, font 1.0): Welcome → sign-up → onboarding through Photos; then Quick start → Discover, Filters, Likes, Match, Messages, Chat, Profile, Edit profile, Settings, Premium, Safety, Help. 29 PNGs, all checked by eye and none duplicated.
> - `flutter analyze integration_test`: no issues (harness `final` set).
> - Not run this session: `flutter test`, `npm run check`, `npm run test:e2e`. Not reached on device: onboarding after Photos.

> **Review batch 2 (2026-11-06, Windows, Flutter 3.47.8, worktree `..\numaya-ente`):**
> - Formatting, analysis and the token check are clean.
> - `flutter test`: **393 passed, 15 skipped, 0 failed**. It includes the new 20-test
>   `test/widget/discover_match_review_test.dart`. 20 older tests were rewritten because they
>   encoded the superseded decisions: buttons, composer, flush sheets, 62pt nav, outlined switch.
> - Emulator (Pixel 10, API 36): 390dp and 320dp at 150% text, 30 captures each, no skips.
> - Not run: physical phone, iOS, TalkBack speech. Goldens were not regenerated.


> **UI review handoff (2026-11-05, Windows, Flutter 3.47.8, worktree `..\numaya-ente`):**
> - `dart format` clean, `flutter analyze` clean, `generate_tokens --check` up to date.
> - `flutter test`: **373 passed, 15 skipped, 0 failed**. This includes 12 new tests in
>   `test/widget/ui_review_handoff_test.dart`:
>   - height skip and unit conversion;
>   - both slider thumbs;
>   - prompt select, save, edit and cancel;
>   - prompt card hierarchy;
>   - heading art position;
>   - alert icon alignment;
>   - quiet button.
> - Emulator (Pixel 10, API 36): 22 shots at 390dp, plus 18 at 320dp with 150% text. The narrow set
>   predates the Discover inline-row fix.
> - Not run: physical phone, iOS, TalkBack speech. Goldens were not regenerated.


> **Ente experiment (2026-11-05, Windows, Flutter 3.47.8, worktree `..\numaya-ente`):**
> - `dart format` clean, `flutter analyze` clean, `generate_tokens --check` up to date;
> - `flutter test` **361 passed, 15 skipped, 0 failed** (the `accessibility_tools` audit is included);
> - emulator (Pixel 10, API 36): 390dp journeys E1 and E2, plus 320dp at 150% text;
> - goldens not regenerated (they are Linux renders of the old look);
> - not run: physical phone, TalkBack speech, iOS.

> **Final design run (2026-11-05):**
> - **Windows host, Flutter 3.47.8 / Dart 3.13.7, worktree `..\numaya-final-design`:**
>   - baseline `f2e18e6`: 342 passed, 15 skipped;
>   - final: `dart format` 0 changed, `generate_tokens --check` up to date, `flutter analyze` clean,
>     `flutter test` **361 passed, 15 skipped, 0 failed** (includes the `accessibility_tools` audit
>     and its negative control);
>   - `flutter build apk --release` builds (debug-signed);
>   - `flutter build apk --debug`: SHA-256 `78170dec…114b`.
> - **Device evidence** (Pixel 10 AVD, Android 16 / API 36, x86_64, 1080×2424, `wm density 443`
>   = 390dp; also 540 = 320dp at font scale 2.0):
>   - journeys in `artifacts/final-design-run/device/`;
>   - keyboard over the tab bar: verified;
>   - three-button navigation: verified;
>   - TalkBack: accessibility tree verified, live speech **not** (first-run permission prompt
>     dismissed, not granted).
> - **Goldens:** 101 Windows-to-Windows diffs reviewed; the Linux goldens were restored, so
>   regenerate them on Linux.
> - **Not run:** iOS, physical phone, profile-mode frame times.

## Pill gaps (2026-11-04, cloud, uncommitted)
| Command | Result |
|---|---|
| format, analyze, token check | clean |
| `flutter test` | **338 passed, 15 skipped, 0 failed** |
| captures | 20 passed; 28 changed and reviewed |

## Core journey pass (2026-11-04, cloud, uncommitted)
| Command | Result |
|---|---|
| format, analyze, token check | clean |
| `flutter test` | **337 passed, 15 skipped, 0 failed** |
| captures | 20 passed; 27 changed and reviewed |
| device | not run |

## Component cleanup (2026-11-04, cloud, uncommitted)
| Command | Result |
|---|---|
| format, analyze, token check | clean |
| `flutter test` | **334 passed, 14 skipped, 0 failed** |
| captures | 20 passed; 93 changed and reviewed |
| device, emulator | not run |

## Spacing and shape pass (2026-11-04, cloud, uncommitted)
| Command | Result |
|---|---|
| format, `flutter analyze`, token check | exit 0; No issues; up to date |
| `flutter test` | **326 passed, 14 skipped, 0 failed** |
| captures | 20 passed; 89 changed and reviewed |
| emulator, device, Inspector | not run (no SDK or device; the Dart MCP server failed to start) |

## Type-roles pass (2026-11-04, cloud, uncommitted)
| Command | Result |
|---|---|
| format, `flutter analyze`, token check | exit 0; No issues; up to date |
| `flutter test` | **323 passed, 14 skipped, 0 failed** |
| `flutter test test/widget/type_roles_test.dart --dart-define=NUMAYA_TYPE_SCALE=base` | fails (+3 −4) as intended |
| captures | 20 passed; 176 goldens changed and reviewed |
| emulator, device, screen readers | not run (no SDK or device) |

## Final QA pass (2026-11-04, cloud, uncommitted)
| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` | **316 passed, 14 skipped, 0 failed** (the baseline before this pass was 312 / 14 / 0) |
| `flutter test --tags screenshots --run-skipped --update-goldens test/screenshots` | 20 passed; only `m01` and `p05` changed; 33 renderer-only goldens restored |
| `integration_test/`, the APK, emulator, device, TalkBack and VoiceOver | **Not run:** no device or Android SDK (`dl.google.com` is denied) |
| `npm run check`, `npm run test:e2e` | **Not run:** no web change; no `node_modules` in the worktree |

## Overnight polish (2026-11-03 UTC, cloud worktree `/home/user/numaya-overnight`, uncommitted)
**Environment:** Linux, Flutter 3.47.8 and Dart 3.13.7 at `/opt/flutter-sdk`. **No Android SDK**:
`flutter doctor` reports "Unable to locate Android SDK", and `dl.google.com` is denied by the
network policy. Everything below is the Flutter test renderer, not an emulator or a device.

| Stage | Command | Result |
|---|---|---|
| HEAD `6b23c85` | `flutter analyze`; `flutter test` | No issues; **302 passed, 12 skipped, 0 failed** (matches the Windows claim) |
| HEAD | `flutter test --tags screenshots --run-skipped` (compare, no update), `fn01` | Fails by 1.17%: the goldens are Windows-rendered, so Linux font rasterising differs |
| Final | `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| Final | `flutter analyze` | No issues found |
| Final | `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| Final | `flutter test` | **312 passed, 14 skipped, 0 failed** (+10 tests in `test/widget/overnight_polish_test.dart`; +2 opt-in files) |
| Final | `flutter test --tags screenshots --run-skipped --update-goldens test/screenshots` | 20 passed. 157 goldens changed after review (154 updated, 3 new `op01`–`op03`); 34 renderer-only diffs restored to the committed versions |
| Final | `flutter test --tags comparison --run-skipped --update-goldens --dart-define=NUMAYA_TYPE_SCALE={base,body14,compact} test/screenshots/compare_type_scale_test.dart` | 3 × 4 passed; renders in `artifacts/overnight-polish/type-comparison/` |
| — | `npm run check`, `npm run test:e2e` (CLAUDE.md, web) | **Not run.** No web file changed (`git diff --stat` touches only `apps/numaya_mobile/`, `docs/` and `artifacts/`), and `node_modules` is not installed in this worktree |
| — | APK build, emulator, physical device, TalkBack, VoiceOver, iOS, profile-mode performance | **Not run** (no Android SDK or Xcode here). Open for the Windows machine |

**Goldens note:** the 154 updated goldens are Linux renders. On Windows they will differ by font
rasterising. Re-render them there (`flutter test --tags screenshots --run-skipped --update-goldens`)
before treating them as the reference.

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

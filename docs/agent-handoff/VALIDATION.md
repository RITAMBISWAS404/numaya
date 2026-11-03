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

**Web** (repository root, from `CLAUDE.md`), when web files change:
```sh
npm ci            # node_modules is not installed on this machine yet
npm run check
npm run test:e2e
```

**On a device** (owner's machine), when UI changes:
```sh
flutter emulators --launch Pixel_9
flutter run       # or: flutter build apk --debug, then install
```

## Last results
| Date | Branch @ commit | Check | Result |
|---|---|---|---|
| 2026-11-03 | premium-refinement @ `e70135c` | `flutter test` | 266 passed, 11 skipped, 0 failed (cloud Linux) |
| 2026-11-03 | premium-refinement @ `e70135c` | `flutter analyze` | No issues (cloud Linux) |
| 2026-11-03 | premium-refinement @ `e70135c` | size matrix, 4 widths × 3 text sizes | all pass |
| 2026-11-03 | premium-refinement @ `e70135c` | `npm run test:e2e` | not run |
| 2026-11-04 | final-ux-polish (setup) | `flutter doctor -v` | Android toolchain ✓, Chrome ✓; Visual Studio ✗ (not needed) |
| 2026-11-04 | final-ux-polish (setup) | Flutter and web suites | not run: docs-only change |

The app has **never been run on a device or emulator**; the first polish session should do this
on this machine.

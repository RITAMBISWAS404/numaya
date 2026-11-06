# V4: QA (Linux, Flutter 3.47.8 / Dart 3.13.7, widget harness; no device)

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` (full) | **452 passed, 21 skipped, 0 failed** at `d564a8a`. Skips are the opt-in `comparison` and `screenshots` capture suites |
| New tests | `test/widget/v4_polish_test.dart`: 9 tests. On the V3 candidate `fc72906` 8 fail and 1 passes (the guard that normal-size rows don't change) |
| Capture regression | All 58 views re-rendered against V3: 0 changed at 390x844; 4 changed at 320x693 / 200% (V4-02 only). Experiments: only EXP-001 A/B and EXP-002 A changed |
| Gallery (Chromium, from a fresh extraction of the V3 review ZIP) | 306/306 full-size links resolve and open in a new tab; unselected export is all null with the 4 register IDs; keyboard (Tab to Export, arrow keys in a radio group, 3px focus ring); filter keeps selections; clearing one choice leaves the others; notes export; no page-level horizontal scroll at 390px. One bug fixed: "1 choices selected" (V4-05) |
| V4 gallery | Rebuilt with the fixed builder and checked again in Chromium (see `gallery-check.json`) |

Exploratory probe tests were not committed (they print findings rather than assert). They ship in the review ZIP under `probes/`.

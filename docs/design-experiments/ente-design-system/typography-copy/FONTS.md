# Font assets and rendered weights

## Asset metadata
Checked with fontTools 4.60.1 in a temporary virtualenv under the session scratchpad. It is not a project dependency.

| File | Family (name ID 1) | Version | Axis | Default | Named instances | x-height / cap | Coverage |
|---|---|---|---|---|---|---|---|
| `assets/fonts/Figtree-Variable.ttf` | "Figtree Light" | 2.002 | wght 300–900 | **300 (Light)** | Light … Black (7) | 500 / 700 per 1000 | Latin-1, Latin Ext-A, curly quotes, dashes, ellipsis, ₹ €; **no** Devanagari, Cyrillic or Greek; `tnum` present |
| `assets/fonts/PlusJakartaSans-Variable.ttf` | "Plus Jakarta Sans" | 2.071 | wght 200–800 | 400 | ExtraLight … ExtraBold (7) | 536 / 745 per 1000 | Same as Figtree; 721 glyphs; `tnum` present |

- Both files are declared once each in `pubspec.yaml` under their family names.
- Hanken Grotesk stays in `assets/fonts/` but is not registered.
- No weight is missing or misdeclared: a single variable file per family covers every role's weight.

## What Flutter rendered
These are measured renders, distinct from the metadata above.

Method:
- Flutter 3.47.8 test renderer with the bundled files loaded (`loadAppFonts`).
- "Hamburgefonstiv 0123" at 28pt, black on white.
- The score is ink coverage: the mean darkness of the image.

| Weight | Figtree via `wght` | Figtree via `fontWeight` only | PJS via `wght` | PJS via `fontWeight` only |
|---|---|---|---|---|
| 300 | 0.0840 | 0.0840 | 0.0852 | 0.0852 |
| 400 | 0.1112 | 0.1112 | 0.1088 | 0.1088 |
| 500 | 0.1292 | 0.1292 | 0.1402 | 0.1402 |
| 600 | 0.1504 | 0.1504 | 0.1631 | 0.1631 |
| 700 | 0.1740 | 0.1740 | 0.1836 | 0.1836 |
| 800 | 0.1977 | 0.1977 | 0.2038 | 0.2038 |
| none set | 0.1112 (= 400) | | 0.1088 (= 400) | |

Findings:
- **Regular, medium, semibold and bold are distinct** in both families. Each step adds 12–29% ink.
- **This engine maps `fontWeight` onto the `wght` axis.** A style with no weight renders at 400, not at Figtree's file default of 300. Material default text, such as tooltips, is therefore not Light.
- **One hazard:** `role.copyWith(fontWeight: w700)` keeps the role's `wght 500` variation and rendered at 0.163, against 0.153 for `AppTypography.weight(role, 700)`. The two don't match, which suggests synthetic emboldening on top of the axis value. No code did this. `test/typography` now fails if any `fontWeight:` in `lib/` lacks `fontVariations` in the same call.
- **Not covered:** names in Devanagari, Cyrillic or Greek would fall back to a system font. Neither family covers them, so these scripts were not rendered in the harness. This is a device check if such names are expected.

Regression coverage, in `test/typography/typography_copy_test.dart`:
- "bundled fonts render distinct weights": each step must be over 8% heavier than the one below.
- "every role sets the wght axis".
- "no screen restyles a weight without its wght axis".

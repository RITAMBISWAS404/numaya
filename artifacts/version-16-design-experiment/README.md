# Numaya V16: Withings Health Mate-inspired visual layer on V11

**What it is:** V11's layouts and UX, unchanged, restyled in the visual language of Withings Health
Mate (iOS):
- a warm grey canvas with white cards;
- black primary actions;
- Withings blue for selection;
- green switches;
- bold Hanken Grotesk headings and uppercase tracked labels.

**Recommendation: return to V11.** V16 is well executed but does not clearly improve Numaya
([ACCEPTANCE_REVIEW.md](ACCEPTANCE_REVIEW.md)).

## Activate
| URL | Renders |
|---|---|
| `flows.html?theme=withings` | every themed screen |
| `flows.html?screen=settings&theme=withings` | one screen |
| `?theme=withings` | welcome |
| `?theme=tiimo` | V11, unchanged |
| no parameter | the production default, unchanged |

## Contents
| Path | |
|---|---|
| [BASELINE.md](BASELINE.md) | repository state, isolation, mechanism, commands |
| [research/REFERENCE_ANALYSIS.md](research/REFERENCE_ANALYSIS.md) | 45 reference screens, colour, type, components, translation, facts vs interpretation, access limits |
| [design-system/](design-system/) | layout contract, principles, tokens, component rules, screen inventory |
| [SCREEN_REVIEW.md](SCREEN_REVIEW.md) | four review passes and their fixes |
| [ACCEPTANCE_REVIEW.md](ACCEPTANCE_REVIEW.md) | criterion-by-criterion ratings |
| `screenshots/v11/`, `screenshots/v16/` | 29 gallery states each |
| `screenshots/compare-v11-v16/` | 29 side-by-sides |
| `screenshots/contact-sheet-v16.png`, `contact-sheet-v11-v16.png` | overviews |
| `screenshots/compare-reference-v16.png` | Health Mate previews next to V16 (Mobbin preview images, for internal review only) |

## Code
**New:**
- `src/design-system/styles/theme-wth.css`: the visual layer, scoped to `.theme-wth`;
- `tests/e2e/experiment-withings.mjs`: 22 checks, including the geometry comparison with V11;
- `tests/unit/theme.test.js`.

**Changed:**
- `src/lib/theme.js`: `withings` and `themeClassName()`;
- `src/flows/Flows.jsx` and `src/prototype/screens/Welcome.jsx`: apply the class;
- `tokens/numaya.tokens.json`: `wth` tokens, then the generated `tokens.css` and `tokens.js`;
- `src/design-system/index.css`: font and stylesheet imports;
- `package.json`: Hanken Grotesk, and V16 added to `test:e2e`;
- `tests/e2e/a11y.mjs`: three V16 targets.

## Verification (2026-11-03)
| Check | Result |
|---|---|
| `npm run check` (tokens, icons, unit, build) | 121/121 unit tests, build OK |
| `npm run test:e2e` | smoke 144/144, product 88/88, V11 111/111, V16 22/22 |
| `npm run test:a11y` | 13/13 targets, 0 serious or critical |
| Geometry (12 states × 393 / 375) | non-text ≤ 1px; text runs change width only |
| V16 recapture vs saved | 29/29 identical |
| V11 from V16 code vs V11 worktree | 29/29 identical |
| Default vs committed gallery | 162/162 identical |

# Validation report: Tiimo-inspired V3

Every result below comes from a command run on this branch's final code (`7c67749`; the artifacts
commit adds only files under `artifacts/`). Logs were not committed.

## Automated checks

| Check | Command | Result |
|---|---|---|
| Token freshness | `npm run tokens:check` | pass: 306 tokens (V2: 302; 4 added, none changed) |
| Icon freshness | `npm run icons:check` | pass |
| Unit tests (Vitest, 7 files) | `npm test` | **117 / 117** |
| Production build | `vite build` | **pass** |
| Smoke e2e (approved contracts) | `tests/e2e/smoke.mjs` | **144 / 144**, unchanged |
| Product e2e (journeys) | `tests/e2e/product.mjs` | **88 / 88**, unchanged |
| Experiment e2e | `tests/e2e/experiment-tiimo.mjs` | **40 / 40** (V2: 25) |
| Accessibility (axe, WCAG 2.1 A/AA) | `npm run test:a11y` | **0 serious or critical** in 10 views, including the themed Welcome and all 11 themed flow screens |

No smoke, product or unit assertion was edited. Only the experiment's own test changed, because its
design contract changed.

## The experiment contract (tests/e2e/experiment-tiimo.mjs)

**Kept from V2:**
- scoping: the flag only, the 12 screens only, no leakage to 5 other screens;
- white canvas;
- neutral fields;
- purple outgoing bubbles at 4.90:1, grey incoming bubbles at 16.53:1;
- selected-interest tint at 5.63:1;
- decorative emoji;
- interactions and navigation;
- no overflow and no console errors at 393 × 852 and 375 × 667.

**New or rewritten for V3:**

| Check | Result |
|---|---|
| No gradient on any element or `::before`/`::after` of the 12 themed screens or the seeded match, placeholders included | 0 found |
| With a pure-white test image in the photo slot, Discover and Like back get a gradient made only of black stops | pass |
| The fade is darkest at the bottom, transparent at the top, and never gets lighter downwards | pass |
| The fade stays in the lower part of the photo and is clipped by its corners | 63% (Discover) and 47% (Like back) of the photo is clear |
| Name over a pure-white photo (large text, ≥ 3:1) | 4.81:1 at 55% black |
| Detail line over a pure-white photo (≥ 4.5:1) | 6.90:1 at 65% black |
| No capsule-shaped element on Basics, Interests, Discover, Like back, Match, Conversation, Messages and Activity, apart from progress, switches, sliders and count badges | 0 found |
| Interest set headings: neutral ink on no coloured fill; the category tint in the emoji holder | pass (`rgb(20, 19, 22)`, 18.51:1) |
| The prompt question is neutral | `rgb(60, 59, 64)` |
| Match: no confetti, no halo | pass |
| Match: their photo is a circular crop and your avatar is a circle | `circle(43% at 50% 50%)` |
| Match: your avatar overlaps the edge of their circle, clear of its centre, and theirs is dominant | circle 223px (radius 111.5), yours 64px, centres 106px apart: 95% of the radius |

The contrast figures are computed. The fade's opacity at the top edge of each text line (its
lightest point) is composited over pure white, which is the worst case for white text.

## Approved design: unchanged

- I captured all 23 states **without** the flag on V3 and on V2. All 23 are byte-identical.
- 22 of them are also byte-identical to the approved design's committed gallery
  (`artifacts/tiimo-inspired-experiment/screenshots/baseline`). The 23rd, 014, has no capture
  there.

## Screenshots

- `screenshots/baseline/`: V2 at `c90e93f`, 23 states, captured from a clean V2 checkout. The 18
  states captured before the brief was widened are byte-identical to this set.
- `screenshots/final/`: V3, the same 23 states, from the running app with `GALLERY_THEME=tiimo`.
- `screenshots/comparisons/`: 23 before/after pairs, plus 4 photo-overlay QA pairs.
- `screenshots/photo-qa/`: Discover and Like back with two **canvas test patterns** in the photo
  slot (pure white, and a portrait-like pattern), on V2 and V3. These are not photographs: the repo
  has none.
- `contact-sheet.png`: the 23 V3 states.

| Screen | States (393 × 852 unless noted) |
|---|---|
| Basics | 013, 014 (focused), 015 (error) |
| Interests | 016, 017 (at the limit), 144 (375 × 667) |
| Discover | 019, 021, 145 (375 × 667) |
| Full profile | 020 (full scroll), 059 (Like back) |
| Match | 030, 032 (typing), 146 (375 × 667) |
| Activity | 061, 064 (filters sheet), 153 (375 × 667) |
| Conversation | 038, 039 (typing), 042 (new match openers), 148 (375 × 667) |
| Messages | 034, 147 (375 × 667) |

## Visual QA

I opened at full size:
- Interests (chips and set headings);
- Discover (the card and its badges);
- Match at 393 and at 375;
- Activity, Messages and the top of the full profile;
- the photo-QA pairs.

I reviewed the rest on the contact sheet.

Defects found and fixed:

| Defect | Cause | Fix |
|---|---|---|
| The SuperSwipe on the photo and Pass/SuperSwipe/Like were still capsules (72 × 56, radius 28) | Their own size rule | Button corner (16) inside the theme |
| At 375 × 667 your avatar covered too much of their (smaller) circle | The avatar had a fixed 64px size while the portrait shrank | The avatar scales with the portrait on short phones (50px) |
| Your avatar's centre sat just outside their circle (116px from the centre, radius 111px), a weak overlap | Percentage offsets that ignored the avatar's size | Placed by formula at 95% of the radius, at every size |
| The first gradient scan accepted overlays on placeholders, and the match was checked in its empty state | Test scope | The fade is allowed only with a real `<img>`, and the match is seeded as right after liking Maya |

## Not verified

- **Real photography:** none exists in the repo. The fade was reviewed on test patterns.
- **The Pemu reference:** not found in Mobbin.
- **Other browsers:** only Chromium was available.
- **Platform emoji:** iOS and Android glyphs differ.
- **Dark mode:** the prototype has none.

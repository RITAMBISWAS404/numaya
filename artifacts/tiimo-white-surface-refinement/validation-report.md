# Validation report: white-surface refinement

Every result below comes from a command run on this branch's final code (commit `e4b9862` plus
these artifacts). Logs were not committed.

## Automated checks

| Check | Command | Result |
|---|---|---|
| Token freshness | `npm run tokens:check` | pass: 302 tokens (305 before; 3 removed) |
| Icon freshness | `npm run icons:check` | pass |
| Unit tests (Vitest, 7 files) | `npm test` | **117 / 117** |
| Production build | `vite build` | **pass** |
| Smoke e2e (approved contracts) | `tests/e2e/smoke.mjs` | **144 / 144**, unchanged |
| Product e2e (journeys) | `tests/e2e/product.mjs` | **88 / 88**, unchanged |
| Experiment e2e | `tests/e2e/experiment-tiimo.mjs` | **25 / 25** (20 before; 5 new or rewritten checks) |
| Accessibility (axe, WCAG 2.1 A/AA) | `npm run test:a11y` | **0 serious or critical** in 10 views, including the themed Welcome and all 11 themed flow screens |

## New and changed experiment checks

| Check | Result |
|---|---|
| Themed screens sit on a pure white canvas | `rgb(255, 255, 255)` |
| Your messages are solid brand purple with white text, no background image | `rgb(114, 98, 199)` / `rgb(255, 255, 255)` / `none` |
| Your message text contrast | 4.90:1 |
| Their messages are a light neutral, distinct from yours and from the white canvas | `rgb(242, 242, 242)` |
| Their message text contrast | 16.53:1 |
| Text fields are a light neutral (R = G = B, ≥ 240), no warm fill | `rgb(242, 242, 242)` |
| No computed gradient on any element or `::before` / `::after` inside `.theme-tiimo`, on Welcome and all 11 themed flow screens (checks `background-image`, `border-image-source` and `mask-image`) | **0 found** |

The scoping checks are kept: without the flag no screen is themed; with it, exactly the 12 selected
screens are; five screens outside the selection stay approved even with the flag.

**Negative control.** I ran the same test file against the original experiment's code
(`36686f8`). It failed 5 checks, as it should: the lilac canvas, the lilac bubble, the white
incoming bubble, the warm `rgb(242, 239, 235)` field, and gradients on 7 of 12 screens (primary
buttons, FABs, the Home header, the profile-card placeholder and scrim). This shows the gradient
scan detects real gradients rather than passing trivially.

## Approved design: unchanged

- No smoke or product assertion was edited.
- **Pixel proof.** I captured the 18 states with the gallery **without** the flag on this branch.
  16 are byte-identical to `artifacts/tiimo-inspired-experiment/screenshots/baseline` (the approved
  design). The other 2 (014 and 043) have no capture there, so I captured them without the flag from
  the original experiment branch, which the earlier report showed is identical to the approved
  design; they are byte-identical too.

## Screenshots

- `screenshots/baseline/`: the Tiimo experiment before this refinement, 18 states. 16 are
  byte-identical to the committed captures in `artifacts/tiimo-inspired-experiment`; 014 and 043
  were captured from a clean checkout of `36686f8` and compared the same way.
- `screenshots/final/`: this refinement, the same 18 states, from the running app with
  `GALLERY_THEME=tiimo`.
- `screenshots/comparisons/`: all 18 states as before/after pairs.
- `contact-sheet.png`: the 18 final states.

Viewports: 393 × 852 for every screen (the gallery standard); 375 × 667 for Welcome, Interests,
Discover, Match and the long conversation (140, 144, 145, 146, 148).

## Visual QA

I opened at full size the final Basics, Discover, Match and Conversation, and the Discover
comparison. I reviewed the rest on the contact sheet.

Defects found and fixed during the refinement:

| Defect | Cause | Fix |
|---|---|---|
| SuperSwipe turned black | The solid-ink rule for Pass/Like (two classes) out-ranked the SuperSwipe variant (one class) | Rule limited to `:not(.action-bar__btn--super)` |
| Name scrim still a gradient | First override targeted the wrong class | Targets `.profile-card__overlay` |
| Confetti dots touched the heading and the badge; one clipped at the screen edge | Positions | Left- and right-anchored dots with box-shadow copies, kept in the margins |

Other experimental screens (Photos, Like back, Likes, Messages, Edit prompt, Activity) were covered
by the smoke check only: no horizontal overflow and no console errors at 393 × 852 and 375 × 667,
and no computed gradient.

## Not verified

- Other browsers: only Chromium was available.
- Real photography: the name band was judged on the grey placeholder only.
- Emoji rendering on iOS and Android.
- Dark mode: the prototype has none.

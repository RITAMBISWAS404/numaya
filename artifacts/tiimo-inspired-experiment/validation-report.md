# Validation report

Every result below comes from a command that was actually run on this branch's final code. Logs were
not committed.

## Automated checks

| Check | Command | Result |
|---|---|---|
| Token freshness | `npm run tokens:check` | pass: 305 tokens (the approved branch had 277; all 28 new ones are `tiimo`) |
| Icon freshness | `npm run icons:check` | pass |
| Unit tests (Vitest, 7 files) | `npm test` | **117 / 117** |
| Production build | `vite build` | **pass** |
| Smoke e2e: the approved design's contracts | `tests/e2e/smoke.mjs` | **144 / 144** (unchanged from the approved branch) |
| Product e2e: journeys | `tests/e2e/product.mjs` | **88 / 88** (unchanged) |
| Experiment e2e (new) | `tests/e2e/experiment-tiimo.mjs` | **20 / 20** |
| Accessibility (axe, WCAG 2.1 A/AA) | `npm run test:a11y` | **0 serious or critical** in 10 views, including the themed Welcome and the flow gallery with all 11 themed flow screens |

`npm run test:e2e` now runs all three e2e files. `npm run test:a11y` adds the two themed views.

## Approved design contracts: unchanged

- No existing smoke or product assertion was edited. The experiment has its own test file.
- One unit-test allowlist gained two component-local variables (`--tone-tint` and `--tone-ink`,
  set per `[data-tone]`). That allowlist exists to document such variables.
- **Pixel proof.** All 40 baseline captures were taken from this branch's code **without** the
  flag. They are byte-identical to the approved branch's own final gallery (`944c532`). Without the
  flag, the experiment does not change a single pixel of the approved design in the captured states.

## Experiment checks (tests/e2e/experiment-tiimo.mjs)

| Area | Checks |
|---|---|
| Scoping | Without the flag, none of the 12 screens is themed. With it, all 12 are. Five screens outside the selection stay unthemed even with the flag. |
| Look | Lilac-white canvas. The interest sets are peach, lilac and mint capsules. A selected interest takes its tint. |
| Contrast | Capsule ink on tint is ≥ 4.5:1 (5.63). Selected interest text is ≥ 4.5:1 (5.63). Your message text on the lilac tile is ≥ 4.5:1 (6.64). |
| Accessibility | Emoji are decorative CSS content with empty alt text. A chip's accessible name is the interest alone. The Welcome stickers are `aria-hidden`. |
| Interaction | Picking an interest still toggles it. Changing tab keeps `?theme=tiimo`, and the next screen is themed. |
| Responsive and console | No horizontal overflow and no console errors on all 12 themed screens at 393 × 852 and at 375 × 667. |

## Contrast of the palette

| Pair | Ratio |
|---|---|
| Peach ink on peach tint | 5.63:1 |
| Lilac ink (purple 800) on lilac tint | 6.64:1 |
| Mint ink on mint tint | 5.75:1 |
| Sky ink on sky tint | 6.26:1 |
| Butter ink on butter tint | 6.41:1 |
| Ink / secondary / muted text on canvas | 17.54 / 10.52 / 5.47:1 |
| Ink / secondary / muted text on stone field | 16.15 / 9.69 / 5.04:1 |
| White on brand purple (primary buttons, unchanged) | 4.90:1 |

## Visual QA

- Every one of the 40 themed captures was rendered from the running app with the project gallery
  (`GALLERY_THEME=tiimo`).
- I opened at full size: Welcome, Basics, Photos, Interests (393 and 375), Discover (card and
  "You both like"), the Discover and Activity filter sheets, Like back, Likes, Match, Messages,
  Conversation, Edit prompt, Activity Explore, and the 1440 desktop flow gallery. I reviewed the
  others in the group contact sheets.

Defects found and fixed during QA:

| Defect | Cause | Fix |
|---|---|---|
| Emoji drawn outside the interest chips | Buttons already use `::before` for the enlarged touch target | Emoji moved to `::after` with `order: -1` |
| Inbox cards ran past the right gutter | The base row's negative-margin trick combined with card padding | Width reset inside the theme |
| Mixed warm and cool photo placeholders on Likes; a lighter second photo slot | The scoped field-fill token reached placeholders, and a specificity tie in the photo slot | Placeholders pinned to their neutral greys |
| Activity cards kept a hairline | The card has its own outline rule | Included in the borderless-card rule |
| Match confetti dot crossed the heading; too faint | Dot positions and sizes | Moved to the margins and enlarged |
| Fifth Welcome sticker sat against the headline | Composition | Reduced to four stickers in a tighter cluster |
| The 🍽️ plate emoji rendered pale | That glyph's appearance in the emoji font | Replaced with 🍝 |
| White cards on a white sheet | Sheet panel colour | Sheets use the canvas inside the theme |

## Responsive

- **Mobile, 393 × 852 and 375 × 667.** There is no overflow, as checked by the e2e test and the
  gallery's own overflow check. At 375 the emoji and capsules cost about one chip row on Interests:
  "Travel" falls below the fold, where in the approved design it was above it. That is a real
  density cost.
- **Desktop, 1440 × 900.** The flow-preview gallery renders the themed screens beside unthemed ones
  (capture 132). There is no layout change, because the phone-width screens are centred as before.

## Not verified

- **Other browsers.** Only Chromium was available: no WebKit or Firefox, and no real iOS or Android
  devices.
- **Emoji rendering.** Glyphs come from the container's emoji font and will look different on iOS
  and Android.
- **Dark mode.** The prototype has none.
- **Motion.** None was added. Reduced motion is unchanged and is covered by the existing e2e suite.

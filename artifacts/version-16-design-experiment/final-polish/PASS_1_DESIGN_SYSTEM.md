# Pass 1: design-system consistency

## What was inspected

- `tokens/numaya.tokens.json` (the V16 groups).
- `src/design-system/styles/theme-withings.css`: all 171 rules.
- `src/flows/theme-withings.css`.
- The V11 rules underneath: `theme-tiimo.css`, because V16 restyles it.
- Computed styles of 47 component classes on all 14 flow screens and their sheets (`qa/audits.txt`).

## Findings

| # | Finding | Cause | Level | Severity |
|---|---|---|---|---|
| 1.1 | **Components defined more than once with conflicting values.** `.list-group__title` (20px, then 22px), `.screen-header__title` (30 bold, then 26 medium), `.organic-portrait__fallback` (navy, then photo grey), `.match-queue__image` (circle, then rounded rectangle, then circle at 72px), `.action-sheet__list`, `.empty-state` (twice). The winning value depended on source order across four appended correction sections. | The first implementation plus four append-only correction passes | Shared stylesheet | P2 |
| 1.2 | **Dead and contradictory rules.** The first in-card chip rule was always outranked; a "keep the rounded-rectangle shape" comment sat above a rule that a later section overrode. | Same | Shared stylesheet | P2 |
| 1.3 | **Raw values bypassing tokens:** type sizes and line heights (32/38, 30/36, 26/32, 22/28, 20/26, 18/24, 15/20, 14, 13.5, 12.5, 11.5), tracking values, the segmented radius (10, 8), search height 46, composer radius 22, small-button height 36, action size 56, portrait 72, mark sizes 28 and 24, choice size 22, thumb sizes 27 and 26 | Not added to the token file in earlier passes | Tokens | P2 |
| 1.4 | **A V16 value that never applied.** The segment corner (8px) was silently beaten by V11's `.theme-tiimo :is(… .chip, .segmented__item)` (specificity 0,5,0), so the selected segment rendered as a **pill in a 10px rounded track**. This is the defect you reported. | A specificity mismatch with the V11 layer | Shared component | **P1** (fixed in pass 2) |
| 1.5 | Two more V11 rules outrank V16 for the same reason: the prompt question colour (`.profile-section--prompt .profile-section__title`, 0,3,0) and emoji chips (0,5,0) | Same | Shared component | P2 (fixed in pass 2) |
| 1.6 | Colour tokens: no duplicates or conflicts; every colour in the CSS goes through a token (the unit test enforces this) | — | — | none |
| 1.7 | Shadows: three in use (`withings-float`, `withings-segment`, the shared thumb shadow), each with one documented role | — | — | none |
| 1.8 | Icons: one family (Material Symbols Rounded, filled when active). Sizes: 18px inside 40px circles, 22px bare in modal headers, 24px in the tab bar. Consistent per role. | — | — | none |

## Corrections made

1. **New tokens (component.withings, 51 added; 437 in total).**
   - Geometry: `button-height-sm`, `segment-radius`, `segment-inset`, `segment-height`, `search-height`,
     `composer-radius`, `action-size`, `portrait-size`, `mark-size`, `prompt-mark-size`, `choice-size`,
     `thumb-switch`, `thumb-slider`.
   - Type: a `type.*` group for every role, sizes and line heights (hero, page, headline, flow, section, sheet, empty,
     row, card, body, body-sm, button-sm, label, caption, micro, header-caps, label-caps, match-max), plus five
     tracking values.
2. **One consolidated stylesheet.** `theme-withings.css` was rewritten as one ordered system: roles, type, surfaces,
   lists and selection, fields, buttons and actions, chips and tabs, labels, navigation and headers, sheets and
   menus, photos and avatars, messaging, empty states and placeholders.
   - Each component is defined once, at the value that actually rendered before.
   - Every raw size above now reads a token. The switch thumb's travel is computed from the tokens
     (`switch-width − thumb − 4px`), not hard-coded as 20px.
   - The file went from 1,075 lines to 1,023 before the pass-2 fixes.
3. **Proof the consolidation is behaviour-neutral.** All 54 states (49 plus 5 full-page) were captured before and
   after it: **54 identical, 0 different** (`qa/isolation.txt`). The unit suite's static CSS rules still pass:
   token-only colours, every `var()` resolves, no primitive tokens in components.

The real fixes (1.4, 1.5) were then applied as pass 2, on top of a verified neutral base.

## Variation kept on purpose (documented, not "fixed")

| Variation | Reason |
|---|---|
| Full-width buttons have 12px corners; small buttons are full pills | The reference does exactly this ("Done" against "Add a Reminder") |
| View tabs are pills on the page; category filter chips are 12px rectangles | Tabs switch a view (the reference's period tabs); category chips are content (the reference's icon chips) |
| Icons are 18px in circles and 22px bare | Optical balance in a 40px circle versus a bare header icon |
| Field labels are capitals; sentence-length labels (`.fl-label`) are not | The reference sets only short labels in capitals |

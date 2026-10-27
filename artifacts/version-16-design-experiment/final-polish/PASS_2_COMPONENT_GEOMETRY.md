# Pass 2: component geometry and visual consistency

## Method

- **Geometry audit (automated).** On every V16 screen and its open sheets and menus (22 states), each visible surface
  is compared with every visible surface child that hugs its edge (inset ≤ 10px). It flags:
  - a pill child in a non-pill container;
  - a child corner larger than the container's minus the inset.

  Output: `qa/audits.txt`.
- **Style inventory (automated).** Height, radius, font size and weight of 47 component classes on all screens.
  Equivalent components that differ show up as several value lines; the before / after diff is in
  `qa/audits.txt`.
- **Visual check.** Every flagged item was inspected at 2× in the rendered app.

## Findings and corrections

| # | Issue | Evidence | Fix | Level | Severity | Verified |
|---|---|---|---|---|---|---|
| 2.1 | **Pill segments in a rounded-rectangle track** (Edit / Preview, Explore / My activities): the selected segment had a 16px (pill) corner inside a 10px track | Geometry audit: `segmented (r10) > segmented__item (r16) inset 2 [pill in non-pill]`; inventory `r999px` | The segment corner is now the track's minus the inset (10 − 2 = 8), read from tokens, with a selector whose specificity matches V11's (0,5,0) | Shared component | **P1** | Audit clean; `comparisons/polish-before-after.png`; e2e "segmented … nests" |
| 2.2 | **The same prompt question, two styles:** 14px semibold grey on your prompt, 15px medium on someone else's (also grey, because a V11 rule outranked V16) | Inventory: `.prompt__label h24 fs14 fw600` against `.profile-section__title fs15 fw500`; e2e colour read | One card-title role (15/20, medium, ink) for `.prompt__label` and `.profile-section__title`, including the higher-specificity prompt variant | Shared component | P2 | e2e "roles: prompt question" |
| 2.3 | **Chip text in two sizes** at the same 36px height: 15px interests and filters, 14px static chips (profile, shared interests, facts) | Inventory: `.chip [chip--static] fs14px` | One chip text size (`type-card-size`, 15) | Shared component | P2 | e2e "roles: every chip" |
| 2.4 | **Person names in two weights:** inbox 700, Likes tiles 600 | Inventory | One weight (semibold) | Shared component | P3 | e2e "roles: person names" |
| 2.5 | **Likes tiles of different sizes in one row** whenever captions wrap differently (430px: 257 against 243px photos). The tile is a shrink-to-fit button, so its 3:4 photo took its width from the caption. | Pass 3 capture at 430px; probe | Tile fills its grid column. Pre-existing in V11 and in the approved design, but a defect in a V16 screen, so fixed in V16 scope only. | Shared component (V16 scope) | P2 | e2e "Likes photos … same size"; `comparisons/responsive-430.png` |
| 2.6 | Switch target 51 × 31 inside a row that isn't a label | Target audit | The track's `::before` extends the hit area to 44px (the thumb is `::after`) | Shared component | P2 (from pass 5) | e2e "targets: switch" |
| 2.7 | Search input 25px tall inside a 46px field (taps on the field's padding missed it) | Target audit | The input stretches to the field's height | Shared component | P3 (from pass 5) | e2e "targets: search" |

## Checked and consistent (no change)

- **Nested corners** follow container minus inset:
  - photo index badge 6 in a 14 tile at 8 inset;
  - activity photo 6 in a 14 card;
  - Likes "New" label 6 at 8 inset.
- Option-card groups: first and last rows take the card corner, middle rows square, and the focus outline follows.
- Action sheet: the group and Cancel share the card corner.
- Sheet: 16px top corners, a full-width header hairline.
- The composer: a 44px pill field beside a 44px circle send button; heights match.
- Paired buttons share heights: Pass / Like back 50/50; Write a bio / See insights 36/36; Discover actions 56/56/56.
- Badges are all 26px with a 6px corner; counts are 20px pills.
- Borders: one hairline colour for dividers, the header and tab bar, and info boxes. Fields use the darker outline
  (reference). No double borders were found.
- Remaining audit hits are false positives: the page itself as a "container", and a switch inside a transparent row.

# Pass 6: screenshot review

## What was captured

All from the running app with `scripts/gallery.mjs` (`GALLERY_THEME=withings`), at 2× device pixel ratio.

| Set | Count | Where |
|---|---|---|
| Inventory states, 393 × 852 | 40 | `screenshots/states/*-393x852.png` |
| Small phone, 375 × 667 | 9 | `screenshots/states/*-375x667.png` |
| Full-page scrolls, 393 wide | 5 (Discover, Match, Profile, Edit, Preview; Activity and Settings also captured in pass 3) | `screenshots/states/*-fullpage-393w.png` |
| 360 and 430 widths | 6 screens each | `screenshots/comparisons/responsive-360.png`, `responsive-430.png` |
| Keyboard focus at 2× | 4 controls | `screenshots/comparisons/keyboard-focus.png` |
| Before / after the polish fixes, 2× crops | 7 | `screenshots/comparisons/polish-before-after.png` |
| Contact sheet | 38 primary states | `screenshots/contact-sheet.png` |

## Review method

1. **Full-size inspection at 2×.** Headers, chip rows, fields, segmented controls, sheets, inbox rows, photo slots and
   tiles, and Settings groups were each cropped and inspected at full resolution. Thumbnails were not relied on.
2. **Equivalent screens compared:**
   - all sheets against each other;
   - all chip contexts (page, card, sheet, match);
   - all paired buttons;
   - all headers (tab root, modal, chat).
3. **Before / after.** A pixel diff of all 54 states against the pre-polish build. **22 changed, 32 identical**,
   and every changed state belongs to a fix in the issue tracker:
   - chips on Discover, Match, Profile, Like back and Preview;
   - segments on Edit and Activity;
   - search and names on Messages;
   - the prompt question on Profile, Edit and Discover.

   No unexplained change.
4. **Reference drift.** The Reference | V11 | V16 sheets from the fidelity audit were re-checked against the new
   states. The fixes move V16 closer to the reference: the segmented control now matches "Programs / Library" exactly.

## Defects found by screenshot inspection

| # | Defect | Severity | Fix | Re-inspected |
|---|---|---|---|---|
| 6.1 | Selected segment was a pill inside a 10px track | P1 | 2.1 | ✓ 2× crop, Edit and Activity |
| 6.2 | Likes tiles in one row differed in size at 430 | P2 | 2.5 | ✓ 430 capture |
| 6.3 | Prompt question grey on Discover but ink after the first fix (a V11 rule outranked V16; caught by the new e2e role check, then confirmed in the capture) | P2 | 2.2, specificity matched | ✓ |
| 6.4 | Empty photo slot: no visible focus ring | P1 | 5.1 | ✓ 2× focus capture |
| 6.5 | Chip text sizes differed between Profile and Interests | P2 | 2.3 | ✓ |

## Inspected and found clean

- One-pixel alignment of icons in rows, header buttons, tab-bar dots, badge baselines and inbox metadata.
- Radius combinations: every nested surface follows the container-minus-inset rule (pass 2 audit).
- Backgrounds:
  - white cards on stone on every screen;
  - info boxes stone with a hairline;
  - sheets white;
  - the action-sheet panel transparent around its white blocks.
- Separators: no missing or doubled dividers in grouped rows, choice groups, sheets or the inbox.
- Sticky and fixed overlap: none (pass 3).
- Selected against unselected: radio, checkbox, chip, tab, segment and switch states read at a glance in every
  context.

## Remaining limitations

- Photo screens are judged with placeholders; the repo has no profile photography.
- Hover and pressed states are not capturable statically; they were checked in CSS.

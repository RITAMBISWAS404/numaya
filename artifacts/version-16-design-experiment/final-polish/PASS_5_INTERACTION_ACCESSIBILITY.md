# Pass 5: interaction and accessibility QA

## What was exercised

| Area | How | Result |
|---|---|---|
| All product journeys: onboarding, Discover like / pass / undo / filters, matching, Likes, chat send / unmatch / block / report, profile edit, prompt save, settings, activity | `tests/e2e/product.mjs` (88 checks) | 88/88 |
| V16 interactions: navigation keeps the theme, switch toggles, slider moves with the keyboard, filter sheet opens, action sheet and report sheet open and dismiss (Escape), the invalid field state | `tests/e2e/experiment-withings.mjs` (55 checks) | 55/55 |
| V11 behaviour on the same branch | `tests/e2e/experiment-tiimo.mjs` | 111/111 |
| Keyboard focus | Tab through the 14 flow screens (up to 40 stops each); every focused element checked for a visible ring on itself or its wrapper; rendered rings captured at 2× | see below |
| Touch targets | Every button, link, input and tab measured, counting the shared 44px `::before` extension | see below |
| Automated accessibility | axe-core on the 15 V16 screens; `npm run test:a11y` on the approved design | 0 serious or critical / 0 serious or critical |

## Defects found and fixed

| # | Defect | Severity | Fix | Verified |
|---|---|---|---|---|
| 5.1 | **Empty photo slots had no visible keyboard focus.** V16 draws their dashed edge with `outline`, which replaced the focus outline. | **P1** (keyboard users lost their place on Photos and Edit) | `:focus-visible` restores a 2px solid blue ring with a 2px offset | Capture `comparisons/keyboard-focus.png`; e2e "focus: an empty photo slot" |
| 5.2 | **Switch hit area 31px tall** (not in a label) | P2 | `::before` extends the target to 44px; the thumb stays `::after` | `elementFromPoint` 6px above and below the track hits the switch; e2e |
| 5.3 | **Search input 25px tall inside a 46px field** | P3 | The input stretches to the field | e2e "targets: search" |

## Checked, no defect

- **Focus rings visible** on fields, the textarea, search and composer (the wrapper's 2px blue ring), segments (they
  follow the 8px segment corner), slider thumbs, choice rows (the card outline), buttons, chips, tabs and the tab bar.
  The audit's remaining "no indicator" entries are wrappers that draw the ring; each was confirmed in a 2× capture.
- **Semantics unchanged:** native checkboxes and radios, `role="tab"` segments, `aria-pressed` filter tabs,
  `aria-current` tab bar, labelled icon buttons. V16 changes CSS only.
- **No dead controls found.** Every captured control was exercised by the suites or the tab-through. No overlapping
  hit areas: the switch's extended area stays inside its row.
- **Dismiss:** sheets close by ✕, Escape and scrim; action sheets by Cancel and Escape; focus returns (product
  suite).
- **States:** empty (4 screens), error (invalid field), disabled (5 controls), selected (all selection controls),
  focus. All are visually distinct.

## Not testable here

- Screen-reader output beyond axe's rules: there is no VoiceOver or TalkBack in this container.
- Real touch devices: touch targets are measured, not tapped.
- Hover: verified in CSS only.

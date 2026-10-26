# V11 layout and UX baseline, and what V16 changed

## What V16 kept from V11

V16 adds no markup, no component and no behaviour. Every JSX change is the theme switch: `src/lib/theme.js`,
`Flows.jsx` and `Welcome.jsx`, which apply the class. So the following are V11's by construction:
- information architecture and the 15 screens;
- the five-tab bar: Home, Activity, Likes, Messages, Profile, with labels and red dots;
- journeys and routing, including deep links and `?theme` being kept on navigation (tested);
- section order on every screen;
- content and copy;
- photo placement and crop, the full-width Discover photo with the name over it, and the two-column Likes grid;
- the three-column photo grid in Edit profile and Photos;
- the conversation list, the bubble alignment and the composer position;
- the step button and progress bar in onboarding;
- the sheets and their actions;
- responsive behaviour: V11's breakpoints and the short-phone match rules are untouched (checked at 375 × 667).

## Changes to presentation within an unchanged layout

These change how existing boxes look, not where they are or what they do. Each is in
[COMPONENT_RULES.md](COMPONENT_RULES.md).

| Change | Reference evidence | Why V11 alone could not match the reference | Usability effect | Verified in |
|---|---|---|---|---|
| Profile sections between photos (Discover, Like back) become white cards | Stacked measurement cards (`07`, `02`) | On a white page there is nothing for a card to separate from; with the stone page, unboxed sections would float with no edge | Each section reads as one unit between the photos | `v11-v16-021-discover-you-both-like.png`, `020` full scroll |
| Choice rows grouped into one card with dividers; the selected row loses its ring | Radio lists (`22`, `21`) | V11's separate outlined rows with a 2px ring are the opposite of the reference's grouped list | Less visual noise; the radio or tick still shows the state; focus gets a visible outline | `v11-v16-013-basics.png`, `v11-v16-108-prompt-editor.png` |
| Discover actions become 56 pt circles (from 72 × 56 pills) | The reference draws icon-only actions as circles ("+", Add Logs, header buttons) | A 50% radius on a 72 × 56 box makes an ellipse (caught in review pass A) | Targets are still 56 pt, above 44 | `v11-v16-022-discover-actions.png` |
| Segmented control becomes a track with a selected segment (items fill the width) | `25` Programs / Library | V11's two separate pills are a different control | A clearer two-way switch; the full-width segments are larger targets | `v11-v16-102-edit-profile.png`, `061` |
| Modal headers become a white bar with a hairline | `14`, `22`, `11` | The bar is what separates the modal header from the stone page | The header is clearly fixed chrome | all modal screens |

**No layout changes.** Nothing moved, no column count changed, nothing was added or removed. The segmented items
now fill the control's width; that is the control's own geometry, not the page layout.

## Changes considered and rejected

- **Radio on the left of the label, as in the reference.** Rejected: it would change V11's row layout and the
  tested selection rows, and gains nothing in usability.
- **Wrapping the conversation list in a white card.** Rejected: V11's direct list with avatar-aligned dividers
  reads well on stone, and a card around a list that grows would change scrolling.
- **Three-tab navigation like the reference.** Rejected: Numaya's five sections are product structure.
- **A Withings-style home greeting ("Good morning, Alex") on Discover.** Rejected: it would be a new element the
  spec does not describe.

# V11 layout contract (V16)

V16 changes how V11 looks, never how it is arranged.

## Locked (V11 decides)
- **Structure:** information architecture; screens; section order; which sections exist; the order of
  fields, rows, cards and content.
- **Size and placement:** every element's position and size:
  - containers, photos, cards, groups, rows, buttons, chips, fields, icons, tab items;
  - grid structure and column counts (Likes 2-column, Edit 3 × 2 photos).
- **Photos:** placement, size and crop: the Discover card, Likes tiles, the Match scallop and its mask.
- **Navigation:** V11's bottom tab bar (five labelled items, red dots), its position and its height.
  Withings' three-tab iOS bar is **not** adopted.
- **Actions:** the position, size and order of every action: Discover SuperSwipe on the photo; the
  Pass / Super / Like bar; Pass / Like back; Write a bio / See insights; Keep browsing; the composer
  and send.
- **Behaviour:** flows, routes, state, responsive behaviour at 393 and 375px.
- **No iOS behaviour:** no collapsing large titles, no action-sheet alerts.

## Allowed (V16 decides)
| Allowed | Condition |
|---|---|
| colour, background | |
| border colour; edges drawn with **inset** box-shadows | they change no box |
| corner radius | |
| font family, weight, tracking, case | |
| font size | only on V11's line-height, so the box is unchanged |
| outer rings (box-shadow) on controls | |
| icon colour | |
| hover, focus, pressed, selected and disabled appearance | |

**Never in `theme-wth.css`:** `width`, `height`, `padding`, `margin`, `gap`, `position`, `inset`,
`display`, `order`, `grid-*`, `flex-*`, a changed line-height, transforms that move content.

## Tolerances
- **Every element that is not a text run** (containers, cards, rows, buttons, chips, fields, icons,
  photos, tab items): position and size **≤ 1px**.
- **Text runs** (a leaf element holding only text): may change **width**, and **x** when centred, because
  a new face and case set the same words at a different width. Their **y and height must stay ≤ 1px**, so
  each run keeps its line, its line count and V11's line-height, and nothing around it moves.
- Measured drift on text runs:
  - uppercase navigation titles: 11–17px wider;
  - the profile name: 8px;
  - the match title: 10px;
  - a count: 2.6px.

  No text run changed its line count.

## Enforcement
`tests/e2e/experiment-withings.mjs` renders 12 screens and states with `?theme=tiimo` and
`?theme=withings` at 393 × 852 and 375 × 667, and compares the box of every element.

**Screens and states:**
- Discover;
- Like back;
- Likes;
- Messages;
- Chat;
- Profile;
- Edit;
- Prompt editor;
- Settings;
- Match;
- Match with no match;
- Discover with the filters sheet open.

## UX ideas recorded, not built
Each of these would move or change components, so none is in V16.
- Withings' grouped radio panel (one card holding all the options) for the prompt editor. V11 uses
  separate option cards.
- Uppercase tracked titles centred in sheets, with "Cancel" moved to the left. V11's sheet header keeps
  its close button on the right.
- A segmented track for Edit / Preview. V11 has two separate pills.
- Blue icon circles in front of settings rows. V11's rows have icons in place, and a circle would add
  size.

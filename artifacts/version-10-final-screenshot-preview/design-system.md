# Numaya V10 design system: balanced geometry on the V9 monochrome system

V10 is a precision pass on V9. It changes four things and leaves everything else alone:

1. **Geometry.** Fully rounded pills and generously rounded rectangles, each chosen per component.
   Conventional shapes come back where a control's function needs them.
2. **Navigation.** A traditional, full-width bottom tab bar.
3. **Notification dots.** Red dots replace the numbers in the tab bar.
4. **Match.** A larger portrait with a softer scallop.

The V9 colour system, surfaces, typography, layouts, copy and behaviour are unchanged; see
[V9's design-system.md](../version-9-final-screenshot-preview/design-system.md) for the palette and
surface rules.

**Where it lives:**
- tokens: `tokens/numaya.tokens.json` (`component.tiimo.radius-*`; run `npm run tokens`);
- components: `src/design-system/styles/theme-tiimo.css`;
- flow screens: `src/flows/theme-tiimo.css`.

**Scope:** everything is scoped to `.theme-tiimo`, which appears only with `?theme=tiimo`. Without
the flag, all 162 gallery states are byte-identical to the approved design
([qa/default-mode-unchanged.txt](qa/default-mode-unchanged.txt)).

## 1. Radius scale

| Token | Value | V9 | Components |
|---|---|---|---|
| `radius-check` | **6px** | 6 | Checkboxes: a conventional, slightly rounded square |
| `radius-tag` | **8px** | 6 | 24–27px labels and badges ("New", "Your move", "Verified", "Live now", the activity category), the photo order badge and remove button |
| `radius-chip` | **12px** | 8 | 36px content chips: interests, emoji categories, shared interests, facts ("Long-term") |
| `radius-control` | **12px** | 10 | 36–44px icon buttons (back, close, filters, more, settings), the send button |
| `radius-item` | **12px** | 10 | Fields, search, the composer, selection rows, opener rows, the unmatch-sheet note |
| `radius-button` | **14px** | 10 | Standard and full-width 48–56px buttons (Continue, Show 3 people, Pass, Like back, Unmatch, Save) |
| `radius-feature` | **16px** | 12 | Cards and groups, your prompt, information containers, photo tiles and slots, new-match portraits, message bubbles (6px tail), the FAB, the readiness meter |
| `radius-photo` | **20px** | 14 | Full-width profile photographs (Discover, Like back), sheets, dialogs |
| `radius-pill` | **999px** | — | Fully rounded: compact actions and toggles (below) |

**Avatars** are rounded squares at a quarter of their size, so every size reads as the same shape:

| Size | Corner |
|---|---|
| 24px | 6 |
| 36px | 9 |
| 48px | 12 |
| 64px | 16 |
| 96px | 24 |

This replaces V9's fixed scale (6–14), which made the large profile avatar look almost square.

**How the values were chosen:**
- A rounded rectangle's corner sits at about a quarter to a third of its height: 8 on 24px, 12 on
  36–44px, 14 on 48–56px, 16 on cards, 20 on photographs.
- The increases from V9 are uneven on purpose. Fields and rows gained about 20%, chips 50%, tags
  33%, cards 33% and photographs 43%. Checkboxes, which already looked right, did not change.

## 2. Pill or rounded rectangle

| Shape | Why | Components |
|---|---|---|
| **Pill** | Compact actions and toggles, in a single row, that switch or trigger something | Likes and Messages filter tabs; segmented options (Explore / My activities, Edit / Preview); small 40px buttons ("Edit profile", "Write a bio", "See insights"); Pass, Like and SuperSwipe (72 × 56px, the star kept); the unread count (min 26px wide, so a single digit is still a pill); onboarding progress segments; switch tracks and handles; slider rails and handles; the readiness bar |
| **Rounded rectangle** | Structured controls and content that sit in families or grids | Content chips (they wrap in sets, and pills would read as buttons); fields and rows; standard buttons; icon buttons; cards, tiles, groups, bubbles, photographs |
| **Conventional** | The shape is the meaning | Radios: circles with a dot. Checkboxes: 6px squares with a tick. Notification dots: 8px dots |

**Not pills:**
- **The FAB (56 × 56).** A pill on a square is a circle, so it is a 16px rounded square.
- **Icon buttons (36–40px square).** They stay 12px rounded squares, for the same reason.

The Discover action row is pill-shaped because each button is wider than it is tall.

## 3. Conventional controls

| Control | V9 | V10 |
|---|---|---|
| Radio | 6px rounded square, square inner mark | **The approved circle with its dot**, untouched by the theme |
| Checkbox | 6px square | 6px square with a tick (unchanged) |
| Switch | 51 × 31 track, 9px corners; 25px rounded-square thumb | **58 × 32 pill track**; **34 × 26 pill handle** (wider than tall, inset 3px); purple when on, neutral when off; same `role="switch"` |
| Slider | 3px rail; 28px rounded-square thumbs | **Pill rail and interval**; **20 × 28px pill handles** (same row and hit height) |
| Avatars | Rounded squares, 6–14px | Rounded squares at a quarter of their size; still never circles |

## 4. Nested corners

The rule is **inner ≈ outer − inset**: a rounded element close to a rounded parent's corner takes the
parent's corner minus the gap between them. The
[nested-corner audit](qa/nested-corners-v9-v10.txt) lists every such pair on 14 screens, for V9 and
V10.

| Pair | Outer | Inset | Inner (V9 → V10) |
|---|---|---|---|
| Photo placeholder in a photo slot (Add photos, Edit profile) | 16 | 0 | 16 (V9 clipped a 16px placeholder in a 10px slot) |
| Order badge ("Main", 2, 3) and remove button in a photo slot | 16 | 8 | 6 → **8** |
| "New" / "Matched" label on a Likes tile | 16 | 8 | 6 → **8** |
| Photo inside an activity card | 16 | 8 | 4 → **8** |
| Readiness bar inside the meter | 16 | 10 | pill (4px tall) |
| Tab items in the tab bar | — | — | No background any more, so nothing to nest |

These pairs aren't nested in this sense:
- the SuperSwipe on the photo (20px in from the corner);
- radios, checkboxes and switches inside rows and groups (19–20px in).

They keep their own shapes. The e2e suite checks the listed pairs to within 2px.

## 5. Bottom navigation

| | V9 | V10 |
|---|---|---|
| Structure | Floating rounded rectangle, 12px outer margins | **Full width**, square-cornered, no outer margin, the last row of the screen |
| Separation | Hairline plus one soft shadow | **1px top divider (`#E4E4E7`), no shadow** |
| Height | 56px, floating above a 12px gap | **56px of items plus the home-indicator inset** (`--safe-bottom`, 12px in the preview frame) |
| Items | 5, about 72 × 48 | 5, about 75 × 56 (377px wide, 8px side padding) |
| Icons | 24px | **24px (unchanged)** |
| Active | Inset-grey rounded rectangle behind a purple icon | **Purple filled icon only**, no background |
| Inactive | Ink icons | **Secondary grey icons (`#77737D`)** |
| Labels | Icon-only (the label is the accessible name) | Unchanged: icon-only, accessible names and `aria-current` as before |

**Content and safe area.** The bar is the last row of each tab screen's flex column, so the body
scrolls above it and its last row ends exactly where the bar begins (tested at 393 × 852 and
375 × 667). The bar pads the home-indicator area instead of floating above it.

**Notification dots.**
- The tab bar's numbers become 8px red dots (the approved notification red `#B93A36`). Each sits at
  the icon's upper right with a 2px white ring, so it stays distinct where it overlaps the icon.
- A dot means "something to check". The count is no longer drawn, but it stays in the badge's text
  and `aria-label` ("5 new in Likes") and in the tab's accessible name ("Likes, 5 new").
- Numbers stay wherever they carry meaning: the Likes and Messages filter counts ("New 3",
  "Unread 1") and the unread count beside a conversation.

See [comparisons/navigation-v9-v10.png](comparisons/navigation-v9-v10.png) and
[qa/navigation-375-and-393.png](qa/navigation-375-and-393.png).

## 6. Match

- **Their portrait** is about 12% larger: up to 296px or 74vw, from 264px or 66vw. At 393px wide it
  is 291px instead of 259px. On short phones (≤ 700px tall) it is capped at 27svh so the whole
  moment still fits above the composer.
- **The scallop** keeps its construction (a radius modulated by a cosine, the same depth) with eight
  lobes instead of ten. Each lobe's curve is therefore about 45% more generous: the radius of
  curvature at a lobe goes from 7.0 to 10.1 units of 100. The edge reads fuller and rounder, while
  the silhouette stays recognisably a scallop and the photo still fills it edge to edge.
- **How the variant is selected.** The shared component draws both masks and reads `--organic-frame`;
  the theme sets it to the soft one. Without the flag, the approved ten-lobe frame renders exactly
  as before.
- **Your photo** is a 64px rounded square with a 16px corner (a quarter of its size) and a white
  ring. It sits on the lower-left edge at the same proportional position. On short phones it shrinks
  with the portrait.
- **Unchanged:** no heart, no halo, no confetti, the shared-interest chips, the composer and "Keep
  browsing".

See [qa/match-composition.png](qa/match-composition.png) and the synthetic-photo fixtures in `qa/`.

## 7. Unchanged from V9

- **Colour:**
  - the white canvas;
  - the grey surfaces (`#F7F7F8`, `#F0F0F2`, `#E4E4E7`);
  - purple `#7262C7`;
  - neutral text.
- **Surfaces and containers:**
  - direct content and outlined modules;
  - secondary-grey information containers and recessed fields;
  - one shadow, only for what floats (the SuperSwipe on a photo, sheets).
- **Discover:**
  - no bar under the logo;
  - the black photo fade on real photographs;
  - the solid band on placeholders.
- **Filters and labels:**
  - Likes and Messages filter tabs have no checkmark;
  - the status-label tones;
  - "Matched" is neutral.
- **Readiness:** shown as a bar, still a meter.

## 8. Contrast

The rendered audit checked 300 text elements on 15 themed screens: **0 below AA**
([qa/contrast-audit.txt](qa/contrast-audit.txt)). That is 10 fewer than V9 because the tab-bar
numbers are no longer drawn. V10 changes no colours. The inactive tab icons are
`#77737D`, which is 4.63:1 on white (non-text UI needs 3:1).

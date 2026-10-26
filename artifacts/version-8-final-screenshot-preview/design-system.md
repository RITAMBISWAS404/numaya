# Numaya V8 design system (Tiimo-inspired experiment)

V8 refines V7. Its three changes were all made as component-level rules, not broad overrides:

1. **No lavender surfaces.**
2. **A tighter radius scale that depends on component size.**
3. **Containers only where they do a job.**

Where these rules apply:
- **Tokens:** `tokens/numaya.tokens.json`. Run `npm run tokens` after editing.
- **Component layer:** `src/design-system/styles/theme-tiimo.css`.
- **Flow layer:** `src/flows/theme-tiimo.css`.

Everything is scoped to `.theme-tiimo`, which renders only with `?theme=tiimo`. Without the flag, all 162
gallery states are byte-identical to the approved design ([qa/default-mode-unchanged.txt](qa/default-mode-unchanged.txt)).

## 1. Colour

### Palette and roles

| Token | Value | V8 role |
|---|---|---|
| Canvas (`--color-palette-canvas`) | `#F6F5F1` | Main canvas (kept from V7, see below) |
| Card | `#FFFFFF` | Outlined modules and groups, raised feed objects, floating chrome, incoming bubbles |
| Recessed on the canvas (`fill-on-canvas`) | `#EDEBE5` | Fields, search, composer, unselected pills, the active tab item, pressed and hover states |
| Recessed inside white (`fill-on-card`) | `#F1F0EA` | Unselected pills and tags inside white surfaces |
| Inset | `#F8F7F3` | Defined, unused in V8 (too close to the canvas to read as a step) |
| Brand | `#7262C7` | Primary actions, selected pills, selected controls and rings, the active tab icon, SuperSwipe, your messages, unread counts, verified marks |
| Border | `#E6E3DD` | Outlines and dividers |
| Text | `#28262D` | Headings and body text |
| Secondary | `#77737D` | Secondary text inside white; `#6B6771` on the canvas (4.25:1 → 5.06:1) |
| Purple tint `#E5E3FA` and Muted `#F2F0FE` | — | **No longer used as surfaces in V8** (the tokens still exist) |

### Keeping the V7 canvas

The supplied Background `#F1F0EA` reads beige across a whole screen. V7's `#F6F5F1` was chosen in a
four-way study (V7 `qa/background-study.png`). V8 keeps it because the reason for the
change has not gone away, and the V8 hierarchy depends on it:

- White outlined modules still separate from it (1.09:1, plus the hairline).
- `#F1F0EA` now serves as the recessed fill inside white.
- With fewer containers, more content sits directly on the canvas, so a lighter canvas matters more
  than before.

### Removing the lavender

The approved components draw lavender through two roles: the brand surface (info cards, prompts,
fallbacks) and the brand tint (selected rows, pressed icon buttons, the brand badge). Inside the
theme, both roles resolve to the neutral recessed fill, and each former lavender surface then got
its own treatment:

| V7 lavender surface | V8 treatment | Why |
|---|---|---|
| Your prompt (Profile, Edit, Interests) | **White, 1px outline**, neutral quote-mark watermark | You open and edit it as a whole module, so it needs a boundary. It doesn't need to look raised. |
| Their prompt (Discover, Like back) | **Direct on the canvas**: label plus the display-face answer, no quote mark | The typography already says "prompt". A box would compete with the photos around it. |
| Info cards (first-photo tip, "Liked you at…", blocking note) | **Direct notes**: an ink icon, a semibold line and body text on the canvas | This is secondary information, so it shouldn't carry the weight of a surface. |
| Selected option row | **White with the 2px brand ring**, plus the filled radio or ticked box | The ring and the indicator already mark the selection, so the wash was redundant. |
| Active tab item | **Neutral `#EDEBE5` fill** behind the filled brand icon | Purple stays on the icon itself, and the tab bar keeps its shape. |
| "Live now" badge | Neutral fill, deep-purple text and icon | The state stays readable, but the tinted box is gone. |
| Activity image fallback | The neutral photo grey with an ink glyph | It now matches every other missing photo. |

The e2e suite reads the background of every element on all themed screens and fails if any is
light and blue-shifted. The only exceptions are identity colours: avatar and new-match fallbacks,
the match-portrait fallback, and category holders, which are explained below.

### Where purple remains

Purple is now either a solid fill or a mark, always with a reason:

- **Solid fill:**
  - primary buttons and the FAB;
  - selected pills and filters;
  - SuperSwipe;
  - your messages;
  - checked controls and slider ranges;
  - unread counts.
- **Mark:**
  - the selected-row ring;
  - the active tab icon;
  - verified ticks;
  - the new-match ring;
  - the readiness ring;
  - progress segments;
  - links (deep purple on the canvas).

[qa/purple-usage.txt](qa/purple-usage.txt) lists each one per screen. Compared with V7, the only change
is that the lavender fills listed above are gone.

**Not changed:** the five category pastels (peach, lilac, mint, sky, butter). They appear only as the
24px holder behind a category emoji and the four Welcome stickers. They code categories rather than
acting as surfaces, and removing them would remove information. Butter remains the highlight for
"New" and "Your move" because it marks a state.

## 2. Radius scale

Radii are chosen by the size and role of each component. The values are tokens (`--tiimo-radius-*`),
applied component by component.

| Token | Value | Size | Components |
|---|---|---|---|
| `tag` | **6px** | ≤ 27px tall | Badges ("New", "Verified", "Live now"), "Your move", the activity category, the photo order badge and remove button, checkboxes |
| `pill` | **10px** | 36px chips | Emoji-and-text pills, filter chips (with or without emoji), fact chips ("Long-term"), segmented options |
| `control` | **12px** | 40–56px controls | Buttons (primary, secondary, quiet), icon buttons (back, close, filters, more), the send button |
| `item` | **12px** | Rows and fields | Fields, search, composer, selection rows, photo slots, new-match portraits, opener rows, the sheet note |
| `feature` | **16px** | Modules | Cards and outlined groups, your prompt, message bubbles (6px tail corner), the 56px FAB, Likes portrait tiles, your photo on the match |
| `photo` | **20px** | Full-width imagery | Discover and Like back profile photos, the top of sheets, dialogs |

**Why these values.** Each step is roughly a quarter to a third of the component's height, which
avoids both near-capsules and sharp corners:
- 6px on 24px;
- 10px on 36px;
- 12px on 48px;
- 16px on cards;
- 20px on photos 480–680px tall.

V7's 24–32px on cards and photos, and its capsule buttons, filters and badges, are what made the UI
feel soft and bubbly. A photo inset inside a card takes the card's radius minus the inset (8px inside
an activity card), so the corners stay concentric.

### Circles and capsules

| Element | V7 | V8 | Reason |
|---|---|---|---|
| Back, close, filter and more buttons | circle | **12px rounded square** | Utility controls, not identity |
| Step FAB | circle | **16px rounded square** | Matches the button language at its size |
| Composer send | circle | **12px square** | Pairs with the 12px field next to it |
| Photo remove (×), add (+) holder | circles (the + with a shadow) | **6px / 12px squares**, the + flat with a hairline | Small tools on a slot; the empty slot should not look raised |
| Buttons, filters, segmented options, search, badges | capsules | **12 / 10 / 10 / 12 / 6px** | One shape per size |
| **Kept as circles:** avatars, radios, numeric badges (tab counts, unread), the switch thumb | circle | circle | The circle means something here: identity, a single choice, a count, on/off |
| **Kept as capsules:** tab bar and its items, progress segments, switch track, slider | capsule | capsule | Established navigation and continuous controls |
| **Kept as designed:** Pass, Like, SuperSwipe (28px on 56px), the star, the match scallop, your 16px photo | — | unchanged | Intentional components named in the brief |

[qa/radius-audit-v7-v8.txt](qa/radius-audit-v7-v8.txt) gives the computed radius of every component on
nine screens for V7 and V8, and marks which components are unchanged on purpose. The e2e suite pins both groups and
checks that the same components keep the approved shapes without the flag.

## 3. Surfaces and elevation

| Treatment | Look | Used for |
|---|---|---|
| **Canvas** | `#F6F5F1` | The page and sheets |
| **Direct content** | No fill, border or shadow; type, spacing and dividers | Someone's profile sections, info notes, inbox rows, section headings, Likes tiles (photo plus text, no card) |
| **Outlined module or group** | White and a 1px `#E6E3DD` outline, no shadow | Your prompt, profile readiness, settings, filter and account groups, selection rows, opener rows, secondary buttons |
| **Recessed** | One neutral step darker, no border or shadow | Fields, search, composer, unselected pills, the active tab item, the sheet note |
| **Raised** | White with the soft card shadow (≤ 9% opacity) | **Activity cards only**: independent objects in a feed |
| **Floating** | The float shadow | Tab bar, floating icon buttons, Pass, Like and SuperSwipe, FAB, primary buttons, sheets |

How to choose:
- **Can the content stand on the canvas** (type plus spacing, or a list with dividers)? Then place it
  directly.
- **Is it a module you act on as a whole, or a group of controls?** Then outline it.
- **Is it an independent object you scan in a feed?** Then raise it.
- **Does it float over scrolling content?** Then it gets the float shadow.

The e2e suite enforces this with an elevation allowlist: activity cards plus the floating and primary
controls. It also checks that cards, your prompt, groups and rows have exactly the 1px outline.

## 4. Containers, screen by screen

| Screen | V7 | V8 |
|---|---|---|
| Discover, Like back | Prompt in a lavender tile; "About me", "You both like" and "My location" in white shadowed cards between photos | **Direct content** between the photos, aligned with the name on the photo; pills use the canvas fill |
| Like back | Lavender "Liked you at…" card | **Direct note** above the photo |
| Messages | Rows separated by spacing only; new-match tile 20px with a ring | **Inset 1px dividers** from the name column; each row 8px taller (12px above and below); new-match tile 12px, keeps its brand ring (unopened state) |
| Conversation | Composer recessed, circle send | Recessed 12px field and 12px send button; bubbles 16px with a 6px tail; incoming white, yours purple |
| Profile | Lavender prompt; raised readiness card | Prompt **outlined**; readiness **outlined** (both are modules, neither floats) |
| Edit profile | Lavender prompt | Outlined prompt; photo slots 12px |
| Interests | Lavender prompt at the end | Outlined prompt; the categories stay direct (heading plus pills, no wrapper) |
| Add photos | Lavender tip card; circular + with a shadow | **Direct tip**; dashed empty slots with a flat 12px + holder; filled slots 12px |
| Basics, Your prompt | Selected row with lavender wash | White with the brand ring |
| Settings, Discover filters | Outlined groups (24px) | Outlined groups (16px); the alerts note stays direct text |
| Likes | Tiles without cards (24px photos) | Same, 16px photos, 6px "New" tags |
| Activity | Raised cards (24px), lavender fallback | Raised cards (16px, the only raised content); neutral fallback; concentric 8px image |
| Match | Scallop photo, 16px rounded-square avatar, no heart, halo or confetti | **Unchanged**; close button 12px; composer 12px |

The [container audit](qa/container-audit-v7-v8.txt) lists every element with a fill, shadow or border on
the 14 themed flow screens, for V7 and V8. The rows with an outer shadow drop from 38 to 31, and every
`.card` (profile sections aside, which are direct) is outlined rather than shadowed; only `.activity-card` keeps a shadow.

## 5. Pills

| State | On the canvas | Inside white |
|---|---|---|
| Unselected | `#EDEBE5`, no border, tint or gradient; ink label | `#F1F0EA` (the activity category tag) |
| Selected | **Solid `#7262C7`**, white semibold label, white minus or check (4.90:1), no ring | — |
| Locked at the limit | Unselected fill, subtle label and glyph | — |
| Shape | 10px on 36px; 6px on the 27px tag; selected and unselected identical in size | |

Filter chips without emoji (Messages, Likes) share the 10px corner because they are the same size,
but keep their own colours: white outlined, or purple when selected. See
[comparisons/pills-only-v7-v8.png](comparisons/pills-only-v7-v8.png).

## 6. Preserved

V8 does not change any of the following, and the e2e suite checks each one:

- **Discover photo fade:** black, 60%, and the rendered column has no visible band.
- **Placeholder photos:** the solid band, with no gradient.
- **Discover actions:** the star and the Pass, Like and SuperSwipe shapes.
- **Match:**
  - the scallop clip;
  - your 16px rounded-square photo on its lower left;
  - no heart, halo or confetti.
- **Behaviour:** interactions, routing, validation and the interest limit.

Fixtures: [fade bright](qa/discover-photo-fade-bright-fixture-393x852.png),
[fade dark](qa/discover-photo-fade-dark-fixture-393x852.png),
[placeholder band](qa/discover-placeholder-solid-band-393x852.png),
[match 393](qa/match-scallop-photo-fixture-393x852.png), [match 375](qa/match-scallop-photo-fixture-375x667.png).

## 7. Contrast

The rendered audit checked 310 text elements on 15 themed screens against the actual colour behind
each one, and found **0 below AA** ([qa/contrast-audit.txt](qa/contrast-audit.txt)). Text that moved
to the canvas uses the canvas text roles:

| Text on the canvas | Ratio |
|---|---|
| Ink `#28262D` | 13.70:1 |
| Secondary `#6B6771` | 5.06:1 |
| Deep purple links | Pass AA |

White on brand is 4.90:1. Ink on the active tab fill, and on recessed fields, is 12.53:1.

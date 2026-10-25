# Design system: Tiimo-inspired experiment

## Architecture: an opt-in, scoped theme

- **Turning it on.** `?theme=tiimo` turns the experiment on (`src/lib/theme.js`). Without the
  parameter, the app renders the approved design. All 40 baseline captures taken from this branch's
  code without the flag are byte-identical to the approved branch's gallery.
- **Which screens.** The 12 selected screens carry `.theme-tiimo`:
  - 11 flow screens, listed in `TIIMO_SCREENS` in `src/flows/Flows.jsx`;
  - Welcome, set in `src/prototype/screens/Welcome.jsx`.

  Every other screen stays approved even with the flag. The theme class sits on the preview frame,
  so sheets opened from a themed screen are themed too.
- **Styles.** Everything is in two files, and every rule is scoped to `.theme-tiimo`:
  - `src/design-system/styles/theme-tiimo.css`: the component layer;
  - `src/flows/theme-tiimo.css`: screen canvas.

  The Welcome stickers live in `src/prototype/styles/screens.css`.
- **Shared components.** These gained one optional prop each and no behaviour change:
  - `Chip` and `FilterChips` options take a `mark`;
  - `ChipGroup` takes `marks` and a per-set `mark`;
  - `SharedInterests` items take a `mark`;
  - `MatchCelebration` takes `marks`;
  - `ActivityCard` takes `categoryMark`.

  A mark (`{ emoji, tone }`) renders only as `data-emoji` and `data-tone` attributes, which nothing
  in the approved design reads. The data lives in `src/flows/data.js`: `INTEREST_MARKS`, the
  interest-set marks, and `ACTIVITY_CATEGORIES[].mark`.
- **Theme strategy.** The theme reassigns two semantic tokens inside its scope
  (`--color-surface-page` → canvas, `--color-surface-soft` → warm field). This retints every page
  background and quiet fill at once, with no duplicated component CSS. Photo placeholders are pinned
  back to their neutral greys.

## Tokens (`tokens/numaya.tokens.json`)

All new tokens are namespaced `tiimo` and are unused outside the theme. The existing pinned
palettes are untouched (purple tints, the Meetup accents, the retired-pink guard).

| Token | Value | Role |
|---|---|---|
| `color.tiimo.canvas` | `#faf8fc` (lilac 25) | Page canvas of themed screens and sheets |
| `color.tiimo.field` | `#f2efeb` (stone 100) | Fields, quiet controls, disabled send |
| `color.tiimo.{peach,lilac,mint,sky,butter}-tint` | `#fde8dc`, `#e9e4fb` (purple 150), `#ddf1e5`, `#e1e9fb`, `#fbf0c9` | One pastel per category |
| `color.tiimo.{…}-ink` | `#94461f`, `#4f4296` (purple 800), `#2b6646`, `#33509a`, `#6e5200` | Text on its tint: 5.63, 6.64, 5.75, 6.26 and 6.41:1 |
| `shadow.tiimo-card` | `0 1px 2px / .03, 0 4px 18px -6px / .09` | Borderless white cards on the canvas |
| `shadow.tiimo-float` | `0 2px 4px / .04, 0 10px 28px -10px / .18` | Corner buttons, tab bar, white secondary pills |
| `tiimo.radius-item` / `-feature` | 16 / 24 px | Item cards (rows, options, fields) / feature cards (profile sections, activity cards, tiles) |
| `tiimo.emoji-size` / `-radius` | 32 px / 10 px | Reserved for emoji holders; not used by the 12 screens |

## Colour rules

| Colour | Used for | Never used for |
|---|---|---|
| Purple (`brand`) | Primary actions, selection of filters, tabs and options, progress, send, confirmations | Category coding |
| Lilac | The Culture category, your message bubbles, the active tab pill, the prompt tile | — |
| Peach | Food and nights in, food activities, games | Warnings or errors |
| Mint | Out and about, outdoors | Success states (those keep the success tokens) |
| Sky | Sport | Links |
| Butter | "New" and "Your move" tags, arts | Text (its ink is used instead) |
| Stone (field) | Text fields, disabled send, quiet fills | Cards |
| Canvas | Page and sheet backgrounds | Cards (cards stay white) |

## Components

| Component | Approved design | Experiment | Decision |
|---|---|---|---|
| Page | White, with lavender only on some tab roots | Lilac-white canvas everywhere in the theme | Refine via token reassignment |
| Profile sections, list groups, activity cards | White, hairline, xs shadow, 24 px | White, **no hairline**, diffuse card shadow, 24 px | Refine (variant) |
| Option cards (radios, checkboxes) | White pill with a hairline | White **16 px item card**, no hairline, card shadow; selected keeps the purple ring | Refine (variant) |
| Fields | Cool grey fill, 16 px | Warm stone fill, 16 px | Refine via token |
| Photo slots | White "add" slots with a hairline | **Dashed** "add" slots with a white plus disc; filled slots unchanged | Refine (variant) |
| Interest set label | Muted caption | **Tinted capsule**: category emoji plus uppercase tracked micro label | New treatment on the existing element |
| Interest chip | White pill; selected solid purple | White pill with **emoji**; selected = **category tint + ink ring + minus glyph** | New treatment |
| Shared interests and match chips | Lavender | **Category tint + emoji** | New treatment |
| Activity category | Quiet caption | **Tinted tag + emoji** | New treatment |
| Filter chips | White pill; selected purple with a check | Unchanged; adds the category emoji | Reuse + mark |
| Secondary button | Grey fill | **White pill with float shadow** | Refine (variant) |
| Tab bar | Translucent white, grey active pill | Opaque white with float shadow; **lilac** active pill | Refine (variant) |
| Inbox rows | Plain rows | **Separate white item cards**, 8 px apart | Refine (variant) |
| Bubbles | Yours solid purple with white text; theirs grey | Yours **lilac tile with deep-purple text**; theirs **white, lifted** | Refine (variant) |
| Tags ("New", "Your move") | Lavender or grey | **Butter** tags | Refine (variant) |
| Sheets | White panel | **Canvas panel**, so the white groups inside read as cards | Refine (variant) |
| Match moment | Plain | Static **confetti scatter** in the margins around the heading (CSS only) | New decoration |
| Welcome hero | Empty reserved slot | Slot kept; **four tinted interest stickers** (decorative) | New decoration |
| Typography | Fraunces + Inter | Unchanged (see the reference analysis, section 2) | Reuse |
| Icons | Material Symbols | Unchanged; emoji only for content | Reuse |

## Candidates for promotion to the main design system

If the team adopts the direction, these could be promoted without changing component architecture:

1. **Category tones with inks**, and `mark` on chips and tags. This is the strongest idea: it gives
   interests and activities a recognisable identity, and it is data-driven.
2. **Borderless white cards on a tinted canvas** (`shadow.tiimo-card`).
3. **Dashed "add" placeholders**: a clear, cheap affordance.
4. **White floating secondary buttons**: clearer than grey fills on a tinted canvas.

To promote these, move the theme rules into the base styles and delete the `.theme-tiimo` scope. The
tokens can then lose their `tiimo` prefix.

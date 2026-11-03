# V16 tokens

**Source:** `tokens/numaya.tokens.json`.
- `primitive.color.wth.*` holds the raw values.
- `primitive.font.family.hanken-grotesk` is the heading face.
- `component.wth.*` holds the roles that `theme-wth.css` reads as `--wth-*`.

**Generation:** `npm run tokens` generates `src/design-system/tokens.{css,js}` (371 tokens). V16 adds
`wth` tokens only; no existing token changed.

**Provenance labels:**

| Label | Meaning |
|---|---|
| **sampled** | read from the Mobbin previews (299 × 678 JPEGs), so approximate (±2 per channel) |
| **derived** | a sampled value adjusted for contrast, with the reason given |

## Colour

| Role (`--wth-*`) | Primitive | Value | Provenance | Use |
|---|---|---|---|---|
| `canvas` | `canvas` | `#F4F3F1` | sampled (#F4F3F1–#F6F5F3, four screens) | page background |
| `surface` | `white` | `#FFFFFF` | sampled | cards, rows, sheets, fields, idle chips |
| `track` | `track` | `#E4E4E6` | sampled | switch off, slider track, photo placeholders, grabber |
| `track-deep` | `track-deep` | `#D6D4D0` | derived: the track vanished on canvas-tone groups in sheets (1.15:1); this keeps V11's 1.32:1 | slider track inside sheets |
| `line` | `line` | `#E7E7E7` | sampled | separators inside cards, chip edges |
| `edge` | `edge` | `#8E8A85` | derived: the reference's light grey border, darkened to 3.43:1 | fields, switch-off outline, icon buttons |
| `ink` / `text` | `ink` | `#0D0D0D` | sampled (#0B0B0B–#0D0D0D) | primary buttons, headings, radios, checkboxes, current tab |
| `on-ink` / `on-accent` | `white` | `#FFFFFF` | | text on ink and on blue |
| `text-body` | `grey-700` | `#4A4A4A` | sampled | row labels, body copy |
| `text-muted` | `grey-600` | `#6D6C6A` | sampled | captions, eyebrows, idle tabs |
| `accent` | `blue` | `#4F65CB` | sampled (three screens) | SuperSwipe, my messages, slider fill, focus ring, verified mark, row icons |
| `accent-text` | `blue-deep` | `#3D50B0` | derived: the blue is 4.36:1 on the tint | text and initials on the tint |
| `accent-tint` | `blue-tint` | `#E6EBFF` | sampled (#E4EAFF–#EBF3FF) | selected filter, selected chip, avatars, info cards, the match scallop |
| `positive` | `green` | `#3C7D40` | sampled | switch on |
| `danger` | `red` | `#CC3034` | sampled | destructive buttons, unread counts, notification dots |
| `disabled` | `disabled` | `#C4C1BC` | sampled | disabled button fill |
| `disabled-text` | `disabled-text` | `#6D6C6A` | derived: sampled #9E9B96 was 1.6:1 | disabled button label |

**Retired in V16:** Numaya's purple `#7262C7` appears nowhere on themed screens; the E2E suite checks
that no computed colour falls in the 238–320° hue band. V11 and the production default keep it.

## Contrast (computed, WCAG 2.x)

| Pairing | Ratio | Requirement |
|---|---|---|
| ink on white / canvas | 19.44 / 17.53:1 | text 4.5 |
| ink on blue-tint | 16.37:1 | text 4.5 |
| grey-700 on white / canvas | 8.86 / 7.99:1 | text 4.5 |
| grey-600 on white / canvas | 5.25 / 4.73:1 | text 4.5 |
| white on blue | 5.18:1 | text 4.5 |
| blue-deep on blue-tint | 5.95:1 | text 4.5 |
| blue on blue-tint | 4.36:1 | **not used for text** |
| white on green / red | 5.00 / 5.20:1 | text 4.5 |
| edge on white / canvas | 3.43 / 3.09:1 | non-text 3 |
| green (switch on) on white | 5.00:1 | non-text 3 |
| disabled-text on disabled | 2.92:1 | exempt (disabled control) |
| track on white | 1.27:1 | decorative; switch off carries the 3.43:1 edge |

## Type

| Role | Value | Notes |
|---|---|---|
| `font-heading` | Hanken Grotesk Variable (OFL, self-hosted) | provisional: the reference's face is unidentified; chosen from four candidates ([trial](../research/font-trial/candidates.png)) |
| `font-text` | Inter Variable | unchanged from V11 |
| `font-wordmark` | Fraunces Variable | the Numaya logotype only |

**Weights:**
- 700: titles, names, the match title;
- 600: section and sheet titles;
- 500: prompt answers.

**Tracking:** zero, except on the uppercase labels:
- navigation titles: 12px, weight 700, 0.14em;
- eyebrows: 11px, weight 600, 0.08em.

**Sizes and line-heights:** V11's, unchanged.

## Shape and depth

| Token | Value | Use |
|---|---|---|
| `radius-button` | 12px | buttons, fields |
| `radius-card` | 16px | cards, groups, the match queue |
| `radius-check` | 4px | checkboxes, tags |
| `radius-pill` | 999px | tabs, chips, small buttons, icon buttons, switches, avatars |
| `border` | 1px | edges, drawn as inset box-shadows so no box changes |
| `focus` | 2px | focus ring in `accent` |
| `shadow-sheet` | `0 -8px 24px -12px rgb(13 13 13 / 0.18)` | sheets only; cards have no shadow |

# Ente design system: token mapping

These tokens come from the Ente Figma file `22AeTw6QiPj2fNYHLhC7MK`, adapted for Numaya.

- **Where the values live:** `apps/numaya_mobile/lib/core/design_system/tokens/monochrome_tokens.dart`.
- **Why the old names stay:** the file keeps its monochrome-era class and field names, so no widget needed renaming. Only the values changed.
- **Consumers:** the widgets read these values through `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii` and `AppSizes`.

Values marked **NX** are Numaya extensions. They are not in Ente's file, and the reason for each is given in its row.

## Colour (Figma node 10871:4421)

| Ente variable | Ente value | Numaya token | Value used | Note |
|---|---|---|---|---|
| background/base | #F4F4F4 | `canvas` | #F4F4F4 | |
| fill/light | #FFFFFF | `surface` | #FFFFFF | |
| fill/dark | #EAEAEA | `fill`, `field`, `disabled` | #EAEAEA | |
| fill/darker | #DEDEDE | `fillStrong`, `fieldPressed`; others' chat bubble | #DEDEDE | |
| fill/darkest | #D2D2D2 | `lineStrong` | #D2D2D2 | |
| stroke/dark | #E0E0E0 | `line` | #E0E0E0 | |
| stroke/faint | #EBEBEB | `divider` | #EBEBEB | |
| text/base | #000000 | `ink` | #000000 | |
| text/dark | #1A1A1A | `text2` | #1A1A1A | |
| text/light | #666666 | `muted` | #666666 | 5.74:1 on white, 5.27:1 on the canvas |
| text/lighter | #969696 | `outline`, `disabledText` | **#8A8A8A** | Ente's value is 2.96:1 on white, short of the 3:1 that WCAG 1.4.11 asks of control edges. Darkened to 3.45:1 |
| text/lightest | #D6D6D6 | (not used for text) | | 1.4:1 on white, too faint even for disabled labels. Disabled labels use #8A8A8A |
| **primary/default** (green #08C225) | | `brand` | **#7262C7** | The explicit override: Numaya purple takes Ente's primary role (constructive action, selected Tag Chip, switch on, own chat bubble, checkbox on) |
| primary/dark | #069D1E | `brandPressed` | #5F50B8 | |
| primary/light | #DDEEDF | `brandSubtle` | #F1EFF9 | |
| primary/stroke | #BAECC2 | `brandLine` | #CBC4EC | |
| (no Ente equivalent) | | `brandText` | #5B4BB0 | NX: purple text at 6.8:1. Plain purple on the canvas is 4.46:1 |
| primary/darker | #057C18 | `success` | **#036614** | Green keeps its meaning as success, not purple. Darkened one step so it reaches 4.5:1 on its own tint |
| primary/light | #DDEEDF | `successSubtle` | #DDEEDF | |
| warning/darker | #C52E2E | `danger` | #C52E2E | warning/default (#F63A3A) gives 3.6:1 under white text, so the darker step is used for the Critical button |
| warning/light | #FAEBEB | `dangerSubtle` | #FAEBEB | |
| caution/light | #FAF4EB | `warningSubtle` | #FAF4EB | caution/default (#F08A1E) is too light for text, so caution text stays #8A5A00 |
| info/dark | #0E5FD9 | `info` | #0E5FD9 | info/default is 4.4:1 as text, so the darker step is used |
| info/light | #E7EFFA | `infoSubtle` | #E7EFFA | |
| special/scrim | #00000066 | `scrim` | #00000066 | |
| background-reverse | #161616 | (`ink`) | #000000 | The selected Filter Chip fill |
| (Numaya) | | `social`, `socialSubtle` | coral, unchanged | NX: heart and match moments |

## Type (Figma node 10854:4420)

The font families are swapped for Numaya's own:

- Ente's display face, **Outfit**, becomes **Plus Jakarta Sans**. It is used for Display-1/2/3, page titles and section headings.
- Ente's text face, **Inter**, becomes **Figtree**. It is used for everything else.

The sizes, line heights and weights are Ente's.

| Ente style | Size/line, weight | Numaya roles |
|---|---|---|
| Display-1 | 32/40, 600 | `hero` |
| Display-2 | 24/32, 600 | `pageTitle`, `flowTitle`, `headline` (Header v2 title) |
| Display-3 | 20/28, 600 | `section`, `emptyTitle` |
| H1 | 20/28, 600 | `sheetTitle` (Bottom Sheet Header), `promptAnswer` |
| H2 | 18/24, 600 | `card` |
| Large | 16/20, 600 | `headerCaps` |
| Body | 14/20, 500 | `body`, `bodySm`, `row`, `input`, `button`, `buttonSm`, `label`, `fieldLabel`, `metricUnit` |
| Mini | 12/16, 500 | `pill`, `chip`, `caption`, `micro`; `labelCaps` at 600 |
| Tiny | 10/12, 500 | not used. Nothing important is set this small |

The Welcome title (36 to 44) and the metric figure (40/44) stay as Numaya exceptions (NX).

## Spacing (11107:37840) and radius (11112:4508)

**Spacing.** Ente's scale is 2, 4, 8, 12, 16, 20 and 24. The existing 4pt scale already contains these steps.

| Role | Value | Ente source |
|---|---|---|
| Screen gutter | 16 | Header (v2) sits at x = 16 |
| Section gap | 24 | spacing/xxl |
| Card padding | 16 | spacing/lg |
| Menu Item padding | 12 | spacing/md |
| Gap between rows | 8 | spacing/sm |

**Radius.** Ente's radii are sm 4, md 12, lg 16 and xl 20.

| Radius | Used for |
|---|---|
| 12 (md) | icon buttons, icon slots, tags |
| 16 (lg) | fields, tiles, Tag Chip |
| 20 (xl) | buttons, cards, menu items, the tab bar, chat bubbles |
| 16 (photo) | the Discover photo, so it nests inside its 24pt hero card with an 8pt inset (24 − 8) |

Three values go past Ente's scale:

- **24 (NX):** the hero card and the sheet top. Larger surfaces need a larger corner, and 24 is also the Filter Chip radius.
- **5:** the checkbox. This is radius/sm (4) scaled with the 20pt mark.
- **Pill:** chips and avatars only.

## Sizes

| Component | Ente | Numaya |
|---|---|---|
| Button Large | 52 tall, 24 side insets, radius 20 | same |
| Button Small | — | 40 (kept) |
| Icon Button | 38 (18 glyph + 8 + 2 padding), radius 12 | 38 visual inside a 44pt hit area (`Pressable.minSize`). The glyph is 20 (NX), because Lucide's 2px stroke at 18 read as spindly |
| Text Input | 52, radius 16, 16 insets | same |
| Menu Item | 60, 36 leading slot, 12 padding | same; the trailing chevron is 24 |
| Filter Chip | 40, pill | same |
| Tag Chip | 44, radius 16, 20 insets | same |
| Toggle Switch | 31 × 18 | **46 × 27 (NX, 1.5×)**: at 31 × 18 the knob is under 16pt on a phone |
| Checkbox / Radio | 16 | **20 (NX, 1.25×)** |
| Nav Bar | 62 tall, radius 20, 15 insets, 38 tiles | same; 5 tiles instead of Ente's 4 |

## Elevation

Ente is flat. Only the Nav Bar casts a shadow: offset 0 4, blur 8.75, black at 25%. That shadow is now `floating`. Everything else uses either surface contrast (white on #F4F4F4) or no elevation.

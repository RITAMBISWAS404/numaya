# Design contract (replacement V8, premium candidate)

Starts from the selected V7's measured tokens: `monochrome_tokens.dart`, `app_typography.dart` and `app_layout.dart`. It also uses the Ente reference nodes in [REFERENCE_LOG.md](REFERENCE_LOG.md). Changes are shared roles, not per-screen exceptions.

## Type (T-01)

| Role | Family | Size/line | Weight | Purpose |
|---|---|---|---|---|
| `hero` | Plus Jakarta Sans | 32/40 | 700 | Names on photos, Welcome |
| `largeTitle` | Plus Jakarta Sans | 30/36 | 700 | Tab-root title, collapsing into the bar |
| `pageTitle`, `flowTitle`, `headline` | Plus Jakarta Sans | 24/32 | 700 | Tab titles, onboarding questions, results |
| `section`, `card` | Plus Jakarta Sans | 18/24 | 600 | Section and card headings |
| `emptyTitle` | Plus Jakarta Sans | 20/28 | 600 | Empty and waiting states |
| `body`, `row`, `input` | Figtree | 15/20 | 500 | Reading text, rows, fields |
| `button` | Figtree | 15/20 | 600 | Actions |
| `caption`, `micro` | Figtree | 12/16 | 500 | Metadata, times |

These are Ente's text-style sizes (Display-1 32/40, Display-2 24/32, H1 20/28, H2 18/24, Body 14/20, Mini 12/16, read live from `10854:4420`), with the approved 15pt body.

**Emphasis:** a composition uses at most three levels, for example a card heading (600), a value (700), and metadata (500 in a muted colour).

**Text scale:** no global clamping.

**Comparison T-02 (not the default):** Bree Serif 400 for `largeTitle` 32/38, `flowTitle` 28/34 and `emptyTitle` 22/28, with Google Sans for every other role. It is compiled only with `NUMAYA_EDITORIAL_TYPE=true`.

## Layout (L-01)

- **Spacing:** page gutter 20, card padding 16, section gap 32, related items 12 apart.
- **Gaps:** inside a group, gaps stay tighter than the gaps between groups (proximity).
- **Columns:** one primary column throughout. Paired buttons sit side by side only when both labels fit, and stack at narrow widths or large text (`NumayaButtonGroup`).
- **Safe areas:** the keyboard lifts the composer, and the floating navigation keeps its clearance.

## Geometry (G-01)

| Element | Radius |
|---|---|
| Buttons, sheets, dialogs, cards | 20 |
| Hero cards | 24 |
| Fields, tiles, photos (the hero's 24 minus its 8 inset) | 16 |
| Tags | 12 |
| Chips, segments, navigation | Pill |
| Nested clips | Container radius minus the inset |

## Card families (K-01)

| Family | Job | Anatomy |
|---|---|---|
| Information | Report one value | Heading, value, optional visual, metadata |
| Status (`StatusBanner`) | Tell what is happening | Mark, title, one line; one action at most |
| Action list (`ListGroup`) | Navigate | Rows of icon, label, detail and chevron in one white card |
| Profile / media | Show a person | Photo first, a concise identity on the adaptive scrim, actions on the photo edge |
| Illustration / empty | Explain an empty or waiting state | Art, title, at most two lines, one solid action |

**Rules for every family:**
- Only the roles a card needs.
- No unrelated action cluster inside a data card.
- A single relevant action may stay inside its card (the setup card).

## Controls and colour (C-03, C-04, C-05)

| Control | Treatment |
|---|---|
| Primary | Solid brand purple `#7262C7`, white label (4.90:1) |
| Secondary, quiet | Transparent with a 1pt ink edge at 20%; the label carries the contrast |
| Brand | Purple label with a 1pt purple edge at 45% |
| Disabled | Filled grey, so it is distinct from secondary |
| Destructive | Red text; a solid red fill only for the final confirmation |

**Selection:** selected chips and segments keep their filled surfaces, which are functional. The off toggle stays borderless, as in V7.

**Dividers:**
- Settings-style grouped cards: no hairlines, as in Ente `12099:96480`.
- Messages list: a near-full hairline `#EBEBEB`, with the gutter at both ends.

**Icons:**
- Tabler only. Outline in rows; filled for the selected state or small marks.
- No decorative backplate. Hit regions stay at least 44pt even with no backplate.
- Safety colours are semantic only.

## Photos (C-07)

- **Gradient:** a smooth bottom-to-clear gradient behind the name, only in the text band.
- **Strength:** the photo's lower 40% is measured once (decoded at 12×16, cached). The edge then runs from 24% on dark photos to 52% on white photos.
- **Text shadows:** the name keeps two soft shadows.
- **No hard box:** no hard name rectangle.
- **Comparison:** `r8-photo-scrim` O keeps V7's fixed 24%.

## Microcopy

- **Length:** short supporting lines. Safety, permission, cost and error text are never clipped to fit.
- **Case:** sentence case. No uppercase metadata.
- **States:** empty, pending, failed and completed each have their own copy.

## Motion (M-01)

| Role | Timing |
|---|---|
| Press, on touch-down | 120ms |
| State change | 200ms |
| Route or sheet in | 280ms, emphasized decelerate |
| Sheet out | 200ms |
| Progress | 560ms |
| Celebration | 560ms, rare |

Reduced motion sets every duration to zero, through `AppMotion.duration`. Nothing new was added: no shared-element transitions and no per-card entrances.

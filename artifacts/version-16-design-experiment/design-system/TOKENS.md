# V16 tokens

Source: `tokens/numaya.tokens.json`, compiled by `npm run tokens` into `src/design-system/tokens.{css,js}` (437 tokens;
V16 adds 112, of which 51 came with the final polish: every type role and component size the stylesheet uses; see
`final-polish/PASS_1_DESIGN_SYSTEM.md`). Generated files are never edited. Components only read the semantic and component tokens. Inside
`.theme-tiimo.theme-withings` the shared roles (`--color-surface`, `--font-text`, `--type-*`, …) are re-pointed at
these, so every existing component picks them up.

## Colour: `--color-withings-*` (primitives `--p-color-withings-*`)

| Token | HEX | Use | Contrast |
|---|---|---|---|
| `canvas` | `#F5F4F1` | The page behind every screen | — |
| `surface` | `#FFFFFF` | Cards, grouped rows, fields, sheets, modal headers, tab bar | — |
| `fill` | `#EAE9E6` | Segmented track, switch-off track, chips on white cards, slider rail | — |
| `border` | `#E6E5E2` | Dividers in cards, header and tab-bar edges, outlined info boxes, search field | decorative |
| `border-strong` | `#D3D0CC` | Dashed empty photo slots, sheet grabber, readiness track | decorative |
| `photo` | `#DFDDD9` | Photo placeholders, missing activity images | — |
| `outline` | `#6D6C6A` | Text-field outline | 5.25:1 on white |
| `control` | `#8A8784` | Unselected radio and checkbox rings | 3.57:1 on white (non-text ≥ 3:1) |
| `ink` | `#121212` | Text, headings, primary buttons, selected radio and option, active tab | 17.0:1 on stone |
| `ink-foreground` | `#FFFFFF` | Text on ink | 18.7:1 |
| `text-secondary` | `#5E5C59` | Subtitles, descriptions, helper text | 6.06:1 stone, 6.66:1 white |
| `text-muted` | `#6B6966` | Metadata, timestamps, inactive tab labels | 4.98:1 stone, 5.47:1 white, 4.51:1 fill |
| `disabled` / `disabled-foreground` | `#D6D2CE` / `#77736F` | Disabled buttons | exempt |
| `accent` | `#5066CC` | Your bubbles, SuperSwipe, checked box, slider interval, unread count, focus, the mark | white on it 5.11:1 |
| `accent-hover` | `#4357B8` | Hover on solid blue | — |
| `accent-tint` | `#E4EBFC` | Selected tabs, interests and filters; toast; tint buttons; prompt-mark holder | — |
| `accent-on-tint` | `#3E4A8F` | Text and icons on the tint, links | 6.81:1 on tint, 8.14:1 white |
| `identity` | `#203068` | Initial avatars | white on it 12.5:1 |
| `positive` | `#3C783C` | Switch on | white thumb 5.32:1 |
| `negative` | `#CF3336` | Destructive buttons, notification dots | white on it 5.02:1 |
| `mark-yellow` / `mark-lavender` / `mark-pink` | `#FCEAB7` / `#E4C9ED` / `#FCCCC4` | Round holders behind interest-set emoji only | never text |

## Type

| Token / role | Value |
|---|---|
| `--font-withings` (primitive `hanken`) | "Hanken Grotesk Variable" (SIL OFL, `@fontsource-variable/hanken-grotesk`) |
| Page title (tab roots: `.topbar__large-title`, `.screen-header__title` on roots) | 30/36, 700, −0.02em |
| Flow heading (onboarding steps) | 26/32, 500, −0.015em |
| Profile name (`--type-hero`) | 32/38, 700 |
| Match title | 32+ (V11's clamp), 700 |
| Section heading (`.fl-section-title`) | 22/28, 500 |
| Group heading (`.list-group__title`) | 22/28, 500, ink |
| Sheet title | 20/26, 500 |
| Modal header title (`.topbar__title`) | 12.5/16, 700, capitals, 0.16em |
| Field label, choice legend | 11.5/14, 700, capitals, 0.06em |
| Prompt answer | V11 sizes, 600, −0.015em |
| Card title in a profile | 15/20, 500, ink |
| Body | 15.5/22, 400 |
| Row label | 16/22, 400 |
| Input | 16/22, 400 |
| Button | 16, 600; small 14, 500 |
| Caption | 13.5/18 |
| Tab label | 11/13, 500 (active 600) |

## Geometry: `--withings-*`

| Token | Value | Use |
|---|---|---|
| `radius-tag` | 6 | Status labels, checkboxes, photo order badge |
| `radius-field` | 8 | Text fields, text areas |
| `radius-control` | 12 | Full-width buttons, chips, search, readiness score |
| `radius-card` | 14 | Cards, groups, prompts, info boxes, photo tiles and slots, bubbles, dialogs |
| `radius-photo` | 16 | Profile photographs, sheets |
| `radius-pill` | 999px | Small outlined buttons, view tabs, toast, counts |
| `button-height` | 50 | Full-width buttons |
| `field-height` | 54 | Text fields |
| `header-button` | 40 | Circular header buttons |
| `row-height` | 56 | Minimum grouped-row height |

## Elevation

| Token | Value | Use |
|---|---|---|
| `--shadow-withings-float` | `0 1px 2px rgb(18 18 18/.06), 0 4px 14px -4px rgb(18 18 18/.14)` | The SuperSwipe over a photo, the toast |
| `--shadow-withings-segment` | `0 1px 2px rgb(18 18 18/.08), 0 0 0 .5px rgb(18 18 18/.04)` | The selected segment |
| (V11) `--shadow-thumb` | — | Switch and slider thumbs |

Cards, groups and fields never take a shadow.

## Spacing

V11's 4 pt scale is unchanged: 16 pt screen gutter (measured 12 px ≈ 16 pt), 12 pt between cards, 28 pt between
sections, 16 pt card padding.

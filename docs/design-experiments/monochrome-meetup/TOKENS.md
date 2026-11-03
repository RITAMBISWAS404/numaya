# Monochrome Meetup tokens

**Source:** `apps/numaya_mobile/lib/core/design_system/tokens/monochrome_tokens.dart`, re-pointed through
`AppColors`, `AppTypography` and `AppLayout`.

**Change process:**
1. Change a value in the token file and in this document together.
2. Run `flutter test test/unit/foundation_test.dart`, which pins the roles and their contrast.

## Colour
**Neutrals:** a cool grey ramp, leaning very slightly violet so the purple sits in it naturally. No
warm stone.

| Token (`MonoColors`) | Value | Role (`AppColors`) | Use |
|---|---|---|---|
| `canvas` | `#F4F4F6` | `canvas`, `surfacePage` | page behind every screen; tab-bar surround |
| `surface` | `#FFFFFF` | `surface` | cards, rows, sheets, fields, bars |
| `fill` | `#ECECF0` | `fill` | idle pills on cards, segmented track, switch-off track, tiles, illustration slots, active tab capsule |
| `fillStrong` | `#E2E2E7` | `photo`, `identity` | photo placeholders, initials avatars |
| `line` | `#E4E4E9` | `border` | hairlines: dividers, card and bar edges |
| `lineStrong` | `#C7C7CE` | `borderStrong` | dashed add-slots, slot dashes, grabber (decorative) |
| `outline` | `#8B8B94` | `outline`, `control` | fields, unselected radios and checkboxes, switch-off edge |
| `ink` | `#18181B` | `ink`, `textPrimary` | text, headings, strong icons |
| `text2` | `#4A4A53` | `textSecondary`, `onIdentity` | body copy, row details, initials |
| `muted` | `#696972` | `textMuted` | captions, metadata, eyebrows, idle tabs |
| `disabled` / `disabledText` | `#E4E4E9` / `#8A8A93` | `disabled*` | disabled fill and label |
| `brand` | **`#7262C7`** | `accent`, `brand` | primary actions, selected pills, segments, radios, checkboxes, switch on, progress, active tab capsule text |
| `brandPressed` | `#5F50B8` | `accentHover` | pressed or hovered primary |
| `brandText` | `#5B4BB0` | `accentOnTint`, `textBrand` | purple **text and icons**: links, active tab, eyebrows, info icons, badges |
| `brandSubtle` | `#F1EFF9` | `accentTint` | info cards, badges, SuperSwipe, the match portrait |
| `brandLine` | `#CBC4EC` | `accentLine` | edge on brand-subtle controls |
| `success` / `danger` / `warning` | `#2F7D4F` / `#C8383B` / `#8A5A00` | `positive`, `negative`, `warning` | state only; red also for notification dots |
| `*Subtle` | `#E8F3EC` / `#FBEDED` / `#FBF3E2` | `successTint`, `dangerTint`, `warningTint` | state banners |
| `scrim` | ink at 45% | `scrim` | modal barrier |
| `photoPanel` | ink at 72% | `photoPanel` | solid panel behind text on photos (replaces gradients) |
| `photoButton` | white at 90% | `photoButton` | buttons over photos |

**Brand purple:** `#7262C7` is the canonical `purple.600` in `tokens/numaya.tokens.json`, and the
repository's `CLAUDE.md` names it. **It is not changed here.**

### Contrast (computed, WCAG 2.x relative luminance)
| Foreground | White | Canvas | Fill | Brand subtle | Requirement |
|---|---|---|---|---|---|
| ink `#18181B` | 17.72 | 16.13 | 15.04 | 15.57 | 4.5 |
| text2 `#4A4A53` | 8.77 | 7.98 | 7.44 | 7.70 | 4.5 |
| muted `#696972` | 5.43 | 4.95 | 4.61 | 4.78 | 4.5 |
| brandText `#5B4BB0` | 6.82 | 6.21 | 5.79 | 6.00 | 4.5 |
| brand `#7262C7` as text | 4.90 | **4.46** | 4.16 | 4.30 | not used as text on grey |
| outline `#8B8B94` (boundary) | 3.38 | 3.07 | — | — | 3.0 (non-text) |
| disabledText `#8A8A93` | 3.42 | 3.11 | — | — | exempt (disabled) |

| On a fill | Ratio |
|---|---|
| White on brand | 4.90 |
| White on danger | 5.14 |
| White on success | 5.04 |
| White on ink | 17.72 |
| White on `photoPanel` over a white photo (worst case) | ≈ 7.2 (asserted in tests) |

## Type
Figtree, variable (weights 300–900), SIL OFL 1.1. See
[TYPOGRAPHY_GUIDELINES.md](TYPOGRAPHY_GUIDELINES.md).

| Role | Size / line | Weight | Tracking |
|---|---|---|---|
| `hero` (profile names) | 34/40 (32/38 on the photo card) | 700 | −0.02em |
| `pageTitle` | 30/36 | 700 | −0.02em |
| `flowTitle` | 28/34 | 700 | −0.015em |
| `headline` | 24/30 | 700 | −0.01em |
| `section`, `sheetTitle`, `emptyTitle` | 20/26 | 700 | −0.01em |
| `promptAnswer` | 20/27 | 600 | −0.01em |
| `card` | 17/22 | 700 | −0.005em |
| `headerCaps` (modal title, now sentence case) | 17/22 | 600 | −0.005em |
| `row` | 16/22 | 500 | 0 |
| `body`, `input` | 16/24, 16/22 | 400 | 0 |
| `button` / `buttonSm` | 16/20 / 14/18 | 600 | 0 |
| `bodySm` | 14/20 | 400 | 0 |
| `label`, `fieldLabel` | 14/18 | 500 / 600 | 0 |
| `caption` | 13/18 | 400 | 0 |
| `micro` | 12/16 | 500 | 0 |
| `labelCaps` (eyebrows, uppercase) | 12/16 | 600 | +0.06em |
| `metric` / `metricUnit` | 32/36 tabular / 15/20 | 700 / 500 | −0.02em / 0 |

## Spacing
4pt scale (`AppSpacing.s1`–`s12`, unchanged) plus roles:

| Role | Value | Was |
|---|---|---|
| `screenGutter` | **20** | 16 |
| `sectionGap` | **32** | 28 |
| `cardPadding` | **18** | 16 |
| `itemGap` | 12 | |
| `fieldGap` | 20 | |
| `headingGap` | 12 | |

## Shape
| Radius | Value | Use |
|---|---|---|
| `tag` | 8 | badges, small tags, checkboxes |
| `field` / `control` | 14 | text fields, code cells, segmented items in cards |
| `iconButton` | 14 | rounded-square header and card buttons (42pt) |
| `tile` | 16 | small tiles, swatches |
| `card` | 20 | cards, grouped rows, info cards, metric tiles, bubbles |
| `photo` (image) | 20 | person photos, event covers |
| `dialog` | 24 | dialogs |
| `sheet` | 28 | bottom sheets (top corners) |
| `pill` | 999 | buttons, filters, view tabs, chips, tab bar, switch |

## Elevation
| Token | Definition | Use |
|---|---|---|
| `none` | | cards, rows, fields (default) |
| `subtle` | 0 1 2 / 4%, 0 4 12 / 3% | a card on white, rarely |
| `floating` | 0 1 4 / 6%, 0 8 24 / 8% | tab bar, RSVP bar, toast, photo buttons |
| `segment`, `thumb` | small single shadows | selected segment, slider and switch thumbs |

All shadows are ink-based and soft: no dark or thick shadows, and none on chips, toggles or ordinary
buttons.

## Sizes
| Size | Value |
|---|---|
| Button | 52 (small 38) |
| Field | 54 |
| Row | 56 |
| Icon button | 42 (44 hit area) |
| Search | 48 |
| Segmented | 44 |
| Tab bar | 64, floating, inset 12 |

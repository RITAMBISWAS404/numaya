# Foundations: Ente scales and Numaya adaptations (alignment V3)

Read from Figma variables (`get_variable_defs` on `4809:8074` and `2207:41577`) and the rules page
`26553:8327`. Flutter tokens: `lib/core/design_system/tokens/monochrome_tokens.dart`.

## Scales (Ente → Numaya)
| Role | Ente | Numaya | Note |
|---|---|---|---|
| Spacing | 2xs 2, xs 4, sm 8, md 12, lg 16, xl 20, xxl 24 | `AppSpacing.s1..s6` = 4/8/12/16/20/24 | Same scale |
| Sheet padding / content gap | xl 20 / lg 16 | 20 / 16 | Same |
| Action group gap | md 12 (stacked sheet buttons) | `NumayaButtonGroup.gap` 12 | New shared value |
| Radius | sm 4, md 12, lg 16, xl 20; buttons and sheets xl | buttons 20, cards 20, **sheets 20** (was 24), hero card 24 | Hero 24 kept (owner's concentric Discover photo selection) |
| Page / card / fill | #F4F4F4 / #FFFFFF / #EAEAEA | same | |
| Secondary text | #666666 | same | |
| Type | Inter; Body 14 Medium | Figtree body **15**, Plus Jakarta Sans headings | Owner override (H-08) |
| Icons | 8/12/18/24/36 | Tabler 16/18/20/24 | Owner override (Tabler) |
| Primary | green #08C225 | purple #7262C7 | Owner override |

## Semantic palette (owner anchors, 2026-11-08)
Anchors are exact. Derived roles mix the anchor with black (text, icon, solid) or white (subtle);
they are **derived**, not owner-supplied. Ratios: WCAG 2.x relative luminance, opaque sRGB.

| Role | Hex | Measured |
|---|---|---|
| Error anchor `errorBase` | **#EB2D2F** | 4.24 on white (dots, marks only) |
| Error text / solid `danger` | #C42326 | 5.81 white bg, 5.28 canvas, 5.02 tint; white text on it 5.81 |
| Error icon `dangerIcon` | #DB2A2C | 4.79 white, 4.14 tint |
| Error tint `dangerSubtle` | #FDEAEA | |
| Warning anchor `warningBase` | **#FF9B0F** | 2.11 on white → fill under **ink** (9.95), never white text |
| Warning text `warning` | #8F5608 | 6.00 white, 5.45 canvas, 5.56 tint |
| Warning icon `warningIcon` | #B86F0A | 3.95 white, 3.59 canvas, 3.66 tint |
| Warning tint `warningSubtle` | #FFF5E7 | |
| Success anchor `successBase` | **#0D9F61** | 3.42 on white (large marks only) |
| Success text `success` | #08774A | 5.60 white, 5.09 canvas, 4.99 tint |
| Success icon `successIcon` | #0C8F57 | 4.13 white, 3.68 tint |
| Success tint `successSubtle` | #E7F5EF | |

Intent mapping: destructive action and validation error → error; recoverable, pending action →
warning; completed, confirmed → success; selection and ordinary primary → brand purple; "full" is
a pending/warning state, not an error. Colour is never alone: banners pair a filled icon and a
title; badges pair a word (and an icon in the specimen). The 10pt notification dot uses the error
anchor. Verified by `test/widget/ente_alignment_test.dart` (EA-C01) and the specimen (qa/01–03).

**Logged, not changed:** switch off track #D6D6D6 (1.45:1 on white), owner decision SW-01.

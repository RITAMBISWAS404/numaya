# Numaya design rules, Ente refinement V4 (2026-11-08)

V4 overrides conflicting earlier visuals. Typography (15px body, Figtree, Plus Jakarta Sans headings),
purple identity and Tabler icons are unchanged. Source: Figma `22AeTw6QiPj2fNYHLhC7MK`, pages
`57:6281` and `12099:96447`. This is not pixel identity with Ente: the owner's neutral-surface and
gradient rules override Ente where they differ, and the differences are listed below.

## Surface
- Page: canvas `#F4F4F4`. Substantive related content: white card `#FFFFFF`. Titles, captions and
  scaffolding stay on the canvas.
- No nested white cards without a real group boundary.
- Icon backplates and secondary fills use neutral `fill #EAEAEA`, never a decorative tint.
- Allowed tints are functional only, listed in [TINT_AUDIT.md](TINT_AUDIT.md).

## Semantic colour
- Anchors `#EB2D2F`, `#FF9B0F`, `#0D9F61` stay palette values. White text never sits on them.
- Solid status badge roles: brand `#7262C7` with white, success `#08774A` with white, danger
  `#C42326` with white, warning `#FF9B0F` with black.
- An inline alert can stay a white card with a semantic icon and short label.
- Red, orange and green mean status or a critical action, never decoration.

## Real contrast values
Ratios are computed from the actual pairs and truncated, never rounded up.

| Pair | Foreground | Background | Ratio | Needed | Result |
|---|---|---|---|---|---|
| White on brand solid (primary action, brand badge) | #FFFFFF | #7262C7 | 4.89:1 | 4.5:1 | pass |
| White on success solid badge | #FFFFFF | #08774A | 5.60:1 | 4.5:1 | pass |
| White on danger solid badge | #FFFFFF | #C42326 | 5.80:1 | 4.5:1 | pass |
| Black on warning anchor badge | #000000 | #FF9B0F | 9.94:1 | 4.5:1 | pass |
| White on raw error anchor #EB2D2F (not used for text) | #FFFFFF | #EB2D2F | 4.24:1 | 4.5:1 | fails, so not used for this |
| White on raw warning anchor #FF9B0F (not used for text) | #FFFFFF | #FF9B0F | 2.11:1 | 4.5:1 | fails, so not used for this |
| White on raw success anchor #0D9F61 (not used for text) | #FFFFFF | #0D9F61 | 3.41:1 | 4.5:1 | fails, so not used for this |
| Black on white card | #000000 | #FFFFFF | 21.00:1 | 4.5:1 | pass |
| Secondary text #666666 on white card | #666666 | #FFFFFF | 5.74:1 | 4.5:1 | pass |
| Secondary text #666666 on canvas #F4F4F4 | #666666 | #F4F4F4 | 5.22:1 | 4.5:1 | pass |
| Brand text #5B4BB0 on white (links) | #5B4BB0 | #FFFFFF | 6.82:1 | 4.5:1 | pass |
| Brand text #5B4BB0 on neutral fill #EAEAEA | #5B4BB0 | #EAEAEA | 5.67:1 | 4.5:1 | pass |
| Supporting icon #8A8A8A on white (decorative beside a text label) | #8A8A8A | #FFFFFF | 3.45:1 | 3:1 | pass |
| White on photo glass, worst case over pure white (55% black) | #FFFFFF | #737373 | 4.74:1 | 4.5:1 | pass |
| White on high-contrast glass over pure white (80% black) | #FFFFFF | #333333 | 12.63:1 | 4.5:1 | pass |
| White on 10% gradient alone over pure white (why a backing exists) | #FFFFFF | #E6E6E6 | 1.24:1 | 4.5:1 | fails, so not used for this |

## Image overlays
- Pill on a photo: `PhotoPill` (`widgets/photo_overlays.dart`). Black at 55% (`0x8C000000`), blur
  sigma 10 clipped to the pill, white 12/16 semibold, minimum height 26. No purple or semantic pill
  over an image.
- Name over a photo: `PhotoLabel` holds the name on the same glass, because a gradient alone gives
  white text only 1.24:1 over a white area.
- Gradient: `PhotoScrim` starts at 10% black (`photoScrimEdge`) at the lower edge and fades to zero.
  The cap is under 25%. No solid panel. A widget test enforces both.
- High contrast: blur off, glass 80% black. Lists with several pills share one backdrop through
  `BackdropGroup` (Events feed, Likes grid).
- Interactive controls over a photo keep their tap target. The Compliment action stays a solid
  purple control because it is an action, approved earlier, not a label.

## Exceptions recorded against Ente
| Ente source | Ente value | Numaya V4 | Why |
|---|---|---|---|
| Memory card `6352:38350` | gradient to 72% black | 10%, plus a compact glass label | Owner cap under 25% |
| Badges `7435:15789` | tinted and light counters | solid accents, glass on photos | Owner neutral and solid direction |
| Text styles `7672:54672` | Inter, 14 body | Figtree and Plus Jakarta Sans, 15 body | Approved baseline H-08 |
| Icon set | Ente glyphs | Tabler | Approved earlier |

## Icons
- Use an icon when it adds category, action, state or navigation. Omit it beside obvious prose.
- Supporting icons `#8A8A8A`, 24 dp in fact rows. Tabler only for actions and safety. Emoji only on
  playful interests, as already approved.
- Known gap: the shared icon set has no accessibility glyph. Event accessibility rows use `info`
  (they used a misleading globe). Adding a wheelchair glyph needs a new shared web and Flutter icon entry.

## Spacing
- Card radius and insets follow the existing `AppRadii` and `AppSpacing`; V4 adds no new scale.
- Fact rows: 8 dp above and below. A row ending in a link drops the lower 8 dp, because the link's
  44 dp target already provides that space.

## Action hierarchy
- One primary per view: solid purple, white label, full width when anchored at the foot.
- Secondary: neutral fill. Critical: danger role, in confirm sheets only.
- Paired peers share width through `NumayaButtonGroup`.
- Primary actions must clear the floating tab bar. Heart's locked state was shortened to one row
  for this reason.

## Event detail (default G)
Photo with category and price pills, title, host. Then separate white cards: logistics, About, who
(count only, per PRD decision 11, no attendee list), good to know. The action stays anchored.

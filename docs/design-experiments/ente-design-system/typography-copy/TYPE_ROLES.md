# Figma-to-Flutter type-role map

> **2026-11-07:** superseded in part by the Figma type and icons pass ([figma-type-icons](../figma-type-icons/README.md)): `caption` is Ente Mini 12/16 (the 13/18 optical adjustment is retired), sentences use the new `helper` 14/20, and buttons are Body 500.

Source: Ente Visual Design (copy), file `22AeTw6QiPj2fNYHLhC7MK`, read live through the Figma MCP connector on 2026-11-06.
Text styles node `10854:4420`. Instances checked in:
- Settings DS `12099:96480`
- Details sheet `26580:107101`
- Login / Create account `26580:260773`
- Banners `14590:125245`
- Buttons Large `2207:41759`
- Action Sheet v2 `25316:7380`
- Toast `9409:4000`

**M** = measured from Figma variables (`get_variable_defs`); **D** = a decision for Numaya. Every Ente style has letter-spacing 0.

## Ente styles as measured
| Ente style | Family | Size/line | Weight | Where seen |
|---|---|---|---|---|
| Display-1 | Outfit | 32/40 | 600 | text styles |
| Display-2 | Outfit | 24/32 | 600 | Login "Create an account" family |
| Display-3 | Outfit | 20/28 | 600 | text styles |
| H1 | Inter | 20/28 | 600 | Details sheet title "Details" |
| H1-Bold | Inter | 20/28 | 700 | text styles (not seen in screens) |
| H2 | Inter | 18/24 | 600 | Details sheet sections "People", "Location"; Settings DS |
| Large | Inter | 16/20 | 600 | text styles |
| Body-Bold | Inter | 14/20 | 600 | banner titles ("Confirm your recovery key") |
| Body | Inter | 14/20 | 500 | rows, fields, Buttons Large, Toast |
| Mini | Inter | 12/16 | 500 | row details ("Tap to add", "7.15 MB"), banner subtitles, Action Sheet |
| Tiny | Inter | 10/12 | 500 | Details sheet |

Text colours measured:
- `text/base` #000
- `text/light` #666 (secondary and metadata)
- `text/lighter` #969696 (hint text and some metadata)

Surfaces: `background/base` #F4F4F4, `fill/light` #FFF and `fill/dark` #EAEAEA.

## Numaya roles (`lib/core/design_system/foundations/app_typography.dart`)
Families:
- Figtree (F) is the reading and UI face (wght 300–900).
- Plus Jakarta Sans (PJS) is the display face (wght 200–800).

| Numaya role | Ente source | Before (9f61314) | After | M/D | Used for |
|---|---|---|---|---|---|
| `hero` | Display-1 | PJS 32/40 600 | unchanged | M | names on photos, Welcome |
| `pageTitle`, `flowTitle`, `headline` | Display-2 | PJS 24/32 600 | unchanged | M | tab roots, onboarding, results |
| `emptyTitle` | Display-3 | PJS 20/28 600 | unchanged | M | empty states |
| `section` | H2 | PJS **20/28** 600 | PJS **18/24** 600 | M (size) / D (face) | "Account", "Your tools", "Photos" |
| `sheetTitle`, `promptAnswer` | H1 | F 20/28 600 | unchanged | M | sheet titles |
| `card` | H2 | F 18/24 600 | unchanged | M | card titles |
| `cardPrimary` | H2 size | F 18/24 500 | unchanged | D (UI-020) | prompt answers and bio in cards |
| `headerCaps` | Large | F 16/20 600, 1 line | 16/20 600, **2 lines** | M / D | top-bar titles (TC-04) |
| `body`, `bodySm`, `row`, `input`, `fieldLabel`, `label` | Body | F 14/20 500 | unchanged | M | reading text, rows, fields, labels |
| `button`, `buttonSm` | Body (Ente) | F 14/20 **500** | F 14/20 **600** (Body-Bold) | D | all button labels |
| placeholder | Body + hint | F 14/20 400 #666 | unchanged | D: Ente's #969696 is 2.96:1 on white, so it is not used for text | field hints |
| `caption` | Mini | F **12/16** 500 #666 | F **13/18** 500 #666 | D (optical) | metadata, row details, timestamps, field notes and errors |
| `micro` | Mini | F 12/16 500 | unchanged | M | badges, photo-slot numbers |
| `pill`, `chip` | Mini | F 12/16 500 | unchanged | M | chips, view tabs |
| `labelCaps` | — | F 12/16 600, 0 | F 12/16 600, **+0.04em** | D | uppercase eyebrows |
| `metric` | — | PJS 40/44 700 −0.02em | unchanged | D (Numaya extension) | scores |
| `wordmark` | — | F 700 −0.03em | unchanged | D | logotype |

## Why the decisions
- **Caption 13/18.** Figtree's x-height is 0.500 em (fontTools, `OS/2.sxHeight` 500/1000). Inter's is about 0.546 em.
  - At 12pt, Figtree draws a 6.0 px x-height against Ente's 6.55 px.
  - At 13pt, Figtree draws 6.5 px, which matches what Ente's Mini shows.
  - Body cannot move (it is held at 14/20), so only the metadata role was adapted.
  - Chips, badges and view tabs keep 12/16 because they are compact containers whose words are short.
- **Buttons at 600.** Ente's Buttons Large use Body Medium. In the before captures, Figtree 500 on a purple 52pt button read lighter than the body text around it, so action labels use Ente's own Body-Bold style.
  - The rendered ink difference is about 16% between 500 and 600 (see FONTS.md).
- **Section at 18.** Ente's Details sheet heads its groups with H2 (18/24), not with a 20pt display style. At 20pt, Numaya's section headings matched the sheet and empty-state titles, so hierarchy depended only on placement.
- **Headings stay semibold.** Plus Jakarta Sans at 600 already fills Outfit SemiBold's role, and the before captures showed no heading that lacked weight. The existing bold uses through `AppTypography.weight(..., bold)` are unchanged: names on photos, the EXP-002 cover and the visibility status. No new bold headings were added.
- **Tracking.** Ente sets 0 everywhere and Numaya follows. The only exception is uppercase eyebrows, which get +0.04em because capitals at 12pt otherwise sit tight.

## Still needs a live Figma check
- Ente's `Small/Regular` (14/17, Medium) variable appears in the Details sheet and Login screens, but it is not in the published text-style frame. Its exact use (probably field input text) was not traced to an instance.
- Ente chat and photo-overlay text: Ente has no chat. Photo overlays in Memories (`26580:107019`) were not inspected in detail. Numaya's photo text is governed by contrast (TC-07), not by an Ente style.

# Figma type and icons pass (2026-11-07)

| | |
|---|---|
| Branch | `experiment/numaya-figma-type-icons-20261107` |
| Starting checkpoint | `b518a4a851b832c4024511af50669b3ee45dd25d` (UI consistency pass, on `origin`, clean tree) |
| Brief | `NUMAYA_FIGMA_TYPE_ICONS.zip` (phases 01–04), sha256 `6a79bd3d…a688d730` |
| Figma | Ente Visual Design (copy) `22AeTw6QiPj2fNYHLhC7MK`. **Read live** through the Figma MCP connector on 2026-11-07 (account RITAM): page IDs confirmed, variables, component code, exported SVGs and screenshots |
| Carried forward unchanged | Tabler family and every filled-icon assignment; Figtree and Plus Jakarta Sans; centred alerts; Events gated off; EXP-001–004 pending with every variant kept; UC-02/UC-03 header and nav geometry |
| Device evidence | `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Figma type and icons 2026-11-07\` |

## Figma sources read
Pages: Design system `57:6281` and Updated screens (design system) `12099:96447` (IDs unchanged). The Design system page has 43 sections; the ones this pass needed were read at component level:

| Family | Node | What was measured |
|---|---|---|
| Text styles | `10854:4420` | Variables: Display-1 Outfit 32/40 600; Display-2 24/32 600; Display-3 20/28 600; H1 Inter 20/28 600; H1-Bold 20/28 700; H2 18/24 600; Large 16/20 600; Body-Bold 14/20 600; Body 14/20 500; Body-Link 14/20 500; Mini 12/16 500; Tiny 10/12 500. Tracking 0 throughout |
| Menu Item (all 40 variants) | `4055:18734` | Title Body `text/base` #000; subtitle Mini `text/light` #666; trailing text Body #666; leading icon 18px in a 36px slot; trailing more 24px; info 12px |
| Toggle Switch | `2482:6644` (`2482:6645` on, `2482:6647` off) | 31 × 18 drawing, knob r7, 2 inset. Description: "Selected=False: fill/dark track". Exported off artwork fills #969696 |
| Icon (30 variants) | `4770:20086` | Sizes Large 36, Medium 24, Small 18, Tiny 12, Micro 8. Colours Primary `text/base`, Secondary `text/light`, Tertiary `text/lighter`, Disabled `text/lightest`, Success, Critical. Exported SVGs: stroke **1.5 px at every size** (Large 36 = 1.0 on a 24 grid; Medium 24 = 1.5; Small 18 = 2.0; Tiny 12 = 3.0) |
| Button Large / Small | `2207:41759` / `2207:41578` | Labels Body 14/20 **500** |
| Text Input / Warning Message | `2275:11526` / `2275:11786` | Body 14; field messages Tiny 10 in `text/light` or `warning` |
| Header (v2) | `11439:5040` | Display-2 / Display-3 titles, Mini subtitle `text/light` |
| Tag chip examples / Filter Chip | `2482:6546` / `9524:4352` | Tag chip Body 14; Filter Chip Mini 12 `text/light`, selected `text/reverse` on `#161616` |
| Banners / Badges / Bottom sheet | `14590:125265` / `7435:15789` / `4809:8074` | Banner title Body-Bold, body Mini; sheet title H1, body Body `text/light` |
| Settings (DS updated) | `12099:96480` | Finished screen: H2 sections, Body rows, Mini details, `text/light` icons |
| Albums / On device / No albums | `26580:259933` | Empty-state description Body in `text/light`; unselected tag-chip labels in `text/light` |

## Type roles (FT-01)
Every authored font size is even. Weights are Ente's numeric weights in Numaya's faces.

| Numaya role | Ente source | Before | After |
|---|---|---|---|
| `caption` (metadata, row details, timestamps-style meta, counters, field notes, banner bodies) | Mini 12/16 500 | 13/18 500 | **12/16 500** |
| `helper` (new: stand-alone explanatory sentences: list footnotes, sheet notes, tips) | Body 14/20 500, `text/light` | (used `caption` 13/18) | **14/20 500 #666** |
| `button`, `buttonSm` | Body 14/20 500 (Button Large/Small) | 14/20 600 | **14/20 500** |
| `wordmark` | logotype | 27 / 21 | **28 / 22** |
| `Emoji` sizes in chips | — | 15.5, 17 | **16, 18** |
| Dynamic initials and Welcome wordmark | — | raw multiples | **`AppTypography.even(...)`** |
| `pill` doc | Filter Chip | "selected pills use semibold" | corrected: weight stays 500, selection is fill and colour |
| All other roles | as measured | unchanged | unchanged (already even and matching) |

Consumers moved from `caption` to `helper` (sentences): ListGroup footnote, Filters notes and fallback line, Settings delete note, Demo hub restore note, Premium demo note, Help contact note, Photos tip, Bio tip, Events notes (picked, sort, report, cover), Visibility notes (note, limits, activity meaning), For you rationale, Chat intro, Likes "passed" footer, Setup hub caption, Prompt editor hint, missing-media line. Metadata consumers stay on `caption` at 12.

## Text colours (FT-02)
| Role | Token | Hex | On white | On page #F4F4F4 | On fill #EAEAEA |
|---|---|---|---|---|---|
| Primary | `textPrimary` / `ink` | #000000 | 21:1 | 19.3:1 | 17.4:1 |
| Secondary, metadata, helper | `textSecondary` (= `textMuted`) | #666666 (was #1A1A1A for `textSecondary`) | 5.74:1 | 5.22:1 | 4.77:1 |
| Placeholder | `textSecondary` at 400 | #666666 | 5.74:1 | | |
| Disabled | `disabledForeground` | #8A8A8A | 3.45:1 (exempt) | | |
| Inverse | `inkForeground` | #FFFFFF | on brand 4.90:1 | | |
| Strong icon ink | `iconStrong` (new; selected tab glyph, idle bar icons, initials) | #1A1A1A | | | |

Ente's `text/lighter` #969696 (2.96:1 on white) is not used for text. Semantic colours (`negative`, `success`, `warning`, `info`, `accentOnTint`) are guarded at 4.5:1 on white and the page. Destructive rows draw icon and label in the same `negative` red (guarded).

## Outline icons (FT-03)
Rendering path: `NumayaIcon` / `MobileIcon` → `TablerSvg` → `TablerOutlineLoader` (outline assets only) rewrites the single root `stroke-width` of the bundled Tabler 3.50.0 SVG. The bundled files are unchanged (the sync check stays valid), filled files never pass through the loader, and the stroke is part of the SVG cache key.

| Class | Sizes (lp) | Authored stroke (24 grid) | Rendered stroke (lp) | Device px at DPR 2.625 | Main consumers |
|---|---|---|---|---|---|
| Small | 14, 16 | 1.0 | 0.58, 0.67 | 1.5, 1.75 | chip × and badge glyphs (14), meta icons, info rows, tile icons (`iconSm` 16; 8 uses + 4 literal) |
| Large | 18, 20, 22, 24 | 1.5 | 1.13, 1.25, 1.38, 1.5 | 3.0–3.9 | chip +, button icons (18); rows, header buttons, tab bar, field icons (`iconMd` 20; 25 uses); chevrons and defaults (`iconLg` 24) |
| Display | 26–56 | 1.0 | 1.08–2.33 | 2.8–6.1 | empty-state art (36; 9 uses), photo placeholders (32, 38), Events art (44/56) |

Before: every outline drew Tabler's 2 (1.17–4.67 lp). Ente draws 1.5 px at every size; Numaya's small class is lighter than Ente by the owner's direction (E-01). Icon colours follow Ente's Icon types: rows and meta `textSecondary` #666, headers and controls `ink`, destructive `negative`, selected tab `iconStrong` filled.

## Off switch (FT-04)
| | Before (UC-01) | After |
|---|---|---|
| Off track | `switchOff` = `_M.outline` #8A8A8A | `switchOff` = `_M.fill` **#EAEAEA** (Ente "fill/dark") |
| Off edge | none | `switchOffEdge` = `_M.outline` #8A8A8A, 1pt inside (3.45:1 white, 3.14:1 page) |
| On | brand #7262C7, no edge | unchanged (edge drawn in the track colour, so geometry is identical in both states) |
| Knob | white 23pt, `AppElevation.thumb`, 2pt inset | unchanged (padding 1 + edge 1) |
| Disabled | 45% opacity | unchanged |

Consumers: `NumayaSwitch` is created only by `ListRow` (no Material/Cupertino switch, no switch theme), so every switch in the app (Settings, notifications, privacy, Filters sheet, Design Lab) took the change. Row tap and toggled semantics are unchanged (guarded in component_cleanup_test).

## Route ledger
| Area | Route / screen | How reviewed |
|---|---|---|
| Onboarding | Welcome; "You're verified" setup hub (first viewport and scroll) | device after; Welcome before/after |
| Discovery | Discover (top, scrolled facts), Filters sheet (top, scrolled) | device before/after |
| Matching | Likes grid | device before/after |
| Messaging | Messages list; Chat (Priya); chat options sheet (Block/Report in red) | device before/after; options after |
| Profile and editors | Profile (top, scrolled to prompt and safety), Edit profile (top, scrolled), The basics, Interests and prompt | device before/after |
| Settings and safety | Settings (top, notifications/app, end with Sign out/Delete account) | device before/after |
| Tools | Demo hub, Design Lab (top, scrolled), Experiment Lab | device after |
| Shared components | switch pairs on white card and grey page at 1.0 and 2.0 text; icon board 14–36pt | harness render (flutter test, DPR 2.625) |
| Everything else | all routes in the widget/journey suites (onboarding steps, safety sheets, events, premium, help, visibility, verification, A/B/C variants) | 507 widget tests, including 13 new guards |

## Tests
- New `test/widget/figma_type_icons_test.dart` (13): even sizes for every role and a **source scan of lib/** (literal `fontSize`, `Emoji` sizes, role definitions, and computed sizes must use `AppTypography.even`); Ente sizes and weights; colour roles and semantic contrast; destructive row; footnote helper; stroke classes and maximum; outline SVG structure; root-only rewrite; loader routing; filled assignments unchanged.
- Updated to the new rules: `typography_copy_test`, `foundation_test`, `component_cleanup_test` (switch), `discover_match_review_test` (switch), `ente_design_system_test` (button weight).

## Exceptions
See `EXCEPTIONS` in the review folder; the same list:
- **E-01** Small outline icons render at 0.58–0.67 lp, lighter than Ente's constant 1.5 px, and the step at 18pt (0.67 → 1.13 lp) is visible on the icon board.
- **E-02** Display art over 24pt uses stroke 1.0, not 1.5, to stay near Ente's 1.5 px Large icon.
- **E-03** Field notes are Mini 12; Ente's field message is Tiny 10, rejected as too small for a sentence.
- **E-04** `NumayaButton` keeps its 1.2 line height (16.8) instead of Ente's 20, for two-line labels at large text.
- **E-05** Section-heading variants kept: Messages list labels and Filters questions in `headerCaps` 16 (recorded Bumble-style choice), Interests label in `fieldLabel` 14.
- **E-06** The off-switch edge is a Numaya addition; Ente's off switch has none (and its artwork disagrees with its description: #969696 vs fill/dark).
- **E-07** Family substitution: Figtree's x-height is 0.500 em against Inter's 0.546, so 12pt metadata draws a 6.0 px x-height against Ente's 6.55 px. The owner chose even sizes over the earlier 13pt compensation.
- **E-08** "3/5 SELECTED" keeps its `labelCaps` weight override (400).
- **E-09** The web prototype's `tokens/numaya.tokens.json` still has odd type sizes (11, 12.5, 13, 13.5, 15, 15.5, 23, 31, 34). The Flutter app does not read type from it; out of scope.
- **E-10** Not captured on the device this pass: Visibility, Premium, Help, the delete-account sheet, onboarding after Photos, 320pt width, 2.0 system font. Covered by widget tests and the harness render.
- **E-11** `sync_tabler_icons.py --check` not run (npm `@tabler/icons` absent); the bundled SVGs are unchanged in git.
- **E-12** Goldens not regenerated (Linux renders of an older look).

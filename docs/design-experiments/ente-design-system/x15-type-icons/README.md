# 15px type and icon experiment (X15, 2026-11-07)

A reversible experiment for the owner to compare on a phone. Not integrated.

| | |
|---|---|
| Branch | `experiment/numaya-15px-icons-20261107` |
| Starting commit (return here) | `7eae0603a0d519cca3299af4ba9935c558e29000` on `experiment/numaya-figma-type-icons-20261107` (SW-01 switch, local demo photos) |
| Final commit | the commit that adds this note (see `git log -1` on the branch) |
| Figma | Ente copy `22AeTw6QiPj2fNYHLhC7MK`, read live: Header (v2) `11439:5040` (collapsed: back + inline title, Display-3 20/28; expanded: Display-2 24/32 under the arrow, Mini subtitle), plus the Text styles, Menu Item and Icon measurements recorded in `../figma-type-icons/README.md` |
| Review folder | `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\15px icon experiment 2026-11-07\` |

## 14 → 15 (X15)
The one permitted odd size. Line heights stay at 20 (Flutter's `height` is a multiplier, so it changes from 20/14 to 20/15); nothing clipped, so no line height was raised.

| Role | Before | After | Used for |
|---|---|---|---|
| `body` (via `MonoType.bodySize`) | 14/20 500 | **15/20 500** | reading text, chat bubbles, sheet and empty-state bodies |
| `bodySm` | 14/20 500 | **15/20 500** | supporting paragraphs, view tabs, message previews |
| `row` | 14/20 500 | **15/20 500** | list-row titles and values, option rows |
| `input` | 14/20 500 | **15/20 500** | typed text, placeholders (multi-line keeps a 22pt line: `22 / 15`) |
| `button`, `buttonSm` | 14/20 500 | **15/20 600** | button labels (weight: see below) |
| `label` | 14/20 500 | **15/20 500** | card and chip-group labels |
| `helper` | 14/20 500 | **15/20 500** | list footnotes, sheet notes, tips |
| `fieldLabel` | 14/20 500 | **15/20 500** | field and option-group labels |
| `metricUnit` | 14/20 500 | **15/20 500** | the unit beside a metric |

Unchanged: Mini 12/16 (caption, micro, pill, chip, labelCaps), 16 (`headerCaps`), 18, 20, 24, 28, 32, 40. No widget sets its own 14pt text (the lib/ scan in `figma_type_icons_test` now allows 15 and still rejects any other odd size). 14pt icon sizes, paddings and asset coordinates were not touched.

## Headings and weights (X15-H)
| Role | Before | After | Why |
|---|---|---|---|
| App-bar titles (`NumayaTopBar`, chat header name) | `headerCaps` Figtree 16/20 600; chat name `row` 14 600 | new **`appBarTitle` Plus Jakarta Sans 20/28 700** | Ente Header v2 collapsed uses Display-3 20/28; at 16 the "Settings" title read weaker than the 18pt "Account" section under it |
| Page titles (`pageTitle`, `flowTitle`, `headline`) | PJS 24/32 600 | PJS 24/32 **700** | the primary heading on a screen; kept consistent with the app-bar title |
| Buttons | Figtree 500 | Figtree **600** | actions lead the 15pt body they share a size with |
| Section headings | PJS 18/24 600 | unchanged | between the 20 title and the 15 rows |
| Row titles, body, supporting text | 500 | unchanged | supporting text is set apart by #666, metadata by size (12) |

Rendered check on the Pixel 10 (median stroke, device px): "Settings" title 5 → 7; "Account" section 6 → 6; "Edit profile" button label 3 → 4; "Phone number" row 5 → 5. Plus Jakarta Sans (wght 200–800) and Figtree (300–900) carry every weight used.

## Icons (X15-I)
- **Stroke** (`tablerOutlineStroke`, 24-grid units): **1.5 up to 24pt**, **1.25 above 24pt** (empty-state and placeholder art). Rendered: 14 → 0.88pt, 16 → 1.0, 18 → 1.13, 20 → 1.25, 24 → 1.5, 36 → 1.88. Supersedes FT-03's 1.0 small class (0.58–0.67pt).
- **Size mapping:** the selectable chip's glyph was 14 (×) when selected and 18 (+) otherwise, so its stroke jumped on selection; both are now `AppSizes.iconSm` (16).
- **Colour:** new `AppColors.iconSupporting` #8A8A8A (3.45:1 on white, 3.14:1 on the page) for list-row leading icons and row chevrons, a step lighter than the #666 supporting text. Near-black selection (`iconStrong`), brand and semantic colours unchanged; destructive rows draw icon and label in the same red.
- **New icon rows** in Settings, using the standard `ListRow` (same 36pt leading slot and alignment as every row): Version (`info`), Sign out (new Tabler `logout`, `NumayaMobileIcons.logout`), Delete account (`trash`, red). They replace the centred `_ActionBlock` text blocks; the actions, labels and 60pt targets are unchanged.
- **Assets:** `logout.svg` added by `tool/sync_tabler_icons.py` from the official `@tabler/icons@3.50.0` package. All 110 bundled SVGs match that package (line endings aside); the sync `--check` reports differences only because git checks the files out with CRLF.

## Verification
- `dart format`: clean. `flutter analyze`: no issues. `flutter test`: **507 passed, 21 skipped, 0 failed**. Updated expectations (intended changes only): `figma_type_icons_test`, `typography_copy_test`, `foundation_test`, `ente_design_system_test`, `overnight_polish_test`, `type_roles_test`, `final_polish_test`.
- Pixel 10 AVD (API 36, 1080 × 2424, DPR 2.625), same Demo Hub data, before (`7eae060` build) and after:
  - 16 screens at font size 1.0: Welcome, Discover (top and scrolled), Likes, Messages, Chat, Profile, Settings (top, notifications, end), Edit profile (top and scrolled), The basics, Interests, Filters sheet (top and scrolled);
  - Chat, Profile, Settings top and end at font size 1.3, and at 320dp width (density 540); the narrow "The basics" capture landed on Edit profile instead.
- No clipping or overflow seen; long row labels wrap; at 320dp a value moves under its label (the existing V4-02 rule).

## Exceptions
- Ente's buttons and rows are Inter 14/20 500; this experiment is deliberately larger (15) and buttons heavier (600).
- Sheet titles (`sheetTitle` Figtree 20/28 600), Filters questions and Messages list labels (`headerCaps` 16) are unchanged; they are not app bars.
- `iconSupporting` #8A8A8A is 2.86:1 on the #EAEAEA fill; it is used only on white cards.
- Repo `npm run check` (line endings) and `npm run test:e2e` (no Playwright) are as in the previous passes. Goldens not regenerated.
- To revert: `git switch experiment/numaya-figma-type-icons-20261107` (or reset to `7eae060`).

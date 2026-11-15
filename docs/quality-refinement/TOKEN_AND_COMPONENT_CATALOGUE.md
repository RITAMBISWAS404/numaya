# Token ownership and component catalogue (quality refinement, 2026-11-15)

Extends `docs/ui087-102/TYPOGRAPHY_CATALOG.md` and `DEV_MODE.md`; does not replace them.

## Who owns what (QR-001)

| Layer | File | Owns | Generated? |
| --- | --- | --- | --- |
| Web/source tokens | `tokens/numaya.tokens.json` | Spacing, sizes, durations, approved semantic web roles | Source |
| Web outputs | `src/design-system/tokens.css`, `tokens.js` | CSS variables, manifest | `node scripts/tokens.mjs` (check: `--check`, LF pinned) |
| Dart generated | `apps/numaya_mobile/lib/core/design_system/tokens/numaya_tokens.g.dart` | `NumayaSizeTokens` (space, sizes) | `node apps/numaya_mobile/tool/generate_tokens.mjs` |
| Dart handwritten | `tokens/monochrome_tokens.dart` | Colours (`MonoColors`), radii (`MonoRadii`), card padding, shadows | Handwritten (**not yet in the pipeline**, QR-001 outstanding) |
| Foundations | `foundations/app_colors.dart`, `app_layout.dart`, `app_typography.dart` | Semantic roles over both; Dev Mode brand and type | Handwritten adapters |
| Dev Mode | `foundations/type_settings.dart`, `dev_mode.dart` | Review comparisons only | Handwritten |

Rule for new code: screens use `AppColors`, `AppTypography`, `AppSpacing`, `AppLayout`, `AppRadii`; never raw values.

## Radius roles (QR-003, owner 2026-11-15)

| Role | Value | Note |
| --- | --- | --- |
| tag, chip | 8 | |
| badge, checkbox | 4 | |
| field, control, iconButton, iconTile, navItem (finite) | 12 | |
| tile, card | 16 | |
| heroCard, image (photo), sheet, dialog | 20 | **`AppRadii.maxFinite` = 20** |
| pill, infoPill, navShell, navItem (UI-026) | 999 (capsule) | Named exception |
| Avatars, rings, round buttons | circle | Named exception |

Nested surfaces use `AppRadii.nested(outer, inset)` (outer minus inset, never below 0) with matching clips. A control
floating on a photo is not nested: it keeps its own 12pt shape and the 16pt inset (photo stays 20).
`test/widget/quality_refinement_test.dart` scans 15 rendered screens in both button shapes for violations.

## Component families touched in this pass

| Family | Shared source | Consumers changed |
| --- | --- | --- |
| Status template | `EmptyState`, `StatusLayout` | Purchase outcomes (6), chat ended, contact sent, already Premium, **verification pending and verified, underage**; Discover states |
| Photo overlays | `SquircleIconButton.photoInset/photoRadius`, person photo card | Discover, Likes, preview, **own-profile header** |
| Framed photo | `match_variants.dart` frame | Match variant frame (lab option) |

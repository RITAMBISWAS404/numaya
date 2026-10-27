# Design system (Flutter)

The Flutter app reproduces the **approved Numaya design** (no `?theme` on the web): Meetup visual system, brand
purple `#7262C7`, Fraunces + Inter. See [REPOSITORY_AUDIT.md](REPOSITORY_AUDIT.md) for why this one.

## One source of truth

```
tokens/numaya.tokens.json ──npm run tokens──▶ src/design-system/tokens.js ──tool/generate_tokens.mjs──▶
    apps/numaya_mobile/lib/core/design_system/tokens/numaya_tokens.g.dart  (191 approved tokens)
src/design-system/icons/material-symbols.js ──tool/export_assets.mjs──▶ icons/numaya_icon_data.g.dart (67 icons)
src/design-system/components/Illustration.jsx ──tool/export_assets.mjs──▶ assets/illustrations/*.svg (9 scenes)
```

Only semantic and component tokens of the approved design are exported; primitives and the V11/V16 experiments stay
on the web.

### Changing the brand colour (or any token)

```bash
# 1. edit tokens/numaya.tokens.json (e.g. primitive.color.purple.600)
npm run tokens                                        # web
node apps/numaya_mobile/tool/generate_tokens.mjs      # Flutter
node apps/numaya_mobile/tool/export_assets.mjs        # only if illustration colours should follow
node apps/numaya_mobile/tool/generate_tokens.mjs --check   # CI: fails if the Dart file is stale
```

Widgets read roles such as `AppColors.brand`, never hex values, so nothing else changes.

## Foundations (`lib/core/design_system/foundations/`)

| Class | Contents |
|---|---|
| `AppColors` | brand, brandTint, brandSubtle, control, accents (marks only, never text), text roles, surfaces, borders, focus, scrim, danger/success/warning |
| `AppTypography` | hero 34/38 · display 31/35 · headline 26/30 · titleSm 23/28 · title 20/25 (Fraunces 520, SOFT 50, WONK 0, opsz = size) · body 15.5/23 · bodySm 15/21 · input 18/24 w500 · button 16/20 w600 · label 13.5/18 · caption 13/18 · micro 12.5/17 · eyebrow 11/14 (Inter). `weight()` sets any variable weight (e.g. 520, 680). `welcomeTitle(width)` reproduces `clamp(36px, 10.4vw, 42px)`. |
| `AppSpacing` | 4 pt scale s1…s12, gutter 16, stack 12, field 20, section 28, content max 430 |
| `AppRadii` | xs 8, sm 12, md 16, lg 20, xl 28, card 24, photo 32, pill |
| `AppBorders` | hairline 1, selected 1.5, focus 2 |
| `AppSizes` | control 56, touch min 44, button 54 / sm 40 / quiet 48, fab 56, icon button 40 / 36, chip 36, progress segment 18×8, code cell 60 (radius 18), switch 51×31, tab bar 64, top bar 56 |
| `AppElevation` | thumb, xs, sm, md, float, lg, button, brand |
| `AppMotion` | 140 / 220 / 380 / 460 ms; ease-out (0.22,1,0.36,1), emphasized (0.32,0.72,0,1), in-out (0.65,0,0.35,1). `duration(context, d)` returns zero when the system asks to remove animations. |
| `AppTheme` | Material theme from the tokens (selection colours, dialogs, sheets, Cupertino-style page transitions, no ripple: controls scale on press as on the web) |

## Components (`lib/core/design_system/widgets/`)

| Flutter | Web | States |
|---|---|---|
| `NumayaButton` (primary, secondary, quiet, brand, destructive, destructiveSolid; small) | `.btn` | enabled, pressed (0.98), disabled (grey), loading |
| `NumayaFab` | `.fab` | enabled (purple), disabled (sunken), loading, pressed (0.94) |
| `NavIconButton` (floating, flat, plain) | `.nav-button` | pressed (0.92), tooltip, label |
| `TextLink` | `.text-button` | enabled, disabled |
| `NumayaTopBar`, `StepProgress` | `.topbar`, `.progress` | back, progress (current segment fills in), title |
| `NumayaScreen`, `StepFooter`, `ScreenHeader`, `NumayaSection` | `.screen`, `.screen-header`, `.section` | page / wash tone |
| `NumayaTextField` (+ multiline), `InputSurface`, `FieldNote` | `.field`, `.input`, `.field__note` | idle, focused (white, 2pt ring, halo), invalid, disabled, helper/error/success note, counter |
| `CountryCodeBadge`, `NumayaSearchField` | `.input__code`, `.search` | focus, clear |
| `CodeInput` | `.code` | empty, active cell with blinking caret, filled, checking (dimmed), error (shake, red), success (purple) |
| `NumayaChip`, `ChipSet` | `.chip` | default, selected (solid purple, minus), unavailable (quota reached) |
| `OptionCard`, `OptionGroup` | `.option-card` | radio / checkbox, selected (lavender + 2pt ring), disabled |
| `InfoCard` | `.info-card` | — |
| `PromptCard` | `.prompt` | answered, empty call to action, tappable |
| `PhotoGrid` | `.photo-grid` | filled (order badge, remove), empty (+) |
| `ResultPanel`, `SetupProgress` | `.result`, `.setup-steps` | done / active ("Up next") / upcoming |
| `showNumayaSheet` | `.sheet` | standard, tall (80%) |
| `NumayaToast` | `.pill` | message, busy (three dots), announced to screen readers |
| `NumayaTabBar`, `NumayaSwitch`, `ListRow`, `ListGroup`, `EmptyState` | `.tab-bar`, `.switch`, `.list-row` | current tab, on/off, chevron/value/switch |
| `Wordmark`, `BrandMark`, `IllustrationView`, `NumayaIcon` | `Brand.jsx`, `Illustration.jsx`, `Icon.jsx` | — |

All controls share `Pressable`: a 44 pt minimum hit area, press scale, keyboard activation (Enter / Space), a focus
ring and button semantics.

## Known differences from the web

| Web | Flutter | Why |
|---|---|---|
| `text-wrap: balance` on titles | Normal wrapping, so a title can break one word later | Flutter has no balanced wrapping |
| Inset 1px highlight inside primary buttons | Omitted | `BoxShadow` has no inset |
| CSS blur radius | Flutter `blurRadius` with the same number | Visually equivalent at these sizes |
| Fonts: full Fontsource builds | Latin subsets | Other scripts fall back to the platform font until full fonts are bundled |
| Light theme only | Light theme only | The approved design defines no dark theme |

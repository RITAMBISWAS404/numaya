# Design system (Flutter): Numaya V16

The Flutter app reproduces **Numaya V16**, the Withings Health Mate reconstruction
(`artifacts/version-16-design-experiment/`, web `?theme=withings`, branch `experiment/numaya-v16-withings` at
`2c11a6d`). The first Flutter foundation (`75f63e7`) used the default purple design by mistake; branch
`experiment/numaya-flutter-v16` replaces that visual layer while keeping every screen, rule and test.

## Sources of truth

| What | Web source |
|---|---|
| Tokens | `tokens/numaya.tokens.json` → `src/design-system/tokens.js` (`color.withings.*`, `component.withings.*`, `shadow.withings-*`) |
| Role remapping | the "Roles" block of `src/design-system/styles/theme-withings.css` |
| Component rules | the rest of `theme-withings.css`, `src/flows/theme-withings.css`, `artifacts/version-16-design-experiment/design-system/COMPONENT_RULES.md` and `TOKENS.md` |
| Inherited layout | V11 (`src/design-system/styles/theme-tiimo.css`): welcome emoji stickers, interest emoji and set marks |
| Screens | `artifacts/version-16-design-experiment/final-polish/screenshots/states/` (49 final states) |

```
tokens/numaya.tokens.json ─npm run tokens─▶ src/design-system/tokens.js ─tool/generate_tokens.mjs─▶ numaya_tokens.g.dart (280 tokens, 89 V16)
src/design-system/components/Illustration.jsx ─tool/export_assets.mjs─▶ assets/illustrations/*.svg (V16 colours)
@fontsource-variable/hanken-grotesk ─tool/convert_fonts.py─▶ assets/fonts/HankenGrotesk-Variable.ttf
```

`AppColors` and `AppTypography` re-point the shared roles exactly as theme-withings.css does (`brand` → Withings
blue, `controlSelected` → ink, `surfacePage` → stone, …), so a widget written against a role gets the V16 value.

## The system

- **Colour:** stone page `#F5F4F1`; white cards with no border and no shadow; ink `#121212` for text, primary
  buttons, the step button, selected radios and the active tab; Withings blue `#5066CC` for checked boxes, slider
  intervals, focus and the mark; blue tint `#E4EBFC` with deep-blue `#3E4A8F` text for selected chips, the toast
  and links; green `#3C783C` switches; red `#CF3336` for destruction and errors; navy `#203068` initials avatars;
  pastel holders (yellow, lavender, pink) behind interest-set emoji only.
- **Type:** one family, Hanken Grotesk. Page titles 30/36 bold; profile name 32/38 bold; flow headings 26/32 medium
  (balanced wrapping, like CSS `text-wrap: balance`); result titles 24/30 semibold; section headings 22/28 medium;
  sheet titles 20/26 medium; empty-state titles 18/24 semibold; rows and inputs 16/22 regular; card titles 15/20
  medium; body 15.5/22; caption 13.5/18. Modal headers in tracked capitals (12.5, bold, 0.16em); field, legend and
  chip-set labels in small bold capitals (11.5, 0.06em).
- **Geometry:** tags 6, fields 8, buttons and chips 12, cards 14, photos and sheets 16; pills only for compact
  buttons and the toast; circles for header buttons, avatars, radios, the step button and switch thumbs. Buttons
  50 tall, fields 54, rows 56, compact buttons 36 inside the 44 touch area. On Android, text inputs, the search field
  (V16 46) and the composer (V16 44) are 48dp tap targets ([VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md) A-2, A-3).

## Components

| Flutter | V16 rule |
|---|---|
| `NumayaScreen` + `NumayaTopBar` | Stone page; modal and flow headers are a white bar with a hairline (also behind the status bar), bare ink back icon, tracked-capital title or ink progress segments on the fill |
| `TabHeader`, Home header | 30pt bold title on the page with 40pt white circle buttons (hairline); Home shows the wordmark |
| `NumayaTabBar` | White, top hairline; current tab ink with filled icon and semibold label; others muted with outline icons |
| `NumayaButton` | Primary ink · secondary white with 1px ink outline · tint · solid red · text; disabled `#D6D2CE` / `#77736F`; `small` = 36pt outlined pill (ink when primary) |
| `NumayaFab` | Ink circle with white arrow; disabled warm grey |
| `NumayaTextField`, `InputSurface`, `FieldLabel` | White, 1px `#6D6C6A` outline, 8 corner, 54 tall; focus 2px blue; invalid 2px red; capital label; text areas show "N characters left" inside. The outline is a foreground decoration, so focus doesn't move the text; single-line inputs are 48dp targets |
| `OptionGroup` + `OptionCard` | One white card, 56pt rows, hairline dividers, no ring on selection; radio 22 grey ring → ink ring + dot; checkbox 22/6 → blue with white tick |
| `NumayaChip`, `ChipSet` | White 12-corner chip with emoji and 15 medium label (fill on white cards); selected blue tint, deep-blue semibold; set name beside its emoji in a 28pt pastel circle |
| `PromptCard`, `PromptMark` | White card; blue speech bubble in a 24pt tint circle; 15 medium question; semibold answer |
| `InfoCard` | Page colour with a hairline, ink icon |
| `PhotoGrid` | 14 tiles in photo grey, 6-corner order tag, round ink remove; empty slots white with a dashed edge and an ink "+" circle |
| `EmptyState` | White card 16pt below what precedes it, left-aligned: illustration (160 wide), 12pt gap, 18 semibold title, body, compact action |
| `ListGroup`, `ListRow` | 22 medium heading; white card; 56pt rows, 16 regular label, secondary subtitle, dividers inset 16 |
| `NumayaSwitch` | 51 × 31, green on, fill off, 27pt white thumb |
| Sliders (`V16SliderThumb`) | Blue interval on the fill rail, 26pt white thumbs with the soft thumb shadow |
| `showNumayaSheet` | White, 16 top corners, warm grabber, 20 medium title above a hairline, bare ✕; covers the tab bar; as tall as its content, at most the screen less 8pt |
| `showNumayaActionSheet` | V16 action sheet: a white group of icon rows (destructive ones red) and a separate white Cancel block |
| `NumayaToast` | Blue-tint pill, deep-blue text, float shadow |
| `Wordmark` | Bold ink "numaya", mark in Withings blue with the rose dot |
| `InitialsAvatar`, `VerifiedMark` | Navy circle with a white initial (no invented photos); optional blue ring for an unopened match; blue verified badge |
| `PhotoPlaceholder` | Photo-grey stand-in with an image glyph; fixed ratio or fills its box |
| `StatusBadge` | 6-corner tag: outlined, blue tint ("New"), white on a photo, translucent on the dark band |
| `ProfileSectionCard`, `InfoChip` | White profile section card with a 15 medium title; fill chips with an icon or emoji |
| `RoundAction` | Pass (white, ink outline), SuperSwipe (blue), Like (ink), 56pt; SuperSwipe also floats on the photo band |
| `ConsequenceList` | Icon + secondary-text lines in unmatch and block sheets |
| `Composer` | White pill field (48dp) and a 44pt ink send circle in a 48dp target; disabled grey when empty |
| `MessageBubble` | Withings blue, white text, 14 corners with a 6pt tail corner |
| `ScallopPortrait` | V16 organic frame `scallop(10, 46.5, 3)` in photo grey with the initial at 88/264 scale |
| `ViewTabs` | Segmented filter tabs with counts ("All 5 · New 3 · Nearby 2"); selected on the blue tint |
| `PersonTile` | Likes grid tile: photo stand-in, badge, name + verified, caption |
| `BalancedText` / `.rich` | Even line lengths, like CSS `text-wrap: balance` (flow titles, the match sentence) |
| `CodeInput` | (no V16 counterpart) extends the V16 field: white cells, 1px outline, 8 corner, blue active, red wrong, tint verified |
| `SetupProgress` | (no V16 counterpart) white cards on the page; done on the fill; next ringed in ink with a blue-tint "Up next" |

## Changing a token

```bash
# edit tokens/numaya.tokens.json (e.g. primitive.color.withings.blue)
npm run tokens
node apps/numaya_mobile/tool/generate_tokens.mjs
node apps/numaya_mobile/tool/export_assets.mjs          # illustrations follow the palette
node apps/numaya_mobile/tool/generate_tokens.mjs --check  # CI
```

## Known differences from the web

| Web V16 | Flutter | Why |
|---|---|---|
| Five tabs (with Activity) | Four tabs | Activity needs real events; not built ([ONBOARDING_FLOW.md](ONBOARDING_FLOW.md)) |
| Edit / Preview segmented control on Edit profile | Not shown | No preview yet; no control that does nothing |
| Profile readiness score and badge | Not shown | The score's inputs (bio, etc.) don't exist in the app yet |
| Profile options "Share profile" | Not shown | No real profile links |
| Settings repeats age and distance | In the Filters sheet only | One place to change them |
| Fonts: full Fontsource build | Latin subset | Other scripts fall back to the platform font |

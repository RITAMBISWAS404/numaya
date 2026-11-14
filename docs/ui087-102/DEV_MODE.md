# Dev Mode comparisons (UI-085, UI-095, UI-096, UI-097, UI-098)

Review builds only (`AppConfig.demoAuthAllowed`). Reached from **Settings → Prototype tools → Dev Mode** and from
the Demo Hub (Design → Dev Mode). Route `/review-typography` (kept so old links work). Release builds have no route and
always render the baseline.

## Verified baseline, recorded 2026-11-15 before any change

Read from the checkpoint build `96c7872` (app source `fe44b27`) and the code, not assumed:

| Setting | Baseline value |
| --- | --- |
| Font pairing | Default: Plus Jakarta Sans (display roles, section and app-bar titles) + Figtree (UI roles) |
| Body size | 15 pt (the owner's 14/15 toggle, unchanged; 14 is the alternative) |
| Brand colour | `#7262C7`; pressed `#5F50B8`; text `#5B4BB0`; subtle `#F1EFF9`; line `#CBC4EC` |
| Button shape | 12 pt corners; compact buttons 8 pt; step button 12 pt |
| Secondary surface | Outline: transparent with a 1 pt ink-at-30% edge (C-03) |

## One system

`TypeSettings` (lib/core/design_system/foundations/type_settings.dart) holds all five settings; `DevModeStyles.apply`
(foundations/dev_mode.dart) applies them together: typography roles, the brand palette (`AppColors.applyBrand`), the
button radius (`NumayaButton.radiusFor`) and the secondary surface (`NumayaButton.outlinedSecondary`). The app root
watches the setting and marks every element for rebuild, so screens, sheets and explicit styles change at once with no
restart. The file `numaya_review_typography.json` in the app-support folder keeps the choice across relaunches; it is
deleted when every setting is back at the baseline.

Replaced, not duplicated: the old independent display and UI font selectors, and the Design Lab group
`r8-secondary-button` (now the Dev Mode secondary surface).

## Options (exactly as specified)

| Control | Options | Notes |
| --- | --- | --- |
| Font pairing (UI-085) | Default · Halant + Nunito Sans · Yeseva One + Josefin Sans · Bree Serif + DM Sans | Both families change together. Fonts bundled offline (SIL OFL 1.1, google/fonts). |
| Body size | 15 (default) · 14 | Existing control, kept. |
| Brand colour (UI-095) | Default (#7262C7) · #7E77F8 · #A07ADD | Seeds exact. Only brand roles move. |
| Button shape (UI-096) | Default · Fully rounded | No third option: the reviewer's third was not described. |
| Secondary surface (UI-098) | Outline · Filled | Filled = black at 8% over the background (4% when disabled, grey label, no edge). |
| Reset all (UI-097) | One button | Restores every control above to the baseline and deletes the saved file. Never touches account, profile, chats, credits or Design Lab choices. |

## Derived brand roles

One rule for both new seeds (seeds unchanged): pressed = seed with HSL lightness -6%; subtle = seed at 10% over white;
line = seed at 36% over white; text = seed darkened until it reaches 6:1 on the page and 4.5:1 on subtle. Focus halo and
outlined-brand edge are the seed at 24% and 45%.

| Option | Brand | Pressed | Text | Subtle | Line | White on brand |
| --- | --- | --- | --- | --- | --- | --- |
| Default | #7262C7 | #5F50B8 | #5B4BB0 | #F1EFF9 | #CBC4EC | 4.90:1 |
| #7E77F8 | #7E77F8 | #625AF7 | #443AF5 | #F2F1FE | #D1CEFC | **3.57:1** |
| #A07ADD | #A07ADD | #8F62D7 | #7239CC | #F6F2FC | #DDCFF3 | **3.32:1** |

**Unresolved accessibility conflict:** white 15 pt semibold labels on the two new seeds are below 4.5:1 (they pass 3:1
for large text and non-text). The seeds are the reviewer's exact values, so they were not altered. If either is chosen
for production, the label colour or the seed needs a decision.

Neutral surfaces, ink, the grey text roles, success, warning, error, info, photo scrims and the dark hero surface do not
follow the brand selection (covered by `test/widget/type_settings_test.dart`).

## Font weights per pairing

| Pairing | Display family and real weights | UI family and real weights | Mapping |
| --- | --- | --- | --- |
| Default | Plus Jakarta Sans, variable 200-800 | Figtree, variable 300-900 | Exact role weights (700 titles, 600 sheet/section, 500 body). |
| Halant + Nunito Sans | Halant, static 300/400/500/600/700 | Nunito Sans, variable 200-1000 | Exact. |
| Yeseva One + Josefin Sans | Yeseva One, 400 only | Josefin Sans, variable 100-700 | Display roles render at 400; never synthetically bolded. Hierarchy comes from size and the display face. |
| Bree Serif + DM Sans | Bree Serif, 400 only | DM Sans, variable 100-1000 | As above for display roles. |

Sizes, line heights and tracking do not change with the pairing; only the families do.

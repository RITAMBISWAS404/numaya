# UI implementation matrix

**Coverage:**
- All screen families of the Flutter app were restyled: the token and component layer moves every
  screen.
- Rows list the screen-specific changes on top of that.
- The 186 golden captures in `apps/numaya_mobile/test/screenshots/goldens/` were reviewed family by
  family. Contact sheets are in [screenshots/](screenshots/).

**Captures:** prefixes refer to the golden file names.

| Batch | Family | Captures | System-level change | Screen-specific change | Status |
|---|---|---|---|---|---|
| A | App shell and navigation | all tab roots | floating rounded tab bar (grey capsule, purple active); rounded-square header buttons; sentence-case top-bar titles; 20pt gutter; cool grey page | Design Lab route; Demo Hub "Design" group | Done |
| B | Onboarding and auth | `01–08`, `o01–o39`, `p06–p07` | Figtree headings; purple Next button, radios, switches and pills; sentence-case field labels; tinted info cards | none: existing onboarding art kept | Done |
| C | Discovery | `16–17`, `d019–d027`, `f02–f05`, `x01–x12` | purple Like, brand-subtle SuperSwipe; purple progress | **solid photo panel replaces the gradient scrim**; panel tightened for long names; For You likes on the brand surface | Done |
| D | Events | `v01–v13`, `n07–n09` | 20pt cards; purple selected filters; floating tab bar | **purple uppercase date eyebrow** above titles; **floating RSVP bar** on detail; 16:9 covers kept | Done |
| E | Profile and management | `20–21`, `f17–f22`, `w01–w04`, `n10–n12` | neutral 176pt avatar; purple progress and primary | Opening Moves header slot | Done |
| F | Likes, matches, matching | `18`, `d054`, `d059`, `f06`, `d030–d032`, `f14` | grey tiles; purple "New" badges | **match portrait on brand-subtle with a purple initial**; like-gone and person-missing slots | Done |
| G | Messaging | `19`, `d034–d052`, `f07–f13`, `n01–n06`, `w05–w06`, `p02–p03` | purple own bubbles, white theirs; purple circular send; neutral avatars with a purple new-match ring | none beyond the system | Done |
| H | Account Health and visibility | `h01–h10` | tinted status cards; purple completeness bar | **activity as 2×2 metric tiles (Bevel)**; "Profile views" shown as "—" with "Not measured" | Done (see review: still list-heavy) |
| I | Safety, settings, account, premium, help | `22–23`, `f15–f16`, `f23–f41`, `p01`, `p04–p05`, `d112b–d113` | grouped white cards; purple switches; red destructive pills | Safety and Premium header slots; sheets at 28pt corners | Done |
| J | Remaining routes and states | QA renders `q145–q158`, `r01–r03`; not-found; offline | system-level only | | Done; nothing left in the old warm-stone style |

## Deliberate exceptions (previous treatment kept on purpose)
| Kept | Why |
|---|---|
| Existing SVG illustrations (onboarding, empty states, verification) | Drawings kept; **recoloured** to the monochrome palette with one purple accent. The V16 blue, warm greys and yellow were mapped to monochrome roles in all 12 SVGs. `tool/export_assets.mjs` now exports the same palette, so a re-export reproduces them. |
| Verification camera viewfinder (ink) | A camera surface should be dark. |
| Photo-viewer page dots (ink) | Neutral indicators; purple would compete with the photo. |
| Notification dots and destructive actions (red) | State colours, not brand. |
| Warning banners (amber tint) | A state colour, used only for "expiring" and "changed". |

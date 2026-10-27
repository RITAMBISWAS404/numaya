# Visual comparison: Numaya V16 (web) vs Flutter

**Reference:** the final V16 captures, `artifacts/version-16-design-experiment/final-polish/screenshots/states/`
(393 × 852 @2x, `?theme=withings`).
**Flutter:** `apps/numaya_mobile/test/screenshots/goldens/` (24 states), captured with
`flutter test --tags screenshots --run-skipped --update-goldens` at the same size with the bundled Hanken Grotesk and
Noto Color Emoji. These are renders from Flutter's test engine on Linux; a phone uses its own font rasteriser and
emoji font, so expect small anti-aliasing differences. This is a close match, not a pixel-perfect one.

| Sheet | Pairs |
|---|---|
| [v16-compare-onboarding.png](screenshots/v16-compare-onboarding.png) | Welcome · Basics (underage error) · Interests + prompt · Interests at 5/5 |
| [v16-compare-photos-prompt-empty.png](screenshots/v16-compare-photos-prompt-empty.png) | Photos · Prompt editor · Likes empty · Messages empty |
| [v16-compare-profile-settings.png](screenshots/v16-compare-profile-settings.png) | Profile · Edit profile · Settings · Delete sheet |
| [v16-compare-home-filters.png](screenshots/v16-compare-home-filters.png) | Filters sheet · Home empty |
| [v16-extended-auth-screens.png](screenshots/v16-extended-auth-screens.png) | Flutter only (V16 has no counterpart): Phone, Country sheet, Verify typing / error / success, Setup hub |

## Measured

Pixels sampled from both renders at the same coordinates: stone page `#F5F4F1` = `#F5F4F1`, step button `#121212` =
`#121212`, header bar `#FFFFFF` = `#FFFFFF`. Tokens are generated from the same JSON, and unit tests assert the
palette, type sizes and weights, and geometry (`test/unit/foundation_test.dart`).

## Matches

Stone page and white cards without borders · white flow header with hairline and ink progress · flow headings
(26 medium, balanced wrapping) · capital field labels · outlined fields with blue focus and red error · one-card
radio and checkbox groups · emoji chips with blue-tint selection and pastel set marks · "5/5 SELECTED" counter ·
prompt card with tint mark · photo grid with dashed empty slots and ink plus · ink step button and disabled grey ·
welcome emoji stickers and bold headline · tab-root titles · white empty-state cards with compact ink action ·
navy initials avatar, centred name, chips, outlined "Edit profile" pill · grouped settings rows, green switches,
white Log out / Delete account blocks · delete sheet with solid red and outlined cancel · filters sheet questions,
blue slider interval, white thumbs · tracked-capital modal headers ("EDIT PROFILE", "YOUR PROMPT", "SETTINGS").

## Remaining differences (deliberate or minor)

| Where | Difference | Reason |
|---|---|---|
| Tab bar | 4 tabs instead of 5 | No Activity feature |
| Edit profile | No Edit / Preview switch; no bio field | Not built; avoids dead controls |
| Profile | No readiness card or score badge | Inputs (bio) don't exist |
| Likes, Messages | No filter tabs | No data |
| Home | "No profiles to show yet" card instead of people or the filter-mismatch state | No matching backend; mock people are not shown |
| Content | Fields start empty; prompt shows "Tap to write your answer" | The web prototype is pre-filled with a sample profile |
| Welcome | Headline sits a few points lower | The hero takes the remaining height; same order and sizes |
| Interests (prompt card) | Flutter needs the answer before Next | Setup step promises "Three interests and one answer" |

## Fixed during comparison

1. Compact buttons ("Edit profile", "Go to Home") stretched full width → they hug their label.
2. Flow headings wrapped greedily ("…with the / basics") → balanced like the web ("…with / the basics").
3. Sheets opened above the tab bar → they cover it.
4. Slider thumbs drew a dark ring → white thumbs with the soft thumb shadow.
5. Welcome lede ran wider than `31ch` → capped.
6. An extra "That's 5" note under interests (not in V16) → removed; the counter states the limit.
7. Edit profile's photo note moved under the grid with an info icon, as V16.

# Visual comparison: approved web design vs Flutter (Phase 10)

Web: committed gallery `artifacts/ui-gallery/screens/` (393 × 852 @2x, approved default theme).
Flutter: `test/screenshots/goldens/` captured by `flutter test --tags screenshots --run-skipped --update-goldens` at the
same size with the bundled fonts. The Flutter captures are renders from the Flutter test engine on Linux; a phone
renders the same layout with its own font rasteriser.

| Sheet | Screens |
|---|---|
| [comparison-auth.png](screenshots/comparison-auth.png) | Welcome, Phone, Country sheet, Verify (typing) |
| [comparison-verify-basics.png](screenshots/comparison-verify-basics.png) | Verify error, Setup hub, Basics underage, Basics complete |
| [comparison-interests-photos.png](screenshots/comparison-interests-photos.png) | Interests + prompt, Photos |
| [flutter-app-shell.png](screenshots/flutter-app-shell.png) | Flutter only: Home, Filters, Profile, Settings, Prompt editor, Verify success |

## Findings

| Element | Match | Note |
|---|---|---|
| Colours (brand, surfaces, text, lavender cards) | Same | Generated from the same tokens |
| Type: Fraunces display, Inter text, sizes and weights | Same | Variable axes wght 520 / SOFT 50 / WONK 0 applied |
| Buttons, next button, nav buttons | Same geometry | Inset highlight omitted (no inset shadows in Flutter) |
| Fields, focus ring and halo, country badge | Same | |
| Code cells (empty, active caret, filled, error, success) | Same | Flutter keeps the wrong digits visible for 650 ms before clearing, like the web's timer |
| Option cards, radio, checkbox | Same | |
| Chips, chip sets, counter | Same | |
| Prompt card with quotation mark | Same | |
| Setup steps (Up next, done, upcoming) | Same | |
| Photo grid | Same | Fixed during review: tiles were tinted and showed an icon; now plain photo grey like the web |
| Progress segments | Same style | 5 steps throughout instead of the prototype's 4 then 6 |
| Title wrapping | Differs slightly | Web balances lines (`text-wrap: balance`); Flutter may break one word later |
| Welcome hero | Same (empty reserved slot) | |
| Verify | Adds a "Demo text message" banner | Development builds only |
| Basics, Interests | Start empty | The prototype is pre-filled with a sample profile |

Fixes made after comparing: photo tiles (above); the long dial code (+971) now scales inside the 120 pt country selector
instead of overflowing; the next button on Verify is disabled while a rejected code is still shown.

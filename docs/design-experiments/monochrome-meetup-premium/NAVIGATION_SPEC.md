# Navigation spec

## Tab bar: floating icon-only pill
**Implementation:** `NumayaTabBar` in `widgets/navigation.dart`, with `indicator: TabIndicatorStyle.tint`.

| Property | Value |
|---|---|
| Container | White pill, 64pt tall, `subtle` shadow, inset from the screen edges, in `bottomNavigationBar` (content does not scroll beneath it) |
| Items | Home, Events, Likes, Messages, Profile. **Icons only, 26pt.** |
| Item size | 52pt; on narrow screens it shrinks to 48pt minimum |
| Selected | Tint circle (`brandSubtle`) with a purple filled icon (`brandText`, 6.00:1, above the 3:1 needed for graphics) |
| Unselected | Muted outline icon |
| Badge | A red dot on the icon (Likes, Messages); also announced in the label |
| Semantics | Each item is `Semantics(button: true, selected: …)`, labelled with the tab name, or with its badge label when badged ("Likes, 2 new") |
| Tooltip | `Tooltip(message: label)` on every item (long-press on touch, hover on desktop) |
| Motion | The indicator cross-fades over `AppMotion.base`; instant under reduced motion |

**Variants compared:** tint, filled and expanded; all three are in the Design Lab. The reasoning is
in [DESIGN_EXPLORATIONS.md §2](DESIGN_EXPLORATIONS.md).

**Tests:** they find tabs by tooltip (`find.descendant(of: NumayaTabBar, matching: find.byTooltip(label))`).

## Top bar (app bar): one shared composition
There are two compositions, and every screen uses one of them.

| Kind | Layout |
|---|---|
| **Tab root** (Profile, Events, Likes, Messages) | A large page title (Jakarta 32/800) on the left, and up to two 46pt white rounded-square actions on the right. Home uses the wordmark in place of the title. |
| **Pushed or modal** (`NumayaTopBar`) | A 46pt white back or close button on the gutter; a centred Figtree 17/600 title (padded clear of the buttons); actions on the right. A hairline appears only once content scrolls under the bar. |

Further rules:
- Flows show purple step segments in place of a title.
- Sheets use the sheet header: a Jakarta 22pt title and a bare ✕, with no rule.

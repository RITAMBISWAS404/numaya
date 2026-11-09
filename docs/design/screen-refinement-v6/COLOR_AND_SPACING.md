# Spacing and colour, V6

## Spacing roles (pass 1)
Measured from Ente Updated screens, Settings `12099:96480` (375 wide), and library variables on Menu Item `2513:51496`.

| Role | Value | Source |
|---|---|---|
| Page inset | 20 (was 16) | Ente cards sit at x 20 to 354 on 375 |
| Card inset | 16 | `spacing/lg` |
| Section separation | 32 | Owner request; Ente uses 8 between groups, so this is intentional |
| Title to content | 12 | `spacing/md` |
| Related items, icon to label | 8 to 12 | `spacing/sm`, `spacing/md` |
| Label to value | 4 | `spacing/xs` |
| Chat bubble gap | 4 grouped, 12 between speakers (was 8) | V6 messaging |

Reviewed across 192 captures at contact-sheet scale, with no clipped content and consistent margins.
Known exception: the Discover photo's margin stays the page margin by default; a tighter 8 is in the gallery.

`rad-spacing` was not installed: GitHub reports no licence. Its proximity principle informed the role order.

## Semantic colour (pass 2)
Source: live Ente Colour tokens, `10871:4420`, light mode.

| Role | Old | New | Ente variable |
|---|---|---|---|
| Error anchor | #EB2D2F | #F63A3A | warning/default |
| Error text and destructive solid | #C42326 | #C22D2D | warning/darker #C52E2E, darkened slightly to pass 4.5:1 on neutral fill |
| Error icon | #DB2A2C | #DD3434 | warning/dark |
| Success anchor | #0D9F61 | #08C225 | primary/default |
| Success text and solid | #08774A | #047917 | primary/darker #057C18, darkened slightly to pass on neutral fill |
| Success icon | #0C8F57 | #069D1E | primary/dark |
| Warning anchor | #FF9B0F | #F08A1E | caution/default |
| Warning text | #8F5608 | #985712 | Derived: Ente has no darker caution role |
| Warning icon | #B86F0A | #BB6C17 | Derived |
| Information | #0E5FD9 | #0E5FD9, banners now use it instead of purple | info/dark |

Ente's pale tints were not adopted for success and error: they failed contrast with their text roles, and decorative tints are out of scope.

Selected country: solid purple row, white labels, no tick. High contrast adds a tick as a non-colour cue. The rendered state sheet is the Semantic specimen screen.

| Pair | Foreground | Background | Ratio | Needed | Result |
|---|---|---|---|---|---|
| White on selected country row and primary action | #FFFFFF | #7262C7 | 4.89:1 | 4.5:1 | pass |
| White on destructive solid | #FFFFFF | #C22D2D | 5.66:1 | 4.5:1 | pass |
| Error text on white | #C22D2D | #FFFFFF | 5.66:1 | 4.5:1 | pass |
| Error text on neutral fill | #C22D2D | #EAEAEA | 4.70:1 | 4.5:1 | pass |
| Error icon on white | #DD3434 | #FFFFFF | 4.55:1 | 3:1 | pass |
| White on success solid | #FFFFFF | #047917 | 5.59:1 | 4.5:1 | pass |
| Success text on neutral fill | #047917 | #EAEAEA | 4.65:1 | 4.5:1 | pass |
| Success icon on white | #069D1E | #FFFFFF | 3.59:1 | 3:1 | pass |
| Black on warning fill | #000000 | #F08A1E | 8.35:1 | 4.5:1 | pass |
| Warning text on neutral fill | #985712 | #EAEAEA | 4.70:1 | 4.5:1 | pass |
| Warning icon on white | #BB6C17 | #FFFFFF | 3.98:1 | 3:1 | pass |
| Information icon and text on white | #0E5FD9 | #FFFFFF | 5.74:1 | 4.5:1 | pass |
| White on raw Ente error | #FFFFFF | #F63A3A | 3.76:1 | 4.5:1 | fails, not used this way |
| White on raw Ente success | #FFFFFF | #08C225 | 2.39:1 | 4.5:1 | fails, not used this way |
| White on raw Ente caution | #FFFFFF | #F08A1E | 2.51:1 | 4.5:1 | fails, not used this way |
| Secondary text on white | #666666 | #FFFFFF | 5.74:1 | 4.5:1 | pass |
| Secondary text on canvas | #666666 | #F4F4F4 | 5.22:1 | 4.5:1 | pass |

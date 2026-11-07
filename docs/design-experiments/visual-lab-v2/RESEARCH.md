# Visual Lab V2: research record (2026-11-08)

Patterns only. No external screenshots are bundled; links are canonical Mobbin/Figma references.

## Ente Figma (file `22AeTw6QiPj2fNYHLhC7MK`, read live 2026-11-08 through the Figma MCP)
Connection verified (session created, page list and Design system page `57:6281` metadata read).
The design-system library search returned no published components, so components were read from
page frames. The metadata is frame-level only (no child geometry); measurements below come from
frame sizes plus readable screenshots of the named frames, not whole-canvas thumbnails.

| Node | Name | What was read | Flutter equivalent |
|---|---|---|---|
| `11439:5040` | Header (v2) | Expanded 343×80 (back arrow row, then large title + optional subtitle, trailing white squircle buttons); collapsed 343×38 (back, title inline, same trailing buttons) | `LargeTitlePage` (R12): expanded title under the leading control, collapses into the bar on scroll |
| `2472:5809` / `2475:5968` | Title Bar / Header | Inline title variants | `NumayaTopBar` (unchanged) |
| `7497:3078` | Tabs | 2- and 3-tab pill track, 326/368×49; white selected thumb on #DDD track; disabled state | `NumayaSegmented` (Heart tab, Insights periods) |
| `4809:8027`, `4809:7992` | Bottom sheet template / header | 20pt padding, header row 38 tall (title left, close right), 16pt to body, 48pt buttons 12 apart; close is a white circle with dark X on the grey sheet | `SheetCloseButton` (R08): white squircle matching header buttons, dark glyph |
| `7585:3109–3148` | 1–4 Segments | Usage bar split into coloured segments with a dot legend | Wallet variant A (stacked bar by bucket, spend order) |
| `14590:125265` | Banners | 351×66 Alert/Info/Neutral/without subtext; icon, title, subtitle, round arrow | `LabStatusBanner` O/A |
| `2207:42075` | Icon Button | Rounded-square icon button | `NavIconButton` (squircle family, R05/R08 size reference) |
| `4863:4744`, `7448:3167` | Count Badge, Badge | Count pill | `CountBadge` |

Fidelity limits: exact text styles of Header v2 were not extracted (no design-context call), so
the large title uses the existing approved `pageTitle` role (Plus Jakarta Sans) and the collapsed
title the approved `appBarTitle`. No unseen page is claimed as inspected.

## Mobbin (iOS, read 2026-11-08), one problem per search
| Problem | Reference | Borrow | Avoid |
|---|---|---|---|
| Intro requests inbox | [Reddit Requests](https://mobbin.com/screens/1b7bfa03-cac2-4261-8612-c22b2fe7f551) | Separate request cards: sender, quoted words, secondary Ignore + primary View | Nested tab rows three deep |
| Request answer | [Insight Timer Friends](https://mobbin.com/screens/0da4ee0b-c3bb-415f-b346-28a1771b9111) | Two equal actions under each request; requests separated from updates | Green brand colour |
| Segmented tabs with counts | [Phantom followers](https://mobbin.com/screens/4756c4ee-5184-4799-a2fa-07d808275cbd) | Count inside the tab label | Dark theme |
| Insights period and denominator | [Brainly Influence](https://mobbin.com/screens/36d76617-6e04-48db-b91e-f2428cae2485) | "Your stats from the last 7 days compared with the previous 7 days" line; zero states shown, not hidden | All-caps title |
| Metric rows with change | [Reddit Insights](https://mobbin.com/screens/e1f37a7f-a9eb-4923-9b41-55afa5811719) | "No change from previous 30 days" in words under each value | — |
| Range + tiles + bars | [X Account analytics](https://mobbin.com/screens/30df032b-1a73-482d-aca4-a7a6c22d8a3f) | Period chips, value tiles above one bar chart | Decorative axis gridlines, % without denominator |
| Empty insight | [How We Feel](https://mobbin.com/screens/e611f2d7-84ee-49b8-a6e3-fe54fdcf52fb) | Say when insights will appear instead of a fake chart | Huge decorative type |
| New matches row | [Bumble Chats](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74) | Circle avatars in a ring that empties; no number below; "Your move" chip in rows | Yellow |
| Name + verified | [Hinge My Hinge](https://mobbin.com/screens/774418cb-9a9b-4261-9f11-2b72d883bbbb) | Filled badge directly after the name in the header | — |
| Own profile header | [Mindtrip profile](https://mobbin.com/screens/528cd69b-458f-4be3-99ef-cfe9f718934f), [Doji](https://mobbin.com/screens/74971865-7252-43e3-b48b-e39b5c6d2146), [Discord](https://mobbin.com/screens/a8cc016f-f6fa-4b02-b826-cfb8281b9f3f) | Compact identity row with Edit (B); avatar + two equal buttons (O); banner with overlapping avatar (A) | Follower counts (no dating meaning) |

Brief 04 references (inspected by the brief author, used for structure): timespent activity cards,
Gentler Streak chart above summary tiles (not its all-caps), Google Health value + weekly bars in one
card (metric variant A).

## Behaviour evidence (brief 03/04)
Tinder discloses activity, preferences and likes as matching inputs; Hinge discloses Your Turn
Limits. Neither proves that ordinary non-reply or blocking secretly lowers anyone's reach. Numaya's
insights therefore never claim such causes.

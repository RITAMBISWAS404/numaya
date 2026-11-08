# Ente to Flutter component map, V4

Extends [the V3 map](../ente-alignment/COMPONENT_MAP.md), which still holds for families V4 did not
change. Figma was read live and read-only through the claude.ai connector.

| ID | Figma node | Measured reference | Flutter component | V4 change | Numaya override | Status |
|---|---|---|---|---|---|---|
| V01 | Memory card `6352:38350` | Radius 16, padding 12×16, gradient 53.66% to 89.96% ending 72% black, 14 bold white title | `PhotoScrim`, `PhotoLabel` | Gradient only, 10% edge, compact label | Under 25% cap | Changed |
| V02 | Images and memories `26580:107019` | White title and pills over image | `PhotoPill`, `PhotoGlass` (new) | Black glass, clipped blur | Black only, no tint | New |
| V03 | Badges `7435:15789` | White and green counters | `StatusBadge` | Solid semantic tones; on-photo tone becomes `PhotoPill` | Owner solid direction | Changed |
| V04 | Buttons `2207:41577` | Large and Small; primary, secondary, neutral, critical, link | `NumayaButton` | Brand variant on neutral fill, brand label | No lavender | Changed |
| V05 | Menu Item `2513:51496` | Grouped rows, subtitle is value or status | `ListRow`, `EvFact`, `IconTile` | Icon tiles neutral; glyph carries tone | None | Changed |
| V06 | Banners `14590:125265` | White card, filled status icon | `StatusBanner` | Sample banner on feed became a quiet caption | Demo notice | Changed |
| V07 | Header v2 `11439:5040` | Back, title, up to three 38pt actions | `NumayaTopBar`, `LargeTitlePage` | None | Fonts | Aligned |
| V08 | Toggle `2513:47857` | Track and knob | `NumayaSwitch` | None (owner SW-01 #D6D6D6 stands) | SW-01 | Aligned, logged |
| V09 | Filter chips `2513:47856` | Active, inactive, disclosure | `ViewTabs`, `EvDisclosureChip` | Active disclosure chip solid accent | None | Changed |
| V10 | Bottom sheet `4809:8074` | Radius 20, stacked actions | `showNumayaSheet` | None | None | Aligned |
| V11 | Colours `10871:4420` | Palette | `MonoColors`, `AppColors` | `photoScrimEdge` token | Owner anchors | Changed |
| V12 | Settings screen `12099:96480` | White grouped lists on grey | Settings, Profile lists | Inherited | None | Aligned |

Reference images are in the review folder's `references/figma`. Full dimensions for earlier families
are in `docs/design-experiments/ente-design-system/figma-type-icons/README.md`.

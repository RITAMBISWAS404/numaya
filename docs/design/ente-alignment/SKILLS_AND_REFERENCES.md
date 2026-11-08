# Skills and references (alignment V3)

## Skills
Inventory: 39 project skills in `.claude/skills/` (from commit `050a889`), plus user plugins
(dart-flutter official plugin, figma, frontend-design, ui-ux-pro-max). Already present and
relevant: `impeccable`, `emil-design-eng`, `prototype` (Emil), `break-ui`,
`design-review-workflow`, `widget-golden-and-a11y-testing`, `accessibility-as-code`,
`adaptive-layout`, and `dart-flutter:flutter-fix-layout-issues`.

**No new skills were installed in this pass.** The shortlisted thienqo/flutter-skills and
humbleteam/design-review were not installed; their roles (Figma-to-existing-component mapping,
screenshot critique, alternative prototyping) were covered by the method below and the existing
skills' guidance. R14 is therefore **partial**: inventory done, installation not done.

Method actually used: Figma rules page + variables → map to existing primitives before adding any
(only `NumayaButtonGroup` and `EvDisclosureChip` are new) → fix the shared primitive → render on
the emulator → critique the captures → fix → recapture (two correction rounds recorded in
ISSUES EA-Q02, EA-X01, EA-B02). Pilot: paired actions (People I met) and the event card.

## Figma (read-only)
`22AeTw6QiPj2fNYHLhC7MK`: pages 57:6281, 12099:96447; nodes 26553:8327 (rules), 2207:41577
(buttons), 4809:8074 (bottom sheets), 2513:47856 (tabs, filters, avatars), 2513:51496 (list
items), 2493:29332 (text fields), 14590:125265 (banners), 25943:237661 (action sheets),
12099:96480 (Settings). Variables read on 4809:8074 and 2207:41577.

## Mobbin (iOS, adapted to Android)
| Screen | Observation | Used in |
|---|---|---|
| [Apple Music concerts](https://mobbin.com/screens/22bd5dea-485c-472e-98cc-0b82f26aa701) | Date badge on a thumbnail, title, venue, date row | ea-event-card A/C |
| [Lightyear corporate events](https://mobbin.com/screens/8c3a2265-dda7-4b61-a699-227858eefc73) | Month/day tile leads a compact row | ea-event-card B |
| [Swiggy event search](https://mobbin.com/screens/0691edb9-4486-4b03-b4ad-11c72485e8f7) | Square cover, two-line title, date and venue | ea-event-card A |
| [Insight Timer retreat](https://mobbin.com/screens/a108ecf2-3f28-407a-a030-aeccf8ff8d11) | "From $950 · Only 4 spots" beside Reserve now | ea-event-action A |
| [Trainline ticket options](https://mobbin.com/screens/006cedf3-df91-4ecb-a875-87426d73603c) | Price summary left, Continue right | ea-event-action A |
| [Hinge Likes You](https://mobbin.com/screens/b0b5ab9f-b79d-404d-b79a-f0971b3da3c6) | Photo-led person cards | ea-met-card A |
| [Bumble Discover](https://mobbin.com/screens/7aea9888-2e9a-4bf8-b3f6-51516e86b2f6) | Photo card with a heart action | ea-met-card A/B |
| [DICE](https://mobbin.com/screens/c5ef6ad8-7fa5-48a5-b1d8-135abf1dd8c4), [StubHub](https://mobbin.com/screens/ce86d8f6-0d1c-4fa5-8d76-0288b648a4a8) | Compact filters (from the brief; not reopened) | ea-event-filters |

No competitor rules (ticketing, ranking, monetisation) or assets were taken.

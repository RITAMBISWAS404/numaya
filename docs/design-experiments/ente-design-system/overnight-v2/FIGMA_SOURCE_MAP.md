# Figma source map (overnight v2)

**File:** `22AeTw6QiPj2fNYHLhC7MK` (ENTE VISUAL DESIGN (Copy)), read-only. Inspected 2026-11-06 through
the Figma connector.

**What was read:** a full hierarchical index of both primary pages, plus readable renders of the
families and screens listed below. The cached XML and renders are in this session's scratchpad; they
are **not committed**, because of the file's artwork licensing (see Provenance).

**What exists already:** the Windows run mapped the foundations (colour 10871:4421, text styles
10854:4420, spacing 11107:37840, radius 11112:4508) and the core components. That table is in
`../README.md`, "Figma source map", and still applies. This file adds the primary-page inventory,
the families inspected in this pass and the source conflicts.

## Page 57:6281 "Design system": every top-level section
| Section (node) | Disposition | Note |
|---|---|---|
| Colours 10871:4420 | Inspected, relevant (mapped earlier) | `TOKENS.md` |
| Text styles 7672:54672 / 10854:4420 | Inspected, relevant (mapped earlier) | Numaya fonts substitute Outfit and Inter |
| spacing 11107:37840, radius 11112:4508 | **Inspected again** | 2/4/8/12/16/20/24; 4/12/16/20 |
| Buttons 2207:41577 (Large 2207:41759, Small, Icon, FAB, Disclosure) | **Inspected again** (Large at readable scale) | Primary, Secondary (fill), Neutral (black), Critical (red), link; default, pressed, disabled, loading, success |
| Textfield 2493:29332 (Text Input 2275:11526, Multiline, OTP, Warning) | **Inspected** (all states) | Default white with no stroke; focused 1pt grey (Numaya keeps its 2pt purple); error red; success green; disabled faded |
| Appbar and header 2513:47854 (Header v2 11439:5040, Title Bar) | **Inspected** | Back arrow over a large title, or back and title inline; 32pt white square actions |
| Tabs, filters and avatars 2513:47856 (Filter Chip 9524:4352, Tag examples, Avatar) | **Inspected** | Selected filter chip is a black pill with ✕; idle white; disabled faded |
| Radio, toggles, checkboxes 2513:47857 | Relevant (mapped earlier) | Switch off track: UI-025 override |
| Divider 5772:34405 | Relevant | `AppColors.divider` |
| List items 2513:51496 (Menu Item 4055:18734, menu item list 5906:38912) | **Inspected** | 52–60pt row cards; trailing more-menu, switch, check or value; white on grey, fill on white, outlined selected |
| Dropdown menu 2513:52763 | Inventory only | Numaya uses action sheets |
| Icons 4770:20147, Used Icons 11187:4760 | Inventory only | Lucide substitutes (approved) |
| Bottom sheet 4809:8074 (header 4809:7992, templates) | **Inspected** | Title on the left with ✕ (header 4809:7992); frame 5124:9067 is artwork only |
| Action sheet (v1) 5910:43260 | Legacy | Superseded by v2 |
| **Action sheet (v2) 25313:7157 / 25316:7380** | **Inspected → OV-03** | Attached white sheet, handle, tile row, divider, icon rows, destructive red |
| All bottom action sheets 25943:237661 | Inventory | Photo-specific layouts |
| Snack bar 7255:38447 | Inventory | Numaya has no snack bar (toasts) |
| **Toast 9377:5294 / 9409:4000** | **Inspected → OV-04** | Tinted status pills and a neutral white pill with ink text |
| **Banners 14590:125265 / 14590:125245** | **Inspected → OV-01** | White r20 card, status icon top-aligned, status-coloured title, muted body, round arrow; single-line and progress variants |
| Slider 7435:14483 | Relevant (UI-005/024 done earlier) | |
| Stepper 7449:29872 | Relevant | Onboarding progress segments |
| Bar graph 7570:3701 | Irrelevant | No charts in Numaya |
| progress dialog 9417:46645 | Inventory | Numaya has no blocking progress dialog |
| Skeleton 9417:46681, Loading 7884:3459 | Inventory | Numaya loads locally; no skeletons yet (gap noted) |
| Date and time picker 7500:3658 | Inventory | The event form uses platform pickers |
| Components not being used yet 11025:18820 | Irrelevant | |
| Header 2475:5968, Top section 7778:38497, Tabs 7497:3078, Status Bar 4852:4588 | Inventory ("Others") | |
| About 25843:7360, How to use this system 26553:8327, Landing page 26580:268163 | Inventory | Guidance and marketing |
| Ente Photos components: Album grid, Memory card, Photo view, Comment bubble 5427:23934, Feed, Badges 7435:15789, Navigation 7634:54339, Photo grid | Comment bubble and Navigation relevant (mapped earlier); Badges inspected at inventory; the rest are photo-storage features, irrelevant | |
| Ducky product catalog 14583:6595, Rewind sections (30834:8414 and others), Glow background, Superseded screens 31228:8414, Section 2 | Irrelevant / legacy | Off-canvas product boards |

## Page 12099:96447 "Updated screens (design system)"
| Section (node) | Disposition | What it decided |
|---|---|---|
| **Settings 12099:96479** (Settings DS updated 12099:96480, Account 12099:96630, Search 12099:96649, Files empty-state DS) | **Inspected → OV-02** | Grey page; related rows share one white r16–20 card, 60pt rows, no dividers, 8pt between groups; single-row cards for standalone items; destructive row in red; title-under-back header |
| **Section 3 (Login and onboarding) 26580:258404** | **Inspected** | Illustration band, then a grey panel; back and title inline; labelled fields; full-width primary; OTP cells; plan cards. Numaya keeps the UI-009 stacked illustration |
| Landing page variants 26580:258405 | Inventory | Onboarding hero |
| **Empty states variants 26580:259932** | **Inspected** | Large title, tabs, centred illustration, 20/28 title, muted body, full-width primary. `EmptyState` already matches |
| Home screen (×4), Landing page 28754:219714 | Inventory | Feed and nav (nav mapped earlier) |
| Image and memory view, Album share, All bottom action sheets, Sections 1/10/11 | Irrelevant | Photo-storage features |

## Source conflicts
- **Menu grouping:** the menu item list (5906:38912) gives each row its own card; the newer Settings
  (DS updated) groups related rows. **The newer screen wins (OV-02).** Selectable option lists keep
  separate cards under the explicit review rule UI-003.
- **Action sheet Cancel:** v2 has no Cancel row. Numaya keeps a quiet Cancel row below Ente's divider,
  as the explicit accessible exit.
- **Focus edge:** Ente draws a 1pt grey focus edge; Numaya keeps its 2pt purple (approved earlier).

## Provenance
Figma renders were used as references only and are not copied into the app or the repository.
Ente's artwork (the duck illustrations) is not reused. Numaya's illustrations are its own approved
assets.

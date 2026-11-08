# Ente → Flutter component map (alignment V3, 2026-11-08)

Source: Figma `22AeTw6QiPj2fNYHLhC7MK`, pages **Design system** `57:6281` and **Updated screens**
`12099:96447`, read live (read-only) with the claude.ai Figma connector. The page's own usage rules
("How to use this system", `26553:8327`) were read in full and govern intent.

**Page inventory.** Design system: *Start here* (rules), *Ente components* (core: current), *Ente
Photos components* (product-specific: not used by Numaya), mascot/illustration and marketing
boards (not used: no mascot art in Numaya), *Others*. Updated screens: shipped Photos screens
(Settings `12099:96480`, albums, home, search, sharing) plus dark/marketing boards. "Components not
being used yet" and superseded screens are not precedent (per the rules page).

Status: **Aligned** = matches the reference (or the documented Numaya override); **Fixed** =
changed in this pass; **Override** = intentional Numaya difference; **Not used** = family absent.

| ID | Figma node / variant | Flutter component / file | Call sites | Mismatch found | Correction | Numaya override | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| C01 | Buttons `2207:41577` (Large/Small; Primary, Secondary, Neutral, Critical, Tertiary critical, Link) | `NumayaButton` `widgets/buttons.dart` | ~200 | Button Small inside `Expanded` stayed content-width (Pressable centres its child), so paired actions floated apart | `expand` now applies to small buttons; default unchanged | Primary is purple, not green | qa/04, qa/05; `ente_alignment_test` | **Fixed** (EA-B01) |
| C02 | Action groups: sheet stacks (`4809:8074`), peer rows in shipped screens | `NumayaButtonGroup` (new) | People I met, Compliment request + inbox variants, Heart likes, staff review | Ad-hoc `Row`/`Expanded` pairs | Equal widths, 12pt (spacing/md) gap; stacks when narrow / large text | none | qa/04, large-360-met-actions | **Fixed** |
| C03 | Yes/no bottom sheet: stacked Button Large, main on top, Cancel (Secondary) below; Critical only for remove/leave/stop | `showNumayaSheet` + confirm buttons | cancel reservation, Compliment dismiss (2) | Main action same grey weight as Cancel; dismiss used Primary purple | Critical (`destructiveSolid`) for removals | Sign-out keeps Primary (reversible) | qa/07 | **Fixed** (EA-B02) |
| C04 | Bottom sheet header `4809:8074`: title, white close control, sheet padding xl 20, corners xl 20 | `showNumayaSheet` `widgets/content.dart` | all sheets | Corner radius 24 | `MonoRadii.sheet` 20 | Close is the approved squircle (R08), not a circle | qa/06, qa/07 | **Fixed** (EA-S01) |
| C05 | Menu Item `2513:51496`: subtitle is a value/status; picker row ends in a selection tick | `ListRow` `widgets/navigation.dart` | all lists | City picker showed "✓" text and a chevron | `selected:` → filled brand tick, no chevron, `selected` semantics | Tick is purple (brand) | qa/06; test EA-L01 | **Fixed** (EA-L01) |
| C06 | Banners `14590:125265`: white card, filled status icon, status-coloured title, muted subtext | `StatusBanner`, `LabStatusBanner` | ~40 | Icons used text-role colours | Icons use derived *icon* roles; titles the *text* roles | Info icon is brand | qa/01, qa/08, qa/09 | **Fixed** (colour) / Aligned (anatomy) |
| C07 | Badges `7435:15789` | `StatusBadge` `widgets/people.dart` | ~60 | No semantic tones | `success`/`warning`/`error` tones (tint + text role) | Neutral/brand kept | qa/02 | **Fixed** |
| C08 | Text input `2493:29332`: white fill, dark focus border, red error border + message, green success | `NumayaTextField` | forms | none (error uses the new red text role) | — | — | qa/02 | Aligned |
| C09 | Filter chips / tabs `2513:47856` (active/inactive/disabled; disclosure chip) | `ViewTabs`, `NumayaChip`, `EvDisclosureChip` (new) | Heart, Chats, Events | Single-choice filters must not use the multi-select chip | Disclosure chip added for the A filter alternative; B uses `ViewTabs` | Selected = purple | screens/ea-event-filters | Aligned (+ alternatives) |
| C10 | Header v2 (`2513:47854`): back, title 24 SemiBold, up to three 38pt icon buttons | `NumayaTopBar`, `LargeTitlePage` | all pages | none found in this pass | — | Plus Jakarta Sans titles | screens/* | Aligned |
| C11 | Navigation `7634:54339` | `NumayaTabBar` | shell | none: five tabs fit at 320pt (UC-03 test) | — | Floating pill, purple-neutral selected tile | qa/11; `ui_consistency_test` | Aligned |
| C12 | Toggle `2513:47857` | `NumayaSwitch` | settings, Events | Off track #D6D6D6 below 3:1 (known SW-01) | Not restyled (owner decision); logged | SW-01 | — | Override (logged) |
| C13 | Colours `10871:4420`; warning/success/caution roles | `MonoColors` / `AppColors` | app-wide | Old states (#C52E2E, #036614, #8A5A00) not the owner's anchors | Anchors + derived roles ([FOUNDATIONS.md](FOUNDATIONS.md)) | Owner anchors replace Ente red/green/yellow | qa/01; tests EA-C01 | **Fixed** (EA-C01) |
| C14 | Text styles `7672:54672` (Inter 20/18/16/14/12/10) | `AppTypography` | app-wide | Inter vs Figtree/Plus Jakarta; 14 vs 15 body | none | Approved fonts and 15px body (H-08) | — | Override |
| C15 | Toast / Snack bar `7255:38447`, `9377:5294` | `NumayaToast` | app-wide | none checked in depth | — | — | — | Unverified (not inspected in depth) |
| C16 | Action sheet v2 `25313:7157`, all action sheets `25943:237661` | `showNumayaActionSheet` | Chat/Compliment options | none checked in depth | — | — | — | Unverified |
| C17 | Dividers `5772:34405`, Dropdown `2513:52763` | `ListGroup` dividers; no dropdown | — | — | — | — | — | Aligned / Not used |

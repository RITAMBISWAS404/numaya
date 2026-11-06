# Ente design system experiment

This experiment rebuilds Numaya's Flutter app as if its screens had been drawn with the Ente component system. The parts come from four sources:

- **Ente** sets the geometry, type sizes, spacing, radii, surfaces and component states.
- **Numaya** keeps its purple, its fonts, its content and its features.
- **Lucide** supplies every icon.
- **Bumble** remains the reference for flow and layout.

## Baseline and status

| | |
|---|---|
| Branch | `experiment/numaya-ente-design-system` (worktree `C:\Users\biswa\Downloads\numaya\numaya-ente`) |
| Baseline | `f2e18e627af9f06e9563db5bf09828995dcde5c4` (`origin/experiment/numaya-overnight-polish`) **plus** the reviewed, uncommitted final-design-run patch (`numaya-final-design/artifacts/final-design-run/patches/final-design-run.patch`, 23 files, applied cleanly). That patch was the newest intended candidate, so the experiment starts from it rather than from the bare commit |
| Status | Implemented and verified locally. **Uncommitted and not pushed**: this run has no publication authorisation |
| Export | `artifacts/ente-design-system/patches/ente-design-system.patch` (`git apply` on `f2e18e6`; it contains the final-design-run changes too) |
| Figma source | `22AeTw6QiPj2fNYHLhC7MK`, page `57:6281`. Read only; nothing in it was changed |

The token mapping and its exceptions are in [TOKENS.md](TOKENS.md).

## Figma source map

These nodes were checked in this session with `get_metadata`, `get_variable_defs` and `get_design_context`.

| Area | Node | What was taken |
|---|---|---|
| Colour variables | 10871:4421 | Full variable set (TOKENS.md) |
| Text styles | 10854:4420 | Display-1/2/3, H1, H2, Large, Body, Mini, Tiny |
| Spacing / Radius | 11107:37840 / 11112:4508 | 2–24 scale; 4 / 12 / 16 / 20 |
| Button Large | 2207:41760 / 41831 / 41833 / 41835 / 41955 | 52 tall, 24 insets, r20, Body label; Primary, Secondary, Neutral, Critical, Disabled |
| Icon Button | 2207:42076, 5518:37854 | 38 (2 + 8 + 18 glyph), r12; Circular for sheet close |
| Toggle / Checkbox / Radio | 2482:6644 / 2482:6649 / 2482:6625 | Geometry, on and off fills, 16pt marks with r4 |
| Menu Item / Menu Item Icon | 4055:18733 / 4055:5652 | 60 tall, 12 padding, 36 leading slot with a coloured glyph and no tile, Mini subtitle, 24 chevron |
| Menu item list | 5906:38912 | Rows are separate r20 cards, 8 apart |
| Filter Chip / Tag Chip | 9524:4352 / 2482:6479 | 40 pill vs 44 r16; selected reverse vs primary |
| Text Input | 7560:3231 | 52, r16, 16 insets, label above, required asterisk |
| Nav Bar | 7634:54194 | 62, r20, white, 15 insets, active tile fill, shadow 0 4 8.75 / 25% |
| Header (v2) | 11439:5076, collapsed 11441:5208 | Back arrow, left title, 38pt action group |
| Bottom Sheet Header | 4809:7991 | H1 title on the left, circular close, padding 20, no grabber |
| Comment Bubble | 5412:23548 / 5412:23575 | r20 with a 6 corner; primary for your own, grey for others |
| Empty states page | 20943:133321 | Looked at, not reused (see the asset register) |

Each component's Figma description (its "USE FOR / NOT FOR / HOW" note) was read and followed. Examples: one primary per surface, a subtitle is a value rather than a sentence, colour sits on the glyph rather than on a tile.

## Component mapping (Flutter)

| Numaya widget | Ente component | Notes |
|---|---|---|
| `NumayaButton` | Button Large / Small | Primary is Numaya purple, Secondary is fill/dark, Critical is warning/darker. Labels still wrap at large text (FD-B1) |
| `NavIconButton` | Icon Button (Primary / Unfilled / Circular) | New `NavButtonStyle.circular`. Visible tile is 38 inside a 44 hit area |
| `NumayaTopBar` | Header (v2), Collapsed | Bare back arrow (Lucide `arrowLeft`), title on the left, actions on the right. Flow steps keep their progress segments |
| `NumayaTabBar` | Nav Bar | New `TabBarSurface.ente`, now the default. Frosted and opaque stay as comparisons in the Design Lab |
| `ListRow` / `ListGroup` | Menu Item / menu item list | Each row is its own r20 card, 8 apart. Rows on a sheet stay flush with hairlines |
| `IconTile` | Menu Item Icon | Glyph only, in its meaning's colour; neutral uses text/light |
| `NumayaSwitch` | Toggle Switch | 1.5×, with a 3:1 off-edge (exception ED-06) |
| `_ChoiceMark` | Checkbox / Radio | 20pt, r5 |
| `NumayaChip` | Filter Chip | Reverse (ink) when selected, with a clear cross |
| `ViewTabs` | Tag Chip | Purple when selected, Body label, 44 tall |
| `InputSurface`, `NumayaSearchField`, `Composer` field | Text Input | White, r16, 1pt control outline, 2pt purple focus |
| `showNumayaSheet` | Bottom Sheet Header + template | No grabber, circular close, padding 20, r24 top |
| `MessageBubble` | Comment Bubble | Mirrored 6pt corner for your own messages |
| `DecisionBar` | Button Large (inline) / Icon Button Circular (floating) | |
| Icons (`NumayaIcon`, `MobileIcon`) | Lucide via `kLucideIcons` | One map in `icons/lucide_icons.dart`. The Material map is deleted |

## Decisions and exceptions

- **ED-01: Ente's primary role is Numaya purple.** Every place Ente uses green for "primary" uses purple instead: Primary button, selected Tag Chip, switch on, checkbox on, your own bubble. Success keeps a darker green, info keeps blue, and danger keeps Ente's darker red.
- **ED-02: Fonts.** Ente's display face, Outfit, becomes Plus Jakarta Sans, used for Display-1/2/3 and page titles. Its text face, Inter, becomes Figtree. Sizes, line heights and weights are Ente's. Body becomes medium (500), which shows up in every paragraph.
- **ED-03: Lucide is stroke-only.** Where the old Material set filled a glyph to show state (active tab, saved heart, selected star), the state is now carried by colour and by the control's own surface. The `outline:` flag stays at call sites as documentation. Package: `lucide_icons_flutter` 4.0.1 (MIT; Lucide glyphs ISC), pinned to a version two weeks old. The day-old 4.0.2 was not used.
- **ED-04: The active tab is Numaya tint and purple, not Ente's neutral grey.** With no filled glyph, a grey tile alone was too weak a signal for "you are here".
- **ED-05: Sizes scaled up for phone legibility (NX).**
  - The switch is 46 × 27 (1.5×) and checkboxes and radios are 20 (1.25×).
  - Icon glyphs are 20 instead of 18, because Lucide's 2px stroke looked spindly at 18.
  - Chat bubbles use 16/12 insets instead of 16 all round.
- **ED-06: Accessibility over fidelity.**
  - The control outline is #8A8A8A instead of #969696 (2.96:1).
  - The switch off-track keeps a 3:1 edge.
  - Disabled text is #8A8A8A instead of #D6D6D6.
  - Every hit area stays at least 44, and text fields and the composer are padded to 48 or more.
- **ED-07: The header follows Ente's Collapsed Header (v2)**, not the Expanded 24pt title. Inner pages already open with their own heading ("Date with confidence"), so an Expanded header would show the title twice.
- **ED-08: Ente's duck mascot was not reused.** It is Ente's brand character, and the Figma file says nothing about its licence. Numaya's replaceable `IllustrationSlot`s stay hidden on product screens (FD-A1), and its existing illustrations are unchanged.

## Reconstruction pass (ER)

A second pass rebuilt the screens that kept their old layout. Route-by-route status, the Bumble flows that were actually inspected and decisions ER-01 to ER-07 are in [TRACKER.md](TRACKER.md). In short:

- **Discovery:** Bumble's full-screen photo card, with the identity and "You both like" on the photo, a permanent floating decision row, the wordmark on the left and options on the photo.
- **Liked and person profiles:** the same card.
- **Chats:** search sits behind a header icon, and the list headings are smaller.
- **Likes:** the lede is removed.
- **Profile tab:** the tile grid became Menu Item rows.
- **Filters:** each question is grouped in an outlined card.
- **Content pass:** the coach card, the repeated sample notes, the completion lede, the safety lede, the Opening Moves footnote and duplicate heading, and the prompt caption are gone. The chat demo note is cut to one line.

Evidence: `sheets/R3-a.jpg` and `sheets/R3-b.jpg` (final, against the pre-Ente baseline), and `sheets/R1-discover.jpg` and `R2-*.jpg` (intermediate).

## Bumble (Mobbin) check

I searched Mobbin and looked at the actual Bumble screens returned:

- discovery card ([1](https://mobbin.com/screens/ee54d57a-33f7-4f05-ba27-012f9f74eb48), [2](https://mobbin.com/screens/83e93b49-e15d-462c-ae89-810a4613cea0));
- Liked You with counted filter chips ([3](https://mobbin.com/screens/ee33fda3-1add-46fd-8c57-855f48f89c87));
- profile editing rows with "Add" values ([4](https://mobbin.com/screens/fc35bf13-823e-4331-a922-4882f5d67e7a)).

Earlier runs already rebuilt these journeys on Bumble's structure. In each case the Ente components drop into that structure without changing the flow:

| Journey | Bumble evidence | Ente component used |
|---|---|---|
| Discovery | Photo card with a name overlay; detail cards scroll beneath | Hero card |
| Likes | Counted chips ("Really into you • 12") | Tag Chips |
| Profile editing | Label-and-value rows with a chevron | Menu Items |

No hidden interaction was inferred from a static screenshot.

## Screen coverage

| Coverage | How |
|---|---|
| Every route in the router | Rendered at 320, 375, 390 and 430pt and 100 to 200% text (`size_matrix_test`, `route_sweep_test`, `overnight_stress_test`). All pass |
| 17 screens on the emulator, before and after | Pixel 10 at 390dp, captured on device (below) |
| Route-specific widgets | Discover's floating buttons, event footer, match, onboarding steps and the Demo Hub inherit from the shared components. No per-screen styling was added |

## Evidence

All evidence is in `artifacts/ente-design-system/`:

| Item | Path |
|---|---|
| Before (final-design candidate, 390dp) | `device/baseline/` |
| First pass (E1) | `device/E1/` |
| Final (E2) | `device/E2/` |
| Narrow phone, large text | `device/E2-320dp-150/` (320dp, 150%) |
| Before/after sheets | `sheets/E1-a,b,c.jpg` (first pass), `sheets/E2-a.jpg` and `sheets/E2-b.jpg` (final) |
| APKs | `Numaya-ente-debug.apk` (SHA-256 `fbc36342…1968`) and `Numaya-ente-release-debugsigned.apk` (`e0ced8cc…3592`). Not for commit |

## Verification (this run)

| Check | Result |
|---|---|
| `dart format` | Clean |
| `flutter analyze` | No issues |
| `node tool/generate_tokens.mjs --check` | Unaffected: generated tokens untouched. The Ente values live in the hand-authored token file |
| `flutter test` | **361 passed, 15 skipped, 0 failed** (includes 5 new tests in `ente_design_system_test.dart`) |
| `accessibility_tools` audit | 0 issues on 14 routes |
| Emulator | Pixel 10, Android 16 (API 36): two full journeys, one narrow, large-text journey, and a recheck of the search fix (`device/E3-checks/`) |
| `flutter build apk --release` | Builds (56.9 MB). Signed with debug keys, because there is no release signing config |

**Test changes.**

- *Tests updated to the Ente contract.* Tests that pinned the old Monochrome/Meetup spec now check the Ente values. These include token values, type roles, chip and tag geometry, the tab corner, rows as cards, and the header style.
- *Real problems found by the existing suite and fixed.* The tab bar overflowed at 320pt, because the 38pt tiles were measured without their 44pt hit areas. The Discover wordmark ran 2pt under Filters at 320pt for the same reason. The Design Lab bar overflowed. And at the smaller 14pt input text, the phone field and the composer fell under 48dp.
- *Found on the device and fixed.* On Messages at 320dp and 150% text, the search placeholder wrapped and was cut in half by the 52pt field. It now stays on one line, with a regression test shown to fail without the fix.

**Goldens.** The committed screenshot goldens are Linux renders of the old look. They were not regenerated here, because Windows renders differ from Linux by renderer alone. Regenerate them on Linux or CI after review.

## Remaining and release items

- **Not checked:** a physical phone, live TalkBack speech, iOS and frame timing.
- **Illustrations:** they still need final Numaya artwork. No Ente artwork shipped (ED-08).
- **Release blockers, unchanged:**
  - no backend, authentication or moderation;
  - no release signing;
  - no privacy review.

  Screenshots and tests do not make this releasable.

## Run and compare

```bash
cd apps/numaya_mobile
flutter run            # Ente experiment
```

To compare, install `artifacts/ente-design-system/Numaya-ente-debug.apk` beside the previous candidate's `numaya-final-design/artifacts/final-design-run/build/Numaya-final-design-debug.apk`. Both use the same package name, so install one at a time. The Design Lab (Demo Hub → Design) shows every component, plus the frosted and opaque navigation for comparison.

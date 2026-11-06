# Tabler MVP pass: decisions, Figma evidence and exceptions

**Branch:** `experiment/numaya-tabler-mvp-20261106-1725`, from the V4 baseline `ea86a08d076e5d4964fd7f9f8ecb8a6117b1098e` (branch `experiment/numaya-ente-polish-v4-20261106-0724`).
- V3, V4 and their worktrees are untouched.
- The experiment choices (EXP-001–004) remain **pending**. All Current/A/B/C variants still render, and none was selected.

## Figma evidence
File: [ENTE VISUAL DESIGN (Copy)](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=57-6281)

| Node | What was read | How it was applied |
|---|---|---|
| [Design system 57:6281](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=57-6281) | Page inventory | Starting point |
| [Updated screens 12099:96447](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=12099-96447) | Light-mode screens: toolbars, rows, sheets, settings | Outline glyphs at rest; filled glyphs only for state and emphasis |
| [Navigation 7634:54339](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=7634-54339) / [Nav=Home 7634:54194](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=7634-54194) | A white 314×62 bar, 38×38 icon-button tiles 82pt apart (centres), 15pt from the ends. The selected tile is filled black on a light grey rounded square; the others are outlines. | The bar is 62pt with 38pt tiles in 48pt slots, a 10pt inset and 34pt gaps (the gaps shrink at 320pt). The selected tile is `iconSelectedFill` with the filled glyph in `iconSelected`. |
| [Used Icons 11187:4760](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=11187-4760) | Ente uses Hugeicons, thin outline, at 20–24pt | Tabler outline at Tabler's default stroke, at the existing role sizes |
| [Banners 14590:125245](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=14590-125245) | Filled status glyph in the semantic colour, vertically centred on the banner's text block, on a white card | `StatusBanner` and `InfoCard`: filled 20pt glyph, centred on the full content height |

Not verified in Figma: keyboard focus styling and the disabled icon colour. Ente shows neither, so the existing Numaya focus ring and `disabledText` role were kept.

## Decisions
| ID | Decision | Supersedes |
|---|---|---|
| TB-01 | Tabler Icons 3.50.0, bundled SVGs ([ICON_MAP.md](ICON_MAP.md)). | The Lucide requirement (`lucide_icons_flutter` 4.0.1 is removed) |
| TB-02 | The selected tab is a **filled** glyph in near-black (`AppColors.iconSelected`, the text colour) on a **very light neutral tile** (`AppColors.iconSelectedFill`, the existing neutral fill), shaped with the icon-button radius. Unselected tabs are **outline** glyphs in light grey `iconInactive #8A8A8A`, 3.46:1 on white (above the 3:1 non-text minimum). Selection is carried by shape (filled vs outline, tile vs none) as well as colour, and is announced through `Semantics(selected: true, button: true)` with the tab's label. | The tinted selection treatment; the UI-026/027 bar geometry |
| TB-03 | Alert icons (`StatusBanner` and `InfoCard`) are filled and **vertically centred against the full content height**. Short, multiline, with-action and 200%-text cases are tested. | **UI-010** (first-line top alignment); OV-01's "top-aligned" detail |
| TB-04 | Events is gated off ([EVENTS_GATE.md](EVENTS_GATE.md)). | — |
| TB-05 | Tab gaps give way before the row would scroll. At 320pt the 314pt bar overflowed the 288pt available, which clipped Profile. Found in the narrow sweep; a test proves the fix. | — |

## Exceptions
- **No filled twin.** Thirty-two roles have no filled state, either because Tabler has no solid artwork for the glyph or because the role is never emphasised. Examples: close (`x`), chevrons, `ban`, `eye-off`, `progress`, `share`. These always draw the outline. A selected or emphasised state never uses one of them: all four tab icons and all twelve alert icons have filled twins, which `tabler_mvp_test` checks. The dormant Events tab icon (`calendar-heart`) has none, so it stays outline when selected if Events is turned back on.
- **Pending alerts use `clock`.** `NumayaIcons.pending` is Tabler `progress`, a dashed ring, kept for incomplete rows as on V4. Tabler has no filled `progress`, so `StatusBanner`'s pending tone (in review, expiring soon, can't check yet) draws the filled `clock`. An hourglass was tried and rejected: it read as "waiting" on the completeness rows, which mean "incomplete".
- **`mobile.attach` reuses `plus`.** The composer's attach control keeps the plus metaphor from V4.
- **`event` (calendar-heart) is kept** for date-related actions ("Did you meet?", the Safety tips row). It is not an Events entry point.
- **Emoji pills (UI-019) are kept.** They are content, not icons.
- **Non-icon assets are kept:** the logo, the mascot cat, illustrations and user photos.
- **`iconInactive` uses its own token.** `#8A8A8A` is close to `disabledText` but is a separate token, so disabled and inactive can diverge later.
- **The Events source still uses `NavIconButton(filled: saved)`.** It was updated with the shared API and is dormant until the gate is turned on.

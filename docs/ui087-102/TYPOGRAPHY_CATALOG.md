# Typography and icon catalog (UI-012, UI-070, UI-074, UI-085, UI-088)

The finite set the app uses after this phase. Source of truth: `lib/core/design_system/foundations/app_typography.dart`
and `app_colors.dart`. Sizes are logical points and scale with the system text size.

## Text roles

Group: **D** = display family (follows the UI-085 pairing's display face), **U** = UI family.

| Role (`AppTypography.`) | Use | Group | Size/line | Weight | Colour role |
| --- | --- | --- | --- | --- | --- |
| hero | Name over a photo, Welcome | D | 32/40 | 700 | primary (white on photos) |
| largeTitle | Expanded tab-root large title | D | 30/36 | 700 | primary |
| pageTitle, flowTitle, headline | Tab-root titles, onboarding headings, result titles, Profile name | D | 24/32 | 700 | primary |
| emptyTitle | Status and empty-state heading (UI-094) | D | 20/28 | 600 | primary |
| sheetTitle | Sheet titles | D | 20/28 | 600 | primary |
| appBarTitle | Pushed-page bar title | U (PJS at baseline) | 20/28 | 700 | primary |
| section | Section heading in a page | U (PJS at baseline) | 18/24 | 600 | primary |
| card | Card title | U | 18/24 | 600 | primary |
| answer, cardPrimary | Bio and prompt answers | U | 18/26, 18/24 | 500 | primary |
| headerCaps | Small heading (Filters questions, Messages list labels) | U | 16/20 | 600 | primary |
| body, bodySm, row, input | Reading text, list rows, typed text | U | 15/20 (14/20 with the toggle) | 500 | primary |
| helper | Supporting sentence, tip, lede | U | 15/20 | 500 | secondary |
| label, fieldLabel | Chip and field labels | U | 15/20 | 500 | secondary / primary |
| button, buttonSm | Button labels | U | 15/20 | 600 | per button |
| caption | Metadata: counters, timestamps, row details, field notes, step footers | U | 12/16 | 500 | **tertiary** |
| micro | Smallest metadata (Compliment meta line, badges) | U | 12/16 | 500 | tertiary |
| pill, chip | Pill labels | U | 12/16 | 500 | per pill |
| metric | Large numbers | D | 40/44 | 700 | primary |

Placeholders use their field's own role (same face, size, weight, line) in the tertiary grey (UI-012 V8).

**Metadata is smaller than body and subheadings** (12 vs 15/16/18), and now also lighter in colour.

**Unresolved baseline conflict.** The register's original UI-012 text names 14 px as the standard. The verified build
default is 15 (owner's X15 decision, 2026-11-07) with the owner's 14/15 Dev Mode toggle. The default was not changed;
the toggle remains for the decision.

## Text colour roles (UI-012, new in this phase)

| Role | Hex | White | Page #F4F4F4 | Fill #EAEAEA | Use |
| --- | --- | --- | --- | --- | --- |
| textPrimary | #000000 | 21:1 | 19.3:1 | 17.6:1 | Headings, main information, typed values |
| textSecondary | #4D4D4D | 8.45:1 | 7.69:1 | 7.03:1 | Supporting copy, subtitles, helper sentences, chip labels |
| textTertiary (= textMuted) | #666666 | 5.74:1 | 5.22:1 | 4.77:1 | Metadata, counters, timestamps, placeholders, previews |

Context colours keep their own tokens: actions (brand text), errors (negative), text on photos (white).

## Icon system (UI-070, UI-088)

| Category | Treatment | Size | Colour | Shared source |
| --- | --- | --- | --- | --- |
| Menu and list-card row leading icons (Profile menu, Settings, Streak tasks, Repair, credit balance and history, InfoList) | **Outline** (UI-088) | 24 | supporting grey #666666 (`iconInactive`; corrected 2026-11-15, QR-008), red on destructive rows | `ListRow`, `InfoList` |
| Premium "What's included" benefit glyphs | **Outline** (UI-088) | 20 | brand | `PremiumScreen._v8.glyph` |
| Conversation preview type glyphs (photo, video, voice) | **Filled** (UI-070) | 16 | tertiary grey | `ConversationRow` V8 |
| Compliment preview glyph | Outline (Tabler has no filled message-heart; nothing invented) | 16 | tertiary grey | `ConversationRow` V8 |
| Chat media controls (voice play/pause in bubble and preview, video play) | **Filled** (UI-070) | 20-28 | brand / white | `chat_voice.dart`, `chat_attachments.dart` |
| Inline countdown clock | Filled (compact) | 16 | secondary, warning under 2 h | `CountdownBanner` |
| Informational card icon | Filled | 24 | brand or tone colour | `InfoCardLayout` |
| Tab bar | Filled when selected, outline idle | 24 | near-black / grey | `NumayaTabBar` |
| Status template art | Outline | 36 | ink | `EmptyState` callers |

**Compact cutoff (design decision, not an approved number):** glyphs at 16 pt and below, and media controls of any
size, are filled; larger glyphs are outline unless their category says otherwise. The menu/list-row category (UI-088)
overrides size: its 24 pt glyphs are always outline.

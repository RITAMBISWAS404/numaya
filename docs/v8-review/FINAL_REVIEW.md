# V8 UI review: final report (14 November 2026)

## Status first
- **Not a production build.** A debug review APK with the on-device demo world. The real backend is still BLOCKED (no Supabase project, phone OTP not configured, no billing client, no push), so nothing here is verified against a server.
- **Emulator only.** The Pixel 10 emulator; no physical phone.
- **Choices are yours.** Every layout alternative is in the gallery and in Prototype tools; none is preselected. The 14/15 body size defaults to 15 and is a separate control.

## Source
- **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (worktree), app `apps/numaya_mobile`.
- **Branch:** `experiment/numaya-v8-review-20261114-0321`, from `7cd7aa4` (the selected designs, app source `ae10663`); pre-run tag `checkpoint/selected-20261114-0321`.
- **App source:** `@@APPSHA@@`. Later commits change only tests, tooling and records.
- **Inputs:** NUMAYA_V8_UI_REVIEW_HANDOFF.zip and NUMAYA_V8_EXECUTION_COMPANION.zip (hashes in RUN_STATE.md).

## Outputs
- **Review folder:** `@@OUT@@`
  - `screens-flat/`: @@NSHOTS@@ emulator PNGs (1080 x 2424, density 420, font 1.0), numbered 0001 onwards.
  - `gallery/index.html`: offline, selectable, notes, JSON export/import; @@NGALLERY@@ harness renders.
  - `apk/@@APKNAME@@` (debug, demo entry, SHA-256 in BUILD_INFO.md).
  - `ISSUE_STATUS.md`, `TEST_RESULTS.md`, `OPEN_DECISIONS.md`, `COVERAGE.md`, `SCREEN_INDEX.md`, `BUILD_INFO.md`, `HANDOFF.md`.

## The 14/15 body size and fonts (your latest decision)
Prototype tools > Typography: Base body size (14 or 15, default 15), Display font (Default, Fraunces, Instrument Serif, DM Serif Display), UI font (Default, Manrope, Poppins) and Reset. Each is independent and kept on the phone across relaunches; release builds always use the defaults. The body size changes only the body tier (reading text, list rows, fields and their placeholders, field labels, chip labels, helper sentences) at the same 20pt line; headings, buttons, metadata, metrics and icons keep their sizes. Single-weight serifs (Instrument Serif, DM Serif Display) are never bolded synthetically. All five fonts are bundled (SIL OFL 1.1, licences beside the files), so nothing needs a network.

## What changed (by area)
- **Shared system:** radius roles 4/8/12/16/20 (UI-050); compact 20/12 navigation with 38 x 48 tiles (UI-026); one inset divider inside grouped cards (UI-003); outlined, muted disabled buttons (UI-057); lighter secondary outline (UI-002); filled, borderless callouts (UI-060); compact 8pt buttons (UI-062); filled compact glyphs in rows (UI-070); a darker shared photo gradient (UI-066).
- **Onboarding:** Welcome card corners show against the image (UI-001); no inline age (UI-052); Photo tips as an icon list (UI-053); Interests count only in the footer (UI-054); placeholder = answer style (UI-007/012); no Save helper line (UI-055).
- **Profiles:** owner preview = public profile (UI-058); content order photo, bio, photo 2, prompt 1 ... location (UI-059).
- **Discover, Likes:** illustrated Premium promo in Filters and Settings (UI-061); slider/fallback dividers; verified card inset (UI-044); one-column Likes (UI-064); blurred free Likes (UI-065).
- **Messages, Chat:** one list with a Your move pill, muted previews, filled type glyphs, no row times (UI-067/068/035); square new-match tiles (UI-033); one Archive row with its count, archived chats only (UI-069/081); bubbles hug their text, no time at rest (UI-079/035); quote at half inset with nested corners (UI-071); outlined round composer controls and one input fill (UI-072/073); countdown-only banner, Extend moved to the chat menu (UI-086); Compliments written in the recipient's chat (UI-083).
- **MVP scope:** For you and Travel unreachable, deep links included (UI-063/075).
- **Alternatives (your choice):** Premium x3 (UI-076), statistics templates x6 (UI-078), Match x6 (UI-082), Profile x10 (UI-084), typography (UI-085).

Issue-by-issue status with criteria, code and evidence: `ISSUE_LEDGER.csv` (in the repo and the review folder).

## Tests
@@TESTS@@

## Limitations
- Backend, OTP, billing and push: BLOCKED; Compliment sends, purchases and reports are on-device demo behaviour.
- Emulator only; widget-harness renders for alternatives (labelled as such).
- 3 and 6-month Premium prices pending; mascot and Premium artwork pending (reserved slots).
- Partial audits (UI-041, 048, 049, 051, 053, 055, 056, 070, 074, 077) are listed with what was not covered in the ledger.
- Tabler has no filled Compliment glyph; it stays outline.
- Private demo photos appear in the screenshots, gallery and APK, which therefore stay local and are not backed up off this computer.

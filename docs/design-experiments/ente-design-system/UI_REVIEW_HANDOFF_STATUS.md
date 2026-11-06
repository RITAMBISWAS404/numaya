# Numaya UI review: implementation status

This file tracks implementation separately from the review register. [NUMAYA_UI_REVIEW.md](NUMAYA_UI_REVIEW.md) and its issue IDs are unchanged.

## Baseline

| | |
|---|---|
| Repository | `RITAMBISWAS404/numaya`, worktree `C:\Users\biswa\Downloads\numaya\numaya-ente` |
| Branch | `experiment/numaya-ente-design-system` (the current Ente experiment) |
| Commit | `f2e18e627af9f06e9563db5bf09828995dcde5c4` plus the uncommitted Ente experiment work. This handoff was implemented on top of that working tree |
| Recovery | `artifacts/ente-design-system/patches/ente-design-system.patch` (before this work) and `ui-review-handoff.patch` (with it). Both apply to `f2e18e6` |
| Device | Pixel 10 emulator, Android 16 (API 36). Main evidence at 390 × 875 dp (density 443), robustness evidence at 320 dp with 150% text |
| Git | Uncommitted, not pushed |

## Status by issue

| Issue | Status | Scope completed | Code or components changed | Evidence | Remaining |
|---|---|---|---|---|---|
| UI-001 | **Partially blocked** | Upper region rebuilt as one large branded-image area. Demo build badge removed. Headline, subheading, both account actions and the legal copy sit in one white card with 24 pt rounded top corners. Demo builds open the Demo Hub by tapping the image, with the same accessible name | `welcome_screen.dart`: new `WelcomeBrandImage` slot, sticker hero and `DemoBadge` removed | `after/390dp/UI-001__get-started__after.png`, `after/320dp-150pct/UI-001__get-started__after.png` | **Final artwork.** No approved image with the Numaya name exists in the project. `WelcomeBrandImage` draws the existing code-drawn mark and wordmark as **temporary artwork**, clearly marked in the code. Swap in the approved asset when supplied; the layout doesn't change |
| UI-002 | **Verified** | `NumayaButtonVariant.quiet` (standalone secondary) is now drawn as the shared light-grey filled secondary button, 52 pt tall, below the purple primary. It applies to every quiet usage | `buttons.dart` | `UI-001__get-started__after.png`, `UI-009__signup-setup-verify__after.png`, `UI-002-UI-009__verify-photo__after.png`; test "a standalone secondary action is a filled button" | None |
| UI-003 | **Verified** | `OptionGroup` rows are separate white cards 8 pt apart on the page. On a white sheet they use light dividers instead, because white cards would be invisible there. Selected, unselected, disabled and multiline states are unchanged in behaviour and semantics | `selection.dart` | `UI-003__signup-setup-meet__after.png`, `UI-003-UI-010__delete-account__options-and-alert.png`, `UI-003__help-contact__options.png` | None |
| UI-004 | **Verified** | On Meet, the age label, range read-out and slider share one dedicated card. In Filters the slider already sat inside its outlined question card, so no extra card was nested | `looking_for_screens.dart`; new shared `AgeRangeSlider` | `UI-003__signup-setup-meet__after.png`, `UI-004-UI-005__filters__age-thumb-active.png`; test "label, read-out and slider share one card" | None |
| UI-005 | **Verified** | While a thumb is pressed or dragged, a pop-up above that thumb shows its exact age. The other thumb shows nothing. The value updates continuously. It uses Flutter's own value indicator, drawn in the overlay so the card doesn't clip it. The active thumb is the one nearer the press, then whichever end changes. Bounds and the two-year minimum gap are unchanged. Values are still announced (`semanticFormatterCallback`). Used in Meet and Filters | `age_range_slider.dart` | `UI-005__age-range__lower-thumb-active.png`, `UI-005__age-range__upper-thumb-active.png`, `UI-004-UI-005__filters__age-thumb-active.png`; test "each thumb shows its own exact age while it moves" | Closely positioned thumbs, plus the minimum and maximum values, were reasoned through rather than captured |
| UI-006 | **Verified** | "Add my height" removed. An inline wheel is usable on arrival, in cm and ft/in, with a subtle grey band on the selected row. The wheel rests on the saved height, or 170 cm when none is saved, without recording it. Skip clears the height. Returning shows the saved value. Rounding is to the nearest whole inch and the nearest whole cm. The 140–210 cm limits are unchanged. "Remove height" stays as an inline link | `looking_for_screens.dart` (`HeightWheel`), new `height_units.dart` | `UI-006__height__centimeters.png`, `UI-006__height__feet-inches.png`; tests "usable on arrival…", "scrolling records…", "Skip leaves height unset…", "one rounding rule…" | None |
| UI-007 | **Verified** | The prompt question is a small muted label (Body 14), and the answer is the dominant text (H1 20/28). The speech-bubble icon is removed and the chevron kept. On empty cards, "Add a prompt" is the small label and "Tap to write your answer" stays body-sized and muted, so it never reads as an answer. Profile prompt sections now use the same card | `content.dart` (`PromptCard`), `person_profile.dart` | `UI-007__signup-setup-prompts__after.png`, `…__answered.png`, `UI-007__profile-tab__prompt-card.png`, `UI-007-UI-011__person-profile__prompt-and-photo.png`, `UI-011__discovery__portrait-photo.png`; test "prompt card: small label above a dominant answer, no icon" | Exclusion: the Opening Moves promo card in Messages is a promotion, not a prompt display, so its icon stays |
| UI-008 | **Partially blocked** (only the unclear phrase) | Category tabs: Dating, About me, Opinions, Weekends, with 11 prompts each. The 6 original prompts are kept and the rest are original copy. Each prompt is a separate card with a chevron. Tapping one opens a sheet titled with that exact prompt, with the answer field below it, a 150-character limit and counter, and Save. Save writes to the intended slot. Reopening starts on the saved prompt's category and marks it "Your current prompt"; its sheet starts with the saved answer. Closing (✕ or swipe) changes nothing. A prompt answered in another slot can't be chosen. The sheet resizes for the keyboard | `prompt_editor_screen.dart` (rewritten), `profile_draft.dart` (`kPromptCategories`), 2 strings | `UI-008__prompts__category-browse.png`, `…__category-opinions.png`, `…__answer-sheet.png`, `…__answer-typed.png` (real keyboard); tests "categories with ten or more prompts…", "select, write, save…; reopen edits it; close keeps it" | **"three-day-to-time-driven response"** is unresolved and not implemented (no timer or expiry was assumed). Unsaved drafts follow the app's existing rule: closing discards them |
| UI-009 | **Verified** | Heading illustrations move out from beside the heading into their own 96 pt square region above it, upper left. This is in the shared `ScreenHeader`, so every consumer changes | `layout.dart` (`ScreenHeader`) | `UI-009__signup-setup-verify__after.png`, `UI-009__signup-setup-name__after.png`; test "heading illustration sits above the heading" | None. Empty-state art was already above its title |
| UI-010 | **Superseded** by the Tabler MVP pass (TB-03, `tabler-mvp/DECISIONS.md`): alert icons are now filled and vertically centred on the full content height. The original record follows. Was **Verified** | `InfoCard` icon is top-aligned with the first line, with the body under the title beside the icon. `StatusBanner` icon is 20 pt to align with its first 20 pt line | `content.dart` (`InfoCard`), `extras.dart` (`StatusBanner`) | `UI-009__signup-setup-verify__after.png`, `UI-003-UI-010__delete-account__options-and-alert.png`, `UI-010__premium__alert.png`; test "alert icon aligns with the first line" | None |
| UI-011 | **Verified** | Full profile photos are now a 3:4 portrait at full content width: Discover card, liked-profile and person-profile cards, additional profile photos, and the photo viewer. Because the Discover photo no longer reaches the bottom of the screen, its decision row sits inline under the photo and floats only once you scroll past (the earlier pattern), so nothing covers the first card | `app_layout.dart` (`AppMedia.personPhoto = 3/4`), `person_profile.dart`, `discover_screen.dart` | `UI-011__discovery__portrait-photo.png`, `UI-007-UI-011__person-profile__prompt-and-photo.png` | Exclusions: chat photo messages (`AppMedia.chatPhoto`), For you list thumbnails (`AppMedia.listThumbnail`), avatars, the upload grid, the match celebration photo (square) and decorative art |
| UI-012 | **Verified** | Body text stays 14 (Ente Body 14/20). One-off sizes were mapped to roles: | `visibility_screen`, `country_sheet`, `home_shell`, `toast`, `fields`, `content`, `selection`, `welcome_screen`, `app_typography` | Device sheets; full test suite | Exception kept: the avatar initial on Profile (40) is sized to its 96 pt avatar. It's avatar art, not a text role |

The UI-012 mappings:
- visibility score 52 → metric 40;
- country sheet 16/22 → row 14/20;
- tab title override → page title 24/32;
- toast 14/18 → Body;
- photo order tag and country code 11 → Mini 12;
- code cells 24 → headline;
- hidden code field 16 → input;
- Welcome headline 36–44 → hero 32/40, and the one-off style was removed.

## App-wide usage checklist

| Rule | Owner | Usages covered |
|---|---|---|
| UI-002 | `NumayaButtonVariant.quiet` | welcome, verify (code), reauth, match, about-you, finish (verify, notifications), settings-more, verification |
| UI-003 | `OptionGroup` | safety sheets (on a sheet, dividers), demo hub, events, event detail, help (contact), filters sheet (dividers), about-you, basics, looking-for, permission prompt, profile editors, settings-more, settings |
| UI-004/005 | `AgeRangeSlider` | onboarding Meet, Filters. These are the only two age-range sliders |
| UI-007 | `PromptCard` | onboarding prompts, Edit profile, profile tab, Opening Moves, chat opening move, person and liked profiles, Discover |
| UI-009 | `ScreenHeader(art:)` | about-you intro, verify offer, notifications primer, interests |
| UI-010 | `InfoCard` (14 files), `StatusBanner` (15 files) | All, through the shared widgets. No local alert variants were found |
| UI-011 | `AppMedia.personPhoto`, `PersonHeroCard`, `PhotoPlaceholder` default | Discover, liked profile, person profile and its photos, photo viewer |

## Verification

- **Checks:** `dart format` clean, `generate_tokens --check` up to date, `flutter analyze` clean, `flutter test` **373 passed, 15 skipped, 0 failed**. New targeted tests are in `test/widget/ui_review_handoff_test.dart`, and 7 existing tests were updated to the new flows.
- **Emulator:** after screenshots are in `numaya-ui-review/after/390dp/` (22) and `after/320dp-150pct/` (18), with sheets in `after/sheets/`:
  - `onboarding-before-after.jpg` pairs every original A-001 to A-006 screenshot with its after shots;
  - `app-wide-rollout.jpg` shows the non-onboarding consumers.

  The original images in `assets/` are untouched.
- **Found and fixed during verification:**
  - the height wheel's grey band hid the selected value;
  - the slider showed pop-ups over both thumbs;
  - the always-floating Discover row covered the first card once the photo became 3:4.
- **Capture artifacts:** the crosshair on slider shots is Android's touch overlay from injected touches. At 320 dp, the "Opinions" tab sits partly off-screen in the scrolling tab row, so the narrow run couldn't tap it, and it has no answer-sheet shots.
- **Not verified:** a physical phone, iOS, TalkBack speech, and screenshot goldens (they are Linux renders of the earlier design and need regenerating there).

## Clarification needed

**UI-008:** what should "three-day-to-time-driven response" mean in the prompt pop-up? It hasn't been implemented. Everything else in UI-008 is done.

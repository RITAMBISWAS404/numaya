# Discovery QA report

Branch `experiment/numaya-discovery-complete`, from `experiment/numaya-onboarding-complete` @
`e4f0f5f`. The app is in `apps/numaya_mobile/`; the web prototype is unchanged.

- Screens and states: [DISCOVERY_SCREEN_INVENTORY.md](DISCOVERY_SCREEN_INVENTORY.md).
- Nothing in this pass ran on a phone or emulator: there is no Android SDK in this environment.

## What changed

| Area | Change | Files |
|---|---|---|
| Photos | New photo viewer: swipe or Previous / Next, "Photo N of M", dots, back closes. Opened from the card (which now shows "N photos") or from any photo in the profile | `photo_viewer_screen.dart` (new), `person_profile.dart`, `routes.dart`, `router.dart` |
| Reading a profile | Tapping the name band ("Show more about {name}") scrolls to the profile. A bar under the header shows progress. Pass / SuperSwipe / Like float over the profile once the card has scrolled away, then hide near the inline row (mounted only while shown or fading). Android back returns to the top first | `discover_screen.dart`, `tab_screens.dart` (overlay slot) |
| First visit | A dismissible tip on the card; it is gone after the first decision | `discover_screen.dart`, `dating_controller.dart` (`coachDone`) |
| Undo | Brings back the last pass at the front of the queue, with "{name} is back". This also covers passes made from For you, which sit later in the deck | `dating_controller.dart` (`front`, `undo()` returns the person) |
| Show them again | Brings back passes only; liked people stay liked | `dating_controller.dart` (`liked`, `passedCount`) |
| Exhausted feed | When everyone seen was liked, the empty state says so, offers no "show again" and points to Likes | `discover_screen.dart` |
| Filters | Reset returns to the sign-up preferences (who to meet, age range). The Filters button gets a mark and the label "Filters, changed from your preferences" when the filters differ | `discovery_filters.dart`, `filters_sheet.dart`, `looking_for_screens.dart` (one argument: `asDefaults: true`) |
| Report / block | "Report or block {name}" link at the end of every profile | `discover_screen.dart` |
| Error | After a failed retry: "Still can't load profiles" | `discover_screen.dart` |
| Toasts | Discover's toasts sit under the header (`NumayaToast.show(belowHeader: true)`) | `toast.dart`, `discover_screen.dart`, `filters_sheet.dart` |
| Design system | `NavIconButton` greys its icon when it has no handler (used by the viewer's Previous / Next) | `buttons.dart` |
| Copy | 16 strings | `app_en.arb` |

## Defects found and fixed

| # | Found by | Defect | Fix |
|---|---|---|---|
| DQ-1 | Reading the controller | **Show them again** cleared every decision, so people already liked came back and could be liked twice | Track likes; bring back passes only (DD-7) |
| DQ-2 | Reading the filters | **Reset** went to app defaults (24–38, everyone), dropping the member's own "who to meet" and age range from sign-up | Reset to the sign-up preferences (DD-10) |
| DQ-3 | Reading the controller | Undo after a pass made from For you returned the person at their deck position, behind others | Undone person goes first (DD-5) |
| DQ-4 | Code reading | Exhausted feed with no passes offered "Show them again", which did nothing | Separate state pointing to Likes (DD-6) |
| DQ-5 | Capture x08 | Discover's toasts (undo, liked, filters saved) were drawn over the tab bar labels; at the footer height they covered the name band instead | Under the header (DD-13) |
| DQ-6 | Capture `d030` diff (58%) | A hidden floating bar stayed in the tree, so "the last Like" found the hidden one and the tap missed | The bar is removed once it has faded out |
| DQ-7 | Captures | Repeated retries looked identical, so it wasn't clear the retry ran | Title changes after a failed retry |

## Tests

| Check | Result |
|---|---|
| `dart format` | clean (123 files) |
| `flutter analyze` | No issues found |
| `flutter test` | **167 passed, 5 skipped** (skips: the 5 opt-in capture tests). Was 152 passed, 4 skipped on the base branch |
| Captures (`--tags screenshots --run-skipped`) | **7 passed**, checked against the committed images without `--update-goldens` after the review below |
| `npm run tokens:check` | OK |
| APK, emulator, device | Not run (no Android SDK) |

**New tests**

`test/widget/discovery_test.dart` (9):
- onboarding into Discover: tip, photo count, Hide tip, no "changed" mark;
- photo viewer: from the card, Next, swipe, Previous, back, and a section photo opening at itself;
- reading a profile: no tappable Pass over the card; floating Pass after "Show more"; a floating decision resets to the next card's top; system back returns to the top and Home stays;
- undo: toast, one step, nothing to undo after a like;
- SuperSwipe: credits count down, a match or a toast, then the paywall with none left;
- report and block from the end-of-profile link;
- exhausted with everyone liked → no "show again", "See who likes you" opens Likes;
- exhausted after passes → "Show them again" brings back the passes only;
- the name band and photos are labelled buttons.

Also: the photo viewer joins the accessibility route sweep (`accessibility_test`: tap targets, labels, 130% text).

`test/unit/dating_controller_test.dart` (+6):
- undo out of deck order;
- undo for passes only;
- show again keeps likes;
- the tip;
- reset to sign-up preferences;
- filters changing the queue.

**Updated tests (intended behaviour changes, no assertion loosened):**
- `dating_test`: the widened-filters check taps "Filters, changed from your preferences", and the error check expects "Still can't load profiles" after a failed retry.
- `full_app_journeys_test`: Reset is reached through the changed label.

**Existing coverage kept:**
- swipe threshold, fling and spring-back (`dating_test`, `motion_test`);
- like / match / keep browsing (`dating_test`);
- the filters' live count and fallback (`full_app_journeys_test`);
- snoozed Home (`dating_test`);
- accessibility guidelines and 130% text on `/home` and `/for-you` (`accessibility_test`);
- worst-case data at 320 pt (`break_ui_test`).

## Captures

New: `apps/numaya_mobile/test/screenshots/goldens/x01`–`x12`. Contact sheets: `docs/mobile/screenshots/discovery-1.png`–`discovery-3.png`.

| Capture | State |
|---|---|
| x01, x02 | First card with the tip; after Hide tip |
| x03 | Reading: progress bar, floating actions |
| x04 | End of the profile: inline actions, "Report or block Maya" |
| x05 | Report / Block options from that link |
| x06, x07 | Photo viewer, photo 1 and 2 |
| x08 | Undo: "Maya is back" under the header |
| x09 | Filters changed mark |
| x10, x11 | Seen everyone: with passes; all liked |
| x12 | Error after a failed retry |

**Existing captures that changed (each compared with the base commit before accepting):**

| Capture | Change | Verdict |
|---|---|---|
| 16-home, d019, f02 | Tip and "4 photos" on the first card | Intended |
| q145 (375 × 667) | Same; the tip wraps to two lines and fits | Intended |
| d021, d022 | Progress bar under the header; "Report or block Maya" above the sample note | Intended |
| d027 | Same, under the options sheet | Intended |

## Remaining gaps

**Needs a device:**
- swipe feel and fling velocity;
- haptic strength;
- the floating bar over real photos;
- TalkBack order with the floating bar;
- photo viewer paging with real images.

**Placeholders:** photos are grey placeholders, so photo navigation shows position, not content.

**Accepted visual notes:**
- The floating bar has no scrim; over a placeholder the centre image icon can show between buttons (x03).
- On narrow phones the under-header toast can touch the "N photos" badge while it is shown (2.2 s).

**Product decisions still open:**
- whether Undo is premium (P-05);
- liking a specific photo or prompt;
- notes with a like;
- quick filter chips.

**Out of scope:** Settings toasts still use the bottom position (`aboveFooter: false`) over the tab bar; recorded for the Settings pass.

**Not persisted:** decisions, undo and filters last for the session only (in memory), like the rest of the demo.

## Build and run (Windows)

```powershell
cd <repo>
git fetch origin
git checkout experiment/numaya-discovery-complete
cd apps\numaya_mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug      # universal APK (see ANDROID_COMPATIBILITY.md)
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

**Try it:**
1. Create an account (the code shows in the demo banner), or use Demo hub › Start a new sign-up.
2. Finish onboarding, then tap **Start discovering**.
3. On Home:
   - swipe or use the buttons;
   - tap the photo for the viewer;
   - tap the name to read the profile;
   - pass and Undo;
   - open Filters, change something and Reset;
   - use "Report or block" at the end of a profile.
4. Demo hub › Simulate connection problems shows the error and retry.

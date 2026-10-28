# UI polish backlog

Defects and polish items found in the quality pass, with their priority and status. **P1** breaks a
journey or hides content, **P2** is visible and wrong, **P3** is small. Sources: the code audit, worst-case
data (`test/helpers/worst_case.dart`), 200% text, the captures, and the motion audit
([MOTION_DESIGN_AUDIT.md](MOTION_DESIGN_AUDIT.md)).

## Fixed

| # | P | Area | Defect | Fix | Evidence |
|---|---|---|---|---|---|
| U-01 | P1 | Every route | No page transitions anywhere. go_router 18 detects the app type through `material_ui`, misses Flutter's `MaterialApp` and builds zero-duration pages | Pages built explicitly as `MaterialPage`; token-driven slide; modal rise for match, paywall, Premium, verification | `motion_test.dart` "a page push slides in…" |
| U-02 | P1 | Chat | Long conversations opened at the oldest message; the keyboard could cover the latest | List anchored to the newest message (`reverse`) | `motion_test.dart` "opens at the newest message…" |
| U-03 | P2 | Chat | On send, the list scrolled before the new bubble was laid out and stopped short of it | Scroll after layout, only if the person had scrolled up | same test |
| U-04 | P2 | Home | Like / Pass / SuperSwipe replaced the profile in the same frame; a released swipe snapped back before deciding | Exit in the decision's direction, settle-in for the next; card leaves from the release point | `motion_test.dart` "Discover decisions" |
| U-05 | P2 | Settings, Edit profile, every `ListRow` with a value | A long value (work, school, a 60-character answer) overflowed the row by up to 302 pt | Value capped at 60% of the row and two lines; label keeps the rest | `break_ui_test.dart` |
| U-06 | P2 | Every tappable `ListRow` | Screen readers heard only the label ("Travel"), not the value or detail ("Premium") | Label, value and detail read together | — (semantics) |
| U-07 | P2 | Welcome at 200% text | Content overflowed the screen by 242 pt; the Demo badge row by 17 pt | Page scrolls when it doesn't fit; the hero gives up its space first; header wraps | `break_ui_test.dart` (Welcome is the first screen) |
| U-08 | P2 | Home, Likes, preview at 200% text | Badges ("Sample profile", "Verified") overflowed by 121 pt; the distance line by 3 pt | Badges grow and wrap; distance text flexible | `break_ui_test.dart` |
| U-09 | P2 | Profile preview with a long name at 200% text | The name band squeezed the photo to nothing and overflowed by 77 pt | The card keeps its design height and grows when the band needs more | `break_ui_test.dart` |
| U-10 | P3 | Code input | The caret kept blinking, and the toast's busy dots kept looping, under reduced motion | Both stop under reduced motion | `motion_test.dart` |
| U-11 | P3 | Completion ring | Jumped to the new percentage | Arc fills from its old value | — |
| U-12 | P3 | Haptics | None in the app | One gated map: selection, commit, reject, success | `motion_test.dart` "Haptics" |
| U-13 | P3 | Captures | `f25` caught the verification spinner at an empty phase | Captured at a legible phase | `f25-verify-pending.png` |

## Open

| # | P | Area | Item | Why it's open |
|---|---|---|---|---|
| O-01 | P3 | Basics | The first-name field has no length limit. A 25-character hyphenated name works everywhere tested; something far longer would wrap to three lines on the profile card | Resolved on `experiment/numaya-onboarding-complete`: 30 characters, letters only (`ProfileRules.maxNameLength`, `nameProblem`) |
| O-02 | P3 | Names | "Mary-Elizabeth Anne-Marie" wraps at the hyphen ("Anne-" / "Marie") | Correct typographically; the alternative (no break) would overflow. No change |
| O-03 | P3 | Badges | Their text line height is 1.1 instead of 1, so badge text sits 1 pt lower than in the V16 captures | Needed so wrapped badge text doesn't collide; within the 1 pt tolerance used elsewhere |
| O-04 | P2 | Device | Keyboard insets, real gesture velocity, haptic strength, TalkBack order, notch safe areas | Need a phone or emulator; the Android SDK can't be downloaded here |
| O-05 | P3 | Swipe | The card snaps back on a short release with the ease-out curve, not a spring carrying the release velocity | Feel needs checking on a device before tuning; the current return is under 250 ms and interruptible |
| O-06 | P3 | Dark mode | Not designed in V16 | Out of scope (documented since the foundation pass) |

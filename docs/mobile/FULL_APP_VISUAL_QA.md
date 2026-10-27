# Full app visual QA

Branch `experiment/numaya-flutter-full-app`. Method as in [VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md): Flutter
renders from widget-test captures (real app, bundled Hanken Grotesk and Noto Color Emoji) at 393 × 852 @2x,
compared side by side with the V16 web captures where one exists. **No pixel-perfect parity is claimed.** Nothing
was run on a phone or emulator (no Android SDK in this environment).

## Evidence

| Set | Where | How it's made |
|---|---|---|
| V16 references | `artifacts/version-16-design-experiment/final-polish/screenshots/states/` | Web captures (unchanged) |
| Onboarding and shell, fresh account | `apps/numaya_mobile/test/screenshots/goldens/01`–`23` | `capture_screens_test.dart` |
| Dating screens named after their V16 capture | `goldens/d019`–`d113`, small screen `q145`–`q158` | `capture_screens_test.dart` |
| **Full app, 41 screens and states** | `goldens/f01`–`f41` | `capture_full_app_test.dart` (quick start in the full demo world) |
| Contact sheets of the full app | `docs/mobile/screenshots/full-app-1.png` … `full-app-4.png` | from the `f` captures |
| V16 side-by-side sheets | `docs/mobile/screenshots/v16-compare-*.png` | previous pass, still valid |

```bash
cd apps/numaya_mobile
flutter test --tags screenshots --run-skipped --update-goldens test/screenshots
```

## Screens with a V16 reference (re-checked after this pass)

All `d` and `q` captures were regenerated and compared again with V16 019–158. They still match as described in
[VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md); the only changes are deliberate extensions:

| V16 | Change in this pass | Why |
|---|---|---|
| 019 Discover header | A "For you" button (✦) at the left of the wordmark | Curated picks (B-33, Mobbin "Discover"); Numaya keeps four tabs, so For you is a sub-view of Home |
| 023 Filters sheet | Basic / Advanced view tabs; switch rows for the fallbacks; who-to-date chips; "Verified profiles only" | B-34 / B-35 (Mobbin "Filtering people"); V16 geometry kept (22pt questions, blue interval, ink button, outlined Reset) |
| 034 Messages | Countdown rings on the queue, a likes tile, expired matches, an Opening Moves card, real Unread / Your move counts, times and unread badges | B-42 / B-43 (Mobbin "Chats") |
| 038 Conversation | The other person's white bubbles, day lines and times in sample conversations, a "Sample conversation" tag | B-44 |
| 042 New match | Time-left banner with Extend, their Opening Move as a prompt card | B-47, B-41 |
| 113 Settings | Snooze opens a length sheet and an away-status sheet; the row shows "Until … · status"; Incognito, Location / Travel, more groups | B-70–B-72 (Mobbin "Settings", "Activating snooze mode") |

## Screens without a V16 reference

These extend V16 with its own parts only (stone page, white cards, ink primary, Withings-blue accents, tint
banners, 22pt section headings, tracked-capital modal titles, the 16pt gutter). Reviewed one by one in the `f`
captures:

| Capture | Screen | Built from |
|---|---|---|
| f01, f38 | Demo hub | `StatusBanner`, `ListGroup`, `OptionGroup` |
| f03 | For you | page header, white cards with `PhotoPlaceholder`, round heart button |
| f04, f05 | Filters basic / advanced (locked) | V16 sheet, `ViewTabs`, `StatusBanner` with lock button |
| f06, f07 | Likes and Messages in the full world | V16 grid and rows plus `CountdownAvatar`, `CountBadge` |
| f08–f13 | Chats: history, menu, Did you meet?, new match, expiring, expired | `MessageBubble(mine:false)`, `ChatSystemLine`, action sheet, V16 sheet, `StatusBanner`, `PromptCard` |
| f14 | Match with an Opening Move | V16 match layout plus one balanced line |
| f15, f16, f27 | Paywall, plan selected, Premium | `PlanCard` (ink 2pt when selected), `ComparisonRow`, legal micro copy |
| f17, f18 | Profile with completion ring, completion hub | `CompletionRing`, `CompletionTile` in a two-column wrap |
| f19, f20, f21, f22 | Edit profile, More about you, preview, Opening Moves | V16 `ListGroup` rows with values, `PromptCard`, `PersonHeroCard(own: true)` |
| f23–f26 | Verification: intro, pose, pending, verified | `ResultPanel` with the V16 "verified" illustration, ink viewfinder, `StatusBanner` |
| f28–f33 | Settings, snooze sheet, notifications, a category, visibility, delete account | V16 settings groups and blocks |
| f34–f37 | Help, article, contact, safety and wellbeing | page title scale, `InfoCard`, `ListGroup` |
| f39, f40, f41 | Account on hold, not found, report "where" step | `StatusBanner` (error), `ResultPanel`, V16 report sheet |

## Defects found and fixed in this pass

| # | Where | Defect | Fix |
|---|---|---|---|
| F-1 | Match (f14) | Their Opening Move read "Which poem do you know by heart?'s Opening Move: "Amara"": the generated message takes its placeholders alphabetically and the arguments were swapped | Arguments in the generated order; capture re-checked |
| F-2 | Account restore | After verifying a deleted account's number, the router sent `/restore` to Home while the verify screen was showing success, so the restore choice never appeared | The rule only applies to sessions that aren't restorable; covered by a journey test |
| F-3 | Copy | Two new string keys collided with the phone verify screen's ("Verify your number", "Verify code") and would have renamed it "Photo verification" | Original copy restored, photo-verification keys renamed |
| F-4 | Home paused | "Resume" on Home cleared the pause but left Settings showing "Until … · status" | Resume ends the snooze everywhere |
| F-5 | Captures and tests | Tapping above a sheet no longer closes the taller filters sheet (it reaches the top) | Tests close sheets with their Close button, as a person would |

## Accessibility and layout checks (automated)

- `labeledTapTargetGuideline` and `androidTapTargetGuideline` on every onboarding screen, the earlier dating
  screens, and 24 full-app routes (Demo hub, seeded inbox, three chat states, For you, Profile, completion hub,
  Edit profile, preview, Opening Moves, verification, Premium, paywall, Settings, notifications, visibility,
  delete, help, an article, contact, safety, account on hold, not found): **pass**.
- The same routes on a 375 × 667 phone at 130% text: **no overflow or layout exception**.
- Android system back: tested on onboarding steps and chats (a chat always returns to Messages).
- Orientation: the app is portrait in practice (no landscape layouts were designed, A-01); not tested.

## Remaining differences and gaps

| # | Item | Reason |
|---|---|---|
| R-1 | No Activity tab (V16 web has five tabs) | Out of scope for Numaya's dating loop (unchanged) |
| R-2 | Premium, verification, help, completion and Demo hub screens have no V16 capture to compare | V16 doesn't define them; built from V16 parts |
| R-3 | Photo placeholders everywhere | No real photos or picker (U-08) |
| R-4 | The ink verification viewfinder is the only dark surface in the app | Stands in for a camera preview; to be replaced by the real camera |
| R-5 | No swipe coach mark, no permission primers | Deferred (inventory B-31, B-76) |
| R-6 | Hardware checks (keyboard insets, real gestures, TalkBack, safe areas on notched phones) | Need a device or emulator |

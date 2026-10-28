# Events QA report

Branch `experiment/numaya-events-account-health`. Screens and states are in
[EVENTS_SCREEN_INVENTORY.md](EVENTS_SCREEN_INVENTORY.md); research is in [EVENTS_RESEARCH.md](EVENTS_RESEARCH.md).

**Nothing in this pass ran on a phone or emulator.** There is no Android SDK in this environment.

## What was built

| Area | Where |
|---|---|
| Model, rules, sample data | `lib/features/events/domain/event.dart`, `sample_events.dart` (12 invented events relative to the app clock, one hosted by the member in the full demo world) |
| Repository | `lib/features/events/data/events_repository.dart`: an `EventsRepository` interface and `DemoEventsRepository`. Every change goes through `send()`, which fails while Demo Hub › Simulate connection problems is on |
| State | `lib/features/events/application/events_controller.dart` (Riverpod Notifier): Explore query and filters, My events lists, join / waitlist / leave / open a spot, save, report, host draft / publish / cancel / remove / move up, reset |
| Screens | `events_screen.dart` (tab: Explore, My events, filters sheet), `event_detail_screen.dart` (details, join question, leave and cancel confirmations, report), `event_people_screen.dart`, `event_form_screen.dart` (create, edit, preview, discard guard), `event_parts.dart` (cover, card, badges) |
| Navigation | Events is the second tab. Routes: `/events` (`?view=mine`), `/event/new`, `/event/:id` (`?published=1`), `/event/:id/people`, `/event/:id/edit` |
| Demo Hub | Events group: Explore, My events, an open / full / cancelled event, Create, **Open a spot at board games**, **Reset events** |
| Design system | `ListRow.avatar` (people rows), `NavIconButton.outline` (unsaved heart) |

**Honesty rules in the UI:**
- Every event list and details page says the events are samples.
- Joining is "Saved on this device (demo)".
- Costs are the host's note: "Any cost is paid to the venue or host. Numaya doesn't sell tickets."
- Reports "stay on this device; nothing is sent or reviewed".
- Share says nothing leaves the device.
- No device location is read: distance uses the area the member chose, and the filter says so.
- Attendees show first names and initials only; beyond five, only a count.

## Tests

| File | Count | Covers |
|---|---|---|
| `test/unit/events_controller_test.dart` | 20 | explore rules (no past, cancelled last, blocked hosts hidden); search by title, venue, description, host; category, free, online, weekend, today and distance filters (with and without an area, area outside the grid); join, waitlist position, open spots promoting in order, leave promoting the waitlist; registration closed, live and cancelled can't be joined; a failed join changes nothing; answers kept; saved, past, going lists; picks; validation of every field; draft → publish; time change sets the change note; cancel keeps the event; delete draft; host remove and move up; reset |
| `test/widget/events_test.dart` | 12 | Events reached from the tab after onboarding, search and no results; join → My events → leave with confirmation; waitlist with position and leaving it; the host's question sheet (Join disabled until answered); closed / live / cancelled / past / unknown events; failed join with Try again, Explore load error, skeleton and "still can't load"; filters (free only, count, badge, no-area note, reset); save from a card into Saved; create with validation errors then publish into Hosting; discard guard and Save draft, incomplete draft sent back to Edit; host remove promotes the waitlist and cancel with a note; report kept on the device with Block offered |
| `test/widget/accessibility_test.dart` | (routes added) | Tap targets, labels and 130% text at 375 × 667 on `/events`, My events, three event details, Who's going and the create form |
| `test/widget/visibility_test.dart` | 1 of 7 | Demo Hub: Open a spot, Reset events, opening a full event |

**Results** (`apps/numaya_mobile`):

| Check | Result |
|---|---|
| `dart format` | clean |
| `flutter analyze` | No issues found |
| `flutter test` | 221 passed, 7 skipped (the opt-in capture tests). The discovery branch had 167 passed, 5 skipped |
| Captures | 9 capture tests pass against the committed images |

## Captures

`apps/numaya_mobile/test/screenshots/goldens/v01`–`v13`. Contact sheets:
`docs/mobile/screenshots/events-1.png`–`events-3.png`.

| Capture | State |
|---|---|
| v01, v02 | Explore with picks (reason shown) and the full list |
| v03 | No results |
| v04 | Details: open, few spots left, cost note, Join |
| v05, v06 | Full with Join waitlist; waitlisted at number 3 |
| v07 | Cancelled with the host's note |
| v08 | Going, changed since joining |
| v09, v10 | Host details (Edit, Attendees); Who's going with Remove and the waitlist |
| v11 | Create, empty |
| v12 | My events |
| v13 | Explore load error |

## Defects found by review and fixed

| # | Found by | Defect | Fix |
|---|---|---|---|
| EQ-1 | Capture v01 | "Picked for your interests" included an event whose registration had closed | Picks only include events you can still join |
| EQ-2 | Capture v09 | Three host buttons truncated to "Attend…" and "Cancel …" | Edit and Attendees in the bar; "Cancel event" is a link at the end of the page |
| EQ-3 | Capture v01 | Single-choice date and My events lists used add / remove pills | `ViewTabs` (scrolls horizontally) |
| EQ-4 | Capture v02 | Card text could run under the save button | Text column inset on the save side only |
| EQ-5 | Widget test | Opening My events directly then leaving used `ref` after unmount (lazy search controller) | Controller created in `initState` |
| EQ-6 | Widget test | New strings used straight apostrophes, unlike the rest of the app | Curly apostrophes throughout the new copy |

## Existing captures that changed

Each was compared with the previous commit before being accepted.

| Captures | Change | Verdict |
|---|---|---|
| Every tab capture (16, 18–20, d0xx, f02/06/07/17, q145/147/157/158, w01/06, x0x) | Five tabs instead of four (≈ 0.7% of pixels) | Intended (EN-1) |
| 22, f28, q149, d113, f29 (Settings) | "Profile & visibility" row; Current location reads "Not set" instead of a sample area | Intended (see the account health QA report) |
| 20, f17 (Profile) | "Profile & visibility · Visible" row | Intended |

## Not tested or not built

**Device:**
- real keyboard insets on the long create form;
- TalkBack order on details;
- haptics;
- performance with many events.

**Backend-dependent** (see the inventory):
- real RSVPs and capacity across members;
- host approval;
- event chat;
- notifications;
- check-in and feedback;
- paid tickets;
- device location;
- moderation of reports.

**Persistence:** none; events reset when the app restarts, like the rest of the demo.

**Remaining visual notes:**
- The create form's single-choice category still uses add / remove pills (as the Discover filters do).
- Long event titles wrap to as many lines as needed, by design (accessibility over truncation).

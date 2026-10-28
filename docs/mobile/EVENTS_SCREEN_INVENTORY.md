# Events screen inventory

The checklist for Events: discovering, joining, saving and hosting events. Evidence and decisions are
in [EVENTS_RESEARCH.md](EVENTS_RESEARCH.md); QA is in [EVENTS_QA_REPORT.md](EVENTS_QA_REPORT.md).

- **Counting:** screens are pages or sheets with their own purpose; states are counted separately.
- **Classes:** **Required** (the MVP needs it), **Supporting** (sheets and confirmations the required
  screens rely on), **Optional** (enhancements), **Deferred** (needs a backend or a product decision).

## Navigation decision (EN-1)

**Events is the second tab:** Home · **Events** · Likes · Messages · Profile.

- **Why:** the product spec already orders the PRD tabs Home, Activity, Likes, Messages, Profile (§2) and
  checked that five items fit at 375 pt (§2). V16's tab bar divides the width evenly: at 320 pt, five tabs
  are 64 pt each, above the 44 pt minimum.
- **Not inside Discover:** events are a different decision ("go to this?") from profiles ("date this
  person?"), and Discover's header has no room.
- **Not inside Profile:** Profile is about you.
- **Name:** "Events" (the brief, and what Meetup and Eventbrite call them) rather than the spec's
  "Activity", which could be read as an activity feed.
- **Routes:**
  - the tab is `/events`, with `?view=mine` for My events;
  - full-screen pages sit outside the tab shell like the person and chat pages: `/event/:id`, `/event/:id/people`,
    `/event/new` and `/event/:id/edit`.

## Screens

| ID | Screen | Class | Route or entry | States | Status |
|---|---|---|---|---|---|
| EV-01 | Events: Explore | Required | `/events` (tab) | list · recommendations row ("Picked for your interests") · search results · no results (clear) · filter count badge · loading skeleton · error · error after retry · no area for distance (choose area) · Demo data note | Built |
| EV-02 | Events: My events | Required | `/events?view=mine` (second view of the tab) | Going · Waitlist · Saved · Hosting (published, drafts, cancelled) · Past · each empty with its own action | Built |
| EV-03 | Filters sheet | Required | Events › Filters (date is the row of tabs on Explore itself) | categories · free only · format (any, in person, online) · distance (needs an area; choose one here) · sort (relevance, date) · live count · reset | Built |
| EV-04 | Event details | Required | `/event/:id` | open · few spots left · full · going · waitlisted (position) · saved · registration closed · happening now · past · cancelled (with host note) · changed (with note) · online · cost note · host view · draft (Publish) · unknown event | Built |
| EV-05 | Join sheet (registration question) | Supporting | details › Join, when the host asked a question | answer required · sending · failed (retry) | Built |
| EV-06 | Leave / leave waitlist confirmation | Supporting | details › Leave | confirm · cancel | Built |
| EV-07 | Who's going (attendees) | Required | `/event/:id/people` | host first with badge · you · named attendees · "and N more" · empty · host: remove attendee · host: waitlist with Move to going | Built |
| EV-08 | Create / edit event | Required | `/event/new`, `/event/:id/edit` | empty · validation errors (title, category, description, date missing or past, venue or online note, capacity too small or below people going) · draft saved · discard changes sheet (save draft / discard / keep editing) · editing a published event (attendees told of time or place changes) | Built |
| EV-09 | Event preview | Supporting | create › Preview | details as attendees will see them, labelled Preview | Built |
| EV-10 | Published confirmation | Supporting | create › Publish → details with `?published=1` | "Your event is live" banner on the event's own page (back returns to Events) | Built, as a state of EV-04 rather than a separate page |
| EV-11 | Cancel event | Supporting | host details › Cancel event | note to attendees (optional) · confirm · cancelled details | Built |
| EV-12 | Report event / block host | Required | details › Report this event | reasons · sent (kept on this device) · block host (existing block sheet) | Built |
| EV-13 | Area sheet | Supporting | Filters › distance, when no area | search · pick · no results (existing onboarding sheet) | Reused |

**Counts:**

| Class | Screens | IDs |
|---|---|---|
| Required | 7 | EV-01, 02, 03, 04, 07, 08, 12 |
| Supporting | 6 | EV-05, 06, 09, 10, 11, 13 |
| **Total** | **13** | 12 new, 1 reused |

**States: 70** (the States column).

## Participation rules (demo)

| Action | Result |
|---|---|
| Join, open event | Going; attendee count +1; "You're going" toast; appears in My events › Going |
| Join, event with a question | The join sheet asks it first; the answer is kept on this device for the host |
| Join, full event | Join waitlist → Waitlist, position = people already waiting + 1 |
| Leave / leave waitlist | Confirmation, then removed; your waitlist place is given up |
| A spot opens (host removes someone, or Demo Hub › Open a spot) | The first person waiting moves to Going; if that's you, a toast says so |
| Save / unsave | Saved list; independent of going |
| Registration closed | Two hours before start: Join is replaced by "Registration closed" (you stay going if you were) |
| Happening now / past | Joining is closed; past events move to My events › Past |
| Cancelled | Banner with the host's note; going and waitlist become "Cancelled"; the event stays in My events with its status |
| Simulated failure (Demo Hub › Simulate connection problems) | Joining fails with "Couldn't save your place", nothing changes, Try again |

## Optional enhancements (not built)

- recurring events;
- guests (+1);
- calendar export;
- share sheet (the Share action shows what would be shared, as Discover's share);
- map;
- event photos.

## Deferred / backend-dependent

| Item | Needs |
|---|---|
| Real RSVPs, capacity and waitlist across members | Events service; this build keeps everything on the device |
| Request to join / host approval | Product decision plus a service (in the web spec; states listed for later) |
| Event discussion or group chat | A group messaging model (spec §5) |
| Notifications for changes and reminders | Push service (Settings already has the switches) |
| Check-in, attendance and post-event feedback | Service and venue integration |
| Paid tickets | Payment provider; never simulated as a charge |
| Real location / "near me" | Location permission flow and geodata; this build uses the chosen area |
| Moderation of reported events | Trust and safety review (reports stay on the device) |

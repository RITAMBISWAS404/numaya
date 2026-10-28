# Events research

Research for Numaya's Events, the "Activity" area of the PRD
([feature expansion spec](../product/numaya-feature-expansion-spec.md) §1 row 9, §3 journeys 1–2). Branch
`experiment/numaya-events-account-health`.

**Evidence labels:**
- **[O]** observed in a Mobbin capture;
- **[D]** documented in this repository or an official page that was actually read;
- **[I]** inferred;
- **[U]** unverified.

## Sources

**Repository:**
- `docs/product/numaya-feature-expansion-spec.md`. The web flows already specify and implement Explore,
  details, Who's going, create / edit with drafts, and My activities. They also set the tab order Home,
  Activity, Likes, Messages, Profile, and the safety rules in §6. **[D]**
- `src/flows/data.js`: eight sample activities, six categories and five London areas. The Flutter
  sample data is adapted from these. **[D]**
- `docs/numaya-meetup-ui-map.md`: the Meetup visual system V16 is built on (event cards, list groups,
  pills). **[D]**
- `docs/mobile/DESIGN_SYSTEM.md`: "Five tabs (with Activity) → four tabs; Activity needs real events;
  not built". This pass builds it on local data. **[D]**

**Official help pages:** none could be read.
- **Meetup** (event creation, attendee management): `help.meetup.com` failed to resolve; the session's
  network policy blocks it.
- **Eventbrite app help:** not attempted after four help hosts in a row had failed the same way.

Anything this document would have taken from them is **[U]**.

**Mobbin (iOS only; no Android captures of these apps were exposed):**

| App | Flow | Screens | Observed |
|---|---|---|---|
| Meetup | [Updating attendance](https://mobbin.com/flows/be0e2e06-6142-4dc7-9cbb-0155c96a0952) | 4 | **Sticky bottom bar** with status and action ("You're going! · Edit attendance", "Free · Attend"); attendance sheet (Going / Not going, guests stepper); toast "You're not going anymore" [O] |
| Meetup | [Registering for an event](https://mobbin.com/flows/285d4cee-cb36-4dca-b78c-881c70da7dd7) | 7 | "Complete registration" sheet; confirmation; "Connect with attendees" list with an **Event host** badge; "Recommended for you" after joining [O] |
| Meetup | [Joining a waitlist](https://mobbin.com/flows/925acb6a-b97a-48f0-b2e7-7b3989cfeef9) | 3 | Full event: "Free · 0 spots left · **Join Waitlist**"; confirmation card "Waitlisted"; bar "Waitlisted · **Leave Waitlist**" [O] |
| Meetup | [Event detail](https://mobbin.com/flows/bda54918-bc53-4eb7-ba68-760751f893b8) | 10 | Cover, title, date with time zone, venue (expandable), organiser card, description; "Learn more about attendees" with **gender distribution and age range** (deliberately not adopted, below); map; similar events; **"Report this event"** at the end [O] |
| Meetup | [Creating an event (from scratch)](https://mobbin.com/flows/4c879eef-05b3-46f1-b28a-f35084fd2092) | 17 | "Start from: Duplicate past event / Continue from draft / Start from scratch"; cover photo; start / end; location In person; description; topics (up to 5); hosts; ticketing "Make event paid" switch; **Attendee limit**, guests; **Ask members a question**; repeat; RSVP window [O] |
| Meetup | [Saving an event as a draft](https://mobbin.com/flows/6adaa4d2-f061-4b8c-b1e7-1b3c2c06401a) | 3 | "Save as draft" from the editor's ⋯; the draft's detail page has a "Draft event" band and **Publish · Edit · More** [O] |
| Meetup | [Adding topics](https://mobbin.com/flows/3d2c8ba1-b8ff-498c-8810-08106eaefa00) | 5 | Topic search with add pills, maximum 5 [O] |
| Meetup | [Other events](https://mobbin.com/flows/4733c7ba-4752-48ec-a666-4dbd79601871) | 3 | Upcoming / Past segmented list grouped by month [O] |
| Meetup | Home ([screen in the flow above](https://mobbin.com/flows/4733c7ba-4752-48ec-a666-4dbd79601871)) | — | Events chips: **Your groups · Hosting 1 · Going 3 · Saved · Past** [O] |
| Meetup | Hosting detail (waitlist flow) | — | "You're hosting this event"; host row **Check in · Attendees · Edit · More**; "Unannounced" badge [O] |
| Meetup | Explore (waitlist flow) | — | Search "events or groups"; date chips Upcoming / Today / Tomorrow / Weekend; category tabs; card with "326 going", distance, organiser and rating; floating **Map** button [O] |
| Eventbrite | [Filtering home](https://mobbin.com/flows/ab64def0-33de-4a35-8678-355ade1e2731) | 11 | Filter sheet: categories (checkboxes, Show all), **Show only free events**, **Show online events**, **Sort by Relevance / Date**, Reset · Apply filters; date-range calendar; filter count badge on the button; card badges **SOLD OUT**, **FEW TICKETS LEFT**, **SALES ENDED**, PROMOTED [O] |
| Eventbrite | [Searching Eventbrite](https://mobbin.com/flows/6b8d4f40-1f70-453a-aba1-67c3a9975f40) | 6 | Search with a separate location field and "Use current location · Share location" (a permission asked only at that point) [O] |
| Eventbrite | Tab bar (both flows) | — | Discover · **Saved** · Tickets · Account [O] |

**Dating apps:** no event features for Bumble, Hinge or happn were found in the screens the connector
returned. Earlier passes saw Bumble's "For You" and happn's "Hub · Explore · Meet" curated lists.
Dating apps showing events is **[U]**.

## What Numaya adopts

| Pattern | Source | How Numaya uses it |
|---|---|---|
| Sticky status-and-action bar on details | Meetup [O] | Bottom bar: price note + Join / Join waitlist; once joined, "You're going · Leave" |
| Waitlist on a full event, leave waitlist | Meetup [O] | Full → Join waitlist → "On the waitlist (position N)" → Leave waitlist; a spot opening moves you to Going |
| Status badges on cards | Eventbrite, Meetup [O] | Full, Few spots left, Cancelled, Registration closed, Happening now, Past, Draft |
| Filter sheet: category, free only, online, sort by relevance / date, reset, count badge | Eventbrite [O] | Same set, in V16's sheet; date chips (Any / Today / This weekend / Next 7 days) as Meetup's chips |
| My events chips (Hosting · Going · Saved · Past) | Meetup [O] | My events: Going · Waitlist · Saved · Hosting · Past |
| Create: cover, start / end, location, description, topics, attendee limit, a question | Meetup [O] | Title, category, description, date, start time, duration, format, venue / link note, cover tone, capacity, optional question, cost note |
| Save as draft, publish from the draft | Meetup [O] | Same; drafts appear under Hosting with a Draft badge |
| Host tools on the detail: Attendees · Edit · More | Meetup [O] | Host bar: Edit · Attendees · Cancel event |
| "Event host" badge in attendees | Meetup [O] | Host listed first with a Host badge |
| "Report this event" at the end | Meetup [O] | Report event and Block host at the end of the details |
| Location asked only when needed | Eventbrite [O] | Distance uses the area you chose in onboarding or picked here; no device location is read |

## What Numaya adapts or avoids

- **Attendee demographics** (Meetup's gender distribution and age range): **not adopted.** On a dating
  app this invites people to judge an event by who they might date and exposes attendees.
  Attendees show first name, initial avatar and a Host badge. Beyond five names only a count is shown
  (spec §6).
- **Paid tickets** (Eventbrite tickets, Meetup "Make event paid"): **not processed.** Numaya has no
  payment backend. An event can carry a host-written cost note ("Pay at the door, about £12"), shown
  as such, and the free filter uses it. No checkout, no prices invented.
- **Groups, ratings, promoted listings, "similar events" carousels:** out of scope for the MVP. Groups
  are a separate community product, and promoted listings would read as advertising (spec §5,
  sponsored carousel). Recommendations use a transparent rule (shared interests), labelled.
- **Event chat / discussion:** **deferred.** Numaya's chat is one-to-one and match-gated (spec §5).
  The details link to the host's profile and safety tips instead.
- **Approval / "Request to join":** in the web spec, deferred in Flutter (the states are listed in the
  inventory as backend-dependent). Capacity and waitlist cover the full-event case.
- **Guests (+1) and repeat events:** deferred.
- **Check-in and post-event feedback:** deferred; there is no venue integration. Past events show
  "This event has ended".
- **Map:** not built (no map SDK, no location). Venue text and area only.

## Events and dating

Events are participation, not a dating like. Joining needs no match and creates nothing in Likes or
Discover. Event activity has **no effect on Discover or on Profile & visibility**: no rule links
them, so none is implied (see [ACCOUNT_HEALTH_METRICS.md](ACCOUNT_HEALTH_METRICS.md)). Attendees open
the normal person profile, where Report and Block work as everywhere else.

## Limitations

- Mobbin exposed iOS captures only.
- Meetup's organiser web tools and the help pages could not be opened.
- No screens for event discussion, check-in or post-event feedback were inspected, so those are **[U]** and deferred.

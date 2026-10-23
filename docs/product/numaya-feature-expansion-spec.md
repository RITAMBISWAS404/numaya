# Numaya feature expansion: specification

Status: implemented in the flow previews (`flows.html`). This document is the specification for the
expansion (Activity, Likes, Messages, Profile insights and account features). It states what the
code does; anything simulated is called out as such. Source brief: the three-page brainstorm
`NUmaya (1).pdf` (an early PRD, not a full specification).

## 1. PRD requirement inventory and status

Status before this expansion → after. **I** implemented, **P** partial, **M** missing,
**S** simulated (front-end state only, no backend), **F** deliberately future.

| # | PRD requirement | Before | After | Where / note |
| --- | --- | --- | --- | --- |
| 1 | Splash (animated) | P | P | Welcome screen (`index.html`). No separate splash: the welcome hero is reserved for artwork |
| 2 | Onboarding, 2–3 screens | I | I | Welcome → phone → code |
| 3 | Auth: Google, Apple; OTP later | P | P | Phone OTP is implemented (simulated SMS). Google / Apple sign-in need real OAuth: **F** |
| 4a | Name, date of birth, gender | I | I | The basics |
| 4b | Sexual orientation | M | I | Edit profile › About you (optional, "Prefer not to say" default) |
| 4c | Photos, 4–6 | I | I | Photos (2 minimum, 4 recommended, 6 maximum) |
| 4d | Interests and hobbies | I | I | Interests and prompts |
| 4e | Bio | M | I | Edit profile › Bio (300 characters) |
| 4f | Prompts | I | I | One prompt answer, editable |
| 5 | Preferences: interested in, looking for, age, distance | I | I | The basics; Settings / Discover filters |
| 6 | Add location | M | S | Area picker (fixed list of London areas). No device location is read |
| 7 | Verification: photo, ID (optional) | P | P | Phone verified. Photo and ID verification: **F** (shown as "Not available in this preview") |
| 8 | Home: swiping, filters, bio/details/prompts | I | I | Home (the former Discover) |
| 8 | Home: Super Like | I | I | SuperSwipe |
| 8 | Home: backtrack | M | I | "Undo" after a pass (one step) |
| 8 | Home: share profile | M | S | Profile options › Share: shows the link would be shared; nothing leaves the preview |
| 8 | Home: block and report | M | I | Profile options › Report / Block |
| 8 | Home: DM | M | F | Messaging needs a match (existing product rule). Recorded as an open decision |
| 9 | Activity: Live / Posted | M | I | **Explore** and **My activities** (see §5), with a **Live now** status badge |
| 9 | Activity: sponsored carousel | M | F | Not built: no sponsor data, and invented sponsors would mislead (see §5) |
| 9 | Activity card: profile, photo, details, interest action | M | I | `ActivityCard` |
| 9 | Create activity: name, tag, place, date and time | M | I | Create / edit activity, with drafts |
| 10 | Likes with filters All, Activity, New, Nearby | M | I | Likes |
| 11 | Messages: new matches | I | I | Match rail |
| 11 | Messages: filter, search | M | I | Search + All / Unread / Your move |
| 11 | Messages: chats | I | I | Conversation rows |
| 11 | Messages: opening prompts | M | I | Suggestions on an empty conversation insert into the composer |
| 11 | Unmatch, report, remove match | P | I | Unmatch, Block and Report are now three separate actions |
| 11 | "Cheating tool" | — | F | Undefined; see §6. Nothing built |
| 12 | Profile edit | I | I | Edit profile |
| 12 | Help and support | M | I | Help and support (static guidance; support contact not connected) |
| 12 | Notifications | I | I | Settings › Notifications (simulated alerts) |
| 12 | Settings | I | I | Settings, plus Blocked people |
| 12 | Premium tiers | M | S | Free / Plus comparison; no prices, no billing |
| 12 | Insights and dashboard (profile score) | P | I | Profile readiness (transparent rules) |
| 13 | Match animation (hand / heart) | P | I | Two halves of a heart join on the match mark; reduced motion = fade |
| 13 | Maintenance | M | I | Reusable system state, reachable from Settings › Prototype tools |
| 13 | Instagram, Spotify | M | S | Consent sheet, connect / disconnect; simulated, no data imported |

## 2. Screen and route map

Single-screen routes are `flows.html?screen=<id>`; the gallery (`flows.html`) shows every screen.
Existing ids are kept so deep links still work (`discovery` is Home, `chats` is Messages).

| Tab | Screen id | Screen |
| --- | --- | --- |
| Home | `discovery` | Home: profile discovery (filters, undo, profile options) |
| | `match` | It's a match |
| Activity | `activity` | Explore activities (area, category, date and distance filters) |
| | `activity-detail` | Activity details (participation, share, report, host tools) |
| | `activity-people` | Who's going (attendees; host: requests) |
| | `activity-form` | Create or edit an activity (publish or save draft) |
| | `my-activities` | My activities: Upcoming, Hosting, Requests, Past |
| Likes | `likes` | Likes with filters |
| | `like-profile` | A person who liked you (like back / pass) |
| Messages | `chats` | Messages: search, filters, new matches, conversations |
| | `chat` | Conversation: openers, safety menu, outcomes |
| Profile | `profile` | Profile home: overview, readiness summary, account groups |
| | `edit`, `prompt` | Edit profile (bio, orientation added), edit prompt |
| | `insights` | Profile readiness dashboard |
| | `settings`, `blocked` | Settings; blocked people |
| | `premium` | Premium tiers (preview) |
| | `connections` | Connected accounts (Instagram, Spotify; simulated) |
| | `help` | Help and support |
| System | `maintenance` | Service unavailable (never in the normal flow) |
| Onboarding | `intro`, `basics`, `interests`, `photos` | Unchanged |

Tab order follows the PRD: **Home, Activity, Likes, Messages, Profile**. Five items fit the
floating tab bar at 375px (≥ 64px per item, 44px minimum target).

## 3. User journeys

1. **Discover an activity:** Activity → filter (category, date, distance) → card → details →
   Join (open), Request to join (approval) or Join waitlist (full) → status shown on the card,
   details and My activities. Leave / withdraw with confirmation.
2. **Host an activity:** Activity → Create → title, category, place, date, time (+ optional
   description, duration, visibility, limit, approval) → Publish (or Save draft) → My activities ›
   Hosting → details (host view) → Who's going → approve / decline requests → Edit or Cancel
   activity (confirmation; cancelled stays visible with its status).
3. **Likes:** Likes → filter → person → Like back (match → It's a match) or Pass (removed with
   feedback). Handled likes leave the list; already-matched people are marked.
4. **Messages:** Messages → search and filter → conversation → (empty) pick an opener → edit →
   send. Options: Unmatch, Block, Report (reason → optional details → also block?) → outcome.
5. **Profile readiness:** Profile → readiness summary → Insights → breakdown → recommendation →
   the matching field in Edit profile (focused).
6. **Account:** Settings (toggles persist), Blocked people (unblock), Premium (compare, preview a
   plan, no charge), Connected accounts (connect / disconnect, simulated), Help.

## 4. Entities and UI states

All fixtures live in `src/flows/data.js`; mutable state in `src/flows/store.js` (reducer,
persisted to `localStorage` key `numaya.preview.v1`). Records use stable string ids.

- **Prototype clock:** `PROTOTYPE_NOW` = Friday 23 October 2026, 12:00 local. Every date
  calculation (upcoming, live now, past, "new" likes, form validation) uses it, so captures and tests
  are deterministic.
- **Area:** `{ id, name, x, y }` on a km grid. Distance = straight-line km between the chosen area
  and an activity or person, rounded. Labelled "about N km".
- **Activity:** `{ id, title, category, description, host, start, durationMin, venue, area, x, y,
  capacity|null, approval, visibility: public|private, tone|null, status: published|draft|cancelled,
  attendees: [personId], othersGoing }`. Derived: `phase` upcoming | live | past; `full`.
- **Participation (me):** `joins[activityId]` = joined | requested | waitlisted. Host-owned
  activities (`host: "me"`) live in state, with `requests: [personId]`.
- **Like:** `{ person, via: profile|activity, activity?, at }`. Handled: `likesHandled[person]` =
  liked | passed.
- **Conversation:** `threads[person]`, `read[person]` (messages read), `ended[person]` =
  unmatched | blocked | reported.
- **Report:** `{ id, target: person|activity, targetId, reason, details, at }`, stored on this
  device only.
- **Profile:** adds `bio`, `orientation`; verification `{ phone: true, photo: false }`.
- **Social:** `{ instagram: bool, spotify: bool }` (simulated).

| State | Treatment |
| --- | --- |
| Loading | Activity feed shows skeleton cards for a short simulated load |
| Empty | Every list has a drawn empty state with one next step (clear filters, create, browse) |
| Error | Prototype tools › Simulate network errors: the feed shows a retry state; joining fails with an alert and nothing changes |
| Location unavailable | No area chosen: Activity asks to choose an area; distance filter disabled |
| Disabled | Publish is disabled until required fields are valid; past dates are rejected |
| Success | Join / request / publish / report each confirm in place (toast or result panel) |
| Permission | No browser permission is ever requested (location, notifications) |

## 5. Decisions on ambiguous PRD items

- **Live / Posted → Explore / My activities.** Nothing in the repository defined the terms.
  "Live" would suggest livestreaming, which Numaya does not have. Explore lists published
  activities by others; My activities lists what I joined, requested, host and attended. An
  activity under way carries a **Live now** status badge.
- **Sponsored carousel: not built.** Optional in the brief; there is no sponsor data or ad
  policy, and placeholder brands would read as real advertising. When it is built, it is a separate
  row labelled **Sponsored**, never mixed into organic ranking.
- **Activity "like option" → Join / Request to join.** Expressing interest in an activity is
  participation, not a dating like; it does not need a match. People who join an activity can
  like you from it ("Activity" filter in Likes).
- **Group chat for activities: future.** The existing chat is one-to-one; there is no group
  messaging model. Details list who's going instead.
- **DM from Home: future.** Messaging stays behind a match, as today.
- **Premium names:** Free and Plus (the names already in the design system). No prices are shown
  or invented.

## 6. Safety and privacy

- Activity cards and details show the venue and area chosen by the host, never a home address or
  live location. Attendees appear by first name and initial avatar; beyond the first five, only a
  count.
- Report and Block are available on activities, hosts, profiles and conversations. Reports are
  stored on this device only, and the UI says so; it never claims a review or enforcement.
- Unmatch ends the match and closes the conversation. Block also hides the person everywhere.
  Report records a reason and, by default, blocks.
- No verification claims beyond the data the preview has (phone verified; people's `verified`
  flag). Hosts and venues are not described as verified.
- Safety guidance on activity details is calm: meet in the listed public place, tell a friend,
  leave whenever you like.
- **"Cheating tool" (PRD).** Undefined. Nothing that monitors, tracks or exposes another person's
  activity is built. Recorded as an unresolved product idea; any future version needs a written
  definition, consent model and safety review first.
- Social connections are optional, never required for readiness, and show what would be shared
  before connecting.

## 7. Profile readiness (score definition)

0–100 from visible profile elements only. Verification is shown separately and never scored.

| Element | Points | Rule |
| --- | --- | --- |
| Basics | 20 | 5 each: first name, birth year, gender, looking for |
| Photos | 30 | 7.5 per photo, up to the recommended 4 |
| Interests | 15 | 5 per interest, up to 3 |
| Bio | 20 | 10 for any bio, 20 at 40+ characters |
| Prompt | 15 | Answer of 10+ characters |

Recommendations are the incomplete elements ordered by points available, at most three, each with
a reason and a button to the field in Edit profile. Nothing about attractiveness, replies,
unmatches or visibility is scored. Account status (Active / Paused) comes from Snooze and is shown
apart from the score.

## 8. Reference patterns

The Meetup, Tinder and Bumble help pages named in the brief could not be opened from this
environment (DNS blocked). The following widely documented patterns were used, marked **[I]**
(not re-verified in this pass): event creation asks title, date and time, location, description,
with an optional attendee limit and approval; full events take a waitlist; hosts see an attendee
list and approve requests; plans and events are joined without a match and show the group before
the meet-up; profiles can surface upcoming plans.

## 9. Acceptance criteria per phase

1. **Navigation:** five tabs, each opening a real screen; existing deep links work; tests pass.
2. **Activity:** discover → details → join / request / waitlist → status visible; create (with
   validation) → publish → in My activities; host edits, cancels, manages requests; report and
   leave available.
3. **Likes and Messages:** filters change content; like back / pass handled once; search +
   filters combine; openers insert into the composer; unmatch, block and report keep their meaning.
4. **Profile:** readiness score matches §7; recommendations lead to the right field; settings
   persist; premium, social and maintenance never imply a backend.
5. **QA:** E2E covers the twelve flows in the brief; screenshots at 393, 375 and 1440; gallery,
   docs and tests updated.

## 10. Verification

Automated in `tests/e2e/product.mjs` (single-screen mode, 393 × 852 and 375 × 667) and
`tests/unit/model.test.js`; screenshots in `artifacts/ui-gallery/` (groups 2–7).

| Brief flow | Covered by |
| --- | --- |
| 1 Five sections | nav: PRD order, every tab opens its screen, 44px targets at 393 and 375 |
| 2 Discover, open, join / request | activity: join, request, withdraw, waitlist; counts and card state |
| 3 Create, validate, publish, find | create: required fields, kept input across the picker, past date, publish, Hosting |
| 4 Edit or cancel own activity | edit: save changes; cancel with confirmation; hidden from Explore; host approvals |
| 5 Filters change content | filters (category, date, distance, no area); likes (All, Activity, New, Nearby) |
| 6 Search and open a conversation | messages: text and name search, combined with filters, read state |
| 7 Opener, multiline, send | chat: opener inserts and focuses, Shift+Enter, send |
| 8 Unmatch, block, report | three separate outcomes; report count, block count, conversation kept when not blocking |
| 9 Insights | score 73 from the rules, breakdown, recommendation focuses Bio, score rises to 93 |
| 10 Settings persist | toggle survives reload |
| 11 Social connect / disconnect | consent, "simulated" label, disconnect |
| 12 Empty, invalid, cancel, narrow, disabled | empty states per filter, form errors, discard sheet, 375 checks, disabled Send report |

Also covered: drafts, activity report and host block, simulated network failure on load and join,
Home undo / share / block, premium without prices or charges, unblock, maintenance retry, the
match animation under reduced motion.

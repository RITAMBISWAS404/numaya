# Screen and state inventory (Flutter V16)

Audit of every documented screen and state against the Flutter app, written at the start of
`experiment/numaya-flutter-v16-complete` (from `b99edb4`) and updated after the work. **Before** is what the
`b99edb4` build actually did (UI and behaviour inspected, not just routes); **After** is this branch, verified by
the tests named in the Tests column (file names under `apps/numaya_mobile/test/`) and the renders in
[VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md).

## Sources and hierarchy

1. The person's direction for this work: implement **Numaya V16**; build honest local demo journeys for the dating
   loop, clearly marked as simulated.
2. `PRODUCT.md` (core loop; "sample people and conversations are mock data, labelled as such"; no invented photos).
3. `docs/research/screen-specs.md` (B-xx), `states-and-recovery.md` (binding Numaya rules), `decision-log.md`,
   `unknowns.md` (open product decisions P-xx).
4. The V16 web implementation and its captures (`artifacts/version-16-design-experiment/final-polish/screenshots/states/`),
   then the web flows (`src/flows/*.jsx`) for behaviour and copy.

Requirement column: **R** required by the core loop or a spec · **O** optional · **D** deferred (open decision,
needs backend/device, or out of scope) · **X** out of scope for the prototype.

## Conflicts found and how they are resolved

| # | Conflict | Resolution |
|---|---|---|
| C-1 | D-21/D-22 and PRODUCT.md "Brand Commitments" name purple `#7262C7`, Fraunces + Inter; the person directs V16 (stone, ink, Withings blue, Hanken Grotesk) | Owner direction for this experiment wins; the web default is untouched |
| C-2 | `states-and-recovery.md`: under-18 is blocked "with no retry with another date in-session"; the web Basics screen shows an inline error and lets the person correct the year | Follow the implemented web behaviour (a typo must not lock someone out); Next stays disabled while under 18. Needs a product decision before launch |
| C-3 | The web preview seeds three matches and two conversations for a brand-new profile | Flutter starts a new account with **no** matches or conversations; matches come only from liking someone who already liked you (coherent new-user journey) |
| C-4 | The web marks sent messages "Delivered" after 700 ms | Never claimed: messages are labelled "Demo · saved on this device, not sent", no replies are invented |
| C-5 | Web Likes has an "Activity" filter and likes "at an activity" | Activity is not built (D): those filters/copy are omitted |
| C-6 | Spec B-46 suggests blurred, premium Likes (P-05 open) | Likes are visible, as in the web prototype; premium is deferred |
| C-7 | Interrupted onboarding should resume after the app is killed (states-and-recovery §3); the mobile constraints forbid personal data in plain local storage | Deferred until encrypted storage or a backend exists; state survives navigation and backgrounding, not process death |

## A. Launch and authentication

| Screen / state | Req | Route | Reference | Before | After | Tests | Next action |
|---|---|---|---|---|---|---|---|
| Welcome (create / sign in / legal) | R | `/` | B-02, V16 001 | Complete | Complete | widget | — |
| Legal links (Terms, Privacy) | R | sheet | B-02 | Complete (honest "not published yet") | Same | — | Publish documents (product) |
| Phone entry: empty, typing, valid, submitting, invalid number, offline, sign-in unavailable | R | `/phone` | B-04 | Complete | Same | widget | — |
| Country sheet: list, search, no results, selected | R | sheet | B-05, web 003/004 | Complete | Same | widget | — |
| Country change trims digits | R | — | states §1 | Complete | Same | unit + widget | — |
| Verify: empty, partial, checking, incorrect (clears 650 ms), expired after 5 tries, success | R | `/verify` | B-07 | Complete | Same | unit + widget | — |
| Resend countdown 30 s, resend, new code sent | R | — | states §1 | Complete | Same | unit | — |
| Change number keeps the number | R | — | B-07 | Complete | Same | widget | — |
| Sign-in: returning member → Home; no account → create or use another number | R | — | B-03 (Numaya form) | Complete | Same | widget | — |
| Android back during verification | R | — | states §4 | Back hidden while checking | Same | — | — |
| Android back between onboarding steps | R | — | states §4 | Router pop, untested | Same, tested | `onboarding_edge_cases_test` | — |
| Session restore after app restart | D | — | states §3 | Not supported (in memory) | Same | — | Needs secure storage + real auth (C-7) |
| Rate limit / blocked account screens | D | — | states §1 | — | — | — | Needs backend |

## B. Onboarding

| Screen / state | Req | Route | Reference | Before | After | Tests | Next action |
|---|---|---|---|---|---|---|---|
| Setup hub (0–3 done, Up next, Go to Home) | R | `/setup` | B-21, web 011/012 | Complete | Same | widget | — |
| Basics: name, birth year, gender, looking for (≤2) | R | `/setup/basics` | B-10/B-11, V16 013 | Complete | Same | widget | — |
| Underage and unrealistic year errors, corrected in place | R | — | V16 015, C-2 | Complete | Same | `onboarding_controller_test`, `onboarding_edge_cases_test` | Product decision C-2 |
| Back keeps entered data; forward keeps picks | R | — | states §4 | Complete (shared draft), untested | Same, now tested | `onboarding_edge_cases_test` | — |
| Interests 3–5, unavailable at limit, deselect | R | `/setup/interests` | B-17, V16 016/017 | Complete | Same | unit + widget | — |
| Prompt editor: pick, answer ≤150, counter, save rules | R | `/setup/prompt` | B-27, V16 108–110 | Complete | Same | widget | — |
| Photos: add (placeholder), remove, min 2 / ideal 4 / max 6 | R | `/setup/photos` | B-15, V16 018 | Complete | Same | unit + widget | — |
| Photo options: make main photo, remove (sign-up), keep at least 2 (edit) | R | sheet | V16 104 ("Tap a photo to make it your main one") | **Missing** | Complete | `photo_options_test`, `onboarding_controller_test` | — |
| Real photo picker, crop, permission denied, upload, moderation | D | — | B-15/B-16, U-08 | Placeholder tiles (labelled) | Same | — | Needs device testing, storage and moderation service |
| Keyboard: tap outside dismisses, footer above keyboard | R | — | states | Footer above keyboard; tap-outside **missing** | Complete | `onboarding_edge_cases_test` | Check on a device |
| Profile preview before Home | O | — | V16 106 (Edit → Preview) | Not built | Not built | — | Optional; the Profile tab shows the result |
| Notification / location primers | D | — | D-17, P-10, U-01 | Not built | Not built | — | No push or location in this build; P-10 proposes after first match |
| Gender details sheet / gender visibility (B-12/B-13) | D | — | B-12/B-13 | Not built (web didn't build it either) | Same | — | Product scope |
| Mode choice (B-14) | X | — | D-08 | Omitted by decision | Same | — | — |

## C. Main dating experience

| Screen / state | Req | Route | Reference | Before | After | Tests | Next action |
|---|---|---|---|---|---|---|---|
| Discover profile (card, prompt, about, you both like, location, photos) | R | `/home` | B-30/B-32, V16 019–022 | **Missing** (empty card only) | Complete with labelled sample profiles | `dating_test`, `dating_controller_test` | Real profiles need a backend |
| Like / pass / SuperSwipe buttons; swipe gesture | R | — | B-30 | **Missing** | Complete (SuperSwipe acts as a like) | `dating_test` | SuperSwipe meaning (P-05) |
| Undo last pass (one step) | O | — | web Discover | Missing | Complete | `dating_test`, `dating_controller_test` | Premium decision P-05 |
| Profile options: report, block from the card | R | sheet | D-13, V16 027 | Missing | Complete (no Share) | `dating_test` | — |
| Filters sheet with live count | R | sheet | B-34, V16 023 | Saved values only | Applies to sample profiles; "Show N people" | `dating_test`, `dating_controller_test` | Fallback switches (D-15) |
| No one fits filters → widen | R | — | V16 024 | Missing | Complete | `dating_test` | — |
| Seen everyone → show again | R | — | web 025 | Missing | Complete | `dating_test` | — |
| Home paused (snooze) | R | — | web 029, B-71 | Missing | Complete | `dating_test` | Hiding the profile needs a backend |
| Load error with Try again (skeleton while retrying) | R | — | states §3 | Missing | Complete via "Simulate connection problems" (demo builds) | `dating_test` | Real network errors need a backend |
| Likes grid with New / Nearby filters and counts | R | `/likes` | B-46, V16 054 | Empty card only | Complete | `dating_test`, `dating_controller_test` | Premium (C-6) |
| Likes empty states per filter | R | — | V16 058 | All only | Complete | `v16_screens_test` (All) | — |
| Like-back profile: like back, pass, message if matched | R | `/like/:id` | V16 059 | Missing | Complete | `dating_test`, `v16_screens_test` | — |
| Match celebration with composer, keep browsing | R | `/match/:id` | B-40, V16 030/032 | Missing | Complete (says the person is a sample) | `dating_test` | Match timer P-03 |
| Messages: new matches queue, search, filter tabs, rows, empty states | R | `/messages` | B-42/B-43, V16 034/037/052 | Empty card only | Complete | `dating_test` | — |
| Conversation: openers, bubbles, composer, status | R | `/chat/:id` | B-44, V16 038/039/042 | Missing | Complete (messages stay on device, labelled; no replies) | `dating_test`, `dating_controller_test` | Real delivery needs backend |
| Message failed → retry / delete | R | — | states §3 | Missing | Complete (simulated) | `dating_test` (delete), `dating_controller_test` (retry) | — |
| Chat menu: unmatch, block, report | R | sheet | B-50–B-53, V16 044–047 | Missing | Complete (report saved on device only, says so) | `dating_test` | Moderation needs a backend |
| Ended conversation result (unmatched, blocked, reported) | R | — | web Chat | Missing | Complete | `dating_test` | — |
| Another person's profile from chat | O | `/person/:id` | B-44 (header opens profile) | Missing | Complete | — (screen shares the tested like-profile sections) | — |
| Own profile | R | `/profile` | B-23, V16 099 | Complete | Same | widget | Readiness score (needs bio etc.) |
| Edit profile (photos, prompt, basics, interests) | R | `/profile/edit` | B-24, V16 102 | Complete | + photo options | `v16_screens_test`, `photo_options_test` | Bio and more fields (B-25) |
| Settings: notifications, log out, delete (cancel and confirm) | R | `/profile/settings` | B-70, V16 111/113/130 | Complete | Notifications aligned with V16 (messages, likes) | `v16_screens_test` | Push needs a service |
| Settings: snooze, blocked people (unblock), prototype tools | R | `/profile/settings`, `/profile/settings/blocked` | V16 111/112/113 | Missing | Complete | `dating_test` | — |
| Tab badges (new likes, new matches) | O | — | V16 tab bar dots | Missing | Complete | `dating_test` (semantics labels) | — |
| Activity tab and screens | D | — | web Activity | Not built | Not built | — | Needs events data and product scope |
| Premium, paywall, purchase (B-60–B-64) | D | — | D-14, P-05 | Not built | Not built | — | Business decision, store setup |
| Photo verification (B-56/B-57) | D | — | D-12, P-06 | Not built | Not built | — | Camera, review service |
| Voice/video calls, media messages | X | — | B-44 | — | — | — | — |

## D. Shared states and quality

| Concern | Before | After | Evidence |
|---|---|---|---|
| Loading | Spinners on async buttons; busy toasts | + Discover retry skeleton | widget tests |
| Empty | Home/Likes/Messages cards | + per-filter and search empties | widget tests, screenshots |
| Error | Auth errors, field errors | + Discover load error, message send failure | widget tests |
| Destructive confirmation | Delete account sheet | + unmatch, block, report, remove photo | widget tests |
| Android back | Router pop; sheets close | Same; a chat always returns to Messages | `onboarding_edge_cases_test` |
| Keyboard | Footer above keyboard | + tap outside to dismiss | `onboarding_edge_cases_test` |
| Small screens (375 × 667) | Not captured | Captured, compared with V16 145–158, overflow-tested | `goldens/q*`, `accessibility_test` |
| Large text (1.3×) | Not checked | Every onboarding and dating screen in the journeys, at 375 × 667 | `accessibility_test` |
| Touch targets | `Pressable` 44 pt minimum; text inputs 22pt | Android 48dp on all checked screens (inputs, search, composer fixed) | `accessibility_test` (`androidTapTargetGuideline`) |
| Semantics | Labels on controls, live regions; an unlabelled full-screen tap area | + tiles, badges; the tap area excluded | `accessibility_test` (`labeledTapTargetGuideline`) |
| Contrast | Unit test on key pairs | Same | `foundation_test.dart` |

## Counts

Rows in tables A–C (each a screen or a group of states): **55** (counted from the tables above).

| Outcome | Rows | Which |
|---|---|---|
| Complete before this branch, unchanged | 17 | A: 10 (Welcome to Android back during verify) · B: 6 (hub, basics, age errors, interests, prompt, photos) · C: own profile |
| Complete before, now covered by tests | 2 | back keeps Basics answers; Android back between steps |
| Implemented or changed on this branch | 25 | B: photo options, tap-outside keyboard · C: 23 (Discover through tab badges, incl. Edit profile photo options and Settings) |
| Not built: deferred (D) or optional (O) | 9 | session restore, rate-limit screens, real photo picker, primers, gender details, profile preview (O), Activity, premium, photo verification |
| Out of scope (X) | 2 | mode choice, calls/media |

Blocked by this environment: building and running on Android (no SDK download), the on-device integration test,
and keyboard and gesture checks on hardware.

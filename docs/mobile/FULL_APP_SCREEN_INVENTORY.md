# Full app screen inventory (Flutter V16)

> Status is now kept in [MASTER_PRODUCT_COMPLETION_MATRIX.md](MASTER_PRODUCT_COMPLETION_MATRIX.md), which corrects B-09, B-45 (Share Date), B-76 and B-77 below. This file keeps the per-screen states.

Branch `experiment/numaya-flutter-full-app` (from `experiment/numaya-flutter-v16-complete` at `37a8007`).
This maps every flow (F1–F29) and reference screen (B-01–B-77) in
[`docs/research/flow-catalogue.md`](../research/flow-catalogue.md) to the Flutter app, plus the screens
Numaya adds. It supersedes the "Before / After" view of [SCREEN_INVENTORY.md](SCREEN_INVENTORY.md), which
stays as the record of the previous pass.

## Counting rules

- **One row per reference screen ID** (B-07a and B-07b are two rows). A row is a distinct surface with its own
  purpose: a route, a full-screen step or a sheet.
- **Variants are not screens.** Loading, empty, error, disabled, selected, pending and success are listed in the
  *States* column of their screen and covered by tests, not counted again.
- **Status:** **Done** = built, reachable from normal navigation and tested · **Partial** = built, but part of the
  reference behaviour needs something this build doesn't have (camera, store, network) · **Deferred** = not built,
  with the reason and dependency · **Out** = outside Numaya's agreed scope (decision log).
- **Scope labels** (Req column): **Core** (the dating loop), **Supporting** (profile, settings, safety), **Optional**
  (nice to have), **Out**.
- **Evidence:** [O] observed on Mobbin, [C] official help, [I] inferred, [U] unverified (as in the research).

## What this pass used

**Repository research:** `docs/research/README.md`, `flow-catalogue.md`, `journey-map.md`, `screen-specs.md`,
`states-and-recovery.md`, `pattern-inventory.md`, `decision-log.md`, `unknowns.md`; the V16 rules and captures
(see [VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md)); the previous [SCREEN_INVENTORY.md](SCREEN_INVENTORY.md).

**Mobbin (connector available, Bumble iOS), flows inspected with their screen counts:**

| Mobbin flow | Screens | What it confirmed or added |
|---|---|---|
| [Discover](https://mobbin.com/flows/da0e3963-af8a-41e2-9f31-58c7df99b2bb) | 5 | Current tabs Profile · For You · People · Liked You · Chats; "For You" curated picks with "See new people in 18 hours" and "Based on your profile and past matches"; swipe coach mark; profile-tips carousel |
| [Filtering people](https://mobbin.com/flows/539ac528-7029-49e9-8636-3d2b4b12a5c0) | 12 | Basic: who you want to date, age + "2 years either side" fallback, distance + "slightly further away" fallback, "Verified profiles only" with "What's this?". Advanced: height ("Taller than 170 cm") + fallback, intentions checklist + fallback, "Add this filter" rows (family plans, kids, religion, education) opening checkbox sheets |
| [Filtering people (BFF)](https://mobbin.com/flows/5c103e1e-0dec-43ab-9a52-00ea0e904b3a) | 7 | Interest and language filters (BFF only, out of scope) |
| [Chats](https://mobbin.com/flows/77f54cb8-94a6-4692-8e2e-97f03a11bd8c) | 7 | Queue "Your matches (10)" with countdown rings and a liked-you stack tile ("50+"); "Your move" tag; ringed unanswered rows; "Conversation expired yesterday" |
| [Sending a chat](https://mobbin.com/flows/6a312979-9402-40e8-b964-f0b771105c4e) | 4 | Bubbles both sides, media, "Delivered", call log rows, composer with camera/GIF/mic |
| [Adding an opening move (text)](https://mobbin.com/flows/4961330a-a184-4c8f-8e2f-8bb6c92dc55c) | 6 | "Your Opening Moves": up to three, "Add" rows, add sheet (photo and caption / text), editor with "111 characters left", Cancel / Save, Done |
| [Matching with a user](https://mobbin.com/flows/e693028d-bda9-45a7-8276-2c1c0fb08e33) (via the Chats search) | 1 seen | "What a match! … You have 24 hours to make your move", composer |
| [Settings](https://mobbin.com/flows/45909c24-0ae4-4add-b508-c74690d67bbf) / [Settings (newer)](https://mobbin.com/flows/9a932505-d4db-486e-9b26-4009af8682d3) | 3 + 3 | Snooze, Incognito (consequence copy), Auto-Spotlight, current location, Travel (lock), video autoplay, notification settings, security and privacy, legal information, get help, restore purchases, log out, delete account, version |
| [Activating snooze mode](https://mobbin.com/flows/06977bc3-faa4-477d-8cca-b77bfa3ee878) | 4 | Away-status action sheet (travelling, work, digital detox, prioritising myself, No thanks) → "Deactivate snooze mode … invisible for another 24 hours" |
| [Completing a profile](https://mobbin.com/flows/3ad96a67-4e1e-4d60-8cdf-893cca19f696) | 12 | Completion ring with % on the Profile tab; "Complete profile" chip |
| [Editing my profile](https://mobbin.com/flows/906e5dfe-59d4-4387-a6ac-905706431897) | 14 | Photos (6, "Hold and drag media to reorder"), Best Photo, Verify my profile, interests (favourite), causes, qualities, prompts, bio with tip card and Cancel / Save bar, About you (work, education, gender, location, hometown), More about you (height, exercise, star sign, education level, drinking, smoking, looking for, family plans, kids, religion, politics), languages, connected accounts |
| [Verifying a photo](https://mobbin.com/flows/6c74489d-ebb8-423d-9964-004637611b19) / [Verifying my profile](https://mobbin.com/flows/eb66bdc5-a349-405a-8c36-a8a9a8158261) | 5 + 11 | Prompt sheet "Show them it's really you", camera with pose thumbnail, help article |
| [Unmatching a user](https://mobbin.com/flows/c0931f07-f723-4020-abf7-b88287484723) | 3 | Chat menu (Share Date, Did you meet?, Unmatch, Report), consequence sheet with "Report instead", reasons after unmatching |
| [Pay plan](https://mobbin.com/flows/8b21909e-9125-4d52-9160-f319bf5bde63) | 2 | Spotlight / SuperSwipe consumables, plan card, "What you get" comparison (unlimited likes, see who liked you, advanced filters, incognito, travel, extends, rematch, backtrack) |

Limitations: flow previews are sampled (some intermediate steps are not shown); images are low-resolution; no
store sheets, OS permission dialogs, offline or failure states exist on Mobbin ([U], as the research already
records). Nothing here is invented: where a state isn't observed, the Numaya rule in `states-and-recovery.md`
was used.

**Gaps the previous inventory missed (all now covered):** curated "For you"; advanced filters and per-filter
fallbacks; "Verified profiles only"; match queue with countdown rings, expiry, Extend and Rematch; the liked-you
tile in the queue; Opening Moves (settings screen and on matches); unmatch reasons; "Did you meet?"; report
"where" step; profile completion ring and hub; bio, About you, More about you, languages, extra prompts;
photo reorder and replace; photo verification; Premium overview, paywall and plan comparison; Incognito and Travel;
snooze length and away status; notification categories and channels; help centre; account restore; moderation
block and appeal.

## Navigation map

```
Welcome ─ Create an account / I have an account ─▶ Phone ─▶ Verify ─▶ Setup hub ─▶ Basics ─▶ Interests ─▶ Photos ─▶ Home
   └ Demo build badge ─▶ Demo hub (development builds only)            └ deleted < 28 days ─▶ Restore account
Tabs: Home (Discover) · Events · Likes · Messages · Profile (Events: EVENTS_SCREEN_INVENTORY.md; Profile › Profile & visibility: ACCOUNT_HEALTH_METRICS.md)
  Home ─ ★ For you · undo · Filters (Basic / Advanced) · ⋯ (Report, Block) · Like ─▶ Match ─▶ Chat
  Likes ─ tile ─▶ Like profile ─▶ Match / Pass
  Messages ─ queue (likes tile, countdown rings, expired) · Opening Moves card · conversations ─▶ Chat ─ ⋯ menu
  Profile ─ ? Help · ⚙ Settings · Complete profile ─▶ Hub · Edit profile ─▶ editors · Preview · Opening Moves ·
            Verify · Premium ─▶ Paywall · Safety and wellbeing · Help centre
  Settings ─ Snooze · Incognito · Location / Travel · Notifications ─▶ categories · Profile visibility ·
             Blocked people · Safety · Help · Terms / Privacy · Restore purchases · Demo hub · Log out · Delete ─▶ reasons
```

## A. Account, sign-in and verification (F1, F2, F26–F28)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-01 | Splash | Optional | — | Deferred | — | — | Brand launch asset; Android shows the default launch screen |
| B-02 | Welcome | Core | `/` | Done | demo badge → Demo hub | `onboarding_flow_test`, `full_app_journeys_test` | — |
| B-03 | Sign-in methods | Core | `/phone?intent=signin` | Done (phone only) | no account sheet | `onboarding_flow_test` | Apple / Google sign-in is P-07 |
| B-04 | Phone number | Core | `/phone` | Done | empty, typing, valid, submitting, invalid, offline, unavailable | `onboarding_flow_test` | — |
| B-05 | Country search | Core | sheet | Done | list, search, no results, selected | `onboarding_flow_test` | — |
| B-06 | Phone submit loading | Core | state of B-04 | Done | busy toast, input locked | `onboarding_flow_test` | — |
| B-07a | Verify by SMS | Core | `/verify` | Done | partial, checking, incorrect, expired, resend, success | unit + `onboarding_flow_test` | Real SMS needs an auth provider |
| B-07b | Verify by call | Optional | — | Deferred | — | — | Needs telephony provider |
| B-08 | Tracking pre-prompt | Out | — | Out | — | — | D-17: no ad tracking |
| B-09 | Email capture | Optional | — | Deferred | — | — | Recommended later for recovery (U-11); A-02 phone-first |
| B-75 | Delete account | Supporting | `/profile/settings/delete` | Done | reason required, snooze instead, consequences, subscription warning, V16 confirm sheet, cancel | `v16_screens_test`, `full_app_journeys_test` | Server deletion endpoint |
| F27 | Account restore | Supporting | `/restore` | Done | restore, start over | `full_app_journeys_test` | Real accounts need a backend |
| B-59 | Moderation block / appeal | Supporting | `/account-blocked` | Done (preview) | appeal empty, sent | `accessibility_test` | Server-triggered: reachable only from the Demo hub |

## B. Profile creation and management (F3–F8, F16)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-10 | Intro (name, birth year) | Core | `/setup/basics` | Done | under 18, unrealistic year, corrected in place | `onboarding_edge_cases_test` | Birth year, not full date (C-2 open) |
| B-11 | Gender | Core | `/setup/basics` | Done | — | `onboarding_flow_test` | — |
| B-12 | Gender detail | Supporting | sheet from Edit profile | Done | — | — | — |
| B-13 | Show gender on profile | Supporting | same sheet, Profile visibility | Done | — | `accessibility_test` | — |
| B-14 | Mode choice | Out | — | Out | — | — | D-08 dating only |
| B-15 | Photos grid | Core | `/setup/photos`, Edit profile | Done (placeholders) | 0–6, min 2, make main, move earlier/later, replace, remove, keep 2 in edit | `photo_options_test` | Real picker and upload (U-08) |
| B-16 | Crop | Supporting | — | Deferred | — | — | Needs the real photo picker |
| B-17 | Interests | Core | `/setup/interests` | Done | 3–5, max reached | `v16_screens_test` | — |
| B-18 | Causes | Optional | — | Deferred | — | — | Not in Numaya's profile model yet |
| B-19 | Relationship status (BFF) | Out | — | Out | — | — | BFF |
| B-20 | Intentions | Core | Basics "Looking for" | Done | max 2 | `onboarding_controller_test` | — |
| B-21 | Profile completion hub | Supporting | `/profile/complete` | Done | per-part progress, 100% copy | `full_app_test` (unit), captures | — |
| B-22 | Mode intro (BFF) | Out | — | Out | — | — | BFF |
| B-23 | Profile tab | Core | `/profile` | Done | completion ring, Premium card active / inactive | `full_app_journeys_test` | — |
| B-24 | Edit profile | Supporting | `/profile/edit` | Done | every row Add / value, Preview | `full_app_journeys_test` | Connected accounts deferred (B-28) |
| B-25 | Text edit | Supporting | sheet | Done | Save disabled until changed, Remove | `full_app_journeys_test` | — |
| B-26 | Attribute picker | Supporting | sheet | Done | choice, Prefer not to say | `full_app_journeys_test` | — |
| B-27 | Opening Move editor + "Your Opening Moves" | Supporting | `/profile/opening-moves` + sheet | Done | 0–3 moves, suggestions, 160 limit, remove | `full_app_journeys_test`, unit | — |
| B-28 | Connected accounts | Optional | — | Deferred | — | — | Instagram / Spotify APIs |
| — | Profile preview (V16 106) | Supporting | `/profile/preview` | Done | hidden age / distance respected | `full_app_journeys_test` | — |
| — | Prompts 2 and 3 | Supporting | `/profile/edit/prompt?slot=1` | Done | add, edit, remove | `full_app_journeys_test` | — |

## C. Discovery and filters (F9–F11)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-30 | People stack | Core | `/home` | Done | like, pass, swipe, undo, SuperSwipe (credits → paywall), fallback banner, retry skeleton, error, snoozed | `dating_test`, `full_app_test` | Real profiles need a backend |
| B-31 | Swipe coach mark | Optional | `/home` first card | Done | tip on the first card; hidden by ✕ or the first decision | `discovery_test` | A small card on the photo instead of a dimmed overlay, so the profile stays visible (DISCOVERY_SCREEN_INVENTORY DD-9) |
| B-32 | Expanded profile | Core | `/home` scroll, `/person/:id?decide=1` | Done | prompts (up to 3), about me with bio and details, shared interests, location, photos, Like / Pass | `dating_test`, `full_app_journeys_test` | — |
| B-33 | Curated Discover ("For you") | Supporting | `/for-you` | Done | picks, refresh countdown, empty | `full_app_journeys_test`, unit | P-08: both formats offered |
| B-34 | Filters: basic | Core | sheet | Done | who to date, age + fallback, distance + fallback, verified only, live count, none fit, reset | `dating_test`, `full_app_journeys_test` | — |
| B-35 | Filters: advanced | Supporting | sheet (Advanced tab) | Done | locked without Premium; height, intentions, add-filter sheets, fallback | unit | P-05 premium scope |
| B-36 | Filters (BFF) | Out | — | Out | — | — | BFF |
| B-37 | Out of profiles | Core | `/home` states | Done | no one fits → widen, seen everyone → show again | `dating_test` | — |

## D. Matching, likes and chat (F12–F17, F19)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-40 | Match | Core | `/match/:id` | Done | send → chat, keep browsing | `dating_test` | — |
| B-41 | Match + Opening Move | Supporting | `/match/:id` | Done | their move shown | captures | — |
| B-42 | Chats inbox | Core | `/messages` | Done | queue rings, urgent, expired, likes tile, search, All / Unread / Your move, counts | `dating_test`, `full_app_journeys_test` | — |
| B-43 | Chats empty | Core | `/messages` | Done | Opening Moves card | `dating_test` | — |
| B-44 | Conversation | Core | `/chat/:id` | Partial | sample history both sides, day lines, times, unread clearing, sending, on device, failed → retry / delete, Opening Move, openers | `dating_test`, `full_app_journeys_test` | Text only: photos, GIFs, voice, calls are Out (X); delivery needs a backend |
| B-45 | Chat ⋯ menu | Core | action sheet | Done | view profile, did you meet, unmatch, block, report | `full_app_journeys_test` | "Share Date" deferred (needs sharing service) |
| B-46 | Liked You | Core | `/likes`, `/like/:id` | Done | All / New / Nearby, matched badge, empty states, like back, pass | `dating_test`, `v16_screens_test` | Visible, not blurred (C-6, P-05) |
| B-47 | Expiry, Extend, Rematch | Supporting | queue + `/chat/:id` | Done | time left, 1 free Extend a day, expired, Rematch → paywall | `full_app_test`, `full_app_journeys_test` | P-03: 24 h used (observed) |
| B-55 | Did you meet? | Optional | sheet | Done | yes / no saved on device | `full_app_journeys_test` | — |

## E. Safety and verification (F17, F18, F20)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-50 | Report reasons | Core | sheet | Done | send disabled until a reason | `dating_test` | Moderation backend |
| B-51 | Report detail ("where") | Supporting | same sheet | Done | photos, profile text, messages | `full_app_journeys_test` | — |
| B-52 | Report confirmation | Core | same sheet | Done | honest "kept on this device" copy | `dating_test` | — |
| B-53 | Unmatch confirm | Core | sheet | Done | report instead | `dating_test` | — |
| B-54 | Unmatch reason | Optional | sheet | Done | skip, reason saved | `dating_test` | — |
| B-56 | Verification prompt | Supporting | `/profile/verify` | Done | intro, demo note | `full_app_journeys_test` | — |
| B-57 | Pose capture | Supporting | `/profile/verify` | Partial | pose, other pose, demo selfie, review, retake | `full_app_journeys_test` | Camera and review service: simulated, says so |
| B-58 | Verification help | Supporting | `/help/verification` | Done | — | `accessibility_test` | — |
| — | Pending / approved / declined | Supporting | `/profile/verify` | Done | tips, 3 tries → support | `full_app_test`, `full_app_journeys_test` | — |
| — | Blocked people | Supporting | `/profile/settings/blocked` | Done | list, unblock, empty | `dating_test` | — |
| — | Safety and wellbeing | Supporting | `/profile/safety` | Done | tips, tools | `accessibility_test` | — |

## F. Premium (F21)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-60 | Pay plan | Optional | `/profile/premium` | Done | inactive, active until, SuperSwipes left, cancel demo plan | `full_app_test` | — |
| B-61 | Paywall | Optional | `/paywall?feature=` | Done | names its trigger, no plan pre-selected, legal copy, restore | `full_app_journeys_test` | D-14 |
| B-62 | Purchase success | Optional | paywall result | Done | "Demo only: no payment was taken" | `full_app_journeys_test` | — |
| B-63 | Active subscription | Optional | Profile card, Premium | Done | — | unit | — |
| B-64 | Plan comparison | Optional | `/profile/premium` | Done | — | captures | — |
| B-65 | Store sheet, failure, cancel | Optional | confirm sheet | Partial | simulated failure keeps the plan selected | `full_app_journeys_test` | Real store (Play Billing) |

## G. Settings and lifecycle (F22–F25, F29)

| ID | Screen | Req | Flutter route | Status | States covered | Tests | Dependency / note |
|---|---|---|---|---|---|---|---|
| B-70 | Settings | Core | `/profile/settings` | Done | every row acts, navigates or says why not | `full_app_journeys_test`, `accessibility_test` | Location, push, store not connected (rows say so) |
| B-71 | Snooze status sheet | Supporting | sheets | Done | length, away status, no thanks | `dating_test`, unit | — |
| B-72 | Snoozed state | Supporting | Settings row, Home paused | Done | until date · status, resume | `dating_test` | — |
| B-73 | Saving toggle | Optional | — | Deferred | — | — | Nothing to wait for without a server |
| B-74 | Notification category | Supporting | `/profile/settings/notifications` | Done | push, in-app, email unavailable | unit, `accessibility_test` | Push service |
| B-76 | OS permission dialogs | Supporting | — | Deferred | — | — | The build asks for no permissions; primers come with location / push / camera |
| B-77 | Offline, error, retry, message failure | Supporting | Home, Chat | Partial | simulated load error with retry, send failure with retry / delete | `dating_test` | Offline banner needs real networking |
| F24 | Turn off a mode | Out | — | Out | — | — | D-08 |
| F29 | Help centre | Supporting | `/help`, `/help/:id`, `/help/contact` | Done | search, no results, article, contact (not sent) | `accessibility_test` | Support desk |
| — | Profile visibility, Incognito, Travel | Supporting | `/profile/settings/privacy`, Settings | Done | locked without Premium | unit | — |
| — | Log out confirmation | Core | sheet | Done | cancel, confirm | `full_app_journeys_test` | — |
| — | Not found (direct-route recovery) | Core | any unknown path | Done | back home / to start | `full_app_journeys_test` | — |
| — | Demo hub | Development | `/demo` | Done | quick start, world, reset, switches, every screen | `full_app_journeys_test` | Refused in release builds |

## Counts

Reference screen IDs in the catalogue: **69 rows** (B-01–B-77 as listed, with B-07a/b separate).

| Status | Rows | IDs |
|---|---|---|
| Done | 52 | B-02–B-06, B-07a, B-10–B-13, B-15, B-17, B-20, B-21, B-23–B-27, B-30, B-31, B-32–B-35, B-37, B-40–B-43, B-45–B-47, B-50–B-56, B-58–B-64, B-70–B-72, B-74, B-75 |
| Partial | 4 | B-44 (text only), B-57 (no camera), B-65 (no store), B-77 (no real network) |
| Deferred | 8 | B-01, B-07b, B-09, B-16, B-18, B-28, B-73, B-76 |
| Out of scope | 5 | B-08, B-14, B-19, B-22, B-36 |

Flows F1–F29: **27 implemented** (F1–F5, F7–F23, F25–F29), of which F15 is text-only, F20 and F21 are
simulated and F28 is a server-triggered preview; **2 out of scope** (F6 BFF setup, F24 turning off a mode). BFF
filters inside F11 are also out.

Screens Numaya adds beyond the catalogue (each a route or sheet): profile preview, extra prompts, blocked people,
safety and wellbeing, profile visibility, notification list, contact support, log out confirmation, not found,
Demo hub — **10**.

**Blocked by this environment** (not product gaps): building the APK, running on a phone or emulator, the
on-device integration test, and hardware checks (keyboard, gestures, TalkBack). The Android SDK download host is
refused by the network policy.

## Product decisions (recommendation used, still open)

| # | Question | What the app does now | Recommendation |
|---|---|---|---|
| P-03 | Match expiry | 24 h, one free Extend a day, Rematch with Premium | Keep 24 h with Extend; it gives the queue meaning without pressure copy |
| P-05 | Premium scope | Advanced filters, Rematch, unlimited Extends, Incognito, Travel, extra SuperSwipes; Likes and Undo stay free | Keep Likes free while the member base is small |
| P-06 | Photo verification | Optional, from Profile / Edit profile / Safety; "Verified only" filter | Optional at launch, required before messaging only if abuse data says so |
| P-08 | Discovery format | Card stack plus "For you" picks | Both |
| P-10 | Notification primer | No primer (nothing to ask for yet) | After the first match |
| C-2 | Under 18 | Inline error, corrected in place | Legal decision |
| D-13 | Reporting always blocks | "Also block" on by default, can be unticked | Decide whether to make it mandatory as D-13 states |

## Quality matrix (quality and motion pass)

Added on `experiment/numaya-quality-motion`. One row per route. **Motion:** *push* = the token page slide
(460 ms, drawer curve), *modal* = rises and fades over the page it interrupts, *tab* = instant (frequent),
*sheet* = sheets on the screen use the drawer curve; every one is instant under *Remove animations*.
**A11y:** *G* = tap-target and label guidelines pass, *L* = no layout error at 375 × 667 and 130% text,
*W* = no layout error with worst-case data at 320 pt, 130% and 200% text. **Device:** nothing has been run
on a phone or emulator (no Android SDK here), so the column is *No* throughout.

| Route | Screen | Status | Motion and feedback | A11y | Tests | Open defects | Device |
|---|---|---|---|---|---|---|---|
| `/` | Welcome | Done | push; scrolls under large text | G L W | `onboarding_flow_test` | — | No |
| `/phone` | Phone | Done | push; selection haptic on country | G L | `onboarding_flow_test` | — | No |
| `/verify` | Code | Done | push; shake + reject haptic on a wrong code; caret still under reduced motion | G L | `onboarding_flow_test`, `motion_test` | — | No |
| `/setup` … `/setup/photos`, `/setup/prompt` | Setup hub, basics, interests, photos, prompt | Done | push; progress segment fills (`progress`); chips and options tick | G L | `onboarding_*`, `v16_screens_test` | O-01 first name unbounded | No |
| `/home` | Home (Discover) | Done | decide: exit 200 ms in the decision's direction, settle 220 ms, commit haptic; swipe: threshold tick, fling, leaves from release; sheets | G L W | `dating_test`, `motion_test` | O-05 spring on release | No |
| `/for-you` | For you | Done | push | G L | `full_app_journeys_test` | — | No |
| `/match/:id` | Match | Done | modal; staged 560 ms entrance, one success haptic, touch skips, complete under reduced motion | G L | `dating_test`, `motion_test` | — | No |
| `/likes`, `/like/:id` | Likes, a like's profile | Done | tab; push | G L | `dating_test` | — | No |
| `/person/:id` | Profile from a chat or For you | Done | push | L | `full_app_journeys_test` | — | No |
| `/messages` | Messages | Done | tab; filter chips tick | G L W | `dating_test`, `full_app_journeys_test` | — | No |
| `/chat/:id` | Conversation | Partial (text only) | push; opens at newest; sent bubble settles in; commit haptic; follows to new message after layout | G L W | `dating_test`, `motion_test` | — | No |
| `/profile` | Profile | Done | tab; completion ring fills from old value | G L W | `full_app_journeys_test` | — | No |
| `/profile/complete` | Completion hub | Done | push | G L W | `full_app_journeys_test` | — | No |
| `/profile/edit` and sub-routes | Edit profile | Done | push; sheets | G L W | `full_app_journeys_test`, `photo_options_test` | — | No |
| `/profile/preview` | Preview | Done | push; card grows under large text | G L W | `full_app_journeys_test` | — | No |
| `/profile/opening-moves` | Opening Moves | Done | push | G L W | `full_app_journeys_test` | — | No |
| `/profile/verify` | Photo verification | Partial (no camera) | modal; success / reject haptic on the review result | G L | `full_app_journeys_test` | — | No |
| `/profile/premium`, `/paywall` | Premium, paywall | Partial (no store) | modal; plan cards tick; success / reject haptic on the simulated result | G L W | `full_app_journeys_test` | — | No |
| `/profile/settings` | Settings | Done | push; switches tick; Vibration switch gates all haptics | G L W | `v16_screens_test`, `motion_test` | — | No |
| `/profile/settings/notifications`, `/privacy`, `/delete`, `/blocked` | Settings pages | Done | push | G L | `full_app_journeys_test`, `v16_screens_test` | — | No |
| `/profile/safety`, `/help`, `/help/:id`, `/help/contact` | Safety and help | Done | push | G L | `full_app_journeys_test` | — | No |
| `/restore`, `/account-blocked` | Account lifecycle | Done | push | G L | `full_app_journeys_test` | — | No |
| `/demo` | Demo Hub (development only) | Done | push; *Reduce motion* switch | G L | `full_app_journeys_test`, `motion_test` | — | No |
| unknown | Not found | Done | push | G L | `full_app_journeys_test` | — | No |
| (shell) | Tab bar and back | Done | tabs instant; Android back on another tab returns to Home first | — | `full_app_journeys_test` | — | No |

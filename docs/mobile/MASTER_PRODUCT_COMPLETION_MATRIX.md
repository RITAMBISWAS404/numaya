# Master product completion matrix

> Updated by [OVERNIGHT_COMPLETION_MATRIX.md](OVERNIGHT_COMPLETION_MATRIX.md): chat photos, videos and demo voice notes (F15), real profile photos (F4), three new screens and four layout fixes.

The authoritative record of what the Flutter app (`apps/numaya_mobile`) implements, what is partial and
what remains. Detailed per-screen rows stay in the area inventories this file links to; this file
reconciles them against the code and records the next action for anything not complete.

- **Branch:** `experiment/numaya-complete-product`, from `experiment/numaya-full-ui-refinement` @ `d92af19`.
  That branch contains every earlier mobile branch (onboarding, Android 12 compatibility, full app, quality and
  motion, discovery, events and account health, UI refinement), checked with `git merge-base --is-ancestor`.
- **Reports:** [MASTER_IMPLEMENTATION_REPORT.md](MASTER_IMPLEMENTATION_REPORT.md) and
  [MASTER_QA_REPORT.md](MASTER_QA_REPORT.md).
- **Restart:** run `git log --oneline -5`, read the "Next actions" section below, then continue from the
  first open item.

## Counting rules

1. A **screen** is a distinct surface with its own purpose: a route, a full-screen step or a sheet.
   Loading, empty, error, success and selected are **states** of their screen, never extra screens.
2. A **flow** is a user journey with an entry and an exit. It spans several screens.
3. Reference screens keep their research IDs (B-xx from [flow-catalogue.md](../research/flow-catalogue.md),
   EV-xx from [EVENTS_SCREEN_INVENTORY.md](EVENTS_SCREEN_INVENTORY.md)). Numaya-only screens are listed
   separately.
4. **Status:**
   - **Complete**: built, reachable through normal navigation, states covered, tested.
   - **Partial**: built, but part of the reference behaviour needs something this build cannot have (camera,
     store, real network, OS dialogs). The simulation is labelled in the UI.
   - **Deferred**: not built. The dependency is named.
   - **Blocked**: cannot be done in this environment.
   - **Out**: outside agreed product scope (decision log).

## Totals (verified against the code on this branch)

| Group | Screens | Complete | Partial | Deferred | Out |
|---|---|---|---|---|---|
| Reference catalogue B-01–B-77 (69 rows) | 69 | 53 | 5 | 6 | 5 |
| Events EV-01–EV-13 | 13 | 13 | — | — | — |
| Profile & visibility | 2 | 2 | — | — | — |
| Numaya-only screens | 13 | 13 | — | — | — |
| **Total** | **97** | **81** | **5** | **6** | **5** |

| Flows | Total | Complete | Partial | Out |
|---|---|---|---|---|
| F1–F29 (dating catalogue) | 29 | 23 | 4 (F15, F20, F21, F28) | 2 (F6, F24) |
| Events (EF-1–EF-4) | 4 | 4 | — | — |
| Profile & visibility (AF-1) | 1 | 1 | — | — |
| System states (SF-1–SF-3) | 3 | 2 | 1 (SF-1, no real network) | — |
| **Total** | **37** | **30** | **5** | **2** |

**Meaningful states:** 70 for Events (its inventory), and 10 Profile & visibility sections with their own
states. The per-screen state lists for the dating catalogue are in the *States* column of
[FULL_APP_SCREEN_INVENTORY.md](FULL_APP_SCREEN_INVENTORY.md). States are not summed into one figure here,
because the inventories count them differently.

## Flow matrix

Tests are files under `apps/numaya_mobile/test/`. "u:" is a unit test, "w:" a widget test.

| ID | Flow and user goal | Routes | Required states (beyond content) | Ref | Tests | Status | Defects, dependencies, next action |
|---|---|---|---|---|---|---|---|
| F1 | Create an account with a phone number | `/`, `/phone`, `/verify` | invalid number, sending, code partial / checking / incorrect / expired after 5 / resend cooldown / success | B-02–B-07a | u:demo_auth_repository, w:onboarding_flow | Complete | Real SMS needs an auth provider. Verify-by-call (B-07b) deferred: states-and-recovery reserves the call fallback |
| F2 | Sign in again | `/` → `/phone` (sign-in) → `/verify` | no account found → create or other number; deleted < 28 days → restore | B-03 | w:full_app_journeys | Complete | — |
| F3 | Profile basics: name, birthday, gender (detail, pronouns, show on profile), who to meet, intentions, height, location | `/setup/*` | under 18 → locked; age confirm; skip on optional steps; discard guard on edits | B-10–B-13, B-20 | w:onboarding_complete, w:onboarding_edge_cases, u:onboarding_controller | Complete | C-2 (under-18 retry) follows the recorded product choice |
| F4 | Add, order, replace and remove photos | `/setup/photos`, `/profile/edit/photos` | fewer than 2 blocks; options sheet (main, move, replace, remove); keep at least 2 in edit | B-15 | w:photo_options, u:onboarding_controller | Complete | Crop (B-16) deferred: needs a real picker |
| F5 | Interests, prompts, bio | `/setup/interests`, `/setup/prompts`, `/setup/bio` | quota counter; quota reached; character counts | B-17, B-27 | w:onboarding_complete | Complete | Causes (B-18) deferred: not in the profile model |
| F6 | BFF mode setup | — | — | B-14, B-19, B-22 | — | Out | D-08: dating only |
| F7 | Complete the profile from a hub | `/profile/complete` | per-part progress; 100% | B-21 | w:visibility, u:full_app | Complete | — |
| F8 | Edit profile | `/profile/edit` + editors | every row add / value; autosave; preview | B-24–B-26 | w:full_app_journeys | Complete | Connected accounts (B-28) deferred: Instagram / Spotify APIs |
| F9 | Decide on people in Discover | `/home` | coach mark; drag to decide; loading skeleton; load error → retry; no one fits → widen; seen everyone → show again; paused; fallback banner | B-30–B-32, B-37 | w:discovery, w:dating, u:dating_controller | Complete | — |
| F10 | Curated picks | `/for-you` | countdown; empty | B-33 | u:full_app | Complete | — |
| F11 | Filter people (basic, advanced) | Filters sheet | live count; per-filter fallbacks; Premium lock on advanced | B-34, B-35 | u:dating_controller, w:dating | Complete | BFF filters (B-36) out |
| F12 | Match and first move | `/match/:id` | Opening Move; composer; keep browsing | B-40, B-41 | w:dating, w:motion | Complete | Match window is 24 h (D-10 / P-03 still **open**; the value is provisional) |
| F13 | Match queue, expiry, Extend, Rematch | `/messages` | countdown rings; expiring; expired; Extend once; Rematch needs Premium | B-42, B-47 | u:full_app, w:full_app_journeys | Complete | Same open decision as F12 |
| F14 | See who liked you | `/likes`, `/like/:id` | filters (All / New / Nearby); empty; like back → match; pass | B-46 | w:dating, w:v16_screens | Complete | Likes visible to everyone (P-05 open, C-6) |
| F15 | Chat | `/chat/:id` | sample history; unread; sending; on device; failed → retry / delete; **waiting offline → sends on reconnect** (this pass); ended view | B-43, B-44 | w:dating, w:system_states, u:dating_controller | Partial | Text only: photos, GIFs, voice and calls out; delivery needs a backend |
| F16 | Opening Moves | `/profile/opening-moves` | up to three; editor with counter; empty | B-27 | w:full_app_journeys | Complete | — |
| F17 | Unmatch | Chat ⋯ | consequences; report instead; reason after | B-53, B-54 | w:dating | Complete | — |
| F18 | Report and block | card ⋯, profile, chat ⋯ | reasons; where (photos, text, messages); saved on device; blocked list; unblock | B-50–B-52 | w:dating, w:full_app_journeys | Complete | Moderation needs trust and safety |
| F19 | Did you meet? | Chat ⋯ | yes / no; thanks | B-55 | w:full_app_journeys | Complete | — |
| F19b | **Share Date** (this pass) | Chat ⋯ → Share date details | empty fields block Share; preview of what a friend sees; saved; edit later | B-45 | w:full_app_journeys | Complete (simulated) | Sending needs the share sheet; nothing leaves the device |
| F20 | Photo verification | `/profile/verify` | intro; pose; other pose; in review; approved; rejected with tips; support after 3 | B-56–B-58 | w:full_app_journeys | Partial | Camera and review service simulated |
| F21 | Premium | `/profile/premium`, `/paywall` | contextual trigger; no pre-selected plan; failure keeps the plan; success; active | B-60–B-65 | w:full_app_journeys | Partial | Store (Play Billing) simulated |
| F22 | Settings and visibility | `/profile/settings` | Incognito lock; Travel lock; location not set; **recovery email** (this pass) | B-70 | w:full_app_journeys, w:recovery_email | Complete | Push / email delivery not connected; switches are preferences |
| F23 | Snooze | Settings | length; away status; snoozed until; resume; Discover paused | B-71, B-72 | w:dating, w:visibility | Complete | — |
| F24 | Turn off a mode | — | — | — | — | Out | D-08 |
| F25 | Notification settings | `/profile/settings/notifications` | per-category; push / in-app / **email (enabled once an email is on file)** | B-74 | w:v16_screens, w:recovery_email | Complete | — |
| F26 | Delete account | `/profile/settings/delete` | reasons; snooze instead; subscription warning; confirm | B-75 | w:full_app_journeys | Complete | — |
| F27 | Restore account | `/restore` | within 28 days; start over | — | w:full_app_journeys | Complete | — |
| F28 | Moderation block and appeal | `/account-blocked` | appeal empty; sent | B-59 | w:accessibility | Partial | Server-triggered: reachable from the Demo Hub and the visibility notice |
| F29 | Help centre | `/help`, `/help/:id`, `/help/contact` | search; no results; article; contact sent | — | w:full_app_journeys | Complete | — |
| EF-1 | Find an event | `/events` | search; categories, date, free, format, distance (needs area), sort; picks; skeleton; error; error after retry; no results; Demo data note | EV-01, EV-03 | w:events, u:events_controller | Complete | Real "near me" needs location |
| EF-2 | Decide and RSVP | `/event/:id`, join sheet | open; few spots; full → waitlist; registration closed; happening now; past; cancelled; changed; question; failure → retry; **offline → fails safely** | EV-04–EV-06, EV-12 | w:events, w:system_states | Complete | Real capacity needs an events service |
| EF-3 | My events | `/events?view=mine` | Going, Waitlist, Saved, Hosting (drafts, cancelled), Past; each empty | EV-02 | w:events | Complete | — |
| EF-4 | Host an event | `/event/new`, `/event/:id/edit`, `/event/:id/people` | validation; draft; preview; publish; edit published; cancel with note; remove attendee; move up from waitlist | EV-07–EV-11 | w:events, u:events_controller | Complete | Paid tickets out (no payments) |
| AF-1 | Understand profile visibility | `/profile/visibility`, `/about` | visible; limited; paused; action needed; can't check; notice; activity live / stale / unavailable / not enough | [ACCOUNT_HEALTH_METRICS.md](ACCOUNT_HEALTH_METRICS.md) | u:visibility_report, w:visibility | Complete | Activity counts are sample data, labelled |
| SF-1 | **Offline** (this pass) | every screen | banner; messages wait; joins fail with retry; banner clears on reconnect | states §3 | w:system_states, u:dating_controller | Partial | Detecting the real network needs a connectivity plugin; simulated from the Demo Hub |
| SF-2 | **Session expired** (this pass) | `/sign-in-again` over the current screen | can't be skipped with back; send code; wrong code; expired code; success returns to the same screen; sign out instead | states §3 | w:system_states | Complete (simulated trigger) | A real 401 would come from the API client |
| SF-3 | Load errors and retry | Discover, Events, sheets | skeleton; error; retry; still failing | states §3 | w:dating, w:events | Complete | — |

## Reference screens not complete

| ID | Screen | Status | Why / dependency | Next action |
|---|---|---|---|---|
| B-44 | Conversation | Partial | Text only; media, voice, calls are out of scope; delivery needs a backend | None until a messaging service is chosen |
| B-57 | Pose capture | Partial | No camera plugin; labelled simulation | Add a camera plugin with the verification service |
| B-65 | Store sheet / failure | Partial | No Play Billing | With the store integration |
| B-76 | OS permission dialogs | Partial | A labelled stand-in for Android's prompt records the answer (`permission_prompt.dart`); real dialogs need a permission plugin | With location / push / camera work. The earlier inventory said Deferred; the code has the stand-in |
| B-77 | Offline, error, message failure | Partial | All UI states built (this pass added offline and the message queue); real detection needs networking | Feed `connectivityProvider` from the platform when a backend exists |
| B-01 | Splash | Deferred | Android shows the default launch screen; a branded one needs native resources that can't be checked without the SDK | With the first device build |
| B-07b | Verify by call | Deferred | Telephony provider; the decision reserves it | Product decision |
| B-16 | Crop | Deferred | Needs a real photo picker | With the picker |
| B-18 | Causes | Deferred | Not in the profile model | Product decision |
| B-28 | Connected accounts | Deferred | Instagram / Spotify APIs | Partner agreements |
| B-73 | Saving toggle | Deferred | Nothing to wait for without a server | With the settings service |

## Numaya-only screens (13, all complete)

1. Profile preview
2. Extra prompts
3. Blocked people
4. Safety and wellbeing
5. Profile visibility (privacy)
6. Notification list
7. Contact support
8. Log out confirmation
9. Not found
10. Demo Hub (debug builds only)
11. Sign in again (this pass)
12. Recovery email sheet (this pass)
13. Share date sheet (this pass)

## Reconciliation with earlier reports

| Earlier claim | Found in code | Resolution |
|---|---|---|
| FULL_APP inventory: B-09 email capture deferred | Not built | **Built this pass** as a recovery email in Settings (B-09 kept out of onboarding: phone-first, A-02) |
| FULL_APP inventory: B-76 deferred | A labelled stand-in prompt exists | Recorded as Partial |
| SCREEN_INVENTORY (older): gender detail sheet, profile preview, Premium, verification "not built" | All built | That file is the earlier record; FULL_APP inventory supersedes it |
| Share Date "deferred (needs sharing service)" | Not built | **Built this pass**, with nothing sent |
| states-and-recovery §3 offline banner, session expired: not covered | Not built | **Built this pass** (SF-1, SF-2) |
| UI_REFINEMENT_QA RR-1 (tab rows inside the gutter), RR-2 (cover badges touching the mark) | Still present | **Fixed this pass** |
| UI_REFINEMENT_QA RR-3 (Likes grid 3:4) | Intentional | Confirmed: thumbnails in a two-column grid (RD-10) |
| Test counts in earlier reports (227 passed, 8 skipped at `d92af19`) | Re-run: 227 passed, 8 skipped | Verified before any change |

## Open product decisions still affecting the build

Each of these uses a provisional value, and the UI does not present it as final.

| Decision | Value used |
|---|---|
| P-03 match expiry | 24 h with one free Extend and a Premium Rematch |
| P-04 minimum photos | 2 required, 4 recommended |
| P-05 Premium scope | Advanced filters, Rematch, unlimited Extends, Incognito, Travel, extra SuperSwipes; Likes visible to everyone |
| P-06 photo verification | Optional, after sign-up |
| P-10 notification primer timing | Primer in onboarding, answers recorded |

## Next actions

1. **Done in this pass:**
   - offline (SF-1);
   - session expired (SF-2);
   - recovery email;
   - Share Date;
   - RR-1 and RR-2.
2. **Waiting on a backend or a product decision:** every Deferred and Partial row above. No coherent local
   prototype is left to build for them without inventing services.
3. **Blocked here:**
   - an APK or device run: the Android SDK host returns 403 through the proxy;
   - TalkBack and touch checks on hardware.

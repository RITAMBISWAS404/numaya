# MVP PRD v1: requirements traceability

> **Amended 2026-11-08 (Visual Lab V2):** S20, S21, S23, S24, S25, S29 and the S11 likes line changed
> (Archive replaces expiry and reconnection; Compliments moved to the Heart tab; Your insights replaces
> the Health score). See [AMENDMENTS_VISUAL_LAB_V2.md](AMENDMENTS_VISUAL_LAB_V2.md). Rows below describe
> PRD v1 as built on `f6c4d8b`.

Every S-ID from [`source/03_SCREENS_AND_FLOWS.md`](source/03_SCREENS_AND_FLOWS.md) mapped to its route and
widget, the tests that cover it, and its gallery screenshots (folder
`C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\MVP PRD 2026-11-07\`, `index.tsv` lists every
file by S-ID). Status: **Built** (implemented and working in the demo), **Retained** (existing screen
kept, checked against the contract), **Changed** (existing screen changed for the PRD), **Demo** (works
on demo data; live service missing, see [LIVE_BLOCKERS](LIVE_BLOCKERS.md)).

Test files: `U-rules` = `test/unit/mvp_rules_test.dart`, `U-ctl` = `test/unit/mvp_controllers_test.dart`,
`W-mvp` = `test/widget/mvp_screens_test.dart` (layout at 320/360/411 dp × 100/200% text, tap targets
and labels on every MVP route), `W-journeys` = `test/widget/full_app_journeys_test.dart`, `W-onb` =
onboarding suites, `W-dating` = `test/widget/dating_test.dart`.

| S-ID | Screen | Route / widget | Status | Tests |
|---|---|---|---|---|
| S01 | Welcome | `/` `WelcomeScreen` (Terms/Privacy now open `/legal/*`) | Changed | W-onb |
| S02 | Phone | `/phone` `PhoneScreen` (rate limit: demo auth throttle) | Retained, Demo | W-onb, `demo_auth_repository_test` |
| S03 | OTP | `/verify` `VerifyScreen` (invalid/expired/throttled) | Retained, Demo | W-onb |
| S04 | Eligibility | `/setup/name` + `/setup/underage` (18+; no profile created under 18) | Retained | `profile_rules_test`, W-onb |
| S05 | Identity | `/setup/name`, `/setup/gender` (pronouns optional) | Retained | W-onb |
| S06 | Preferences | `/setup/meet` (who + age range), `/setup/intentions` | Retained | W-onb |
| S07 | Location | `/setup/location` (manual area; coarse device location not wired) | Retained, Demo | W-onb |
| S08 | Photos | `/setup/photos` 2–6, reorder, demo moderation note | Changed, Demo | `profile_photos_test`, `photo_options_test` |
| S09 | About | `/setup/prompts`, `/setup/prompt`, `/setup/bio` (bio required 1–300; prompt 1–150; up to 3) | Changed | `profile_rules_test`, `onboarding_complete_test` |
| S10 | Review | `/setup/review` (bio in missing list) → `/setup/done` (welcome credits once) | Changed | `onboarding_complete_test`, U-ctl |
| S11 | Discover | `/home` `DiscoverScreen`: likes-left line, Compliment anchors on photo 1 and every photo/prompt | Changed | W-mvp, W-dating, U-ctl |
| S12 | Profile detail | `/person/:id?decide=1` `PersonProfileScreen` (anchors, like/pass, report) | Changed | W-mvp |
| S13 | Filters | `showFiltersSheet` (age/distance/gender free; intention/lifestyle Premium; preferences kept) | Retained | W-journeys, `full_app_test` |
| S14 | Compliment composer | `/compliment/:id?kind=&index=` `ComplimentComposerScreen` | Built | W-mvp, U-ctl, U-rules |
| S15 | Match | `/match/:id` `MatchScreen` (24 h) | Retained | W-dating |
| S16 | Supply empty | Discover empty states (no fit → widen; seen all; never implies paying adds people) | Retained | `discovery_test`, `dating_test` |
| S17 | Allowance used | `/allowance` `AllowanceUsedScreen` + Discover out-of-likes line | Built | W-mvp, U-ctl |
| S18 | Likes | `/likes` `LikesScreen` (free locked count; Premium grid) | Changed | W-dating, `v16_screens_test` |
| S19 | Incoming profile | `/like/:id` `LikeProfileScreen` (like back spends allowance; free → locked) | Changed | W-dating |
| S20 | Chats | `/messages` `MessagesScreen`: Requests, pending matches with time left, conversations, Expired entry | Changed | W-mvp, `profile_review3_test` |
| S21 | Request | `/request/:id` `RequestScreen` (reply opens chat; dismiss; report/block) | Built | W-mvp, U-ctl |
| S22 | Conversation | `/chat/:id` `ChatScreen`: text only, sending status/retry, expired read-only with reconnect, spam guard | Changed | W-journeys, `chat_review3_test`, U-ctl |
| S23 | Check-in | `showCheckInSheet` on opening a 7-day-quiet chat | Built | W-mvp, U-ctl, U-rules |
| S24 | Expired chats | `/chats/expired` `ExpiredChatsScreen` | Built | W-mvp, `full_app_test` |
| S25 | Reconnect request | `/reconnect/:id` `ReconnectRequestScreen` | Built | W-mvp, `full_app_test`, U-rules |
| S26 | Chat actions | Chat menu: Mute/Unmute added; unmatch, block, report with confirmations | Changed | W-dating |
| S27 | Profile hub | `/profile` `ProfileScreen`: Profile Health row, credits, streak, insights | Changed | W-mvp, `visibility_test` |
| S28 | Edit profile | `/profile/edit` `EditProfileScreen` | Retained | `profile_*` tests |
| S29 | Health dashboard | `/profile/health` `HealthScreen` | Built | W-mvp, U-rules |
| S30 | Health explanation | `/profile/health/about` `HealthAboutScreen` (factors, restrictions, appeal link) | Built | W-mvp, U-rules |
| S31 | Insights | `/profile/insights` `InsightsScreen` (7 free; 28/90 + rate Premium; sample labelled) | Built, Demo | W-mvp, U-rules |
| S32 | Streak | `/profile/streak` `StreakScreen` | Built | W-mvp, U-rules, U-ctl |
| S33 | Credit wallet | `/profile/wallet` `WalletScreen` | Built | W-mvp, U-rules |
| S34 | Premium | `/paywall` `PaywallScreen`, `/profile/premium` `PremiumScreen` (₹ provisional, full terms, restore) | Changed, Demo | W-journeys, U-ctl |
| S35 | Compliment pack | `/store/compliments` `ComplimentPackScreen` | Built, Demo | W-mvp, U-ctl |
| S36 | Recovery purchase | `/store/recovery` `RecoveryScreen` (recheck before charge) | Built, Demo | W-mvp, U-ctl |
| S37 | Purchase outcome | `/store/outcome?kind=&result=` `PurchaseOutcomeScreen` | Built | W-mvp, W-journeys |
| S38 | Settings | `/profile/settings` + Subscription, Legal, Support requests rows | Changed | `settings`/`v16` tests |
| S39 | Notifications | `/profile/settings/notifications` (switches; no push service) | Retained, Demo | existing |
| S40 | Privacy and pause | `/profile/settings/privacy`, snooze | Retained | `dating_test` (snooze) |
| S41 | Blocked accounts | `/profile/settings/blocked` (unblock never recreates a match) | Retained | `dating_test` |
| S42 | Report | `showReportSheet` (reason, part, detail, block choice; device-only) | Retained, Demo | `dating_test` |
| S43 | Support and appeal | `/help/contact` (now tracked) + `/help/requests` `SupportRequestsScreen` | Built, Demo | W-mvp |
| S44 | Delete account | `/profile/settings/delete` | Retained, Demo | `v16_screens_test` |
| S45 | Legal | `/legal`, `/legal/:doc` (readable signed out) | Built (drafts) | W-mvp |
| S46 | Account restricted | `/account-blocked` `AccountBlockedScreen` (reason, appeal, no paid bypass) | Retained, Demo | `visibility_test` |

## Business rules → code
| Rule (PRD 01/02/04) | Code | Tests |
|---|---|---|
| IST daily reset, Monday week | `core/time/ist.dart` | U-rules |
| 5/15 likes a day, unique per pair, duplicate taps free | `likes/domain/allowances.dart` `LikeQuota`; `DatingController.decide/likeBack` | U-rules, U-ctl |
| Match 24 h; first message stops timer; extension one per match (free weekly, Premium daily) | `matches/domain/match_lifecycle.dart`; `DatingController.extend` | U-rules, `full_app_test`, W-journeys |
| 7-day check-in, 14-day expiry, history kept, sends disabled | `matchStatus`; `ChatScreen` expired bar | U-rules, U-ctl |
| Reconnect once per episode, acceptance required, free | `canRequestReconnect`, `requestReconnect`, `respondReconnect` | U-rules, `full_app_test`, W-mvp |
| Compliment 150 chars, one per pair, credit on accepted send, refund on failure, no refund on dismiss, block hides, mutual like converts | `compliments/domain/compliment.dart`, `ComplimentsController`, `DatingController._convertRequest` | U-rules, U-ctl |
| Ledger append-only, buckets, spend order, cap 5, welcome once, weekly no rollover, idempotency | `commerce/domain/credit_ledger.dart`, `EconomyController` | U-rules, U-ctl |
| Streak day, 7-day award unique per cycle, recovery 48 h once per 7 days, no duplicate award | `streaks/domain/streak.dart` | U-rules, U-ctl |
| Health formula v1, discovery status separate, unknown ≠ restricted, low sample < 20 | `health/domain/profile_health.dart` | U-rules |
| Provisional catalog, no hard-coded prices in widgets | `commerce/domain/catalog.dart` | U-rules |
| Purchases grant only on verified success; unavailable never succeeds | `EconomyController.purchase`, `store_gateway.dart` | U-ctl |
| Server-side atomic rules, RLS, idempotency | `backend/migrations/*.sql`, `backend/functions/CONTRACTS.md` | `backend/tests/rls_cross_user.sql` (not run: no database) |

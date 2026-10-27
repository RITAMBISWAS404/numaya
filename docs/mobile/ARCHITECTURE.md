# Architecture

Feature-first, with three layers inside each feature. UI never talks to a data source directly.

```
presentation  (screens, widgets)        reads view models, renders, sends intents
     │
application   (Notifier view models)    screen state, validation flow, calls repositories
     │
domain        (models, rules,           pure Dart: PhoneNumber, Country, ProfileDraft, ProfileRules,
               repository interfaces)    AuthRepository, ProfileRepository, typed failures
     │
data          (implementations)          DemoAuthRepository, UnconfiguredAuthRepository,
                                         InMemoryProfileRepository
```

## Dependency injection

Riverpod providers in `lib/app/providers.dart` are the only place implementations are chosen:

| Provider | Today | Later |
|---|---|---|
| `authRepositoryProvider` | `DemoAuthRepository` in debug/profile development builds, otherwise `UnconfiguredAuthRepository` | The real auth provider's adapter |
| `profileRepositoryProvider` | `InMemoryProfileRepository` | An API client |
| `clockProvider` | `DateTime.now` | same (tests inject a fixed time) |
| `appConfigProvider` | `AppConfig.fromEnvironment()` | same |

Tests replace any of these with `ProviderScope(overrides: …)`.

## View models

| Notifier | Screen(s) | Holds |
|---|---|---|
| `PhoneEntryController` | Phone | country, digits, intent, submitting, failure |
| `VerificationController` | Verify | request, status (entering / checking / incorrect / expired / success), resending |
| `SessionController` | all | the signed-in `AuthSession` or null; sign out; delete account |
| `OnboardingController` | Setup hub, Basics, Interests, Photos, Profile, Edit profile | `ProfileDraft`, completed steps, edit snapshot |
| `DiscoveryFiltersController` | Filters sheet, Discover | age range, distance; `broaden()` for "Widen age and distance" |
| `DatingController` | Discover, Likes, Match, Messages, Chat, Blocked people, Settings | decisions, matches, last pass (undo), handled likes, threads and message status, opened matches, ended (unmatched / blocked / reported), reports, snooze, simulated errors |
| `AccountPrefsController` | Settings, notifications | channels per category, snooze |
| `PremiumController` | Premium, paywall, filters, settings | simulated plan state |
| `PhotoVerificationController` | Verification | simulated review |
| `ProfileDetailsController` | Edit profile, hub, preview, Opening Moves | profile details |

Rules live in the domain (`ProfileRules`, `ProfileDraft.basicsComplete`, `Country.formatNational` …), so screens and
tests share one definition.

## Navigation

`go_router` (`lib/app/router.dart`), one table of paths in `lib/app/routes.dart`.

- **Guard:** signed out → anything under setup, home, likes, messages or profile redirects to Welcome. Verify without a
  pending request redirects to Phone. Signed in → Welcome and Phone redirect to Home or the setup hub (except while the
  verify screen shows its success state and hands over itself).
- **Stack:** Welcome → Phone → Verify are pushed (back works, "Change number" pops with the number kept). Verification
  replaces the stack with the setup hub, so back can't return to the code. Setup steps are pushed from the hub.
  Finishing photos replaces the stack with Home.
- **Shell:** `StatefulShellRoute.indexedStack` with four tabs, each keeping its own state.
- **Full-app routes** (outside the shell): `/for-you`, `/paywall?feature=`, `/profile/{complete,preview,opening-moves,verify,premium,safety}`,
  `/profile/settings/{notifications,privacy,delete,blocked}`, `/help`, `/help/contact`, `/help/:id`, `/restore`,
  `/account-blocked`, `/demo`.
- **Dating routes** sit above the shell (full screen, no tab bar): `/like/:id`, `/match/:id`, `/chat/:id`,
  `/person/:id`; Blocked people is `/profile/settings/blocked`. A match replaces itself with the chat when a message
  is sent; a chat always returns to Messages (its back button and Android back), where the conversation lives.
- The router re-runs its redirect whenever the session changes (sign out and delete land on Welcome).

## Configuration and environments

`--dart-define=NUMAYA_ENV=development|production` (default development), read at compile time in `AppConfig`.

`AppConfig.demoAuthAllowed = !kReleaseMode && NUMAYA_ENV != 'production'`. Both parts are compile-time constants, so in
a release build the demo branch is dead code and the compiler drops `DemoAuthRepository` from the binary. The demo
service can't be turned on at runtime.

## Logging

`AppLogger` (`lib/core/logging/app_logger.dart`):
- logs events and error **types** only, never messages that may carry input;
- runs every line through `redact()`, which masks digit runs (numbers, codes) as a safety net;
- keeps warnings and errors only in release builds;
- `PhoneNumber.toString()` and `ProfileDraft.toString()` print no personal data, so accidental interpolation is safe.

Verification codes are never logged. The demo service delivers its code to an in-app banner only.

## Data at rest

Nothing personal is written to disk. Session, profile draft, filters and the dating demo (matches, messages, reports,
blocks) live in memory for the app session; closing the app or signing out clears them (`SessionController` also
resets `datingProvider` and the filters). When a backend exists, the auth provider's refresh token goes in the platform keystore
(`flutter_secure_storage`, Keychain / Android Keystore), never in `SharedPreferences`. See
[PRODUCTION_READINESS.md](PRODUCTION_READINESS.md).

## Errors

Repositories throw a sealed `AuthFailure` (`InvalidPhoneNumber`, `IncorrectCode`, `CodeExpired`, `ResendTooSoon`,
`AuthNetworkFailure`, `AuthUnavailable`). `authFailureMessage()` maps each to fixed copy, so no server text reaches a
screen. Unexpected exceptions become `AuthNetworkFailure` and are logged by type. `main.dart` routes uncaught Flutter
and zone errors to the logger.

## Localisation

`flutter gen-l10n` from `lib/l10n/app_en.arb` (707 strings, ICU plurals). Screens read `context.l10n`. Interest and
prompt names are product content kept in the domain for now; they move to the backend or ARB when translation starts.

## Demo data and simulated services (no backend)

Everything after sign-in runs on local, deterministic sample data so every screen can be explored, without
pretending anything happened on a server.

| Piece | File | What it holds |
|---|---|---|
| Sample people | `features/dating/domain/sample_people.dart` | 7 base profiles, 5 extra (`kExtraPeople`), 7 seeded matches (`kSeedMatchPeople`) with sample conversations (`kSeedMatches`), likes, report and unmatch reasons. Initials instead of photos |
| Sample world | `DemoWorldController` (`dating_controller.dart`) | `full` (default in demo builds: larger deck, queue with one match expiring and one expired, 3 sample conversations) or `fresh` (a brand-new account). Tests choose explicitly |
| Dating | `DatingController` | Decisions, matches with `matchedAt`, 24 h expiry, Extend (one free a day) and Rematch, threads with unread and "your move", SuperSwipe credits, For you picks, fallback filtering, Did you meet?, reports with the part, unmatch reasons, blocks, snooze flag, simulated errors |
| Filters | `DiscoveryFiltersController` | Basic (who, age, distance, verified only) and advanced (height, intentions, More-about-you sets), each with an "if I run out" fallback |
| Premium | `PremiumController` | Simulated plans (illustrative prices), purchase success or simulated failure, active until, Incognito, Travel city, extra SuperSwipes. No store, no payment |
| Photo verification | `PhotoVerificationController` | Not started → pending (2 s) → verified or declined (outcome chosen in the Demo hub), attempts and poses. No camera |
| Profile details | `ProfileDetailsController` | Bio, About you, height, More about you, languages, extra prompts, Opening Moves, gender detail and visibility switches |
| Account preferences | `AccountPrefsController` | Notification channels per category, snooze length / start / away status |
| Help content | `features/help/domain/help_articles.dart` | Original Numaya articles |

Honesty rules, enforced in the UI and covered by tests:

- Sample profiles carry a "Sample profile" badge; seeded conversations a "Sample conversation" tag and a note that
  the other side's messages were written for the demo.
- The member's messages go `sending` → `onDevice` and say "Demo · saved on this device, not sent". **No reply is
  ever generated** to something the member writes.
- Reports, appeals, support messages and Did you meet? answers are kept on the device, and the screens say nothing
  is sent or reviewed. Purchases say no payment is taken; verification says no camera or review is used.
- Logs carry only kinds of events (decision, ending, demo purchase), never names or text.

**Demo hub** (`features/demo/presentation/demo_hub_screen.dart`, route `/demo`): quick start (a sample account on a
fictional 555 number via `DemoAuthRepository.quickStart`), world switch, reset (`SessionController.resetDemoData`),
switches and links to every screen. The router refuses `/demo` when `demoAuthProvider` is null, i.e. in release
builds, and the Welcome badge that opens it only exists in demo builds.

**Account restore:** `DemoAuthRepository` keeps deleted accounts for 28 days; verifying the same number returns a
session with `restorableUntil`, the router holds it on `/restore` until the member restores or starts over.

**Direct-route recovery:** unknown paths show `NotFoundScreen` (`errorBuilder`), and deep links to missing people
or help articles show an empty state instead of failing.

When a backend exists, these controllers are the seams: swap the sample lists for repository calls behind
providers, as auth and profile already do.

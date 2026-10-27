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
| `NotificationPrefsController` | Settings | new messages, new likes (session only) |

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

`flutter gen-l10n` from `lib/l10n/app_en.arb` (328 strings, ICU plurals). Screens read `context.l10n`. Interest and
prompt names are product content kept in the domain for now; they move to the backend or ARB when translation starts.

## Dating demo (sample data, no backend)

The dating loop runs on local sample data so the journeys can be tried end to end, without pretending anything
happened on a server:

- `features/dating/domain/sample_people.dart`: seven sample people (`kSamplePeople`) and five sample likes, with
  initials instead of photos. No real people, no stock photos, no personal data.
- `DatingController` (in memory, deterministic): liking someone who already liked you is a match; nobody else matches;
  messages go `sending` → `onDevice` after 400 ms and stay on the device; **no replies are ever generated**; reports are
  stored locally and the UI says nothing is sent or reviewed; unblocking never restores a match.
- Every surface says it is a sample: the "Sample profile" badge, footnotes on Discover, Likes, Match and Chat, and the
  message status "Demo · saved on this device, not sent".
- "Simulate connection problems" (Settings › Prototype tools) makes Discover fail to load and sends fail, so the
  error and retry states can be seen. It is shown only when the demo sign-in exists (`demoAuthProvider` is not
  null, i.e. `AppConfig.demoAuthAllowed`), never in release builds.
- The controller logs only decision and ending kinds (never names or text).

When a backend exists, `DatingController`'s methods are the seams: swap the sample lists for repository calls behind
providers, as auth and profile already do.

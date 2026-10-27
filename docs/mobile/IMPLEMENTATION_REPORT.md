# Implementation report

## Full app coverage (branch `experiment/numaya-flutter-full-app`)

Based on `experiment/numaya-flutter-v16-complete` at `37a8007` (unchanged). V16 remains the visual direction;
Bumble (research + Mobbin) informs structure and interactions only.

**Coverage:** [FULL_APP_SCREEN_INVENTORY.md](FULL_APP_SCREEN_INVENTORY.md) maps the 69 reference screen rows
(B-01–B-77) and 29 flows: **51 done, 4 partial, 9 deferred, 5 out of scope**; 27 of 29 flows implemented, 2 out of
scope; 10 Numaya-only screens added. Mobbin flows inspected: Discover, Filtering people (2), Chats, Sending a
chat, Adding an opening move, Settings (2), Activating snooze mode, Completing a profile, Editing my profile,
Verifying a photo / my profile, Unmatching a user, Pay plan.

**Built in this pass (all simulated, labelled, local):** a full demo world (12 profiles, 7 likes, 7 seeded matches
with expiry, 3 sample conversations); For you picks; Basic / Advanced filters with fallbacks and verified-only;
match queue with countdown rings, Extend and Rematch; unread and Your move; Opening Moves; Did you meet?; unmatch
reasons; report "where"; completion ring and hub; Edit profile with bio, About you, More about you, languages,
prompts 2–3, photo reorder / replace; profile preview; photo verification; Premium overview, paywall, simulated
purchase and failure; Incognito, Travel; snooze length and away status; notification categories; profile
visibility; help centre, articles, contact; safety and wellbeing; log out confirmation; delete with reasons;
account restore within 28 days; account on hold with appeal; not-found recovery; the development-only Demo hub
with quick start, worlds, reset and switches. See [ARCHITECTURE.md](ARCHITECTURE.md) for the honesty rules.

**Checks (real results):**

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | clean |
| `flutter analyze` | No issues found |
| `flutter test` | **115 passed**, 2 skipped (opt-in capture tests) |
| — unit (69) | + 18 for the full app: seeding, unread, expiry / Extend / Rematch, SuperSwipe credits, filters and fallbacks, For you, simulated purchase, Incognito / Travel, verification, completion, limits, snooze, notification channels |
| — widget (46) | + 11 journeys (Demo hub and worlds, not-found recovery, tabs and For you, sample conversation, expiry and paywall purchase, filters, profile editing and preview, verification, Did you meet? and report, log out, delete and restore) and 2 accessibility tests over 24 full-app routes |
| Capture tests (`--tags screenshots --run-skipped`) | 4 passed: 24 + 20 + 7 + 41 renders |
| `flutter test integration_test` | **Not run**: needs a phone or emulator |
| `flutter build apk --debug` | **Not run: blocked** (no Android SDK; `dl.google.com` refused by the network policy) |

---

## Product audit and completion (branch `experiment/numaya-flutter-v16-complete`)

Based on `experiment/numaya-flutter-v16` at `b99edb4` (unchanged). V16 stays the visual direction.

**Audit:** [SCREEN_INVENTORY.md](SCREEN_INVENTORY.md) lists 55 screens or state groups with requirement, route,
reference, before/after, tests and next action, and the 7 conflicts between sources with how each was resolved.
Before this branch the onboarding was complete, but the dating loop was empty cards: no profiles, likes, matches,
chat or safety actions.

**Built (on labelled sample data, in memory, deterministic):** Discover (profile card, sections, like / pass /
SuperSwipe buttons and swipe, one-step undo, report or block from the card, filters with a live count, "no one fits"
→ widen, "seen everyone" → show again, paused, load error with retry); Likes (grid, All / New / Nearby with counts,
empty states, like-back profile); match screen (V16 organic frame, shared interests, composer, keep browsing);
Messages (new-match queue, search, conversation filters, empty states); chat (openers, bubbles, "Demo · saved on this
device, not sent", failed → retry / delete, unmatch / block / report with consequences and result screens); another
person's profile; Settings (snooze, blocked people with unblock, prototype tool to simulate connection problems);
tab badges; photo options (make main, remove, keep at least 2 when editing); tap outside to dismiss the keyboard.
Nothing is sent anywhere, no replies are generated, and every surface says it is a sample
([ARCHITECTURE.md](ARCHITECTURE.md), "Dating demo").

**Visual QA:** 27 new Flutter renders compared with the V16 captures; 11 visual defects and 4 accessibility defects
fixed ([VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md)).

**Checks on this branch (real results):**

| Check | Result |
|---|---|
| `dart format lib test integration_test` | 0 files changed |
| `flutter analyze` | No issues found |
| `flutter test` | **84 passed**, 1 skipped (the opt-in capture test) |
| — unit (51) | dating controller (16: matching, undo, filters and hidden count, likes filters, like back, message on device / failed / retry / delete, unmatch, report with and without block, unblock, snooze), make main photo, plus the earlier auth, rules, tokens and contrast tests |
| — widget (33) | 12 dating journeys, 4 onboarding edge cases (under 18 corrected, back keeps answers, Android back, keyboard dismissal), 2 photo options, 4 accessibility (tap targets and labels on every onboarding and dating screen; 375 × 667 at 130% text), and the earlier onboarding and V16 screen tests |
| Capture tests (`--tags screenshots --run-skipped`) | 3 passed: 24 + 20 + 7 renders |
| `node tool/generate_tokens.mjs --check` | Up to date |
| `flutter test integration_test` | **Not run**: needs a phone or emulator |
| `flutter build apk --debug` | **Not run: blocked.** No Android SDK; `dl.google.com` returns 403 at this environment's proxy |

The app has **not** been run on a phone or emulator. Android config checked: application id
`com.numaya.numaya_mobile`, label "Numaya", no permissions in the main manifest (debug and profile builds add
INTERNET for hot reload, the Flutter default; the app itself uses no network, camera or storage), Hanken Grotesk
and illustrations declared in `pubspec.yaml`, release builds still signed with the debug key (see
[BUILD_AND_RELEASE.md](BUILD_AND_RELEASE.md)).

---

## V16 visual correction (branch `experiment/numaya-flutter-v16`)

The foundation (`75f63e7`, branch `experiment/numaya-flutter-foundation`, unchanged) used the default purple
design. This branch re-implements the visual layer as **Numaya V16** while keeping the architecture, routing, view
models, validation, demo auth and tests.

**V16 sources inspected:** `src/design-system/styles/theme-withings.css` (all 1,063 lines),
`src/flows/theme-withings.css`, the inherited V11 rules in `theme-tiimo.css` and `src/prototype/styles/screens.css`
(welcome stickers, emoji chips, set marks), `src/flows/data.js` (interest emoji and tones), `src/design-system/tokens.js`
(the 89 `withings` tokens), `artifacts/version-16-design-experiment/README.md`, `design-system/TOKENS.md`,
`design-system/COMPONENT_RULES.md`, `final-polish/PASS_2_COMPONENT_GEOMETRY.md`, and the final captures in
`final-polish/screenshots/states/` (001 welcome, 013/015 basics, 016/017 interests, 018 photos, 019/023/024 discover
and filters, 037 messages empty, 054/058 likes, 099/100 profile, 102 edit profile, 108 prompt editor, 111/112
settings, 130 delete sheet).

**Changed:** font (Hanken Grotesk replaces Fraunces + Inter); token generator now exports V16 tokens; every
foundation (`AppColors`, `AppTypography`, `AppRadii`, `AppSizes`, `AppElevation`, `AppTheme`) and every shared
component; illustrations re-exported in V16 colours; screens: Welcome (emoji sticker hero), Phone, Country sheet,
Verify, Setup hub, Basics, Interests, Photos, a new full-screen Prompt editor (was a sheet), Home, Likes, Messages,
Filters, Profile (rebuilt to V16's layout), Edit profile (photo grid in place, prompt card, rows), Settings (white
action blocks, delete confirmation sheet). See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) and
[VISUAL_COMPARISON.md](VISUAL_COMPARISON.md).

**Checks on this branch:** `dart format` clean · `flutter analyze` no issues · `flutter test` **45 passed**, 1
opt-in screenshot test (passes when run) · 24 screenshots captured and compared with the V16 web captures ·
`generate_tokens.mjs --check` up to date. Not run: `flutter test integration_test` (needs a device) and
`flutter build apk` (no Android SDK; `dl.google.com` is blocked in this environment).

---


Branch `experiment/numaya-flutter-foundation`, app in `apps/numaya_mobile/`. Not merged, not deployed, nothing
published to any store.

## What was built

- **Native Flutter app** (Dart, no WebView) for Android and iOS, feature-first with presentation / application /
  domain / data layers, Riverpod view models and go_router navigation ([ARCHITECTURE.md](ARCHITECTURE.md)).
- **Design system port** of the approved Numaya design: 191 tokens generated from `tokens/numaya.tokens.json`, the
  web's 67 icons and 9 illustrations exported, Fraunces and Inter bundled (OFL), 25+ components with their states
  ([DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)).
- **Complete onboarding:** Welcome, Phone with country sheet, Verify, no-account sheet, Setup hub, Basics,
  Interests + prompt editor, Photos, with validation, back navigation, loading, error and success states
  ([ONBOARDING_FLOW.md](ONBOARDING_FLOW.md)).
- **App shell** within scope: Home / Likes / Messages / Profile tabs, Filters, Profile, Edit profile, Settings (sign
  out, delete account). No dead buttons; no mock people.
- **Demo auth** for development builds only, compiled out of release builds; no codes logged; no personal data on disk.
- **Localisation** (ARB, ≈180 strings), redacting logger, error handling.
- **Docs:** this folder, plus a beginner Windows guide and PowerShell helper.

## Checks run in this environment (real results)

| Check | Result |
|---|---|
| `flutter pub get` | OK |
| `dart format` | Applied; clean |
| `flutter analyze` (flutter_lints + stricter rules, strict casts and raw types) | **No issues found** |
| `flutter test` | **41 passed**, 1 skipped (the opt-in screenshot test) |
| — unit | country formatting, phone rules, profile rules, onboarding controller, demo auth (wrong code, expiry, resend cooldown, returning member, deletion), tokens and contrast, logger redaction |
| — widget | welcome; phone validation; country change trims digits; unusable number error; full sign-up from Welcome to Profile including wrong code, underage error and prompt; change number keeps the number; sign-in with an unknown number |
| Screenshot capture (19 states) | OK, see [VISUAL_COMPARISON.md](VISUAL_COMPARISON.md) |
| `node tool/generate_tokens.mjs --check` | Up to date |
| `flutter test integration_test` | **Not run**: needs a phone or emulator |
| `flutter build apk --debug` | **Not run: blocked.** No Android SDK. The SDK is downloaded from `dl.google.com`, which this cloud environment's network policy refuses (HTTP 403 at the proxy). `flutter doctor -v`: "✗ Unable to locate Android SDK". |

The build was not faked or simulated. Follow [GETTING_STARTED_WINDOWS.md](GETTING_STARTED_WINDOWS.md) to build and run
on a phone; the project has no native plugins, so a standard Android Studio install is all it needs.

## Problems found and fixed during the work

| Problem | Fix |
|---|---|
| Verify screen skipped straight to the hub: the router's signed-in redirect also ran for the Welcome route underneath | Redirect waits while Verify shows success and hands over itself |
| `+971` overflowed the 120 pt country selector | Dial code scales down |
| Pending caret animation and countdown kept frames scheduled forever | Caret runs only while visible; countdown stops at zero |
| Photo tiles didn't match the web | Plain photo grey, no icon; any empty slot adds |
| Deleted demo account still counted as a returning member | `AuthRepository.deleteAccount` |
| Next button could re-submit a rejected code | Enabled only while entering |

## Not done (and why)

See [PRODUCTION_READINESS.md](PRODUCTION_READINESS.md): real auth, backend, photo upload, matching/chat/safety,
release signing, store listings, iOS build, device QA. Match, chat and Activity screens were not built because without
a backend they would be unreachable or fake.

## How to try it

```powershell
cd apps\numaya_mobile
flutter pub get
flutter run          # phone connected, USB debugging on
```
Sign up with any real-looking number; the code appears in the "Demo text message" banner.

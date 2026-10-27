# Implementation report

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

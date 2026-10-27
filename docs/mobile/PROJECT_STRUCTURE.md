# Project structure

```
apps/numaya_mobile/
├── lib/
│   ├── main.dart                         entry: error handlers, ProviderScope
│   ├── app/
│   │   ├── app.dart                      MaterialApp.router, theme, localisations
│   │   ├── providers.dart                dependency injection (the one place implementations are chosen)
│   │   ├── router.dart                   go_router table and redirect guard
│   │   └── routes.dart                   path constants
│   ├── core/
│   │   ├── config/app_config.dart        environment + compile-time demo guard
│   │   ├── logging/app_logger.dart       redacting logger
│   │   └── design_system/
│   │       ├── design_system.dart        the only import screens use for UI
│   │       ├── tokens/numaya_tokens.g.dart   GENERATED from tokens/numaya.tokens.json
│   │       ├── icons/numaya_icon_data.g.dart GENERATED from the web icon set
│   │       ├── foundations/              AppColors, AppTypography, AppSpacing/AppRadii/AppSizes/
│   │       │                             AppElevation (app_layout.dart), AppMotion, AppTheme
│   │       └── widgets/                  buttons, fields, selection, content, layout, navigation, toast,
│   │                                     people (avatars, badges, composer, bubbles, action sheet, tabs, tiles)
│   ├── features/
│   │   ├── auth/        domain (Country, PhoneNumber, AuthRepository) · data (demo, unconfigured) ·
│   │   │                application (phone entry, verification, session) · presentation (welcome,
│   │   │                phone, country sheet, verify)
│   │   ├── onboarding/  domain (ProfileDraft, rules, ProfileRepository) · data (in-memory) ·
│   │   │                application (OnboardingController) · presentation (setup hub, basics,
│   │   │                interests, prompt editor screen, photos, photo options, edit guard)
│   │   ├── dating/      domain (sample people, worlds, seeded matches) · application (DatingController,
│   │   │                DemoWorldController) · presentation (+ For you, time format) ·
│   │   │                presentation (Discover, Likes and like profile, Match, Messages and Chat, person
│   │   │                profile sections, unmatch/block/report sheets)
│   │   ├── home/        application (filters) · presentation (tab shell with badges, TabPage, Filters sheet)
│   │   ├── profile/     domain (ProfileDetails, completion) · application (details) · presentation (Profile,
│   │   │                Edit profile, editors, completion hub, preview, Opening Moves)
│   │   ├── premium/     application (simulated plans) · presentation (Premium, paywall)
│   │   ├── verification/ application (simulated review) · presentation (photo verification)
│   │   ├── help/        domain (articles) · presentation (help centre, article, contact, safety)
│   │   ├── demo/        presentation (Demo hub, development only)
│   │   └── settings/    application (account prefs) · presentation (Settings, notifications, visibility,
│   │                    delete, restore, account on hold, Blocked people)
│   └── l10n/            app_en.arb, generated/ (gen-l10n output), l10n.dart (context.l10n)
├── assets/
│   ├── fonts/           HankenGrotesk-Variable.ttf (V16's one family), OFL licence
│   └── illustrations/   9 SVGs exported from the web in V16 colours
├── test/
│   ├── unit/            domain rules, demo auth, tokens, logger, controllers
│   ├── widget/          onboarding flows and edge cases, dating journeys, photo options, accessibility
│   │                    (tap targets, labels, 375 × 667 at 130% text) through the real app
│   ├── screenshots/     opt-in screenshot capture (goldens/ holds the PNGs)
│   └── helpers/         test app with deterministic clock and auth; shared sign-up journeys
├── integration_test/    on-device sign-up test
├── tool/
│   ├── generate_tokens.mjs   web tokens → Dart
│   ├── export_assets.mjs     web icons and illustrations → Dart/SVG
│   ├── convert_fonts.py      Fontsource woff2 → TTF
│   └── windows/run-on-phone.ps1  beginner helper for Windows
├── android/ ios/        platform projects (app name "Numaya", id com.numaya.numaya_mobile)
├── l10n.yaml  analysis_options.yaml  dart_test.yaml  pubspec.yaml
```

Rules: screens import UI only from `core/design_system/design_system.dart`; generated files (`*.g.dart`,
`l10n/generated/`) are never edited by hand.

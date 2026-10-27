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
│   │       └── widgets/                  buttons, fields, selection, content, layout, navigation, toast
│   ├── features/
│   │   ├── auth/        domain (Country, PhoneNumber, AuthRepository) · data (demo, unconfigured) ·
│   │   │                application (phone entry, verification, session) · presentation (welcome,
│   │   │                phone, country sheet, verify)
│   │   ├── onboarding/  domain (ProfileDraft, rules, ProfileRepository) · data (in-memory) ·
│   │   │                application (OnboardingController) · presentation (setup hub, basics,
│   │   │                interests + prompt editor, photos, edit guard)
│   │   ├── home/        application (filters) · presentation (tab shell, Home, Likes, Messages, Filters)
│   │   ├── profile/     presentation (Profile, Edit profile)
│   │   └── settings/    presentation (Settings)
│   └── l10n/            app_en.arb, generated/ (gen-l10n output), l10n.dart (context.l10n)
├── assets/
│   ├── fonts/           Fraunces-Variable.ttf, Inter-Variable.ttf, OFL licences
│   └── illustrations/   9 SVGs exported from the web
├── test/
│   ├── unit/            domain rules, demo auth, tokens, logger, controllers
│   ├── widget/          onboarding flows through the real app
│   ├── screenshots/     opt-in screenshot capture (goldens/ holds the PNGs)
│   └── helpers/         test app with deterministic clock and auth
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

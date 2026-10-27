# Numaya mobile (Flutter)

Native Android and iOS app for Numaya: the complete onboarding flow in the approved Numaya design, on a layered
architecture ready for a real backend. **Not production-ready**: sign-in is a demo in development builds and absent in
release builds until an auth provider is chosen.

```bash
flutter pub get
flutter run                  # development build, demo sign-in (code shown in-app)
flutter analyze && flutter test
```

New to Flutter on Windows? Start with [docs/mobile/GETTING_STARTED_WINDOWS.md](../../docs/mobile/GETTING_STARTED_WINDOWS.md).

| Doc | |
|---|---|
| [Implementation report](../../docs/mobile/IMPLEMENTATION_REPORT.md) | What was built, checks and results |
| [Architecture](../../docs/mobile/ARCHITECTURE.md) · [Tech stack](../../docs/mobile/TECH_STACK.md) · [Project structure](../../docs/mobile/PROJECT_STRUCTURE.md) | How it's built |
| [Design system](../../docs/mobile/DESIGN_SYSTEM.md) · [Visual comparison](../../docs/mobile/VISUAL_COMPARISON.md) | Tokens, components, fidelity |
| [Onboarding flow](../../docs/mobile/ONBOARDING_FLOW.md) | Screens, rules, states |
| [Build and release](../../docs/mobile/BUILD_AND_RELEASE.md) · [Production readiness](../../docs/mobile/PRODUCTION_READINESS.md) | Shipping |
| [Repository audit](../../docs/mobile/REPOSITORY_AUDIT.md) | Starting point and decisions |

Design changes start in `tokens/numaya.tokens.json` at the repo root, then
`npm run tokens && node apps/numaya_mobile/tool/generate_tokens.mjs`. Never edit `*.g.dart` or `lib/l10n/generated/`.

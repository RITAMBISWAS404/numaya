# Tech stack

| Concern | Choice | Version | Why |
|---|---|---|---|
| Framework | Flutter (native rendering, no WebView) | 3.47.8 stable, Dart 3.13.7 | One codebase for Android and iOS, pixel control needed to match the approved design |
| State, DI | `flutter_riverpod` | ^3.4.3 | Notifier view models, compile-safe providers, easy overrides in tests |
| Routing | `go_router` | ^18.1.1 | Declarative routes, redirect guard, tab shell with preserved stacks |
| Vector art | `flutter_svg` | ^2.3.0 | Draws the web's icon paths and illustrations exactly |
| Localisation | `flutter_localizations`, `intl`, `gen-l10n` | SDK, ^0.20.2 | Official, type-safe strings |
| Tests | `flutter_test`, `integration_test` | SDK | Unit, widget and on-device tests |
| Lints | `flutter_lints` + stricter rules | ^6.0.0 | See `analysis_options.yaml` |

**No plugins with native code** are used yet. The Android build needs only Flutter's own Gradle setup.

## Rejected or deferred

| Option | Decision |
|---|---|
| WebView wrapper of the web prototype | Rejected (brief, and it would not feel native) |
| `bloc` | Viable; Riverpod chosen for less boilerplate in a small team |
| `google_fonts` package | Rejected: downloads at runtime. Fonts are bundled. |
| Material icon font | Rejected: the web uses Material Symbols Rounded weight 500; the exact paths are exported instead |
| `shared_preferences` for session or profile | Rejected: no personal data in plain storage |
| `flutter_secure_storage` | Deferred until a real auth provider issues tokens |
| `image_picker`, crop | Deferred until photo upload and moderation exist |
| Firebase Auth / Supabase / Twilio Verify | Not chosen: a product and legal decision (see PRODUCTION_READINESS.md) |

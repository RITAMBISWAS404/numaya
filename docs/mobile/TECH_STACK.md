# Tech stack

| Concern | Choice | Version | Why |
|---|---|---|---|
| Framework | Flutter (native rendering, no WebView) | 3.47.8 stable, Dart 3.13.7 | One codebase for Android and iOS, pixel control needed to match the approved design |
| State, DI | `flutter_riverpod` | ^3.4.3 | Notifier view models, compile-safe providers, easy overrides in tests |
| Routing | `go_router` | ^18.1.1 | Declarative routes, redirect guard, tab shell with preserved stacks |
| Vector art | `flutter_svg` | ^2.3.0 | Draws the web's icon paths and illustrations exactly |
| Localisation | `flutter_localizations`, `intl`, `gen-l10n` | SDK, ^0.20.2 | Official, type-safe strings |
| Photo and video picking | `image_picker` (flutter.dev) | ^1.2.4 | Android's Photo Picker and camera intent for chat attachments and profile photos; no storage permission, no network or telemetry in its tree. Behind `MediaPicker` (`lib/features/dating/data/media_picker.dart`) |
| Tests | `flutter_test`, `integration_test` | SDK | Unit, widget and on-device tests |
| Lints | `flutter_lints` + stricter rules | ^6.0.0 | See `analysis_options.yaml` |

**One plugin with native code:** `image_picker` (added in the overnight pass). Its Android build could not be checked in the cloud environment (the Android SDK host is blocked), so the first local `flutter build apk` is its first build. It needs no manifest permission: the gallery uses the Photo Picker, and the camera uses the system camera app.

## Rejected or deferred

| Option | Decision |
|---|---|
| WebView wrapper of the web prototype | Rejected (brief, and it would not feel native) |
| `bloc` | Viable; Riverpod chosen for less boilerplate in a small team |
| `google_fonts` package | Rejected: downloads at runtime. Fonts are bundled. |
| Material icon font | Adopted in the UI refinement (RD-04): the shared icon names render with Flutter's bundled Material Icons |
| `shared_preferences` for session or profile | Rejected: no personal data in plain storage |
| `flutter_secure_storage` | Deferred until a real auth provider issues tokens |
| `image_picker` | **Adopted** for local picking only; nothing is uploaded |
| Crop | Deferred until photo upload and moderation exist |
| `video_player`, audio recording (`record`) and playback plugins | Deferred: more native plugins whose builds can't be verified here; videos show as file cards and voice notes are a labelled demo |
| Firebase Auth / Supabase / Twilio Verify | Not chosen: a product and legal decision (see PRODUCTION_READINESS.md) |

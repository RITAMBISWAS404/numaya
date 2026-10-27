# Build and release

## Commands (run in `apps/numaya_mobile`)

| Goal | Command |
|---|---|
| Install packages | `flutter pub get` |
| Format | `dart format lib test integration_test` |
| Static analysis | `flutter analyze` |
| Unit + widget tests | `flutter test` |
| On-device test | `flutter test integration_test` |
| Screenshots | `flutter test --tags screenshots --run-skipped --update-goldens` (writes `test/screenshots/goldens/`) |
| Regenerate tokens | `node tool/generate_tokens.mjs` (from repo root: `node apps/numaya_mobile/tool/generate_tokens.mjs`) |
| Check tokens are current | `node apps/numaya_mobile/tool/generate_tokens.mjs --check` |
| Regenerate icons / illustrations | `node apps/numaya_mobile/tool/export_assets.mjs` |
| Regenerate strings | `flutter gen-l10n` (also runs on `pub get` / build) |
| Run, development | `flutter run` |
| Debug APK | `flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk` |
| Production-mode build | `flutter build appbundle --release --dart-define=NUMAYA_ENV=production` |

## Environments

| Build | `NUMAYA_ENV` | Mode | Sign-in |
|---|---|---|---|
| Development | `development` (default) | debug / profile | Demo service, banner shows the code |
| Development release | `development` | release | **None** ("Sign-in isn't available in this build") |
| Production | `production` | release | None until a real provider is integrated |

Demo sign-in is compiled out of every release build (see ARCHITECTURE.md).

## Before any store release (not done, by design)

1. **Application id.** `com.numaya.numaya_mobile` (Android) and the iOS bundle id are placeholders from
   `flutter create`. Pick the final reverse-domain id the company owns **before the first upload**; it can't change
   afterwards.
2. **Signing.** `android/app/build.gradle.kts` still signs release builds with the debug key (Flutter's template).
   Create an upload keystore on a trusted machine, keep it and its passwords out of git (already ignored:
   `key.properties`, `*.jks`, `*.keystore`), enable Play App Signing, and load the key through `key.properties` or CI
   secrets. No keystore was created here.
3. **Real authentication** and backend (PRODUCTION_READINESS.md).
4. **App icon and splash** (`flutter_launcher_icons`, `flutter_native_splash`) from the final logo; the template icon
   is still in place.
5. **Version:** bump `version:` in `pubspec.yaml` (`0.1.0+1` now; the `+N` build number must grow every upload).
6. **Privacy:** store data-safety forms, privacy policy URL, account deletion URL (Play requires one).
7. **iOS:** needs a Mac with Xcode, an Apple Developer account, and `pod install`. Not attempted.

Nothing was published to Google Play or the App Store.

## CI suggestion

```yaml
- run: flutter pub get
- run: dart format --output=none --set-exit-if-changed lib test integration_test
- run: flutter analyze
- run: flutter test
- run: node apps/numaya_mobile/tool/generate_tokens.mjs --check   # needs `npm ci` at repo root
- run: flutter build apk --debug
```

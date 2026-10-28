# Android compatibility

Why an APK can install on the Pixel emulator (Android 16) and be refused as "App not compatible" on a
Samsung phone running Android 12 (API 31), what the repository allows, and how to check a real APK.

This was diagnosed from the repository at `dc22646` (branch `experiment/numaya-quality-motion`), in a cloud
environment with **no Android SDK**: `dl.google.com` is refused there. No APK was built or opened there.
Everything said below about a specific APK file must be confirmed with the commands in this document.

## What the repository configures

| Setting | Where | Value |
|---|---|---|
| `minSdk` | `android/app/build.gradle.kts` → `flutter.minSdkVersion` | **24** (Android 7.0), the Flutter 3.47.8 default in `flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt` |
| `targetSdk` / `compileSdk` | `flutter.targetSdkVersion` / `flutter.compileSdkVersion` | 36 / 36 |
| `maxSdkVersion` | — | none |
| ABI filters, `splits { abi }`, `ndk { abiFilters }` | — | none |
| `<uses-feature>`, `<supports-screens>`, `<compatible-screens>` | the three manifests | none |
| Android 12 requirement: `android:exported` on activities with intent filters | `src/main/AndroidManifest.xml` | present (`MainActivity`, `exported="true"`) |
| Plugins with Android code | `pubspec.yaml` | none. `flutter_riverpod`, `go_router`, `flutter_svg` and `intl` are pure Dart. `integration_test` is a dev dependency and not packaged |

**Finding:** nothing in the source excludes API 31. `minSdk` 24 is below 31, there is no maximum, no
dependency raises the minimum, and nothing restricts architecture or hardware features. A target SDK of 36
does not stop installation on older Android: the target only changes runtime behaviour.

## Most likely cause: an APK holding only the emulator's architecture

Flutter writes **two different kinds of APK to the same file**,
`build\app\outputs\flutter-apk\app-debug.apk`:

| Command | Native libraries in the APK | Source |
|---|---|---|
| `flutter build apk --debug` | `armeabi-v7a`, `arm64-v8a`, `x86_64` (universal) | `flutter_tools/lib/src/commands/build_apk.dart`, `_kDefaultJitArchs` |
| `flutter run` on a device, and Android Studio's Run button | **only the device's architecture** | `flutter_tools/lib/src/android/android_device.dart`: `targetArchs: <AndroidArch>[androidArch]` |

A Pixel emulator on a Windows PC normally runs an x86_64 system image. If the copied `app-debug.apk` was
last written by a run on that emulator, it holds only `lib/x86_64/libflutter.so`. An ARM Samsung phone then
fails it with `INSTALL_FAILED_NO_MATCHING_ABIS`, which the on-device installer shows as "App not
compatible".

This matches what you saw: it installs on the emulator and fails on the phone. It is not *proven*,
because the APK that failed is on your PC. The check is step 2 below.

## Changes made

- `tool/windows/run-on-phone.ps1 -Apk` builds the universal debug APK and then lists the APK's native
  libraries. It stops with an error if `arm64-v8a` is missing, and prints the SHA-256.
- [GETTING_STARTED_WINDOWS.md](GETTING_STARTED_WINDOWS.md) §8: build the APK immediately before copying it,
  and never copy it after `flutter run`.
- **No Gradle, manifest or Dart change.** The configuration already supports Android 12. Pinning `minSdk`
  or adding `abiFilters` would not stop `flutter run` from overwriting the file.

## 1. Build a replacement APK (Windows PowerShell)

```powershell
cd <repo>
git fetch origin
git checkout experiment/numaya-android12-compat
cd apps\numaya_mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug        # no --split-per-abi, no --target-platform
```

Don't press Run in Android Studio, and don't run `flutter run`, between this build and copying the file.
Alternatively, `powershell -ExecutionPolicy Bypass -File tool\windows\run-on-phone.ps1 -Apk` builds and checks
in one go.

## 2. Inspect the APK before copying it

```powershell
$apk = "build\app\outputs\flutter-apk\app-debug.apk"
$bt  = (Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools" | Sort-Object Name | Select-Object -Last 1).FullName

# Package, SDK levels and native code
& "$bt\aapt2.exe" dump badging $apk | Select-String "^package:|sdkVersion|targetSdkVersion|native-code|testOnly|debuggable"

# Native libraries by architecture
tar -tf $apk | Select-String "^lib/"

# Signature and checksum
& "$bt\apksigner.bat" verify --print-certs $apk
Get-FileHash $apk -Algorithm SHA256
```

Expected:
- `package: name='com.numaya.numaya_mobile'`
- `sdkVersion:'24'` and `targetSdkVersion:'36'`
- `native-code: 'arm64-v8a' 'armeabi-v7a' 'x86_64'`
- `lib/arm64-v8a/libflutter.so` in the listing
- A verified "Android Debug" signer

To check the APK that already failed, run the same commands on that file. If it shows `native-code: 'x86_64'`
only, that was the cause.

## 3. Get the real error from the Samsung phone

The installer's "App not compatible" covers several different failures. `adb` prints the exact one.

1. On the phone, enable Developer options: Settings › About phone › Software information › tap **Build
   number** seven times. Then turn on Settings › Developer options › **USB debugging**.
2. Connect it by USB, unlock it, and accept the "Allow USB debugging" prompt.
3. On the PC:
   ```powershell
   adb devices                                    # the phone must say "device", not "unauthorized"
   adb -d shell getprop ro.build.version.sdk      # expect 31 for Android 12
   adb -d shell getprop ro.product.cpu.abilist    # e.g. arm64-v8a,armeabi-v7a,armeabi
   adb -d install -r <path>\app-debug.apk
   ```
4. If it fails, keep the line starting `Failure [INSTALL_...]`, plus the installer log:
   ```powershell
   adb -d logcat -d | Select-String "PackageManager|PackageInstaller|INSTALL_" | Select-Object -Last 40
   ```

| `adb install` says | Meaning | Fix |
|---|---|---|
| `INSTALL_FAILED_NO_MATCHING_ABIS` | The APK has no library for the phone's CPU | Rebuild with step 1 and check step 2 |
| `INSTALL_FAILED_OLDER_SDK` | The APK's `minSdk` is above the phone's API level | Not expected from this repo (24). Check `sdkVersion` in step 2; a different local Flutter or edited Gradle file would show here |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | A Numaya already on the phone is signed with a different key | Uninstall the old copy on the phone (this erases its local demo data), then install again |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | The phone has a newer `versionCode` | Uninstall the old copy, or raise the version in `pubspec.yaml` |
| `INSTALL_FAILED_TEST_ONLY` | The APK was produced by an IDE deploy and marked test-only | Use the step 1 build (or `adb install -r -t` for a quick test) |
| `INSTALL_PARSE_FAILED_*`, `INSTALL_FAILED_INVALID_APK` | The file is damaged or incomplete | Compare `Get-FileHash` on the PC with the copy on the phone. Transfer by USB or Drive, not a chat app that may alter files |
| `Success` | The APK is fine | Then the earlier file was a different (single-ABI) build |

To check a copy on the phone: `adb -d shell sha256sum /sdcard/Download/app-debug.apk`, then compare with the
PC hash.

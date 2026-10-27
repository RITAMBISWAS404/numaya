# Run Numaya on your Android phone (Windows, step by step)

No experience needed. Plan about an hour the first time, mostly downloads. Commands go in **PowerShell** (press
Start, type `PowerShell`, open "Windows PowerShell"). Copy each grey block, paste it with right-click, press Enter.

## 1. Install Git

1. Download from <https://git-scm.com/download/win> and run the installer. Keep every default.
2. Close and reopen PowerShell, then check:
   ```powershell
   git --version
   ```

## 2. Install Flutter

1. Open <https://docs.flutter.dev/get-started/install/windows/mobile> and download the latest **stable** Flutter zip
   for Windows (this project was built with 3.47.8; any newer stable 3.x is fine).
2. Create the folder `C:\src` and unzip so that you get `C:\src\flutter\bin\flutter.bat`.
   Don't use `C:\Program Files` (it needs admin rights).
3. Add Flutter to your PATH (paste as one block):
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\src\flutter\bin", "User")
   ```
4. Close and reopen PowerShell, then:
   ```powershell
   flutter --version
   ```

## 3. Install Android Studio (gives you the Android SDK)

1. Download from <https://developer.android.com/studio> and install with the defaults.
2. Open Android Studio. The setup wizard downloads the Android SDK: choose **Standard** and accept.
3. In Android Studio: **More Actions → SDK Manager → SDK Tools** tab, tick **Android SDK Command-line Tools
   (latest)**, click **Apply**.
4. Back in PowerShell, accept the licences (type `y` and Enter for each question):
   ```powershell
   flutter doctor --android-licenses
   ```

## 4. Check everything

```powershell
flutter doctor -v
```

You need green ticks for **Flutter** and **Android toolchain**. Chrome, Visual Studio and Linux items can stay red;
they're for other platforms.

## 5. Get the code

```powershell
cd $HOME
git clone https://github.com/RITAMBISWAS404/numaya.git
cd numaya
git checkout experiment/numaya-flutter-foundation
cd apps\numaya_mobile
flutter pub get
```

## 6. Prepare your phone

1. On the phone: **Settings → About phone**, tap **Build number** seven times until it says you're a developer
   (on Samsung: Settings → About phone → Software information → Build number).
2. **Settings → System → Developer options** (Samsung: Settings → Developer options): turn on **USB debugging**.
3. Connect the phone with a USB cable that carries data (some charge-only cables don't).
4. On the phone, a prompt "Allow USB debugging?" appears: tick **Always allow from this computer**, tap **Allow**.
5. If the phone asks what the USB connection is for, choose **File transfer**.
6. Check that Flutter sees it:
   ```powershell
   flutter devices
   ```
   Your phone's name should be listed.

## 7. Run the app

```powershell
flutter run
```

The first build takes several minutes (Gradle downloads its tools). The app opens on the phone. While it runs, press
`r` in PowerShell to reload after a code change, `q` to quit.

**Demo sign-in:** this is a development build. Enter any real-looking number (for example `415 555 0132` with United
States), tap the arrow, and the code appears in a "Demo text message" banner at the top. Tap the banner to fill it.
No real text message is sent and nothing leaves the phone.

Alternatively, the helper script does steps 5–7 checks for you:
```powershell
powershell -ExecutionPolicy Bypass -File tool\windows\run-on-phone.ps1
```

## 8. Make an installable APK (optional)

```powershell
flutter build apk --debug
```

The file is `apps\numaya_mobile\build\app\outputs\flutter-apk\app-debug.apk`. Copy it to a phone and open it to install
(the phone will ask you to allow installs from that source). A debug APK is for testing only; see
[BUILD_AND_RELEASE.md](BUILD_AND_RELEASE.md) for real releases.

## 9. Run the tests (optional)

```powershell
flutter analyze
flutter test
flutter test integration_test   # with the phone connected
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `flutter` is not recognised | Reopen PowerShell. Check that `C:\src\flutter\bin` is in PATH (step 2.3). |
| `flutter doctor` says Android licences not accepted | Run `flutter doctor --android-licenses` and answer `y` |
| `cmdline-tools component is missing` | Step 3.3 |
| `flutter devices` doesn't show the phone | Try another cable or USB port; unlock the phone; revoke and re-allow USB debugging (Developer options → Revoke USB debugging authorisations); install your phone maker's USB driver (Samsung: "Samsung Android USB Driver") |
| Phone shows "unauthorized" | Unlock it and accept the "Allow USB debugging?" prompt |
| Gradle build fails downloading | Check your internet connection or company proxy, then run `flutter clean` and `flutter run` again |
| `Execution failed for task ':app:...' Java` | Android Studio bundles Java; run `flutter doctor -v` and make sure it finds Android Studio's JDK. `flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"` points Flutter at it. |
| Build is very slow the first time | Normal. Later builds take seconds. |
| Windows Defender slows builds | Optionally exclude `C:\src\flutter` and your project folder from real-time scanning |
| Path too long errors | Keep the project near the drive root, e.g. clone into `C:\dev` instead of a deep folder |
| "App not installed" when opening the APK | Uninstall any older Numaya build first |

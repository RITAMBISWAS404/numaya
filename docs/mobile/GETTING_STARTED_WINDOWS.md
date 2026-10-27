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
git checkout experiment/numaya-quality-motion
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

**Fastest way in: the Demo hub.** On the Welcome screen, tap the small **Demo build** label (top right). Tap
**Quick start as Alex (sample account)** to skip sign-up and land on Home with a finished sample profile. The hub
lists every screen by area and has switches for Premium (simulated), connection problems and the next
verification result, plus **Reset demo data** and a choice between the **Full demo** (matches, expiring and
expired matches, sample conversations) and a **Brand-new account**. Later, it's under Profile › Settings ›
Prototype tools › Demo hub.

**Things to try** (all sample data, labelled as such; nothing is sent anywhere, nothing is charged):

1. **Home:** like and pass (buttons or swipe), undo, SuperSwipe (3 free, then the paywall), the ⋯ menu (report,
   block), **Filters** (Basic and Advanced) and **✦ For you** (today's picks).
2. **Likes:** open someone, **Like back** → match → write the first message.
3. **Messages:** the queue rings show time left (Lina has 1 hour); open her and **Extend 24 hours**. Ollie's match
   has expired: **Rematch** opens the paywall. Priya's sample conversation has 2 unread messages; your reply says
   "Demo · saved on this device, not sent", and nobody replies.
4. **Chat ⋯ menu:** View profile, Did you meet?, Unmatch (with an optional reason), Block, Report (asks where).
5. **Profile:** the ring shows completion; **Complete profile** opens the hub. **Edit profile**: photos (tap one to
   make it main, move or replace it), prompts (up to 3), bio, About you, More about you, languages, Opening Moves,
   and **Preview** (globe icon) to see it as others do. **Verify my profile** runs a simulated photo verification.
6. **Premium:** choose a plan; the confirmation sheet says no payment is taken (you can also simulate a failed
   payment).
7. **Settings:** Snooze (length and away status), Incognito and Travel (Premium), notification categories, profile
   visibility, blocked people, help centre, log out (with confirmation) and delete account (reason → confirm).
8. **Restore:** delete the account, then **I have an account** with the same number: you're offered to restore it.
9. **Motion and feel:** like and pass to see the profile leave in the decision's direction; drag the photo past
   the line and back (the phone ticks each time); match with Maya for the one-time match entrance. Settings ›
   App › **Vibration** turns every haptic off. Demo hub › **Reduce motion** shows the app as it behaves with
   Android's *Remove animations* setting (Settings › Accessibility on the phone).

Alternatively, the helper script does steps 5–7 checks for you:
```powershell
powershell -ExecutionPolicy Bypass -File tool\windows\run-on-phone.ps1
```

## 7b. No phone? Use the Android emulator

1. In Android Studio: **More Actions → Virtual Device Manager → Create device**. Pick **Pixel 7** (or any phone),
   then a system image marked **x86_64** with the newest API level, click **Download**, then **Finish**.
   (If the wizard says virtualisation is off, enable "Intel VT-x"/"AMD-V"/"SVM" in your PC's BIOS, or turn on
   "Windows Hypervisor Platform" in *Turn Windows features on or off*.)
2. In PowerShell, list and start it:
   ```powershell
   flutter emulators
   flutter emulators --launch Pixel_7_API_35   # use the id printed by the previous command
   ```
3. Wait until the Android home screen shows, then from `apps\numaya_mobile`:
   ```powershell
   flutter devices
   flutter run
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
flutter test integration_test   # with the phone or emulator connected
flutter test --tags screenshots --run-skipped --update-goldens test/screenshots   # regenerate the review renders
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

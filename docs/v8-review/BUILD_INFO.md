# Build info

- **APK:** `apk/Numaya-V8-Review-20261114-fe44b27-debug.apk`
- **SHA-256:** `4391d664f718a550e8470d5ed05d09dea7551e392438a72866eb2c2907c679b1`
- **Type:** debug (Android, x86_64 and arm), development environment, `--dart-define=NUMAYA_DEV_TOOLS=true` (Prototype tools: Typography, Statistics cards, Design Lab, Demo hub). No secrets in the build.
- **App source:** `fe44b27128ece2f27d2866ab73f7f02749fcb00c` on `experiment/numaya-v8-review-20261114-0321`.
- **Flutter:** 3.47.8 stable.
- **Sign-in:** Welcome keeps the real phone sign-in ("Create an account", "I have an account"); with no SMS provider connected they reach the demo code screen. "Explore the demo" opens the on-device sample account.
- **Installed and checked** on the Pixel 10 emulator as an update (`adb install -r`, no uninstall or data wipe). See device-walk/.
- **Earlier copy:** `apk/SUPERSEDED-no-dev-tools-...-73a745f-...` was built without the development-tools flag, so the Typography controls were unreachable, and it could hold the launch screen on a cold start. Do not use it.
- **Known limits:** demo world only; backend, OTP, billing and push not connected; prices provisional; 3 and 6-month plans not purchasable.

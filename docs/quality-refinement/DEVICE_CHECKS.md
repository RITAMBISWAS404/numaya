# Device checks (2026-11-15)

Authorised by the owner in chat ("Yes, start it"). AVD `iPhone_16_Custom`, serial `emulator-5554`, Android 16 (API 36),
1180×2556 at 480 dpi, SwiftShader software rendering (`-gpu swiftshader_indirect`). Started by this session; no emulator
settings were changed (the hardware-keyboard setting was left as it was).

Review APK installed with `adb install -r` and launched: `Numaya-QualityRefinement-20261115-db3101d-debug.apk`, SHA-256
`3995c169b88d431bd02a15dd6a6029efe5a6047f89d3c496fdb4e40258c6b879` (hash checked before install). The integration and
profile runs installed their own builds; the review APK was reinstalled afterwards and left running.

Screenshots: delivery folder `screenshots\250-device-*.png` to `271-device-*.png` (labelled "emulator screenshot" in INDEX.csv).

| Check | Issue | Steps | Result |
| --- | --- | --- | --- |
| Dev Mode persists across relaunch | UI-085, UI-095, UI-096, UI-098, UI-097 | Set Halant + Nunito Sans, #A07ADD, Fully rounded, Filled; force-stop; relaunch | **Pass.** Welcome rendered in Halant; primary button sampled (160, 122, 221) = #A07ADD; capsule ends; filled secondary |
| Reset all, then relaunch | UI-097 | Dev Mode > Reset all; force-stop; relaunch | **Pass.** Summary "Default · Default (#7262C7) · Default · Outline · 15pt"; primary sampled (114, 98, 199) = #7262C7; outlined secondary |
| Slider drag | UI-090 | Filters > drag the age start thumb 182 px | **Pass.** 24 - 38 became 37 - 38; thumb and halo clear the label and divider; Reset restored 24 - 38 |
| Microphone permission | QR-009 | Chat > Record a voice note | **Pass.** System prompt "Allow Numaya to record audio?"; chose Only this time; recording started |
| Voice note record, preview, send, play | UI-070 | Record ~16 s, Stop, Play preview, Send, play the bubble | **Pass.** Preview Play became Pause; sent bubble shows solid pause bars while playing and progress advances |
| Photo attach (system picker) | QR-009 | Add a photo > Choose a photo > pick | **Pass.** Android photo picker (no storage permission); "Ready to send: Photo"; sent |
| Photo reply, keyboard open | UI-091, UI-093, QR-009 | Swipe the photo bubble right; type "Where was this" | **Pass.** Soft keyboard opened; preview above it with full-height thumbnail and the X outside; Send filled brand with white arrow, centred on the field |
| External dismiss | UI-091 | Tap Cancel reply | **Pass.** Quote cleared; typed text kept |
| Keyboard close | QR-009 | Back key | **Pass.** IME hidden (`mInputShown=false`); composer back at the bottom (Send y 1473 → 2310); draft kept |
| Integration test | QR-009 | `flutter test integration_test/onboarding_test.dart -d emulator-5554` | **Pass** (1 test) after replacing a retired step-by-step body with the maintained `signUpToHome` journey. Log: `final/integration_onboarding_device.txt` |
| Profile-mode frame timings | QR-011 | `flutter drive --profile` with `integration_test/perf_scroll_test.dart`, two runs | See below |

## QR-011 frame timings (two runs, profile mode)

| Scenario | Frames | Build p50 / p90 / p99 ms | Raster p50 / p90 ms |
| --- | --- | --- | --- |
| Discover scroll | 119 / 124 | 1.3 / 2.7 / 15.3 · 1.2 / 3.3 / 31.7 | 146 / 153 · 150 / 160 |
| Messages scroll | 142 / 139 | 1.9 / 4.6 / 23.7 · 2.0 / 4.9 / 30.8 | 86 / 95 · 90 / 99 |
| Chat scroll | 142 / 144 | 2.0 / 4.1 / 18.1 · 2.4 / 6.3 / 25.0 | 73 / 80 · 77 / 85 |

Reading: the UI (build) thread is well inside budget at the median and p90 in every scenario. Raster times reflect the
emulator's **software** renderer and say nothing about a GPU device; every frame exceeds 16 ms there. Discover rasterises
about twice as slowly as Messages (photos, blur), which is the scenario to re-measure on a physical phone. **No
optimisation was made**: there is no evidence of a defect on real hardware. Raw reports: `final/profile_frames_run1.json`,
`run2.json`. (`traceAction`/`watchPerformance` were tried first and need a VM-service socket the device refused; the test
reads the engine's FrameTiming instead.)

## Not run

TalkBack (screen reader) was not exercised. No physical phone, no iOS. The SwiftShader raster numbers are not
representative.

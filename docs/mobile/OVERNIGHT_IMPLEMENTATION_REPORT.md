# Overnight implementation report

Branch `experiment/numaya-overnight-completion`, from `experiment/numaya-complete-product` @ `103daa0`.
Status is in [OVERNIGHT_COMPLETION_MATRIX.md](OVERNIGHT_COMPLETION_MATRIX.md); evidence is in
[OVERNIGHT_QA_REPORT.md](OVERNIGHT_QA_REPORT.md).

## Batches

| # | Batch | Commit | Main files |
|---|---|---|---|
| 1 | Chat media: photos and videos from the phone, demo voice notes | `8bf58ae` | `dating/data/media_picker.dart`, `dating/presentation/chat_attachments.dart`, `messages_screens.dart`, `Composer`, `MobileIcon` |
| 2 | Illustrations for Events and visibility empty states; backlog | `dc30ea7` | `assets/illustrations/mobile/*.svg`, `NumayaIllustration`, `ILLUSTRATION_BACKLOG.md` |
| 3 | Adversarial QA (small phones, large text, keyboard) and the four fixes it found | `3e1b3db` | `overnight_stress_test.dart`, `route_sweep_test.dart`, action sheet, composer area, plan card |
| 4 | Profile photos from the phone; tests own the picker; failure artifacts untracked | `b095818` | `photo_options.dart`, `photos_screen.dart`, `edit_profile_screen.dart`, `person_profile.dart`, `core/media/local_image.dart` |
| 5 | Docs (this report, matrix, QA, tech stack) | see git log | `docs/mobile/` |

## Chat media: what works and what's simulated

| Capability | Implementation | Honest limit |
|---|---|---|
| Photo | Android Photo Picker via `image_picker`. Decoded at display size (`ResizeImage`), shown 4:3 in the chat, opens full screen with pinch zoom | Stays on the phone; not sent to anyone |
| Video | Picked the same way. Shown as a file card with name and size; files over 100 MB are refused | No player in this build; tapping says so |
| Voice note | Demo recorder: real timer, too-short rule (< 1 s), 2-minute limit, record again | No microphone plugin, so no sound is captured; the sheet and bubble say so |
| Caption | The composer text goes with the attachment; Send works with an attachment alone | — |
| Attachment menu | Photo, Video, Voice note: only options that do something | — |
| Failures | Cancel (nothing happens); photo access denied; unsupported type; video too large; unreadable file; picker unavailable, each with its own message | — |
| Offline | Attachments wait and send on reconnect like text | — |
| Inbox | The preview reads "You: Photo: caption" or "Voice note, 0:08" | — |
| Sample media | A Demo Hub switch uses a bundled fictional photo and a sample video card, for emulators with empty galleries | Labelled "Sample" |
| Accessibility | Each attachment message is one node (what it is, caption, open action); pending preview and Remove are separate | — |

**Architecture:**
- `MediaPicker` is an interface with three implementations: `DeviceMediaPicker` (`image_picker`),
  `SampleMediaPicker` and test fakes.
- Attachments ride on the existing `DemoMessage` and `DatingController.send`, so retry, offline queueing
  and per-thread state needed no new store.
- `localImage()` (`core/media`) resolves picked files and bundled samples for chat and profile photos alike.

## Profile photos

- Sign-up and Edit profile add or replace photos from the phone (gallery, or the camera after the existing
  permission prompt).
- `DraftPhoto.source` carries the file path through the draft, so these all read it:
  - the photo grids;
  - the Profile avatar (the main photo);
  - `memberAsPerson` (Preview, profile sections).
- No repository change was needed.
- Where no picker exists (tests, desktop) a placeholder tile is added, as before.

## Fixes found by testing, not by request

1. Toasts with long messages overflowed (`NumayaToast`).
2. The pending-attachment description swallowed its Remove button for screen readers.
3. The chat composer area overflowed at 320 × 568 with 2× text and the keyboard up.
4. The shared action sheet overflowed with six actions at 150% text; its rows also clipped.
5. Paywall plan cards overflowed at 200% text.
6. 204 golden-failure artifacts were committed by earlier batches; untracked, and the folder is ignored.

## Dependency added

`image_picker ^1.2.4` (flutter.dev publisher, BSD-3).
- **Transitive packages:** its platform packages, `file_selector_*` for desktop, `cross_file`, `mime`,
  `plugin_platform_interface`, `flutter_plugin_android_lifecycle`. None opens a network path or collects
  telemetry.
- **Unverified build:** this is the app's first native plugin. Its Android build could not be compiled
  here, because the SDK host is blocked. [TECH_STACK.md](TECH_STACK.md) says so.

## Not done, and why

| Item | Why |
|---|---|
| Video playback, recording and playing voice | More native plugins (and a microphone permission) that can't be built or tried here; adding them blind risks breaking the first local build |
| Message and media delivery | Needs a backend; everything stays on the device and says so |
| Mobbin research | No new product gap needed it: chat media follows the existing catalogue (B-44 lists photos, video and voice) |
| APK | Android SDK host returns 403 |

## Build on Windows (final branch)

```
git fetch origin
git checkout experiment/numaya-overnight-completion
cd apps\numaya_mobile
flutter pub get
flutter doctor -v
flutter build apk --debug
```

The APK is written to `build\app\outputs\flutter-apk\app-debug.apk`. To try the media features on a phone:
1. Open a chat, then **+** › Photo. The Photo Picker opens.
2. Profile › Edit profile › add a photo.
3. On an emulator with an empty gallery, turn on Demo Hub › **Use sample media**.

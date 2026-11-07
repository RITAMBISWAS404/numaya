# Run state and reproduction (Visual Lab V2)

**Status: complete** for this run (2026-11-08). Nothing pending except the owner's selections.

## Reproduce (Windows, Git Bash, from `apps/numaya_mobile`)
1. Demo photos: `python tool/install_demo_photos.py` (local only, never committed).
2. Emulator: Pixel 10 AVD (API 36) running as `emulator-5554`.
3. Capture: `ADB=<sdk>/platform-tools/adb.exe bash tool/capture_visual_lab.sh emulator-5554 <out>`.
   Targeted recapture: `ONLY=<parts or group IDs> bash tool/capture_visual_lab.sh …` (parts: `default`,
   `sheet`, `scenario`, `card`, `screen`, `large`, `motion`, `motion-sheet`, or a card group ID).
   The final set = full run on `9d4ed30`+harness fixes, then `sheet,scenario,plan-card,motion` and
   `default,plan-card,wallet-card` recaptured on `8510778`, merged by file name. Every shot whose
   screen changed after the full run was recaptured on `8510778`.
4. Registry JSON: `flutter test tool/dump_lab_registry.dart --dart-define=OUT=<file>`.
5. Gallery: `python tool/visual_lab_gallery/build_gallery.py --registry <json> --capture <out>
   --history "<MVP gallery folder>" --commit <sha> --baseline 0df9ec3 --branch <branch> --out <dir>`.
6. APK: `flutter build apk --debug`; copy to `<Desktop>\Numaya Test Builds\`.

## After the owner's choices (brief 07 follow-up; not started)
Read the exported JSON; check `reviewId` (`vl2-8510778-2026-11-08`) and `codeCommit` (`8510778`);
reject unknown IDs; apply only explicit choices (and dependency-approved screen bundles) by setting
`proposed` in `lib/features/lab/lab_registry.dart`; leave undecided groups unchanged; rerun analyze,
tests and a targeted capture; rebuild the APK; update this handoff and push.

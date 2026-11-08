# Delivery (alignment V3)

- **Branch:** `experiment/numaya-ente-alignment-lab-20261108-1829` (from `a000ff3`; checkpoint tag
  `checkpoint/pre-ente-alignment-20261108-1829`, pushed). Not merged.
- **App source for captures and APK:** `ba3a6fc4807833b8a19623738b095d18cae9cbca`. Later commits are
  tooling and docs only.
- **Gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya Ente Alignment Review\2026-11-08 1909\index.html`
  (review `ea3-ba3a6fc-2026-11-08`; `components/`, `screens/`, `qa/`, `raw-captures/`,
  `manifest.json`, `README.md`, `choices-example.json`). Local only: it shows private demo photos.
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Ente-Alignment-Lab-20261108-ba3a6fc.apk`
  - SHA-256 `ea6f34756963cfc82793a0cd207a84fed0fc1cb148111c242ff8d7940e549ffc`, 222,375,911 bytes
  - debug, `com.numaya.numaya_mobile`, 0.1.0 (1), minSdk 24, targetSdk 36
  - `flutter build apk --debug` in `apps/numaya_mobile`; existing debug signing; `adb install -r`
    (data kept) Success; launches to Welcome. Contains private demo photos: never publish.
- **Reproduce:** `TEST=integration_test/ente_alignment_review_test.dart CLEAR_ANR=1 bash
  tool/capture_visual_lab.sh emulator-5554 <raw dir>`, then `python tool/ente_alignment_gallery/
  build_gallery.py --capture <raw dir> --commit <sha> --baseline a000ff3 --branch <branch> --out <dir>`.
- **Not in Git:** the review folder, APK and private photos (`pics/`).

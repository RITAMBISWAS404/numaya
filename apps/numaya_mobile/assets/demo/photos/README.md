# Local demo photos (not in git)

This folder holds a **local** reference-photo set for judging the demo UI with real photography.
Everything here except this README is git-ignored, so it never reaches GitHub. The folder is
declared in `pubspec.yaml`; with no set installed the app shows its grey photo placeholders.

Install or replace a set (from `apps/numaya_mobile`):

    python tool/install_demo_photos.py "<photo folder>"

The photo folder needs a `numaya_demo_photos.json` spec (see the tool's docstring): each photo's
role (`portrait` for main photos and avatars, `scene` for later gallery positions) and its face
position. The tool copies the originals unchanged as `photo_NN.jpg`, writes square `face_NN.jpg`
crops for portraits, and writes `demo_photos.json`, which `DemoPhotoLibrary` reads at start-up.
Rebuild the APK after installing.

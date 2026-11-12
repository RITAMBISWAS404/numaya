# Account handoff

> **2026-11-13, Fable design lab. Read this first.**
> - **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (a worktree). **Branch:** `experiment/numaya-fable-design-20261113-0048`, based on the replacement V8 `c890d02`. App source `da197b7`.
> - **What it is:** six experiment groups with real alternatives (Discover, Profile, Messages, Received Compliment, Credits, Streak). The app default is still the owner's baseline (O) in every group.
> - **Records:** [docs/design/fable-lab](../design/fable-lab/EXPERIMENTS.md): EXPERIMENTS, COVERAGE.csv, QA_HANDOFF.
> - **Next:** the owner reviews the gallery and exports choices. Then follow QA_HANDOFF. Do not pick options for the owner.
> - **Other checkouts:** `C:\Users\biswa\Projects\Numaya` (replacement V8) and `C:\Users\biswa\Projects\Numaya-backend` are separate work. Do not switch or edit them from here.

Open `C:\Users\biswa\Projects\Numaya-fable-lab` on the next account, then read this file and START_HERE.

- **Branch:** `experiment/numaya-fable-design-20261113-0048`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-fable-design-20261113-0048`.
- **Base:** replacement V8 `c890d02` (itself on the selected V7 `b5e5245`).
- **App source:** `da197b7`. Later commits change only tools and records.
- **Gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya Fable Lab Review\2026-11-13 da197b7\index.html`. Review ID `fx-da197b7-2026-11-13`.
- **Renders:** `C:\Users\biswa\OneDrive\Desktop\Numaya Fable Lab Screenshots\2026-11-13 da197b7` (28 PNGs and INDEX.md).
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Fable-Lab-20261113-da197b7-debug-lab.apk` (debug, Design Lab enabled, 0.1.0+1, SHA-256 `28ccb2df599c77d913723b563ec1fb1e74d4203275646f23e730629598072c5e`).
- **Rebuild the review set:** `python tool/fable_lab/build_review.py` (see its docstring), after rendering with `test/screenshots/fx_lab_capture_test.dart`.
- **Local only, not on GitHub:** the demo photos, `test/screenshots/fx/`, the gallery, the render folder, APKs, and the reference images from the brief ZIPs.
- **Do not touch:** `C:\Users\biswa\Projects\Numaya`, `C:\Users\biswa\Projects\Numaya-backend`, `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

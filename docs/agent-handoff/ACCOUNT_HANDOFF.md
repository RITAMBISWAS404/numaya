# Account handoff

> **2026-11-13, selected designs applied. Read this first.**
> - **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (a worktree). **Branch:** `experiment/numaya-selected-20261113-0232`, from the Fable lab `c6a31a4` (tag `checkpoint/fable-lab-20261113-0232`). App source `ae10663`.
> - **What it is:** the owner's export `fx-da197b7-2026-11-13` applied as the app defaults, with every note (Discover O with notes, Profile A, Messages A, Received Compliment A, Credits O and Streak O on one summary card), plus a labelled Explore the demo entry on Welcome.
> - **Records:** [docs/design/selections](../design/selections/FINAL_REVIEW.md): FINAL_REVIEW, JOURNEY_EVIDENCE.csv, BACKEND_BOUNDARY.
> - **Real backend:** BLOCKED (no Supabase project, OTP not configured, no billing or push). The backend branch is not merged here.
> - **Other checkouts:** `C:\Users\biswa\Projects\Numaya` and `C:\Users\biswa\Projects\Numaya-backend` are separate work. Do not switch or edit them from here.

Open `C:\Users\biswa\Projects\Numaya-fable-lab` on the next account, then read this file and START_HERE.

- **Branch:** `experiment/numaya-selected-20261113-0232`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-selected-20261113-0232`.
- **Base:** the Fable lab `c6a31a4`, on the replacement V8 `c890d02`.
- **App source:** `ae10663`. Later commits change only tools and records.
- **Review page:** `C:\Users\biswa\OneDrive\Desktop\Numaya Selected Design Review\2026-11-13 ae10663\index.html` (opens offline).
- **Screenshots:** `C:\Users\biswa\OneDrive\Desktop\Numaya Selected Design Screenshots\2026-11-13 ae10663` (203 emulator PNGs, numbered 001 to 203).
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Selected-20261113-ae10663-debug-demo.apk` (debug, demo entry, no Design Lab, SHA-256 `e66250087cb0bf488038f7bd0ae0f6ca808e11ca5e5e0701c7225222ba29aa31`).
- **Rebuild the review set:** capture with `integration_test/final_screens_capture_test.dart` through `tool/capture_visual_lab.sh`, then `python tool/selections/build_review.py` (see its docstring).
- **Local only, not on GitHub:** the demo photos, screenshots, the review folder, APKs, and the reference images from the brief ZIPs.
- **Do not touch:** `C:\Users\biswa\Projects\Numaya`, `C:\Users\biswa\Projects\Numaya-backend`, `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

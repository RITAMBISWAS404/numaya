# Account handoff

> **2026-11-14, V8 UI review applied. Read this first.**
> - **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab` (a worktree). **Branch:** `experiment/numaya-v8-review-20261114-0321`, from `7cd7aa4` (tag `checkpoint/selected-20261114-0321`). App source `fe44b27`.
> - **What it is:** the owner's V8 review register (UI-001 to UI-086) applied with the execution companion; a persisted 14/15 body-size toggle plus display and UI font selectors (Prototype tools > Typography); alternatives for Premium, statistics cards, Match and Profile in the gallery and the Design Lab (choices kept across relaunches).
> - **Records:** [docs/v8-review](../v8-review/FINAL_REVIEW.md): FINAL_REVIEW, ISSUE_LEDGER.csv, OPEN_DECISIONS, ARTWORK_SLOTS.csv, RUN_STATE.
> - **Review folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f`.
> - **Real backend:** BLOCKED (no Supabase project, OTP, billing or push). The backend branch is not merged here.
> - **Other checkouts:** `C:\Users\biswa\Projects\Numaya` and `C:\Users\biswa\Projects\Numaya-backend` are separate work. Do not switch or edit them from here.

Open `C:\Users\biswa\Projects\Numaya-fable-lab` on the next account, then read this file, START_HERE and docs/v8-review/RUN_STATE.md.

- **Branch:** `experiment/numaya-v8-review-20261114-0321`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-v8-review-20261114-0321`.
- **App source:** `fe44b27128ece2f27d2866ab73f7f02749fcb00c`. Later commits change only tests, tooling and records.
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f\apk\Numaya-V8-Review-20261114-fe44b27-debug.apk` (debug, demo entry, SHA-256 `4391d664f718a550e8470d5ed05d09dea7551e392438a72866eb2c2907c679b1`).
- **Screenshots:** `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f\screens-flat` (222 emulator PNGs).
- **Gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f\gallery\index.html` (offline; export JSON).
- **Rebuild:** emulator capture `integration_test/final_screens_capture_test.dart` via `tool/capture_visual_lab.sh`; harness renders `test/screenshots/v8_review_capture_test.dart` (see its header); gallery `python tool/v8_review/build_gallery.py`.
- **Local only, not on GitHub:** demo photos, screenshots, renders, the review folder, APKs and the review ZIPs.
- **Do not touch:** `C:\Users\biswa\Projects\Numaya`, `C:\Users\biswa\Projects\Numaya-backend`, `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

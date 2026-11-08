# Account handoff

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `experiment/numaya-ente-refinement-v4-20261108-1928`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-ente-refinement-v4-20261108-1928`.
- **Approved baseline:** tag `checkpoint/pre-ente-v4-20261108-1928` (`6fad2d1`), which carries the owner-approved 15px typography (H-08).
- **V4 candidate:** app code `25e145f`. A later records-only commit sits on top and does not change the app. Not merged anywhere.
- **Next action:** the owner reviews the gallery, chooses, exports JSON and sends it back. Then apply those choices in a separate pass. An empty export means nothing was chosen.
- **Owner choices open:** 10 groups in the gallery. Also Events decisions O1, O2 and D2 from earlier.
- **Gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya V4 Review\2026-11-09 0109\gallery\index.html`
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Ente-V4-20261109-25e145f.apk` (debug, version 0.1.0+1, SHA-256 `34054bc737187daac584221cf0ef43d76a0f4f6990a372eaca81959f07c3f13e`).
- **Records:** `docs/design/ente-refinement-v4/` (rules, component map, tint audit, routes, skills, references, register).
- **Skills:** project-local `flutter-figma-workflow`, `flutter-ui-design`, `design-review`, and the existing `impeccable`.
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics\`, `apps/numaya_mobile/assets/demo/photos/`, APKs and review folders. They show private photos, so back them up privately. Rebuilding the demo needs `pics\` and `tool/install_demo_photos.py`.
- **Not done:** physical-phone test, blur profiling (needs a phone), keyboard check on device.
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

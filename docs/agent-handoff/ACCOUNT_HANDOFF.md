# Account handoff

Open this same folder on the next account, then read this file and START_HERE. A fresh clone is not needed.

- **Branch:** `experiment/numaya-mvp-focus-v5-20261109-2303`. Verify with `git status -sb` and `git ls-remote origin experiment/numaya-mvp-focus-v5-20261109-2303`.
- **Checkpoint before V5:** tag `checkpoint/pre-mvp-v5-20261109-2303` (`ca0ff57`), the V4 candidate.
- **MVP scope:** [MVP_SCOPE.md](../product/mvp-focus-v5/MVP_SCOPE.md). Events and Health are deferred; the Events PRD is roadmap history. To re-enable Events internally: `--dart-define=NUMAYA_EVENTS=true`.
- **App source:** `36407b3`. Later commits on the branch change only records and delivery tooling. Not merged anywhere.
- **Compliment policy:** [COMPLIMENT_CONTRACT.md](../product/mvp-focus-v5/COMPLIMENT_CONTRACT.md). One per pair, debit after acceptance, recipient's reply opens the chat.
- **Approved:** 15px type, purple brand, Tabler icons, #D6D6D6 switch, V4 surfaces. The gradient name is the owner-requested V5 default.
- **Undecided in the gallery:** name over photo, received Compliment card, Welcome colour, Chats layout, Profile layout. Earlier Events decisions are parked with Events.
- **Next action:** the owner reviews the phone folder and gallery, exports choices and sends them back. Apply them in a separate pass.
- **Phone folder:** `C:\Users\biswa\OneDrive\Desktop\Numaya MVP V5 Screenshots\2026-11-10 0058`
- **Screen index:** `C:\Users\biswa\OneDrive\Desktop\Numaya MVP V5 Screenshots\2026-11-10 0058 review-gallery\index.html`
- **Choice gallery:** `C:\Users\biswa\OneDrive\Desktop\Numaya MVP V5 Review\2026-11-10 0058\gallery\index.html`
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-MVP-V5-20261110-36407b3.apk` (debug, 0.1.0+1, SHA-256 `c9453662932b30293828227ae9e934f13bfa769f966e8cfec57c24932945b0e8`).
- **Records:** `docs/product/mvp-focus-v5/` (scope delta, benchmark, contract, launch readiness, references, skills, coverage, register).
- **Skills:** project-local `flutter-figma-workflow`, `flutter-ui-design`, `design-review`, `impeccable`. `rad-spacing` and `audit-design-system` are not installed: no licence on GitHub.
- **Connectors:** Figma (claude.ai connector) and Mobbin need sign-in on a new account. The Figma plugin needs `/mcp`.
- **Local only, not on GitHub:** `pics\`, `apps/numaya_mobile/assets/demo/photos/`, APKs, review folders, `.claude/launch.json`. They show private photos. **No private backup location exists yet.** Rebuilding the demo needs `pics\` and `tool/install_demo_photos.py`.
- **Known baseline failures:** web token and icon checks and one token test fail on CRLF only; browser e2e needs Playwright's browser.
- **Not done:** physical phone, iOS, screen reader, blur profiling. This is a front-end test build: see [LAUNCH_READINESS.md](../product/mvp-focus-v5/LAUNCH_READINESS.md).
- **Do not touch:** `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app`.

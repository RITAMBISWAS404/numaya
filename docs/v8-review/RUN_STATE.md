# V8 UI review run state

Updated 2026-11-14. Read this first after compaction or an account switch.

- **Checkout:** `C:\Users\biswa\Projects\Numaya-fable-lab` (worktree). App: `apps/numaya_mobile`.
- **Branch:** `experiment/numaya-v8-review-20261114-0321`, from `7cd7aa409f4e2b1e7ea0bffa19e2ebb00806b98f` (selected designs, app source ae10663; clean tree at start).
- **Checkpoint:** tag `checkpoint/selected-20261114-0321` (pushed).
- **Why this base:** newest pushed frontend candidate (remote refs fetched 2026-11-14); the review screenshots show its Messages A (Your turn / Waiting) and Profile A.
- **Backend:** `C:\Users\biswa\Projects\Numaya-backend` (`bbbe8af`), separate and untouched; not merged. Real backend BLOCKED (no Supabase project, OTP, billing, push).
- **Inputs:** NUMAYA_V8_UI_REVIEW_HANDOFF.zip sha256 `421a0d8979c992114330c82bf92704fbb8c2344d84193d6e7a40d17fc1f9d28a`; NUMAYA_V8_EXECUTION_COMPANION.zip sha256 `6f6bf391180a3e9119e425149db38bb0a0cb1daee30145305f46c02d8c54ecb1`. Extracted to the session scratchpad `v8z/` (not committed).

## Done
1. Typography review controls (7786041): Prototype tools > Typography; Display font, UI font, Base body size 14/15 (default 15), Reset; persisted to app-support JSON in review builds only.
2. Shared foundations (3a571ab): UI-050 radius roles, UI-026 compact nav, UI-003 CardDivider, UI-057 outlined disabled, UI-002 lighter outline, UI-060 filled callouts, UI-062 compact 8pt.
3. Flows (2bd3cb8): onboarding copy/grouping, UI-058/059 preview + order, UI-061 PromoCard (filters, settings), UI-064/065 Likes, UI-066 scrim, UI-063/075 gating.
4. Messages/Chat (3efc9a6): UI-033/067/068/069/081/035/079/080/071/072/073/086/083.

## Render harness
`flutter test --tags comparison --run-skipped --update-goldens test/screenshots/v8_review_capture_test.dart --dart-define=V8_ONLY=<prefixes>`; scenes in `test/screenshots/v8_scenes.dart`; output `test/screenshots/v8/` (git-ignored).

5. Profile area (a4e775c); alternatives: Premium (b6fafe8), statistics (683dbc6), Match (77bced0), Profile (81e826d); lab persistence (554f534).
6. Tests updated to the V8 rules and new V8 tests (f9cffe4); overflow fixes; startup fix (fe44b27, the APK's app source).
7. Delivery records committed and pushed (8767b8d, remote verified).

## Outputs (local, private)
- Review folder: `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f` (screens-flat 222, gallery 96 renders, apk, device-walk, records).
- APK: `apk\Numaya-V8-Review-20261114-fe44b27-debug.apk`, SHA-256 `4391d664f718a550e8470d5ed05d09dea7551e392438a72866eb2c2907c679b1`.

## Next
The owner reviews the gallery and the APK and exports choices (layouts plus display font, UI font, 14 or 15 body). Then apply the exported choices as defaults in a new pass; supply 3/6-month prices and artwork; decide UI-034.

## Active processes
None. The emulator was left running; the gallery preview server (port 8775) is a local preview only.

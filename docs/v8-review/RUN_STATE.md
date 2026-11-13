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

## Known test updates needed
Tests encoding superseded geometry fail (stadium nav, 20pt buttons, outlined StatusBanner, no-hairline groups, old inbox sections, bubble time). Update them to the V8 rules; do not delete.

## Next
Profile/Settings/Completion/Wallet (UI-041-048, 053, 070); lab choice persistence; experiments (UI-076 x3, UI-078 x6, UI-082 x6, UI-084 x10, UI-034 likes tile); fix tests; capture; gallery; APK; ledger; push.

## Active processes
None.

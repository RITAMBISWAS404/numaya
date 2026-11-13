# V8 UI review run state

Updated 2026-11-14. Read this first after compaction or an account switch.

- **Checkout:** `C:\Users\biswa\Projects\Numaya-fable-lab` (worktree). App: `apps/numaya_mobile`.
- **Branch:** `experiment/numaya-v8-review-20261114-0321`, from `7cd7aa409f4e2b1e7ea0bffa19e2ebb00806b98f` (selected designs, app source ae10663; clean tree at start).
- **Checkpoint:** tag `checkpoint/selected-20261114-0321` (pushed).
- **Why this base:** newest pushed frontend candidate (remote refs fetched 2026-11-14); the review screenshots show its Messages A (Your turn / Waiting) and Profile A.
- **Backend:** `C:\Users\biswa\Projects\Numaya-backend` (`bbbe8af`), separate and untouched; not merged. Real backend BLOCKED (no Supabase project, OTP, billing, push).
- **Inputs:** NUMAYA_V8_UI_REVIEW_HANDOFF.zip sha256 `421a0d8979c992114330c82bf92704fbb8c2344d84193d6e7a40d17fc1f9d28a`; NUMAYA_V8_EXECUTION_COMPANION.zip sha256 `6f6bf391180a3e9119e425149db38bb0a0cb1daee30145305f46c02d8c54ecb1`. Extracted to the session scratchpad `v8z/` (not committed).

## Done
1. Typography review controls (commit 7786041): Prototype tools > Typography; Display font, UI font, Base body size 14/15 (default 15), Reset; persisted to app-support JSON in review builds only.

## Next
Shared-system passes (radius, colour, gradient, spacing, borders, icons, components), then flows (onboarding, Discover, Likes, Match, Messages/Chat/Compliments, Profile/Settings/Premium), experiments (UI-076 x3, UI-078 x6, UI-082 x6, UI-084 x10), capture, gallery, APK, ledger, push.

## Active processes
None.

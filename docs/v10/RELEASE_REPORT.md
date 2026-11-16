# V10 release report (2026-11-16)

- **Branch:** `experiment/numaya-v10-design-led-20261116-1847`, from `6129fa2`, which is the owner-approved `42b8dba` plus the Flutter skills. The source commit is the one that adds this file; see `git log`.
- **Mode:** demo. No live backend was configured or contacted.
- **Platform evidenced:** Android emulator `emulator-5554` (AVD named iPhone_16_Custom, which is Android, not iOS) and Flutter widget renders.

**Overall: RED for public release.** This is a usable private review build. It is not launch-ready: signing, the live service and store items are missing (see below).

## Visual: PASS (heuristic, for the evidenced screens)
- Direction A (People first) won two blind critique rounds against the baseline. The final-candidate critic gave a narrow yes (DECISIONS D7); its one regression, the Premium placement, is fixed.
- Every defect the critics and device pass found in V10's own changes is fixed (ISSUE_TRACKER.csv). Two items that predate V10 and exist in both versions are recorded, not fixed: DEF-V10-14 and DEF-V10-15.
- At 320pt with 200% text, nothing is clipped, no word breaks inside itself, and every action stays visible (DEF-V10-04 fixed).
- Scope: Discover, the person body (Likes, the person page, the own preview and the onboarding review share it), own Profile, and received and active Chat. Other screens keep the shared V8/QR components unchanged.
- This is a heuristic review, not proof that every user prefers A. O and C stay selectable in the Design Lab of dev builds.

## Engineering: PASS for this revision
- `flutter analyze` reports only the two pre-existing infos.
- `flutter test`: 747 passed, 50 skipped, 0 failed. The 50 skipped tests are the comparison-capture suites, run separately.
- The debug APK builds.
- Assertions changed: tests of O-only structure are pinned to O, and each has an A counterpart. No assertion was removed, and no overflow was suppressed.
- Riverpod, go_router, providers, routes and backend contracts are unchanged. V10 is presentation-only. Business rules are unchanged: credits, reply-is-free, Dismiss asks first, block and report. Events, Health, Follow and SuperSwipe stay off.
- Motion: no new animation. Press feedback uses `AppMotion.duration`, which is zero under reduced motion.
- Not run:
  - `npm run check` and `npm run test:e2e`. No web files changed, and there are no node_modules in this worktree.
  - TalkBack spoken output.
  - A physical phone (PR-005).
  - iOS.

## Service: NOT EVIDENCED (RED)
- No Supabase project, OTP provider, push or billing is configured. Live auth, discovery, Compliments and chat persistence were not exercised.
- U1–U6 live states are open.
- The demo labels unsent messages "Not sent: saved on this device". Nothing in the demo is shown as live.

## Release: BLOCKED (RED)
- **Signing:** there is no upload keystore. The PR-001 gate makes `flutter build apk --release` fail as designed, and was re-checked 2026-11-16. No signed release artifact exists.
- **Labs:** release builds render `LabGroup.proposed` only. The Design Lab and Demo Hub need dev tools, and the review APK is built with `NUMAYA_DEV_TOOLS=true`, so it is not a public artifact.
- **Privacy:** demo photos stay in the git-ignored render folders and the local review folder only. No secrets were read or printed.
- **Not prepared:** store declarations, privacy and deletion, moderation and child-safety reviews, and the account review.

## Owner actions
1. Provide the upload keystore through `android/key.properties`, then build and verify the signed release.
2. Configure a staging backend (Supabase, OTP, push) so the service gate and U1–U6 can be exercised.
3. Approve or overrule A as the default. One switch: `v10-direction` `proposed` in `lab_registry.dart`.
4. Decide whether the credits and streak cards should sit below "Your profile" (D6).
5. Decide UI-099/UI-100 (needs a PRD and ranking rules).
6. Attach a physical phone for PR-005 performance and a TalkBack pass.

# Work log

## 2026-11-06 · Overnight v4 (cloud, Linux)
- Branch `experiment/numaya-ente-polish-v4-20261106-0724` from `fc72906`.
- Probes: keyboard over 7 forms, Back and double taps, failed send/retry, accessibility guidelines on 58 routes and 12 variants, focus order, long names, missing photos, reduced motion.
- Fixes V4-01 to V4-05 with `v4_polish_test` (8 of 9 tests fail on V3).
- Evidence: `artifacts/ente-design-system/overnight-v4/`. Not pushed.

## 2026-11-06 · Overnight v3 (cloud, Linux)
- Pre-run backup `numaya-ente-recovery-20261106-062350-prerun-v3-f2e18e6.zip` (sha256 cdc60fe2…7a8337).
- Checkpoint commit `e60504e`; tag `numaya-ente-design-system-finalized-20261106-0624`; branch
  `experiment/numaya-ente-delight-v3-20261106-0624` (worktree `/home/user/numaya-ente-v3`).
- Skills installed project-locally: `prototype` (emilkowalski/skills c8a7962, MIT) and
  `ux-researcher-designer` (alirezarezvani/claude-skills 8f08254, MIT, no persona script).
- Fidelity: V3-D01, V3-D02, V3-F01; component boards; Figma Ducky catalog and banner, action-sheet,
  toast and button sources re-read.
- Experiments EXP-001 to EXP-004 (Current/A/B/C), Experiment Lab, MascotArt slot + 3 poses.
- Two visual reviews (390x844; 320pt at 200%); 9 variant fixes.
- Evidence and choices: `artifacts/ente-design-system/overnight-v3/`. Not pushed, merged or deployed.

## 2026-11-06: review batch 2, UI-013 to UI-032 (Windows, uncommitted)
- Implemented across Discover, Filters, navigation, New Match and the first-release scope:
  - Backtrack and Filter header;
  - swipe-only decisions with accessible alternatives;
  - photo identity group; shared interests below the photo; About me divider;
  - emoji detail pills and the card label hierarchy;
  - gender rows (multi-select kept), outlined inactive tabs, grey sheets with white cards;
  - full-width sliders and the Figma off switch;
  - compact nav with a soft shadow;
  - New Match with app bar, card, and View profile and Open chat actions;
  - `ReleaseScope` gates Opening Moves and SuperSwipe; Follow does not exist.
- Device: 30 shots at 390dp plus 30 at 320dp with 150% text, under `C:\Users\biswa\Downloads\NUMAYA_DISCOVER_MATCH_HANDOFF\numaya-ui-review\after\\`. Tracker: `docs/design-experiments/ente-design-system/UI_REVIEW_BATCH2_TRACKER.md`.


## 2026-11-05: UI review handoff UI-001 to UI-012 (Windows, uncommitted)
- Implemented the onboarding review and its app-wide rules:
  - secondary buttons, option cards, age-range card and pop-up;
  - inline height wheel, prompt cards, category prompt browser with answer sheet;
  - stacked heading art, top-aligned alert icons, 3:4 profile photos, type one-offs.
- UI-001 final artwork is blocked (temporary brand image in place). The UI-008 phrase "three-day-to-time-driven response" is awaiting clarification.
- 373 passed, 15 skipped.
- Evidence in `C:\Users\biswa\Downloads\NUMAYA_ONBOARDING_HANDOFF\numaya-ui-review\after\`. Status in `docs/design-experiments/ente-design-system/UI_REVIEW_HANDOFF_STATUS.md`.

## 2026-11-05: UI screenshot inventory (Windows, capture only)
- 151 device screenshots of the current Ente working tree, in `C:\Users\biswa\OneDrive\Desktop\Numaya-UI-Review-2026-11-05-1747`, with a README, index, coverage report, contact sheets and gallery.
- Capture-only tool added, uncommitted: `apps/numaya_mobile/integration_test/ui_review_capture_test.dart`.
- No product code changed.

## 2026-11-05: Ente reconstruction pass (Windows, uncommitted)
- Checked Bumble's discovery, filters, Chats and search flows on Mobbin.
- Rebuilt Discovery as a full-screen photo card with the identity overlaid and a floating decision row.
- Liked and person profiles use the same card.
- Chats: search moved behind a header icon. The Profile tab uses Menu Item rows. Filters are grouped in cards.
- Content pass removed redundant copy.
- 361 passed, 15 skipped; R3 device journey captured; tracker in `TRACKER.md`.

## 2026-11-05: Ente design system experiment (Windows, uncommitted)
- New worktree `numaya-ente` from `f2e18e6` plus the final-design-run patch.
- Read the Ente Figma file: tokens, type, spacing, radius and 14 components.
- Mapped the Ente values into the hand-authored tokens, with purple in Ente's primary role.
- Replaced the Material icon map with Lucide 4.0.1.
- Restyled the shared components to Ente's specs.
- Checked discovery, Likes and profile editing against Bumble on Mobbin.
- QA fixed four real layout and target bugs and moved the old-spec tests to the Ente contract.
- 361 passed, 15 skipped; two emulator journeys and a narrow, large-text pass.


## 2026-11-04: pill gaps (cloud, uncommitted)
- Root cause: the `ViewTabs` row had no gap; fixed in the shared component (11 callers).
- Event badges 6 → 8.
- New gap and edge-tap test, shown to fail at gap 0.
- 338 passed, 15 skipped; 28 goldens changed and reviewed.

## 2026-11-04: core journey (cloud, uncommitted)
- Live Mobbin research (Bumble People, Chats, chat, Interests; Hinge profile) and a wireflow.
- Discover A against B (B kept, with a large-text fallback); inbox order; nav solid against frosted; separators.
- 337 passed, 15 skipped; 27 goldens changed and reviewed.

## 2026-11-04: design direction (cloud, uncommitted)
- Issue map and thesis.
- DX-01: Safety tips, A against B, B kept.
- 334 passed, 14 skipped; only `f37` changed.

## 2026-11-04: component cleanup (cloud, uncommitted)
- Implemented CL-01 to CL-07 in shared components; 8 new tests; 7 tests updated to the new decisions.
- 334 passed, 14 skipped; 93 goldens changed and reviewed.
- **Left:**
  - the remaining separator sites;
  - device checks;
  - commit and push (needs authorisation).

## 2026-11-04: spacing and shape (cloud, uncommitted)
- **Audit:** a source scan of spacing and radius literals; a doubled-gutter scan (none found);
  nested radii (consistent).
- **Fixed** SP-01 to SP-08 in shared components (`app_layout.dart` gains 6 semantic tokens).
- **Tests:** new `spacing_rules_test.dart`, shown to fail on drift. 326 passed, 14 skipped; 89
  goldens changed and reviewed.
- **Left:** commit and push (needs authorisation); device and Inspector checks.

## 2026-11-04: type roles (cloud, uncommitted)
- Traced the body, pill and chip styles.
- Added the `pill` role (12/16) for `ViewTabs` and `NumayaChip`; `chip` and `StatusBadge` are now
  12/16.
- Mapped the headings to 32/28/24/20/18, and removed the unused compact switch.
- The 8/12 badge trial was rejected (illegible at 1x).
- New `type_roles_test.dart`; its regression check fails under 16/24 as intended.
- 323 passed, 14 skipped; 176 goldens changed and reviewed.
- Left: commit and push (needs authorisation); a device check.

## 2026-11-04: final refinement and QA pass (cloud, uncommitted)
- **Verified:** the worktree, branch and HEAD (`6b23c85`); nothing staged; the other checkout's 14
  files untouched; the overnight branch is not on GitHub; no device (Linux desktop only); the
  Android SDK host is still denied.
- **Baseline:** 312 passed, 14 skipped; analyze clean. The capture showed a nondeterministic
  `m01`.
- **Audited** onboarding, events, settings, safety, premium, help and verification at 14/20 on
  golden renders; computed the overlay composites.
- **Fixed:**
  - F-01: the Design Lab clock;
  - F-02: `ListRow` long value plus detail (`p05`), with Mobbin Family and Expedia as
    references.
  - Each has a regression test; F-02's test was shown to fail without the fix.
- **Added** a keyboard-over-tab-bar test and a rapid double-Send test.
- **Results:** 316 passed, 14 skipped, 0 failed. Only `m01` and `p05` captures changed, both
  reviewed.
- **Left:** commit and push (needs authorisation); the APK and device checks on Windows.

## 2026-11-03 UTC: overnight polish (cloud worktree, uncommitted)
- **Verified:**
  - `wip/frosted-navigation-handoff` is at `6b23c85aa7be16b5cfeaebdea06c36a9090243b2` on GitHub
    (`git ls-remote`).
  - The worktree `/home/user/numaya-overnight` was created on the new branch
    `experiment/numaya-overnight-polish` at that commit.
  - The other checkout (`/home/user/numaya`, 14 uncommitted files) was not touched.
- **Tools:**
  - Installed the official `dart-flutter` plugin 1.0.7 at user scope (it loads next session).
  - Mobbin connector live.
  - No Android SDK: `dl.google.com` is denied by the environment's network policy.
- **Baseline:** all 188 captures rendered on Linux from HEAD; full suite 302 passed, 12 skipped.
- **Type:**
  - Added `MonoType` with a token switch.
  - Compared 16/24, 14/20 and compact on Discover, the bio, Profile, a long bio and Chat, at
    320/390 and 100%/200% text.
  - Adopted 14/20 (OP-01); exceptions OP-02 and OP-03.
- **Direction:** built a calm and an expressive treatment; kept calm and removed the trial code
  (OP-07).
- **Fixed** the pre-existing large-text defects (OP-04):
  - a route-gap sweep found an overflow on `/profile/edit/interests`;
  - glass highlight (OP-05);
  - mascot (OP-06).
- **Results:**
  - 312 passed, 14 skipped;
  - 20 capture tests passed;
  - 157 goldens with real changes kept (3 new); 34 renderer-only diffs restored.
- **Left:**
  - commit and push (needs authorisation);
  - the APK and device pass on Windows;
  - re-rendering the goldens on the baseline machine.

Newest first. One entry per session: date, who, what changed, commits, what was left.

## 2026-11-04: frosted-navigation experiment (worktree, uncommitted)
- **Isolated:** the main checkout had uncommitted header-spacing work, so I created the worktree
  `..\numaya-frosted-navigation` on the new branch `experiment/numaya-frosted-navigation` from
  `eb0b37b`.
- **Baseline A:** 292 passed, 11 skipped; analyze clean. Captured on the Pixel 10 emulator at
  390dp and 320dp.
- **Stage B:**
  - `AppTypography.chip` (Figtree 14/18 medium, ink) for `InfoChip` and Profile chips; chips grow
    instead of truncating;
  - `Wordmark(maxWidth:)`, so Discover shows the mark alone at 320dp.
- **Stage C:**
  - `NumayaTabBar(surface: frosted)` with a built-in `BackdropFilter` and `MonoGlass` tokens;
  - `HomeShell` `extendBody`; `TabPage` and Profile bottom padding;
  - idle icons `text2` on glass;
  - a system-inset strip (added after an emulator three-button check);
  - High Contrast falls back to opaque.
- **Tests:**
  - 10 new tests in `frosted_navigation_experiment_test.dart`;
  - 1 opt-in golden `fn01-glass-backgrounds`;
  - 302 passed, 12 skipped;
  - goldens regenerated.
- **Tools:**
  - Apple HIG, Liquid Glass Widgets and Mobbin search skills installed (project, in the worktree);
  - `liquid_glass_widgets` package not adopted.
- **Not committed or pushed.**

## 2026-11-04: universal APK and system bars
- **Verified:**
  - `85f46d1` clean;
  - SDKs 24 / 36 / 36; both Android plugins declare `minSdk` 24;
  - no ABI filters or `<uses-feature>` entries.
- **System bars:**
  - edge to edge on all versions, with transparent bars and dark icons (`AppSystemUi`);
  - themes per API level (`values`, `-v26`, `-v27`, `-v29`), canvas window and splash background;
  - removed the black `values-night` themes;
  - replaced `SystemUiOverlayStyle.dark`, which made the navigation bar black.
- **Found on device:** under three-button navigation, the sheet bottoms sat under the system
  buttons. Fixed and covered by tests.
- **Built:** universal debug APK, copied to `C:\Users\biswa\Desktop\Numaya\Numaya-final-debug.apk` (checksums match).
- **Tested:** Pixel 10 emulator, API 36, gesture and three-button navigation.
- **Left:** physical-phone test (Samsung, Android 12).

## 2026-11-04: final UX polish (same account, Claude Code desktop)
- **Verified:**
  - branch `experiment/numaya-final-ux-polish` at `93d5ce7`, clean, tracking `origin`;
  - baseline `flutter test` on Windows: 266 passed, 11 skipped.
- **Implemented**, see `docs/design-experiments/numaya-final-ux-polish/`:
  - semantic `AccentTone` colours;
  - `IconTile` in `ListRow`;
  - inset list dividers;
  - Account Health status tiles;
  - Settings tiles on every row;
  - Discover swipe stamp, plus cancel, fling-back and double-decision fixes;
  - the single-photo Match;
  - `AppRadii.nested`, the concentric tab indicator and the RSVP bar corner;
  - four copy fixes;
  - named illustration slot ratios.
- **Tests:**
  - added `test/widget/final_polish_test.dart` (22);
  - added `/match/amara` to the route matrix;
  - fixed a 320pt / 200% overflow that the matrix caught.
- **Goldens:** all 187 regenerated after review. They are now Windows renders (FP-14).
- **Docs:** polish README, DECISIONS, VISUAL_REVIEW_REPORT and ILLUSTRATION_ASSET_BACKLOG.
  TOKENS, COMPONENT_RULES, LAYOUT_GUIDELINES, NAVIGATION_SPEC and `contrast_check.py` updated.
- **Built and smoke-tested:** debug APK on the Pixel 10 emulator. Real swipes work.
- **Left:**
  - owner review;
  - web checks blocked by CRLF and the missing Playwright browser;
  - physical-device pass.

## 2026-11-04: handoff setup (new Claude account, Claude Code desktop)
- **Verified:**
  - the repo, the remote and `gh` admin auth;
  - Mobbin MCP;
  - the 34 skills;
  - the toolchain (`flutter doctor -v`).
- **Branches:**
  - Created a local `experiment/numaya-monochrome-premium-refinement` tracking `origin`, at
    `e70135c`.
  - Created `experiment/numaya-final-ux-polish` from it.
  - Left `experiment/numaya-android12-compat` (`e5184e1`) unchanged.
- **Added:** `docs/agent-handoff/` (this folder), plus the handoff protocol in `CLAUDE.md`.
- **Android:** the SDK is healthy. adb isn't on `PATH`, and that is harmless. No system changes
  were made.
- **No product code changed.**
- **Left:** the owner to confirm the scope of the final UX polish ([ACTIVE_TASK.md](ACTIVE_TASK.md)).

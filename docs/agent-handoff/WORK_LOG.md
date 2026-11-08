# Work log

## 2026-11-08 · Events MVP + approved visual refinements (Windows, Claude desktop)
- Branch `experiment/numaya-events-selected-ui-20261108-1629` from the selections branch; WIP checkpoint `bdaa659` pushed.
- Events MVP module `lib/features/events_mvp/` (domain, clock-injected controller, E01–E08, S01,
  M01/M02, H01–H04 demo role); `DatingController.connectFromEvent` reuses chats, never reopens
  archived ones; five-tab shell; Health/Insights/visibility deleted with a Profile fallback.
- Owner's Visual Lab selections applied (match ring A 3:4, no likes tile, Compliment O card + pills,
  like tile A, header A, setup D, prompt O, photo O concentric radii, 55% scrim at AA).
- Tests: 2 new Events files; 30+ tests updated for five tabs and selections; superseded tests
  skipped with reasons. `ebf3623`.
- Emulator journey `integration_test/events_review_test.dart` (34 captures; first run spoiled by a
  System UI ANR dialog, harness now taps Wait). APK built and installed. `6a12b91`.
- Docs: `docs/product/events-mvp/` (checklist, limitations, D4 audit, references).

## 2026-11-08 · Selections pass (Windows, Claude desktop)
- Validated the owner's JSON: valid but empty (0 selections). Nothing applied; asked the owner.
- Tag `checkpoint/visual-lab-v2-20261108` at `ae78935`; branch `experiment/numaya-visual-lab-selections-20261108`.
- Backend: archive lifecycle in `0001`/`0002`, CONTRACTS.md and README; reconnect removed from `NumayaApi`.
- Harness: Heart directions captured as Premium; gallery rebuilt; empty-export confirmation added.

## 2026-11-08 · Visual Lab V2 (Windows, Claude desktop)
- Verified start: `experiment/numaya-mvp-prd-20261107` clean at `0df9ec3` = origin; tagged and pushed
  `checkpoint/pre-visual-lab-20261108`; branch `experiment/numaya-visual-lab-20261108`.
- Read START_HERE and 01–11. Figma (Ente) read live: Header v2, Tabs, Bottom sheet, Segments, Banners,
  Icon Button. Mobbin: 6 targeted searches (requests inbox, insights, own profile, Bumble chats).
- R01–R12 implemented (lifecycle rewrite to archive; Heart tab; Your insights fixtures; shared squircle,
  segmented control, NameWithBadge, LargeTitlePage, motion presets). Registry + Visual Lab + previews.
- 15 card families × 5 variants, 5 screens × 4 directions. Two screenshot refinement loops (CRITIQUE.md).
- Capture harness and gallery builder (`tool/capture_visual_lab.sh`, `tool/visual_lab_gallery/`).
- Commits: `d15b9d0` (WIP), `9d4ed30` (loop 1), `8510778` (loop 2, final code), then docs.

## 2026-11-07 · MVP PRD v1 implementation (Windows, Claude desktop)
- Verified start: `experiment/numaya-15px-icons-20261107` clean at `c56e36b`, equal to origin. Tagged
  `checkpoint/pre-mvp-prd-20261107`; new branch `experiment/numaya-mvp-prd-20261107`.
- Read every document of `NUMAYA_PRD_IMPLEMENTATION_V1.zip` (copied to `docs/product/mvp-prd-v1/source/`).
- Figma live (Ente file, sheets `4809:8074`, banners `14590:125265`) and Mobbin references (LinkedIn
  note, Bumble match, WHOOP/Cal AI streak, Cal AI/Flo/Locket/Hinge paywalls). Figma plugin MCP needs
  `/mcp` sign-in; the claude.ai Figma connector worked.
- Rules (pure Dart, clock-injected): IST calendar, catalog, credit ledger, like quota, extensions,
  match lifecycle, Compliments, streak, Profile Health. Controllers: economy, compliments; dating
  controller extended (quota, conversion, lifecycle, reconnect, mute, check-in, spam guard).
- Screens: S14 composer, S17 allowance, S21 request, S23 check-in, S24 expired, S25 reconnect,
  S29-S33 health/insights/streak/wallet, S34-S37 commerce, S43 support requests, S45 legal; changed
  Discover, Likes, Chats, chat, Profile hub, Settings, Welcome links, onboarding (bio required,
  interests optional, welcome credits), notification categories.
- Backend contracts: `backend/` (schema + RLS, transactional functions, endpoint contracts, pgTAP
  denial tests), `lib/app/backend/numaya_api.dart` (unconfigured live API).
- 12 Tabler 3.50.0 SVGs added (official files, synced with the tool).
- Tests: 564 passed, 21 skipped, 0 failed (from 507); new `mvp_rules_test`, `mvp_controllers_test`,
  `mvp_screens_test`. Superseded expectations updated (bio Skip, rematch, free Likes grid, UI-033 timer).

## 2026-11-07 · Account-switch handoff (Windows, Claude desktop)
- Owner approved the X15 15px typography and icon experiment as the working design baseline (H-08).
- Verified: branch `experiment/numaya-15px-icons-20261107` at `4d713e3`, level with origin, clean;
  no stashes; local-only files are the reference photos, the installed demo set and Flutter-generated files.
- Reset the clone's fetch refspec to all branches (H-10).
- Wrote `NUMAYA_ACCOUNT_HANDOFF.md` and refreshed START_HERE, HANDOFF_PROMPT, DECISIONS, NEXT_STEPS,
  TOOLS_SKILLS_AND_INTEGRATIONS, CURRENT_STATE, ACTIVE_TASK and VALIDATION. No app code changed.

## 2026-11-07 · 15px type and icon experiment X15 (Windows, Claude desktop)
- New branch `experiment/numaya-15px-icons-20261107` from `7eae060` (clean, on origin).
- Re-read Ente Header v2 (`11439:5040`) live for the app-bar title size.
- 14 → 15 for body, bodySm, row, input, buttons, label, helper, fieldLabel, metricUnit (line 20 kept; multi-line input `22 / 15`).
- New `appBarTitle` (PJS 20/28 700) for the top bar and chat header; page titles 700; buttons 600.
- Icons: stroke 1.5 (≤24pt) / 1.25 (>24pt); `iconSupporting` #8A8A8A for row icons and chevrons; chip glyph one size (16); Settings Version, Sign out (`logout`, synced from `@tabler/icons@3.50.0`) and Delete account icon rows.
- Seven tests updated to the experiment's values; device before/after at 1.0, 1.3 and 320dp in `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\15px icon experiment 2026-11-07`.

## 2026-11-07 · Switch off state #D6D6D6 (SW-01)
- Owner direction: enabled off track #D6D6D6, no border or stroke; keep the white thumb and the on state.
- New `MonoColors.switchOff`; `AppColors.switchOff` points at it; `switchOffEdge` and the switch border removed (knob inset back to 2pt padding). `NumayaSwitch` is the only switch and `ListRow` its only consumer (Settings visibility, notifications, privacy and app rows; Filters sheet; Design Lab), so there were no per-screen overrides to remove.
- Measured: 1.45:1 on white, 1.32:1 on #F4F4F4, 1.21:1 on #EAEAEA, 3.37:1 against the brand on-track. Flagged, not compensated.
- Tests `component_cleanup_test` and `discover_match_review_test` now pin the colour, no border, and the measured ratios. Device before/after and a harness render on the grey page in `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Switch off D6D6D6 2026-11-07`.

## 2026-11-07 · Local demo photos (Windows, Claude desktop)
- Populated the demo UI with the owner's local reference photos (`tarini pics`, 13 portrait JPEGs of one person): 5 chosen as portraits (main photo, avatar, thumbnail), 8 as gallery scenes; the one with burned-in text is last in the rotation.
- New `tool/install_demo_photos.py` (copies originals unchanged as `photo_NN.jpg`, writes square face crops and `demo_photos.json`) and `lib/core/media/demo_photos.dart` (`DemoPhotoLibrary`).
- `SamplePerson.photoAt` / `avatarPhoto` fall back to the set by a fixed per-person index; cover crops anchor on the recorded face (`localImageFocus`).
- Avatars (`InitialsAvatar`, `CountdownAvatar`), `PersonTile`, `GridPhoto`, the photo viewer and For you thumbnails gained photo support; initials and grey placeholders remain the fallback.
- Git: `/tarini pics/` and `apps/numaya_mobile/assets/demo/photos/*` (except README) are ignored. New `test/unit/demo_photos_test.dart` (4).

## 2026-11-07 · Figma type and icons pass (Windows, Claude desktop)
- Ran `NUMAYA_FIGMA_TYPE_ICONS.zip` phases 01–04 on the new branch `experiment/numaya-figma-type-icons-20261107`, from `b518a4a` (clean, on origin).
- Figma read live through the connector: Text styles, Menu Item, Toggle Switch, Icon, Buttons, Text Input, Header v2, chips, Banners, Badges, Bottom sheet, Settings and empty-state screens. Node map in `docs/design-experiments/ente-design-system/figma-type-icons/README.md`.
- **FT-01** even font sizes and Ente weights (caption 12/16, new helper 14/20, buttons 500).
- **FT-02** text colour roles (#000 / #666; `iconStrong`).
- **FT-03** Tabler outline stroke classes via `TablerOutlineLoader`.
- **FT-04** light off-switch track with a 3:1 edge.
- New `test/widget/figma_type_icons_test.dart` (13 guards, including a lib/ scan for odd font sizes); 5 older tests moved to the new rules.
- Device: 16 before and 16 after captures on the Pixel 10 AVD, 8 more after-only sweep screens, 12 compare boards, harness switch pairs and icon board, updated typography HTML, in `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Figma type and icons 2026-11-07`.

## 2026-11-07 · UI consistency pass (Windows, Claude desktop)
- Ran `NUMAYA_FINAL_UI_CONSISTENCY.zip` phases 00–05 on the new branch `experiment/numaya-ui-consistency-20261107`, from `f6614fa`. The interrupted run's edits were committed first as `b0194d4`.
- Figma MCP needs authorisation, so recorded Figma maps were used and the unverified values are labelled.
- **UC-01:** switch off track.
- **UC-02:** `HeaderActions`.
- **UC-03:** stadium nav.
- **UC-04:** tab-header height.
- **UC-05:** chat header.
- **UC-06:** country dial-code role.
- **UC-07:** status pill inset.
- New `test/widget/ui_consistency_test.dart`; 6 older tests moved to the new rules.
- Device: 18 before and 18 after captures, plus 7 compare boards, in `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\UI consistency 2026-11-07`.

## 2026-11-07 · Device screenshot review (Windows, Claude desktop)
- Verified branch `experiment/numaya-typography-copy-20261106` at `f6614fa` (also on `origin`). Rewrote CURRENT_STATE: a verified current block for the Tabler MVP and typography passes, with the older entries moved under History.
- Added a `final` set to `integration_test/ui_review_capture_test.dart`. Its harness run was interrupted, and its 10 partial PNGs sit at the root of the Desktop folder.
- Reset the Pixel 10 emulator's `wm density` override (443 → default 420).
- Built the debug APK at `f6614fa` and installed it with `-r`; no signing conflict. Drove the app by hand over adb: 29 screencap/pull PNGs at 1080×2424 in `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Device review 2026-11-07` (INDEX.md).
- Not reached: the onboarding steps after Photos (they need two photos).
- Uncommitted: CURRENT_STATE, this log, ACTIVE_TASK, VALIDATION, the capture harness.

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

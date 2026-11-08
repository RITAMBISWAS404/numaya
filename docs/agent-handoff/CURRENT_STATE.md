# Current state

> **Ente Alignment Lab V3 (2026-11-08):** branch **`experiment/numaya-ente-alignment-lab-20261108-1829`** from `a000ff3` (tag `checkpoint/pre-ente-alignment-20261108-1829`). App code `ba3a6fc`. Shared fixes: equal-width action groups, critical confirm sheets, sheet radius 20, picker ticks, owner semantic anchors #EB2D2F/#FF9B0F/#0D9F61 with derived roles. Four Events layout groups (`ea-*`) await selection; default stays O. Gallery `C:\Users\biswa\OneDrive\Desktop\Numaya Ente Alignment Review\2026-11-08 1909\index.html` (review `ea3-ba3a6fc-2026-11-08`); APK `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Ente-Alignment-Lab-20261108-ba3a6fc.apk`. Record: [`docs/design/ente-alignment/`](../design/ente-alignment/REQUIREMENTS.md). Not merged.

> **Events MVP + selected UI (2026-11-08):** branch **`experiment/numaya-events-selected-ui-20261108-1629`** (WIP checkpoint `bdaa659`; app code
> `ebf3623`, capture tooling `6a12b91`, handoff on top). Implements the owner's
> `NUMAYA_EVENTS_COFOUNDER_PRD.md` as a labelled frontend demo: five tabs (Discover / Likes / Chats /
> Events / Profile), E01–E08, S01, M01/M02 (pending O1), internal demo-role H01–H04 at `/staff`;
> Health and Insights removed (old links land on Profile with a note); the owner's Visual Lab
> selections applied (`lab_registry.dart` `proposed`). Record: [`docs/product/events-mvp/`](../product/events-mvp/README.md).
> APK `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Events-Selected-UI-20261108-6a12b91.apk` (SHA-256 `dab6b1c2680e44075917bc759e6aa972427ff2dea19abc105b730505bc430d93`; private photos, never publish). Review: `C:\Users\biswa\OneDrive\Desktop\Numaya Events Review\2026-11-08 1720\index.html` (34 emulator captures).
> O1, O2 and D1–D7 stay open (LIMITATIONS.md). Not merged anywhere.

> **Selections pass (2026-11-08):** branch **`experiment/numaya-visual-lab-selections-20261108`** from
> `ae78935` (Visual Lab V2 delivered; tag `checkpoint/visual-lab-v2-20261108`, pushed). The owner's
> export `numaya-visual-lab-choices-vl2-8510778-2026-11-08.json` validated (review ID and commit match,
> IDs valid) but holds **0 selections** (21 groups undecided), so no design was changed. Done here:
> backend contracts moved to 7-day archiving with no reconnection/check-in; Heart directions recaptured
> as Premium; gallery export now warns before exporting an empty file. Updated gallery:
> `C:\Users\biswa\OneDrive\Desktop\Numaya Visual Lab\2026-11-08 Premium Likes update\index.html` (review `vl2-010fe8f-2026-11-08`). The APK from `8510778` is unchanged in UI and still current.

> **Backup checkpoint (2026-11-08):** branch `experiment/numaya-visual-lab-20261108` pushed and verified;
> baseline tag `checkpoint/pre-visual-lab-20261108` pushed. Moving machines: follow
> [NEW_MACHINE_SETUP.md](NEW_MACHINE_SETUP.md). **Private reference photos moved:** the originals and
> `numaya_demo_photos.json` are now in `<repo>\pics\` (git-ignored); `tarini pics\` is empty. They, the
> APKs and the screenshot galleries (all of which show those photos) are **not** on GitHub (public repo)
> and need a separate private backup. Visual Lab V2 is complete; the next action is the owner's gallery
> selection (ACTIVE_TASK).

> **Visual Lab V2 (2026-11-08):** branch **`experiment/numaya-visual-lab-20261108`** from `0df9ec3`
> (MVP PRD v1 head; tag `checkpoint/pre-visual-lab-20261108`, pushed). App code for screenshots, clips
> and APK: **`8510778`**; later commits are docs only. Implements the owner's `NUMAYA_VISUAL_LAB_V2`
> brief: required changes R01–R12 (Archive replaces expiry/reconnection; ring avatars; Heart tab with
> Likes and Compliments; no likes-left line; Compliment squircle bottom-right with prompt footers;
> badge after names; sentence case; squircle sheet close; illustration boxes; Your insights with labelled
> samples; collapsing large titles), 15 card families with O + A–D, 5 screens with O + three directions,
> MotionTokens M0/M1/M2, and a debug **Visual Lab V2** (Demo Hub). Proposed defaults are not owner
> approvals. Record: [`docs/design-experiments/visual-lab-v2/`](../design-experiments/visual-lab-v2/README.md).
> APK `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Visual-Lab-20261108-8510778.apk`; gallery `C:\Users\biswa\OneDrive\Desktop\Numaya Visual Lab\2026-11-08\index.html`; ZIP `C:\Users\biswa\OneDrive\Desktop\Numaya Visual Lab\Numaya-Visual-Lab-20261108-8510778.zip`.

> **MVP PRD v1 implementation (2026-11-07):** branch **`experiment/numaya-mvp-prd-20261107`**, cut from
> `c56e36b` (checkpoint tag `checkpoint/pre-mvp-prd-20261107`; the working tree was clean, so no
> checkpoint commit was needed). Implements the owner's `NUMAYA_PRD_IMPLEMENTATION_V1` package as a
> deterministic **demo**: like allowance (5/15 a day, IST), Compliments and Requests, match lifecycle
> (24 h, one extension, 7-day check-in, 14-day expiry, free reconnection), credit ledger, streak with
> paid recovery, Profile Health v1, Insights, provisional INR commerce with a demo store, legal and
> support screens, text-only chat. Backend is contracts only (`backend/`). Record:
> [`docs/product/mvp-prd-v1/`](../product/mvp-prd-v1/TRACEABILITY.md) (traceability, decisions,
> live blockers, report). Design baseline unchanged (X15, purple, Tabler).

> **Account switch, 2026-11-07 (Windows, `C:\Users\biswa\Projects\Numaya`):** working branch
> **`experiment/numaya-15px-icons-20261107`**, level with origin. **The X15 15px typography and icon
> experiment (`4d713e3`) is approved as the working design baseline** (H-08); the handoff commit sits
> on top of it with no app-code change. Full transfer notes: [`NUMAYA_ACCOUNT_HANDOFF.md`](../../NUMAYA_ACCOUNT_HANDOFF.md).
> Next task: the owner's feature brief, then a revised PRD.


> **15px type and icon experiment X15 (2026-11-07), awaiting owner approval, not integrated:** branch
> `experiment/numaya-15px-icons-20261107`, started from `7eae060` (the approved working line is still
> `experiment/numaya-figma-type-icons-20261107`; switch back to it to revert).
> - Every 14pt text role is 15 (line height kept at 20); app-bar titles use a new `appBarTitle`
>   (Plus Jakarta Sans 20/28 700); page titles 700; buttons 15/600.
> - Tabler outline stroke 1.5 up to 24pt, 1.25 above; row icons and chevrons `iconSupporting` #8A8A8A;
>   Settings gains Version, Sign out (new `logout`) and Delete account icon rows.
> - Tests 507 passed, 21 skipped. Record: `docs/design-experiments/ente-design-system/x15-type-icons/README.md`. Before/after: `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\15px icon experiment 2026-11-07`.


> **Switch off state SW-01 (2026-11-07, owner decision):** the enabled off track is solid #D6D6D6
> (`MonoColors.switchOff` → `AppColors.switchOff`) with no border or stroke; white thumb, on state,
> 45% disabled opacity and the row's focus ring and toggled semantics unchanged. Supersedes FT-04's
> #EAEAEA track with a #8A8A8A edge (`switchOffEdge` removed). **Contrast flag for owner review:**
> #D6D6D6 is 1.45:1 on a white card (and against the white thumb) and 1.32:1 on the #F4F4F4 page,
> under the 3:1 non-text target; no border was added. Before/after: `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Switch off D6D6D6 2026-11-07`.


> **Demo photos (2026-11-07, Windows):** on `experiment/numaya-figma-type-icons-20261107`, the local demo photo set. Real reference photos (one person, 13 JPEGs) now fill every demo
> photo surface: Discover cards and galleries, the photo viewer, Likes tiles, new-match tiles,
> conversation and chat-header avatars, the match screen, For you thumbnails, Alex's own profile,
> Edit profile and onboarding photo grids.
> - **The photos are local only, never in git.** Originals: `<repo>/tarini pics/` (git-ignored).
>   Bundled copies: `apps/numaya_mobile/assets/demo/photos/` (git-ignored except its README).
> - **To resume on another account or machine:** copy the `tarini pics` folder (it holds the
>   photos and `numaya_demo_photos.json`, the local spec of each photo's role and face position)
>   into the repo root, then from `apps/numaya_mobile` run
>   `python tool/install_demo_photos.py "../../tarini pics"` and rebuild. Without a set the app
>   shows its grey placeholders, as before, and every test still passes.
> - Code: `lib/core/media/demo_photos.dart` (`DemoPhotoLibrary`, loaded in `main.dart`);
>   `SamplePerson.photoAt` falls back to it deterministically (`demoPhotoIndex`), so a person keeps
>   the same main photo and gallery on every screen; face crops (`face_NN.jpg`) for circles.


> **Figma type and icons pass (2026-11-07, Windows):** branch `experiment/numaya-figma-type-icons-20261107`
> from `b518a4a` (the UI consistency pass). Figma was read live this time (Ente copy `22AeTw6QiPj2fNYHLhC7MK`).
> - **FT-01:** even font sizes only. The 13/18 caption is now Ente Mini 12/16; sentences moved to a new
>   14/20 `helper` role; buttons are Ente Body 500 (was 600); wordmark 28/22; emoji 16/18; computed sizes
>   go through `AppTypography.even`.
> - **FT-02:** text colours: primary #000, secondary/metadata #666 (`textSecondary` was #1A1A1A); new
>   `iconStrong` #1A1A1A for the selected tab and bar icons.
> - **FT-03:** Tabler outline stroke by size class (1.0 under 18pt, 1.5 at 18–24pt, 1.0 over 24pt),
>   applied centrally by `TablerOutlineLoader`; assets and filled assignments unchanged.
> - **FT-04:** off switch track #EAEAEA (`fill`) with a 1pt #8A8A8A edge (was solid #8A8A8A).
>
> Tests: 507 passed, 21 skipped. Record: `docs/design-experiments/ente-design-system/figma-type-icons/README.md`. Device before/after: `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Figma type and icons 2026-11-07`.


> **UI consistency pass (2026-11-07, Windows):** branch `experiment/numaya-ui-consistency-20261107`
> from `f6614fa`. `b0194d4` preserves the interrupted screenshot run's handoff edits; the pass
> follows it.
> - **UC-01:** Ente's solid grey switch off track (#8A8A8A).
> - **UC-02:** a shared `HeaderActions` group (8pt between header tiles).
> - **UC-03:** a stadium bottom nav (8 inside the bar, 4 inside each item, 48pt targets).
> - **UC-04 and UC-05:** one tab-header height, and the chat header on the top-bar line.
> - **UC-06 and UC-07:** the type and inset one-offs.
>
> Tests: 489 passed, 21 skipped. Record: `docs/design-experiments/ente-design-system/ui-consistency/`.
> Device before/after: `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\UI consistency 2026-11-07`.
> Figma was not re-read live (the connector needs authorisation).


**Last verified:** 2026-11-07, on the owner's Windows 11 machine (Claude desktop session).

## Git
| Item | Value |
|---|---|
| Repository | `RITAMBISWAS404/numaya` (`origin`, HTTPS) |
| Permanent checkout | `C:\Users\biswa\Projects\Numaya` (the only worktree on this machine) |
| Branch | `experiment/numaya-typography-copy-20261106`, on `origin` |
| HEAD at session start | `f6614fa009de56b771926c5b29ba4140d6fafb7f` "Typography and copy pass: docs and before/after evidence"; the 2026-11-07 handoff and capture-tool commit sits on top (see WORK_LOG) |
| Lineage | V4 `ea86a08` (on `origin`) → Tabler MVP `deda6dd`, `4cfb405`, `9f61314` → typography code `332c2b4` → docs and boards `f6614fa` |
| Tabler branch | `experiment/numaya-tabler-mvp-20261106-1725` is **not on `origin` and not on this machine**; its three commits are contained in this branch |
| Working tree | Clean at the start of the 2026-11-07 session |

## What is built (checked against the commits and their records)
- **Flutter app** `apps/numaya_mobile/`: the Ente design system with Numaya purple `#7262C7`, Figtree text and Plus Jakarta Sans headings, with the V3 experiments and V4 polish.
- **Tabler MVP** ([record](../design-experiments/ente-design-system/tabler-mvp/README.md)):
  - TB-01 Tabler Icons 3.50.0 as bundled SVGs (Lucide removed);
  - TB-02 Ente-style tab bar: a filled near-black glyph on a light tile when selected, grey outlines otherwise;
  - TB-03 filled alert glyphs centred on the full content height (supersedes UI-010);
  - TB-04 Events gated off (`--dart-define=NUMAYA_EVENTS=true` re-enables it);
  - TB-05 tab gaps shrink at 320pt.
  - Linux harness and tests only: 473 passed, 21 skipped. No device evidence in that pass.
- **Typography and copy pass** ([record](../design-experiments/ente-design-system/typography-copy/README.md)):
  - TC-01 section headings 18/24, TC-02 semibold button labels, TC-03 caption 13/18 and eyebrow tracking;
  - TC-04 two-line top-bar titles, TC-05 visibility score badge below the score, TC-06 Birthday sub-labels;
  - TC-07 `PhotoScrim` on photo identities; TC-08 16 copy edits in `app_en.arb`.
  - Linux: 484 passed, 21 skipped; `npm run check` OK; `npm run test:e2e` 143/144 (one Chromium-version-dependent squircle count). No APK or device run in that pass.
- **Waiting on the owner:** EXP-001 to EXP-004 choices (every Current/A/B/C variant kept, none selected); final Welcome artwork (UI-001); the UI-008 phrase.
- **Device status (2026-11-07):** the f6614fa debug APK runs on the Pixel 10 emulator; 29 device screenshots of the major screens are in `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\Device review 2026-11-07` with `INDEX.md`. Awaiting the owner's visual review. Physical phone, TalkBack speech and iOS: not verified.

## Environment (this machine)
| Tool | State |
|---|---|
| Flutter / Dart | 3.47.8 stable / 3.13.7 at `C:\src\flutter`, on `PATH`; matches `pubspec.yaml` (`sdk: ^3.13.7`) |
| Android SDK | `C:\Users\biswa\AppData\Local\Android\sdk`. Flutter finds it without `ANDROID_HOME`. Platforms 36, 36.1, 37.0; build-tools 36.0.0; NDK 28.2.13676358; licences accepted |
| JDK | Android Studio's bundled JBR (OpenJDK 25.0.3) |
| Emulators | `Pixel_8`, `Pixel_9`, `Pixel_9_2`, `Pixel_10` are listed, but **only `Pixel_10` has its system image** (android-36.1). Boot `Pixel_10` with `-gpu swiftshader_indirect` if it is not running. On 2026-11-07 it was already running as `emulator-5554` (API 36, 1080×2424). The leftover `wm density 443` override from earlier 390dp passes was reset to the default 420 on 2026-11-07 |
| adb | 1.0.41 in `sdk\platform-tools`, **not on `PATH`**. Call it by full path, or use `flutter devices` |
| Node / npm | Node 24.20.0; `node_modules` installed. `npm run check` fails here only on CRLF line endings (`core.autocrlf=true`); the Playwright browser is not installed |
| Visual Studio | Not installed. Only needed for Windows desktop builds; irrelevant here |
| Shells | PowerShell 5.1 and Git Bash |

## Connected tools
| Tool | State |
|---|---|
| GitHub (`gh`) | Signed in as `RITAMBISWAS404`; admin on the repo; scopes `repo`, `workflow` |
| Mobbin MCP | Working (test search returned results) |
| Figma MCP | Needs authorisation via `/mcp` |
| dossier, pencil, magic MCP | Failed to connect on 2026-11-04; not needed |

## Skills
34 project skills in `.claude/skills/`:
- **Design:** impeccable, emil-design-eng, apple-design, ui-ux-pro-max, design, design-system,
  design-system-structure, brand, ui-styling, liquid-glass, break-ui, design-review-workflow.
- **Motion:** animate, review-animations, improve-animations, find-animation-opportunities,
  animation-performance, animation-vocabulary, motion-and-haptics.
- **Flutter:** flutter-conventions-index, widget-composition, state-management-riverpod,
  navigation-and-routing, adaptive-layout, accessibility-as-code, forms-and-input,
  ui-states-and-feedback, async-safety, flutter-performance, testing-strategy,
  widget-golden-and-a11y-testing, dependency-hygiene.

---

## History (superseded; kept for reference)
These entries describe earlier worktrees and branches, several in cloud containers or under `C:\Users\biswa\Downloads\numaya\`. They are not the current state.

> **Overnight v4 (2026-11-06, cloud/Linux, local commits only):** branch
> `experiment/numaya-ente-polish-v4-20261106-0724` (worktree `/home/user/numaya-ente-v4`) from the V3
> candidate `fc72906`. Fixed and verified in the harness: V4-01 missing-photo fallback (Profile,
> EXP-002, attachment viewer), V4-02 whole-word ListRow labels at 320pt/200% (Settings,
> Notifications, Edit profile, The basics), V4-03 EXP-001 A/B chips, V4-04 EXP-002 A cover,
> V4-05 gallery status text. Tests: 452 passed, 21 skipped. Records:
> `docs/design-experiments/ente-design-system/overnight-v4/`; gallery
> `artifacts/ente-design-system/overnight-v4/gallery/index.html`. **Next:** your V3 choices and the
> device checklist.


> **Overnight v3 (2026-11-06, cloud/Linux, committed locally, not pushed):** checkpoint
> `e60504e` "checkpoint: Ente design system before V3 experiments" (annotated tag
> `numaya-ente-design-system-finalized-20261106-0624`) in `/home/user/numaya-ente`; work on branch
> `experiment/numaya-ente-delight-v3-20261106-0624` in worktree `/home/user/numaya-ente-v3`.
> Baseline corrections V3-D01 (Unmatch/Block sheets pinned action at 320pt/200%), V3-D02
> (EmptyState inset at large text), V3-F01 (tappable banner arrow). Four experiments, each with
> Current/A/B/C behind the debug Experiment Lab: EXP-001 match, EXP-002 own-profile header, EXP-003
> empty conversations, EXP-004 completion card; purple-cat slot with three provisional poses.
> **Choices pending** (recommended: 001 A, 002 Current, 003 A, 004 A). Tests: 443 passed, 20 skipped.
> Records: `docs/design-experiments/ente-design-system/overnight-v3/`; gallery
> `artifacts/ente-design-system/overnight-v3/gallery/index.html`. **Next:** your choices, then a
> device pass (sheets, keyboard, TalkBack, lab clipboard) and golden regeneration.


> **Latest (2026-11-06): review batch 2.** Worktree `..\numaya-ente`, branch
> `experiment/numaya-ente-design-system`, HEAD `f2e18e6` plus **uncommitted** work: Ente, batch 1
> and batch 2.
> - Tracker: `docs/design-experiments/ente-design-system/UI_REVIEW_BATCH2_TRACKER.md`.
> - Export: `artifacts/ente-design-system/patches/ui-review-batch2.patch`, which applies to
>   `f2e18e6`.


> **Latest (2026-11-05): UI review handoff.** This is implemented on the Ente worktree
> `..\numaya-ente`, branch `experiment/numaya-ente-design-system`, HEAD `f2e18e6` plus
> **uncommitted** changes.
> - Status: UI-001 to UI-012 are implemented. Two items are open:
>   - UI-001 final artwork is blocked;
>   - the UI-008 phrase "three-day-to-time-driven response" is awaiting clarification.
> - Status register: `docs/design-experiments/ente-design-system/UI_REVIEW_HANDOFF_STATUS.md`.
> - Export: `artifacts/ente-design-system/patches/ui-review-handoff.patch`, which applies to `f2e18e6`.


> **Latest (2026-11-05):** Ente experiment in `C:\Users\biswa\Downloads\numaya\numaya-ente`,
> branch `experiment/numaya-ente-design-system`, HEAD `f2e18e6` plus **uncommitted** changes (the
> final-design-run patch and the Ente work). Export:
> `artifacts/ente-design-system/patches/ente-design-system.patch`.

> **Latest (2026-11-05):**
> - Worktree `C:\Users\biswa\Downloads\numaya\numaya-final-design`, branch
>   `experiment/numaya-final-design-candidate`, HEAD `f2e18e6` plus **uncommitted** final-design-run
>   changes. Export: `artifacts/final-design-run/patches/final-design-run.patch`.
> - GitHub has `experiment/numaya-overnight-polish` at `f2e18e6` (this run's base).
> - Backend: none (demo and in-memory repositories).

> **Final QA (2026-11-04), cloud:** the same worktree, branch and HEAD as the overnight entry below
> (`/home/user/numaya-overnight`, `experiment/numaya-overnight-polish`, `6b23c85`). Two more
> fixes; **local only, not on GitHub**. See
> [FINAL_QA.md](../design-experiments/overnight-polish/FINAL_QA.md).

> **Overnight polish (2026-11-03 UTC), cloud.** The worktree is `/home/user/numaya-overnight` on the
> local branch `experiment/numaya-overnight-polish`, at HEAD `6b23c85` (`wip/frosted-navigation-handoff`, verified
> live on GitHub).
> - **Local changes, uncommitted:** the 14/20 body, the large-text fixes, the glass highlight and
>   the mascot.
> - **Not on GitHub** until the owner authorises a push.
> - **Record:** [overnight-polish](../design-experiments/overnight-polish/README.md).
> - **Elsewhere in the same container:** another checkout, `/home/user/numaya`
>   (`experiment/impeccable-visual-refinement`, `6e4dbd1`), holds 14 uncommitted Impeccable web
>   files. They are unrelated and were left untouched.

> **Frosted-navigation experiment (2026-11-04).** Worktree
> `C:\Users\biswa\Downloads\numaya\numaya-frosted-navigation` on branch
> `experiment/numaya-frosted-navigation`, from `eb0b37b`, **uncommitted**.
> - Stage B: chip type role and compact Discover wordmark.
> - Stage C: frosted tab bar.
> - Report: `docs/design-experiments/frosted-navigation/README.md`.
> - Main checkout: `C:\Users\biswa\Downloads\numaya\numaya` on
>   `experiment/numaya-first-ui-improvement` still holds the earlier uncommitted header-spacing
>   fix, untouched.
> - Backend: none (demo and in-memory repositories only).
> - Tools: see TOOLS_SKILLS_AND_INTEGRATIONS.md.

**Last verified:** 2026-11-04, on the owner's Windows 11 machine, after the final UX polish.

### Git
| Item | Value |
|---|---|
| Repository | `RITAMBISWAS404/numaya` (`origin`, HTTPS) |
| Local path | `C:\Users\biswa\Downloads\numaya\numaya` |
| Working branch | `experiment/numaya-final-ux-polish` (tracks `origin`) |
| Latest commit | the final-UX-polish commit on this branch (`git log -1`), on top of `93d5ce7` (handoff setup) |
| Baseline branch | `experiment/numaya-monochrome-premium-refinement` |
| Baseline commit | `e70135c` "Premium refinement: docs, contrast table, success token fix" (2026-11-03) |
| Repo default branch | `claude/pensive-newton-glyzjr` |

**Branch lineage:** `experiment/numaya-android12-compat` (`e5184e1`) is an ancestor of the
baseline, 34 commits behind it. The baseline therefore already contains the Android 12 and quality
work.

**Branches not to touch:**
- `experiment/numaya-android12-compat`: kept as it was.
- `design/apple-impeccable-full-app` (`944c532`): separate Impeccable work in progress.
- `experiment/impeccable-visual-refinement`: named in the final-polish brief, with 14 uncommitted
  files in a separate checkout. **It does not exist on GitHub, and this machine has no such
  branch or worktree** (checked 2026-11-04). If that checkout exists elsewhere, it is untouched
  and unreconciled with this branch.

### What is built
- **Flutter app:** `apps/numaya_mobile/`, in the Monochrome Premium design with the final UX
  polish:
  - Plus Jakarta Sans headings over Figtree, purple `#7262C7`, filled controls, an icon-only
    floating tab pill;
  - semantic icon tiles (`AccentTone`) and inset list dividers;
  - cancel-safe swipes;
  - a single-photo Match.
  - The record is in
    [`docs/design-experiments/numaya-final-ux-polish/`](../design-experiments/numaya-final-ux-polish/README.md).
- **Web prototype:** the repo root. The premium refinement did not touch it.
- **Design record:** [`docs/design-experiments/monochrome-meetup-premium/`](../design-experiments/monochrome-meetup-premium/README.md).
- **Latest QA:** [VISUAL_REVIEW_REPORT.md](../design-experiments/numaya-final-ux-polish/VISUAL_REVIEW_REPORT.md)
  (2026-11-04).
  - 292 tests passed, 11 skipped.
  - The 4-width × 3-text-size matrix passes, now including Match.
  - Smoke-tested on the Pixel 10 emulator; not run on a physical phone.
  - System bars: edge to edge with transparent bars on all versions (AppSystemUi, plus themes per
    API level). The universal debug APK was verified and copied to the Desktop. See
    [ANDROID_COMPATIBILITY.md](../mobile/ANDROID_COMPATIBILITY.md) and VALIDATION.md.
  - The previous report is the premium
    [VISUAL_QA_REPORT.md](../design-experiments/monochrome-meetup-premium/VISUAL_QA_REPORT.md).
- **Research and specs:** [`docs/research/`](../research/README.md).

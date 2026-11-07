# Current state

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

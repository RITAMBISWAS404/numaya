# Current state

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

## Git
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

## What is built
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

## Environment (this machine)
| Tool | State |
|---|---|
| Flutter / Dart | 3.47.8 stable / 3.13.7 at `C:\src\flutter`, on `PATH`; matches `pubspec.yaml` (`sdk: ^3.13.7`) |
| Android SDK | `C:\Users\biswa\AppData\Local\Android\sdk`. Flutter finds it without `ANDROID_HOME`. Platforms 36, 36.1, 37.0; build-tools 36.0.0; NDK 28.2.13676358; licences accepted |
| JDK | Android Studio's bundled JBR (OpenJDK 25.0.3) |
| Emulators | `Pixel_8`, `Pixel_9`, `Pixel_9_2`, `Pixel_10` are listed, but **only `Pixel_10` has its system image** (android-36.1). The others point at a missing android-36 image. Boot `Pixel_10` with `-gpu swiftshader_indirect` (the hardware GPU path stayed offline) |
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

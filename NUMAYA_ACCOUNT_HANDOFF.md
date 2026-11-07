# Numaya account handoff (2026-11-07)

Read this first in a new Claude Code conversation opened at `C:\Users\biswa\Projects\Numaya`, then
`CLAUDE.md` and `docs/agent-handoff/START_HERE.md`. Nothing here overrides `CLAUDE.md`.

## Where things are
| | |
|---|---|
| Repo (local) | `C:\Users\biswa\Projects\Numaya` (remote `https://github.com/RITAMBISWAS404/numaya.git`) |
| Flutter app | `C:\Users\biswa\Projects\Numaya\apps\numaya_mobile` (Flutter 3.47.8 stable, Dart 3.13.7) |
| Working branch | **`experiment/numaya-15px-icons-20261107`** (tracks `origin/experiment/numaya-15px-icons-20261107`) |
| Approved design baseline | **The 15px typography and icon experiment (X15), approved by the owner on 2026-11-07.** Implementation commit `4d713e35c6fb58c7de9603bcbf45890689510c62`; this handoff is committed on top of it. Further refinements build on this branch |
| Previous line (history only) | `experiment/numaya-figma-type-icons-20261107` at `7eae060` (X15 started there) |
| Do not touch | `experiment/numaya-android12-compat`, `design/apple-impeccable-full-app` (CLAUDE.md) |

## Next task
**Wait for the owner's feature brief, then help prepare a revised PRD for additional features.**
Do not start building features before the PRD is agreed. Useful inputs: `PRODUCT.md`,
`docs/research/`, `docs/engineering/architecture.md`, and this file's "Current design" section.

## Current design (approved baseline)
- **Families:** Figtree (variable, wght 300–900) for reading text, labels and controls; Plus Jakarta
  Sans (variable, wght 200–800) for headings, names and metrics. Both bundled in `assets/fonts/`.
- **Sizes:** authored sizes are even, **with one exception: the 15pt body tier** (body, bodySm, row,
  input, buttons, label, helper, fieldLabel, metricUnit), all with a 20pt line. Metadata is 12/16
  (Ente Mini); 16, 18, 20, 24, 28, 32, 40 for headings and display. `figma_type_icons_test` scans
  `lib/` and rejects any other odd size.
- **Headings and weights:** app-bar titles (`appBarTitle`, top bar and chat header) Plus Jakarta Sans
  20/28 **700** (Ente Header v2 collapsed); page titles 24/32 **700**; section headings 18/24 600; card
  titles 18/24 600; buttons 15/20 **600**; rows, body and supporting text 500. Text colours: primary
  #000, secondary/metadata #666, disabled #8A8A8A.
- **Icons (Tabler 3.50.0, unchanged filled assignments):** outline stroke 1.5 up to 24pt, 1.25 above
  (24-grid units, set at load by `TablerOutlineLoader`; bundled SVGs are untouched official files).
  Supporting icons (row leading glyphs, chevrons) `iconSupporting` #8A8A8A; selection near-black
  `iconStrong` #1A1A1A; destructive icon and text share `negative` red. Settings has icon rows for
  Version (info), Sign out (logout) and Delete account (trash).
- **Switch:** enabled off track solid **#D6D6D6, no border**; white thumb; brand on track; disabled at
  45% opacity. Contrast 1.45:1 on white, 1.32:1 on the page, **flagged for owner review** (SW-01).
- **Events:** gated off (`ReleaseScope.events`, compile flag `NUMAYA_EVENTS`, default false).
- Visual system follows Meetup, UX follows Bumble, brand purple #7262C7 (CLAUDE.md).

## Completed (this account, 2026-11-06/07)
Typography and copy pass → UI consistency (UC-01–07) → Figma type and icons (FT-01–04) → SW-01
borderless #D6D6D6 switch → local demo photos → **X15 15px type and icon experiment (approved)**.
Records: `docs/design-experiments/ente-design-system/{typography-copy,ui-consistency,figma-type-icons,x15-type-icons}/`.

## Incomplete work and pending decisions
- **Owner decisions:** SW-01 off-switch contrast (below 3:1); EXP-001–004 layout variants (Experiment
  Lab); UI-001 Welcome artwork; UI-008 phrase; merging this line into a shipping branch.
- **Recorded exceptions to revisit:** `NumayaButton` line height 1.2 (not 20); sheet titles,
  Filters questions and Messages list labels keep their sizes (not app bars); `iconSupporting` is
  2.86:1 on the #EAEAEA fill, so it is used only on white cards.
- **Device checks still pending:** a physical phone; Visibility, Premium, Help and the delete-account
  sheet on the device; Android font size 2.0 on the device; three-button navigation; "The basics" at
  320dp; onboarding steps after Photos; iOS. Goldens not regenerated.
- **Environment gaps:** repo-root `npm run check` fails only on CRLF in `tokens:check`; `npm run
  test:e2e` needs `npx playwright install chromium`; no Java on PATH (Maestro not usable).

## Verification (latest, on `4d713e3`)
- `dart format --set-exit-if-changed lib test`: clean. `flutter analyze`: no issues.
- `flutter test`: **507 passed, 21 skipped, 0 failed**.
- Tabler assets: all 110 bundled SVGs match `@tabler/icons@3.50.0` (line endings aside).
- Pixel 10 AVD (API 36, 1080×2424, DPR 2.625): before/after at font 1.0 (16 screens), 1.3 and 320dp
  (5 screens each); no clipping found. Evidence:
  `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\15px icon experiment 2026-11-07\`.

## Latest APK
`C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-15px-Icon-Experiment-20261107-1732.apk`
— debug, 192,181,351 bytes, sha256 `afb2d631b619d2527873ab7857b540e0042099ed3e01b92f6e04c0ad1d4baf18`,
built from `4d713e3` with the local demo photos installed. The handoff commit changes no app code.

## Local-only files (not in Git)
| What | Where | Why / how to restore |
|---|---|---|
| Reference photos (13 JPEGs) + spec `numaya_demo_photos.json` | `C:\Users\biswa\Projects\Numaya\tarini pics\` | Private photos, git-ignored. Back them up separately if the folder moves |
| Installed demo photo set (`photo_NN.jpg`, `face_NN.jpg`, `demo_photos.json`) | `apps\numaya_mobile\assets\demo\photos\` | Git-ignored except README. Recreate: from `apps\numaya_mobile`, `python tool/install_demo_photos.py "../../tarini pics"`, then rebuild. Without it the app shows grey placeholders and all tests pass |
| Flutter/Android generated files (`local.properties`, gradle wrapper, plugin registrants) | `apps\numaya_mobile\android\…`, `ios\…` | Regenerated by `flutter pub get` / `flutter build` |
| APKs and review screenshots | `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\`, `…\Numaya Final Screenshots\` | Build output and evidence; never committed |
| Credentials | GitHub CLI keyring (`gh auth status`: RITAMBISWAS404) | Account-specific; nothing is stored in the repo |

## Figma
- File: https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/ENTE-VISUAL-DESIGN--Copy-?node-id=57-6281
- Pages: Design system `57:6281`, Updated screens (design system) `12099:96447`, Icons `1101:22781`.
- Nodes used: Text styles `10854:4420`; Menu Item `4055:18734`; Menu Item Icon `4055:5652`; Toggle
  Switch `2482:6644` (on `2482:6645`, off `2482:6647`); Icon `4770:20086`; Header (v2) `11439:5040`
  (collapsed `11441:5188`); Button Large `2207:41759`; Button Small `2207:41578`; Text Input
  `2275:11526`; Warning Message `2275:11786`; Tag examples `2482:6546`; Filter Chip `9524:4352`;
  Banners `14590:125265`; Badges `7435:15789`; Bottom sheet `4809:8074`; Settings (DS updated)
  `12099:96480`; Albums / On device / No albums `26580:259933`.
- Source maps: `docs/design-experiments/ente-design-system/x15-type-icons/README.md`,
  `…/figma-type-icons/README.md`, `…/typography-copy/TYPE_ROLES.md`,
  `…/overnight-v2/FIGMA_SOURCE_MAP.md`, `…/TOKENS.md`.

## Tools, skills and connectors
Full table and setup steps: `docs/agent-handoff/TOOLS_SKILLS_AND_INTEGRATIONS.md` (updated
2026-11-07). Summary:
- **Reusable as-is (in this repo):** 39 project skills under `.claude/skills/` (Impeccable, Apple HIG,
  Flutter-Skills set, Emil Kowalski set, ui-ux-pro-max, liquid-glass, Mobbin search and others),
  pinned in `skills-lock.json` where sourced from GitHub.
- **Machine-level (same Windows user, likely reusable; verify with `claude plugin list`):** plugins
  `figma@claude-plugins-official` 2.2.108, `dart-flutter@dart-flutter` 1.0.7,
  `ui-ux-pro-max@ui-ux-pro-max-skill` 2.0.1, `frontend-design@claude-plugins-official`
  `ea10b213686c`; user MCP servers in `~/.claude.json` (mobbin, magic, pencil, dossier,
  job-research-browser).
- **Account-specific (reconnect on the new account):** claude.ai connectors such as Figma (used live
  for every Figma read in these passes), Notion, Gmail and others; the Figma plugin's own MCP
  (`plugin:figma:figma`) needs `/mcp` authorisation; `magic` needs a new 21st.dev key; `pencil` and
  `dossier` were failing to connect. GitHub CLI login is per machine keyring.

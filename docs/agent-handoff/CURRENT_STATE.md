# Current state

**Last verified:** 2026-11-04, on the owner's Windows 11 machine.

## Git
| Item | Value |
|---|---|
| Repository | `RITAMBISWAS404/numaya` (`origin`, HTTPS) |
| Local path | `C:\Users\biswa\Downloads\numaya\numaya` |
| Working branch | `experiment/numaya-final-ux-polish` (tracks `origin`) |
| Baseline branch | `experiment/numaya-monochrome-premium-refinement` |
| Baseline commit | `e70135c` "Premium refinement: docs, contrast table, success token fix" (2026-11-03) |
| Repo default branch | `claude/pensive-newton-glyzjr` |

**Branch lineage:** `experiment/numaya-android12-compat` (`e5184e1`) is an ancestor of the
baseline, 34 commits behind it. The baseline therefore already contains the Android 12 and quality
work.

**Branches not to touch:**
- `experiment/numaya-android12-compat`: kept as it was.
- `design/apple-impeccable-full-app` (`944c532`): separate Impeccable work in progress.

## What is built
- **Flutter app:** `apps/numaya_mobile/`, in the Monochrome Premium design. Plus Jakarta Sans
  headings over Figtree, purple `#7262C7`, filled controls, an icon-only floating tab pill.
- **Web prototype:** the repo root. The premium refinement did not touch it.
- **Design record:** [`docs/design-experiments/monochrome-meetup-premium/`](../design-experiments/monochrome-meetup-premium/README.md).
- **Latest QA:** [VISUAL_QA_REPORT.md](../design-experiments/monochrome-meetup-premium/VISUAL_QA_REPORT.md)
  (2026-11-03). 266 tests passed, 11 skipped. The 4-width × 3-text-size matrix passes. It has
  never been run on a device.
- **Research and specs:** [`docs/research/`](../research/README.md).

## Environment (this machine)
| Tool | State |
|---|---|
| Flutter / Dart | 3.47.8 stable / 3.13.7 at `C:\src\flutter`, on `PATH`; matches `pubspec.yaml` (`sdk: ^3.13.7`) |
| Android SDK | `C:\Users\biswa\AppData\Local\Android\sdk`. Flutter finds it without `ANDROID_HOME`. Platforms 36, 36.1, 37.0; build-tools 36.0.0; NDK 28.2.13676358; licences accepted |
| JDK | Android Studio's bundled JBR (OpenJDK 25.0.3) |
| Emulators | `Pixel_8`, `Pixel_9`, `Pixel_9_2`, `Pixel_10` |
| adb | 1.0.41 in `sdk\platform-tools`, **not on `PATH`**. Call it by full path, or use `flutter devices` |
| Node / npm | Node 24.20.0. **`node_modules` is not installed**. Run `npm ci` before `npm run check` |
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

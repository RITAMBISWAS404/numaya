# New machine setup (Windows): clone, restore and resume

Written 2026-11-08 for a move off the current laptop. Paths use `%USERPROFILE%` (PowerShell
`$env:USERPROFILE`), so they work under any username. Working branch:
**`experiment/numaya-visual-lab-20261108`** (baseline tag `checkpoint/pre-visual-lab-20261108`).

## 1. Install tools (versions verified on the old laptop)
| Tool | Version used | Notes |
|---|---|---|
| Git for Windows (includes Git Bash) | any recent | Run `git config --global core.autocrlf input` before cloning (avoids the CRLF-only web check failures) |
| GitHub CLI `gh` | any recent | `gh auth login` (account `RITAMBISWAS404`) |
| Flutter | **3.47.8 stable** (Dart 3.13.7) | Unzip to e.g. `%USERPROFILE%\dev\flutter`, add `bin` to your user PATH, run `flutter doctor` |
| Android Studio | current | Provides the SDK (platforms 36/36.1/37, build-tools 36.0.0, NDK 28.2.13676358) and the bundled JDK. Accept licences: `flutter doctor --android-licenses` |
| Android emulator | AVD **Pixel_10**, API 36 image | Create in Android Studio › Device Manager. Old laptop started it with `-gpu swiftshader_indirect` |
| Node.js | v24.x | For the web prototype checks (`npm ci`) |
| Python | 3.12 with Pillow | `py -m pip install pillow` (gallery builder, demo-photo installer) |
| Claude desktop app | current | Open the checkout folder in the Code tab |

## 2. Clone this branch
```powershell
mkdir $env:USERPROFILE\Projects -Force; cd $env:USERPROFILE\Projects
git clone --branch experiment/numaya-visual-lab-20261108 https://github.com/RITAMBISWAS404/numaya.git Numaya
cd Numaya; git fetch --tags
git log --oneline -1   # compare with docs/agent-handoff/CURRENT_STATE.md
```
Do not touch `experiment/numaya-android12-compat` or `design/apple-impeccable-full-app`.

## 3. Install dependencies
```powershell
npm ci                                    # repo root (web prototype)
cd apps\numaya_mobile
flutter pub get                           # regenerates local.properties, plugin files
flutter analyze; flutter test             # expect: no issues; 579 passed, 27 skipped, 0 failed
```
Android generated files that are git-ignored (`android/local.properties`, the Gradle wrapper,
`android/app/src/main/java/io/flutter/...` registrant) are recreated by `flutter pub get` /
`flutter build`. If the Gradle wrapper is missing, run `flutter build apk --debug` once.

## 4. Restore files that are NOT in Git (from your private backup)
| What | Put it at | Then |
|---|---|---|
| Private reference photos (13 JPEGs + `numaya_demo_photos.json`; on the old laptop in `<repo>\pics\`) | `<repo>\pics\` (git-ignored) | `cd apps\numaya_mobile; py tool\install_demo_photos.py "..\..\pics"` then rebuild. Without them the app shows grey placeholders and every test still passes |
| Earlier APKs, galleries and the Visual Lab ZIP | anywhere (they are outputs) | Optional; all can be regenerated from the commits recorded in VALIDATION.md, but the screenshots then need the emulator capture again |

Never commit the photos, APKs containing them, `.env` files or signing keys. The repo is **public**.

## 5. Build, test and capture commands (from `apps\numaya_mobile`)
```powershell
flutter analyze
flutter test                                   # unit + widget suites
flutter build apk --debug                      # -> build\app\outputs\flutter-apk\app-debug.apk
```
Screenshot gallery (Git Bash, emulator running as `emulator-5554`):
```bash
export ADB="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"
bash tool/capture_visual_lab.sh emulator-5554 ../../out/capture          # full run (~45 min)
ONLY=default,scenario bash tool/capture_visual_lab.sh emulator-5554 ../../out/capture2   # targeted
flutter test tool/dump_lab_registry.dart --dart-define=OUT=../../out/lab_registry.json
py tool/visual_lab_gallery/build_gallery.py --registry ../../out/lab_registry.json --capture ../../out/capture --history "" --commit <sha> --baseline 0df9ec3 --branch experiment/numaya-visual-lab-20261108 --out ../../out/gallery
```
Web checks (repo root): `npm run check` (tokens/icons checks fail on CRLF unless `autocrlf input`),
`npm run test:e2e` needs `npx playwright install chromium` first.

## 6. Claude: plugins, connectors and sign-ins
- Project skills (39) are committed in `.claude/skills/` (pinned in `skills-lock.json`); nothing to install.
- Plugins and marketplaces: see [TOOLS_SKILLS_AND_INTEGRATIONS.md](TOOLS_SKILLS_AND_INTEGRATIONS.md)
  (`claude plugin marketplace add anthropics/claude-plugins-official`, then the listed plugins).
- Sign in again on the new machine: **GitHub CLI** (`gh auth login`); **Figma** (claude.ai Figma
  connector; the Figma plugin MCP needs `/mcp` sign-in in a terminal session); **Mobbin** connector;
  **21st.dev magic** needs a fresh API key; `pencil` and `dossier` MCP servers were failing to connect.
- Open `<repo>` in the Claude desktop Code tab and paste the prompt in
  [HANDOFF_PROMPT.md](HANDOFF_PROMPT.md), or simply: "Read docs/agent-handoff/START_HERE.md and resume."

## 7. Resume
Current state: Visual Lab V2 is **complete** (app code `8510778`). The exact next action is the
owner's: open the gallery (rebuild it if the old Desktop copy is lost), choose, export the JSON and
send it; Claude then runs the application pass described in
`docs/design-experiments/visual-lab-v2/RUN_STATE.md`.

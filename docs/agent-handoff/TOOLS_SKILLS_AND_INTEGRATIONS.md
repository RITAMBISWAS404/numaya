# Tools, skills and integrations

## Verified inventory for the account switch (2026-11-07, Windows 11, Claude desktop)

### 1. Reusable as-is: committed in this repo (project-local)
All 39 skills live in `C:\Users\biswa\Projects\Numaya\.claude\skills\` and are tracked in Git, so any
account opening this folder gets them. GitHub-sourced ones are pinned in `skills-lock.json`.

| Skill | Source / revision |
|---|---|
| `accessibility-as-code` | zakariaf/Flutter-Skills (GitHub), hash `f15b3db3f463` |
| `adaptive-layout` | zakariaf/Flutter-Skills (GitHub), hash `02e8012c5808` |
| `animate` | emilkowalski/skills (GitHub), hash `7598d33e7f60` |
| `animation-performance` | emilkowalski/skills (GitHub), hash `b68ba704106e` |
| `animation-vocabulary` | emilkowalski/skills (GitHub), hash `0058036865ec` |
| `apple-design` | emilkowalski/skills (GitHub), hash `0190417d092a` |
| `apple-hig` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `async-safety` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `banner-design` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `brand` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `break-ui` | emilkowalski/skills (GitHub), hash `60ada6766292` |
| `dependency-hygiene` | zakariaf/Flutter-Skills (GitHub), hash `33fd752937b3` |
| `design` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `design-review-workflow` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `design-system` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `design-system-structure` | zakariaf/Flutter-Skills (GitHub), hash `0ec90e0e1e0d` |
| `emil-design-eng` | emilkowalski/skills (GitHub), hash `51f2537e04d1` |
| `find-animation-opportunities` | emilkowalski/skills (GitHub), hash `465d087c4176` |
| `flutter-conventions-index` | zakariaf/Flutter-Skills (GitHub), hash `2afbc6ab45af` |
| `flutter-performance` | zakariaf/Flutter-Skills (GitHub), hash `87eeb58ea986` |
| `forms-and-input` | zakariaf/Flutter-Skills (GitHub), hash `eadea3bd9953` |
| `impeccable` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `improve-animations` | emilkowalski/skills (GitHub), hash `524ea241e41d` |
| `liquid-glass` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `liquid-glass-widgets` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `motion-and-haptics` | zakariaf/Flutter-Skills (GitHub), hash `5649e9d49b1f` |
| `navigation-and-routing` | zakariaf/Flutter-Skills (GitHub), hash `4fc5b3950d40` |
| `prototype` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `review-animations` | emilkowalski/skills (GitHub), hash `b4e5f0f4fe3e` |
| `search` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `slides` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `state-management-riverpod` | zakariaf/Flutter-Skills (GitHub), hash `9e48c2a8edec` |
| `testing-strategy` | zakariaf/Flutter-Skills (GitHub), hash `8c5d0323d70b` |
| `ui-states-and-feedback` | zakariaf/Flutter-Skills (GitHub), hash `8f6e22b77318` |
| `ui-styling` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `ui-ux-pro-max` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `ux-researcher-designer` | committed copy (see the skill folder; earlier passes record upstreams below) |
| `widget-composition` | zakariaf/Flutter-Skills (GitHub), hash `097df65a85d4` |
| `widget-golden-and-a11y-testing` | zakariaf/Flutter-Skills (GitHub), hash `9d467f8883c8` |

### 2. Machine-level (Windows user `biswa`), probably reusable; confirm with `claude plugin list`
Installed at user scope under `C:\Users\biswa\.claude\` (`plugins\installed_plugins.json`,
`settings.json` → `enabledPlugins`). These files belong to the Windows user, not the Claude account,
but whether a new account sees them depends on the client; verify, and reinstall if missing.

| Plugin | Marketplace (source) | Version / commit | Installed path |
|---|---|---|---|
| `figma@claude-plugins-official` | anthropics/claude-plugins-official | 2.2.108, `f046182e` | `C:\Users\biswa\.claude\plugins\cache\claude-plugins-official\figma\2.2.108` |
| `dart-flutter@dart-flutter` | flutter/agent-plugins | 1.0.7, `774dc2c1` | `C:\Users\biswa\.claude\plugins\cache\dart-flutter\dart-flutter\1.0.7` |
| `ui-ux-pro-max@ui-ux-pro-max-skill` | nextlevelbuilder/ui-ux-pro-max-skill | 2.0.1, `07f4ef3a` | `C:\Users\biswa\.claude\plugins\cache\ui-ux-pro-max-skill\ui-ux-pro-max\2.0.1` |
| `frontend-design@claude-plugins-official` | anthropics/claude-plugins-official | `ea10b213686c` | `C:\Users\biswa\.claude\plugins\cache\claude-plugins-official\frontend-design\ea10b213686c` |

User skill outside the repo: `C:\Users\biswa\.claude\skills\emil-design-eng` (also committed in the repo).

User MCP servers in `C:\Users\biswa\.claude.json` (`mcpServers`): `mobbin`, `magic` (21st.dev; key was
reported missing/reset), `pencil` and `dossier` (failing to connect this session), `job-research-browser`.
None has a project-level entry for Numaya.

Reinstall a missing plugin:
```
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install figma@claude-plugins-official
claude plugin marketplace add flutter/agent-plugins
claude plugin install dart-flutter@dart-flutter
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill
claude plugin install frontend-design@claude-plugins-official
```

### 3. Account-specific: reconnect on the new account
| Connector | Used for | State on the old account | New account |
|---|---|---|---|
| claude.ai **Figma** connector | Every live Figma read in the 2026-11-07 passes (variables, components, screenshots, SVG exports) | Connected (Figma handle RITAM) | Connect Figma in claude.ai settings; check it can open `22AeTw6QiPj2fNYHLhC7MK` |
| Figma plugin MCP `plugin:figma:figma` | Not used (the connector above was) | Needs `/mcp` authorisation | Authorise via `/mcp` in a terminal session if wanted |
| Mobbin (claude.ai connector and/or user MCP) | Reference research | Available | Reconnect if needed |
| Notion, Gmail, Google Drive and other claude.ai connectors | Not used for Numaya | Present | Optional |
| Claude desktop built-ins (in-app browser, Artifacts, Docs) | Browser checks, previews | Built into the app | Nothing to install |

### 4. Machine tools (not Claude-specific)
Flutter 3.47.8 stable (Dart 3.13.7) on PATH; Android SDK `C:\Users\biswa\AppData\Local\Android\sdk`
(adb by full path: `...\platform-tools\adb.exe`); AVDs `Pixel_10` (used), `Pixel_8`, `Pixel_9`, `Pixel_9_2`;
Python 3.12 with Pillow (capture boards, photo tool); Node 24 (repo web checks); GitHub CLI logged in
as RITAMBISWAS404 (keyring, per machine); Microsoft Edge (headless HTML renders). No Java on PATH.
`@tabler/icons@3.50.0` is fetched on demand with `npm pack` for `tool/sync_tabler_icons.py`.

---

## Earlier record

> **Cloud session, 2026-11-03 UTC (Claude Code 2.1.317, Linux):**
> - **`dart-flutter` plugin 1.0.7:** installed at user scope with
>   `claude plugin marketplace add flutter/agent-plugins` and
>   `claude plugin install dart-flutter@dart-flutter`; BSD-3-Clause. `claude plugin list` shows it
>   enabled; its skills load in the next session.
> - **Mobbin MCP:** connected; live searches ran.
> - **Repo-local skills:** `impeccable`, `apple-hig`, `liquid-glass-widgets`, `liquid-glass` and
>   `search` are present in the worktree and were read as files. This session was opened in
>   another checkout, so only `impeccable` and `apple-design` loaded as `/` skills.
> - **Not available here:**
>   - the Android SDK (`dl.google.com` is denied by the network policy);
>   - an SVG rasteriser (the mascot was verified through Flutter's own renderer).
> - **Not installed:** Widgetbook, Alchemist, Maestro, Patrol, Color.js, Material Color
>   Utilities, Lucide, Phosphor. Existing tests and goldens covered every check, contrast used
>   the repo's Python script, and the icons were sufficient.

**Verified:** 2026-11-04, Claude Code 2.1.272, Windows 11. Agent tools are not app dependencies;
`pubspec.yaml` is unchanged.

| Tool | Upstream | Version / commit | Status | Scope | Route used | Verification |
|---|---|---|---|---|---|---|
| Flutter/Dart agent plugin `dart-flutter` | https://github.com/flutter/agent-plugins | 1.0.7 | **Installed and verified** (installed in the previous session) | User | `claude plugin marketplace add flutter/agent-plugins`, then `claude plugin install dart-flutter@dart-flutter` | `claude plugin list`: enabled. Its skills (`dart-flutter:*`) appear in the session's skill list. `claude mcp list`: `plugin:dart-flutter:dart-mcp-server` ✔ Connected |
| Dart and Flutter MCP server | https://dart.dev/tools/mcp-server | Dart 3.13.7 | **Verified** (bundled by the plugin) | User | via the plugin | Connected; tools available (analyze, widget inspector, hot reload and others). Not needed beyond analysis for this experiment |
| Official Flutter rules in `CLAUDE.md` | https://github.com/flutter/agent-plugins (rules) | — | **Deferred** | — | — | Project `CLAUDE.md` already carries Numaya-specific rules; nothing conflicting or missing was found that this task needed |
| Impeccable | https://github.com/pbakaus/impeccable | in repo | **Already installed and verified** | Project (`.claude/skills/impeccable`) | — | In the session's skill list; used as review vocabulary |
| Apple HIG (community) | https://github.com/allexp1/apple-hig | `d501976`, skill v2.0.0, MIT | **Installed** | Project (experiment worktree) | Upstream `install.sh --project` (read first; it only copies files) | `.claude/skills/apple-hig/SKILL.md` plus 10 reference files present. **Loads as `/apple-hig` in a session opened in the worktree.** This session started in the main checkout, so it was read directly and applied (glass on the functional layer only, legibility at both ends, High Contrast fallback) |
| Liquid Glass Widgets skill | https://github.com/sdegenaar/liquid_glass_widgets | `5911897` (package 1.16.1), MIT | **Installed** | Project (worktree) | Upstream Claude Code instruction: copy `skills/liquid-glass-widgets/SKILL.md` to `.claude/skills/liquid-glass-widgets/` | File present; read in full for the package decision |
| `liquid_glass_widgets` runtime package | same | 1.16.1 (Flutter ≥ 3.41, Dart ≥ 3.5) | **Not adopted (deferred)** | — | — | Requires `initialize()` in `main`, `LiquidGlassWidgets.wrap()` around the app and `GlassScaffold` per screen: an app-wide migration. Its minimal tier is plain `BackdropFilter` |
| `flutter_liquid_glass` | https://github.com/whynotmake-it/flutter_liquid_glass | — | **Not installed** | — | — | Avoids a second competing renderer |
| Mobbin MCP | https://github.com/mobbin/mobbin-mcp-server | HTTP `https://api.mobbin.com/mcp` | **Already configured and verified** | User | — | `claude mcp list` ✔ Connected; real searches returned Hinge, Tinder, Coffee Meets Bagel and Yubo screens |
| Mobbin search skill | https://github.com/mobbin/skills | `79124d9`, MIT | **Installed** (`skills/search` only) | Project (worktree) | Copied the skill folder. The official `claude plugin install mobbin@mobbin` was **not** used because it would add a second Mobbin MCP server next to the connected one | `.claude/skills/search/SKILL.md` present |
| Maestro | https://github.com/mobile-dev-inc/maestro | — | **Deferred** | — | — | No `java` on `PATH`. The journey was replayed on the emulator with `adb` and the accessibility tree, and the behaviour is covered by widget tests |
| Patrol | https://github.com/leancodepl/patrol | — | Not applicable | — | — | No native dialogs or permissions in scope |
| Alchemist | https://github.com/Betterment/alchemist | — | Not applicable | — | — | The existing golden system (`test/screenshots`) covered it, including the new stress-background golden |
| Material Color Utilities | https://github.com/material-foundation/material-color-utilities | Dart `material_color_utilities` 0.13.0 (transitive via Flutter) | Not needed | — | — | The palette stayed brand-defined; no tonal regeneration |
| Color.js / Contrast Ratio | https://github.com/color-js/color.js, https://github.com/siege-media/contrast-ratio | — | **Equivalent used** | — | — | WCAG 2.x luminance in Python (independent of Flutter), cross-checked against Flutter's `computeLuminance` in tests and against rendered pixels |

## Other MCP servers in this environment
| Server | State |
|---|---|
| Figma | Needs `/mcp` authentication |
| magic (21st.dev) | Not authenticated |
| pencil, dossier | Fail to connect |

None of these were needed.

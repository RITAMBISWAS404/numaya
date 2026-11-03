# Tools, skills and integrations

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

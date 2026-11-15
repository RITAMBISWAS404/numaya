# Quality refinement: implementation and QA report

2026-11-15. Worktree `C:\Users\biswa\Projects\Numaya-fable-lab`.

| Item | Value |
| --- | --- |
| Baseline | `e8f871a` (tag `checkpoint/pre-quality-refinement-20261115-1849`; app source `e3c50cd`) |
| Branch | `experiment/numaya-quality-refinement-20261115-1849` |
| Final app source | `db3101d` (APK and all evidence built from it; records follow in later commits) |
| APK | `C:\Users\biswa\OneDrive\Desktop\Numaya Quality Refinement\2026-11-15 db3101d\apk\Numaya-QualityRefinement-20261115-db3101d-debug.apk` |
| APK SHA-256 | `3995c169b88d431bd02a15dd6a6029efe5a6047f89d3c496fdb4e40258c6b879` (248,402,121 bytes) |
| Build | `flutter build apk --debug --dart-define=NUMAYA_DEV_TOOLS=true`, Flutter 3.47.8. Demo world and Dev Mode on. **Not installed or launched**: no device authorised. |
| Screenshots | same folder, `screenshots\` (249 PNGs, flat, numbered; `INDEX.csv` maps file, flow, state, issue, revision, viewport, text scale and kind). All are **widget renders** of the real app tree (Flutter test renderer), not emulator or device screenshots. |

Package inputs read: README, 00_SCOPE_AND_PRECEDENCE, GENERATION_SUMMARY, NEW_FINDINGS (QR-001..014),
FINDING_SOURCE_LOCATIONS, LOCAL_CHECK_RESULTS, IMPLEMENTATION_ROADMAP. History (UI-001..102) read in the previous phase
and carried by `docs/ui087-102`. Tracker: [EXECUTION_TRACKER.csv](EXECUTION_TRACKER.csv). Coverage:
[ROUTE_STATE_COVERAGE.csv](ROUTE_STATE_COVERAGE.csv). Tokens and components: [TOKEN_AND_COMPONENT_CATALOGUE.md](TOKEN_AND_COMPONENT_CATALOGUE.md).

## Results (fresh runs, logs in `baseline/` and `final/`)

| Check | Baseline `e8f871a` | Final `db3101d` |
| --- | --- | --- |
| `node scripts/tokens.mjs --check` | exit 1 (CRLF only) | exit 0 |
| `generate_tokens.mjs --check` (Dart) | exit 0 | exit 0 |
| `flutter analyze` | 2 infos | 2 infos (same: a deprecated test matcher, an unbraced `if` in a test) |
| `flutter test` | 693 passed, 47 skipped, 0 failed | 732 passed, 49 skipped, 0 failed |
| Comparison renders (393 @1.0) | n/a | 159 passed |
| Comparison renders (320 @2.0) | n/a | 80 passed (no layout overflow) |
| Integration tests, device, iOS, TalkBack, profiling | not run | **not run: no device authorised** |
| Web `npm run check` / e2e | not run | not run: no web source changed (only the token script's comparison and `.gitattributes`) |

Skipped tests are the opt-in `screenshots`/`comparison` tagged suites (`dart_test.yaml`; the comparison renders were run
separately, above) and explicit `skip:` cases in five older files (dormant Events and superseded experiments).

Changed expectation: `final_polish_test` "Discover photo nests inside its hero card" asserted 12 + 16 = 28; the owner's
2026-11-15 directive (finite corners at most 20; a floating control is not a nested surface) supersedes it.

## Completed and verified

QR-002, QR-003, QR-007 (with recorded exceptions), QR-008, QR-012 (SDK guidelines on six screens), QR-013, DEF-QR-01,
UI-049 (remaining overlays), UI-070 (playing voice render), UI-091 (chat photo reply render), UI-094 (comparable
statuses). Regression of UI-087..098, 101, 102 and the amendments: full suite and fresh renders pass.

## Partial

QR-001 (generators deterministic; handwritten Mono tokens not migrated), QR-005 (documented; no production palette
chosen), QR-009 (widget-level only), QR-014 (catalogue, no CI gate), UI-012/UI-074 (no per-override sweep).

## Blocked or outstanding

- QR-004 scoped theme: not implemented; the static compatibility facade stays (reported as debt).
- QR-010 style-candidate classification (613 hits): outstanding.
- QR-011 performance and QR-009 native checks: blocked (no device).
- DEF-QR-02 large titles break inside words at 320pt and 200% text (pre-existing): needs a decision.
- UI-099, UI-100: blocked (no approved PRD or discovery rules).
- Production choices: font pair, body size, palette, button shape, secondary surface and status surface.

## Launch blockers (unchanged by this pass)

The frontend uses demo and unconfigured auth with in-memory profiles. No OTP, purchases, uploads or push are real.
The backend is a separate worktree and was not touched. A clean build is not production readiness.

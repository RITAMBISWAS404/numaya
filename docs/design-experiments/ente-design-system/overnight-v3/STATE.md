# Overnight v3: state

| Item | Value |
|---|---|
| Live candidate (frozen) | `/home/user/numaya-ente`, branch `experiment/numaya-ente-design-system` |
| Checkpoint commit | `e60504e` — `checkpoint: Ente design system before V3 experiments` (parent `f2e18e627af9f06e9563db5bf09828995dcde5c4`) |
| Checkpoint tag | `numaya-ente-design-system-finalized-20261106-0624` (annotated, local; "finalized" is a checkpoint label, not a release certification) |
| Working branch | `experiment/numaya-ente-delight-v3-20261106-0624` in worktree `/home/user/numaya-ente-v3` |
| Pre-run backup | `numaya-ente-recovery-20261106-062350-prerun-v3-f2e18e6.zip` (SHA-256 `cdc60fe2976e9731aa43a01439a6cd69a3f1385f885f08b2e31a28d6548a7337`): 400 files, 1 staged deletion, 19 intent-to-add, base + patch + files + restore.sh |
| Contents | Windows Ente redesign and review batches 1-2 (restored), batch 3 (UI-033 to UI-046), overnight v2 (OV-01 to OV-04) |
| Push / merge / deploy | None. Local commits only |
| Environment | Linux cloud container; Flutter 3.47.8 / Dart 3.13.7; no Android SDK, emulator or device |
| Connectors | Figma (read; screenshots via base64), Mobbin. Dart MCP server failed to start (CLI used instead) |
| Unrelated checkout | `/home/user/numaya` (branch `experiment/impeccable-visual-refinement`, uncommitted work) left untouched |

## Baseline evidence (Current)
- Harness `test/screenshots/capture_v3_test.dart`, `--dart-define=V3_SET=current`.
- `phone`: 390x844 logical, DPR 2 (780x1688 px), text 1.0. 58 views.
- `narrow`: 320x693 logical, DPR 2, text 2.0. 58 views; **1 defect**: the Unmatch sheet overflowed by 31pt (V3-D01).
- Fixture: quick-start demo (Alex) or onboarding quick start; photos are the app's own grey placeholders (no licensed photography exists).
- Renders are gitignored (`test/screenshots/comparison/`); copies live in `artifacts/ente-design-system/overnight-v3/screens/current/`.
- Route inventory: the same 58 views as ov2 (`../overnight-v2/COVERAGE.csv`) and the empty states added for experiments. Debug-only Design Lab and Experiment Lab are excluded from product coverage.

## Next action
See `RUN_STATE.md`.

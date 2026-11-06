# Numaya V4 review: interaction and edge-case polish

**Start here:** open `gallery/index.html` (offline). Your layout choices from V3 are still pending.
The gallery shows the same four experiments (Current/A/B/C), plus every V4 change as a before/after pair.

| What | Where |
|---|---|
| What changed and why (ledger) | `EVIDENCE.csv` (V4-01 to V4-05 fixed; P-01 to P-06 probed with no defect) |
| Before/after for each changed screen | `before-after/<id>__<scene>/{pair,before,after}.png` |
| Experiments at the V4 revision | `experiments/` (only EXP-001 A/B and EXP-002 A changed) |
| Test results and gallery check | `reports/qa.md`, `reports/gallery-check.json` |
| Checks that need a real phone | `DEVICE_CHECKS.md` |

## Revisions
- **V3 candidate (before):** `fc72906` on `experiment/numaya-ente-delight-v3-20261106-0624`. The checkpoint tag `numaya-ente-design-system-finalized-20261106-0624` is `e60504e`.
- **V4 (after):** `experiment/numaya-ente-polish-v4-20261106-0724`, parent `fc72906`.

## Notes
- **Evidence.** All renders come from the Linux Flutter harness at 2x; the 320pt scenes use 200% text. None of it is device evidence.
- **Rebuilding the gallery.** Run `python tools/build_review_gallery.py review-manifest.json gallery`. This copy fixes the "1 choices" status bug (V4-05).

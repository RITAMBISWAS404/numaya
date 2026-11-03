# V16 acceptance review

**Ratings:** each criterion of the V16 brief is rated **Pass**, **Needs work** or **Fail**.

**Evidence:**
- **Commands:** run on 2026-11-03 in the V16 worktree, after a machine restart, on the committed
  state.
- **Screenshots:** under `screenshots/`.

| # | Criterion | Rating | Evidence |
|---|---|---|---|
| 1 | V16 is based on V11 and isolated on its own branch | **Pass** | Branch `experiment/numaya-v16-withings-inspired` from V11 `59e06e8`, in its own worktree; the main checkout and the other experiment branches are untouched ([BASELINE.md](BASELINE.md)). |
| 2 | Production default unchanged | **Pass** | The full gallery without `?theme`: **162/162 captures pixel-identical** to the committed gallery. |
| 3 | V11 stays available as the fallback, unchanged | **Pass** | `?theme=tiimo` from V16's code: **29/29 states pixel-identical** to captures from the V11 worktree; the V11 E2E suite passes 111/111. |
| 4 | V11 UX and layout locked | **Pass** | Geometry check: every non-text element within 1px on 12 states × 2 viewports (2,230 boxes). Text runs keep their y, height and line count; only their width changes (titles up to 17px). The four full-page captures have identical heights. |
| 5 | Reference studied honestly, limits stated | **Pass** | 45 Health Mate screens from the Mobbin connector, each linked; the blocked `mobbin.com` page and the unverifiable version ID are stated; colours labelled as sampled approximations ([REFERENCE_ANALYSIS.md](research/REFERENCE_ANALYSIS.md) §0). |
| 6 | Reference's visual language reconstructed (colour, type, surfaces, buttons, controls, tabs, states) | **Pass** | [compare-reference-v16.png](screenshots/compare-reference-v16.png); E2E checks for canvas, cards, buttons, switches, tabs, radios and type (22/22). |
| 7 | Tokens, not raw values; generated files not edited by hand | **Pass** | `wth` tokens in `tokens/numaya.tokens.json` → `npm run tokens`; `tokens:check` and the `css-usage` test pass. |
| 8 | Design-system documentation | **Pass** | Five docs in `design-system/`: layout contract, principles, tokens, component rules, screen inventory. |
| 9 | Screenshots, contact sheet and side-by-sides | **Pass** | 29 V11 and 29 V16 states; 29 side-by-sides; `contact-sheet-v16.png`, `contact-sheet-v11-v16.png`, the reference comparison. |
| 10 | Four review passes, at least two substantive | **Pass** | [SCREEN_REVIEW.md](SCREEN_REVIEW.md): passes 1–3 each fixed defects (slider fill, chat name, match avatar, sheet slider track, prompt legend); pass 4 assessed accessibility and fit. |
| 11 | Accessibility | **Pass** | axe-core 13/13 targets with 0 serious or critical issues, 3 of them V16; text ≥ 4.5:1, control edges ≥ 3:1, 2px focus ring. |
| 12 | Responsive (393 and 375) | **Pass** | Geometry check at 393 × 852 and 375 × 667; gallery states 145–158 at 375 × 667. |
| 13 | Tests run, none weakened | **Pass** | Unit 121/121; build OK; smoke 144/144; product 88/88; V11 111/111; V16 22/22; a11y clean. No existing test was edited except to **add** V16 targets to the a11y suite. |
| 14 | No regressions | **Pass** | Rows 2, 3 and 13. |
| 15 | V16 clearly improves Numaya | **Fail** | V16 is clean, legible and consistent. It reads as health and utility software rather than a premium dating product, and the Match and Welcome screens lose warmth. It also retires the brand purple that `CLAUDE.md` makes non-negotiable ([SCREEN_REVIEW.md](SCREEN_REVIEW.md), pass 4). |

## Open items (Needs work, not blocking the experiment)
- **Like back (059):** while scrolled, the white "You both like" card is cut flat by the canvas action
  bar. V11 shares the structure; fixing it needs a surface change on V11's sticky bar.
- **Reference colours:** sampled from 299 × 678 JPEG previews. A check against full-resolution
  screens would firm them up.

## Verdict
V16 meets every execution criterion: the layout is locked, the production default and V11 are intact,
and it is accessible and documented.

It fails the deciding product criterion. Per the brief: **stop the experiment and keep V11** as the
direction and the fallback.

V16 stays on its branch as an opt-in theme (`?theme=withings`) and a reference.

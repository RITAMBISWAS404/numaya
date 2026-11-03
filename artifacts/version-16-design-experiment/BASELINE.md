# V16 baseline (verified 2026-10-26)

## Repository state

**Remote:** `origin` → `https://github.com/RITAMBISWAS404/numaya`.

**Main checkout** `/home/user/numaya`:
- on `experiment/impeccable-visual-refinement` at `6e4dbd1`, with 14 uncommitted changes (the
  unfinished Impeccable experiment);
- **not touched.**

**Branches and worktrees (verified with `git worktree list`, `git ls-remote` and `git status`):**

| Version | Branch | Head | State |
|---|---|---|---|
| Approved fallback (Apple Design + Impeccable) | `design/apple-impeccable-full-app` | `944c532` | pushed; clean worktree |
| **V11, the layout and UX baseline** | `experiment/tiimo-inspired-v11` | **`59e06e8`** | **committed and pushed**; clean worktree. It is an opt-in theme (`?theme=tiimo`) over the approved default. |
| V12 (Liquid Glass) | `experiment/tiimo-inspired-v12-liquid-glass` | `e2272e8` | pushed; clean |
| V13 (Salt editorial) | `experiment/numaya-v13-salt-editorial` | `e2272e8` + uncommitted | local only; untouched |
| V14 (J.P. Morgan reconstruction) | `experiment/numaya-v14-jpmorgan` | `e2272e8` + uncommitted | local only; untouched |
| V15 (J.P. Morgan visual on V11) | `experiment/numaya-v15-jpmorgan-visual` | `59e06e8` + uncommitted | local only; untouched. Its layout-contract method is reused. |

## V16 isolation
- **Branch:** `experiment/numaya-v16-withings-inspired`. Verified absent locally and on `origin`
  before creation.
- **Base:** **V11 (`59e06e8`)**, in its own worktree.
- **Added:** the small multi-theme mapping from V12 (`themeClassName` and its two call sites), as in
  V15. `?theme=tiimo` renders exactly as on V11's branch (verified, below).
- **Committed and pushed to its own branch on 2026-11-03, with the user's authorization. Not merged
  or deployed.**

## Mechanism
- **Classes:** `?theme=tiimo` → `.theme-tiimo` (V11). `?theme=withings` → `.theme-tiimo .theme-wth`
  (V16).
- **Stylesheet:** `src/design-system/styles/theme-wth.css`, imported last, with every rule scoped to
  `.theme-wth`.
- **Tokens:** `tokens/numaya.tokens.json` (`primitive.color.wth`, `primitive.font.family.hanken-grotesk`,
  `component.wth`) → `npm run tokens`.
- **Markup:** no component markup, routes or state changed.

## Screenshot workflow
- **Gallery:** `scripts/gallery.mjs` (`GALLERY_THEME`, `GALLERY_ONLY`, `GALLERY_OUT`).
- **V11 baseline:** captured from the V11 worktree (`screenshots/v11/`).
- **Layout comparison:** `tests/e2e/experiment-withings.mjs` measures every element's box against V11.

## Validation commands
| Command | What it runs |
|---|---|
| `npm run check` | tokens, icons, Vitest (including `css-usage`, the static CSS check), Vite build |
| `npm run test:e2e` | `smoke.mjs`, `product.mjs`, `experiment-tiimo.mjs` (V11), and V16's `experiment-withings.mjs` |
| `npm run test:a11y` | axe-core, including the V16 views |

There is no ESLint config.

## Reference access
- **Available:** the Mobbin connector; its five searches returned 45 distinct Health Mate screens (preview images).
- **Blocked:** `mobbin.com` itself, by the environment's network policy (proxy 403). The exact
  collection page and full-resolution images could not be opened.
- **Details:** see `research/REFERENCE_ANALYSIS.md` §0.

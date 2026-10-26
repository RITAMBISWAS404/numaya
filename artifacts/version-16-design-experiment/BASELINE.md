# V16 baseline: the verified V11 starting point

Recorded before any V16 change, on 2026-10-26.

## Repository state

| | |
|---|---|
| Remote | `origin` → `https://github.com/RITAMBISWAS404/numaya` |
| Starting branch | `experiment/tiimo-inspired-v11`, up to date with `origin/experiment/tiimo-inspired-v11` |
| Starting commit | `59e06e8` "Add V11 final screenshot preview, design decisions and research" (the remote branch head, `59e06e87eb44`) |
| Working tree | clean, no stashes, one worktree (the checkout itself) |
| V16 branch | `experiment/numaya-v16-withings`, created from `59e06e8`; no branch of that name existed locally or on the remote |
| Other branches | 18 remote branches (`experiment/tiimo-inspired-v3` … `-v12-liquid-glass`, `design/apple-impeccable-full-app`, `experiment/combined-visual-craft`, …). None was modified. |

**Is it V11?** Yes:
- the history ends with V11's two commits (`ff84175` implementation, `59e06e8` artifacts) on top of V10 (`f1001ef`);
- `artifacts/version-11-final-screenshot-preview/README.md` names `ff84175` as the implementation and this branch;
- `src/design-system/styles/theme-tiimo.css` opens with "Tiimo-inspired visual experiment, V11";
- V11's experiment suite passes 111/111, the count its README reports.

## How V11 is built

- **No production framework** (CLAUDE.md). A Vite + React 19 prototype with three entries: `index.html` (onboarding), `flows.html` (product screens) and `showcase.html` (design system).
- **Tokens.** `tokens/numaya.tokens.json` (DTCG), compiled by `npm run tokens` into `src/design-system/tokens.{css,js}`. Never edited by hand.
- **Components.** `src/design-system/components/*.jsx`, styled by `src/design-system/styles/*.css`, imported only through `src/design-system/index.js`.
- **The experiment layer.** `?theme=tiimo` adds `.theme-tiimo` to 14 flow screens and Welcome (`TIIMO_SCREENS` in `src/flows/Flows.jsx`; `src/lib/theme.js`). All V11 styling is in `src/design-system/styles/theme-tiimo.css` and `src/flows/theme-tiimo.css`, scoped to that class. Without the flag the approved design renders.
- **Fonts.** Fraunces (display) and Inter (text), both from `@fontsource-variable`.

## Screen inventory (V11 scope)

| Area | Screen id | Title |
|---|---|---|
| Onboarding | (index.html) | Welcome |
| Profile creation | `basics`, `interests`, `photos` | The basics; Interests and prompt; Photos |
| Home | `discovery` | Profile card, like or pass, plus the filters sheet and the options menu |
| Matching | `match` | It’s a match |
| Likes | `likes`, `like-profile` | People who liked you; Like back or pass |
| Messages | `chats`, `chat` | Conversations; Chat, with the report, block and unmatch sheets |
| Profile | `profile`, `edit`, `prompt` | My profile; Edit profile and preview; Edit prompt |
| Settings | `settings` | Preferences and privacy, with the delete-account sheet |
| Activity | `activity` | Explore activities |

Outside the experiment, and so outside V16 too: `intro`, `activity-detail`, `activity-people`, `activity-form`, `my-activities`, `insights`, `blocked`, `premium`, `connections`, `help`, `maintenance`.

## Tooling

- `scripts/gallery.mjs`: drives the real UI in Chromium and writes numbered screenshots (393 × 852 at 2×, 375 × 667 for QA). `GALLERY_THEME`, `GALLERY_ONLY` and `GALLERY_OUT` pick the theme, states and folder. Every V11 and V16 screenshot here comes from it.
- E2E: `tests/e2e/smoke.mjs`, `product.mjs`, `experiment-tiimo.mjs`, `a11y.mjs` (Playwright and axe-core).

## Baseline validation, as run

| Command | Result on `59e06e8` |
|---|---|
| `npm ci` | ok |
| `npm run check` (tokens, icons, Vitest, build) | pass: 325 tokens, 67 icons, **119/119** unit tests, build ok |
| `node tests/e2e/smoke.mjs` | **143/144**. The one failure, "no squircle or superellipse corner-shape anywhere", is environmental. This container's Chromium (headless shell 1243) reports `superellipse(1)` as the default `corner-shape` of every element; a bare `<div>` shows it too. The repo's own CSS never sets `corner-shape`. |
| `node tests/e2e/product.mjs` | **88/88** |
| `node tests/e2e/experiment-tiimo.mjs` | **111/111** |
| `node tests/e2e/a11y.mjs` | 0 serious or critical violations |

**Environment note.** The repo pins Playwright 1.56.1, which looks for Chromium build 1194. The container ships build 1243. I linked
`/opt/pw-browsers/chromium_headless_shell-1194/chrome-linux/headless_shell` to the 1243 binary. That is a container-only change; nothing in the repository changed for it.

## V11 baseline screenshots

`screenshots/v11/`: 49 states captured with `GALLERY_THEME=tiimo` on the V16 branch, before any V16 CSS existed. They are the V11 side of every comparison. After V16 they were captured again and are pixel-identical (see `qa/isolation.txt`).

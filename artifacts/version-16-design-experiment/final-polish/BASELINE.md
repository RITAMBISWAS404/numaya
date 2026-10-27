# Final polish: baseline

Recorded on 2026-10-27, before any polish change.

## Starting state, as verified

| | |
|---|---|
| Branch | `experiment/numaya-v16-withings` |
| HEAD | `6f81133` "V16 final fidelity audit: correct the remaining reference mismatches". Pushed with your authorisation at the start of this task; the remote is equal to local. |
| Working tree | clean (`git status` empty) |
| V11 | `experiment/tiimo-inspired-v11` at `59e06e8`, untouched; on this branch it is reachable with `?theme=tiimo` |
| Default | no `?theme`: the approved design |
| Polish work | stays uncommitted on this branch, as this task instructs (no commit, no push) |

## Architecture, checked against the code (not just the docs)

- **Activation.** `themeClasses()` in `src/lib/theme.js`. `?theme=withings` puts `.theme-tiimo.theme-withings` on
  the 14 flow screens in `TIIMO_SCREENS` (`src/flows/Flows.jsx`) and on Welcome (`src/prototype/screens/Welcome.jsx`).
- **Tokens.** `tokens/numaya.tokens.json` → `npm run tokens` → `src/design-system/tokens.{css,js}`: 386 tokens,
  including `--color-withings-*`, `--font-withings`, `--shadow-withings-*` and `--withings-*`.
- **Styles.**
  - `src/design-system/styles/theme-withings.css`: 1,075 lines, 171 rules, loaded after `theme-tiimo.css`.
  - `src/flows/theme-withings.css`: 20 lines.
- **What the docs don't say.** The component file is no longer one ordered system. It is the first implementation
  plus four appended correction sections, so several components are styled twice or three times with conflicting
  values (see `PASS_1_DESIGN_SYSTEM.md`).
- **Components.** Shared React components in `src/design-system/components/`. V16 changes none of them and adds no
  markup.

## Reference

44 archived Withings Health Mate previews in `../research/reference/`; analysis in `../research/REFERENCE_ANALYSIS.md`
and `../FINAL_FIDELITY_AUDIT.md`.

## Validation commands

| Purpose | Command | Baseline result on `6f81133` |
|---|---|---|
| Tokens, icons, unit tests, build | `npm run check` | pass: 386 tokens, 67 icons, 122/122 tests, build ok |
| Approved-design contract | `node tests/e2e/smoke.mjs` | 143/144. The failure is environmental: this Chromium build reports `corner-shape: superellipse(1)` on every element. It fails identically on untouched V11. |
| Product journeys | `node tests/e2e/product.mjs` | 88/88 |
| V11 contract | `node tests/e2e/experiment-tiimo.mjs` | 111/111 |
| V16 contract | `node tests/e2e/experiment-withings.mjs` | 47/47 |
| Accessibility, approved design | `npm run test:a11y` | 0 serious or critical |
| Accessibility, V16 screens | axe-core script over the 15 V16 screens (session tooling) | 0 serious or critical |
| Screenshots | `GALLERY_THEME=withings GALLERY_ONLY=… GALLERY_OUT=… node scripts/gallery.mjs` | 49 V16 states |
| Isolation | pixel diff of the default gallery (162 states) against `59e06e8` rendered in the same browser, and of `?theme=tiimo` (49 states) against the pre-V16 captures | 162/162 and 49/49 identical |
| Lint / static analysis | **none configured** in `package.json`. The unit suite's CSS rules (token-only colours, every `var()` resolves, no primitive tokens in components) act as the static check. | — |

**Environment.** Playwright 1.56.1 expects Chromium build 1194; the container ships 1243. A container-only symlink at
`/opt/pw-browsers/chromium_headless_shell-1194/chrome-linux/headless_shell` makes the suites run. Nothing in the
repository depends on it.

## Audit tooling written for this pass (session scratch, not committed)

- **Geometry audit.** Walks every visible surface on each V16 screen and open sheet, and flags children whose corner
  radius conflicts with their container's (pill in a non-pill, non-concentric corners).
- **Style inventory.** Computed height, radius, font size and weight for 47 component classes across all screens, to
  find equivalent components that differ.
- **Focus and target audit.** Tabs through every screen checking for a visible focus indicator, and measures every
  control's hit area against 44pt, counting the shared `::before` target extension.

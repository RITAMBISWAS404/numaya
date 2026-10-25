# Progress log

This log is kept so the run can be resumed. The newest entry is last.

- **Branch:** `design/apple-impeccable-full-app`. It started from `75b095c`
  (`experiment/skill-combination-matrix`), whose product code is the Apple-only `6e4dbd1` plus the
  project-local Apple Design and Impeccable skills.
- **Worktree:** a separate `git worktree`. The main checkout (`experiment/impeccable-visual-refinement`,
  which has uncommitted work) was not touched.
- **Methodology:** Apple Design + Impeccable only. Liquid Glass, UI/UX Pro Max and the other installed
  skills are not used.

## Phase 0: baseline and inventory (done)

- Baseline tests, all passing:
  - `npm run check`: tokens, icons, unit tests 117/117 and the production build.
  - `npm run test:e2e`: smoke 144/144 and product 88/88.
  - `npm run test:a11y`: no serious or critical violations.
- Baseline gallery: 162 states in [screenshots/baseline](screenshots/baseline/README.md), captured with the
  project gallery tool. I added a `GALLERY_OUT` override so the canonical gallery folder is untouched.
- Inventory: [screen-inventory.md](screen-inventory.md), covering 28 distinct screens.
- Impeccable context: `PRODUCT.md` is copied from the user-confirmed `/impeccable init` answers of
  24 October. Impeccable's interview step was replaced by the brief, because the user asked for no
  questions.

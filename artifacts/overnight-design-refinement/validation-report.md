# Validation report

Every result below comes from a command that was actually run, in the repository's own tooling, on
the branch's final source. Logs were not committed.

## Automated checks

| Check | Command | Baseline (`75b095c`) | Final |
|---|---|---|---|
| Token freshness | `npm run tokens:check` | pass | pass (277 tokens) |
| Icon freshness | `npm run icons:check` | pass | pass |
| Unit tests (Vitest, 7 files) | `npm test` | 117 / 117 | **117 / 117** |
| Production build | `vite build` (in `npm run check`) | pass | **pass** |
| Smoke e2e (Chromium) | `tests/e2e/smoke.mjs` (in `npm run test:e2e`) | 144 / 144 | **144 / 144** |
| Product e2e (Chromium) | `tests/e2e/product.mjs` (in `npm run test:e2e`) | 88 / 88 | **88 / 88** |
| Accessibility (axe, WCAG 2.1 A/AA) | `npm run test:a11y` | no serious or critical | **no serious or critical** in all 8 audited views |
| Impeccable detector | `impeccable detect --json` on the 10 changed UI files | n/a | **0 findings** |

The 8 audited views are the prototype welcome, flow previews, chat options menu, unmatch sheet,
Discover filters sheet, Edit profile preview, photo options sheet and the design-system showcase.

## Responsive, overflow and console

These come from the smoke e2e suite and the gallery run.

- All 25 flow screens render at desktop and at 375 px, with no horizontal overflow and no console
  errors. The prototype, single-screen mode, the showcase and reduced motion are also free of console
  errors.
- iPhone 15 (393 × 852) and iPhone SE (375 × 667) have 0 px horizontal overflow.
- The gallery's 162 captures completed with no failures. These cover 393 × 852, 375 × 667 QA,
  full-page and 1440 × 900 desktop context.

## Design-contract tests that changed

Three smoke assertions encoded the previous design. They were updated to assert the new contract,
not removed or loosened:

| Check (smoke) | Before | After | Reason |
|---|---|---|---|
| Prompt surface | flat grey `rgb(242, 242, 242)`, no shadow | lavender `rgb(243, 240, 253)`, no shadow | Decision D-22: the prompt is the conversation signature. |
| Section-card hairline | first `.profile-section` on Discover | first non-prompt `.profile-section` | The prompt object deliberately has no hairline. Every other section card still must. |
| "You both like" pills | grey `rgb(242, 242, 242)` | lavender `rgb(243, 240, 253)` | One shared-interest treatment, the same as Match. |

No other test was edited. The "Step N of 3" checks still pass, because the text is kept as
screen-reader text.

## Contrast

These were measured on this branch's final build with `scripts/skill-matrix-measure.mjs`. The script
reads the foreground colour, hides the glyphs, and compares against the pixels actually rendered
behind them. Each ratio is the worst 2% of those pixels, at 393 × 852.

| Element | Ratio | Threshold |
|---|---|---|
| Primary button label (Welcome, readiness card): white on brand purple | 4.90:1 | 4.5:1 (text) |
| Prompt question on the lavender prompt object | 7.32:1 | 4.5:1 |
| "You both like" pill on Match | 7.32:1 | 4.5:1 |
| Name over the photo scrim | 4.66:1 (baseline 3.06:1) | 3:1 (large text) |
| SuperSwipe star on the photo | 4.90:1 | 3:1 (non-text) |
| Inactive tab icons, at rest and scrolled | 11.1:1 | 3:1 (non-text) |

Destructive buttons (Unmatch, Block, Delete) use the existing danger pair, which the token contrast
unit test already covers.

## Visual QA

I inspected every gallery group contact sheet, before and after. I also opened individual full-size
captures for Welcome, setup intro, Basics, Interests, Photos, Discover (card, "You both like", end of
profile, full scroll), Like back, Likes, Match, Messages, new-match chat, Unmatch sheet, Activity
Explore and details, Guests, Edit profile, Edit prompt, Settings, Readiness, Premium and Connected
accounts. I also went through the full 375 × 667 QA sheet and the desktop-context sheet.

These defects were found and fixed during QA:

- Activity details: the category caption sat flush against the title. The card's negative margin
  leaked into it, so the margin is now scoped to the card.
- Connected accounts, Blocked people, Guests: trailing actions floated mid-row. `IdentityRow` now
  fills the row.
- Unmatch rendered as a brand-purple primary action after the token change. It now uses the
  destructive style.

## Coverage

- 28 distinct product screens, 162 captured states.
- 106 states changed visibly against the baseline. The other 56 were checked and need no change:
  mainly states without primary actions or prompts, such as Messages list, Likes grid, Settings,
  Readiness, Help, and the phone and code entry states.
- See [screen-inventory.md](screen-inventory.md) for status by screen.

## Not verified

- **Browsers other than Chromium.** Only Chromium is installed; WebKit and Firefox were not run.
- **Real devices and real keyboards.** The on-screen keyboard is the prototype's simulation.
- **Dark mode.** The prototype has no dark theme, so there is nothing to verify.
- **Interaction feel (motion, springs).** This was not changed and not re-reviewed frame by frame.
  Reduced-motion rendering is covered by the e2e suite.

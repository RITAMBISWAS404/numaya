# Architecture

## Production framework

**Not established.** This repository is a browser prototype built with React 19 and Vite 8. It does
not decide the mobile app architecture (options: SwiftUI, React Native/Expo, Flutter, PWA;
see [unknowns P-01](../research/unknowns.md#product-decisions-still-open)).

The design system is kept portable for that decision:
- `tokens/numaya.tokens.json` is platform-neutral (DTCG). A native target adds a generator next to
  `scripts/tokens.mjs`; the token names and semantics stay.
- Component specifications live in [`../design-system/`](../design-system/README.md), independent
  of React.
- The React components are a reference implementation of those specs.

## File organisation

```
tokens/numaya.tokens.json     token source (edit this)
scripts/tokens.mjs            token build and --check
src/design-system/            reusable library (index.js is the public API; tokens.* generated)
src/prototype/                onboarding prototype (screens, simulator chrome, presentation brief)
src/showcase/                 design-system showcase (showcase.html)
src/data/, src/lib/           shared data (countries) and utilities (hooks, cx, contrast)
tests/unit/                   Vitest: tokens, contrast, CSS usage, component contracts
tests/e2e/smoke.mjs           Playwright smoke run with screenshots
docs/                         research, design system, engineering
```

Rules: product code imports only from `src/design-system/index.js`. Simulator chrome (keypad,
status bar, iOS banner) stays in `src/prototype/sim` and is excluded from product tokens.

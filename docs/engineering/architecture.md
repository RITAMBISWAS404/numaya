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
src/flows/                    product flow previews (flows.html; ?screen=<id> for one screen)
  frame.jsx                   screen scaffold and the five-section tab bar
  data.js                     fixtures: people, activities, areas, likes, PROTOTYPE_NOW
  model.js                    pure rules: activity phases, joining, filters, likes, readiness
  store.js                    reducer + localStorage persistence (numaya.preview.v1)
  screens.jsx                 onboarding, Home, match, Messages, Profile, Edit, Settings
  activity.jsx, activity-host.jsx   Explore, details, guests / create, edit, My activities
  likes.jsx, account.jsx      Likes / Insights, Blocked, Premium, Connections, Help, Maintenance
src/data/, src/lib/           shared data (countries) and utilities (hooks, cx, contrast)
tests/unit/                   Vitest: tokens, contrast, CSS usage, component contracts
tests/e2e/smoke.mjs           Playwright smoke run with screenshots
tests/e2e/product.mjs         Playwright journeys for Activity, Likes, Messages, Profile, account
docs/                         research, design system, engineering
```

Rules: product code imports only from `src/design-system/index.js`. Simulator chrome (keypad,
status bar, iOS banner) stays in `src/prototype/sim` and is excluded from product tokens.

## Prototype data and backend dependencies

There is no backend. All state is a reducer persisted to `localStorage`, and every date rule uses
`PROTOTYPE_NOW` (Friday 23 October 2026, 12:00) so screens and tests are deterministic. These
need real services before production and are labelled as simulated in the UI:

| Capability | In the preview | Needs |
| --- | --- | --- |
| Location | Area picker from a fixed list; km on a grid | Device location with consent, geocoding |
| Activities, joins, requests | Local state; host approvals change only this device | Activity service, notifications to hosts and guests |
| Reports | Stored on this device, never sent | Trust and safety intake and review |
| Messaging | Local threads; "delivered" is a timer | Messaging service |
| Notifications | Switches only; no permission asked | Push service |
| Premium | Comparison; no prices, no billing | Store billing, entitlements |
| Instagram, Spotify | Consent and a stored flag; nothing imported | OAuth, data import, revocation |
| Verification | Phone (simulated SMS) only | Photo and ID verification |
| Maintenance | Screen opened from Prototype tools | Service status signal |

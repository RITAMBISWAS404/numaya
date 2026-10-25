# Numaya

Onboarding prototype, design system and UX research for Numaya, a premium dating app.

```bash
npm install
npx playwright install chromium   # only for the browser smoke test on a fresh machine
npm run dev                       # http://localhost:5173 (prototype) · /flows.html (product flows) · /showcase.html (design system)
npm run check                     # token check, unit tests, production build
npm run test:e2e                  # browser smoke test with screenshots
npm run test:a11y                 # accessibility audit (axe-core)
npm run gallery                   # numbered screenshot gallery of every screen and state
```

- **Prototype:** Welcome → Phone → Verify, in an iPhone simulator on desktop and full screen on
  phones. The demo code arrives as a Messages banner.
- **Design system:** tokens in `tokens/numaya.tokens.json` (generated to CSS), React library in
  `src/design-system`, interactive showcase at `/showcase.html`.
- **Product flow previews:** `/flows.html` shows 10 representative screens (profile setup, discovery,
  match, chats, chat with report and block, profile, settings) built only from the design system,
  with mock data. Buttons jump between connected screens.
- **Docs:** see [CLAUDE.md](CLAUDE.md) and [docs/](docs/).

Fonts: Fraunces and Inter (SIL OFL), self-hosted. Icons: Material Symbols Rounded (Google, Apache 2.0), extracted from `@material-symbols/svg-500`; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Brand colour: Meetup-derived purple `#7262C7` (the old pink `#F770E3` is retired; see [docs/numaya-meetup-ui-map.md](docs/numaya-meetup-ui-map.md)).

**Screen gallery:** [artifacts/ui-gallery/](artifacts/ui-gallery/README.md) holds every screen and
state in user-flow order at 393 × 852, with contact sheets. Any flow screen can also be opened on its
own, full screen, at `/flows.html?screen=<id>` (for example `?screen=edit`).

**Design review:** [artifacts/overnight-design-refinement/](artifacts/overnight-design-refinement/README.md)
records the full-app Apple Design + Impeccable refinement, with before-and-after comparisons, the screen
inventory and validation results.

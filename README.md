# Numaya

Onboarding prototype, design system and UX research for Numaya, a premium dating app.

```bash
npm install
npx playwright install chromium   # only for the browser smoke test on a fresh machine
npm run dev                       # http://localhost:5173 (prototype) · /flows.html (product flows) · /showcase.html (design system)
npm run check                     # token check, unit tests, production build
npm run test:e2e                  # browser smoke test with screenshots
```

- **Prototype:** Welcome → Phone → Verify, in an iPhone simulator on desktop and full screen on
  phones. The demo code arrives as a Messages banner.
- **Design system:** tokens in `tokens/numaya.tokens.json` (generated to CSS), React library in
  `src/design-system`, interactive showcase at `/showcase.html`.
- **Product flow previews:** `/flows.html` shows 10 representative screens (profile setup, discovery,
  match, chats, chat with report and block, profile, settings) built only from the design system,
  with mock data. Buttons jump between connected screens.
- **Docs:** see [CLAUDE.md](CLAUDE.md) and [docs/](docs/).

Fonts: Fraunces and Inter (SIL OFL), self-hosted. Icons: Solar by 480 Design (CC BY 4.0) via `@solar-icons/react` (MIT); see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Brand pink: `#F770E3`.

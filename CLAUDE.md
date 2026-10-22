# Numaya

Premium dating app. This repo holds the onboarding prototype, the design system and the UX
research. **No production framework is chosen yet** ([architecture](docs/engineering/architecture.md)).

## Start here
- How to build a screen, commands, token rules: [docs/engineering/implementation-guide.md](docs/engineering/implementation-guide.md)
- Design system: [docs/design-system/](docs/design-system/README.md) · live at `/showcase.html`
- UX research and screen specs: [docs/research/](docs/research/README.md)

## Non-negotiables
- Brand pink is exactly `#F770E3` (the only brand colour; no second dark pink). Text and glyphs on solid pink fills are dark ink, never white (white is 2.51:1). Pink text on white fails contrast, so brand-context text uses ink.
- Import UI only from `src/design-system/index.js`; style with semantic tokens only.
- Edit tokens in `tokens/numaya.tokens.json`, then `npm run tokens`. Never edit generated files.
- Do not build screens the spec does not describe. Cover every state the spec lists.
- Before committing: `npm run check` and `npm run test:e2e`.

# Numaya

Premium dating app. This repo holds the onboarding prototype, the design system and the UX
research. **No production framework is chosen yet** ([architecture](docs/engineering/architecture.md)).

## Start here
- How to build a screen, commands, token rules: [docs/engineering/implementation-guide.md](docs/engineering/implementation-guide.md)
- Design system: [docs/design-system/](docs/design-system/README.md) · live at `/showcase.html`
- UX research and screen specs: [docs/research/](docs/research/README.md)

## Non-negotiables
- Visual system follows Meetup (palette, surfaces, components); UX follows Bumble. Brand colour is Meetup's sampled purple `#7262C7` (white on it is 4.90:1); the old pink `#F770E3` is retired. Secondary Meetup colours (`--color-accent-*`) are for marks and framing only, never text. See [docs/numaya-meetup-ui-map.md](docs/numaya-meetup-ui-map.md).
- Import UI only from `src/design-system/index.js`; style with semantic tokens only.
- Edit tokens in `tokens/numaya.tokens.json`, then `npm run tokens`. Never edit generated files.
- Do not build screens the spec does not describe. Cover every state the spec lists.
- Before committing: `npm run check` and `npm run test:e2e`.

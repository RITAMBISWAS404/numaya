# Implementation guide

## Commands

```bash
npm install                       # fresh clone; add `npx playwright install chromium` for e2e
npm run dev                       # prototype at /, showcase at /showcase.html
npm run check                     # tokens:check + unit tests + production build
npm run test:e2e                  # browser smoke test → tests/e2e/artifacts/*.png
npm run test:a11y                 # axe-core WCAG 2.1 A/AA audit (fails on serious/critical)
npm run gallery                   # numbered screenshot gallery → artifacts/ui-gallery/
npm run tokens                    # regenerate src/design-system/tokens.{css,js}
```

## Screen implementation workflow

1. **Find the journey.** Locate the screen in [flow-catalogue](../research/flow-catalogue.md) and
   read its entry in [screen-specs](../research/screen-specs.md) plus the relevant rows of
   [states-and-recovery](../research/states-and-recovery.md) and the
   [decision log](../research/decision-log.md).
2. **Select components** from [components.md](../design-system/components.md) and the showcase
   recipes. Do not restyle them per screen.
3. **Build** with `Screen` / `TopBar` / `ScreenHeader` / `ScreenFooter`, semantic tokens only.
   Cover every state the spec lists: loading, empty, error, disabled, pending, success.
4. **Validate:** `npm run check`, `npm run test:e2e`, then review screenshots at 393×852 and
   375×667, including reduced motion. Add a test for any new interaction contract.

## Brand and typography rules

- The UI follows Meetup's visual system ([UI map](../numaya-meetup-ui-map.md)); UX follows Bumble.
  The brand is Meetup's sampled purple `#7262C7` (`--color-brand`); the old pink `#F770E3` is retired
  and a test fails if it renders.
- Foreground on solid purple is white (`--color-on-brand`, 4.90:1). Purple text (`--color-text-brand`)
  is for links on white; on grey or lavender use `--color-text-brand-deep`. See the
  [contrast table](../design-system/foundations.md#contrast).
- Secondary Meetup colours (`--color-accent-*`) frame and mark (avatars, badges, guidance cards,
  status icons); never text and never a second UI accent.
- Headline emphasis uses `Emphasis` (the word in `--color-text-accent`, `#C1486A`), only on hero
  headlines (Welcome, You're verified, What are you into?, It's a match). No decorative ribbons.
- Fraunces for display, Inter for everything operational. No other fonts.

## Changing tokens

1. Edit `tokens/numaya.tokens.json`: primitive for a raw value, semantic for meaning, component
   only for an explicit reusable need. Add a `$description` for any non-obvious token.
2. Run `npm run tokens`, then `npm run check`. Tests guard the exact brand value, contrast pairs,
   unresolved `var()` references, raw colours and primitive leaks.
3. Never hand-edit the generated files or hard-code colours in CSS.

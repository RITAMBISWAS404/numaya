# Implementation guide

## Commands

```bash
npm install                       # fresh clone; add `npx playwright install chromium` for e2e
npm run dev                       # prototype at /, showcase at /showcase.html
npm run check                     # tokens:check + unit tests + production build
npm run test:e2e                  # browser smoke test → tests/e2e/artifacts/*.png
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

- `#63AFE9` (`--color-brand`, `--color-text-brand-display`) is used exactly. Never substitute
  another blue for a brand-bearing element, and never change the token globally.
- Foreground on solid brand fills is white; never dark. Body-size blue text uses the named
  `--color-text-brand`. See the [contrast table](../design-system/foundations.md#contrast).
- Fraunces for display, Inter for everything operational. No other fonts.

## Changing tokens

1. Edit `tokens/numaya.tokens.json`: primitive for a raw value, semantic for meaning, component
   only for an explicit reusable need. Add a `$description` for any non-obvious token.
2. Run `npm run tokens`, then `npm run check`. Tests guard the exact brand value, contrast pairs,
   unresolved `var()` references, raw colours and primitive leaks.
3. Never hand-edit the generated files or hard-code colours in CSS.

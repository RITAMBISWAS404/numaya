# Third-party notices

## Material Symbols Rounded (icon artwork)

- **Creator:** Google — [fonts.google.com/icons](https://fonts.google.com/icons),
  [github.com/google/material-design-icons](https://github.com/google/material-design-icons)
- **Distribution used:** `@material-symbols/svg-500` 0.47.6 (pinned dev dependency; a packaging of
  Google's official SVGs, [github.com/marella/material-symbols](https://github.com/marella/material-symbols))
- **Licence:** [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0); full text shipped at
  `src/design-system/icons/LICENSE-material-symbols.txt`.
- **Use in Numaya:** the interface icons, Rounded style, weight 500, optical size 24, filled (FILL 1)
  and unfilled (FILL 0) drawings, extracted by `scripts/icons.mjs` into
  `src/design-system/icons/material-symbols.js` and rendered by the shared `Icon` component.
- **Changes:** none to the drawings; only the path data is copied, coloured by `currentColor`.
- **Visible credit:** the flow previews footer, the prototype brief and the design-system Icons
  section name Material Symbols, Google and the licence.

Earlier icon sets (Solar, then Phosphor) were removed; no other icon artwork ships.

## Fonts

- **Fraunces** (Undercase Type) and **Inter** (Rasmus Andersson), self-hosted via `@fontsource-variable`,
  under the [SIL Open Font License 1.1](https://openfontlicense.org).

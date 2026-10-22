# Third-party notices

## Solar Icon Set (icon artwork)

- **Creator:** 480 Design
- **Source:** [Solar Icons Set on Figma Community](https://www.figma.com/community/file/1166831539721848736)
- **Licence:** [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
- **Use in Numaya:** the interface icons, rendered through the shared `Icon` component
  (`src/design-system/components/Icon.jsx`). The tick inside checked checkboxes
  (`src/design-system/styles/selection.css`) inlines Solar's `check` path.
- **Changes:** stroke width set per state (1.5 / 2, 2.5 for the Pass action), colour set by the
  surrounding component. Glyph drawings are otherwise unmodified.
- **Visible credit:** the flow previews footer, the prototype brief and the design-system Icons
  section name Solar, 480 Design and the licence.

## @solar-icons/react (React wrapper)

- **Author:** Hakim Saoudi — [github.com/saoudi-h/solar-icons](https://github.com/saoudi-h/solar-icons)
- **Version:** 2.3.2 (pinned)
- **Licence:** MIT. The wrapper's MIT licence covers its code only; the icon artwork it ships stays
  under CC BY 4.0 (above).
- Not to be confused with the separate `solar-icon-set` npm package (GPL-3.0), which Numaya does
  not use.

## Fonts

- **Fraunces** (Undercase Type) and **Inter** (Rasmus Andersson), self-hosted via `@fontsource-variable`,
  under the [SIL Open Font License 1.1](https://openfontlicense.org).

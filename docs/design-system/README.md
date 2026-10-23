# Numaya design system

The reusable foundation for every Numaya screen. It covers tokens, components, interaction
contracts and the rules for extending them.

| Document | Contents |
| --- | --- |
| [foundations.md](foundations.md) | Colour roles and contrast, typography, space, radius, elevation, motion, icons, interaction states, accessibility baseline |
| [components.md](components.md) | Component catalogue: purpose, variants, states, accessibility; extension rules |
| [../research/states-and-recovery.md](../research/states-and-recovery.md) | System states and recovery contracts |

Interaction recipes (onboarding step, discovery, match, verification, permissions, safety,
settings) are live in the showcase's *Patterns* section.

Live reference: `npm run dev` → <http://localhost:5173/showcase.html>.

## Architecture

```
tokens/numaya.tokens.json        single source of truth (DTCG format)
        │  npm run tokens
        ▼
src/design-system/tokens.css     CSS custom properties (generated)
src/design-system/tokens.js      resolved manifest (generated; showcase and tests)
        │
src/design-system/styles/*.css   component styles: semantic and component tokens only
src/design-system/components/*   React components
src/design-system/index.js       public API: import from here only
```

### Token layers

| Layer | CSS name | Holds | Who may reference it |
| --- | --- | --- | --- |
| Primitive | `--p-color-purple-600`, `--p-dimension-16` | Raw values (palette, scales) | Semantic and component tokens only |
| Semantic | `--color-text-muted`, `--space-4`, `--type-body-size` | Meaning | All component and screen CSS |
| Component | `--button-height`, `--code-cell-radius` | Explicit reusable needs a semantic token cannot express | That component's CSS |

The generator enforces this: primitives must hold raw values, semantic tokens cannot reference
component tokens, references must resolve and CSS names must be unique. A test fails if any CSS
references a primitive (`var(--p-…)`), an undefined variable, or a raw colour.

Values are CSS-compatible strings. That is a pragmatic deviation from DTCG composite types, which
keeps the source readable and lets any platform transform it: Style Dictionary, a Swift or Kotlin
generator, or a React Native theme ([architecture](../engineering/architecture.md#production-framework)).

### Runtime variables

These are not tokens. They describe the device at runtime and are set by the shell (the simulator
or the real page):

| Variable | Meaning |
| --- | --- |
| `--safe-top`, `--safe-bottom` | Safe-area insets. `env(safe-area-inset-*)` on devices; 54px / 34px in the simulator |
| `--keyboard-inset` | Height covered by the software keyboard (visualViewport) |
| `--keypad-h` | Simulated iOS keypad height (simulator only) |

## Principles

1. **Semantic first.** Screens use semantic tokens and library components, never raw values.
2. **Meetup system, Numaya identity.** Meetup's purple `#7262C7` marks meaning (selected, verified,
   progress, links, the one floating action) with white on it; ink carries primary actions and
   controls; Meetup's secondary colours only frame (avatars, badges, illustrations).
3. **Expression vs operation.** Fraunces expresses (headlines, names, prompt answers); Inter
   operates (everything you read to act).
4. **States are part of the component.** Loading, error, disabled, pending and empty are
   designed, not improvised per screen.
5. **Accessible by construction.** Labels, focus, contrast and reduced motion are built into the
   primitives, so screens inherit them.

# Foundations

Values live in [`tokens/numaya.tokens.json`](../../tokens/numaya.tokens.json). This page states
the **rules**. Live swatches and specimens: `showcase.html` (Foundations section).

## Colour

| Role | Tokens | Rule |
| --- | --- | --- |
| Brand | `--color-brand` (exact `#63AFE9`), `-pressed`, `-tint`, `-subtle` | Marks, progress, focus ring, selected borders, verified mark, like/send fills, display-size emphasis. Never darkened globally |
| On brand | `--color-on-brand` (white) | The only foreground allowed on a solid brand fill |
| Brand text | `--color-text-brand-display` (exact `#63AFE9`) | One emphasised word in a display headline (≥ 26px) |
| Readable brand variants | `--color-text-brand`, `--color-brand-strong` (`#1F6FB0`, same hue) | Named variants for **body-size** brand text (links, labels) and blue fills that must carry white body text. Never used where the canonical brand is meant |
| Text | `--color-text-primary`, `-secondary`, `-muted`, `-subtle`, `-on-inverse`, `-brand-deep` | Dark text only on white, neutral or tinted surfaces |
| Surface | `--color-surface`, `-soft`, `-sunken`, `-canvas`, `-brand`, `-inverse` | Ink (`inverse`) for primary buttons and toasts |
| Border / focus | `--color-border-subtle`, `-strong`, `-brand`, `-control`; `--color-focus-ring`, `-halo` | Unchecked controls use `border-control` (≥ 3:1) |
| Feedback | `--color-danger`, `--color-success`, `--color-warning` (+ `-tint`) | Distinct from the brand palette; never use brand blue for status |
| Overlay | `--color-overlay-scrim`, `-photo`, `-hover-light` | `photo` is a functional legibility overlay on images |

### Contrast

All pairs below are enforced by `tests/unit/tokens.test.js`.

| Pair | Ratio | Status |
| --- | --- | --- |
| Primary / secondary / muted text on white | 17.9 / 10.4 / 5.4 | AA |
| `text-brand` on white, white on `brand-strong` | 5.3 | AA |
| Feedback text on white and on its tint | ≥ 4.5 | AA |
| `border-control` on white | 3.2 | Non-text AA |
| **White on `#63AFE9`** | **2.38** | **Exception.** Allowed only for glyphs (check, heart, arrow) ≥ 16px with stroke ≥ 2, where meaning is repeated by a text label or a shape cue (knob position, check mark). Never for text |
| **`#63AFE9` text on white** (`text-brand-display`) | **2.38** | **Exception.** Display size only, one word per headline, decorative emphasis of text that is also fully readable in context. Never for body, links or labels |
| `text-subtle` on white | 2.6 | Exception: placeholders and disabled labels only |

## Typography

| Role (`--type-*`) | Family | Size / line / weight |
| --- | --- | --- |
| `hero` | Fraunces | 34 / 38 / 440 |
| `display` | Fraunces | 31 / 35 / 440 |
| `headline` | Fraunces | 26 / 30 / 440 |
| `title-sm`, `title` | Fraunces | 23 / 28, 20 / 25 / 450 |
| `body`, `body-sm` | Inter | 15.5 / 23, 15 / 21 / 400 |
| `input`, `button`, `label` | Inter | 18 / 24 / 500, 16 / 20 / 600, 13.5 / 18 / 500 |
| `caption`, `micro`, `eyebrow` | Inter | 13 / 18, 12.5 / 17, 11 / 14 / 600 uppercase +0.12em |

Fraunces uses `--font-display-axes` (`SOFT 50, WONK 0`). Never bold the serif; emphasis is size
or brand colour. Numerals in inputs, codes and prices use `tabular-nums`.

## Space, size, shape

- **Spacing:** 4-point scale `--space-1…12`. Gutter `--layout-gutter` 24px (dense: 16px). Section
  gap 32px, stacked controls 12px.
- **Sizes:** touch target ≥ `--size-touch-min` 44px; input 56px; button 54px (sm 40, quiet 48);
  Fab 56; icon button 40 (sm 36); avatars 24/36/48/64/96.
- **Radius:** xs 8 · sm 12 · md 16 (fields, rows) · lg 20 (cards) · xl 28 (sheets) · 2xl 32 · pill.
- **Borders:** hairline 1px, selected 1.5px, focus 2px.
- **Elevation:** `--shadow-xs`, `float` (chrome over content), `card`, `button`, `sheet`, `toast`,
  `brand` (under brand fills), `knob`, `thumb`, `segment`, `panel`.
- **Layout:** single column, max `--layout-content-max` 430px; wider viewports centre it. Respect
  `--safe-top`, `--safe-bottom` and `--keyboard-inset` (runtime, see [README](README.md#runtime-variables)).

## Motion

Durations `fast 140` · `base 220` · `slow 380` · `push 460` ms; easing `out` (enter, state change),
`emphasized` (navigation, sheets), `in-out` (exit). Under `prefers-reduced-motion` the durations
collapse (1ms / 120ms / 160ms) and movement becomes fades. Spinners keep rotating as status.

## Icons

24px grid, stroke `--icon-stroke` 1.75 (2 in filled controls), round caps, `currentColor`.
Sizes 16 / 20 / 24. Icon-only controls always have an accessible label.

## Interaction states

| State | Treatment |
| --- | --- |
| Hover (pointer only) | Surface shifts one step (`soft` → `sunken`); never the only cue |
| Focus | 2px `focus-ring` outline, 2px offset; fields use an inset ring + `focus-halo` |
| Pressed | Scale 0.98 (buttons), 0.92–0.94 (round controls) |
| Selected | Brand border or fill **plus** a shape cue (check, dot, knob) |
| Disabled | `surface-sunken` fill, `text-subtle`; `disabled` or `aria-disabled` |
| Loading / pending | Spinner replaces the label or control, `aria-busy`, input locked, size unchanged |
| Error | `danger` border and text, message linked by `aria-describedby`, recovery action offered |
| Success | Result panel or inline success note |

## Accessibility baseline

Every control has a visible or accessible label. Errors are announced (`role="alert"`). Modals
trap focus, close on Escape and restore focus to the trigger. Destructive dialogs focus the safe
action. Status updates use polite live regions. System and recovery states are specified in
[states-and-recovery](../research/states-and-recovery.md).

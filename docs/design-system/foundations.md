# Foundations

Values live in [`tokens/numaya.tokens.json`](../../tokens/numaya.tokens.json). This page states
the **rules**. Live swatches and specimens: `showcase.html` (Foundations section).

## Colour

| Role | Tokens | Rule |
| --- | --- | --- |
| Brand | `--color-brand` (exact `#F770E3`), `-tint`, `-subtle` (lightened mixes of the brand; no darker second pink) | Marks, progress, selected borders and fills, verified mark, like/send fills, switches. Never darkened |
| On brand | `--color-on-brand` (dark ink) | The only foreground allowed on a solid brand fill: 7.15:1. White on `#F770E3` is 2.51:1 and is not allowed |
| Brand text | `--color-text-brand-display` (exact `#F770E3`) | One emphasised word in a display headline (>= 26px) only |
| Brand-context text | `--color-text-brand`, `-brand-deep` (resolve to ink) | Links, eyebrows, labels. Pink text on white fails, so these use the neutral ink; links stay underlined |
| Text | `--color-text-primary`, `-secondary`, `-muted`, `-subtle`, `-on-inverse`, `-brand-deep` | Dark text only on white, neutral or tinted surfaces |
| Surface | `--color-surface`, `-soft`, `-sunken`, `-canvas`, `-brand`, `-inverse` | Ink (`inverse`) for primary buttons and toasts |
| Border / focus | `--color-border-subtle`, `-strong`, `-brand`, `-control`; `--color-focus-ring`, `-halo` | Unchecked controls use `border-control` (≥ 3:1) |
| Feedback | `--color-danger`, `--color-success`, `--color-warning` (+ `-tint`) | Distinct from the brand palette; never use the brand pink for status |
| Overlay | `--color-overlay-scrim`, `-photo`, `-hover-light` | `photo` is a functional legibility overlay on images |

### Contrast

All pairs below are enforced by `tests/unit/tokens.test.js`.

| Pair | Ratio | Status |
| --- | --- | --- |
| Primary / secondary / muted text on white | 17.9 / 10.4 / 5.4 | AA |
| Ink (`on-brand`, `text-brand`) on `#F770E3` / on brand tint | 7.15 / 16 | AA |
| Focus ring (ink) on white | 17.9 | Non-text AA. The pink halo is decorative |
| **White on `#F770E3`** | **2.51** | **Not allowed.** This is why `on-brand` is ink |
| **`#F770E3` text on white** (`text-brand-display`) | **2.51** | **Exception.** Display size only, one word per headline, decorative emphasis of text that is also fully readable in context. Below the 3:1 large-text minimum, so set `--color-text-brand-display` to `text-primary` for strict compliance. Never for body, links or labels |
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

- **Spacing:** 4-point scale `--space-1…12`. Gutter `--layout-gutter` 16px (edge-to-edge: 8px). Section
  gap 32px, stacked controls 12px.
- **Sizes:** touch target ≥ `--size-touch-min` 44px; input 56px; button 54px (sm 40, quiet 48);
  Fab 56; icon button 40 (sm 36); avatars 24/36/48/64/96.
- **Radius** (compact rounded rectangles; `border-radius` is the baseline, with `corner-shape: squircle`
  layered on where supported via `shape.css`): xs 8 (tags, badges) · sm 12 (chips, inner elements) ·
  md 16 (buttons, fields, option cards) · lg 20 (cards, list groups, message bubbles, tab items) · xl 28
  (hero profile card, sheets, dialogs, the floating tab bar) · 2xl 32 (framed screens). Nested corners
  follow outer = inner + inset: the tab bar (xl 28) wraps items (lg 20) with an 8px inset. Circles stay circles (icon buttons, Fab, Pass / Like / SuperSwipe, the success badge). Identity
  avatars and their completion ring take `--shape-identity` (`superellipse(1.5)`, a soft squircle) where
  `corner-shape` is supported, and fall back to the circle.
  `pill` is only for shapes whose meaning is a pill: progress bars, switches, slider tracks, count
  badges. Never for ordinary buttons, chips, tabs or badges.
- **Borders:** hairline 1px, selected 1.5px, focus 2px.
- **Gutters:** 16px screen padding; the Discover card runs to 8px from the edges so the photo leads.
- **Reference baseline (Bumble layout, Meetup styling):** white pages; cards are white with a hairline
  and a faint shadow (20px), grouped rows 16px, photos 24px (`radius.photo`); buttons and chips are
  pills (primary ink, secondary light grey); Pass and Like are ink circles; sliders are ink. SuperSwipe is the single brand-pink action on Discover.
- **Pink footprint:** SuperSwipe, selected states, verification, progress, toggles and the match
  mark. Avatars, placeholders, empty states, info banners and completion badges are neutral.
- **Surfaces:** app screens (Discover, Chats, a conversation, Match, Profile, Settings) sit on
  `--color-surface-page`, a blush-warm neutral; cards and list groups are white and raised with a
  shadow instead of an outline, with inset dividers only between rows. Onboarding forms stay white and
  content-led. Chips are soft fills (selected adds the brand tint and ring). In chat, incoming bubbles
  are white and outgoing are ink; pink is kept for send, unread, new matches and the like action.
- **Elevation** (neutral ink, very low opacity; flat controls and fields use none): `--shadow-xs` tiny
  moving parts · `sm` cards, list groups and floating icon buttons (no ring) · `float` persistent
  floating chrome (tab bar, hero profile card) · `md` bottom sheets and panels · `lg` dialogs,
  toasts and popovers (the only tier that must clearly layer) · `button` the primary ink button.
- **Layout:** single column, max `--layout-content-max` 430px; wider viewports centre it. Respect
  `--safe-top`, `--safe-bottom` and `--keyboard-inset` (runtime, see [README](README.md#runtime-variables)).

## Motion

Durations `fast 140` · `base 220` · `slow 380` · `push 460` ms; easing `out` (enter, state change),
`emphasized` (navigation, sheets), `in-out` (exit). Under `prefers-reduced-motion` the durations
collapse (1ms / 120ms / 160ms) and movement becomes fades. Spinners keep rotating as status.

## Icons

[Phosphor Icons](https://phosphoricons.com) via `@phosphor-icons/react`, imported individually through
the shared `Icon` wrapper (no other icon family, no emoji icons). Regular weight for inactive and
secondary icons, Bold inside filled controls and small sizes, Fill selectively for active states
(active tab, liked heart). Sizes 16 / 20 / 24 (tab bar 24). Icon-only controls always have an
accessible label; the icons themselves are `aria-hidden`.

## Navigation

Bumble destinations and order (Profile, Discover, Chats) with Meetup styling
([UI map](../numaya-meetup-ui-map.md)): a frosted capsule floating above the bottom edge, icon over
label. The active item sits on a light-grey pill with a filled pink icon and a bold ink label. The bar
stays in the layout flow under the scrolling content, so it never covers content or composers.

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

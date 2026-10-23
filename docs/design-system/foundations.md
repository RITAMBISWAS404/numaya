# Foundations

Values live in [`tokens/numaya.tokens.json`](../../tokens/numaya.tokens.json). This page states
the **rules**. Live swatches and specimens: `showcase.html` (Foundations section).

## Colour

Meetup-derived palette (sampled values and references in the [UI map](../numaya-meetup-ui-map.md#sampled-palette-and-roles)).

| Role | Tokens | Rule |
| --- | --- | --- |
| Brand | `--color-brand` (Meetup purple `#7262C7`), `-tint`, `-soft`, `-subtle`, `-hero` | Selected chips and pills, outgoing bubbles, SuperSwipe, send, progress, verified marks, links, focus |
| On brand | `--color-on-brand` (white) | Text and glyphs on a solid purple fill: 4.90:1 |
| Accents | `--color-accent-promo`, `-pink`, `-pink-tint`, `-yellow`, `-orange`, `-green` | Meetup's secondary palette, by role only: guidance cards (periwinkle), badges and category marks, avatar and illustration framing, status icons. Never text, never a second UI accent |
| Headline emphasis | `Emphasis` → `--color-text-accent` (`#C1486A`) | One word in a hero headline (Meetup "The people platform"). 4.77:1 |
| Brand-context text | `--color-text-brand` (purple, on white), `-brand-deep` (on grey or lavender) | Links (underlined where they sit inside a sentence), eyebrows, the active tab label |
| Text | `--color-text-primary`, `-secondary`, `-muted`, `-subtle`, `-on-inverse` | Neutral greys (not blue-tinted) |
| Surface | `--color-surface`, `-soft` (Meetup grey `#F2F2F2`), `-sunken`, `-canvas`, `-brand` (lavender wash), `-inverse` | White pages; grey fills for fields, secondary buttons, incoming bubbles and quote cards; ink for primary CTAs, switches and checkboxes |
| Border / focus | `--color-border-subtle`, `-strong`, `-brand`, `-control`; `--color-focus-ring` (purple), `-halo`, `-field` | Unchecked controls use `border-control` (≥ 3:1) |
| Feedback | `--color-danger` (+ `-tint`, `-badge`), `--color-success`, `--color-warning` (+ `-tint`) | Deepened from Meetup's red and green for AA text |
| Overlay | `--color-overlay-scrim`, `-photo`, `-hover-light` | `photo` is a functional legibility overlay on images |

### Contrast

All pairs below are enforced by `tests/unit/tokens.test.js`.

| Pair | Ratio | Status |
| --- | --- | --- |
| Primary / secondary / muted text on white | 18.8 / 10.9 / 5.8 | AA |
| White on brand purple (`on-brand`), purple text on white | 4.90 | AA |
| Purple text on `brand.tint` | 4.62 | AA |
| Deep purple on lavender / grey | 7.1+ | AA |
| Emphasis pink (`text-accent`) on white | 4.77 | AA |
| Secondary text on the periwinkle guidance card | 9+ | AA |
| Focus ring (purple) on white | 4.90 | Non-text AA |
| `text-subtle` on white | 2.8 | Exception: placeholders and disabled labels only |

Purple text on grey fills is 4.4:1, so text on grey uses `text-brand-deep`.

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
- **Radius** (plain `border-radius` only: no `corner-shape`, superellipse or squircle anywhere, enforced
  by a unit test): xs 8 (tags, badges) · sm 12 (chips, inner elements) ·
  md 16 (buttons, fields, option cards) · lg 20 (cards, list groups, message bubbles, tab items) · xl 28
  (hero profile card, sheets, dialogs, the floating tab bar) · 2xl 32 (framed screens). Nested corners
  follow outer = inner + inset: the tab bar (xl 28) wraps items (lg 20) with an 8px inset. Form
  fields are 16px rounded rectangles, text areas 20px, search a pill. Avatars are rounded rectangles
  (radius 30% of the image side); the completion ring traces the same shape as a 4px round-capped
  stroke. Circles stay for genuine indicators (the verified dot, the success badge).
  `pill` is only for shapes whose meaning is a pill: progress bars, switches, slider tracks, count
  badges. Never for ordinary buttons, chips, tabs or badges.
- **Borders:** hairline 1px, selected 1.5px, focus 2px.
- **Gutters:** 16px screen padding; the Discover card runs to 8px from the edges so the photo leads.
- **Reference baseline (Bumble layout, Meetup styling):** white pages; cards are white with a hairline
  and a faint shadow (20px), grouped rows 16px, photos 24px (`radius.photo`); buttons and chips are
  pills (primary ink, secondary light grey); Pass and Like are ink pills (72×56) beside the SuperSwipe pill, which is also a pill when it floats on the photo. SuperSwipe is the single purple action on Discover.
- **Purple footprint:** SuperSwipe, selected chips and pills, outgoing bubbles, send, verification,
  progress, links and focus. Switches, checkboxes, radios and primary CTAs are ink (Meetup).
- **Surfaces (Meetup):** white pages; section cards and list groups are white with a hairline and a
  faint shadow, inset dividers between rows; quote-like content (prompt answers) sits on flat grey;
  guidance cards are periwinkle. Interest chips are white pills with a hairline (selected: purple).
  In chat, incoming bubbles are grey with ink text and outgoing are purple with white text.
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

[Phosphor Icons](https://phosphoricons.com) (MIT) via `@phosphor-icons/react` 2.1.10 (pinned),
imported per icon through the shared `Icon` wrapper. Chosen as the closest open match to the
current Meetup iOS iconography (thin rounded line glyphs; the same glyph filled in purple when
active; lavender-filled spot icons). Meetup's own set is proprietary and unpublished, so this is a
stylistic match, not Meetup's assets. No other icon family ships (credits in
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md)).

- **regular** (default): line glyphs everywhere: tabs, menus, list rows, chips, fields, top bars.
- **fill**: the current tab, Like and SuperSwipe, the match heart, the "You both like" mark,
  verified seals, setup-progress tiles.
- **bold**: line glyphs inside small marks (badge checks) or beside heavy neighbours (the Pass X).
- **duotone**: spot icons on guidance cards, empty states and permission primers (Meetup's
  lavender-filled spot icons).

Sizes 16 / 20 / 24 (tab bar 24, spot icons 22–28). Icon-only controls always have an accessible
label; the icons themselves are `aria-hidden`. Action-sheet rows carry a line icon before the label,
left-aligned, as in Meetup's options menu.

## Navigation

Bumble destinations and order (Profile, Discover, Chats) with Meetup styling
([UI map](../numaya-meetup-ui-map.md)): a frosted capsule floating above the bottom edge, icon over
label. The active item sits on a light-grey pill with a filled purple icon and a deep-purple label. The bar
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

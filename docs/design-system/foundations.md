# Foundations

Values live in [`tokens/numaya.tokens.json`](../../tokens/numaya.tokens.json). This page states
the **rules**. Live swatches and specimens: `showcase.html` (Foundations section).

## Colour

Meetup-derived palette (sampled values and references in the [UI map](../numaya-meetup-ui-map.md#sampled-palette-and-roles)).

| Role | Tokens | Rule |
| --- | --- | --- |
| Brand | `--color-brand` (Meetup purple `#7262C7`), `-tint`, `-soft`, `-subtle`, `-hero` | Selected chips and pills, outgoing bubbles, SuperSwipe, send, progress, verified marks, links, focus |
| On brand | `--color-on-brand` (white) | Text and glyphs on a solid purple fill: 4.90:1 |
| Accents | `--color-accent-promo`, `-pink`, `-pink-tint`, `-yellow`, `-orange`, `-green` | Meetup's secondary palette, by role only: badges and category marks, avatar and illustration framing, status icons. Never text, never a second UI accent |
| Headings | `--color-text-primary` | One colour per heading. No coloured-word emphasis (removed, with the `Emphasis` component and its token) |
| Controls | `--color-control-selected` (purple), `-selected-text` (white), `-track-off` (neutral) | One selected-state system: checked radios and checkboxes, switch tracks, slider intervals, selected pills and segmented options. Off states stay neutral |
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
| Secondary text on the lavender guidance card | 10+ | AA |
| Focus ring (purple) on white | 4.90 | Non-text AA |
| `text-subtle` on white | 2.8 | Exception: placeholders and disabled labels only |

Purple text on grey fills is 4.4:1, so text on grey uses `text-brand-deep`.

## Typography

| Role (`--type-*`) | Family | Size / line / weight |
| --- | --- | --- |
| `hero` | Fraunces | 34 / 38 / 520 |
| `display` | Fraunces | 31 / 35 / 520 |
| `headline` | Fraunces | 26 / 30 / 520 |
| `title-sm`, `title` | Fraunces | 23 / 28, 20 / 25 / 520 |
| `body`, `body-sm` | Inter | 15.5 / 23, 15 / 21 / 400 |
| `input`, `button`, `label` | Inter | 18 / 24 / 500, 16 / 20 / 600, 13.5 / 18 / 500 |
| `caption`, `micro`, `eyebrow` | Inter | 13 / 18, 12.5 / 17, 11 / 14 / 600 uppercase +0.12em |

Fraunces uses `--font-display-axes` (`SOFT 50, WONK 0`). Headings use one colour; hierarchy comes from size and weight, never from colouring individual words. Numerals in inputs, codes and prices use `tabular-nums`.

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
  fields are 16px rounded rectangles, text areas 20px, search a pill. Avatars are circles (Meetup);
  the completion ring traces the same circle as a 4px round-capped stroke.
- **Expressive shapes (the deliberate exception, nowhere else):** Meetup's organic droplet framing
  on empty-state illustration slots (plain elliptical `border-radius`). Match previews are 72×96
  portraits with the 20px corner; success, unmatch and block outcomes use drawn illustrations
  (`Illustration`), never a badge on a shape. No squircles or `corner-shape`.
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
  guidance cards (`InfoCard`) are a flat light-lavender wash with the icon and heading on one row and the body below. Interest chips are white pills with a hairline (selected: purple).
  In chat, incoming bubbles are grey with ink text and outgoing are purple with white text.
- **Elevation** (neutral ink, very low opacity; flat controls and fields use none): `--shadow-xs` tiny
  moving parts · `sm` cards, list groups and floating icon buttons (no ring) · `float` persistent
  floating chrome (tab bar, hero profile card) · `md` bottom sheets and panels · `lg` dialogs,
  toasts and popovers (the only tier that must clearly layer) · `button` the primary ink button.
- **Layout:** single column, max `--layout-content-max` 430px; wider viewports centre it. Respect
  `--safe-top`, `--safe-bottom` and `--keyboard-inset` (runtime, see [README](README.md#runtime-variables)).

## Responsive

Single column, max `--layout-content-max` (430px), centred on wider screens; the showcase and
flow previews lay frames out in a grid at desktop. QA viewports: 393 × 852 (reference), 375 × 667
(small phone) and 1440 × 900, including long scroll positions (gallery groups 5 and 6).

- Pills wrap their label inside the pill (`max-width: 100%`) rather than widening the screen.
- The new-match rail scrolls horizontally; portraits keep 72 × 96.
- The composer grows to 120px, then scrolls; the field is a 20px rounded rectangle at every height.
- On phones 700px tall or less, the profile-setup screen drops the wordmark so the step cards stay
  in view; the CTA stays pinned in the footer.

## Motion

Durations `fast 140` · `base 220` · `slow 380` · `push 460` ms; easing `out` (enter, state change),
`emphasized` (navigation, sheets), `in-out` (exit). Under `prefers-reduced-motion` the durations
collapse (1ms / 120ms / 160ms) and movement becomes fades. Spinners keep rotating as status.

## Icons

**Material Symbols Rounded** (Google, Apache 2.0). Source: the version-pinned official SVG
distribution `@material-symbols/svg-500` (dev dependency, weight 500, optical size 24).
`scripts/icons.mjs` extracts only the symbols Numaya uses, filled (FILL 1) and unfilled (FILL 0),
into the committed module `src/design-system/icons/material-symbols.js`; `npm run icons:check`
(part of `check` and `build`) fails if it is stale. Production ships no icon font and makes no remote
request. Licence: `src/design-system/icons/LICENSE-material-symbols.txt`, credits in
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

- **One wrapper:** `Icon` (semantic names, official symbol names mapped in `scripts/icons.mjs`).
  Add an icon there, then `npm run icons`.
- **Filled by default** (FILL 1). The unfilled drawing (`weight="outline"`) only where it marks a
  different state: inactive tabs beside the filled current tab.
- **Sizes:** 18 inside pills, 20 compact rows and buttons, 24 standard and navigation, 26–28
  large actions and spot icons. Always square, `currentColor`, aligned by the container.
- **No decorative containers:** plain glyphs; no circles around add / remove, no tiles behind
  empty-state, primer or tip icons, no badge stacked on a shape. The verified mark is the single
  filled `verified` seal (on avatars it gets a white outline painted under the fill, not a disc).
  Kept on purpose: the match heart's white disc, which bridges two photos and needs it for
  legibility; solid action buttons (send, SuperSwipe, Pass, Like), which are controls, not decoration.
- **Illustrations** are separate from icons: original SVG scenes in `Illustration`
  ([illustration map](../numaya-illustration-map.md)).
- **Pills are text-first.** Interest pills carry no leading icon; their add / remove affordance is the
  plain `add` / `remove` glyph. Profile-fact chips keep a leading icon only where it names the
  category (looking for, lives in). **No emoji as UI icons;** emoji only when users type them as content.
- Icons are `aria-hidden`; icon-only controls always carry an accessible label.

## Navigation

Five sections in the PRD's order (Home, Activity, Likes, Messages, Profile) with Meetup styling
([UI map](../numaya-meetup-ui-map.md)): a frosted capsule floating above the bottom edge, **icons
only**. The active item sits on a light-grey pill with a filled purple icon; inactive items use the
outline glyph in ink. Labels are not drawn: each item's label is its accessible name ("Likes, 5 new")
and its pointer tooltip. Items are at least 64 × 52 at 375px. The bar stays in the layout flow under
the scrolling content, so it never covers content or composers.

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

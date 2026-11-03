# V16 component rules

**Scope and constraints:**
- Every rule lives in `src/design-system/styles/theme-wth.css` and is scoped to `.theme-wth`.
- No rule changes a box: every edge is an inset box-shadow, and sizes, spacing and line-heights are
  V11's ([V11_LAYOUT_CONTRACT.md](V11_LAYOUT_CONTRACT.md)).
- Values are `--wth-*` roles ([TOKENS.md](TOKENS.md)).

**Focus:** for every control, a 2px solid ring in the accent (`#4F65CB`), on `:focus-visible`. Fields
show focus as a 2px inset accent edge instead.

**Pressed:** V11's pressed behaviour is inherited unchanged in every component. V16 adds no pressed
style.

## Actions

| Control | Default | Hover | Disabled | Reference |
|---|---|---|---|---|
| Primary button, FAB | ink fill, white text, 12px | body-grey fill | taupe `#C4C1BC`, grey label | "Next", "Confirm", "Done" |
| Secondary button | white, 1px inset ink edge, ink text | canvas fill | taupe, no edge | "Not now", outline buttons |
| Quiet button | ink text, no fill | underline, 4px offset | grey text | "Check my Achieve tab" |
| Destructive | red fill, white text | (V11) | taupe | the "Exit" sheet |
| Small button (`.btn--sm`) | pill | as its variant | as its variant | "Add a Reminder" |
| Icon button | white circle, 1px edge | (V11) | (V11) | the round header buttons |

**Discover actions:**
- SuperSwipe: accent fill, white star.
- Pass: white with an ink edge.
- Like: ink.

**Composer:**
- The send button is ink.
- While empty it is disabled and takes the taupe.

## Selection

| Control | Off / idle | On / selected |
|---|---|---|
| Switch | track fill with a 1px edge (3.43:1); white knob with an edge | green `#3C7D40` with a white knob; no edge |
| Radio | V11's native radio, `accent-color: ink` | black ring and dot |
| Checkbox | 4px corners, `accent-color: ink` | black fill, white tick |
| Option card | white card | 1.5px inset ink edge, plus the black radio |
| Filter tab, segmented item | no fill, grey text; count in grey | blue tint, deep-blue text; count deep blue |
| Interest chip | white, `line` edge | tint, deep-blue text, accent edge |
| Chip in a chip group (Edit) | white, `edge`-colour edge (3:1, since it is an input) | as interest chip |
| Slider | track `#E4E4E6`, or `#D6D4D0` inside sheets; fill in the accent; V11's white thumb | (continuous) |
| Tab bar item | grey icon and label | ink icon and label |

## Containers

| Component | Treatment |
|---|---|
| Page | canvas `#F4F3F1` |
| Card, list group, prompt card, readiness card | white, 16px, no edge, no shadow |
| Info card | blue tint; icon in the accent |
| Sheet | white, V11's grabber in the track colour, `shadow-sheet`; groups inside take the canvas |
| Row | label in body grey; icon in the accent; separators in `line` |
| Field, search, composer | white, 12px, 1px `edge`; focus 2px accent |

## Type

| Element | Face | Weight | Case |
|---|---|---|---|
| Page titles, names, match title, welcome | Hanken Grotesk | 700 | sentence case |
| Section and sheet titles | Hanken Grotesk | 600 | sentence case |
| Prompt answers | Hanken Grotesk | 500 | sentence case |
| Navigation title (`.topbar__title`) | Inter | 700, 12px, 0.14em | UPPERCASE |
| Eyebrows: list, slider-group and option-card legends; profile section titles; "You both like" on Like back | Inter | 600, 11px, 0.08em, muted | UPPERCASE |
| Everything else | Inter | V11's | V11's |

**Eyebrow exclusions:** two labels keep sentence case, because their width sets a shared line:
- the match's "You both like";
- the Edit interests label.

## Signals and people

**Signals:**
- **Unread counts, notification dots:** red.
- **"New" badge, verified mark:** the accent.
- **"Your move":** tint, with deep-blue text.
- **The profile-readiness score tag:** ink.

**People:**
- **Avatars:** circles in the tint with a deep-blue Hanken initial.
  - On the match, your own avatar is white, so it stands out on their tinted scallop.
- **Match queue portraits:** 72 × 96 rounded rectangles, 16px, with an accent ring when new.
- **Photo placeholders:** track grey.
  - Over a real photo, V11's black fade stays, so the name stays legible.

**Messages:**
- **Mine:** accent with white text.
- **Theirs:** white with ink text.

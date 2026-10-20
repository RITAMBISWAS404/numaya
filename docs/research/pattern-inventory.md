# Component and pattern inventory (derived from the journeys)

This inventory groups every reusable UI element found in the reference journeys. It is the input
to the Numaya component catalogue ([`../design-system/components.md`](../design-system/components.md)).
**Uses** cites screen IDs from [flow-catalogue.md](flow-catalogue.md).

Legend: **P** primitive (generic, content-agnostic) · **C** composite (built from primitives) ·
**X** product pattern (domain-specific, multi-component).

## Actions

| Element | Tier | Uses | Notes |
| --- | --- | --- | --- |
| Full-width button (primary, secondary, quiet, destructive) | P | B-02, B-03, B-52, B-53, B-61 | Pill shape; destructive as text in sheets |
| Circular next button | P | B-04, B-07, B-10–B-17 | Disabled until the step is valid |
| Icon button (round, plain) | P | Back, close, ⋯, filter, undo, gear | 40–44 px target |
| Floating action (SuperSwipe, like / pass) | C | B-30, B-32 | Large round, icon-only |
| Text link / inline link | P | Terms, *Change number*, *What's this?* | Underlined |
| Action sheet | C | B-45, B-71 | List of actions; destructive last |

## Inputs and selection

| Element | Tier | Uses | Notes |
| --- | --- | --- | --- |
| Text field (labelled) | P | B-09, B-10, B-24 | Label above, soft fill |
| Segmented date field | C | B-10 | Month / Day / Year |
| Phone field + country selector | C | B-04, B-05 | Selector opens a searchable list |
| Code input (6 cells) | C | B-07 | Auto-submit, paste, autofill |
| Search field | P | B-05, B-17, B-42 | Leading icon, clear button |
| Textarea + counter | P | B-24, B-27 | Remaining characters |
| Chip (toggle, removable, with icon) | P | B-13, B-17, B-18, B-24, B-30 | Single or multi select, quota |
| Chip tabs with counts | C | B-46 | Filter content in place |
| Radio option card (title + description) | C | B-11, B-14 | Selected border; expandable detail |
| Checkbox option card / list | C | B-20, B-35 | Max selections |
| Switch row with explanation | C | B-13, B-34, B-70, B-74 | Pending spinner state (B-73) |
| Slider and dual range slider | P | B-34, B-35 | Value summary above |
| Segmented control | P | B-23, B-34 | Two to three options |

## Content and media

| Element | Tier | Uses | Notes |
| --- | --- | --- | --- |
| Avatar (sizes, ring) | P | B-23, B-42, B-44 | Completion or countdown ring |
| Photo slot / grid (main, numbered, add, remove, reorder) | C | B-15, B-24 | 3×2 |
| Discovery card (photo, overlay, badges, actions) | X | B-30 | Full-bleed with gradient-free legibility scrim |
| Profile tile (portrait, name, heart, locked/blurred) | C | B-33, B-46 | Carousel/grid |
| Prompt card (question + answer) | C | B-24, B-32 | Editable and read-only |
| Badge (verified, new, premium, count) | P | B-30, B-42 | Icon + label |
| Tag ("Your move", "Most popular", "Save 53%") | P | B-42, B-61 | Small uppercase or pill |
| List row (icon, label, value, chevron / switch / lock) | C | B-24, B-70 | Grouped rounded sections |
| Section header + helper | P | B-24 | Title + one-line description |
| Tip / promo card | C | B-24, B-43 | Icon, title, body, optional chevron |
| Completion tile | C | B-21 | Illustration, label, "N of M added" |
| Comparison table | C | B-60, B-64 | Feature × tier with checks |
| Plan card | C | B-61 | Selected, ribbon, discount |
| Feature carousel with dots | C | B-61 | Paged, auto or swipe |

## Navigation and progress

| Element | Tier | Uses | Notes |
| --- | --- | --- | --- |
| Top bar (back, title, actions) | C | Most | Large-title variant (B-23, B-42) |
| Progress bar / segments | P | B-09–B-20 | Onboarding only |
| Tab bar (5 items, badge dot) | C | B-23, B-30, B-42, B-46 | Icon + label |
| Photo progress segments | P | B-30 | Per-photo bars at the top of the card |
| Page dots | P | B-22, B-61 | Carousels |
| Countdown ring / pill | P | B-33, B-42 | Time-limited states |

## Feedback and overlays

| Element | Tier | Uses | Notes |
| --- | --- | --- | --- |
| Bottom sheet (grabber, header, scroll body, footer) | P | B-12, B-20, B-50–B-56 | Primary modal surface |
| Floating status pill | P | B-06, B-07 | "Loading" |
| Spinner (inline / row) | P | B-73 | |
| Coach mark / tooltip with step count | C | B-31, B-41 | "Got it · 2 of 2" |
| Result panel (icon, title, body, action) | C | B-52, B-54, B-62 | Success confirmation |
| System alert | P | B-62 | Platform alert style |
| Empty state (illustration, title, body, action) | C | B-43 | One next step |
| Consequence list | C | B-53 | Icon + statement rows |

## Product patterns

| Pattern | Uses | Composition |
| --- | --- | --- |
| Multi-step onboarding step | B-04–B-20 | Top bar + progress, header, form body, footer (meta + next) |
| Contextual paywall | B-61 | Sheet / full screen: feature carousel, plan cards, legal, CTA |
| Safety report | B-50–B-52 | Sheet flow: reasons → detail → result |
| Unmatch | B-53, B-54 | Consequences → confirm → optional reason |
| Verification | B-56–B-58 | Primer → capture → pending → result |
| Match celebration | B-40, B-41 | Photos, title, composer |
| Conversation | B-44 | Header, message list, composer, ⋯ menu |
| Filter editing | B-34, B-35 | Segmented groups of filter cards, sticky apply |
| Settings group | B-70, B-74 | Rounded groups of list rows with footnotes |

# Numaya V6: palette experiment

**Start here:** [contact-sheet.png](contact-sheet.png)

V6 applies the supplied Numaya palette to the V5 Tiimo-inspired UI. It changes colour and surface
hierarchy only:

- Layout, typography, component sizes and interactions are unchanged.
- Every component keeps its V5 shape: the computed radii on nine screens are identical to V5.
- The Discover fade and the Match composition are unchanged.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v6` |
| Starting commit | `2d63542`, the head of `experiment/tiimo-inspired-v5`, fetched and verified |
| Implementation commit | `de7a3f8` |
| Final commit | the commit that adds this folder (see the branch head) |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

Open `http://localhost:5173/flows.html?screen=interests&theme=tiimo`. Replace `interests` with
`basics`, `photos`, `discovery`, `like-profile`, `likes`, `match`, `chats`, `chat`, `prompt` or
`activity`. The welcome screen is at `http://localhost:5173/?theme=tiimo`.

The match screen shows a match after you like Maya on Discover; otherwise it shows its empty state.
Without `theme=tiimo` you get the approved design: all 25 captured states are byte-identical to the
approved design's committed gallery.

## The palette as tokens

The nine supplied colours are tokens with their exact values. Primitives are in
`primitive.color.palette.*`, roles in `color.palette.*`, and the CSS variables are
`--color-palette-*`. Brand and Card reuse the existing `#7262C7` and `#FFFFFF`.

| Token | Hex | Where V6 uses it |
|---|---|---|
| Background | `#F1F0EA` | The canvas of every themed screen and sheet |
| Card | `#FFFFFF` | Cards, option rows, conversation rows, the tab bar, incoming bubbles, and quiet fills on the canvas (fields, search, unselected pills) |
| Inset | `#F8F7F3` | Quiet fills inside white cards: unselected pills, the activity category tag, hover states |
| Brand | `#7262C7` | Primary actions, the FAB, SuperSwipe, selected outlines and indicators, sliders, your messages, verified marks |
| Purple tint | `#E5E3FA` | Selected pills and the active tab item only |
| Border | `#E6E3DD` | Subtle dividers (`border-subtle`) |
| Text | `#28262D` | Headings and body text |
| Secondary | `#77737D` | Secondary labels and descriptions inside white cards |
| Muted | `#F2F0FE` | Supporting lavender tiles: the profile prompt, info cards ("Liked you at Parkrun…", "Your first photo leads…") |

**One derived value, documented.** Secondary `#77737D` is 4.06:1 on Background and 4.32:1 on
Inset, below AA (4.5:1) for small text. Secondary text on those surfaces uses
`color.palette.secondary-strong` `#6B6771`. That is Secondary moved toward Text just far enough to
reach 4.84:1 on Background. The exact `#77737D` is used wherever it passes: on white cards, at 4.63:1.

**One existing token reused for contrast.** Brand-purple link text ("Terms", "Privacy Policy") is
4.29:1 on Background. On the canvas it uses the existing deep brand purple (purple 800); inside
cards it stays `#7262C7`.

See [qa/palette-and-contrast.png](qa/palette-and-contrast.png) for every pair, measured.

## How colour is placed

The palette is applied through two surface contexts, set once in
`src/design-system/styles/theme-tiimo.css` and inherited by every component:

- **On the canvas** (Background): quiet fills are white, so fields, search, incoming bubbles and
  pills stand off the warm canvas, and secondary text uses the derived value.
- **Inside a white card:** quiet fills are Inset off-white (white on white would vanish), and
  secondary text is the exact Secondary.

This gives one consistent surface pattern, not a colour per section:
- warm canvas, white cards on it, off-white inside them;
- purple only for actions, the active tab and selection;
- Muted only for the two supporting tile types.

The [purple usage audit](qa/purple-usage.txt) lists every purple fill, outline, text and icon on
ten screens. Compared with V5, the only change is less purple: selected pills no longer use purple
text. Photo placeholders keep their V5 neutral grey; they are not quiet fills.

## Pills

| State | V5 | V6 |
|---|---|---|
| Unselected, on the canvas (Interests, Match, Activity rail) | Light grey `#F2F2F2` | **White `#FFFFFF`**, no border, no tint, no gradient |
| Unselected, inside a white card (Discover and Like back "You both like", activity tag) | Light grey `#F2F2F2` | **Inset `#F8F7F3`**, no border |
| Selected | `#E9E4FB`, 1px purple outline, purple text | **Purple tint `#E5E3FA`**, 1px Brand outline, Brand minus/check glyph, **Text label** (11.9:1), so purple marks the state once rather than four times |
| Shape | 12px (8px on the 27px tag) | Unchanged |

Only the emoji-and-text pills changed, as in V5. Filters without emoji, buttons, badges, navigation,
avatars and inputs keep their own styling.

## Screenshots

### `final/`: 25 V6 states

These are the same 20 states as V5, plus Photos (018), the Discover filters sheet (023), the
unmatch sheet (045), the Activity filters sheet (064) and Edit prompt (108). All are 393 × 852 unless
the name says 375 × 667.

### `comparisons/`: V5 against V6

- [pills-only-v5-v6.png](comparisons/pills-only-v5-v6.png): just the pills, cropped.
- Full screens:
  - [Basics](comparisons/013-basics.png), [Interests](comparisons/016-interests-prompt.png),
    [Interests at the limit](comparisons/017-interests-max.png), [Photos](comparisons/018-photos.png)
  - [Discover](comparisons/019-discover.png), [You both like](comparisons/021-discover-you-both-like.png),
    [Discover filters](comparisons/023-discover-filters-sheet.png)
  - [Match](comparisons/030-match.png), [Like back](comparisons/059-like-profile.png),
    [Likes](comparisons/054-likes.png)
  - [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png)
  - [Activity](comparisons/061-activity.png), [Activity filters](comparisons/064-activity-filters-sheet.png),
    [Edit prompt](comparisons/108-prompt-editor.png)

### `qa/`

| File | What it checks |
|---|---|
| [palette-and-contrast.png](qa/palette-and-contrast.png) | Every token, its role and its measured contrast on each surface |
| [contrast-audit.txt](qa/contrast-audit.txt) | Every visible text element on 12 themed screens against the actual solid background behind it: 202 checked, 0 below AA |
| [purple-usage.txt](qa/purple-usage.txt) | Every purple fill, outline, text and icon per screen, and the difference from V5 |
| [shape-audit.txt](qa/shape-audit.txt) | Computed corner radius of every component on nine screens; identical to V5 |
| [discover-photo-fade-bright-fixture-393x852.png](qa/discover-photo-fade-bright-fixture-393x852.png), [dark](qa/discover-photo-fade-dark-fixture-393x852.png) | The V5 photo fade, unchanged |
| [discover-placeholder-solid-band-393x852.png](qa/discover-placeholder-solid-band-393x852.png) | No photo, so the solid band and no gradient |
| [match-scallop-photo-fixture-393x852.png](qa/match-scallop-photo-fixture-393x852.png), [375x667](qa/match-scallop-photo-fixture-375x667.png) | Their photo clipped by the scallop, and your rounded-square photo on its lower-left edge |

The photo captures use **canvas-drawn test patterns, not photographs**; the repo has no profile
photography.

## Validation

| Check | Result |
|---|---|
| Tokens / icons | pass (325 tokens) / pass |
| Unit tests (Vitest) | **117 / 117** |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **56 / 56** |
| Accessibility (axe, 10 views including the themed Welcome and flows) | **0 serious or critical** |
| Default mode without the flag, 25 states | byte-identical to the approved design's gallery |
| Rendered contrast (in the e2e suite) | 205 text elements on the themed screens and the match, all AA |

New and updated experiment checks:
- **Palette:** the nine tokens have their exact values, and the theme's canvas, text, border and
  brand resolve to them.
- **Pills:**
  - unselected pills are white on the canvas and Inset inside cards, with no border;
  - none uses the purple tint or Muted;
  - selected pills are the purple tint, with a 1px Brand outline, a dark label and a Brand
    indicator.
- **Bubbles:** incoming bubbles are white on the warm canvas.
- **Unchanged from V5:** the 23 pinned component shapes, the rendered Discover fade, the scallop
  clip, your rounded photo and the absent heart.

## Remaining limitations

- **Profile and Settings are outside the experiment.** They are not part of the 12 Tiimo-themed
  screens and render the approved design even with the flag, which a scoping test enforces.
  Bringing them into the theme would be a scope change, so I didn't make it.
- **The derived secondary.** `#6B6771` is not in the supplied palette. It is the minimum change
  that keeps secondary text accessible on the warm canvas.
- **Light photos on the warm canvas.** With a very light photo, the scallop's contour softens
  against Background. The test pattern shows it; real photos need a look.
- **Brand purple text on the canvas** uses the deep brand purple for contrast. Inside cards it stays
  `#7262C7`.
- Only Chromium was tested.

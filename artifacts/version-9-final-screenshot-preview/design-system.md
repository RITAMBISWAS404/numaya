# Numaya V9 design system: monochrome with a purple accent

V9 refines V8 into a predominantly monochrome UI:
- white and neutral greys build the hierarchy;
- purple `#7262C7` is the one accent;
- geometry is tighter, with no circular UI.

The research behind these choices is in [mobbin-research.md](mobbin-research.md).

**Where it lives:**
- tokens: `tokens/numaya.tokens.json` (run `npm run tokens`);
- components: `src/design-system/styles/theme-tiimo.css`;
- flow screens: `src/flows/theme-tiimo.css`.

**Scope:** everything is scoped to `.theme-tiimo`, which appears only with `?theme=tiimo`. Without
the flag, all 162 gallery states are byte-identical to the approved design
([qa/default-mode-unchanged.txt](qa/default-mode-unchanged.txt)).

## 1. Palette

V9 replaces the warm V6–V8 palette, which only the experiment used. Its values are tokens:
primitives in `primitive.color.palette.*`, roles in `color.palette.*`, CSS variables
`--color-palette-*`.

| Role | Value | Use |
|---|---|---|
| `canvas` | `#FFFFFF` | The app background |
| `surface` | `#FFFFFF` | Outlined modules and groups, floating chrome |
| `surface-secondary` | `#F7F7F8` | Gentle separation without elevation: information containers, the readiness meter, the Welcome stickers |
| `surface-inset` | `#F0F0F2` | Recessed controls: fields, search, composer, text areas, unselected chips and filter tabs, the active tab item, incoming bubbles, avatar fallbacks |
| `border` | `#E4E4E7` | Outlines and dividers |
| `brand` | `#7262C7` | Primary actions, selection, the active tab icon, SuperSwipe, unread counts, your messages |
| `brand-foreground` | `#FFFFFF` | Text and icons on purple (4.90:1) |
| `text` | `#28262D` | Primary text and headings |
| `secondary` | `#77737D` | Secondary text on white |
| `secondary-strong` | `#6B6771` | Secondary text on the grey surfaces |
| `muted` | `#929099` | Disabled text and icons only |
| `disabled` | `#EAEAED` | Disabled control surfaces |
| `photo-fade` | black | The one gradient (section 7) |

**Values changed from the brief's starting map.**
- **Secondary text on grey.** `#77737D` is 4.63:1 on white but only 4.33:1 on `#F7F7F8` and
  4.07:1 on `#F0F0F2`, below AA. Text inside the grey surfaces therefore uses `#6B6771` (5.16:1
  and 4.85:1).
- **Muted `#929099`.** It is 3.15:1 on white, so it is used only for disabled foregrounds, which
  are exempt from contrast minimums.

**Consolidated.** The warm palette, the V7 canvas and recessed tokens, the category pastels
(`color.tiimo.*`) and the separate card shadow are removed. Only the experiment used them, and
nothing references them any more.

**Not used as surfaces:**
- warm neutrals;
- lavender (the approved "brand surface" and "brand tint" roles resolve to `#F0F0F2` inside the
  theme);
- category pastels (the interest-set emoji holders and Welcome stickers are neutral);
- avatar identity tints.

The e2e suite fails if any light background on a themed screen is not a neutral grey.

## 2. Surfaces

| Treatment | Look | Used for |
|---|---|---|
| **Canvas** | White | Every screen and sheet |
| **Direct content** | No fill, border or shadow: type, spacing, hairline dividers | Someone's profile sections, inbox rows (divider from the name column), headings, Likes tiles, section notes |
| **Outlined** | White, 1px `#E4E4E7`, no shadow | Your prompt, profile readiness, activity cards, settings, filter and account groups, selection rows, opener rows, secondary buttons, icon buttons |
| **Secondary** | `#F7F7F8`, no border or shadow, 10px corner | Information that belongs together: the first-photo tip, why someone liked you, the blocking note, the report note in the unmatch sheet |
| **Recessed** | `#F0F0F2`, no border or shadow | Fields, search, composer, text areas, unselected chips and filter tabs |
| **Floating** | One soft shadow: `0 4px 20px -6px` at 12% ink | The tab bar (plus a hairline), the SuperSwipe on a photo, sheets |

**How to choose:**
1. Can it sit on the canvas? Then place it directly.
2. Do you act on it as a whole, or does it group controls? Then outline it.
3. Is it information that should read as one unit? Then use the secondary grey.
4. Is it an input? Then recess it.
5. Does it sit above scrolling content? Only then give it the shadow.

**Changes from V8:**
- activity cards and cards lose their shadows and are outlined;
- primary buttons, the FAB, the Discover action row and icon buttons are flat;
- info notes, which V8 placed directly on the canvas, return to a container, now neutral grey.

**Rings are not elevation.** A few elements keep a thin, unblurred ring so overlapping or adjacent
images stay readable:
- the white ring on your match photo;
- the white ring around tab counts;
- the white ring on the stacked activity avatars;
- the brand ring on an unopened new match.

The e2e elevation check allows these and nothing else.

## 3. Geometry

The V9 scale is set by component size. The tokens are `--tiimo-radius-*`.

| Token | Value | Components |
|---|---|---|
| `tag` | **6px** | Badges and labels (24px), counts (18–20px), checkboxes and radios, photo order and remove buttons, switch thumbs, 24px avatars, emoji holders |
| `pill` | **8px** | 36px chips (emoji pills, filter tabs, fact chips, segmented options), slider thumbs, 36px avatars |
| `control` | **10px** | Buttons, icon buttons, the send button, the active tab item |
| `item` | **10px** | Fields, search, composer, selection rows, photo slots, information containers, new-match portraits, 48px avatars |
| `feature` | **12px** | Cards and groups, your prompt, bubbles (4px tail corner), the FAB, Discover actions, the tab bar, 64px avatars, your match photo |
| `photo` | **14px** | Discover and Like back photographs, sheets, dialogs, 88–96px avatars, the Welcome stickers |

A photo inset inside a card takes the card's radius minus the inset: 4px inside an activity card.
The switch track is concentric with its thumb (6 + 3 = 9px).

### Circles replaced

| Element | V8 | V9 |
|---|---|---|
| Avatars (Messages, conversation header, Profile, activity attendees) | circles | Rounded squares, 6–14px by size; fallbacks `#F0F0F2` with an ink initial |
| Profile readiness ring around your avatar | circular ring | Removed. The "73" label stays, as a 6px tag |
| Readiness meter | circular ring | A `#F7F7F8` rounded square with the score and a 4px bar filled to it (still `role="meter"` with its value) |
| Radios | circles | 6px rounded squares with a square inner mark. Checkboxes stay 6px squares with a tick, so the two remain distinct |
| Switch | capsule track, round thumb | 9px track, 6px thumb; the thumb's position still says on or off |
| Slider thumbs | circles | 28px rounded squares, 8px corner, same hit area |
| Tab counts, unread count | circles | 6px rounded rectangles |
| Icon buttons (back, close, filters, more, settings) | 12px squares | 10px squares, outlined |
| FAB, Pass, Like, SuperSwipe | 16px / 28px capsule | 12px rounded rectangles; the star icon is unchanged |
| Tab bar, active item | capsules | 12px and 10px rounded rectangles |
| Progress segments | capsules | 3px-corner bars |

**Kept:** the match scallop. It is an SVG mask, not a radius, so it is neither a circle nor a
rounded square. Your photo overlaps its lower-left edge as a 12px rounded square (10px on short
phones).

**Out of scope:** the Numaya wordmark's dot (logo artwork) and illustrations.

[qa/geometry-audit-v8-v9.txt](qa/geometry-audit-v8-v9.txt) lists each component's radius on nine
screens in V8 and V9. Its element inventory counts 17 circle rows and 22 capsule rows in V8, and
0 of each in V9. The e2e geometry check covers the 15 themed screens and the match, including
pseudo-elements.

## 4. Navigation

| | V8 | V9 |
|---|---|---|
| Height | 64px | **56px** |
| Inner padding / gap | 6px / 4px | **4px / 0** |
| Shape | Capsule | **12px rounded rectangle** |
| Surface | White with a background blur, hairline plus a two-layer shadow | **White, hairline plus one soft shadow layer**, no blur |
| Active item | Neutral capsule | **`#F0F0F2` 10px rounded rectangle** behind the filled purple icon |
| Icons | 24px | **24px (unchanged)** |
| Touch targets | 68 × 52 | **72 × 48** (all ≥ 44 × 44) |

These are unchanged and tested: labels, `aria-current`, tab routing and red notification counts.
See [comparisons/navigation-v8-v9.png](comparisons/navigation-v8-v9.png).

## 5. Status labels

All labels share one shape (24px tall, 6px corner, semibold micro text) and carry one of four
semantic tones.

| Tone | Look | Used for |
|---|---|---|
| **Neutral** | `#F0F0F2` with ink, or white with ink on a photo | "Your move", "Matched", "Snoozed", "You're going" |
| **Emphasis** | Deep purple text (8.23:1 on white) on white or grey | "New" on a like, "Live now" |
| **Strong** | Solid purple with white | The unread message count |
| **Alert** | The approved red with white (5.64:1) | Notification counts on the tab bar |

On photographs, "Verified" and "New here" keep the approved dark translucent label. The verified
seal stays a purple glyph. The readiness score ("73") is an ink 6px tag.

## 6. Filters, chips and selection

- **Likes and Messages filter tabs.**
  - The active tab is solid purple with a white label and count, and **no checkmark**.
    `aria-pressed` still marks it.
  - Inactive tabs are `#F0F0F2` with no outline.
- **Emoji-and-text pills** (interests, the Activity category rail, shared interests).
  - Unselected pills are `#F0F0F2`; selected pills are solid purple with a white minus or check.
  - The check stays here because it means "added".
  - The pill shape is an 8px rounded rectangle.
- **Selection rows** (Basics, Your prompt, Activity filters): white with the 2px purple ring when
  selected.
- **Checkmarks are kept** wherever they mark a choice: checkboxes, the Activity rail and interest
  chips.

## 7. Discover header and photo fade

- **Header.** The thin bar under the logo was a decorative element (`.fl-disc-head__progress`,
  `aria-hidden`), and it read as an unexplained progress indicator. It is hidden on Discover and
  Discover profile. Onboarding progress segments elsewhere are untouched and tested.
- **Fade.** With a real photograph, pure black fades upward:
  - from 85% at the bottom edge to clear at 60% of the photo's height;
  - on an ease of `0.85·(1−t)^1.6`, sampled at 11 stops;
  - as its own layer: above the photo, below the name, badges and SuperSwipe, clipped by the 14px
    corners.

  V8's fade peaked at 72% opacity and read weak.
- **Measured result** ([qa/discover-fade-profile.png](qa/discover-fade-profile.png)): on a bright
  synthetic photo, the fade darkens rows steadily to 79% just above the corners (V8: 68%). No step
  between rows sampled 4px apart exceeds 0.9%, so there is no band edge.
- **Placeholders** (no photo) get no gradient and keep their solid translucent ink band behind the
  name.
- See [comparisons/discover-photo-fade-v8-v9.png](comparisons/discover-photo-fade-v8-v9.png). The
  repo has no photography, so the fixtures are synthetic: drawn per pixel with sky, horizon,
  textured ground, grain and a figure.

## 8. Screens

| Screen | V9 treatment |
|---|---|
| Discover, Discover profile | White canvas, no header bar, outlined icon buttons, 14px photo with the new fade, direct sections, flat Pass/Like, floating SuperSwipe |
| Discover filters, Activity filters | White sheet, outlined groups and rows, rounded-square thumbs and radios |
| Likes | Filter tabs without a checkmark; 12px tiles; "New" white with deep purple, "Matched" neutral |
| Like back | Secondary-grey "Liked you at…" container; direct shared interests; outlined Pass, purple Like back |
| Match | Scallop kept (neutral photo grey when there is no photo); your photo a 12px rounded square; recessed composer |
| Messages | Rounded-square avatars and new match; rows with inset dividers; neutral "Your move"; purple unread square |
| Conversation | Rounded-square header avatar; purple bubbles for you, inset grey for them; recessed composer and square send |
| Profile | Rounded-square avatar without the ring; outlined prompt and readiness card with a bar meter; outlined account groups |
| Edit profile, Add photos | 10px photo slots; dashed empty slots with a flat plus; secondary-grey photo tip |
| Interests, Basics, Your prompt | Inset-grey pills, purple selection; neutral emoji holders; outlined rows with square radios |
| Settings | Outlined groups, rounded-rectangle switches and slider thumbs |
| Activity | Outlined activity cards with a concentric 4px photo; neutral and emphasis labels on the photo |
| Welcome | White, neutral sticker tiles with a hairline, flat |

## 9. Contrast

The rendered audit checked 310 text elements on 15 themed screens against the colour behind each
one: **0 below AA** ([qa/contrast-audit.txt](qa/contrast-audit.txt)).

Key pairs:

| Pair | Ratio |
|---|---|
| Ink on white | 14.94:1 |
| Ink on `#F7F7F8` | 13.96:1 |
| Ink on `#F0F0F2` | 13.13:1 |
| Secondary `#77737D` on white | 4.63:1 |
| Secondary-strong `#6B6771` on `#F0F0F2` | 4.85:1 |
| White on purple | 4.90:1 |
| Deep purple on white | 8.23:1 |
| Deep purple on `#F0F0F2` | 7.23:1 |
| Border on white (non-text) | 1.27:1, always with a white surface either side |

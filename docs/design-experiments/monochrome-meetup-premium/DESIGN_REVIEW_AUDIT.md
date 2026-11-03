# Design review audit

## Starting point
The starting point is Monochrome Meetup (`0003d17`). Its own review
([../monochrome-meetup/DESIGN_REVIEW_REPORT.md](../monochrome-meetup/DESIGN_REVIEW_REPORT.md))
rated every family 3–4 and named the gaps this round addresses.

| Gap at the start | Evidence | Addressed by |
|---|---|---|
| Figtree everywhere: headings and body had the same voice | All headings 600–700 Figtree; little contrast between title and text | Plus Jakarta Sans display face (TYPOGRAPHY_GUIDELINES) |
| Outlined controls: every field, secondary button, Pass and chip had a hairline | `InputSurface` 1pt `#8B8B94`, secondary `ink 30%` ring | Filled neutral `field` surface; purple edge only on focus |
| Divider-heavy lists | `ListGroup`, option groups, chat list, menus and sheet headers all ruled | Rules removed; 60pt rows and grouping by surface |
| Tab bar with labels inside a grey capsule | 5 labelled items at 11pt | Icon-only floating pill (NAVIGATION_SPEC) |
| Discover: dark photo panel heavy over placeholders | Rubric 3 for reference coherence | Image-first card: name below the photo, decision row inside the card |
| Profile: a stack of cards, not a personal page | Rubric 3 | Hero card: avatar, name, badge, interests, actions; tile grid |
| Account Health: long and row-heavy | Rubric 3 for hierarchy | Status-and-completeness hero, Bevel-style big number |
| Radii nearly uniform (14–20) | No shape roles | Role scale: tag 8, control 16, field 18, card 24, hero and sheet 32 |

## Skills used
- **`impeccable`** (`.claude/skills/impeccable`): `craft-floor.md` and `android.md` were applied as
  rules:
  - no eyebrow above a heading and no nested cards;
  - one primary per screen;
  - 48dp targets;
  - state coverage.
  - Its context loader returns the web `PRODUCT.md` (Fraunces and Inter), which is stale for
    Flutter, so only its rules were used, not its brand context.
- **`apple-design`**: used for motion restraint, press feedback, reduced motion and typographic
  tracking.
- **Not installed:** the Emil Kowalski, animation and Flutter-specific skills named in the brief
  are not in this environment. Their topics are covered by the two skills above and Flutter's own
  APIs.

## Mobbin references
This round reused the **54 screens** studied and recorded for Monochrome Meetup:

| App | Screens |
|---|---|
| Meetup | 22 |
| Jomo | 12 |
| Bevel | 10 |
| Alan | 10 |

The record is in [../monochrome-meetup/REFERENCE_AUDIT.md](../monochrome-meetup/REFERENCE_AUDIT.md).
**No new Mobbin searches were run this round.** The moves taken from that audit:
- **Meetup:** floating tab pill; image-first cards with content under the photo; personal profile
  header.
- **Bevel:** one large number with a thick bar, and "—" for data that does not exist.
- **Alan:** filled tinted info cards.
- **Jomo:** filled inputs and generous rounded shapes.

## Review cycles
Every cycle rendered the 187 golden screens at 393 × 852 @2x with the real fonts and reviewed them
family by family. All reviews are on test-renderer PNGs, **not a phone or emulator**.

| Cycle | Focus | Found, then fixed |
|---|---|---|
| 1 | Type trial, tokens, components | The trial switch survived the revert (fixed by regex). The tab pill overflowed in the Design Lab (items sized with `LayoutBuilder`). Profile chips overflowed at 200% (label style, `Flexible`). |
| 2 | Priority screens | Profile buttons truncated ("Edit pro…"): Preview became a round icon button. The name panel blocked the photo viewer: the card became image-first. The Discover details offset was hard-coded: now measured. A `GlobalKey` kept the drag offset across people: the card is now keyed by person (`81e3e29`). |
| 3 | Remaining families | Hairlines left under sheet titles, around the RSVP bar, between option, chat and menu rows: removed. Illustration slots added to the profile completion hub and "How this works". |
| 4 | Adversarial sizes and text | 12-cell matrix (320/375/390/430pt × 100/130/200%). One failure: `/paywall` at 320pt and 200%. **Three defects behind it, all fixed in shared components:** the slot caption overflowed its box; the pinned footer took most of the height; the top-bar title ran under the close button. At 200% the Discover name broke inside a word: it now steps down to 24pt (still 48pt rendered) and wraps at the hyphen. |
| 5 | Contrast | `success` on `successSubtle` measured 4.43:1. It was not rendered anywhere, but the token was darkened to `#2B774B` (4.80:1) and the pair is now tested. |

## Rubric after cycle 5 (1–5; a review aid, not proof)
**Criteria:**

| Criterion | Short |
|---|---|
| Visual hierarchy | Hier |
| Typography | Type |
| Spacing and layout | Space |
| Component consistency | Comp |
| Colour and contrast | Colour |
| Clarity of interaction | Interact |
| Reference-inspired coherence | Ref |
| Accessibility and legibility | A11y |

| Family | Hier | Type | Space | Comp | Colour | Interact | Ref | A11y | Note |
|---|---|---|---|---|---|---|---|---|---|
| Shell and tab pill | 4 | 4 | 4 | 5 | 4 | 4 | 5 | 4 | Icon-only, with tooltips and selected semantics |
| Discovery | 5 | 5 | 4 | 4 | 4 | 5 | 4 | 4 | Image-first; decision row in the card. Placeholders are grey (no demo photography). |
| Profile | 5 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | Was 3 for Ref; now a personal page |
| Account Health | 4 | 5 | 4 | 4 | 4 | 4 | 4 | 4 | Was 3 for Hier; the page below the hero is still list-based |
| Onboarding | 4 | 5 | 4 | 4 | 4 | 4 | 4 | 4 | Filled fields and code cells; purple step segments |
| Messaging | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | Filled composer in a white tray; the chat list has no rules |
| Events | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | Floating RSVP bar with no hairline |
| Settings, safety, help | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | No dividers; sheet headers without rules |
| Premium, verification | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | |

**Every family reaches 4 or more on all eight criteria.** The scores are a judgement on rendered
PNGs; they were not measured with users.

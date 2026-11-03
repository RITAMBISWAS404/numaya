# Layout guidelines

## Page
| Element | Rule |
|---|---|
| Gutter | 20pt |
| Section gap | 40pt |
| Card padding | 20pt; hero card 24pt |
| Content column | Centred at 430pt maximum on wider screens |
| Page | `canvas` grey. Content sits on white cards. |

## Composition of a priority screen
1. **The hero card** (32pt corners): the one thing the screen is about.
   - Discover: the person, with the decision row.
   - Profile: you.
   - Account Health: status and completeness.
2. **Sections** with a Jakarta 21pt title, in 24pt cards or a tile grid.
3. **Support and footnotes last**, in muted text.

Rules from `impeccable/craft-floor.md`:
- no nested cards;
- no eyebrow above a heading;
- one primary action per screen.

## Small screens and large text
These rules are verified by `test/widget/size_matrix_test.dart` on every full-app route at four
widths:

| Width | Phone class |
|---|---|
| 320pt | SE class |
| 375pt | |
| 390pt | |
| 430pt | |

Each width is tested at 100%, 130% and 200% text.

| Situation | Behaviour |
|---|---|
| Tab pill on narrow screens | Gaps shrink and items stay ≥ 48pt (`LayoutBuilder`) |
| Decision row at 320pt | Icons only; labels remain in semantics |
| Screen height < 700pt and text > 160% | The footer (primary action) **scrolls with the content** instead of being pinned, so the content keeps its room |
| Top-bar title | Padded clear of the side buttons; one line with ellipsis (the page heading repeats it) |
| Long single-word names at > 160% text | Discover name steps down to 24pt; it wraps at the hyphen |
| Illustration slots | Fixed ratio; the caption scales down inside |

## Geometry and spacing rules (final polish)
| Rule | Value |
|---|---|
| Nested corners | `inner = max(0, outer − inset)` via `AppRadii.nested`. Applies when the curves are visibly related (inset ≤ outer radius); content far inside a card keeps its own role radius (FP-06, FP-07) |
| Worked examples | Discover hero 32 − 8 = photo 24. Tab pill 32 − 6 = tint 26 (a circle on a 52pt item). RSVP bar = button 28 + inset 12 = 40. Pill-in-pill trays (composer) are concentric automatically |
| Touch targets | ≥ 48dp everywhere (`androidTapTargetGuideline`); tab items never below 48 |
| Icon to label | 8pt for a bare icon (`iconLabelGap`); 12pt for a tile or avatar (`tileLabelGap`) |
| Text start in rows | Every row in one group starts its text on the same line: tiles and avatars are both 40pt |
| Button spacing | 12pt between adjacent buttons (`AppSpacing.s3`, as in the Profile hero and the RSVP bar); never closer |
| Gutter / card padding / hero padding | 20 / 20 / 24 |
| Section gap / heading gap / item gap | 40 / 12 / 12 |
| Tab-bar clearance | The pill sits in `bottomNavigationBar`, so content never scrolls beneath it; screens end with `AppLayout.screenBottom` (24pt) |
| Sticky actions | The footer scrolls with content on screens under 700pt tall above 160% text (PR-13) |
| Authored copy | Rewrite a label rather than let it wrap or truncate; dynamic content (names, titles, messages) wraps naturally and is never truncated (FP-12) |

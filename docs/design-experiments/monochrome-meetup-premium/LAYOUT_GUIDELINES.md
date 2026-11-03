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

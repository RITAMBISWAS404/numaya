# Font and art asset inventory

## Fonts (apps/numaya_mobile/assets/fonts)

| Family | File | Use | Source and licence | SHA-256 (first 20) |
|---|---|---|---|---|
| Figtree | `Figtree-Variable.ttf` (wght 300–900) | Recommended: body, labels, controls, wordmark | google/fonts `ofl/figtree`, SIL OFL 1.1, `OFL-Figtree.txt` | unchanged from V7 |
| Plus Jakarta Sans | `PlusJakartaSans-Variable.ttf` (wght 200–800) | Recommended: headings, names, numbers | google/fonts `ofl/plusjakartasans`, SIL OFL 1.1, `OFL-PlusJakartaSans.txt` | unchanged from V7 |
| Google Sans | `GoogleSans-Variable.ttf` (wght 400–700, GRAD, opsz) | Editorial comparison only (`NUMAYA_EDITORIAL_TYPE`) | google/fonts `ofl/googlesans` (upstream github.com/googlefonts/googlesans), SIL OFL 1.1, `OFL-GoogleSans.txt`. Restored byte for byte from archived commit `47ba247`, where it was taken from google/fonts. "Google Sans" is a Google trademark; the unmodified file keeps its name and is not used for the product name. | `d0a87d835a944b8b40d0` |
| Bree Serif | `BreeSerif-Regular.ttf` (Regular 400 only) | Editorial comparison only: page, flow and empty-state titles | google/fonts `ofl/breeserif`, SIL OFL 1.1, Reserved Font Names "Bree", "Bree Serif", `OFL-BreeSerif.txt` | `fd080582d70112ef479b` |

**Comparison fonts:**
- Bree Serif is never synthetically emboldened: `AppTypography.weight` and `_style` keep it at 400.
- The two comparison faces add about 5 MB to the APK, because Flutter bundles every registered font. They could be unregistered if the comparison is rejected.

## Art

All art is V7's own, in `assets/illustrations/` and the mascot set. There is no new generated art, and V8's code-drawn SceneArt is not imported.

| Placement | Asset | State it reflects | Bounds | Semantics |
|---|---|---|---|---|
| Sent Compliment, waiting | `NumayaIllustration.mascotWaiting` | A real pending outgoing Compliment | 140 wide, centred under the message | Decorative; the title "Waiting for {name}" carries the meaning |
| Messages empty | `NumayaIllustration.noChats` | No threads and no pending Compliments | 160 wide | Decorative |
| Chat for a non-match with nothing pending | `NumayaIllustration.noChats` | No contact is allowed | 140 wide | Decorative; the title says why |

**Not supplied:** the "3D art reference" the old V8 brief mentions was never attached. Nothing was invented in its place.

**Private photos:** the demo member photos (`apps/numaya_mobile/assets/demo/photos/`, `pics/`) are private reference material. They are git-ignored, are not licensed production art, and have no private backup.

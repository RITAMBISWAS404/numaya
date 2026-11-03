# Typography

## Faces
| Face | File | Licence | Role |
|---|---|---|---|
| **Plus Jakarta Sans** (variable) | `assets/fonts/PlusJakartaSans-Variable.ttf` | OFL (`OFL-PlusJakartaSans.txt`) | Display: page, flow, section and sheet titles; names; card titles; prompt answers; metrics |
| **Figtree** (variable) | unchanged | OFL | Text and controls: body, rows, buttons, labels, captions, inputs, top-bar titles |

How the type trial was chosen: [DESIGN_EXPLORATIONS.md §1](DESIGN_EXPLORATIONS.md).

## Scale (`AppTypography`)
| Role | Face | Size/line | Weight | Tracking |
|---|---|---|---|---|
| `hero` | Jakarta | 36/42 | 800 | −0.03em |
| Discover name | Jakarta | 32/38 (24/30 above 160% text) | 800 | −0.03em |
| `pageTitle` | Jakarta | 32/38 | 800 | −0.03em |
| `flowTitle` | Jakarta | 30/36 | 700 | −0.025em |
| `headline` | Jakarta | 26/32 | 700 | −0.02em |
| `sheetTitle`, `emptyTitle` | Jakarta | 22/28 | 700 | −0.015em |
| `section` | Jakarta | 21/28 | 700 | −0.015em |
| `promptAnswer` | Jakarta | 20/27 | 600 | −0.01em |
| `card` | Jakarta | 18/24 | 700 | −0.01em |
| `metric` | Jakarta | 40/44 (52 in the Health hero) | 700, tabular | −0.02em |
| `headerCaps` (top-bar title) | Figtree | 17/22 | 600 | — |
| `body` | Figtree | 16/24 | 400 | 0 |
| `row`, `input` | Figtree | 16/22 | 500 / 400 | 0 |
| `button` | Figtree | 16/20 | 600 | 0 |
| `label`, `fieldLabel` | Figtree | 14/18 | 600 | 0 |
| `bodySm` | Figtree | 14/20 | 400 | 0 |
| `caption` | Figtree | 13/18 | — | 0 |
| `micro` | Figtree | 12/16 | — | 0 |

## Rules
- **Jakarta only at 18pt and above.** Below that its wide letterforms and loose punctuation hurt
  readability.
- **Sentence case everywhere.** The only uppercase is the event date line (`labelCaps`, +0.06em).
- **Negative tracking only on display sizes.** Body text is untracked.
- **Every role scales with the system text size.** No role caps the scale.
  - The single exception is a *step-down*: the Discover name changes from 32 to 24pt above 160% text
    so long single-word names wrap at hyphens instead of inside a word. It still renders larger at
    200% (48pt) than at 100%.
- **Numbers that are read as data use Jakarta with tabular figures.**

# Pass 4: typography, colour and visual hierarchy

Judged on the rendered screens (`screenshots/contact-sheet.png` and full-size crops), not on token definitions.

## Hierarchy, as rendered

| Level | Role | Style | Where |
|---|---|---|---|
| 1 | Tab-root page title | 30 / 36, bold | Likes, Messages, Profile, Activity |
| 1 | Name on a photo | V11 clamp, bold | Discover, Like back, Preview |
| 1 | Match title | 32–36, bold | Match |
| 2 | Flow heading | 26 / 32, medium | Onboarding |
| 3 | Section and group heading | 22 / 28, medium | All |
| 3 | Prompt answer (content focus) | 22 / 28, semibold | Discover; your prompt at 20 |
| 4 | Sheet title | 20 / 26, medium | Sheets |
| 4 | Empty-state title | 18 / 24, semibold | Empty states |
| 5 | Card title / prompt question | 15 / 20, medium, ink | Profile sections, prompt cards (unified in pass 2) |
| 5 | Row label | 16 / 22, regular | Grouped rows, choices |
| 6 | Body | 15.5 / 22 | — |
| 6 | Caption, metadata | 13.5 / 18, muted | — |
| — | Capitals | Modal header 12.5 tracked 0.16em; labels 11.5 tracked 0.06em | — |

Each level is visibly distinct in size or weight from its neighbours. The pass-2 fix removed the one place where
equal roles differed: the prompt question.

## Colour semantics, as rendered

| Colour | Means | Used for |
|---|---|---|
| Ink | Act / selected | Primary buttons, selected radios, active tab, step button, Like |
| Blue | Brand / yours | Your bubbles, SuperSwipe, checked boxes, slider interval, links, focus, unread count |
| Blue tint | Chosen / gentle | Selected tabs and chips, toast, tint buttons, the prompt-mark holder, "New" labels |
| Green | On | Switch on |
| Red | Destructive / alert | Destructive buttons, invalid field, notification dots |
| Pastels | Decoration only | Interest-set holders (never text or controls) |

No colour carries two meanings. The e2e suite scans for leftover V11 purple: none.

## Checks

| Check | Result | Evidence |
|---|---|---|
| Contrast | 0 text below 4.5:1 on the 14 flow screens (painted background traced per text node) | e2e "a11y: readable text" |
| Primary against secondary | Ink-filled against white with an ink outline, on every paired action | 059, 130, 045 |
| Selected state | Radio dot, tick, tint pill or white segment, never colour alone (shape or position too) | 013, 054, 102 |
| Disabled state | Warm grey fill with a grey label, clearly inert next to ink | 015, 047, 108 |
| Grouping by surface | White cards on stone; info boxes outlined on stone; nothing double-boxed | All |
| Decoration against content | Pastels only behind emoji; no gradients except the photo fade; one float shadow | All |

## Corrections made in this pass

None beyond those already made in pass 2 (prompt-question role, chip size, name weight). The rendered hierarchy and
colour semantics pass. No palette or decoration change was needed or made.

## Recorded, not changed

"Your move" is an outlined status label (the reference's "Withings+" style) and sits close to the outlined-pill
button style. They differ in corner (6 against pill), height (26 against 36) and weight. They are kept because both
follow the reference.

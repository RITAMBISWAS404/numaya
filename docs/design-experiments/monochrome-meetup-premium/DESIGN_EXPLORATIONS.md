# Design explorations

Every alternative here was built in Flutter and rendered on the same screens. None was a mockup.

## 1. Type: three combinations
**Evidence:** [evidence/type-trial-screens.jpg](evidence/type-trial-screens.jpg) and
[evidence/type-trial-crops.jpg](evidence/type-trial-crops.jpg).

**How it was built:** a temporary `--dart-define` switch (now removed) changed the display family.
It was rendered on Discover, Profile, Account Health, an onboarding step and Messages.

| Option | Headings | Text | Verdict |
|---|---|---|---|
| A | Figtree 700 | Figtree | Coherent but flat: titles and body share one voice |
| **B (winner)** | **Plus Jakarta Sans 700–800** | **Figtree** | Editorial and premium; the clearest heading/body contrast; numerals hold up at 52pt |
| C | Outfit 600–700 | Figtree | Geometric and friendly, but reads younger. Its round "a" fights Figtree's at small sizes. |

**Known cost of B:**
- Jakarta's comma and apostrophe sit loosely ("Bo, 22", "Let’s").
- It is wider, so long names wrap sooner (see QA).

## 2. Navigation: selected-state variants
All three are rendered in the Design Lab ("Navigation: selected-state variants"; see
[evidence/design-lab.png](evidence/design-lab.png)).

| Variant | Selected item | Verdict |
|---|---|---|
| **tint (winner)** | brand-subtle circle, purple icon | Quiet and clearly selected. The red badge dot keeps its contrast. |
| filled | purple circle, white icon | Strongest, but a red badge on purple loses contrast, and it makes a second purple primary on Discover |
| expanded | tint pill that grows to show the label | Best for wayfinding, but the icons shift sideways on every tab change; this contradicts the icons-only brief |

## 3. Discovery card
| Option | Verdict |
|---|---|
| Monochrome Meetup: name on a dark panel over the photo | Heavy over placeholders; it covered the photo's tap target |
| **Image-first (winner)** | Clean 4:3 photo with only small white badges. Name in 32pt Jakarta and the job below. Decision row inside the same white hero card. |

## 4. Profile header
| Option | Verdict |
|---|---|
| 176pt centred avatar over separate cards (before) | Avatar dominates; it reads as a settings page |
| Two full-width buttons (Edit, Preview) | Truncated to "Edit pro…" at 320pt |
| **Hero card (winner)** | 96pt avatar beside the name, a verification badge, interest chips. Edit profile as the primary, Preview as a 56pt round icon button. |

## 5. Account Health summary
| Option | Verdict |
|---|---|
| Status banner plus a list (before) | Rubric 3 for hierarchy |
| 2×2 metric tiles at the top | Puts "Not measured" first: it leads with absence |
| **Status-and-completeness hero (winner)** | A tinted status pill and its action, then one 52pt number ("28% complete") over a 10pt bar. Only real data; activity tiles stay further down, with "—" and "Not measured" where data doesn't exist. |

## 6. Field boundaries
| Option | Verdict |
|---|---|
| 1pt outline at 3:1 (before) | Busy on dense forms |
| **Filled `#EAEAEF` with a visible label (winner)** | Calm. The fill-to-page contrast is below 3:1, so the boundary is carried by the label above, the placeholder (4.53:1) and the 2pt purple focus edge. Recorded as decision PR-07. |

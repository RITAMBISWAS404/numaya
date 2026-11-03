# V16 design principles

Withings Health Mate's language on Numaya's V11 layouts. Evidence is in
[../research/REFERENCE_ANALYSIS.md](../research/REFERENCE_ANALYSIS.md) (§2 patterns, §3 colour).

1. **Two surfaces, no decoration.**
   - A warm light-grey canvas (`#F4F3F1`) with white rounded cards.
   - Cards separate by tone alone: no borders, no shadows. Hairlines only divide rows inside a card.
2. **Black acts; blue accents.**
   - The primary action is near-black with white text.
   - Withings blue (`#4F65CB`) marks selection, information and Numaya's one accent action
     (SuperSwipe).
   - No other hue competes; purple is retired.
3. **Monochrome choices, a green "on".**
   - Radios and checkboxes are black.
   - The only coloured control is the switch: green when on.
   - Red is kept for destructive actions and "new" signals.
4. **Bold, tight headings; quiet text; tiny tracked titles.**
   - Hanken Grotesk bold for page titles, names and the match headline; medium for section titles.
   - Inter for everything read or tapped.
   - Small uppercase tracked labels for navigation titles and group eyebrows.
5. **Rounded rectangles for actions, pills for choices.**

   | Shape | Use |
   |---|---|
   | 12px rounded rectangle | buttons, fields |
   | 16px | cards |
   | full round | tabs, chips, icon buttons, switches |
   | 4px | checkboxes and tags |

6. **Calm density.** V11's spacing is kept exactly. The calm comes from fewer edges, less colour and
   steadier type, not from more whitespace.
7. **Accessible by default.**
   - Every text pairing meets AA.
   - Field and control edges meet 3:1.
   - Focus is a 2px blue ring.
   - The reference is iOS and shows no focus states; V16 supplies them in its accent.
8. **Layout is V11's.** See [V11_LAYOUT_CONTRACT.md](V11_LAYOUT_CONTRACT.md).

# V16 design principles

V16 is V11's Numaya, with V11's screens, order, content and behaviour, drawn in the visual system of Withings Health
Mate. Each principle cites its evidence in [REFERENCE_ANALYSIS.md](../research/REFERENCE_ANALYSIS.md).

1. **Stone page, white cards, nothing else to separate them.**
   - The page is warm off-white `#F5F4F1`. Content that belongs together is a white card with a 14 pt corner. It
     has no border and no shadow, because the contrast between white and stone is enough.
   - This replaces V11's white canvas with hairline outlines.
   - Evidence: 02, 07, 12, 14, 18, 19.
2. **A card is a container for content. Information gets an outlined box.**
   - Facts and notices you read but don't open ("Liked you at Parkrun", the first-photo tip, the report note) sit in
     a page-coloured box with a hairline, like the notification box.
   - Evidence: 08, 10, 34.
3. **Ink acts, blue marks.**
   - Primary actions are near-black: Like back, Show 3 people, the step button, Save.
   - Withings blue is rare and means "brand" or "yours": your messages, the SuperSwipe, a checked box, a slider
     interval, a link, focus.
   - The blue tint means "selected" or "a gentle action": the chosen tab or interest, the toast.
   - Green is only for a switch that is on. Red is only for destruction and notification dots.
   - V11 purple is gone from V16 screens; the e2e suite checks this.
4. **One grotesk, two registers.**
   - Hanken Grotesk everywhere.
   - Tab roots open with a heavy page title: Likes, Messages, Profile, Activity.
   - Modal and detail screens get a white bar with tracked capitals: SETTINGS, EDIT PROFILE, YOUR PROMPT, KEMI.
   - Headings above groups are medium-weight ink, never grey labels. Short field labels are small bold capitals.
5. **Rounded rectangles, with circles where the reference uses them.**
   - Corners by role: tags 6, fields 8, buttons and chips 12, cards 14, photos and sheets 16.
   - Circles: header buttons, avatars, radios, switch thumbs, the step button and the round Discover actions.
   - Full pills only for compact outlined actions and tint tabs.
6. **Lists are grouped, not stacked.**
   - Choice rows, settings and prompt pickers are one white card with hairline dividers inset 16 pt on both sides.
   - The selected row takes no ring: the radio says it, as in the reference.
7. **Preserve the product.**
   - The name, mark, wordmark, copy, photo placement, grid, navigation and every interaction stay V11's.
   - Withings' name and logo appear nowhere in the app.
   - The mark keeps its shape and dot, recoloured to the accent.
8. **Accessible by construction.**
   - Every text colour is 4.5:1 or better on every V16 surface.
   - Controls keep 44 pt targets: the small pills are 36 pt visible inside the existing 44 pt hit area.
   - Focus is a 2 pt blue outline.

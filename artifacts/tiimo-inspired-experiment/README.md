# Numaya × Tiimo: a 12-screen visual-direction experiment

**Question:** does a visual language adapted from Tiimo's iOS app make Numaya more distinctive, warm
and premium than the approved Apple Design + Impeccable baseline?

**Short answer:** partly. The **category-colour system** (a tinted pastel and emoji for each
interest or activity category) and the **borderless white cards on a tinted canvas** are real
improvements. They give interests an identity and make cards calmer. The **pastel selection state**
and the **denser, more decorated chips** are regressions for a selection-heavy dating flow. My
recommendation is to promote the category system and card surfaces into the main design system, and
not to adopt the whole theme as is. See [Recommendation](#recommendation).

- **Branch:** `experiment/tiimo-inspired-12-screen`, from the approved
  `design/apple-impeccable-full-app` (`944c532`). The approved branch is untouched.
- **Try it:** run `npm run dev` and add `?theme=tiimo` to any URL, for example
  `/flows.html?screen=interests&theme=tiimo` or `/?theme=tiimo`. Without the parameter you see the
  approved design.
- **Documents:** [Reference analysis](reference-analysis.md) ·
  [Screen selection](screen-selection.md) · [Design system](design-system.md) ·
  [Validation](validation-report.md) · [Progress](progress.md)

## Reference principles adopted

The study covered 27 Tiimo screens across 8 flows via the Mobbin connector; see
[the analysis](reference-analysis.md), which marks what was observed and what was inferred.

1. **A tinted canvas with white, borderless, softly lifted cards.** Tiimo never uses hairlines on its
   cards.
2. **One pastel per category**, always with a dark ink for text on it. In Tiimo, Morning is peach,
   Afternoon blue and Evening lilac.
3. **Emoji mark content, line icons mark controls.**
4. **Tinted capsules with uppercase tracked micro labels** for group headers.
5. **Dashed placeholders** for empty or "add" slots.
6. **Floating white chrome**: corner buttons, a white tab capsule, white secondary pills.
7. **A large-radius sheet on the canvas** holding white groups.
8. **Celebration through colour scatter**, not through layout change.

Kept from Numaya on purpose:
- **Purple primary actions.** Tiimo's are near-black. The brief and decision D-22 keep purple.
- **Fraunces and Inter.** Tiimo also pairs a regular-weight serif with a grotesk.
- **Icon-only navigation, every layout, all copy, and every interaction.**

## Contact sheet: the 12 screens

![The 12 screens in the Tiimo-inspired direction](screenshots/tiimo-inspired-12-screens.png)

All full-size captures: [screenshots/tiimo-inspired](screenshots/tiimo-inspired/README.md), 40
states. Baseline at the same numbers: [screenshots/baseline](screenshots/baseline/README.md).

## Before and after

Each pair shows the approved design on the left and the experiment on the right, in the same state
and viewport.

| | |
|---|---|
| ![Welcome](screenshots/comparisons/001-welcome.png) | ![The basics](screenshots/comparisons/013-basics.png) |
| ![Photos](screenshots/comparisons/018-photos.png) | ![Interests](screenshots/comparisons/016-interests-prompt.png) |
| ![Discover](screenshots/comparisons/019-discover.png) | ![You both like](screenshots/comparisons/021-discover-you-both-like.png) |
| ![Like back](screenshots/comparisons/059-like-profile.png) | ![Likes](screenshots/comparisons/054-likes.png) |
| ![Match](screenshots/comparisons/030-match.png) | ![Messages](screenshots/comparisons/034-chats.png) |
| ![Conversation](screenshots/comparisons/038-chat-conversation.png) | ![Edit prompt](screenshots/comparisons/108-prompt-editor.png) |
| ![Activity](screenshots/comparisons/061-activity.png) | ![Discover filters sheet](screenshots/comparisons/023-discover-filters-sheet.png) |
| ![Unmatch sheet](screenshots/comparisons/045-chat-unmatch-sheet.png) | ![Interests at 375](screenshots/comparisons/144-qa-interests.png) |
| ![Messages at 375](screenshots/comparisons/147-qa-chats.png) | |

## Screens

| # | Screen | What changed | Improvement | Regression |
|---|---|---|---|---|
| 1 | Welcome | Canvas, four tinted interest stickers in the reserved hero | The empty hero now says "interests" before any copy does. It is the warmest first impression so far. | The stickers are decoration standing in for the missing artwork, so the hero is friendlier but less premium than a real illustration would be. |
| 2 | The basics | Borderless white option cards, stone fields | Calmer and lighter; options read as tappable cards. | None material. |
| 3 | Photos | Dashed "add" slots with a white plus disc | The clearest "add here" affordance of any variant. | None. |
| 4 | Interests | Category capsules, emoji chips, tinted selection | Categories are scannable at a glance, with a lot of personality. | Selection is **less obvious**: pastel and ring versus solid purple. The chips are taller, so at 375 one row falls below the fold. |
| 5 | Discover | Canvas, white lifted cards, emoji shared-interest tiles, lilac active tab | "You both like" becomes a visible hook, and the cards sit better on the canvas. | The photo dominates the first view either way, so the change there is small. |
| 6 | Like back | White Pass pill, emoji tile | A clearer primary/secondary pair. | None. |
| 7 | Likes | Butter "New" tags, larger tile radius | The tags are warmer and readable. | Little change overall; the placeholders dominate. |
| 8 | Match | Confetti scatter, tinted emoji chips | The shared interests now pop; it is more celebratory. | The confetti is subtle and static, so it adds less than real motion would. |
| 9 | Messages | Rows as separate white cards, butter "Your move" | Each conversation is a distinct object, and the "Your move" nudge is clearer. | Denser chrome: more edges on the screen. |
| 10 | Conversation | Lilac bubble with deep-purple text; white incoming bubble | Softer, and it matches the tile language. | Your messages lose the strong purple ownership the approved design had; the two speakers are less contrasted. |
| 11 | Edit prompt | Borderless option cards, stone answer field | Consistent with Basics. | None. |
| 12 | Activity | Borderless cards, emoji filters, emoji category tags | Categories gain an identity, and the cards are calmer. | The filter row is wider, so more of it scrolls off-screen. |

## Scores

The scale is 1–5. These are my design judgments from the rendered screens, not measurements.

| Criterion | Approved baseline | Tiimo-inspired | Note |
|---|---|---|---|
| 1. Fidelity to Tiimo's principles | n/a | 4 | Canvas, cards, tones, capsules, dashes, floating chrome, sheets. It deviates on CTA colour by design. |
| 2. Numaya brand integrity | 5 | 4 | Purple still owns actions, but four new hues now share the screen. |
| 3. Coherence across the 12 screens | 4 | 4 | One rule set throughout; the category tones repeat correctly across Interests, Discover, Match and Activity. |
| 4. Component-system consistency | 4 | 4 | Implemented as tokens and scoped variants, with no one-off screen styling. |
| 5. Readability and accessibility | 5 | 4 | All pairs pass AA and axe is clean, but selection is weaker and screens are denser. |
| 6. Distinctiveness and emotional quality | 3 | 4 | Clearly more personality and warmth. |
| 7. Suitability for a dating product | 4 | 3 | Emoji interests suit dating, but the overall feel leans "planner" in places (stone fields, capsules). |
| 8. Preservation of UX and functionality | 5 | 5 | Same layouts, copy and interactions; verified by 88 + 20 e2e checks. |
| 9. Responsive quality | 5 | 4 | No overflow, but the denser chips push content below the fold at 375. |
| 10. Overall preference | **4** | **3.5** | Prefer the approved design with the category system promoted into it. |

## The questions

- **Does the expanded palette improve the experience?**
  - Yes, where colour **means something**: interest and activity categories, "New" and
    "Your move".
  - No for selection: the pastel selected chip is weaker than solid purple.
  - The rule "one tint per category, always with its ink" is what makes it work rather than look
    like a pastel theme.
- **Which surfaces and cards work best?**
  - White borderless cards on the lilac canvas: profile sections, activity cards, option cards.
  - Sheets on the canvas holding white groups.
  - Dashed "add" placeholders.
  - Inbox rows as separate cards work, but add visual noise.
- **Does the more expressive language suit Numaya?**
  - In moderation. Interests, shared interests and the match moment benefit.
  - Forms and messaging gain little. Stone fields and capsules make the product feel closer to a
    planner than a premium dating app.
- **Where do emoji help, and where do they detract?**
  - They help on interests, shared interests, activity categories and the Welcome stickers. Emoji
    there carry content.
  - They would detract on controls, navigation or headings, which is why they were not used there.
  - On Interests they add width, so more chips wrap.
- **Are typography and shapes coherent?**
  - Yes. Fraunces and Inter are unchanged.
  - The two card radii (16 for items, 24 for features) and pills only for buttons, chips and tags
    hold across all 12 screens.
- **Which changes should become shared components?**
  - Category tones with inks and the `mark` attribute on chips and tags.
  - Borderless white cards on a tinted canvas.
  - Dashed "add" placeholders.
  - White floating secondary buttons.
- **Which should be rejected?**
  - Pastel selection for interests (keep solid purple).
  - Lilac "my" bubbles (keep solid purple ownership).
  - Inbox rows as cards.
  - Stone (warm grey) fields: a neutral grey is cleaner.
- **Does this direction justify extending the full theme to the whole app?** No, not as a whole
  theme. It does justify promoting the four elements above into the approved design system and
  re-testing them on the remaining screens.

## Recommendation

1. **Keep** the approved Apple Design + Impeccable design as the default.
2. **Promote**, in a follow-up and as main design-system changes:
   - category tones (tint plus ink) and interest and category emoji via `mark`;
   - borderless white cards on a lightly tinted canvas;
   - dashed "add" placeholders;
   - white floating secondary buttons.
3. **Revise** before reuse:
   - The Welcome stickers work as a stop-gap while the hero artwork is missing; replace them when
     the artwork arrives.
   - Make the match confetti more visible, or animate it under the reduced-motion rules.
4. **Discard:**
   - pastel interest selection;
   - lilac outgoing bubbles;
   - card-style inbox rows;
   - warm stone field fills.

## Component-system changes

These are summarised from [design-system.md](design-system.md):
- **New tokens:** `color.tiimo.*` (canvas, field, five tints with inks), `shadow.tiimo-card` and
  `shadow.tiimo-float`, and `component.tiimo.*` geometry. All are additive; no existing token
  changed.
- **Shared components:** they gained only an optional `mark` prop, rendered as data attributes. The
  approved rendering is unchanged.
- **Styles:** all theme styling is scoped to `.theme-tiimo`, in
  `src/design-system/styles/theme-tiimo.css` and `src/flows/theme-tiimo.css`.
- **Tooling:**
  - The gallery gained `GALLERY_THEME` and `GALLERY_ONLY`; with neither set, output is unchanged.
  - `gallery-compare.mjs` gained caption and sheet options; its defaults are unchanged.

## Validation summary

These checks all passed; details are in [validation-report.md](validation-report.md):
- unit tests 117/117 and the production build;
- smoke e2e 144/144 and product e2e 88/88, with no approved contract edited;
- the new experiment e2e, 20/20;
- axe accessibility, with 0 serious or critical issues on the themed views;
- **all 40 captures without the flag are byte-identical to the approved branch.**

## Known issues and limitations

- **Reference access.** I studied Tiimo through Mobbin search results filtered to Tiimo, not by
  opening the exact supplied page. Values are estimates from about 300 px previews. No Tiimo assets
  are committed.
- **No real photography or artwork**, so Discover, Likes and Match are dominated by placeholders in
  both designs. This limits what any visual direction can show.
- **Only Chromium was tested**, and emoji glyphs differ by platform.
- **Experiment only.** The theme is opt-in and covers 12 screens. Every other screen is the approved
  design, and the mix is visible when you navigate outside the selection.

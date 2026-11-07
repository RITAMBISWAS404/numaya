# Visual Lab V2: screenshot critique and refinement log

Method (brief 10): inspect the actual emulator screenshot → name the defect → fix in Flutter →
recapture → re-inspect. Scores are simulated review lenses (1–5) from one reviewer, not user research
and not a guarantee: **C** member comprehension, **T** task completion, **H** visual hierarchy and Ente
coherence, **B** business honesty. 5/5 is never given by default.

## Refinement loop 1 (capture run 1 → fixes → capture run 2)
| Seen in run 1 | Fix | Where |
|---|---|---|
| Yellow double underlines on every text of Your insights (no Material ancestor on a pushed `LargeTitlePage`) | `LargeTitlePage` paints a `Material` canvas | `large_title_page.dart` |
| A white empty bar under "This match ran out" | The expired bar shows only for a match that has history | `messages_screens.dart` |
| White Compliment squircle almost invisible on white prompt cards | `OnWhiteSurface`: on white cards the squircle takes the fill grey, flat | `squircle_button.dart`, `profile_prompt_card.dart` |
| `conversation-row` C: the unread count stretched to a full-width purple bar | Badge laid out in a min-size Row | `conversation_row.dart` |
| `insights-summary` D: "in the last 9 days … matched with 7" (placeholders in the wrong order) | Arguments follow the generated order; regression test added | `insight_cards.dart`, `visual_lab_v2_test.dart` |
| `metric-widget` A: weekday letters crammed under 36pt inline bars | Inline bars drop their labels (the full chart keeps them) | `ExposureBars.labels` |
| `like-tile` in context showed the free locked state for every variant | Context shots for that Premium surface use a Premium member | capture harness |
| Dismiss sheet step skipped (second Compliment card below the fold) | Scroll the card into view first | capture harness |
| Ordinary demo profile had no bio, which the MVP requires | Quick start fills a sample bio (fixture fixed, not the test) | `session_controller.dart` |
| Design Lab profile preview showed age 29 while the screen showed 30 | Preview computes the real age | `visual_lab_screen.dart` |

## Per-family scores (after loop 1)
Scores for the proposed variant, then notable alternatives. Evidence = the screenshot IDs in the gallery.

| Family | Proposed | C | T | H | B | Evidence and trade-off |
|---|---|---|---|---|---|---|
| match-avatar | O | 4 | 4 | 4 | 5 | Ring reads at a glance (Bumble pattern) and keeps UI-033's no-name rule; time is spoken. B adds names (helps people who forget faces) at the cost of the owner's UI-033 decision. D's pie badge is the least clear. |
| conversation-row | O | 4 | 4 | 4 | 5 | Ente row with badge after the name; A makes "Your move" scannable but moves time; B cards cost height; D only for heavy users and falls back at large text. |
| compliment-card | B | 4 | 4 | 4 | 5 | Showing *what* they noticed (your photo or prompt question) answers "why did they write"; O is shorter; A gives the words most weight but hides the sender; D's photo-led card is attractive but long. |
| like-tile | O | 4 | 4 | 4 | 5 | Two columns with name below keeps faces large and names legible; A is denser but names sit on photos; B is fastest to scan for like-back; C is cramped at 200%. |
| profile-header | O | 4 | 4 | 4 | 5 | Approved round photo; A cover is the most expressive but long; C/D integrate activity and remove a card each. |
| insights-summary | A | 4 | 4 | 4 | 4 | Bars with the exact total and period line; status banner under it. C funnel is the most explanatory (one cohort) but heavier; D is the calmest; B duplicates the activity grid. |
| metric-widget | A | 4 | 3 | 4 | 4 | Value with inline bars for appearances; other metrics without daily data show period text. C makes change explicit; D is calm but long. |
| profile-setup | B | 4 | 5 | 4 | 5 | Only the next missing part with its action; never a score. C checklist is complete but long. |

Remaining families (prompt-card, discover-photo, streak-card, wallet-card, plan-card, status-banner,
empty-state) and the five screen directions are scored in loop 2 below from the final capture.

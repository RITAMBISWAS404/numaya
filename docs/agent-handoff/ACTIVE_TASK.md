# Active task: final UX and UI polish

**Status:** not started. The branch and handoff were set up on 2026-11-04; no product code has
changed yet.
**Branch:** `experiment/numaya-final-ux-polish`, from `e70135c`.

## Goal
The final UX and UI refinement of the Flutter app (`apps/numaya_mobile/`), building on the approved
Monochrome Premium design. It refines; it does not redesign.

## Constraints
- Keep the approved system: palette, `#7262C7`, type pairing, radius scale, the tab pill, filled
  controls. Any change needs a decision recorded in [DECISIONS.md](DECISIONS.md).
- Follow `CLAUDE.md`: semantic tokens only; no screens the spec does not describe; cover every
  state the spec lists.
- Do not weaken, skip or delete tests. Regenerate goldens only after review, and say so.
- Text scaling is never capped. Contrast stays at 4.5:1 for text and 3:1 for marks (PR-07 is the
  recorded exception).

## Known open items from the last QA (candidate scope)
From [VISUAL_QA_REPORT.md](../design-experiments/monochrome-meetup-premium/VISUAL_QA_REPORT.md) and
the premium [DECISIONS.md](../design-experiments/monochrome-meetup-premium/DECISIONS.md):
1. Account Health below the hero is still a parts list. Make it more visual, with no invented
   metrics (PR-11).
2. Top-bar titles are cut off with an ellipsis at 320pt width and 200% text.
3. Jakarta punctuation is loose ("Bo, 22", "Let's").
4. Filled-field boundary below 3:1 (PR-07). Revisit only on evidence.
5. No demo photography: Discover, Likes and event covers show grey placeholders.
6. Two illustration slots to commission.
7. Never verified on a device: fonts, the tab pill over the gesture bar, haptics, performance.

**Owner to confirm:** the exact scope and priority of the final refinement. Record it here before
implementation starts.

## Progress
_None yet._

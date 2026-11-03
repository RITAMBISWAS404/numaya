# Active task: final UX and UI polish

**Status:** implemented, tested and pushed on 2026-11-04. Waiting for the owner's review.
**Branch:** `experiment/numaya-final-ux-polish`, from `e70135c`.

## Goal
The final UX and UI refinement of the Flutter app (`apps/numaya_mobile/`) on the approved
Monochrome Premium design. It refines; it does not redesign.

## Constraints (unchanged)
- Keep the approved system: palette, `#7262C7`, type pairing, radius scale, tab pill, filled
  controls. Any change needs a recorded decision.
- Follow `CLAUDE.md`: semantic tokens only; no screens the spec does not describe; cover every
  state the spec lists.
- Do not weaken, skip or delete tests. Regenerate goldens only after review.
- Text scaling is never capped. Contrast is 4.5:1 for text and 3:1 for marks (PR-07 is the
  recorded exception).

## Done in this pass
The full record is in
[docs/design-experiments/numaya-final-ux-polish/](../design-experiments/numaya-final-ux-polish/README.md).

| Brief phase | Result |
|---|---|
| 0: handoff and verification | Done; see WORK_LOG. The `experiment/impeccable-visual-refinement` branch named in the brief does not exist locally or on GitHub (see CURRENT_STATE) |
| 1: skills and references | Project skills used. Mobbin: Bumble, Feeld, Alan |
| 2: preserve the direction | Nothing reverted |
| 2 and 8: semantic colours | `AccentTone` set, contrast-checked (FP-01) |
| 3.1: icon tiles | `IconTile` via `ListRow.leading` (FP-03, FP-11) |
| 3.2: list separation | Inset `divider` hairlines (FP-02); list-pattern rules in COMPONENT_RULES |
| 3.3: copy density | Four strings shortened (FP-12) |
| 4.1: Discovery swipes | Stamp on the photo; cancel-safe; fling-back cancels; no double decisions; tests |
| 4.2: Profile | Toned 48pt tiles. Other-user profile structure already Bumble-like; kept |
| 5: Match | Single large photo of the matched person (FP-05) |
| 6: mascot-ready layouts | Named slot ratios; ILLUSTRATION_ASSET_BACKLOG.md |
| 7: geometry | `AppRadii.nested`; tab indicator and RSVP bar fixed (FP-06, FP-07) |
| 9 and 10: spacing and visual QA | Before/after evidence; scores in VISUAL_REVIEW_REPORT.md |
| 11: tests | 22 new tests; Match added to the route matrix; emulator smoke |
| 12: handoff | This folder |

## Not done or not verified
- **Real photography:** none exists.
- **Long-name Match:** not exercised; the sample names are short.
- **Physical-device checks:** haptics, performance, font hinting.
- **Web checks:** `npm run check` fails here only because of CRLF line endings, and
  `npm run test:e2e` needs `npx playwright install`. See VALIDATION.md.

## Next decision for the owner
Review the branch, by APK or screenshots, and choose:
- merge it into the line you ship from; or
- request changes.

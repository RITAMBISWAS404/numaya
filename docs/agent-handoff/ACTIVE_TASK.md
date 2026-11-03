# Active task: frosted-navigation experiment, handed off

**Resume from:** branch `wip/frosted-navigation-handoff` (pushed). It contains the whole
experiment as one commit on top of `eb0b37b`. `experiment/numaya-frosted-navigation` still points at
`eb0b37b` and holds nothing extra.

## Included in this branch
| Stage | What | Files |
|---|---|---|
| B: typography | `AppTypography.chip` (Figtree 14/18 medium, ink) for `InfoChip` and Profile chips; chips grow instead of truncating | `foundations/app_typography.dart`, `widgets/people.dart`, `features/profile/presentation/profile_screen.dart` |
| B: compact layout | `Wordmark(maxWidth:)`: Discover shows the mark alone when the word does not fit (320dp, large text) | `widgets/content.dart`, `features/dating/presentation/discover_screen.dart` |
| C: frosted nav | `NumayaTabBar(surface: TabBarSurface.frosted)` with a built-in `BackdropFilter` and `MonoGlass` tokens; idle icons `text2` on glass; a system-inset strip; High Contrast falls back to the opaque pill | `widgets/navigation.dart`, `tokens/monochrome_tokens.dart` |
| C: content under the bar | `HomeShell(extendBody: true)`; `TabPage` and Profile add the bar height to their bottom padding; Discover's floating row sits above the bar | `home/presentation/home_shell.dart`, `home/presentation/tab_screens.dart`, `profile_screen.dart` |
| Tests | 10 widget tests; 1 opt-in stress-background golden | `test/widget/frosted_navigation_experiment_test.dart`, `test/screenshots/capture_frosted_navigation_test.dart` |
| Goldens | 51 updated after review, plus `fn01-glass-backgrounds.png` | `test/screenshots/goldens/` |
| Docs | experiment report; tools record; handoff | `docs/design-experiments/frosted-navigation/README.md`, `docs/agent-handoff/*` |
| Skills (project) | `apple-hig` (allexp1, MIT), `liquid-glass-widgets` (sdegenaar, MIT), `search` (Mobbin, MIT), each with its upstream LICENSE | `.claude/skills/` |

The palette is unchanged (decision in the report). The `liquid_glass_widgets` runtime package was
not adopted.

## Still open
1. **Next task: the 14/20 default body-size variant is NOT implemented.**
   - Today `AppTypography.body` is 16/24. A 14/20 style exists only as the secondary `bodySm`.
   - The experiment deliberately did not change the default (see the report's typography section).
   - Build it as a reviewable variant, for example a token switch shown in the Design Lab. Compare
     it with 16/24 on Discover, profile prose and Chat at 320 / 390dp and 100 / 200% text before
     deciding.
2. **Owner decision per stage:** B keep, C tune, package defer (recommendations in the report).
3. **Physical phone:** scroll performance, heat, and the glass over real photos (the emulator uses
   a software GPU; the demo data has only placeholders).
4. **Unverified:** the keyboard over tab screens on a device with the frosted bar; TalkBack;
   iOS.
5. **Evidence images not in git:** the A/B/C screenshots, comparisons and patch files stay in the
   local worktree only (see VALIDATION). Regenerate them with the journey described in the
   report if needed.

---

# Earlier task: final UX and UI polish

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

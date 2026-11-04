# Active task: frosted-navigation experiment, handed off

> **Bumble × Meetup batch (2026-11-04):**
> - BM-01: verified tick beside the name;
> - BM-02: flush list groups in sheets;
> - BM-03: attachment metadata uses `MetaText`;
> - BM-04: " · " copy replaced.
>
> 342 passed, 15 skipped. Record: [DESIGN_CONTRACT.md](../design-experiments/overnight-polish/DESIGN_CONTRACT.md). Worktree `/home/user/numaya-overnight`, branch `experiment/numaya-overnight-polish`, HEAD `6b23c85`. **Local only, uncommitted; not on GitHub.** **Next:** the Windows device pass, then the illustration art.

> **Pill gaps (2026-11-04):** `ViewTabs` now has an 8pt gap between pills; event badges 8/8. 338 passed, 15 skipped. Record: SPACING_AND_SHAPE.md, "Pill gaps". **Local only, uncommitted.**

> **Core journey pass (2026-11-04):**
> - DX-02: shared interests in the Discover hero (they return to the body above 160% text);
> - DX-03: the Opening Moves card follows the conversations;
> - DX-04: frosted navigation kept, solid under High Contrast;
> - Likes and Events separators migrated.
>
> 337 passed, 15 skipped. Record: [CORE_JOURNEY.md](../design-experiments/overnight-polish/CORE_JOURNEY.md). **Local only, uncommitted.**

> **Design direction (2026-11-04):**
> - thesis and issue map written;
> - Safety tips moved to one grouped list (DX-01);
> - 334 passed, 14 skipped.
>
> Next: issue 7 (the remaining " · " separators). Record: [DESIGN_DIRECTION.md](../design-experiments/overnight-polish/DESIGN_DIRECTION.md). **Local only, uncommitted.**

> **Component cleanup (2026-11-04):**
> - switches without outlines;
> - plain row icons;
> - tinted-card borders;
> - `MetaText` separators;
> - a composer without its tray;
> - one chat demo notice.
>
> 334 passed, 14 skipped. Record: [COMPONENT_CLEANUP.md](../design-experiments/overnight-polish/COMPONENT_CLEANUP.md). **Local only, uncommitted.**

> **Spacing and shape pass (2026-11-04):**
> - **Rules:**
>   - one pill inset (12 × 4) and one badge inset (8 × 4);
>   - a two-tier icon gap: 4 in pills and badges, 8 in rows, fields and buttons;
>   - an 8pt group gap;
>   - bubble and toast insets on the grid.
> - **Tests:** 326 passed, 14 skipped.
> - **Record:** [SPACING_AND_SHAPE.md](../design-experiments/overnight-polish/SPACING_AND_SHAPE.md).
> - **Local only, uncommitted.**

> **Type-roles pass (2026-11-04):**
> - **Body:** 14/20 confirmed by resolved-style tests.
> - **Pills, chips and badges:** 12/16 (8/12 tried and rejected).
> - **Larger scale:** 32/28/24/20/18.
> - **Tests:** 323 passed, 14 skipped.
> - **Record:** [TYPE_ROLES.md](../design-experiments/overnight-polish/TYPE_ROLES.md).
> - **Local only, uncommitted.**

> **Final QA pass (2026-11-04):** the overnight candidate passed the audit.
> - **Fixes:**
>   - F-01: the Design Lab now uses the app clock (its golden had been nondeterministic);
>   - F-02: a long `ListRow` value with a detail stacks under the label (Settings recovery
>     email).
> - **Tests:** 4 new regression tests; **316 passed, 14 skipped, 0 failed**.
> - **Record:** [FINAL_QA.md](../design-experiments/overnight-polish/FINAL_QA.md).
> - **Still local only, uncommitted.**
> - **Next:**
>   1. The owner authorises a commit and push.
>   2. A Windows APK and device pass (TalkBack, gesture and three-button navigation, profile-mode
>      scrolling).

# Active task: overnight polish (14/20 body, large-text fixes, glass highlight, mascot)

**Status:** implemented and tested in a cloud worktree on 2026-11-03 UTC. **Local only: not committed,
not pushed.** Waiting for the owner's review and an authorisation to commit and push.

| Item | Value |
|---|---|
| Worktree | `/home/user/numaya-overnight` (cloud container; ephemeral, so commit and push it before the session ends) |
| Branch | `experiment/numaya-overnight-polish` (local only; not on GitHub) |
| Base and HEAD | `6b23c85aa7be16b5cfeaebdea06c36a9090243b2` (`wip/frosted-navigation-handoff`, live on GitHub) |
| Record | [docs/design-experiments/overnight-polish/README.md](../design-experiments/overnight-polish/README.md) |

## Done
- **14/20 semantic default body** (OP-01), compared against 16/24 and a rejected compact scale
  under identical conditions.
- **Role exceptions:** option rows and typed text stay 16 (OP-02, OP-03).
- **Large-text fixes (OP-04):**
  - tab title;
  - Profile hero;
  - Discover photo badges;
  - `ChipSet` heading and interests count.
- **Glass top highlight** (OP-05); the High Contrast fallback is unchanged.
- **Mascot** SVG on the Likes empty states (OP-06).
- **Calm direction** kept over the expressive one (OP-07).
- **Tests:** 10 new widget tests, including a sweep of six never-tested routes; 3 new goldens;
  154 goldens updated after review.

## Next
1. **Owner:** review the sheets listed in the record. Authorise commit and push, or request
   changes.
2. **On Windows** (Android SDK): build the debug APK and run the device pass:
   - 320/390dp at font scale 1.0 and 2.0;
   - the keyboard over tab screens with the frosted bar;
   - TalkBack;
   - profile-mode frame times for the blur.
3. **Goldens:** the updated goldens were rendered on Linux. Re-render on the machine that owns
   the golden baseline before treating them as the reference.

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

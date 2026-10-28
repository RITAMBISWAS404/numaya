# UI refinement: QA report

Branch `experiment/numaya-full-ui-refinement`. Decisions are in
[UI_REFINEMENT_DECISIONS.md](UI_REFINEMENT_DECISIONS.md); the baseline is in
[UI_REFINEMENT_AUDIT.md](UI_REFINEMENT_AUDIT.md).

**Nothing in this pass ran on a phone or emulator.** There is no Android SDK in this environment, so no
APK was built. All visual evidence comes from Flutter golden captures rendered with the app's real fonts.

## Batches

| # | Batch | Commit |
|---|---|---|
| 1 | Audit, route inventory, decisions | docs commit |
| 2 | Shared components: layout tokens, shapes, Material icons, app bars, selected states, pills, outlines, switches | `41a7c87` |
| 3 | Discovery: 4:3 photo, scrim, decision bar, gutters | `41a7c87` |
| 4 | Events: 16:9 flush covers, metadata rows, save button | `a68f01b` |
| 5 | Profile: avatar, completion card, header glyphs | `a68f01b` |
| 6 | Rest of the app: icon buttons, holders, gutter token | `845711e` |
| 7 | Adversarial QA (long text, narrow screens, large text) and the scrim fix | `876e8ea` |
| 8 | Motion and regression review | this report |

## Before and after

Captures are in `apps/numaya_mobile/test/screenshots/goldens/`. These sheets compare the baseline goldens
(`5e1b57c`) with this branch; each pair is shown before, then after.

| Sheet | Shows |
|---|---|
| `screenshots/refinement-discover.png` | Discover card (x02) and reading with the floating bar (x03) |
| `screenshots/refinement-events.png` | Events Explore (v01) and event detail (v04) |
| `screenshots/refinement-profile.png` | Profile tab (f17) and the completion hub (f18) |
| `screenshots/refinement-other.png` | Edit profile (f19), chat (f08), settings (f28) |
| `screenshots/refinement-worst-case.png` | The adversarial board at 320 pt 1×, 375 pt 1× and 375 pt 2× |

**Goldens were not regenerated blindly.** After each batch every changed area was rendered into contact
sheets and inspected:
- Discover: 16-home, x01–x09;
- Events: v01–v13;
- Profile: f17, f18, h01;
- the rest: f03, f06–f08, f15, f18–f19, f23, f27–f28, f34, f38, o12.

The baseline files were kept aside for comparison.

## Adversarial QA (batch 7)

`test/helpers/refinement_board.dart` puts the refined components on one page with worst-case data:
- a hyphenated 21-letter name with a two-line job and every badge;
- a person with no job;
- a 93-character event title with a long venue, two badges and a "picked" reason;
- the completion card at 28% and at 100%.

| Check | How | Result |
|---|---|---|
| No overflow at 320 / 375 / 430 pt, 1×, 1.3× and 2× text | `test/widget/refinement_layout_test.dart` (6 cases, runs in `flutter test`) | Pass |
| Decision bar keeps a ≥ 44 pt target and its screen-reader names at every size; labels hide before they would clip | same test | Pass. Labelled at 375 and 430 pt at 1×; icon-only at 320 pt, and at 1.3× and above |
| Long name and title wrap, never truncated | same test | Pass |
| A complete profile offers no action | same test | Pass |
| Visual | `capture_refinement_qa_test.dart` → `r01`–`r03` | One defect, fixed (RQ-1) |
| Existing large-text and tap-target checks | `accessibility_test`, `break_ui_test` (all routes at 130%, 375 × 667) | Pass |

## Defects found and fixed

| # | Found by | Defect | Fix |
|---|---|---|---|
| RQ-1 | Capture r01/r03 | With a long name, a job or large text the name block grew above the dark part of the fixed scrim: badges and the first line were white on a light photo | The scrim travels with the block (RD-11): a fade, then at least 65% ink behind the text |
| RQ-2 | Test compile after RD-12 | Discovery tests found the old round buttons by type | Tests now find the inline and the floating decision bar separately and assert which one is tappable (inline at the photo, floating while reading); nothing was loosened |
| RQ-3 | Sheet review | Filled help and settings glyphs read as dark discs in the header buttons | Outline glyphs (RD-09) |
| RQ-4 | Sheet review | Completion tiles, add-photo tiles and the chat send still used circles | RD-02 and RD-08 applied |
| RQ-5 | Analyzer | `NavButtonStyle` comments still described circles | Updated |

## Behaviour verified

`flutter test` covers:
- Discover Like, Pass, SuperSwipe, drag to decide, undo (one step, with its toast and header button), filters, photo viewer, report, and Android back from deep in a profile;
- Events filters, join, waitlist, leave, save, hosting, create and edit;
- Profile completion recalculating after an edit;
- reduced-motion paths (`motion_test`).

## Motion and regression review (batch 8)

- New animations are only the completion bar fill and the top-bar divider. Both use `AppMotion.duration`,
  which is zero under reduced motion.
- The decision pills reuse `Pressable`'s press scale.
- The floating bar's fade is unchanged from the previous brief.
- No route, provider or business rule changed. The diff touches presentation code, design-system
  widgets, tests and docs only.

## Results

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | Clean |
| `flutter analyze` | No issues |
| `flutter test` | **227 passed, 8 skipped** (skipped = opt-in captures) |
| Captures (`--tags screenshots --run-skipped`) | 12 passed |
| `npm run tokens:check` | Tokens OK: 437 tokens, generated files up to date |
| `npm run check` | Pass (web build unchanged) |
| `npm run test:e2e` | 143 / 144; the one failure (corner-shape) exists on the base branch and the web app is untouched |

## Remaining defects and limits

| # | Item | Note |
|---|---|---|
| RR-1 | Date and view tab rows scroll inside the gutter instead of bleeding to the screen edge | Needs a shared `ViewTabs` option; cosmetic |
| RR-2 | At 2× text the event card's badges can touch the category mark on the 16:9 cover | Placeholder covers only; real photos have no centred mark |
| RR-3 | The Likes grid stays 3:4 (RD-10) | Deliberate; revisit with real photos |
| RR-4 | No device run: TalkBack order, real-photo scrim contrast and touch feel are untested | Needs an Android SDK or a device |
| RR-5 | Material Icons replace the custom set on mobile only; the web prototype keeps its SVGs | Out of scope by the brief (web not modified) |

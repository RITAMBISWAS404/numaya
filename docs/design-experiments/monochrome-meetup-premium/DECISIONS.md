# Decisions: premium refinement

| # | Decision | Why | Rejected |
|---|---|---|---|
| PR-01 | Branch from `experiment/numaya-monochrome-meetup` (`0003d17`), in its own worktree | The brief; the base stays untouched and recoverable | Committing on the base |
| PR-02 | Plus Jakarta Sans for display, Figtree for text | The three-way trial in Flutter (DESIGN_EXPLORATIONS §1) | Figtree alone (flat); Outfit (younger, clashing "a") |
| PR-03 | Keep `#7262C7` and the cool greys; purple for the single primary, selection, progress and "yours"; `#5B4BB0` for purple text | Brief and `CLAUDE.md`; stronger but strategic purple | New hues; gradients (forbidden) |
| PR-04 | Role-based radius scale: 8 / 16 / 18 / 24 / 32 / pill | More expressive geometry with meaning per role | One radius for everything |
| PR-05 | Icon-only floating tab pill, tint indicator | DESIGN_EXPLORATIONS §2; tooltips, semantics and 48dp keep it accessible | Filled (badge contrast, second primary); expanded (icons shift) |
| PR-06 | Filled neutral secondary buttons and fields; no outline | Fewer lines; Jomo and Meetup | Outlined controls |
| PR-07 | **Filled fields below 3:1 against the page** | The boundary is carried by the visible label, the 4.53:1 placeholder and the 2pt purple focus edge. WCAG 1.4.11 applies to the visual information *needed to identify* the component; the label and placeholder identify it. This is a judgement call and is recorded here so it can be revisited. | A 3:1 outline (busier) |
| PR-08 | Remove dividers from list groups, option lists, chat lists, menus and sheet headers | Space and surfaces separate; rows are 56–60pt | Inset hairlines |
| PR-09 | Discover card image-first, with the decision row inside the hero card | Unblocks the photo tap target; reads like Meetup's image cards; keeps the 4:3 photo | A dark panel over the photo |
| PR-10 | Profile as a personal hero card plus a tile grid | Was rated 3 for reference coherence; Meetup's profile header | A 176pt centred avatar |
| PR-11 | Account Health hero: status plus one completeness number. Activity stays with "—" and "Not measured". No visibility scores, rankings or shadowban predictions. | Bevel's big number; the brief forbids invented metrics | Leading with metric tiles; a "health score" |
| PR-12 | The Discover name steps down from 32 to 24pt above 160% text | Prevents mid-word breaks while still scaling (48pt at 200%) | Capping text scale (rejected: accessibility) |
| PR-13 | On screens under 700pt tall with text above 160%, the footer scrolls with the content | A pinned footer took most of the height at 320pt and 200% | Shrinking the footer text |
| PR-14 | `success` darkened `#2F7D4F` → `#2B774B` | 4.43:1 → 4.80:1 on its tint; now tested | Leaving an untested failing pair |
| PR-15 | New test `size_matrix_test.dart`: 4 widths × 3 text sizes over every full-app route | Machine-checked adversarial QA | Visual spot checks only |
| PR-16 | Goldens regenerated only after the review cycles | They are this branch's visual baseline; the base branch keeps its own | — |

## Handoff folder
`docs/agent-handoff/` does not exist on this branch or its base, so it was not created or updated.
This folder is the durable record.

## To resume
1. `git switch experiment/numaya-monochrome-premium-refinement`
2. Install Flutter 3.47.8, then in `apps/numaya_mobile` run `flutter pub get` and `flutter test`.
3. Next work, in priority order:
   1. Commission the two new illustration slots.
   2. Add demo photography so Discover shows real photos.
   3. Verify on a physical Android device: fonts, the tab pill over the gesture bar, haptics.
   4. Make the Account Health parts list more visual.

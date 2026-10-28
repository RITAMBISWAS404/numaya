# UI refinement: audit

Baseline audit for the full-app UI refinement of the Flutter app (`apps/numaya_mobile`).

- **Branch:** `experiment/numaya-full-ui-refinement`, from `experiment/numaya-events-account-health` @
  `5e1b57c`.
- **Kept from V16:**
  - stone canvas `#F5F4F1`;
  - white surfaces;
  - ink `#121212`;
  - accent `#5066CC`;
  - Hanken Grotesk.
- **Related docs:** decisions are in [UI_REFINEMENT_DECISIONS.md](UI_REFINEMENT_DECISIONS.md); QA and
  before/after evidence are in [UI_REFINEMENT_QA.md](UI_REFINEMENT_QA.md).

**Baseline on `5e1b57c`:**
- analyzer clean;
- `flutter test` 221 passed, 7 skipped;
- captures 9 passed (164 goldens, copied aside as the "before" set).

## Route inventory

All routes are in `lib/app/routes.dart`. Tabs sit in a `StatefulShellRoute`; every other route is a
full-screen page above the shell.

| Area | Routes | Root (no back arrow) |
|---|---|---|
| Sign-in | `/` welcome, `/phone`, `/verify`, `/restore` | `/` |
| Onboarding | `/setup` hub, `/setup/name`, `/underage`, `/gender`, `/meet`, `/intentions`, `/height`, `/location`, `/interests`, `/photos`, `/prompt`, `/prompts`, `/bio`, `/verify`, `/notifications`, `/review`, `/done` | `/setup` |
| Home (tab 1) | `/home` Discover, `/for-you`, `/person/:id`, `/like/:id`, `/match/:id` | `/home` |
| Events (tab 2) | `/events` (Explore, `?view=mine`), `/event/:id`, `/event/:id/people`, `/event/new`, `/event/:id/edit` | `/events` |
| Likes (tab 3) | `/likes` | `/likes` |
| Messages (tab 4) | `/messages`, `/chat/:id` | `/messages` |
| Profile (tab 5) | `/profile`, `/profile/edit` (+ `basics`, `interests`, `photos`, `prompt`), `/profile/complete`, `/profile/preview`, `/profile/opening-moves`, `/profile/verify`, `/profile/premium`, `/profile/safety`, `/profile/visibility`, `/profile/visibility/about` | `/profile` |
| Settings | `/profile/settings` (+ `blocked`, `notifications`, `privacy`, `delete`) | — |
| Other | `/paywall`, `/help`, `/help/contact`, `/account-blocked`, `/demo` (Demo Hub), not found | — |

**Sheets:**
- Discover filters;
- Events filters;
- join, leave and cancel event;
- report and block;
- snooze length;
- area picker;
- photo actions;
- delete account;
- profile field editors.

## Baseline findings

What the refinement brief asked for, compared with the app at `5e1b57c`:

| # | Area | Finding |
|---|---|---|
| A-01 | Layout | Gutters, section gaps and card padding were literal `AppSpacing` values per screen; Discover used its own gutter |
| A-02 | Shapes | Header icon buttons were white circles with a ring; the step button and chat send were circles; button radius varied by size |
| A-03 | App bars | Page headers drew a white bar and a permanent hairline above the stone canvas |
| A-04 | Icons | Custom SVG icon set; the brief asks for standard Material icons |
| A-05 | Selection | Selected tabs and chips used a pale blue tint that read as disabled next to the unselected text |
| A-06 | Pills | Neutral pills were heavy (fill with a border) |
| A-07 | Outlines | Secondary buttons used a full-strength ink border |
| A-08 | Switches | Thumb drew a shadow; off track too light on the canvas |
| A-09 | Passive icon holders | Circles or tints behind icons on prompts, chips, completion tiles, add-photo tiles and info rows |
| A-10 | Discover photo | 3:4 portrait photo with a solid info panel under the name |
| A-11 | Discover actions | Three round buttons; Pass, SuperSwipe and Like had different sizes and only the round row at the end of the profile |
| A-12 | Event cards | Cover inset with its own padding and radius, 120 pt tall whatever the width; the save button sat in the text area |
| A-13 | Profile | 96 pt avatar inside a completion ring that showed only a number |
| A-14 | Header glyphs | Filled help, settings and globe glyphs read as dark discs inside the header buttons |

Every finding maps to a decision in [UI_REFINEMENT_DECISIONS.md](UI_REFINEMENT_DECISIONS.md).

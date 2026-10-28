# UI refinement: decisions

Decisions for the full-app UI refinement. Code comments cite them by ID (`RD-xx`). Findings are
in [UI_REFINEMENT_AUDIT.md](UI_REFINEMENT_AUDIT.md).

**The V16 direction is unchanged:**
- stone canvas, white surfaces, ink and the `#5066CC` accent;
- Hanken Grotesk.

**Token source:** `tokens/numaya.tokens.json` feeds the web prototype too, so new mobile-only values
live in the hand-written Dart foundations (`app_layout.dart`, `app_colors.dart`). No generated file
was edited, and the web app is unchanged.

| ID | Decision | Where | Why |
|---|---|---|---|
| RD-01 | **Semantic layout tokens.** `AppLayout`: `screenGutter`, `screenTop`, `screenBottom`, `sectionGap`, `headingGap`, `itemGap`, `cardPadding`, `iconLabelGap`, `metaGap`, `fieldGap`, `barPadding`. `AppMedia`: `personPhoto` 4:3, `eventCover` 16:9. Feature screens use `AppLayout.screenGutter` instead of `AppSpacing.gutter` | `foundations/app_layout.dart` | One place sets each kind of space; Discover had drifted |
| RD-02 | **Shape language.** Pills for actions, chips, status labels and the decision bar. Rounded rectangles (`AppRadii.control`) for cards, fields and every icon button, including header buttons, the onboarding step button and chat send. Circles only for avatars, progress, radios and colour swatches | `buttons.dart`, `people.dart`, `selection.dart` | One shape per role, so a circle always means a person or a value |
| RD-03 | **App bars on the canvas.** The top bar uses the page background. A hairline appears only once the content scrolls under it (animated, zero under reduced motion) | `layout.dart` (`NumayaScreen`) | No white band; the divider shows only when it separates something |
| RD-04 | **Material icons.** The shared `NumayaIcons` names render as Flutter Material Icons (rounded), filled and outline, through one map. `star_shine` has no Material Icons equivalent, so curated picks use `auto_awesome`. Tests load the bundled MaterialIcons font | `icons/material_icons.dart`, `primitives.dart` | Standard, recognisable glyphs; no new dependency |
| RD-05 | **Selected states.** Selected tabs, date pills, filter chips and choice chips are solid accent with white text and counts. Unselected neutral pills are lighter: canvas on cards, surface on the page, no border | `people.dart` (`ViewTabs`, `InfoChip`), `selection.dart` (`NumayaChip`) | The selection is clear at a glance and passes contrast (white on `#5066CC` is 5.1:1) |
| RD-06 | **Flat switches.** No thumb shadow; the off track is `borderStrong` so it shows on the canvas | `navigation.dart` | Flat surfaces |
| RD-07 | **Soft outline.** Secondary buttons, Pass and outlined pills use `outlineSoft` (ink at 30%) | `app_colors.dart`, `buttons.dart` | Lighter than a full ink border and still visible on canvas and white |
| RD-08 | **No passive icon holders.** Icons sit inline with no circle or tint behind them: prompt marks, chip emoji, info rows, completion tiles, add-photo tiles | `content.dart`, `selection.dart`, `extras.dart` | A holder suggests a button; these icons are labels |
| RD-09 | **Header glyphs.** Header buttons use outline glyphs where the filled one is a solid shape (help, settings) | `profile_screen.dart`, `edit_profile_screen.dart` | A filled disc inside a rounded square read as a second, nested button |
| RD-10 | **Person photos at 4:3 (width:height).** One token, `AppMedia.personPhoto`, used by the Discover card, profile photos, For You and the skeleton. **Conflict:** V16's Discover card was a portrait 3:4. The brief asked for 4:3, so the card is shorter, and the decision bar and the first prompt show without scrolling. The Likes grid keeps its 3:4 tiles: they are thumbnails in a two-column grid, where a landscape tile would show faces too small | `app_layout.dart`, `person_profile.dart`, `discover_screen.dart` | Brief; documented conflict with V16 |
| RD-11 | **Gradient scrim, no blur.** The name block sits on a gradient that travels with it: a 48 pt fade, then 65%→80% ink behind the text, so a long name, a job or large text never lands on a light photo. No blur: a masked blur needs a shader or a second layer with a visible seam, and the gradient already gives the contrast | `person_profile.dart` | Brief allowed blur only if it helped; it didn't |
| RD-12 | **Decision bar.** A full-width pill group: Pass (white, soft outline, 2 parts), SuperSwipe (accent, star only, 1 part), Like (ink, 2 parts), 52 pt tall. It sits inline under the photo and floats over the profile while reading. Labels show only when each side pill has at least 112 pt × the text scale; otherwise the pills are icon-only, keeping their names for screen readers and in tooltips | `people.dart` (`DecisionBar`), `discover_screen.dart` | One consistent control in both places; it never clips a label |
| RD-13 | **Event cover at 16:9, flush.** The card clips its cover to its own top corners; details are padded below (`cardPadding`) with shared `EventMetaRow` lines (date, place, people). The detail page and the create form use the same 16:9 cover with the photo radius | `event_parts.dart`, `event_detail_screen.dart`, `event_form_screen.dart` | The cover is the card's image, not a box inside it |
| RD-14 | **Event save button over the cover.** A white rounded-square button in the cover's top-right corner; status badges wrap to its left | `event_parts.dart` | Frees the text column; same position on every card |
| RD-15 | **Profile header.** Avatar 176 pt (`AppSizes.avatarProfile`, about 2× the old 96 pt) with no ring. Completion is a card: "Profile N% complete", a progress bar, one line and **Complete profile** while anything is missing. At 100% it shows a check and no action. **Edit profile** stays as the one button under the name | `profile_screen.dart`, `extras.dart` (`CompletionCard`) | A number alone didn't say what to do next |
| RD-16 | **Motion.** New motion uses the existing `AppMotion` durations and collapses to zero under reduced motion: the completion bar fill and the top-bar divider. Pills keep the shared press scale | `extras.dart`, `layout.dart`, `people.dart` | No new motion vocabulary |

## Not changed

| Item | Why |
|---|---|
| Likes grid tiles (3:4) | See RD-10 |
| Search field clear button (grey circle with ×) | The standard "clear" glyph, not a holder |
| Date and view tab rows scroll inside the gutter | Bleeding them to the screen edge needs a shared change to `ViewTabs`; noted as a remaining defect in the QA report |
| Match screen scalloped portraits, chat avatars, Likes heart tile in Messages | Avatars, so circles by RD-02 |

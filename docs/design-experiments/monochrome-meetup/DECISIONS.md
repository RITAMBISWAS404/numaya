# Decisions: Monochrome Meetup

| # | Decision | Why | Alternatives rejected |
|---|---|---|---|
| MM-01 | Branch from `experiment/numaya-overnight-completion` (`61de076`) | The newest commit (2026-10-29), and every other reported branch is an ancestor of it (`git merge-base --is-ancestor`) | Older `complete-product` or `full-ui-refinement` heads |
| MM-02 | Flutter-only hand-authored token file (`monochrome_tokens.dart`) re-pointed through the existing `AppColors`, `AppTypography` and `AppLayout` roles | Moves every screen at once with no screen-by-screen colour edits, and cannot touch the web prototype. The generated `numaya_tokens.g.dart` and its `--check` stay valid. | Editing `tokens/numaya.tokens.json`, which would change the web; a runtime `ThemeExtension`, which would mean rewriting every `static const` call site |
| MM-03 | No runtime baseline/monochrome switch | The baseline's colours are compile-time constants used in about 500 places. A toggle would mean converting the design system to `InheritedWidget` lookups, a high-risk refactor for a comparison tool. **Comparison happens through Git** (the base branch) and the before/after sheets. | A debug toggle (the brief allowed skipping it where unsafe) |
| MM-04 | Page `#F4F4F6` (cool grey), surfaces white | Meetup, Jomo and Bevel separate content by surface contrast, and the brief retires the warm stone | A white page with shadowed cards: more shadows, less calm |
| MM-05 | Purple `#7262C7` (canonical) for primary actions, selection, active tab, switch, progress; `#5B4BB0` for purple **text** | `#7262C7` is only 4.46:1 on the grey page; the deep variant passes everywhere | A new purple: forbidden by the brief and `CLAUDE.md` |
| MM-06 | Primary actions are purple, not Meetup's black | The brief asks for purple primary actions. Meetup's own detail-page CTA is black (REFERENCE_AUDIT §E). | Black primaries |
| MM-07 | Figtree for everything | Trial of five OFL faces against the baseline ([font-trial](font-trial/candidates.png)). It is rounded and spacious without being childish, with good numerals. | Plus Jakarta (wide), Nunito (childish), DM Sans and Manrope (mechanical), keeping Hanken |
| MM-08 | Sentence case for modal titles and field labels; uppercase only for eyebrows | All four references use sentence case; the uppercase was a Withings trait | |
| MM-09 | Floating Meetup tab bar, kept in `bottomNavigationBar` (content doesn't scroll under it) | The Meetup look without changing scroll insets on every screen | Overlaying content: needs per-screen bottom padding |
| MM-10 | Solid translucent panel (ink 72%) behind text on photos, inset 6pt | The brief forbids gradient scrims; the panel keeps white text ≥ 4.5:1 over any photo | A plain shadow on text (fails contrast) |
| MM-11 | SuperSwipe on the brand-subtle surface; Like purple | One purple primary per screen; SuperSwipe stays distinct | Both purple (two primaries) |
| MM-12 | Neutral initials avatars (grey with a charcoal initial) | A 176pt dark disc dominated Profile; purple is reserved for actions | Purple avatars (purple everywhere) |
| MM-13 | Event card date eyebrow in purple uppercase | Meetup's date-first hierarchy; a small, functional brand presence | Grey eyebrow: weaker hierarchy, no brand |
| MM-14 | Metric tiles for Account Health activity; "—" plus "Not measured" for views | Bevel; never fake zeros or imply unsupported metrics | Charts: no time-series data exists |
| MM-15 | Illustration slots only on seven screens with no art | The brief: no meaningless boxes | Slots everywhere |
| MM-16 | Existing illustrations recoloured by mapping V16 roles to monochrome roles; the export tool maps the same | Keeps the drawings, removes blue, yellow and warm grey; regeneration stays reproducible | Leaving the V16 blue (competing colour) |
| MM-17 | Goldens regenerated after review | They are the visual baseline *of this branch*; the old ones remain on the base branch | Keeping stale goldens (tests are opt-in, but misleading) |
| MM-18 | Flutter's `textContrastGuideline` not used as a gate | It fails on the untouched baseline too, with false positives in the headless renderer (QA_REPORT) | |

## Continuing the experiment
**Handoff folder:** `docs/agent-handoff/` **does not exist** on this branch or its base, so there was
nothing to update. This folder (`docs/design-experiments/monochrome-meetup/`) is the durable record.

**To resume:**
1. Check out `experiment/numaya-monochrome-meetup`.
2. Install Flutter 3.47.8.
3. In `apps/numaya_mobile`, run `flutter pub get`, then `flutter test`.
4. Read DESIGN_REVIEW_REPORT.md, "Below 4", for the next design tasks, in priority order:
   1. Account Health summary.
   2. A Meetup-style personal page for Profile.
   3. Discover placeholders.
   4. Onboarding and Messaging moves.
5. Commission the assets in ILLUSTRATION_ASSET_BACKLOG.md.
6. Verify on a real Android device.

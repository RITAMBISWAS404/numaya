# Monochrome Meetup: premium refinement 2.0

**Branch:** `experiment/numaya-monochrome-premium-refinement`.
**Base:** `experiment/numaya-monochrome-meetup` at `0003d17`. The base branch is unchanged and
still recoverable.

**Scope:**
- The Flutter app only (`apps/numaya_mobile/`). The web prototype is untouched.
- The palette is the same cool monochrome with purple `#7262C7`. There are no gradients.

## What changed, in one paragraph
- **Type:** headings are now Plus Jakarta Sans (chosen from three combinations rendered in
  Flutter), over Figtree text.
- **Controls:** filled neutral fields and secondary buttons replace outlines, and most dividers
  are gone.
- **Geometry:** a larger, role-based radius scale (8 / 16–18 / 24 / 32).
- **Navigation:** the tab bar is a floating white pill with icons only.
- **Priority screens:**
  - Discovery is image-first, with the decision row inside the card.
  - Profile has a personal hero card and a tile grid.
  - Account Health leads with a status-and-completeness hero, Bevel-style. It shows no invented
    metrics.
  - Onboarding and Messaging got the filled controls.
- **Everything else:** every other surface picked up the system through the shared components.
- **QA:** a new test lays out every full-app route on four phone widths at 100%, 130% and 200%
  text.

## Documents
| File | Contents |
|---|---|
| [DESIGN_REVIEW_AUDIT.md](DESIGN_REVIEW_AUDIT.md) | Starting audit, review cycles, rubric scores |
| [DESIGN_EXPLORATIONS.md](DESIGN_EXPLORATIONS.md) | Alternatives tried and the winner of each |
| [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) | The system in one page |
| [TOKENS.md](TOKENS.md) | Colour, radius, size, spacing, elevation; **contrast table** |
| [COMPONENT_RULES.md](COMPONENT_RULES.md) | Every shared component's treatment |
| [TYPOGRAPHY_GUIDELINES.md](TYPOGRAPHY_GUIDELINES.md) | Faces, scale, rules |
| [LAYOUT_GUIDELINES.md](LAYOUT_GUIDELINES.md) | Gutters, sections, hero cards, small screens |
| [NAVIGATION_SPEC.md](NAVIGATION_SPEC.md) | The icon-only tab pill and the top bar |
| [MOTION_GUIDELINES.md](MOTION_GUIDELINES.md) | Motion and haptics |
| [ILLUSTRATION_BACKLOG.md](ILLUSTRATION_BACKLOG.md) | Slots and art to commission |
| [SCREEN_IMPLEMENTATION_MATRIX.md](SCREEN_IMPLEMENTATION_MATRIX.md) | Per-family changes |
| [VISUAL_QA_REPORT.md](VISUAL_QA_REPORT.md) | Tests, size and text matrix, known defects, APK steps |
| [DECISIONS.md](DECISIONS.md) | Decision log |
| [evidence/](evidence/) | Type trial, before/after sheets, Design Lab, `contrast_check.py` |

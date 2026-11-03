# Monochrome Meetup: design system

**Branch:** `experiment/numaya-monochrome-meetup`, based on `experiment/numaya-overnight-completion`
(`61de076`).

**Purpose:** an experimental alternative visual identity for the native Flutter app
(`apps/numaya_mobile/`). It does not replace the baseline:
- the baseline stays recoverable on its own branch;
- the web prototype is not touched.

**Influences:**

| Reference | Influence | What it contributes |
|---|---|---|
| Meetup | primary | Information hierarchy, events, cards, selection, navigation |
| Jomo | supporting | Spaciousness, tall rounded buttons, quiet headings |
| Bevel | supporting | Metric cards and missing-data states |
| Alan | supporting | Editorial pages, tinted explanation cards, rounded-square buttons |

Evidence for each is in [REFERENCE_AUDIT.md](REFERENCE_AUDIT.md).

## Principles
1. **Neutral first, purple on purpose.**
   - The page is a cool soft grey; surfaces are white; text is charcoal.
   - Purple (`#7262C7`, Numaya's canonical brand colour) marks only what matters:
     - the one primary action;
     - the selected control;
     - the active tab;
     - progress;
     - links;
     - rare celebratory moments (the match).
   - It is never decoration on ordinary cards, icons or labels.
2. **No gradients.**
   - Anything over a photo sits on a solid translucent panel.
   - Separation comes from surface contrast first, then spacing, hairlines, and finally soft shadows.
3. **Flat by default, float on purpose.** Cards sit flat on the grey page. Only things that float
   over content cast a soft shadow:
   - the tab bar;
   - the RSVP bar;
   - the toast;
   - buttons over photos.
4. **Rounded, not bubbly.** Each component role has its own corner radius
   ([TOKENS.md](TOKENS.md#shape)), not one giant radius for everything.
   - Buttons, filters and tabs are full pills.
   - Header buttons are rounded squares.
5. **Spacious and editorial.**
   - 20pt gutters and 32pt between sections.
   - Bold Figtree headings.
   - 16/24 body text.
   - Left-aligned page titles.
6. **Missing data is said, not faked.** Metric tiles show an em dash and "Not measured" instead of zero.
   Demo data stays labelled.
7. **Accessible by construction.**
   - Every text role meets 4.5:1 on every surface it is used on; unit tests enforce this.
   - Control boundaries meet 3:1.
   - Touch targets are at least 44pt.
   - Motion turns off with the system setting.

## Where things live
| What | Where |
|---|---|
| Token values (Flutter-only, hand-authored) | `lib/core/design_system/tokens/monochrome_tokens.dart` |
| Roles every screen uses | `foundations/app_colors.dart`, `app_typography.dart`, `app_layout.dart` |
| Motion (unchanged centralised system) | `foundations/app_motion.dart`, `app_transitions.dart` |
| Components | `lib/core/design_system/widgets/*` (import only `design_system.dart`) |
| Illustration placeholder | `widgets/illustration_slot.dart` |
| Design Lab (development only) | Demo Hub › Design › Design Lab (`/design-lab`) |

**The web token pipeline is untouched.** `numaya_tokens.g.dart` is still generated from
`tokens/numaya.tokens.json`, and the monochrome layer re-points roles on top of it.

## Documents
| Document | Contents |
|---|---|
| [TOKENS.md](TOKENS.md) | Colour, contrast, type scale, spacing, radii, elevation |
| [TYPOGRAPHY_GUIDELINES.md](TYPOGRAPHY_GUIDELINES.md) | Font choice, licence, roles, rules |
| [COMPONENT_RULES.md](COMPONENT_RULES.md) | Each component's states |
| [LAYOUT_GUIDELINES.md](LAYOUT_GUIDELINES.md) | Gutters, rhythm, page patterns |
| [MOTION_GUIDELINES.md](MOTION_GUIDELINES.md) | Durations, curves, reduced motion |
| [ILLUSTRATION_GUIDELINES.md](ILLUSTRATION_GUIDELINES.md) and [ILLUSTRATION_ASSET_BACKLOG.md](ILLUSTRATION_ASSET_BACKLOG.md) | Illustration slots and the assets they await |
| [UI_IMPLEMENTATION_MATRIX.md](UI_IMPLEMENTATION_MATRIX.md) | Every screen family and what changed |
| [DESIGN_REVIEW_REPORT.md](DESIGN_REVIEW_REPORT.md) | Review cycles, rubric scores, fixes |
| [QA_REPORT.md](QA_REPORT.md) | Test results, accessibility, limits |
| [DECISIONS.md](DECISIONS.md) | Decisions with reasons; continuation notes |

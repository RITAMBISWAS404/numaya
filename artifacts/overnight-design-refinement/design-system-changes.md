# Design-system changes

The refinement was made almost entirely in the shared system: tokens, shared components and their
styles. That is why 106 of the 162 captured states changed while only three screen files have
screen-specific edits.

Method: Apple Design + Impeccable. Impeccable's `context`, its critique of the Apple baseline (scored
26/40, with three P1 findings), and its polish and craft-floor playbooks set the priorities. Apple
Design's principles set the rules applied below: purpose, familiarity and consistency, restraint, and
a destructive style for irreversible actions. The skill-combination matrix had already shown this
pairing to be the strongest approach
([report](../skill-combination-matrix/README.md)).

## Tokens (`tokens/numaya.tokens.json`)

| Token | Before | After | Why |
|---|---|---|---|
| `component.button.primary.bg-top` / `bg-bottom` | ink gradient (`neutral.800` → `surface.inverse`) | flat `semantic.color.brand.default` | Purple owns the primary action (Impeccable P1). White on `#7262C7` is 4.90:1. |
| `component.button.primary.bg-hover-*` | ink hover | `semantic.color.brand.hover` | Hover state for the new fill. |
| `component.button.ink.bg-top` / `bg-bottom` (new) | n/a | `neutral.800` → `surface.inverse` | Pass and Like keep the ink pill. The token makes that explicit instead of borrowing the primary token. |

No raw colours were added. The token pipeline, the contrast tests and the raw-colour tests all pass.

## Shared components and styles

| Component / style | Change | Consumers |
|---|---|---|
| `Button` primary, `Fab` (`components.css`) | Inherit the purple tokens. | Every primary CTA and step FAB: entry flow, sheets, empty and result states, Activity, account. |
| Action bar (`content.css`) | Pass and Like use `--button-ink-*`. SuperSwipe stays the single purple action on the card. | Discover, Like back. |
| Prompt object (`.prompt`, `.profile-section--prompt`) | Lavender `surface.brand` with no hairline, a deep-purple question (`text.brand-deep`, 7.32:1), and a quiet Fraunces quotation mark (decorative, `content: "\201D" / ""`). | Discover, Profile, Edit profile, Edit preview, Interests (onboarding). |
| Shared interests (`.shared-interests__pill`, `.match__shared-chip`) | One lavender treatment for "You both like" everywhere (deep purple, semibold). | Discover, Like back, Match. |
| `MatchCelebration` (`Patterns.jsx`) | New `you` and `shared` props show the pair (your monogram overlapping theirs) and what you share, from real data. | Match. |
| Photo scrim (`content.css`) | Mid-stops at 40% and 84%, so white names reach 4.66:1 or better (was 3.06:1). | Discover, Like back, Edit preview. |
| `ProfileSection` / `ProfileCard` headings | h3 → h2. The heading order now follows the page h1. | Discover, Like back, Edit preview. |
| `SetupProgress` (`Content.jsx`) | "Step N of 3" kicker is screen-reader text. The ordered list and the "N of 3 done" header carry position visually. | Profile setup intro. |
| `ActivityCard`, Activity details | The category follows the title as a quiet secondary caption, instead of a purple kicker above it. | Explore, My activities, Activity details. |
| `IdentityRow` in a list row (`activity.css`) | Fills the row, so trailing actions sit on the right edge. | Connected accounts, Blocked people, Guests. |
| Browser surfaces (`base.css`) | `::selection` uses the brand tint and the caret is brand purple. | All text fields. |
| Composer placeholder (`chat.css`) | `text.muted`, for 4.5:1 placeholder contrast. | Match, Conversation. |

## Screen-specific edits

These are the only screens whose own file changed, beyond inheriting the system.

| Screen | Change | Why |
|---|---|---|
| Conversation → Unmatch sheet (`screens.jsx`) | "Unmatch" uses `destructive-solid`. | It is an irreversible ending ("You won't see each other again"), consistent with Block and Delete account. A brand-purple button would read as a positive action. |
| Connected accounts (`account.jsx`) | "Connect" is `secondary`. | The screen says connecting is optional. Two equal purple buttons over-weighted it. |
| Premium (`account.jsx`) | "Your plan" kicker plus a "Free" heading become one heading: "You're on Free". | Removes the kicker above the heading (an Impeccable ban). The copy is unchanged in meaning. |
| Match, Profile (`screens.jsx`) | Pass `you` and `shared` to `MatchCelebration`. Move the prompt above the readiness card. | Match shows the pair and shared ground. The profile leads with what matches reply to, not a metric. |

## Considered and rejected

- **A prompt card in the Welcome hero.** Spec B-02 mentions a prompt-card hero, but a smoke contract
  and the illustration registry deliberately keep the hero as a reserved slot for unsupplied
  artwork. That slot was left empty and honest.
- **Lavender on conversation openers, the "Your move" tag, or Likes cards.** These would dilute the
  two conversation hooks. Lavender stays reserved for prompts and shared interests.
- **Glass, gradients or a second accent colour.** These were explicitly excluded, and the matrix
  showed they did not help these screens.
- **Changing the Interests count copy** ("3/5 selected" and "3/5 interests"). Both strings are spec
  copy, so the duplicate count was noted and left.

## Documentation updated

- [Decision log](../../docs/research/decision-log.md): new **D-22**. It supersedes the ink-CTA part of
  D-21 and records the prompt object and the no-kicker rule.
- [Foundations](../../docs/design-system/foundations.md): purple footprint, surfaces and elevation.
  This also corrects an older inaccuracy: selected controls were documented as ink, but they render
  purple.
- [Components](../../docs/design-system/components.md): PromptCard and SetupProgress.
- [UI map](../../docs/numaya-meetup-ui-map.md): the primary button row.

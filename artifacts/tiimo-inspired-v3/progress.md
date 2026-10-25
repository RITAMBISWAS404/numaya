# Progress log: Tiimo-inspired V3

The brief was revised mid-run. The revision added a circular match crop, no gradient on
placeholders, Activity and Messages in scope, and design-decisions.md. The log below covers both;
the final state follows the revised brief.

## Phase 0: reconnaissance (done)

- Baseline: `experiment/tiimo-white-surface-refinement` at `c90e93f`, the same commit locally and on
  the remote. New branch `experiment/tiimo-inspired-v3` from that commit, in its own worktree. The
  approved branch, the earlier Tiimo branches and the unfinished Impeccable checkout were not touched.
- Six screens mapped to gallery states:

  | Screen | States |
  |---|---|
  | Basics | 013, 014, 015 |
  | Interests | 016, 017, 144 |
  | Discover | 019, 021, 145 |
  | Full profile | 020 (full profile scroll), 059 (Like back profile) |
  | Match | 030, 032, 146 |
  | Conversation | 038, 039, 042, 148 |

- Baseline: 18 captures of V2 in `screenshots/baseline/`. The 15 that V2 also captured are
  byte-identical to V2's committed finals.
- Pemu reference: not found in Mobbin (searched "Pemu" and Pemu-like chip and button screens). I
  proceeded with an original compact rounded-rectangle system, as the brief allows.
- Runtime audit of the six screens (coloured text and capsule-shaped elements):
  - **Coloured headings:** the interest set capsules (peach, lilac and mint text), and the purple
    "A perfect first date" label on Interests, Discover and Like back.
  - **Capsules:** chips, shared-interest chips, photo badges, the tab bar and its items,
    Pass/Like back, the small match button, and Pass/SuperSwipe/Like.
- Match decorations: confetti pseudo-elements (V2) and the lavender `organic-portrait__backdrop`
  halo.

## Phases 1–2: shared refinements, photo and match (done)

- **Tokens:**
  - `component.tiimo.radius-control` (12) and `radius-tag` (8).
  - `color.tiimo.photo-fade` (black at 72%) on a new primitive `alpha.black-72`.
- **Geometry:**
  - buttons and the 72 × 56 action buttons: 16;
  - chips, small buttons and segmented options: 12;
  - photo badges, "Your move", "New" and activity tags: 8;
  - tab bar: 24, items 16;
  - search: 16.
- **Headings:**
  - Interest set labels are neutral ink, sentence case. The category colour moved to a small
    tinted emoji holder.
  - The prompt question is neutral secondary text.
- **Photo overlay:** a black bottom-to-top fade on `.profile-card__overlay` only.
- **Match:** confetti removed and the lavender halo hidden. The organic frame and the overlapping
  avatar (white separation ring) are kept.
- **After:** the runtime audit finds no coloured headings and no capsule controls. The coloured text
  that remains is category chips only (selected interests and shared interests).

## Revised brief (done)

- **Scope:** eight screens. Added Activity (061, 064, 153) and Messages (034, 147). Baseline
  re-captured from a clean V2 checkout: 23 states.
  - Audit: only semantic colour (category and state tags) and no capsules remain on either screen.
- **Photo fade:** applied only when a real `<img>` is present. Placeholders keep V2's solid band and
  take no gradient.
- **Match:**
  - Their photo is a clean circle: a 43% clip on the existing component.
  - Your avatar's centre is at 95% of their circle's radius, at 45° lower-left.
  - Your avatar scales with their portrait on short phones.
- **Pass/SuperSwipe/Like:** the 72 × 56 action buttons took the button corner (16).

## Visual QA (done)

See validation-report.md. Three defects were found and fixed: the capsule action buttons, the
avatar's size at 375, and the weak avatar overlap.

## Validation and delivery (done)

- Check, e2e (144 + 88 + 40) and axe are all green.
- Default mode is byte-identical to V2 in all 23 states.
- Implementation commit `7c67749`, then the artifacts commit, pushed to
  `experiment/tiimo-inspired-v3`.

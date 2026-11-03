# Design review report

## Method
- **Renders:** each cycle rendered all 186 golden screens, plus the Design Lab, with the real fonts
  (Figtree, Material Icons, Noto Color Emoji) at 393 × 852 @2x, with QA states at 375 × 667, 320 and
  large text.
- **Comparison:** renders were compared with the baseline captured from `61de076` in the same
  environment, with the Mobbin references, and with the rules in this folder.
- **Viewing:** reviews were done on rendered PNGs in the test harness, **not on a phone or emulator**.

## Cycles
| Cycle | Focus | Defects found, then fixed |
|---|---|---|
| 0 | Token pass only | Black primary buttons; tinted (not filled) selection; stock tab bar; heavy charcoal avatar; uppercase nav titles; a gradient scrim on Discover |
| 1 | Components | **The tab bar filled the whole screen** (a `Center` in `bottomNavigationBar`; five capture tests failed); fixed with `heightFactor: 1`. Like still black → purple. Avatars → neutral. Match portrait → brand-subtle. Send → purple circle. Progress, plan selection and radios → purple. |
| 2 | Families: onboarding, Discover, events, social, profile, settings | For You like buttons were black circles → brand surface. Event cards lacked Meetup's date hierarchy → purple date eyebrow. The RSVP bar sat flat → floating card. Account Health was list-only → metric tiles. InfoCard → tinted (Alan). |
| 3 | Small screens and large text | At 200% text, long names broke inside the word on the photo card. Panel inset tightened and the card name set to 32pt; the extreme case remains (the baseline breaks too). See QA_REPORT. |
| 4 | Consistency | Sheets still had 20pt corners → 28pt (theme and shared sheet). The Material `primary` was still ink → brand. |

## Rubric (1–5; a review aid, not proof)
**Criteria:**

| Criterion | Short |
|---|---|
| Visual hierarchy | Hier |
| Typography | Type |
| Spacing and layout | Space |
| Component consistency | Comp |
| Colour and contrast | Colour |
| Clarity of interaction | Interact |
| Reference-inspired coherence | Ref |
| Accessibility and legibility | A11y |

| Screen family | Hier | Type | Space | Comp | Colour | Interact | Ref | A11y | Notes |
|---|---|---|---|---|---|---|---|---|---|
| Shell and tab bar | 4 | 4 | 4 | 4 | 4 | 4 | 5 | 4 | Clearly Meetup |
| Onboarding | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 4 | Layouts unchanged from the baseline; the restyle is system-level |
| Discover | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 4 | Over grey placeholders the photo panel reads as a heavy dark block; with real photos it is fine |
| Events list and detail | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | Strongest Meetup influence: eyebrow, covers, floating RSVP bar |
| Profile and edit | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 4 | Still a stack of cards rather than a "personal page"; see below |
| Likes and match | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | |
| Messaging | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 4 | |
| Account Health | 3 | 4 | 4 | 4 | 4 | 4 | 3 | 4 | Metric tiles help, but the page is long and row-heavy |
| Settings and safety | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | Grouped cards and tinted tips (Meetup, Alan) |
| Design Lab | 4 | 4 | 4 | 4 | 4 | 4 | — | 4 | Development only |

**No family scores 5 overall.** The restyle is coherent and every high-priority defect found was
fixed. But several families keep the baseline's layout composition: the brief allowed composition
changes, and they were made only where clearly justified.

## Below 4: what would improve it (next cycle)
- **Account Health (hierarchy 3):**
  - collapse "Discovery setup", "Verification" and "Account notices" into one summary card with
    drill-in;
  - lead with the visibility state and completeness as two large metric tiles.
- **Profile (reference coherence 3):** a Meetup-style personal page:
  - a larger photo header;
  - interests as one horizontal row;
  - the completion card moved below the profile content.
- **Discover (reference coherence 3):** placeholders could use a lighter panel style when no
  real photo is present, or real demo photography.
- **Onboarding and Messaging (reference coherence 3):** no screen-specific Meetup or Jomo moves yet.
  Candidates:
  - Jomo-style tall rounded option cards in onboarding;
  - a Meetup-style "New matches" carousel card.

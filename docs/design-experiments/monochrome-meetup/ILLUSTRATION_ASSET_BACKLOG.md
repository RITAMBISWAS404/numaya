# Illustration asset backlog

**Applies to:** every `IllustrationSlot` placed in the app, plus the two in the Design Lab.

**Common requirements for every asset:**
- format: SVG;
- transparent background;
- monochrome, with one purple accent (see
  [ILLUSTRATION_GUIDELINES.md](ILLUSTRATION_GUIDELINES.md)).

**Reserved size:** the width at 393pt screen width.

| Slot | Screen (file) | Purpose | Ratio | Reserved | Mood / subject | Priority |
|---|---|---|---|---|---|---|
| `safety_header` | Safety and wellbeing (`help_screens.dart`) | Introduce "Date with confidence" | 16:9 | 353 × 199 | Two people meeting in a bright public café; a phone face-down | High |
| `premium_header` | Numaya Premium paywall (`premium_screens.dart`) | "More ways to meet the right people" without hard sell | 16:9 | 353 × 199 | A few profile cards fanned out, one highlighted in purple | Medium |
| `opening_moves_header` | Opening Moves (`profile_hub_screens.dart`) | "Start a new conversation" | 16:9 | 353 × 199 | Two speech bubbles, one with a question mark in purple | High |
| `like_gone` | Like back, when the like is no longer active (`likes_screens.dart`) | Soften "this like has moved on" | 4:3 | 176 × 132 | A heart drifting off a card, gently | Medium |
| `person_missing` | Person profile not found (`likes_screens.dart`) | "This profile is no longer here" | 4:3 | 176 × 132 | An empty photo frame with a small plant | Low |
| `event_missing` | Event detail and Who's going, event not found (`event_detail_screen.dart`, `event_people_screen.dart`) | "This event isn't here anymore" | 4:3 | 176 × 132 | A folded event flyer and a calendar page | Low |
| `likes_empty` | Design Lab sample (`design_lab_screen.dart`) | Pattern sample: "No incoming likes yet" | 4:3 | 200 × 150 | Not shipped in a product screen | — |
| `events_explore` | Design Lab sample | Pattern sample: "Explore events near you" | 16:9 | 353 × 199 | Not shipped in a product screen | — |

**Considered and left without a slot**, because existing art or typography already does the job:
- Discover's exhausted feed;
- the Messages empty state;
- the Events empty and no-results states;
- Account Health's not-enough-data state;
- the Welcome hero;
- the match screen;
- verification.

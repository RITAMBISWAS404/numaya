# Illustration and mascot asset backlog

**Status:**
- No mascot or final art was made in this pass; the brief says to prepare the layout only.
- Every place art can go is an `IllustrationSlot` (named, fixed ratio, decorative) or an existing
  `IllustrationView` SVG.
- When the Numaya mascot exists, it drops into these places with `asset:`, and nothing moves.

**Reference:** Alan's bear, studied on Mobbin:
- [Today dashboard](https://mobbin.com/screens/fde621eb-94c5-4c7e-88c1-7a32ea845bd7);
- [explanatory cards](https://mobbin.com/screens/fc70fe25-5fdc-4ab8-8c99-416546c33a23);
- [companion chat](https://mobbin.com/screens/f3b30253-bcee-43d6-a2b4-18035a9e69d1).

Alan uses the mascot in four ways:
1. **As a hero** on one summary screen.
2. **On the right of explanatory cards:** text left, mascot right, the card stays readable without
   it.
3. **As a guide's face** in a conversation header.
4. **As a small avatar** in sheets.

It never sits on task screens such as forms, settings or payment.

## Rules for the mascot in Numaya
- **Purpose first.** It welcomes, explains or reassures. It never decorates a task, and it never
  sits beside a person's photo: in a dating app, people are the content.
- **Style:** monochrome ink with the single purple `#7262C7` accent and the `#F1EFF9` tint. No
  gradients. Semantic accents (FP-01) only when the moment has that meaning, for example green on a
  success.
- **Absent is fine.** Every slot's copy carries the meaning on its own. Slots are excluded from
  semantics, and the screen works with the placeholder or nothing.
- **Ratios:**
  - `IllustrationSlot.header` (16:9) for page headers and explainers;
  - `IllustrationSlot.empty` (4:3) inside empty-state cards;
  - 72pt square for onboarding step art.
  - Export with a 24pt safe margin.

## Slots, with the mascot's purpose
| Slot | Screen | Ratio | Mascot expression and purpose | Priority | Today |
|---|---|---|---|---|---|
| `onboarding_hello` | Onboarding: name | 72pt sq | Waving, welcoming: "nice to meet you" | High | SVG `hello` |
| `onboarding_interests` | Onboarding: interests | 72pt sq | Holding two hobby props, curious | Medium | SVG `interests` |
| `onboarding_verify` | Onboarding: verify offer | 72pt sq | Holding a phone with a check, reassuring | High | SVG `verified` |
| `onboarding_notifications` | Onboarding: notifications | 72pt sq | Listening, a speech bubble | Low | SVG `noChats` |
| `profile_completion` | Profile › Complete profile (header) | 16:9 | Assembling a profile card from tiles, encouraging | High | Slot |
| `health_how_it_works` | Account Health › How this works | 16:9 | Calm explainer beside a profile card; no dials or scores | High | Slot |
| `safety_header` | Safety and wellbeing | 16:9 | Protective: at a café table with a shared plan on a phone | High | Slot |
| `opening_moves_header` | Opening Moves | 16:9 | Holding a question card, playful | Medium | Slot |
| `premium_header` | Premium | 16:9 | Opening a door onto profile tiles | Low | Slot |
| `discover_seen_everyone` | Discover: seen everyone | 132pt | Resting, content: "come back later" | Medium | SVG `seenEveryone` |
| `discover_paused` | Discover: snoozed | 132pt | Asleep in a hammock | Medium | SVG `paused` |
| `likes_empty` | Likes: no likes yet | 160pt | Waiting hopefully with an empty heart frame | Medium | SVG `noMatch` |
| `messages_empty` | Messages: no chats | 132pt | Writing the first message | Medium | SVG `noChats` |
| `events_explore` | Events: no events nearby | 4:3 | Looking through binoculars | Medium | SVG `noEvents` |
| `events_going` | Events: my events, going | 4:3 | Celebrating an RSVP with a ticket | Medium | SVG `eventGoing` |
| `event_missing` | Event gone; people list gone | 4:3 | Shrugging kindly beside an empty chair | Low | Slot |
| `like_gone` / `person_missing` | A like or profile no longer here | 4:3 | Waving goodbye, no blame | Low | Slot |
| `health_not_enough_data` | Account Health: can't check yet | 132pt | Patient, with an hourglass | Low | SVG `notEnoughData` |

## Considered and kept typography-first
| Place | Why no mascot |
|---|---|
| Discover card, profile, photo viewer | The person's photo is the content; a mascot would compete with them |
| Match | FP-05: the matched person alone is the moment |
| Chat | Conversation between two people; a third face intrudes |
| Settings, notifications, privacy, delete account | Task screens; art pushes controls below the fold at 200% text |
| Paywall plans | A decision screen; a mascot would read as pressure |
| Successful RSVP | Already confirmed by the bar's live-region status and a toast; a modal celebration would block |

## Handoff
1. Export each asset at its ratio with a 24pt safe margin, as SVG, into
   `apps/numaya_mobile/assets/illustrations/`.
2. Set `asset:` on the `IllustrationSlot`, or swap the `NumayaIllustration` for the
   `IllustrationView`.
3. Run `flutter test test/widget/final_polish_test.dart` (slot ratios), then the screenshot
   captures.

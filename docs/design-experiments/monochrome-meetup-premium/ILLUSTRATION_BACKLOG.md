# Illustration backlog

**Status:**
- No new art was drawn this round (no illustrator; the brief forbids generated mockups in place
  of app work).
- The app reserves named `IllustrationSlot`s where art would add meaning. Each slot has a fixed
  aspect ratio, so the final SVG drops in without layout change: pass `asset:`.

**Style for every asset:**
- monochrome ink line art with a single purple `#7262C7` accent and a `#F1EFF9` tint fill;
- no gradients and no photography;
- matching the 12 existing recoloured SVGs (see
  [../monochrome-meetup/ILLUSTRATION_GUIDELINES.md](../monochrome-meetup/ILLUSTRATION_GUIDELINES.md)).

## Slots in the app
| Slot | Screen | Ratio | Brief for the artist | Priority | Status |
|---|---|---|---|---|---|
| `profile_completion` | Profile › completion hub (header) | 16:9 | A profile card assembling itself from photo, prompt and interest tiles | High | **New this round** |
| `health_how_it_works` | Account Health › How this works | 16:9 | A calm explainer: a profile card, a check mark, and a small "you decide" hand, without dials or scores | High | **New this round** |
| `opening_moves_header` | Opening Moves | 16:9 | Two speech bubbles, one a question card | Medium | Existing |
| `premium_header` | Numaya Premium | 16:9 | More ways to meet: a door ajar with small profile tiles | Medium | Existing |
| `safety_header` | Safety and wellbeing | 16:9 | Date with confidence: a café table with a phone showing a shared plan | High | Existing |
| `events_explore` | Events, explore empty | 4:3 | Explore events near you | Medium | Existing |
| `event_missing` (×2) | Event not found; people list | 4:3 | This event isn't here any more | Low | Existing |
| `likes_empty` | Likes, empty | 4:3 | No incoming likes yet: an empty heart-shaped frame | Medium | Existing |
| `like_gone` | A like that expired | 4:3 | This like has moved on | Low | Existing |
| `person_missing` | Profile not found | 4:3 | This profile is no longer here | Low | Existing |

## Considered and not added
| Place | Why not |
|---|---|
| Discover | The photo is the content; art would compete |
| Settings, help article, paywall plans | Dense, task-focused; an illustration would push actions below the fold at large text |
| New-match screen | Already a composed portrait (the scalloped initial) |
| Onboarding steps | The existing SVGs (hello, interests, verified and others; 12 in the app) already carry the storytelling |

## Handoff
1. Export each SVG at the slot ratio with a 24pt safe margin.
2. Place it under `assets/illustrations/`.
3. Set `asset:` on the slot.
4. Re-run `flutter test --tags screenshots --run-skipped --update-goldens` and review.

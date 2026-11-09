# Creative Lab V7

Experiment branch only. The app's default is the baseline plus the V6 improvements. Nothing here is
approved until the owner exports choices from the gallery.

## Directions

| | Name | Rule |
|---|---|---|
| A | Image-led | The photo is the page: edge to edge, words on a smooth scrim, one large number where there is no photo. |
| B | Calm and spacious | Words before imagery, nothing on photos, compact identity, sheets that keep you in place. |
| C | Social and expressive | What connects two people leads, on solid purple. Warm headings, starters, collected marks. |

Discover, Compliment, Profile and Streak are bound together. They use one direction or the baseline.
The gallery shows the conflict and refuses to export or import a mix.

Recommendation, which is a suggestion and not a selection: direction A for those four screens, the
count on locked Likes, words-led received Compliments and a single Filters list. Keep the floating
navigation and benefits-first paywall.

## What each experiment records

`experiments.json` is the registry: user task, friction, essential information, primary action,
benefit, cost, hypothesis, references, route, verification and a four-way critique by one reviewer
in separate passes. Hypotheses are design assumptions, not user research.

## Rejected before building

- Full-screen swipe stack without page scroll: hides prompts and safety actions behind gestures.
- Blurred faces behind the locked Likes count: reads as pressure, and the brief rules out deceptive urgency.
- Compliment suggestions written from the person's profile: would need generated text and could misrepresent the sender.
- Purple Discover page background: colour competes with photos.

## Corrected after rendering

- Edge-to-edge Profile cover kept rounded corners at the screen edge: now square.
- Locked Likes said the count twice: now once.
- Photo-led received Compliment pushed actions off screen: photo is now 4:3.
- Compliment starters asked "Where was this?" about written prompts: starters now depend on the target.

## Product proposals (not implemented, not active behaviour)

- Let a member attach a Compliment to a shared interest. It changes what a Compliment can reference, so the moderation and notification copy would need review.
- Show today's status in the Streak header. The number-led and purple directions omit it, and if either is chosen it should return.

## Limits

Reviewed by renders on one emulator, not by people. Purchase, backend and notification behaviour are simulated.

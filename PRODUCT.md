# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Intentional daters: adults looking for real dates and relationships who are tired of endless
swiping, using Numaya on their phone. (Confirmed by the product owner, October 2026.)

## Product Purpose

Help people get from a profile to a good first date with fewer swipes: profiles give the right person
something real to talk about, and matches lead straight into a first message. Success is a
conversation that starts easily and a better first date, not time spent browsing.

## Positioning

Conversation-first. Profiles are built around prompts and real shared interests ("You both like"),
so the right person knows what to say; real-world activities extend that into meeting in person.
(Confirmed; see also docs/research/decision-log.md D-11.)

## Operating Context

Mobile, one-handed, in short sessions. Core loop in the repository: onboarding (phone number, code,
basics, interests and prompt, photos) → Home (Discover profile cards, like / pass / SuperSwipe) →
match → messages; plus Activity, Likes and Profile tabs, safety (report, block, unmatch) and
settings.

## Capabilities and Constraints

- Web prototype (React + Vite) rendered at a 393 px phone width; no production framework is chosen
  yet (docs/engineering/architecture.md).
- UI comes from `src/design-system/` and semantic tokens in `tokens/numaya.tokens.json`.
- Every state a screen spec lists must keep working; screens the spec does not describe are not
  built.

## Brand Commitments

- Name and logo: "numaya" wordmark with its mark (existing asset; keep).
- Brand purple #7262C7 as the primary brand colour; white and neutral foundation.
- Fraunces for prominent headings and names; Inter for body text, labels and controls.
- Headlines are plain ink; no selectively coloured words.

## Evidence on Hand

- No profile photography exists in the repository: photos are honest grey placeholders and must not
  be replaced with generated or stock people.
- The welcome hero composition and the match "hands forming a heart" illustration are unsupplied:
  their slots are reserved (src/design-system/illustrations/registry.js) and must not be faked.
- Sample people and conversations in src/flows/data.js are mock data, labelled as such in the UI.

## Product Principles

1. Conversation over browsing: surface what two people can talk about.
2. Truthful by default: no invented photos, compatibility claims or social proof.
3. Calm confidence: fewer, better decisions rather than pressure or urgency.
4. One coherent brand: purple identity carried consistently, not as decoration.

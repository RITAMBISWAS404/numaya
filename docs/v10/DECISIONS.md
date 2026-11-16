# V10 decisions

## D1 Baseline (2026-11-16)
Branch `experiment/numaya-v10-design-led-20261116-1847` from `6129fa2`: the owner-approved `42b8dba` plus three official
Flutter skills committed in the V10 preparation workspace (no app changes). That workspace and its branch were left
untouched.

## D2 Pilot directions
V2's protocol: recommended A plus one materially different alternative. A = People first; the alternative is C =
Editorial (the largest compositional contrast with A; A+B overlaps A on Discover). Implemented as real Flutter code behind
the Design Lab group `v10-direction` (O current, A, C). The default stays O until the owner selects, as the review rules require.

## D3 Critique round 1 (blind; baseline, candidate 1 = C, candidate 2 = A)
Critic carried A: clearest information structure, labelled facts map directly to Profile. C regressed on typography
(run-on fact line wrapping with a leading separator, orphaned words) and mixed container systems. C is **not** carried
to Profile and Chat; it stays selectable on Discover for the owner. No third direction: A's defects were mechanical,
not an unresolved trade-off.

Round-1 fixes applied to A:
1. One labelled Compliment component (photo variant as a dark glass pill, content variant as a tint pill), including the
   hero, which reserves the pill's width beside the name.
2. Section rhythm tightened (bio to facts and facts to shared interests 16pt, not 20+20).
3. Prompts on the same white card as About; balanced bio and answers; long fact values take the full row.

## D4 Carry A to Profile and Chat
- Every person body (Discover, Likes, person page, own preview, onboarding review) uses the selected direction through
  the shared `personSections`, so a person looks the same everywhere.
- Own Profile's prompt uses the same `V10PromptCard` as Discover, with Edit as its action.
- Received Compliment: a sender block (photo, "X sent you a Compliment", "about your photo/prompt") replaces the small
  system line; the quoted bubble and reply composer are unchanged.

## D5 Critique round 2 and default (2026-11-16)
Blind round 2 (baseline vs A after round-1 fixes): A is an improvement, "a narrow one". Top defects, all fixed:
1. Received Compliment: the reply field was invisible (page-on-page, DEF-V10-01) and there was no visible decline. Fixed:
   the field now sits on a white tray, and a Dismiss link asks first.
2. Own Profile: the prompt's text link broke the chevron-row pattern, and Premium sat inside the identity group. Fixed:
   the whole card opens the editor with a chevron, and Premium has its own group.
3. Discover: 12pt grey labels were too small and the section rhythm was uneven. Fixed: labels are now 14/20 medium, and
   the facts run gap is 12.

A becomes `proposed` (what launches render). The V10 brief delegates choosing where evidence is clear, A won both rounds,
and the alternatives stay one tap away in the Design Lab. No third round: the remaining notes were the defects above,
not an open trade-off.

Making A the default exposed three real regressions, all fixed before acceptance:
- The facts list dropped gender and pronouns. It now leads with them, as the baseline did.
- The bio used the 18/26 answer role instead of the specified 18/24 card-primary role (UI-020). It now uses card-primary.
- The labelled pill replaced the fx sheet/bar actions. It now shows only with the default fx variant.

Tests asserting O-only structure (emoji pills, the 48pt squircle) are pinned to O. Each has an A counterpart that
asserts the new rule, and no assertion was removed.

## D6 Credits and streak above identity
The critic's round-2 note #2 also asked to move credits and the streak below "Your profile". That order is an earlier
owner selection (Visual Lab review vl2-8510778), so V10 keeps it and records the critique for the owner. Only Premium
moved, because it is an offer, not a status.

## D7 Final-candidate critic (2026-11-16)
On the first pass the critic reported that X and Y were byte-identical. The capture harness had stopped choosing O once A
became the default, so the "before" folder held A. The harness now always chooses its direction; O was re-rendered and the
gallery rebuilt.

Valid pass verdict: **narrow yes**.
- Y is improved on Discover top, Discover photos and prompts, and the received Compliment.
- Y is equivalent on the About sheet and the active chat.
- Y was worse on Profile, because of Premium as an orphaned, headerless card.

Applied:
1. Premium goes back to being a row of "Your profile". This reverses round 2's move: the two critics disagreed, and the
   render showed a one-row group plus a stray card, so the evidence favours the original placement.
2. At ≥130% text the received Compliment drops the large sender photo, since the header already shows it. This keeps
   the Compliment itself in view at 200%.

Found while testing and applied: shared-interest pills go from 12pt to 14pt. At 12pt the rendered glyphs measured 1.95:1
against the tint with real fonts (SDK contrast guideline, PR-004).

Recorded, not changed (pre-existing in both versions or out of V10 scope):
- At 320pt and 200% text, the hero name block covers the face.
- An incoming chat bubble ends on one short word ("ten.").
- "Not verified" shows both as a chip and in the Verify row.
- The credits subline repeats the credits title.

## References actually inspected
- Figma ENTE VISUAL DESIGN (Copy), node 2513:51496 "List items", rendered via the Figma connector: title + muted
  subtitle and trailing value rows. Supports labelled facts.
- Mobbin iOS (2026-11-16), question "how do dating profiles present labelled facts": Tinder lifestyle
  ([d7f88c62](https://mobbin.com/screens/d7f88c62-50ee-4f16-9f6f-1233e07e376e)) label over value with icon rows in a card;
  Badoo ([cc53696e](https://mobbin.com/screens/cc53696e-e23c-413b-9b74-64e098ace53f)) label left, value right; Plenty of
  Fish and Feeld use pill clouds (the pattern the baseline already had). Adapted: labelled rows; not imported: icons per
  fact, emoji, edit chevrons on someone else's profile.
- Package references (Hinge prompt, Airbnb unboxed biography) read from REFERENCE/04; not re-fetched.

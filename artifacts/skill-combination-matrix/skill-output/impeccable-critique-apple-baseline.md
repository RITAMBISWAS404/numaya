---
target: five Numaya screens (Apple baseline)
total_score: 26
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 3
target_identity: "file:/home/user/numaya/src/flows/screens.jsx"
target_fingerprint: "sha256:9d4aba48c98d3c62c57088131cefceabb26ec2368733f20b1eafc9d59c6e1e16"
target_path: /home/user/numaya/src/flows/screens.jsx
timestamp: 2026-10-24T22-37-21Z
slug: src-flows-screens-jsx
---
Method: dual-agent (A: design-review sub-agent · B: detector + browser sub-agent)
Target: five screens on the Apple-refined baseline 6e4dbd1 — Welcome (index.html, src/prototype/screens/Welcome.jsx), Discover, Match, Profile, Interests (flows.html?screen=…, src/flows/screens.jsx).

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 3 | Unlabelled black scroll bar on Discover reads as a step bar |
| 2 | Match System / Real World | 3 | "Settings and privacy · Active", "up to 20 points" |
| 3 | User Control and Freedom | 3 | Pass not visible above the fold |
| 4 | Consistency and Standards | 2 | Primary action changes shape/colour; prompt card grey vs white |
| 5 | Error Prevention | 2 | Only card action is SuperSwipe |
| 6 | Recognition Rather Than Recall | 2 | Icon-only tabs; swipe only discoverable via aria-label |
| 7 | Flexibility and Efficiency | 3 | Swipe + buttons + undo |
| 8 | Aesthetic and Minimalist Design | 3 | Under-designed: empty Welcome, repeated score |
| 9 | Error Recovery | 3 | Specific empty states |
| 10 | Help and Documentation | 2 | SuperSwipe and readiness unexplained |
| Total | | 26/40 | Acceptable |

## Design Specificity Verdict
Mostly category-interchangeable; Fraunces and the composer opener are the only authored moves. Purple never owns a primary action. "You both like" has no form above the fold. Detector: CLI 0 findings; live 6 (Discover name 2.9:1, detail 4.4:1, h1→h3; Match placeholder 2.8:1; Interests h1→h3).

## Priority Issues
- [P1] Purple never owns a primary action — /impeccable colorize
- [P1] Match moment shows one monogram, not the pair or shared ground — /impeccable delight
- [P1] SuperSwipe is the only card action, squashed capsule — /impeccable layout (partly out of scope: spec places Like/Pass at the end of the profile)
- [P2] Prompt object generic and inconsistent across screens — /impeccable bolder
- [P2] Contrast and heading-order defects (detector) — /impeccable polish
- [P2] Profile score-heavy, prompt below the metric — /impeccable distill / layout

## Persona Red Flags
Jordan: accidental SuperSwipe, guessed tabs, unexplained 73. Casey: filters out of reach, Like/Pass a full scroll away, prompt hidden at 375×667 on Interests. Priya: first view is a photo slab and a star; generic match.

## Minor Observations
Dead tab-bar blur (nothing scrolls under it); red count badges; duplicated/inconsistent interest counts; generic Interests spot art; radius inconsistency; two exits on Match.

## Questions to Consider
Which element says "conversation-first" in one screenshot? What if purple only meant "move toward a conversation"? Should Match be about the two of you plus what you share?

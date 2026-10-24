# Combined experiment: Apple Design + Numaya Visual Craft

Branch `experiment/combined-visual-craft`, based on the Apple experiment (`6e4dbd1`); the
`numaya-visual-craft` skill copied from `998696b` only (commit `d532344`). Original baseline is
`7954fa3`.

## Evidence and capture setup

`node scripts/combined-visual-craft.mjs capture <state> [--root <checkout>]` and `… compare`.
Chromium (Playwright), Vite dev server, 2× DPR, reduced motion, light theme, fonts awaited and
checked (Fraunces and Inter must both report loaded), seeded sessions identical to `npm run gallery`
(match: Maya just matched; interests: 2 chosen / 5 chosen). Viewports: 393 × 852 (primary),
375 × 667 (small phone), 1440 × 900 for Welcome only (the only screen with a designed desktop
layout; flow screens just stretch in single-screen mode).

| State | Code | How it was rendered |
| --- | --- | --- |
| `A_original/` | `7954fa3` | temporary detached worktree, same script |
| `B_apple_design/` | `6e4dbd1` | this branch before any combined change |
| `C_apple_plus_visual_craft/` | this branch, final | same script |

Verification of reuse: every A and B capture (34 files) is pixel-identical to the Apple
experiment's own `*-before-*` / `*-after-*` files in `artifacts/apple-design-experiment/`, so the
labels are correct and the pipeline is deterministic.

Route map (verified in code): Welcome = `index.html` → `src/prototype/screens/Welcome.jsx`;
Discover = `flows.html?screen=discovery` → `Discovery` (`src/flows/screens.jsx`) + `ProfileCard`,
`ProfilePrompt`, `SharedInterests`; Match = `?screen=match` → `Match` + `MatchCelebration`,
`OrganicPortrait`, `IllustrationSlot match-hands-heart`; Profile = `?screen=profile` → own
profile, `MyProfile`; Interests = `?screen=interests` → `InterestsPrompts` + `ChipGroup`.

Rubric: the user's seven criteria, 1–5 (hierarchy, composition, typography, craft,
distinctiveness, restraint, usability), the same as the Apple experiment, instead of the skill's
13-dimension 0–4 instrument. The skill's hard gates and its keep rule are applied: **keep** only if
no criterion regresses and at least two pre-selected criteria rise one level; otherwise refine,
revert, or retain B.

## Pre-registered diagnosis of the Apple-refined screens (B)

Written before any combined change. At most three weaknesses per screen.

### Welcome

What B already fixed: brand present (wordmark), sheet removed, one left axis for headline/lede,
editorial headline. Keep all of it.

| Evidence / location | Problem | Consequence | Correction | Success signal |
| --- | --- | --- | --- | --- |
| B 393, lower half | Legal footnote is centred while wordmark, headline and lede share a left edge | Two alignment axes in a five-element composition; the footnote reads as a leftover from the old centred sheet | Left-align the legal text on the shared edge | Every text block starts on one edge at 393 and 375 |
| B 393, top 55 % | Empty reserved hero (product decision, asset missing) | The screen's largest region says nothing | None possible without the artwork; do not fill | — (constraint) |

Pre-selected criteria: composition, craft. Expected: small; likely retain B if no level change.

### Discover

What B fixed: prompt answer is the voice (Fraunces), section titles are labels, larger name.

| Evidence / location | Problem | Consequence | Correction | Success signal |
| --- | --- | --- | --- | --- |
| B 393, card overlay | The first screen shows name, job and badges but no conversation cue; the real shared interests ("You both like") sit after the second photo, ~1000 px down | The product's promise (profiles built around conversation) is invisible at first glance; the card could be any dating app | One subordinate line on the card from existing `person.shared`: "You both like Jazz, Natural wine" | Name stays the first read; the cue is readable as the third line without crowding SuperSwipe at 375 |
| B details, chips | Fact chips carry icons, shared pills don't | Minor grammar difference | Leave (both are established components) | — |

Pre-selected criteria: distinctiveness, usability.

### Match

What B fixed: display title, calmer halo, name emphasis, fits 375 × 667.

| Evidence / location | Problem | Consequence | Correction | Success signal |
| --- | --- | --- | --- | --- |
| B 393, under the heart | ~230 px of empty band between the fallback heart and the composer | The moment trails off; the composer placeholder ("Ask about the record shop…") has nothing visible to connect to | Show what the two people actually share (existing `shared`) as quiet pills under the copy, "You both like" | The empty band shrinks with real content; still fits 375 × 667 with the heart visible |
| B 393, portrait | Yellow monogram fallback inside lavender halo | Two pastels; constrained by the missing photo | Leave (per-person avatar tone is consistent app-wide) | — |

Pre-selected criteria: composition, distinctiveness.

### Profile

What B fixed: centred identity with facts and interests, one section-label style.

| Evidence / location | Problem | Consequence | Correction | Success signal |
| --- | --- | --- | --- | --- |
| B 393, avatar + card | Two identical "73" rings within 300 px | Repetition reads as a mistake; the card looks like a second avatar | Keep the avatar ring + badge (spec B-23) and a meter in the card (e2e), but draw the card's meter as a bar: "73 of 100" + bar + next step | One ring on screen; card reads as an action, still contains "73" and one `role=meter` |

Pre-selected criteria: restraint, craft.

### Interests

What B fixed: labelled sets, locked chips keep their outline.

Inspection of B at 393 / 375 / max state found no weakness with a defensible one-level gain:
the count appears in the header and footer, but they serve different places (selection vs. the
next button); set rows wrap unevenly, but that is the natural cost of real labels; selected purple is
a product decision. **Plan: retain B (no change).**

---

# Results

Gallery: [`index.html`](index.html) (every triptych, with links to each full-size capture).
Triptychs: `triptychs/<screen>-393x852.png` (primary), `triptychs/<screen>-375x667.png` (small
phone), `triptychs/onboarding-1440x900.png` (desktop). Full-size images: `A_original/`,
`B_apple_design/`, `C_apple_plus_visual_craft/`. Rejected attempt: `rejected/`. Shared-consumer
captures (B vs C): `regression/B`, `regression/C`, showcase crops `regression/showcase-B-vs-C-*.png` (left B, right C). Contrast figures: `node scripts/combined-card-contrast.mjs [root]`.

Pixel diff C vs B: Welcome (all three viewports) and Interests (both states, both viewports) are
**identical**; only Discover, Match and Profile changed.

## Scores (reviewer judgements, 1–5)

H hierarchy · C composition · T typography · Cr craft · D distinctiveness · R restraint ·
U usability. A and B carry the Apple experiment's scores, except **Discover B usability, revised
4 → 3**: measured in this experiment, B's white text on the placeholder scrim is 2.84:1 for the
name (large text needs 3:1) and 4.15:1 for the job line (needs 4.5:1). Pre-selected criteria are
marked *.

| Screen | Ver. | H | C | T | Cr | D | R | U | Mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Welcome | A | 3 | 2 | 3 | 3 | 2 | 4 | 4 | 3.0 |
| | B | 4 | 3 | 4 | 4 | 3 | 4 | 4 | 3.7 |
| | C | 4 | 3* | 4 | 4* | 3 | 4 | 4 | 3.7 (= B) |
| Discover | A | 3 | 3 | 3 | 3 | 2 | 4 | 4 | 3.1 |
| | B | 4 | 3 | 4 | 4 | 3 | 4 | 3 | 3.6 |
| | C | 4 | 3 | 4 | 4 | **4*** | 4 | **4*** | 3.9 |
| Match | A | 3 | 2 | 3 | 3 | 3 | 3 | 4 | 3.0 |
| | B | 4 | 3 | 4 | 3 | 3 | 3 | 4 | 3.4 |
| | C | 4 | **4*** | 4 | 3 | **4*** | 3 | 4 | 3.7 |
| Profile | A | 2 | 2 | 3 | 3 | 2 | 3 | 3 | 2.6 |
| | B | 4 | 4 | 4 | 4 | 3 | 3 | 4 | 3.7 |
| | C | 4 | 4 | 4 | 4* | 3 | **4*** | 4 | 3.9 |
| Interests | A | 3 | 3 | 3 | 2 | 2 | 3 | 3 | 2.7 |
| | B | 3 | 4 | 3 | 4 | 3 | 3 | 4 | 3.4 |
| | C | 3 | 4 | 3 | 4 | 3 | 3 | 4 | 3.4 (= B) |

No criterion regressed on any screen.

## Screen by screen

**Welcome — retain B.** A: empty lavender top, no brand, copy on a modal-looking sheet. B: wordmark,
no sheet, editorial left-aligned headline. Visual Craft tried one change (legal text onto the shared
left edge). It aligned correctly but only moved the mismatch: "I have an account" became the single
centred element. No criterion rose, so it was reverted (`rejected/welcome-rejected-legal-left-393.png`).
Constraint: the reserved hero is still empty until the artwork exists.

**Discover — keep.** A: inverted prompt hierarchy, muddy scrim. B: answer in Fraunces, label-style
section titles, 40px name. C adds a third line on the card from existing `person.shared`, "You both
like Jazz and Natural wine" (regular weight, label size, below the job line), and darkens the scrim's
middle stops. Measured white-text contrast on the placeholder in C: name 4.21 / 3.73:1 (large text,
≥ 3:1), job 5.01 / 4.80:1, cue 5.55 / 5.29:1 at 393 / 375; B was 2.84 and 4.15:1. Improvement over
B: the first screen now shows why to talk to this person, and the text passes AA. Not improved:
the card is still a placeholder; the scrim is darker on real photos too (tradeoff: more ink at the
bottom 40 % of every photo). Constraint: no photography.

**Match — keep.** A: small title, heart floating in a void. B: display title, calmer halo, name in
ink, fits 375. C adds "You both like" + two grey pills (existing `shared`, same pill style as the
profile section) between the copy and the illustration slot, and a short-phone rule (≤ 700 px tall)
that shrinks the portrait to 25svh so everything stays above the composer. Improvement over B: the
empty band below the heart is now real, specific content that the composer's "Ask about the record
shop…" builds on. Not improved: the monogram and pastel fallback; on short phones the portrait is
smaller (≈ 167px vs 213px). Constraint: no photo, no hands artwork.

**Profile — refine (provisionally keep).** A: score shown twice, settings-page feel. B: centred
identity, facts, interests. C draws the card's meter as a bar (`ReadinessMeter shape="bar"`, still
`role="meter"`) with "73 of 100" beside the title, so only the avatar (spec B-23) draws a ring. One
pre-selected criterion rose (restraint); craft stayed 4, so the pre-registered keep rule is not met.
No regression, e2e still pass. Recommend keeping it pending an owner look.

**Interests — retain B.** No weakness with a defensible one-level gain was found (see diagnosis);
nothing was changed.

## Critical evaluation

1. **Did Visual Craft add value beyond Apple Design?** Yes, modestly: on three of five screens
   (Discover +0.3, Match +0.3, Profile +0.2 mean); none on Welcome and Interests.
2. **Visual reasoning vs motion:** all changes are static. Two came straight from Visual Craft's
   principles (conversation cue in the core surface, §§6, 10; "make the two people and a real shared
   interest central", case study 3); the contrast fix came from its gate ("verify contrast with actual
   rendered values"), which caught a defect the Apple pass had missed. No motion was touched.
3. **Coherence:** coherent. Both additions reuse existing data and components (`shared`, the grey
   shared-interest pill, Inter label roles); the Discover cue and the Match pills tell the same story
   ("You both like") on consecutive screens. No conflicting choices found.
4. **Benefited most:** Discover (a real gate failure fixed plus a new, useful line).
5. **Least:** Welcome and Interests (no change survived).
6. **Unnecessary / counterproductive:** the Welcome legal realignment (reverted). The darker scrim is
   a deliberate tradeoff, not free.
7. **Apply more widely?** The methodology yes, especially its pre-registered success signals,
   measured contrast and "retain if no gain" rule; it made this pass more disciplined than the Apple
   pass. Its marginal visual gain here is small because the largest remaining weaknesses are missing
   assets (photos, hero and match artwork), which no method can fix.

## Files and shared components changed (C vs B)

- `src/design-system/components/Content.jsx` — `ProfileCard` gets an optional `cue` line.
- `src/design-system/components/Patterns.jsx` — `MatchCelebration` gets an optional `shared` list.
- `src/design-system/components/Insights.jsx` — `ReadinessMeter shape="bar"` (ring is the default).
- `src/design-system/styles/content.css` — `.profile-card__cue`, darker scrim stops,
  `.match__shared*`, short-phone match rule.
- `src/flows/screens.jsx` — Discover passes `cue`; Match passes `shared`; Profile card uses the bar.
- `src/flows/flows.css` — readiness card header and bar; removed the unused card-ring rule.
- Consumers checked: Likes profile and Edit preview (scrim only, now darker, no cue), Insights
  (identical), design-system showcase (scrim on its card examples; other diffs are spinner frames).

## Verification

`npm run check` (tokens, icons, 117/117 unit tests, production build), `npm run test:e2e`
(144/144 smoke, 88/88 product) and `npm run test:a11y` (no serious or critical violations) all pass.
Every capture loaded Fraunces and Inter, with no console errors and no horizontal overflow. The
repo has no separate lint or type-check script. Not tested: real photographs (none exist), 320px
reflow, browser text enlargement, screen readers beyond axe.

# Controlled five-screen Numaya experiment

**Status:** Prepared, not executed. No Numaya repository, route, running application, baseline screenshot, or implementation was inspected in this conversation. Category names below are user-requested categories, not invented routes.

**Question:** Does applying this skill improve the static visual quality of existing Numaya screens while preserving identity, functionality, and shared-component consistency?

## 1. Isolate and map

Read repository guidance and inspect git status. Create a separate experiment branch, for example `design/numaya-visual-craft-pilot`, from the agreed base commit. If the working tree contains user changes, preserve them and create an isolated worktree if appropriate. Do not merge, push, deploy, or overwrite the user's work.

Map each category to the actual navigation path, route if present, component, required state, data fixture, and shared primitives. Mark missing categories unavailable; do not invent a route or implement a new screen to fill the test.

| Requested category | Actual route/navigation | Component | Fixture/state | Shared components | Available? |
| --- | --- | --- | --- | --- | --- |
| Onboarding / Get Started | Discover | Discover | Discover | Discover | Unverified |
| Discovery / Profile Card | Discover | Discover | Discover | Discover | Unverified |
| Match Celebration | Discover | Discover | Real mutual-match fixture | Discover | Unverified |
| Profile | Clarify own versus viewed profile from actual app | Discover | Discover | Discover | Unverified |
| Interests / Interest Selection | Discover | Discover | Existing selection rules | Discover | Unverified |

## 2. Freeze the comparison conditions

For a web implementation, proposed capture viewports are **390×844**, **320×740**, and **768×1024 CSS pixels**, with the same recorded DPR for each pair. These are experimental conditions, not assumptions about supported devices. Inspect repository/platform requirements and replace them before baseline capture if necessary. Test wider layouts only if the app supports them. For native UI use supported simulator/device dimensions, record logical/physical units, and hold OS text size and safe areas constant.

Use deterministic, privacy-safe fixtures with the same text, people, photographs, selection states, and scroll offsets in both conditions. Include a typical record, a long-name/long-prompt record, and missing-image or empty-data states where applicable. Preserve authentication and eligibility behavior in the test environment.

Wait for actual fonts and images. Use reduced motion or deterministic settled states in both versions. Capture normal viewport images; add full-page or scroll-position captures for long screens. Record the base commit, app command, route/state entry procedure, browser/platform, viewport, DPR, theme, font loading, fixture IDs, and timestamps.

Suggested experiment evidence folder, only after checking repository conventions:
`design-reviews/numaya-visual-craft/<run-id>/`
with `baseline/`, `revised/`, and `review.md`. Use category labels for filenames only; these do not imply routes.

## 3. Baseline and pre-register success signals

Use the 13-dimension [review rubric](../references/visual-review-checklist.md). Score each baseline before editing. For each screen record three concrete weaknesses maximum and select the two dimensions expected to improve most. Set observable success signals in advance.

A correct observation names an actual location and visible relationship. “Too generic” is insufficient. For example, a finding might be that five repeated labels compete with the person's name—but only record it if present.

## 4. Screen-specific inspection and meaningful improvements

| Screen | Inspect the existing implementation | Meaningful improvement to test, if the problem exists | Guard against |
| --- | --- | --- | --- |
| Onboarding / Get Started | Relationship of brand, headline, image/illustration, value statement, CTA and secondary action; heading wraps; permissions; safe areas; first actionable state | A clearer first/second/action reading order; better Fraunces/Inter roles; coherent illustration weight; less irrelevant visual competition; obvious next action at narrow width | Removing needed eligibility/consent or matching information; inventing claims; art pushing the action out of reach |
| Discovery / Profile Card | Portrait crop and aspect behavior; name/metadata hierarchy; prompt/interests; controls and hit areas; card edge/padding; navigation; overlays on bright/dark photos | More recognizable person-first composition; conversation cues easier to scan; legible text over varied photos; balanced controls and less redundant chrome | Hiding identity/context to enlarge photos; obscuring faces; inventing compatibility metrics; changing recommendation or swipe logic |
| Match Celebration | Whether the event is unmistakably a mutual match; balance between both people; typography; shared-interest cue if real; message/continue hierarchy; dismissibility | A distinctive static composition where the two people and next conversation action dominate; consistent accent and type; celebration that reads without animation | Unsupported mutual-interest claims; confetti as the only improvement; delaying chat behind a reveal; pressure or fake urgency |
| Profile | Own/viewed profile scope; photo/header relationship; name and bio/prompt hierarchy; section rhythm; interest distribution; navigation/edit/contact controls actually present | Better scanning from identity to interests and prompts; deliberate section grouping; consistent controls; readable long content and coherent images | Adding/removing fields or actions; making every section a card; tiny text; drifting from discovery representation |
| Interests / Interest Selection | Chip/row/grid behavior; selected versus unselected; category groupings; counts/limits if present; wrapping; tap targets; CTA availability; save/validation behavior | Clear selection states beyond color; stable component dimensions; more coherent spacing/density; understandable progress toward existing rules; usable narrow layout | Huge chips that increase effort; color-only feedback; inventing minimums/maximums; hiding selections or resetting them |

These are hypotheses, not diagnoses of the unseen app. Preserve route and data contracts. Any new feature or change to the core product model belongs in a separate proposal.

## 5. Revise one screen, then apply coherently

Run the skill against the mapped screen and its baseline. Prioritize composition, hierarchy, typography, then rhythm/proportion, then restrained component details. Identify shared consumers before edits.

Start with one mapped screen that exposes the most reusable primitives, chosen after inspection. Inspect its result before carrying the same decisions across the remaining screens. Do not duplicate a local variant five times or change global tokens without checking consumers. Keep dependencies and product behavior stable.

No new motion implementation in this pilot. A visually weak still frame cannot pass through animation.

## 6. Capture equivalent results and check regressions

Use identical capture metadata and fixtures. Compare every screen at the primary viewport and both secondary conditions. Include the same error/empty/selected states when they exist.

Check the union of shared-component consumers touched by changes, plus adjacent navigation screens. Record which consumers were inspected and which were not; do not claim a whole-app audit from five screenshots. Exercise the actual task: enter/continue onboarding, inspect discovery, open/dismiss the match, navigate profile, and select/save interests, as applicable.

Run repository-required checks and relevant behavior tests. Verify contrast, targets, focus, semantics, text enlargement, crop behavior, overflow, and data persistence with tools appropriate to the platform.

## 7. Decide using the fixed rubric

Use the exact 0–4 anchors and hard gates from the checklist. Proposed pilot keep threshold: no dimension regresses, at least two preselected weak dimensions gain one level, all gates pass, and improvement holds in secondary captures. Mark untested outcomes unverified.

Evaluate every screen independently. Do not average a failed screen into an overall positive result. When shared-token changes improve one screen but hurt another, refine the shared rule or use a justified semantic variant before accepting either.

If possible, obtain an owner or independent reviewer A/B comparison with varied order. Record the reviewer's rationale and disagreement. Self-scoring is not a user study and cannot establish better retention, conversion, or perceived value.

| Category / actual route | Baseline evidence | Revised evidence | Two preselected dimensions | Score changes | Gate/regression result | Verdict / reason |
| --- | --- | --- | --- | --- | --- | --- |
| Onboarding | Not captured | Not captured | Choose after inspection | Not measured | Not run | Pending |
| Discovery | Not captured | Not captured | Choose after inspection | Not measured | Not run | Pending |
| Match | Not captured | Not captured | Choose after inspection | Not measured | Not run | Pending |
| Profile | Not captured | Not captured | Choose after inspection | Not measured | Not run | Pending |
| Interests | Not captured | Not captured | Choose after inspection | Not measured | Not run | Pending |

## 8. Close the experiment

Record per-change and per-screen keep/refine/revert decisions, actual evidence paths, commits/diffs, failed hypotheses, limitations, and next steps. A keep recommendation is a review outcome, not authorization to merge or push.

If the results are ambiguous, refine the smallest uncertain relationship and re-capture. If blocked on runtime or screenshot access, preserve the isolated work and report exactly what remains unverified.

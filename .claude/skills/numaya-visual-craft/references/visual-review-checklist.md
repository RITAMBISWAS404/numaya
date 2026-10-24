# Visual review checklist and scoring rubric

This is a researcher-designed evaluation instrument for the Numaya pilot. It is not Tim Gabe's exact scorecard, a usability study, or a validated measure of perceived premium quality.

## Record evidence before scoring

Record route/component, git revision, viewport in CSS pixels, device pixel ratio, browser/platform, text scale, theme, scroll position, fixture ID, loading state, and screenshot paths. Keep these equal between baseline and revision. Include normal viewport shots and full-page views where content scrolls.

Wait for real fonts and images. Remove animation from both comparison conditions. Never compare a baseline fallback font or empty image with a fully loaded revision. Do not use device mockup frames, altered copy, better photography, or different sample people to make one version look better.

For every finding write: **location → observation → consequence → correction → evidence of outcome**.
Example: “At the profile header, name and secondary facts use nearly equal emphasis, slowing the reading order; revise the existing name role and reduce metadata emphasis, then compare the same long-name fixture.” This is a hypothetical diagnosis template, not a finding about the unseen app.

## Inspection checklist

| Dimension | Questions requiring specific observations |
| --- | --- |
| Composition | What is the first focus? Where do major edges align? Is image/text/action balance intentional? |
| Hierarchy | Can title, supporting information, and primary action be distinguished? Which element competes unnecessarily? |
| Typography | Are Fraunces/Inter loaded and used by role? Which line wraps, clips, or becomes too faint? |
| Spacing | Are internal and section gaps meaningfully different? Which repeated edge or gap is inconsistent? |
| Color | Where is purple used and why? Are selected, disabled, error, and focus states understandable? |
| Component craft | Which button, chip, card, field, or navigation item has unstable proportions, alignment, or states? |
| Surfaces/depth | Does each border, shadow, radius, and gradient clarify structure or obscure it? |
| Images | Are faces/crops preserved? Do bright/dark/missing images work? Is image resolution sufficient? |
| Distinctiveness | Which concrete decision expresses Numaya beyond replacing a logo? Is it serving content? |
| Consistency | Do equivalent roles match adjacent screens and shared primitives? Are exceptions justified? |
| Responsiveness | At narrow width, long content, and enlarged text, what overlaps, hides, or requires horizontal scrolling? |
| Accessibility | What are measured text contrast, focus visibility, target dimensions, semantics, and keyboard outcomes? |
| Usability | Can the existing primary task be completed? Do back, selection, submit, and recovery preserve behavior? |

## Scoring: fixed rubric, equal conditions

Score each of the 13 dimensions above from 0–4 for both versions. Keep the same reviewer and criteria; score baseline before coding. Never invent precision from a weighted “premium score.”

- **0 — Broken:** Lost content, unreadability, unusable action, or serious visual incoherence.
- **1 — Weak:** Several concrete defects interfere with the intended hierarchy or use.
- **2 — Adequate:** Works, but visible inconsistency or an unresolved important weakness remains.
- **3 — Strong:** Deliberate and coherent; no major observed issue under the tested conditions.
- **4 — Exceptional:** Strong plus distinctive, context-appropriate craft that improves the core experience; cite the exact evidence. Mere decoration does not qualify.

Use **N/A** with a reason when a dimension truly does not apply, and **unverified** if the check was not performed. Never convert unverified to a passing number. Maximum 52 points only when all dimensions are applicable and verified; otherwise report applicable denominator and leave the total incomplete if any required dimension is unverified.

| Dimension | Baseline 0–4 | Revised 0–4 | Change | Specific baseline/revised evidence | Confidence |
| --- | --- | --- | --- | --- | --- |
| Copy all 13 rows for each screen | | | | | |

Scores are ordinal reviewer judgments. A total is a directional summary, not a statistically meaningful interval scale. Do not call a 4-point gain “X% more premium.” Compare each criterion and each screen rather than averaging away a regression.

## Pass/fail gates independent of scores

- Preserve actual task behavior, truthful data, consent, navigation, and available recovery.
- Check text contrast: normally at least 4.5:1; large text at least 3:1 under the WCAG definition. Do not classify all headings as large text.
- For web UI, check pointer targets against WCAG 2.2's 24×24 CSS-pixel minimum or its documented exceptions. Prefer around 44×44 for prominent touch controls as a local usability target, not a claim about AA's minimum.
- Check 320 CSS-pixel reflow for applicable web content, text enlargement, keyboard navigation, and visible focus. For native applications, use actual supported devices and platform accessibility equivalents; do not equate CSS pixels with native units.
- Verify labels/roles/selection announcements, reading order, and error descriptions using suitable tools. Screenshots alone cannot pass these checks.
- No new clipping, hidden action, image distortion, unintended horizontal scroll, or broken shared component in tested layouts.

Primary references: [text contrast](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [target size and exceptions](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html), [reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html).

## Compare without self-praise

1. Inspect normal-size baseline/revised images side by side. Make the same content comparison at every declared viewport.
2. Mark whether each planned success signal was met, partly met, missed, or unverified.
3. Revisit the three primary weaknesses. Did they improve, or did a change only make another area more decorative?
4. Check unaffected consumers of shared primitives and at least the neighboring routes actually affected.
5. If possible, ask the product owner or another reviewer to compare anonymized A/B images with order varied. Ask which version communicates focus, identity, and action better, and why. Record disagreement; do not imply this occurred if it did not.
6. Separate visual verdict, accessibility/interaction results, and product hypotheses. No retention or conversion claim follows from a screenshot.

## Decision rule (pilot policy, S)

**Keep:** All hard gates pass; none of the 13 dimensions worsens; at least two preselected weak dimensions improve by at least one anchored level in the primary viewport; improvements survive the secondary viewports. Justify each change visually.

**Refine:** Direction is promising but a gate fails, a dimension regresses, an important success signal is missed, or the preference is ambiguous. Re-render after the fix.

**Revert:** A change repeatedly fails its hypothesis, damages Numaya's coherence or core task, or makes the original weaknesses worse. Revert the unsuccessful change without removing unrelated improvements.

If implementation or screenshot tools are blocked, mark **unverified / not ready to keep**. Never award a keep decision solely from code inspection. This threshold is deliberately conservative and can be revised by the product owner before the test, not after seeing results.

## Required final review record

- Mapping and reproducible capture setup.
- Top three observed weaknesses and planned success signals.
- Changed components/tokens, decision rationales, and tradeoffs.
- Baseline/revised screenshot links and completed rubric.
- Interaction, accessibility, responsive, and shared-consumer check results.
- Change-level and screen-level keep/refine/revert decisions.
- Reviewer identity, confidence, disagreement, blockers, and next action.

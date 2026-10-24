---
name: numaya-visual-craft
description: Improve Numaya's existing screens through repository inspection, deliberate visual direction, reusable components, and screenshot-based iteration. Use for visual redesigns, UI polish, design critiques, onboarding, discovery, match, profile, or interest-selection work.
---

# Numaya visual craft

Improve the actual product, and prove the improvement in rendered screens. Use this skill for visual design work; do not treat it as permission to change product strategy or invent features.

## Read selectively

1. Read [visual principles](references/visual-principles.md) and [review checklist](references/visual-review-checklist.md) before diagnosing.
2. Consult [case studies](references/visual-case-studies.md) when choosing a direction or resolving a tradeoff.
3. Consult [source index](references/video-source-index.md) only when attribution matters. Implementation must work without YouTube.
4. Use [five-screen experiment](research/five-screen-experiment-plan.md) for the controlled pilot.
5. Read [research report](research/research-report.md) for evidence limits, not as implementation instructions.

Treat Tim Gabe's verified explanations, directly observed frames, and this skill's Numaya adaptations as different evidence classes. Never attribute the proposed type scale, spacing choices, review scores, or accessibility thresholds to him.

## 1. Establish ground truth

- Read repository instructions, package manifests, app entry points, navigation/router definitions, styling configuration, design tokens, component library, fonts, icons, and asset directories.
- Inspect git status before edits. Preserve user changes. For the five-screen pilot, use a separate branch such as `design/numaya-visual-craft-pilot`; never merge or push without authorization. If a clean isolated checkout is necessary, preserve the original worktree.
- Map the requested screen category to its real route, component, state, and data source. Do not infer routes from category names. Distinguish own-profile from another person's profile.
- Start the application using its documented commands. Inspect the running screen, adjacent screens, and existing screenshots. Verify that Fraunces and Inter actually load rather than judging fallback fonts.
- Record actual viewport, pixel ratio, content fixture, scroll position, theme, browser/platform, and interaction state. Capture baseline viewport screenshots and full-page views when scrolling matters.
- If the application cannot run or screenshots cannot be inspected, continue with a clearly marked code audit and setup work. Report the blocker; never declare visual validation or an improved result.

## 2. Lock Numaya's identity

Preserve white/neutral surfaces, deliberate purple/lavender accents, Fraunces for prominent headings and names, and Inter for reading and controls. Keep the experience refined, expressive, contemporary, approachable, and centered on connection.

Discover exact colors, font axes/weights, radii, spacing, and shadows in the repository; do not invent a second system. Use a consistent functional icon family. Never substitute emojis for controls. Preserve existing brand assets and approved illustration direction. Do not derive a new illustration style from these videos.

Write one short art-direction sentence appropriate to the existing screen, plus three observable constraints. Example proposal: “An airy editorial introduction to a person, grounded in shared interests.” Translate that into a clear name hierarchy, a deliberate portrait crop, and one visible conversation cue using existing data. Validate the proposal against the current product; it is not a universal layout mandate.

## 3. Diagnose before decorating

Make an observation table:

| Evidence / location | Concrete problem | User or visual consequence | Proposed correction | Success signal |
| --- | --- | --- | --- | --- |
| Screenshot + component | Specific competing sizes, gap, crop, state, or alignment | What becomes harder to scan, read, trust, or use | Minimal justified change | What the revised screenshot or interaction must show |

Identify at most three primary weaknesses per screen. Distinguish structural problems (hierarchy, order, proportion, density) from detail problems (stroke, border, optical alignment). Fix structure first. Do not use “cleaner,” “premium,” or “modern” as a diagnosis.

Inspect happy, selected, loading, empty, error, and long-content states that actually exist. Do not claim missing states exist or fabricate success feedback. Assess visual quality separately from the usefulness of the underlying flow.

## 4. Choose references with a job

Use up to three references: one for composition, one for component craft, optionally one for an emotional moment. Prefer existing Numaya screens as consistency references. For every external reference record the problem it helps solve, the abstract principle to borrow, and the distinctive branding/artwork/interaction to leave behind.

Choose one compatible direction. Do not combine entire design systems, copy a dating competitor, adopt Apple's conventions wholesale, or paste unrelated screenshots into an instruction pile. If external images are unavailable, use the bundled verbal cases and actual Numaya evidence; never invent a viewed reference.

## 5. Plan the smallest coherent change

For each major decision state: observation → change → expected benefit → tradeoff → validation. Identify shared-component consumers before modifying a shared token or primitive.

Prefer existing component variants and semantic tokens. Consolidate accidental one-off values only within the authorized scope. Add a new variant only if existing variants cannot express the required role; name it by function. Do not rebuild the whole design system to polish five screens.

Specify information order, type roles, grouping, image treatment, accent roles, and component states before coding. Start with composition and typography, then spacing and proportion, then surfaces and details. Do not equate quality with blur, gradients, glass, shadows, huge radii, or artwork volume.

## 6. Implement and inspect

- Implement the plan in the real components, keeping interactions and data contracts intact.
- Render with the same fixtures and viewports as the baseline. Wait for fonts and images, settle transitions, and disable incidental motion in both versions.
- Inspect the screenshots yourself at normal size. Use overlays or side-by-side views for alignment and proportion; a pixel difference alone cannot establish quality.
- Check actual contrast, target sizes, keyboard focus, screen-reader semantics, long text, missing photos, and responsive overflow. A screenshot does not prove accessibility or usability.
- Recheck neighboring screens affected by shared changes. Run repository-required checks and relevant interaction tests.
- Apply the rubric. If a change fails its success signal, refine it or revert that change. Re-capture after meaningful revisions. Do not repeat unproductive iterations; if evidence remains ambiguous, label the result provisional and request a focused human comparison.
- Complete static evaluation before suggesting motion. Never add motion in the first pilot. Any later motion must clarify state or support a meaningful moment, respect reduced motion, and retain a usable static equivalent.

## 7. Finish with evidence

Provide the actual route/component map, three primary observations, major decisions and tradeoffs, affected tokens/components, before/after screenshot paths, per-criterion scores, functional checks, shared-screen regression results, and a keep/refine/revert decision. Include unresolved issues and unverified claims.

Do not report “measurably better” from self-assessment alone. Explain the visible changes and label scores as reviewer judgments. If no screenshot comparison exists, mark visual outcome **unverified**.

## Final gate

- [ ] Numaya's font, surface, color, icon, and asset identity remains coherent.
- [ ] One primary focus and action are clear without hiding essential information.
- [ ] Spacing, type roles, crops, and component proportions have explicit reasons.
- [ ] Every new effect serves a stated purpose.
- [ ] Equivalent baseline and revised screenshots were inspected.
- [ ] Small-screen, long-content, state, accessibility, and shared-component checks passed.
- [ ] Each major change earned a keep/refine/revert decision.
- [ ] No merge or push occurred without authorization.

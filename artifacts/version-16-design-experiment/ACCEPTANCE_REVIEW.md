# V16 acceptance review

| Criterion | Verdict | Evidence |
|---|---|---|
| Fidelity to the Mobbin reference | **Pass**, with noted limits | `screenshots/comparison-reference-v16.png`: eight reference / V16 pairs. Settings, Basics, the sheets, Profile and Edit profile reproduce the reference's page and card relationship, capital headers, grouped rows, field anatomy, the Share / Done pair, the segmented control and navy avatars. **Limits:** the reference was seen as 299 px previews, not full resolution, and its app-version id could not be confirmed. |
| Colour and typography | **Pass** | Every colour was sampled from the reference ([REFERENCE_ANALYSIS.md](research/REFERENCE_ANALYSIS.md)); only `muted` and `control` were deepened, for contrast. The e2e suite asserts the canvas, card, ink, blue, tint, green and red values. **Type:** Hanken Grotesk (chosen against four other OFL faces), with the reference's two registers: bold page titles and tracked capital headers. **Needs work:** the exact Withings face is unknown, and the substitute's bold is slightly narrower. |
| Buttons, cards, controls, icons and surfaces | **Pass** | One rule per component ([COMPONENT_RULES.md](design-system/COMPONENT_RULES.md)); the rules marked ✓ there are asserted by the e2e suite. No V11 purple on any V16 screen (scanned). Icons are V11's Material Symbols Rounded, filled when active, as the reference's glyph icons are. |
| Spacing, padding, radii and proportions | **Pass** | Radii (6 / 8 / 12 / 14 / 16) and heights (button 50, field 54, row 56, header button 40) come from pixel measurements ([TOKENS.md](design-system/TOKENS.md)). The ±1.3 pt preview resolution is noted. |
| Consistency across screens | **Pass** | `screenshots/contact-sheet.png` (24 states). Two passes fixed the inconsistencies found: label styles, cancel buttons, card titles. |
| Numaya identity and dating function | **Pass** | Numaya's name, wordmark, mark shape, copy and every interaction are kept; no Withings branding. The e2e suite exercises navigation (keeps `?theme`), switches and sliders. V11's own suites pass: product 88/88, experiment 111/111. |
| Existing UX and justified changes | **Pass** | No layout moved. Five presentation changes, each with evidence and reasoning ([V11_LAYOUT_AND_UX_BASELINE.md](design-system/V11_LAYOUT_AND_UX_BASELINE.md)) and visible in `screenshots/comparisons/`. |
| Accessibility and responsive behaviour | **Pass** | axe: 0 serious or critical on 15 screens. Contrast scan: 0 text below 4.5:1. No overflow and no console errors at 393 and 375. 44 pt targets kept. Focus rings visible. |
| Technical correctness and isolation | **Pass** | `npm run check` passes. E2E: smoke 143/144 (the one failure is environmental and identical on V11), product 88/88, V11 experiment 111/111, V16 40/40. **Default mode:** 162/162 states pixel-identical to the untouched V11 commit. **V11 (`?theme=tiimo`):** 49/49 identical before and after V16. No other branch was touched. |

## Overall

V16 is a convincing continuation of the Withings Health Mate system, not a recolour of V11: the surface model,
action colour, type registers, control anatomy and list grouping all changed to the reference's. It keeps V11's
structure and behaviour exactly.

**What would most improve it:**
1. Real profile photography. Placeholder-heavy screens such as Discover and Likes undersell any visual system.
2. Licensing or confirming the reference's typeface.
3. A pass with full-resolution reference images, to tighten the ±1.3 pt measurements.

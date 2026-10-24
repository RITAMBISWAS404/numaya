# Visual principles for Numaya

## Evidence key and contents

**D** = Tim Gabe directly explains it in verified English auto-captions. **V** = selected playback frames were directly inspected; observations are limited to visible evidence. **S** = researcher synthesis/adaptation, not a Tim Gabe rule. **B** = brand constraint supplied by the user. Source IDs resolve in [video-source-index.md](video-source-index.md).

Sections: perceived quality; composition; typography; spacing; color; components; depth; photography; illustration; emotional design; consistency; unfinished patterns; critique workflow.

## 1. Perceived quality: coherent intent plus dependable execution

**Grounding:** D: TG01 0:52–1:18 and 7:06–10:45; TG03 1:37–4:08 and 4:09–6:43. S: the operational test below.

**Meaning / why:** A recognizable point of view, a coherent system, and thoughtful execution reinforce one another. A tidy happy-path screen is insufficient if the surrounding states contradict it. Tim's scoring example is an illustrative critique, not a controlled measurement of design quality.

**Recognize:** The screen could belong to any app after replacing the logo; a polished button leads to an unexplained blank state; one route uses different navigation or type roles from its neighbors.

**Improve:** State the intended experience in one sentence. Translate it into three visible decisions and one behavioral requirement. For a profile: give the person a strong name/photo relationship, make real shared interests easy to find, and preserve a clear next action. Design loading and recovery with the same care.

**Do not apply mechanically:** Do not invent unique interactions to avoid familiarity. Familiar controls can be the best execution. Do not claim a serif or minimal palette makes users trust the service.

## 2. Layout, composition, hierarchy: decide what should be noticed

**Grounding:** D: TG01 4:04–4:17, 10:05–10:45; TG02 6:35–6:59. S: specific hierarchy and layout method.

**Meaning / why:** Contrast in size, position, density, and grouping should reflect the screen's purpose. Everything cannot be primary.

**Recognize:** Name, toolbar, chips, and CTA carry equal weight; cards nest without explaining relationships; a hero occupies most of the screen while the user cannot identify the action.

**Improve:** List the first, second, and third things the user should notice. Compare that order with the screenshot. Remove competing emphasis, regroup related facts, and establish a shared alignment edge. Use negative space to separate meaningful groups, not to fill a fashionable quota.

**Numaya:** In discovery, test whether the portrait, name, and conversation-relevant information form a useful reading sequence. Do not assume the portrait must always dominate.

**When not:** Dense interest selection may benefit from compact repeated rows/chips. Airier layouts must not bury controls or force unnecessary scrolling. A sparse screen can still be poorly composed.

## 3. Typography: assign roles rather than random sizes

**Grounding:** D: TG01 4:04–4:17, 10:24–10:28; TG02 9:04–9:14; TG05 8:29–8:40. B: Fraunces and Inter. S: implementation rules.

**Meaning / why:** A small, repeatable set of roles makes names, prompts, metadata, and actions distinguishable. Letterforms and wrapping materially affect composition.

**Recognize:** Fraunces appears on tiny controls; many near-identical font sizes compete; bold weight substitutes for hierarchy; fallback fonts alter line breaks; a long name is clipped.

**Improve:** Inspect existing tokens first. Map each element to a role: expressive heading/name, section title, body/prompt, metadata, control. Use Fraunces selectively for prominent roles and Inter for reading/controls. Tune size, weight, line-height, and width together. Test a long name, a two-line CTA, and enlarged text. Preserve meaningful names instead of shrinking them excessively.

**When not:** Do not introduce a new type scale on one screen. Do not use extremely thin type or tight tracking to signal luxury. Avoid an oversized heading if it displaces essential content.

## 4. Spacing and rhythm: make relationships visible

**Grounding:** D: TG01 4:04–4:17 and 5:33–6:11. S: proximity, token, and optical-review procedure.

**Meaning / why:** Related elements should read as groups. Consistent rhythm reduces the impression of accidental assembly.

**Recognize:** A label is farther from its field than from the next section; chip gaps vary; card padding changes between otherwise identical states; bottom controls collide with safe areas.

**Improve:** Measure the existing spacing scale and reuse it. Distinguish intra-component, intra-group, and inter-section spacing. Align repeated edges; then inspect optical alignment of icons, baselines, and asymmetrical artwork. Change container padding before adding child-specific margins everywhere.

**When not:** Uniform spacing everywhere destroys grouping. Do not force every visual relationship to the same number or expand all gaps to make the screen seem expensive.

## 5. Color and contrast: assign an accent a role

**Grounding:** D: TG02 8:19–9:14 defines a restrained brand palette but explicitly says a palette alone is insufficient. V: its palette frame. B: neutral/white with purple/lavender. S: color distribution and semantic checks.

**Meaning / why:** Saturated color directs attention; its distribution should express priority and state.

**Recognize:** Purple covers backgrounds, chips, icons, headings, and every card equally; pale lavender text is difficult to read; selected and unselected states differ only subtly.

**Improve:** Map existing semantic roles: canvas, surface, primary text, secondary text, accent, selected, focus, success/error. Keep neutrals as the base; use purple deliberately for priority and selection. Verify contrast with actual rendered foreground/background values, including image overlays. Distinguish selection through a check/shape/text in addition to color.

**When not:** Do not hard-code a universal 60/30/10 ratio or add a new hex palette. Preserve functional warning/error semantics. Do not copy Undertone's greens into Numaya.

## 6. Component craftsmanship: role, proportion, and state

**Grounding:** D: TG02 9:04–9:14; TG03 5:40–6:31; TG04 5:30–6:15. S: component inspection details.

**Meaning / why:** A component should remain legible, balanced, and recognizable when its content or state changes.

**Recognize:** Icons appear off-center; pill shapes hide awkward padding; button heights differ without reason; fields lose labels after entry; selected chips jump in width; empty cards have a different visual grammar.

**Improve:** Audit primitive, variant, and consumers. Check icon family/stroke, text baseline, label length, padding, hit area, disabled/focus/selected/error states. Prefer layout rules that survive wrapping to fixed pixel heights. Give status components a clear title, useful detail, and real next action.

**Numaya:** Interest chips need stable selection feedback and understandable limits if limits exist. Reuse the same button hierarchy across onboarding and match screens.

**When not:** Do not make every row a card. Do not create a custom control to avoid using an accessible native or established primitive. Never show invented progress or unsupported undo.

## 7. Surfaces, borders, depth, and shadows: explain structure

**Grounding:** S. Selected videos do not establish a precise shadow, blur, border, material, or radius recipe. TG01's warning about incoherent references supports restraint broadly, not any particular effect.

**Meaning / why:** Surface differences should distinguish regions, grouping, elevation, or interaction.

**Recognize:** Nested shadows create dirty edges; every card floats; borders and gradients compete with portraits; huge radii make compact chips or buttons look inflated.

**Improve:** Begin with the existing neutral surface and spacing. Add a border or tonal step only when grouping needs help. Use elevation when actual overlap demands it. Reuse radius/elevation tokens and inspect at normal scale.

**When not:** A simple flat selection list may need no depth. A controlled gradient behind image text can improve legibility, but a full-screen ornamental gradient may weaken Numaya's white/neutral direction. TG01's sunrise gradient belongs to that example's concept, not every premium app.

## 8. Photography and image composition: respect the person

**Grounding:** S/B. No photography-specific rule was verified in this research.

**Meaning / why:** Dating interfaces depend on people being recognizable and information remaining readable across diverse photographs.

**Recognize:** Foreheads are cut off; controls obscure faces; image stretching or compression is visible; the same overlay fails on a bright photograph; placeholders feel like errors.

**Improve:** Inspect available assets and crop metadata. Use consistent aspect-ratio behavior, subject-aware positioning where supported, and deliberate text-safe zones. Test dark, light, close-up, full-body, and missing-photo fixtures. Keep discovery and profile representations recognizably related.

**When not:** Never replace real users' images with generated people, beautify bodies, or invent visual identity. Do not impose one crop that harms different subjects. Photography changes require asset rights and truthful product data.

## 9. Illustration and storytelling: make meaning visible

**Grounding:** D: TG05 1:31–4:14 describes personality in the core surface; TG02 14:48–16:58 frames a meaningful recap reveal. S/B: Numaya adaptation.

**Meaning / why:** An illustration should clarify a state or reinforce the screen's emotional purpose. It cannot repair weak hierarchy.

**Recognize:** Generic hearts/sparkles fill space but add no meaning; several illustration styles coexist; detailed art becomes noise at its actual display size.

**Improve:** Use existing approved Numaya assets. Decide what the image communicates before placing it. Check silhouette, visual weight, palette, and readability at the actual size. Balance it against Fraunces headings and primary actions.

**When not:** Profile and interest screens may need no illustration. Do not import Carrot's sarcasm, Undertone's sleeve, or Soulcard's card art. Never invent a reference-derived style specification from videos that were not about illustration.

## 10. Emotional design and delight: place effort where it matters

**Grounding:** D: TG02 13:25–16:58; TG05 1:31–4:14; TG07 7:21–9:40. S: application to dating.

**Meaning / why:** The core interaction and the person's emotional context should shape presentation. An emotional moment is more than a decorative animation.

**Recognize:** Match celebration feels like a generic success alert; artwork dominates the two people; prompts shame someone for inactivity; errors become jokey when the user needs reassurance.

**Improve:** For a real mutual match, make the two people and a clear conversation next step central. Use warm, specific language backed by actual information. Design the complete static state first. Keep celebration dismissible and actions clear.

**When not:** Do not manufacture scarcity, pressure, compatibility claims, or affection. Do not adopt the social-pressure or loss mechanisms discussed in other videos merely because they may drive return visits. This pilot evaluates visual quality, not engagement optimization.

## 11. Consistency: review the product as a connected experience

**Grounding:** D: TG03 4:09–6:43; TG01 9:21–9:43; TG02 7:27–9:19; TG04 2:54–3:17.

**Meaning / why:** Repeated roles should look and work alike while allowing purposeful differences.

**Recognize:** Profile names change family between routes; primary actions change shape; similar cards have unrelated padding; the match screen introduces a new visual language.

**Improve:** Compare all five screen screenshots together. Map reused roles to shared primitives/tokens. Check the same states, navigation, and image treatments across routes. Document justified exceptions.

**When not:** Consistency does not mean identical composition. A celebration can differ from a dense selector while retaining type, color, and component grammar. Do not change every screen to match a single outlier.

## 12. Patterns that look generic or unfinished

The following is S, supported broadly by TG01's examples rather than a quoted creator checklist.

| Pattern | Diagnosis to verify | Better correction |
| --- | --- | --- |
| Repeated equal-weight cards | Everything competes; grouping lacks meaning | Establish a primary region and subordinate repeated facts |
| A pile of stylistic references | Incompatible type, radius, spacing, or material | Choose one direction and borrow isolated principles |
| Accent everywhere | Color no longer marks importance | Assign accent roles; use neutral foundations |
| Huge empty hero | Action or meaningful content pushed away | Rebalance the content/negative-space relationship |
| Tiny pale metadata | Readability sacrificed for appearance | Restore contrast and adequate type size |
| Artwork as a rescue | Core surface remains generic | Improve composition and content presentation first |
| Happy path only | Missing or inconsistent state handling | Design and test actual loading/empty/error states |
| Perfect short-name mockup | Real content breaks the component | Test long names, wrapping, missing images, and localization |

## 13. Repeatable critique

Write a concrete observation, hypothesize its cause, propose one change, define a success signal, implement, render, compare, and keep/refine/revert. Separate static visual scores from behavioral checks. The linked checklist defines the measurement procedure; it is a local experiment rubric, not a validated industry instrument or Tim Gabe's exact scorecard.

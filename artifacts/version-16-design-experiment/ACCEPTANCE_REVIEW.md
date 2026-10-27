# V16 acceptance review (final)

Scored on the rendered app after the final fidelity audit ([FINAL_FIDELITY_AUDIT.md](FINAL_FIDELITY_AUDIT.md)).
**Evidence:** `screenshots/final-review/`, which holds the contact sheet, three Reference | V11 | V16 sheets, the audit
before/after, and the 375 sheet.

| Dimension | Score | Evidence | What holds it back |
|---|---|---|---|
| Fidelity to the Withings reference | **8 / 10** | `reference-v11-v16-1.png`: Settings, Basics and the sheets match the reference's grouped-settings, radio-list and sheet anatomy almost one to one. In `-2` / `-3`, the Profile, segmented control, empty-state card and people row clearly come from the same system. | Photo-led screens (Discover, Likes, Match) are dominated by grey placeholders and dating-specific elements with no reference equivalent: the photo with the name over it, the scalloped match portrait, bubbles. The reference was only seen as 299 px previews. |
| Typography and colour relationships | **8 / 10** | Every colour sampled, `#F5F4F1` / white / `#121212` / `#5066CC` / `#E4EBFC` (`research/REFERENCE_ANALYSIS.md`). Both type registers are reproduced: bold page titles and tracked capital headers. | Hanken Grotesk is a substitute: its bold is narrower and less round than the reference's. The prompt answer (22 semibold) is heavier than any reference card statement, kept as Numaya's content focus. |
| Component-level fidelity | **8 / 10** | Buttons, fields, radios, checkboxes, switch, segmented control, tabs, sheets, action sheet, toast, badges, avatars and people rows each map to an observed reference component (matrix). The V16 e2e suite (47 checks) asserts them. | Inferred components (search, composer, bubbles, slider) have no reference to match. The radio stays on the right (V11 layout) where the reference puts it on the left. |
| Spacing, padding, geometry and alignment | **8 / 10** | Measured radii (6 / 8 / 12 / 14 / 16) and heights (50 / 54 / 56 / 40). Dividers inset 16 on both sides. Empty-state cards now align to the column. | The measurements carry ±1.3pt uncertainty from preview resolution. Two-line rows come out 64–68pt against the reference's 72. |
| Consistency across screens | **8 / 10** | `contact-sheet-final.png`, 36 states: one surface model, one action hierarchy, one label style. The audit fixed the last inconsistencies: tab-root buttons, sheet dismiss, action-sheet cancel, chips on cards. | The new-match ring is the one state indicator without a reference counterpart. Discover keeps a tighter 8pt gutter than other screens (V11's photo layout). |
| Dating-product usability | **7 / 10** | Every journey works: product e2e 88/88, and the V16 suite exercises navigation, switches, sliders and the error state. Hierarchy is clear: ink primary, outlined secondary. Like back / Pass reads instantly. | The utilitarian health-app character is calm and trustworthy but less warm and expressive than a dating product usually wants. Profiles depend on photography the prototype doesn't have. |
| Accessibility and responsive quality | **9 / 10** | axe: 0 serious or critical on 15 V16 screens. Contrast scan: 0 text below 4.5:1. 44pt targets kept. Focus rings visible. The invalid state is restored. No overflow or clipping at 375 or 393. | Moderate axe notes ("landmark", "region") come from the preview harness and exist in V11 too. Focus styling is inferred, not observed. |
| Technical correctness | **9 / 10** | `npm run check` passes (122 unit tests). E2E: product 88/88, V11 111/111, V16 47/47. The 7 new checks fail on the pre-audit code, so they really test the fixes. Default mode 162/162 and V11 49/49 pixel-identical. | Smoke is 143/144 because of the container's Chromium `corner-shape` default, identical on untouched V11. A test environment that matches the pinned Playwright build would clear it. |

## Remaining discrepancies

1. **The typeface is a substitute.** Hanken Grotesk, not the Withings face.
2. **Photo-dependent screens are unproven.** No real photography exists in the repo.
3. **Inferred components.** Search, composer, bubbles and slider have no reference.
4. **The radio sits on the right** (V11 layout) where the reference puts it on the left.
5. **Two-line row height** is 64–68pt against the reference's 72pt.
6. **Field outline on empty fields.** One reference screen (`42`) suggests a lighter outline for an empty field; with
   only one example, I left it unchanged.
7. **No destructive-sheet variant.** The reference's destructive sheet sets its title in centred capitals (`39`);
   V16 keeps the medium left title from `21` and `42` for every sheet.

## Inaccessible reference states

- High-resolution images: the proxy blocks mobbin.com.
- Mobbin's own app-version id for the supplied link.
- Dark mode, iPad, hover and focus states, keyboard-open layouts other than the code field.

## Verdict

V16 is a genuine reconstruction of the Withings Health Mate system, not a recolour. Its settings, forms, sheets and
lists are close to the reference, and its photo-led dating screens are a coherent but necessarily inferred extension.

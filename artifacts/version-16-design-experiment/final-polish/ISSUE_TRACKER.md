# Final polish: issue tracker

**Severity:**
- **P0:** broken or unusable.
- **P1:** an inconsistent shared component, or a wrong interaction or accessibility state.
- **P2:** a visible polish issue.
- **P3:** a subtle refinement.

**Fix level:**
- **T:** token.
- **C:** shared component rule.
- **V:** variant.
- **U:** specific usage.

**Status:**
- **Verified:** re-captured and inspected, and/or asserted by e2e.
- **Recorded:** deliberately not changed, with the reason given.

| ID | Severity | Area / component | Issue | Fix | Level | Status | Evidence |
|---|---|---|---|---|---|---|---|
| FP-01 | **P1** | Segmented control (Edit, Activity) | Selected segment a pill (16px) inside a 10px rounded track: the "square container with pill selector" | Segment corner = track − inset (8px) from tokens, with a selector matching V11's (0,5,0) specificity | C, T | Verified | Geometry audit clean; `polish-before-after.png`; e2e |
| FP-02 | **P1** | Photo slots (Photos, Edit) | Empty slot shows no keyboard focus (the dashed `outline` replaced the focus ring) | `:focus-visible` restores a 2px blue ring | C | Verified | `keyboard-focus.png`; e2e |
| FP-03 | P2 | Theme stylesheet | Components defined twice or three times with conflicting values across four appended sections; the winning value depended on source order | One consolidated, ordered stylesheet; proven pixel-neutral (54/54) | C | Verified | `PASS_1`; `qa/isolation.txt` |
| FP-04 | P2 | Theme stylesheet | Raw sizes (type, radii, heights, thumbs) bypassed tokens | 51 `component.withings` tokens; the stylesheet reads them | T | Verified | `tokens:check` pass; unit CSS rules pass |
| FP-05 | P2 | Prompt question (Profile, Edit, Interests against Discover and Like back) | Same role in two styles (14 semibold against 15 medium) and grey | One card-title role, 15 / 20 medium ink; specificity matched for the prompt variant | C | Verified | Inventory diff; e2e |
| FP-06 | P2 | Chips (static against interest and filter) | 14px against 15px text at the same height | One chip text size (15) | C | Verified | Inventory diff; e2e |
| FP-07 | P2 | Likes grid | Tiles in a row differ in size when captions wrap differently (430px: 257 against 243) | The tile fills its column (V16 scope; also present in V11 and default) | C | Verified | `responsive-430.png`; e2e |
| FP-08 | P2 | Switch (Settings) | Hit area 51 × 31 | `::before` extends it to 44px | C | Verified | `elementFromPoint` probe; e2e |
| FP-09 | P3 | Person names (inbox against Likes) | 700 against 600 | One weight (600) | C | Verified | Inventory diff; e2e |
| FP-10 | P3 | Search (Messages) | Input 25px inside a 46px field: taps on the field's padding missed it | The input stretches to the field | C | Verified | e2e |
| FP-11 | P3 | Edit profile | Section headings and capital field labels share a screen (Photos / BIO / FIRST NAME / About you) | Not changed: V11's real structure (fields against groups) and the reference's pattern; changing it means regrouping the form | — | Recorded | `PASS_3` |
| FP-12 | P3 | "Your move" label against small buttons | An outlined label sits close to the outlined-pill button style | Not changed: both follow the reference; they differ in corner, height and weight | — | Recorded | `PASS_4` |
| FP-13 | P3 | Discover gutter | 8pt against 16pt elsewhere | Not changed: V11's photo-led layout; cards align to the same edge | — | Recorded | `PASS_3` |

**Totals:** 13 issues. 0 P0. 2 P1, both fixed and verified. 6 P2, all fixed and verified. 5 P3: 2 fixed and
verified, 3 recorded.

There are **no open P0, P1 or P2 issues**.

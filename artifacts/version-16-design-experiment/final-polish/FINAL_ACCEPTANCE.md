# Final polish: acceptance

Judged on the rendered application and the executed checks (`PASS_7_REGRESSION.md`), not on the build alone.

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Design-system consistency | **Pass** | One consolidated stylesheet, each component defined once. 51 new tokens replace every raw size in the V16 layer. The consolidation is pixel-neutral (54/54). The unit suite's static CSS rules pass. `PASS_1`. |
| 2 | Component geometry and styling | **Pass** | The geometry audit found one real conflict (pill segments in a rounded track): fixed. Nested corners follow container minus inset everywhere. Equivalent roles (prompt question, chips, names) are unified; inventory diff in `qa/audits.txt`. `PASS_2`. |
| 3 | Layout and alignment | **Pass** | 0 overflow, clipping or overlap at 360, 375, 393 and 430. The Likes tile-size defect is fixed. Margins, rhythm and label spacing are consistent. One structural mix in Edit profile recorded, not changed. `PASS_3`. |
| 4 | Typography and colour hierarchy | **Pass** | Six distinct type levels, applied consistently. One meaning per colour. 0 text below 4.5:1. No V11 purple (scanned). `PASS_4`. |
| 5 | Responsive behaviour | **Pass** | Four phone widths plus the 1440 desktop gallery, automated and visual. `PASS_3`, `screenshots/comparisons/responsive-*.png`. |
| 6 | Interaction correctness | **Pass** | Product 88/88, V16 55/55, V11 111/111. Switches, sliders, sheets, action sheets, navigation, forms and the error state all exercised. `PASS_5`. |
| 7 | Accessibility | **Pass**, with noted limits | axe: 0 serious or critical on 15 V16 screens and on the approved design. Every control has a visible focus ring (the photo-slot P1 is fixed) and a 44pt target (switch and search fixed). **Limits:** no screen reader or real touch device in this container. |
| 8 | Screenshot-verified visual quality | **Pass** | 54 states and extra widths captured; inspected at 2×. 22 changed states, each traced to a fix; 0 unexplained diffs. `PASS_6`, `screenshots/contact-sheet.png`. |
| 9 | Regression and build integrity | **Pass**, with one environmental failure | `npm run check` passes (122 unit tests, build ok). Smoke 143/144: the one failure is the container Chromium's `corner-shape` default, identical on untouched V11. Default mode 162/162 and V11 49/49 pixel-identical. The 8 new checks fail on the pre-polish code. |
| 10 | Consistency with the V16 direction | **Pass** | No palette, layout or UX change. Every fix tightens the existing Withings-derived rules; the segmented fix makes the control match the reference's "Programs / Library" exactly. |

## Open items

- **No open P0, P1 or P2 issues** (`ISSUE_TRACKER.md`).
- **Three P3 items recorded and deliberately unchanged:**
  - the Edit profile heading / label mix;
  - the "Your move" label's resemblance to small buttons;
  - Discover's tighter gutter.

## Not verifiable here

- Real photography: the repo has none, so photo screens show placeholders.
- Screen-reader announcements and real-device touch.
- Hover and pressed states, beyond CSS review.
- Loading skeletons on V16 routes: no V16 route renders one without the network-error tool.

## Is it production-ready?

**As a visual system, yes. As a product, not yet.**
- **Ready:** the V16 experiment now meets the acceptance criteria above with no known high-priority defect.
- **Not yet:** "production" also needs real photography, real-device and screen-reader testing, and a decision on
  V16 against V11, none of which this task can supply.
- **Uncommitted:** the work is still uncommitted on `experiment/numaya-v16-withings`, pending your authorisation.

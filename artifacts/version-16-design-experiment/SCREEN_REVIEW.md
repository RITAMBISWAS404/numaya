# V16 screen review

Each pass was reviewed on full-size captures from `scripts/gallery.mjs` (393 × 852 at 2×, plus 375 × 667). The working
captures for each pass were kept in the session's scratch space; the final set is in `screenshots/`.

## Pass 1: first implementation (49 states)

**Fidelity (A).** It already read as Withings, not as V11 recoloured: the stone page, white cards without outlines,
capital modal headers, ink buttons and green switches.

| Problem | Correction |
|---|---|
| Discover actions and the photo's SuperSwipe were **ellipses**: V11's 72 × 56 pills with a 50% radius | 56 × 56 circles. Pass became the outlined secondary and Like the ink primary (the Share / Done pair) |
| The new-match portrait became an **oval** (portrait aspect at 50%) | Kept V11's rounded rectangle at the card corner |
| The Match portrait placeholder was a heavy **navy blob** | Navy is for avatars; the placeholder became the warm photo grey with an ink initial |

**Consistency (B).**

| Problem | Correction |
|---|---|
| Choice legends ("I'm a", "Pick a prompt", "When") and chip-set labels were still V11's grey sentence case, beside capital field labels | One label style: bold capitals |
| Profile card titles ("You both like") were grey labels, unlike the reference's ink card headers | Ink, 15 medium |
| The delete and block sheets' Cancel showed a grey hover-style fill when focused, and matched nothing in the reference | Outlined secondary ("Previous" under "Next") |

## Pass 2: side by side with the reference

Compared Settings with "Account & Security" (`14`) and Basics with "Cycle tracking" (`22`) at the same scale.

| Problem | Correction |
|---|---|
| The modal header sat on the stone page; the reference's is a **white bar with a hairline** | White bar plus hairline on `.topbar` (not on tab-root large titles) |
| Group headings were smaller than the reference's ("Account Settings" ≈ 22 pt) | 22 / 28 medium |
| Onboarding headings were bold display; the reference's flow questions are **medium** | 26 / 32, weight 500. Bold stays for tab-root titles |
| The capitals rule also hit a full sentence ("NEED AN OPENER? TAP ONE TO EDIT IT FIRST.") | Reverted for `.fl-label`; capitals only for short labels, as in the reference |

## Pass 3: technical review, which changed the visuals

| Problem | How it was found | Correction |
|---|---|---|
| **Body text was still Inter.** `body` sets `font-family` from `:root`, so text that inherits it (rows, buttons, copy) ignored the theme's `--font-text`; only `var(--font-display)` users had switched | The new e2e check read `font-family` on a list row | `.theme-withings { font-family: var(--font-text) }`. Every screen recaptured and re-reviewed: wider, lighter letterforms, closer to the reference |
| A raw `rgb()` shadow in the segmented control | Unit test "no raw colours" | `--shadow-withings-segment` token |
| The text on the tint (`#3B4FB4`) was more saturated than the reference | Sampling the archived weight screen `33` (#3E4987) | `#3E4A8F` (6.8:1 on the tint) |
| One reference preview was mislabelled (`05` is the Pace screen) and the comparison sheet showed it as "period tabs" | Visual audit of all archived previews | Renamed to `05-pace-solid-blue.jpg`; the real weight screen archived as `33`; sheets rebuilt |

## Layout and UX (C)

- V11 and V16 compared at the same state for all 49 captures (`screenshots/comparisons/v11-v16-*.png`, overview
  `comparison-v11-v16.png`).
- Nothing moved: photos, grids, headers, tab bar, composers and sheets are where V11 put them.
- The presentation changes are listed, with reasons, in `design-system/V11_LAYOUT_AND_UX_BASELINE.md`.

## Responsive and accessibility (D)

- **375 × 667** (`responsive-375.png`, 9 states): no clipped text, no horizontal overflow on any V16 screen at 393 or
  375 (e2e). Tab labels fit. The match portrait uses V11's short-phone rule.
- **Contrast:** the e2e scan walks every visible text node on the 14 flow screens to its painted background and
  found none below 4.5:1. Photos, disabled controls and decorative text are excluded.
- **axe:** 0 serious or critical issues on all 15 V16 screens (`qa/accessibility-axe-v16.txt`). The moderate
  "landmark" and "region" notes come from the single-screen preview harness and appear in V11 as well.
- **Focus:** fields, search and the composer show a 2px blue ring; choice rows a blue outline.

## Known limitations

- **No real photography** in the repo, so photo screens show placeholders and the V11 fade is unchanged.
- **The reference has no chat, search, slider or bubble**, so those rules are inferred. They are marked in
  `REFERENCE_ANALYSIS.md`.
- **The font is a substitute** (Hanken Grotesk). It is close but not identical; the reference's bold is slightly
  wider.
- **The new-match portrait's double ring** (V11's unseen-match ring, now blue around a navy tile) is heavier than
  anything in the reference. I kept it because it carries state.

## Final fidelity audit (passes A, B and C)

The full matrix is in [FINAL_FIDELITY_AUDIT.md](FINAL_FIDELITY_AUDIT.md); before/after crops are in
`screenshots/final-review/audit-before-after.png`.

| Pass | Problem found in the rendered app | Correction | Verified |
|---|---|---|---|
| A | Profile's gear and Activity's "+" were bare; the modal-header rule leaked into tab-root bars | Circles in page and tab-root headers; bare icons only in modal headers | Capture and e2e |
| A | Sheet dismiss was a filled grey circle (no reference counterpart) | Bare ink ✕ | Capture and e2e |
| A | Action-sheet Cancel was an outlined full pill | Separate white block, 14 corner, semibold | Capture and e2e |
| A | Empty states floated bare on the page | White empty-state card | Capture and e2e |
| A | New-match portraits were navy rectangles with a heavy double ring | 72pt circles, thinner blue ring (people-row evidence `40`, `13`) | Capture and e2e |
| A | Match avatar had a drop shadow; match title oversized | Flat avatar; title 32–36 | Capture |
| B | Invalid field showed no red outline (the V16 field rule overrode `.is-invalid`); disabled field lost its fill | States restored | Capture and e2e |
| B | Chips on "You both like" were white on a white card (specificity clash) | Matching selector; fill on cards, tint when selected | Capture and e2e |
| B | Checked: photo-options action sheet shows the form through the scrim | Kept: matches the reference's iOS action sheet | Capture |
| B | 375 × 667 states | No clipping or overflow | Capture and e2e |
| C | Empty-state cards were centred and inset 16pt beyond the content column | Left-aligned like the reference card, aligned to the column | Capture |

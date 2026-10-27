# V16 final fidelity audit

The final quality gate on the V16 that was first delivered (commit `5000592`). It is a correction pass, not a redesign:
the audit compared the running app with the reference, fixed the code, and checked every fix in a fresh capture.

## How it was done

1. **State before editing.** Branch `experiment/numaya-v16-withings`, clean working tree, in sync with
   `origin/experiment/numaya-v16-withings` at `5000592`.
2. **Reference revisited through the Mobbin connector.** Two new searches ("alert dialog or confirmation", "empty
   state") returned 18 Withings Health Mate screens, 11 of them new to this project. Seven were archived as
   `research/reference/38–44`:

   | Archived | What it shows | Mobbin |
   |---|---|---|
   | `38-eyes-closed-primary-not-now.jpg` | Ink primary over an outlined "Not now" | [f5748282](https://mobbin.com/screens/f5748282-5c67-4b85-bcb7-1a7236cbae2a) |
   | `39-leave-sheet-caps-title.jpg` | Destructive sheet: centred capital title, hairline, red button | [e7f9067d](https://mobbin.com/screens/e7f9067d-673a-4b2d-9e97-15759456b081) |
   | `40-assign-avatars-alert.jpg` | "Assign to" row of round avatars with names below; iOS alert | [df0ef8d5](https://mobbin.com/screens/df0ef8d5-9c69-4c0a-b403-8b1e905c72e5) |
   | `41-two-line-radio-card.jpg` | Two-line radio rows in a white card | [deeb49e0](https://mobbin.com/screens/deeb49e0-ca1e-4309-a876-cce1f37f9dcb) |
   | `42-continue-with-sheet.jpg` | Sheet: medium title with a text "Cancel", field, ink / outlined buttons, "OR" rule | [ac8a2c06](https://mobbin.com/screens/ac8a2c06-98ae-4fec-9558-8ad3b1da79b7) |
   | `43-wifi-direct-list.jpg` | A direct full-bleed list with hairlines on the page | [f6b771eb](https://mobbin.com/screens/f6b771eb-328e-4c5a-a73a-74dcda535094) |
   | `44-log-manually-sheet.jpg` | Modal: white header area over a grey body with a white list card | [fcbf72ea](https://mobbin.com/screens/fcbf72ea-cdcf-407a-8807-7023f2eea773) |

   The iOS action sheet [cffd85c8](https://mobbin.com/screens/cffd85c8-91fa-4181-a454-e43c1aa7c043) was seen again.
   The ids above follow the connector's result order; the images were matched by content.
3. **Access limits, unchanged from the first pass.**
   - Only the connector's 299 px previews are available: mobbin.com is blocked by this container's proxy, and no
     browser connector exists in this cloud session.
   - The app-version id in the supplied link cannot be confirmed through the connector.
   - **Not seen, so not claimed:** dark mode, iPad, hover and focus states, and any chat, search, slider or message
     bubble (the app has none).
4. **Every implemented screen re-captured.** All 49 states with `scripts/gallery.mjs` (393 × 852 at 2×, plus
   375 × 667), and inspected at full size, including 2× crops of headers, chips, fields and sheets.

**Evidence labels:**
- **O**: observed in a named reference screen.
- **A**: an approximation of something observed, adjusted for contrast or for the preview's resolution.
- **I**: inferred, because the reference has no equivalent.

## Traceability matrix

| Category | The reference shows | V16 before the audit | Discrepancy | Correction (status) |
|---|---|---|---|---|
| **Tab-root header** | Home and Measure: white 40pt circles with a hairline for "+" and the device icon (**O** `10`, `34`) | Discover had circles; **Profile's gear and Activity's "+" were bare icons** | Inconsistent; the modal-header rule `.topbar .nav-button--floating` also hit the tab-root large-title bars | Rule limited to `.topbar:not(.topbar--large)`; all tab-root buttons are circles. **Fixed**, e2e |
| **Modal header** | White bar, hairline, tracked capitals, bare chevron or ✕ (**O** `14`, `22`, `11`) | Same | None | Kept |
| **Logo** | Withings shows no logo inside the app | Numaya wordmark (Hanken bold) with the mark in the accent | Deliberate: Numaya identity | Kept; no Withings branding |
| **Bottom navigation** | White, hairline, filled black active icon, grey inactive, red dots (**O** `10`) | Same, 5 items (Numaya's sections) | Item count is product structure | Kept |
| **Icons** | Filled glyphs, about 20pt, ink (**O**) | Material Symbols Rounded, filled when active | Close in weight and fill | Kept |
| **Page titles** | Bold ≈30–32pt (**O** `10`, `09`) | 30 bold | None | Kept |
| **Match title** | (page-title scale) | V11's clamp, 36–42 | Oversized against the page-title scale | `clamp(32px, 9vw, 36px)`, 700. **Fixed** (**A**) |
| **Section and group headings** | 22pt medium ink (**O** `14`, `18`) | 22 medium | None | Kept |
| **Field and legend labels** | Bold capitals (**O** `11`, `16`, `26`) | Same | None | Kept |
| **Body and row text** | Regular grotesk (**O**) | Hanken Grotesk regular | The face is a substitute | Kept (limitation) |
| **Page and surfaces** | Stone page, white cards, no border or shadow (**O**) | Same | None | Kept |
| **Information box** | Page colour plus a hairline (**O** `08`, `10`) | Same | None | Kept |
| **Grouped rows** | 56pt rows, dividers inset both sides (**O** `14`, `17`, `30`) | Same | None | Kept |
| **Direct lists** | Full-bleed rows with hairlines on the page (**O** `43`) | Messages is a direct list | Matches | Kept (confirms the first pass's decision) |
| **Choice lists** | One white card, dividers, radio state (**O** `22`, `41`) | Same; radio on the right (V11) | Side of the radio | Kept on the right: V11 layout (documented) |
| **Primary / secondary buttons** | Ink 46–49pt, 12 corner; outlined white secondary (**O** `03`, `22`, `38`) | Same | None | Kept |
| **Destructive** | Red full-width (**O** `16`, `28`, `39`) | Same | None | Kept |
| **Small actions** | Outlined compact pills (**O** `13`, `19`, `23`, `28`) | Same, inside a 44pt target | None | Kept |
| **Sheet anatomy** | Grabber, medium title, **plain "Cancel" or ✕**, hairline (**O** `21`, `42`); caps title for a destructive sheet (**O** `39`) | Title and hairline right; **the dismiss was a filled grey circle** | The filled circle has no reference counterpart | Dismiss is a bare ink ✕, 44pt target kept. **Fixed**, e2e. The left medium title is kept (`21`, `42` pattern) |
| **Action sheet** | iOS: white row group and a **separate white Cancel block**, semibold (**O** cffd85c8) | **Cancel was an outlined full pill** | Wrong control family and radius | White block, 14 corner, no outline, 56pt; group without shadow. **Fixed**, e2e |
| **Empty states** | Illustration plus semibold title plus body **in a white card, left-aligned** (**O** `20`, `13`) | Bare on the page, centred | Missing card and alignment | White card aligned to the content column, left-aligned, 18 semibold title. **Fixed**, e2e (card) |
| **People row / new matches** | Round avatars with the name below, navy initials (**O** `40`, `13`) | 72 × 96 rounded rectangles with a heavy double ring | Shape | 72pt circles, a thinner blue ring for unopened matches. **Fixed**, e2e; layout note below |
| **Avatars** | Flat circles, navy initials (**O** `11`, `19`) | Match avatar had a drop shadow | Shadow | Shadow removed, white ring kept. **Fixed** |
| **Radios / checkboxes** | Grey ring, ink selected; blue checkbox (**O** `22`, `23`) | Same | None | Kept |
| **Switch** | Green, round thumb (**O** `13`, `15`) | Same | None | Kept |
| **Segmented control** | Grey track, white segment (**O** `25`) | Same | None | Kept |
| **Period / filter tabs** | Plain text, selected tint pill (**O** `04`, `33`) | Same | None | Kept |
| **Chips** | White icon chips on the page (**O** `24`) | White on the page; **white-on-white inside cards** ("You both like") | A specificity clash: the emoji-chip rule outranked the in-card rule | Matching selector; chips on cards take the fill, selected keeps the tint. **Fixed**, e2e |
| **Fields** | White, 1px dark outline, 8 corner (**O** `11`, `16`, `26`) | Same, but **the invalid state lost its red outline** and disabled lost its fill | A regression against V11 | `.is-invalid` red 2px and `:disabled` fill restored. **Fixed**, e2e |
| **Field outline when empty** | `42` shows a lighter outline on an empty field | One outline colour | Possibly a state variant (a single example) | Not changed: one example is too little evidence (**I**) |
| **Search / composer / bubbles / slider** | Absent from the reference | White field with a hairline; blue / white bubbles; blue slider | — | Kept, marked **I** |
| **Toast** | Light-blue pill (**O** `15`) | Same | None | Kept |
| **Badges** | Outlined "Withings+" (**O** `19`, `36`); tint "View product" | Same | None | Kept |
| **Radii / borders / shadows** | 6 / 8 / 12 / 14 / 16; hairlines; almost no shadow (**O**, **A**) | Same; one stray avatar shadow | Fixed above | — |
| **Spacing** | 16pt gutter, 12pt between cards (**O**) | Same; empty-state cards were inset 16pt beyond the column | Misalignment | Aligned to the column. **Fixed** |
| **Responsive** | — | 375 × 667: no clipping or overflow | None | Verified (e2e and captures) |

## Layout adjustment made in this pass

**New-match portraits went from 72 × 96 rounded rectangles to 72pt circles.**
- **Evidence:** the reference's two people rows (`40` "Assign to", `13` "Family") are round avatars with names
  below, and every Withings avatar is round.
- **Why V11's shape blocked a convincing result:** a portrait rectangle in navy reads as a card, not a person.
- **Usability:** the rail is 24pt shorter, names sit closer to their faces, and the target is unchanged at 72pt wide.
- **Verified in:** `final-review/audit-before-after.png` and `reference-v11-v16-2.png`.

No other element moved.

## Passes

- **Pass A, design system:** tab-root buttons, sheet dismiss, action sheet, empty-state card, round new-match
  portraits, a flat match avatar, match title scale.
- **Pass B, screens:** re-captured all 49 states. Fixed the invalid and disabled field states and chips on white
  cards. Checked 375 × 667.
- **Pass C (small, warranted by the comparison sheets):** left-aligned empty-state cards and aligned them to the
  content column.

Every pass was re-captured and checked at full size.
`screenshots/final-review/audit-before-after.png` shows each fix in the same state.

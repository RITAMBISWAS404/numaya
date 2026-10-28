# Master QA report

Evidence for the "complete the product" pass on `experiment/numaya-complete-product`. Scope and status are
in [MASTER_PRODUCT_COMPLETION_MATRIX.md](MASTER_PRODUCT_COMPLETION_MATRIX.md); the changes are in
[MASTER_IMPLEMENTATION_REPORT.md](MASTER_IMPLEMENTATION_REPORT.md).

**Nothing in this pass ran on a phone or emulator.** The Android SDK host is refused (403) by this
environment's proxy, so no APK was built. All visual evidence is from Flutter golden captures that use the
app's real fonts.

## Results

| Check | Baseline (`d92af19`) | This branch |
|---|---|---|
| `dart format --set-exit-if-changed lib test` | Clean | Clean |
| `flutter analyze` | No issues | No issues |
| `flutter test` | 227 passed, 8 skipped | **235 passed, 9 skipped** (skipped = opt-in screenshot captures) |
| Captures (`--tags screenshots --run-skipped`) | 12 passed | 13 passed |
| `npm run tokens:check` | OK | OK (437 tokens) |
| `npm run check` | Pass | Pass |
| `npm run test:e2e` | 143 / 144 | 143 / 144. The same corner-shape check fails as before; the web app was not modified |

## New and changed tests

| Test | Covers |
|---|---|
| `test/widget/system_states_test.dart` | **Offline:** banner on Home and in chat; a message waits, then sends on reconnect; a join fails with no state change and succeeds on Try again. **Session expired:** the page appears over the current screen; back can't skip it; a wrong code is refused; the demo code succeeds and returns to the same route with a toast; "Sign out instead" returns to Welcome and clears the flag |
| `test/unit/dating_controller_test.dart` (+1) | Offline messages wait in order, retry still waits while offline, and on reconnect the first goes out before the second; all end on the device |
| `test/widget/recovery_email_test.dart` | Email check (valid and invalid cases); removing the email turns email notifications off and leaves push; Settings add with a typo → error, fix → saved and labelled not verified; remove |
| `test/widget/full_app_journeys_test.dart` (+1) | Share Date: Share disabled until both fields are filled; preview text; nothing-sent copy; saved per match; menu label changes and reopens filled |
| `test/screenshots/capture_complete_product_test.dart` | Captures p01–p07 |

No assertion was removed or loosened.

## Screenshot review

**New screens:** captures p01–p07. Sheets: `screenshots/complete-product-1.png` and
`complete-product-2.png`.
- offline Home;
- offline chat with a waiting message;
- Share Date with its preview;
- recovery email error;
- Settings with the email;
- sign in again before and after sending the code.

**Changed by RR-1 and RR-2:** v01, v12, f06 and r03 were reviewed in contact sheets.
- Rows run to the screen edge; "Next 7 days" and "Hosting" are no longer cut at the gutter.
- At 2× text the cover badges sit above a smaller category mark.

**Unchanged:** after the final capture run, only the seven new p-captures were new files. Every other golden
matched the polish commit, so nothing else moved.

**RR-3 (Likes grid at 3:4)** is intentional and confirmed (RD-10).

## Findings in this pass

| # | Found by | Finding | Outcome |
|---|---|---|---|
| CQ-1 | Code vs inventory | B-76 recorded as Deferred, but a labelled permission stand-in exists | Matrix corrected to Partial |
| CQ-2 | Code vs inventory | The older SCREEN_INVENTORY lists the gender details, preview, Premium and verification as not built; all are built | Matrix records FULL_APP as the current inventory |
| CQ-3 | UI_REFINEMENT_QA | RR-1 and RR-2 still present | Fixed |
| CQ-4 | Capture p03/p04 | Share and Save looked disabled with filled fields | Capture artefact: the capture tapped before the frame rebuilt. Fixed in the capture; the widget tests already asserted the enabled state |
| CQ-5 | Visual review | The email field keeps its focus border colour while showing the error text | Left as is: the error is stated in text, so colour isn't the only signal. Noted for the design system |

## Accessibility and motion

- The offline banner is a live region, so screen readers announce it.
- The waiting message status is a live region.
- The sign-in-again page has a header, and back is consumed rather than dropped silently.
- All new text uses the type scale and wraps; nothing is clamped or truncated.
- No new animation was added. The banner and page use the existing route transitions, which collapse
  under reduced motion.

## Not tested or not determinable here

- **Hardware:**
  - running on a phone;
  - TalkBack order;
  - keyboard behaviour with the system keyboard;
  - touch feel.
- **APK:** not built (Android SDK host blocked). Build commands are in MASTER_IMPLEMENTATION_REPORT.md.
- **Real services:** network detection, 401 handling, email delivery, sharing. Each is simulated and
  labelled.

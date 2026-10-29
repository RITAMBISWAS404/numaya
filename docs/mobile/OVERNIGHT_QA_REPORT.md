# Overnight QA report

Evidence for `experiment/numaya-overnight-completion`. Changes are in
[OVERNIGHT_IMPLEMENTATION_REPORT.md](OVERNIGHT_IMPLEMENTATION_REPORT.md).

**Three kinds of evidence, kept apart:**
1. **Automated tests** (widget, unit, layout sweeps) ran here.
2. **Golden captures** ran here and were inspected as contact sheets.
3. **Real devices: none.** The Android SDK host returns 403, so no APK, emulator, TalkBack or
   frame-time measurement. The `image_picker` integration is tested only through its interface.

## Results

| Check | Baseline (`103daa0`) | Final |
|---|---|---|
| `dart format --set-exit-if-changed` | Clean | Clean |
| `flutter analyze` | No issues | No issues |
| `flutter test` | 235 passed, 9 skipped | **247 passed, 10 skipped** (skipped = opt-in captures) |
| Captures (`--tags screenshots --run-skipped`) | 13 passed | 16 passed |
| `npm run tokens:check` | OK | OK (437 tokens) |
| `npm run check` | Pass | Pass |
| `npm run test:e2e` | 143 / 144 | 143 / 144. The same corner-shape check fails as before; the web app is untouched |

## New tests

| File | Tests | Covers |
|---|---|---|
| `widget/chat_media_test.dart` | 5 | Photo: preview, remove, caption, send, in chat and inbox, full-screen viewer. Video card and its no-playback message. Voice: too short refused, timed note sent and labelled. Picker refused (toast) and cancelled (nothing). Attachment offline: waits, then sends on reconnect |
| `widget/profile_photos_test.dart` | 1 | Edit profile: cancel and refusal add nothing; a picked photo lands in the grid; made main, it shows as the Profile avatar and in Preview; replace keeps the position |
| `widget/overnight_stress_test.dart` | 4 | 320 × 568: chat with a pending photo, long caption, keyboard and 2× text; recovery email and Share Date sheets with the keyboard at 1.5×; sign in again with the code at 2×; the offline banner never covers the chat header. Controls must sit above the keyboard |
| `widget/route_sweep_test.dart` | 2 | All 33 signed-in routes at 320 × 568 / 150% and 393 × 852 / 200%; any overflow fails and lists every broken route |

**Counts:**
- Previous suites: unchanged in count. No assertion was removed or loosened.
- Test helpers: they now take a `mediaPicker` (default: none), so tests no longer depend on the host's
  plugin behaviour.

## Screenshots reviewed

| Captures | What was checked |
|---|---|
| n01–n06 | Attachment menu; pending photo with caption; sent photo; demo recorder at 0:08; video card and voice note; inbox preview |
| n07–n09 | My events with an event; Hosting empty with the new illustration; Events no results with the new illustration |
| n10–n12 | Edit profile with a real main photo; Profile avatar from it; Preview card |
| d044, q148, w05, f11 | Chat menu with Share date details; long messages at 130%; long link; new match (attach button added) |
| o22, o23 | Changed only by sub-pixel anti-aliasing of the new clipped photo tile (no pixel differs by more than 40 levels) |
| 21, f19, f20, w03 | Edit profile: only the photo note copy changed |

Every other golden matched exactly after the final capture run.

## Defects found and fixed

| # | Found by | Defect | Fix |
|---|---|---|---|
| OQ-1 | `chat_media_test` | Long toasts overflowed horizontally | Toast text wraps |
| OQ-2 | `chat_media_test` | Pending attachment: Remove merged into the description node, so it couldn't be reached on its own | Separate semantics nodes |
| OQ-3 | `overnight_stress_test` | Chat composer area overflowed (208 px) on 320 × 568, 2×, keyboard up | Capped at 55%, scrolls; demo note hides while typing |
| OQ-4 | `overnight_stress_test` | Action sheet overflowed with six actions at 150% | Scrolls; rows grow with text |
| OQ-5 | `route_sweep_test` | Paywall plan card overflowed at 150% and 200% | Saving tag wraps under the title |
| OQ-6 | Capture review | The attach-menu golden was overwritten by three different states | Captured once |
| OQ-7 | Repo hygiene | 204 golden-failure artifacts tracked in git | Untracked and ignored |

## Not tested

- On a phone:
  - the Photo Picker;
  - the camera intent;
  - real file paths;
  - large real images (decoding is size-limited by design).
- TalkBack reading order.
- Performance in profile mode.
- The visibility "not enough data" capture: the demo world always has recent sample likes. The rule is
  covered by `visibility_report_test`.

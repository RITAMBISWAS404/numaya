# QA handoff for the Fable design lab

For the follow-up executor (a cheaper model is fine). App source `da197b7` on `experiment/numaya-fable-design-20261113-0048`. Work in `C:\Users\biswa\Projects\Numaya-fable-lab`; leave `C:\Users\biswa\Projects\Numaya` and `C:\Users\biswa\Projects\Numaya-backend` alone.

## 1. Apply the owner's choices

1. **Read the export.** It is `numaya-choices-fx-da197b7-2026-11-13.json` (or `.txt`) from the gallery. Check that `reviewId` is `fx-da197b7-2026-11-13` and `sourceCommit` is `da197b7`.
2. **For each `selected` decision,** set that group's `proposed` in `apps/numaya_mobile/lib/features/lab/lab_registry.dart` to the chosen option.
3. **Leave `undecided` and `keep-baseline` groups at O.** Do not choose for the owner.
4. **Remove the unchosen branches and widgets** using the code map in [EXPERIMENTS.md](EXPERIMENTS.md), once the owner confirms.

## 2. What was checked in the design run

- **`flutter analyze`:** one older deprecation info in a test file.
- **`flutter test`:** 655 passed, 43 skipped, 0 failed. The skips are the same 42 as before plus the opt-in render harness. Nine new tests in `test/widget/fx_lab_test.dart` cover the rules the alternatives must keep.
- **Renders:** every option rendered from `da197b7` with the same demo data at 393 × 852. All options also rendered at 1.5× text and at 360 wide with no overflow error.
- **Device:** the debug APK installed and launched on the Pixel 10 emulator; the Demo hub opened, and the Visual Lab listed the `fx-` groups.

## 3. Not checked (do these before any release decision)

| Area | What to do |
|---|---|
| Switching options on a device | In the debug APK: tap the purple brand area on Welcome → Demo hub → Quick start, then Demo hub → Visual Lab V2 → choose an `fx-` option and visit its screen. Only the tests exercised this. |
| Keyboard | Compliment thread B: tap Reply and confirm the composer takes focus and sits above the keyboard. Thread A: type with the keyboard open. |
| Text scale 2.0 | Rendered only at 1.0 and 1.5. Check Profile B/C, Credits A/B, Streak A (the day circles) and Messages B at 2.0. |
| Narrow phone with large text | 360 wide and 1.5× together was not rendered. |
| Screen reader | TalkBack order on the feature card (header, balances, action), the week strip's spoken summary, and the Messages A group headings. |
| Reduced motion | No new motion was added. Confirm nothing regressed. |
| Long content | A 150-character Compliment in thread B (large type); a long prompt answer in thread A (Show more); long names in Messages rows. |
| Unavailable context | A Compliment whose photo or prompt was removed: thread A and B, and Messages B (no thumbnail must show). |
| Zero and many credits | 0 credits and 20+ credits in the feature card and Credits A. |
| Streak edge cases | Day 0, day 6, day 7 (reward day) and a counted today in Streak A and B. |
| Emulator screenshots | The delivered images are Flutter test renders with no status bar. Capture the chosen options once on the emulator. |
| Performance | Not profiled on real hardware. |
| Physical phone, iOS | Not run. |

## 4. Known limitations

- **Artwork:** Profile B/C, Credits B and Streak B use the mascot as a stand-in. They are artwork-pending.
- **Profile C** is a palette study of B, not a separate layout.
- **`r8-photo-scrim`** is still undecided by the owner.
- **No motion was added or recorded** in this run.
- **Release-mode APKs cannot sign in.** Demo sign-in is compiled out of release builds (`AppConfig.demoAuthAllowed`), so test builds must be debug builds until real auth exists.

## 5. Commands

Run these from `apps/numaya_mobile`.

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter test --tags comparison --run-skipped --update-goldens test/screenshots/fx_lab_capture_test.dart
```

```bash
flutter build apk --debug --dart-define=NUMAYA_DEV_TOOLS=true
```

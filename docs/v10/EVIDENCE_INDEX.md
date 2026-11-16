# V10 evidence index

The review folder is local and private: it holds demo photos, so nothing in it goes to Git.
**`C:\Users\biswa\OneDrive\Desktop\Numaya V10 Review\2026-11-16\`**

| What | Path (in the review folder unless noted) | Notes |
|---|---|---|
| Review APK | `Numaya-V10-review-debug.apk` | SHA-256 `41f8504b38938c862b2fd9f059d51a8e569e463a86f376664810cb954b9fb37f`, 253,928,069 bytes. `flutter build apk --debug --dart-define=NUMAYA_DEV_TOOLS=true`, Flutter 3.47.8. **Demo mode**: no live backend, so sends are stored on the phone and labelled "Not sent: saved on this device". Debug-signed, so it is not for distribution. |
| Signed release | none | Blocked: no `android/key.properties` and no upload keystore. `flutter build apk --release` fails with the PR-001 gate message (re-checked 2026-11-16). |
| Phone screenshots | `screenshots/01-…png` to `25-…png` | 01–07: A renders at 393 × 852 @3x. 08–22: emulator-5554 (AVD iPhone_16_Custom, an Android emulator at 1180 × 2556; not an iPhone). 08–16 and 18–20 are from the first trace; 17, 21 and 22 were taken on the final APK after D7. 23–25: A at 320pt and 200% text. |
| Gallery | `gallery/index.html` (serve the folder over HTTP, e.g. `python -m http.server`) | 7 scenes × O / A / C / A-stress (28 images). Tested in the built-in browser: a note persists after reload; JSON and Markdown export; JSON import merges (DEF-V10-10 fixed) and rejects a non-V10 file. |
| Raw renders | repo `apps/numaya_mobile/test/screenshots/v10/{O,A,C}/` (git-ignored) | `v10_capture_test.dart`; stress in `*/stress_w320_x2.0/`. |
| Gallery builder | repo `apps/numaya_mobile/tool/v10_gallery.py` | `python tool/v10_gallery.py test/screenshots/v10 <out>` |
| Critique | `docs/v10/DECISIONS.md` D3, D5, D7 | Blind critics; the images were the only input. In D7 the first pass caught a harness bug (O folder held A); the valid pass is recorded. |

## Device trace (emulator-5554, review APK; screenshots 08–22)
Each line is the trace step, then its screenshot numbers.
1. Explore the demo, then Discover renders A by default. The facts read as "Label: value". (08)
2. Scroll the page. (09)
3. Tap the Compliment pill, which opens the composer. (10)
4. Type a Compliment: the counter reads 20/150, the field stays visible with the keyboard up, and the text shows "Uses 1 credit". (11)
5. Send. The confirmation reads "Sent. You can keep chatting once Maya replies." (12)
6. Messages shows the new row as "Compliment sent · waiting". (13)
7. Open Sam's received Compliment: sender block, white reply tray, and a Dismiss link 44pt tall. (14)
8. Type a reply and send it. The chat opens with the reply labelled "Not sent: saved on this device" (demo, honest). (15–16)
9. Profile: the prompt card has a chevron, and tapping it opens the prompt editor. (17–18)
10. Dismiss Chloé's Compliment: it asks first, Cancel keeps it. (19–20)
11. On the final APK: Premium is a row of "Your profile", the prompt card is read once (uiautomator: one node, "A perfect first date. A record shop…"), and the About sheet and received Compliment are re-checked. (17, 21, 22)

Steps 1–10 ran on an earlier build of this branch. Screens that changed afterwards were re-captured on the delivered APK.
Not run: TalkBack spoken output, a physical phone, iOS.

## Automated checks (final revision)
- `flutter analyze`: 2 pre-existing infos (`design_review_capture_test.dart` curly braces; `ente_alignment_test.dart` deprecated `containsSemantics`). No V10 issues.
- `flutter test`: 747 passed, 50 skipped (the comparison captures, run separately), 0 failed. Run on 2026-11-16 on the final source.
- Capture harness: `v10_capture_test.dart` O, A, C (21 scenes) and the O and A stress runs (14 scenes) passed with no overflow exceptions.
- `npm run check` / `npm run test:e2e`: **not run**. V10 changed no web-prototype file, and this worktree has no `node_modules`.

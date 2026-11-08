# Validation (alignment V3, code `ba3a6fc`)

| Check | Result |
|---|---|
| `dart format` / `flutter analyze` | Clean / **No issues** |
| `flutter test` (full) | **575 passed, 42 skipped, 0 failed** (566 before; +9 in `ente_alignment_test`) |
| Skips | Unchanged from the Events pass (superseded old-Events, visibility, "no Events in MVP"); **none added** |
| Tests changed | `foundation_test` sheet radius 24 → 20 (EA-S01); `visual_lab_v2_test` registry allows `ea-*` groups with O + 2–3 options, and the 320pt/200% sweep now covers the four new groups |
| Regressions found and fixed | None in behaviour; first run had 2 failures, both from intended token/registry changes |
| Emulator capture | Pixel 10 AVD, API 36, 1080×2424 (411 dp; large-text shots at 360 dp, 200%): **38/38**, 0 skipped, 0 ANR overlays in the final run |
| Gallery (in-app browser, HTTP) | 38/38 images resolve; nothing preselected (0 of 4); choice + note persist across reload; export has schemaVersion, reviewId, codeCommit, generatedAt, exportedAt, selections, undecidedGroups, notesWithoutSelection; reset → import round trip identical; wrong reviewId, unknown variant, unknown group and invalid JSON refused without changing state; zero-selection export shows "No designs selected" and needs confirmation; non-zero export shows "n of 4" |
| APK | Debug, built at `ba3a6fc`, `adb install -r` Success, launches to Welcome |
| Contrast | All derived pairs computed (FOUNDATIONS.md) and asserted in tests |
| Web prototype | Not touched; not re-run (known CRLF failures unchanged) |

**Unverified:** physical phone, iOS, dark mode, profile-mode performance, toast and action-sheet
fidelity (not inspected in depth), a fresh full screen-by-screen re-audit of Discover, Likes,
Chats, Profile and onboarding (shared-primitive changes propagated and tested, not re-captured
screen by screen).

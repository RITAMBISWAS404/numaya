# Visual review report: final UX polish

**Run:** 2026-11-04, on the owner's Windows 11 machine, with Flutter 3.47.8 and Dart 3.13.7.

**Method:**
- Every screen was rendered by the screenshot captures (393 × 852 @2x).
- The baseline `e70135c` was rendered on the same machine from a `git archive` extract, so before
  and after use identical font rasterising.
- Discover was also checked on an Android emulator.
- Each issue got the smallest coherent fix, a re-render and its related test.

## Evidence
| Sheet | Screens |
|---|---|
| [before-after-match-discover.jpg](evidence/before-after-match-discover.jpg) | Match (two variants), Discover card |
| [before-after-lists.jpg](evidence/before-after-lists.jpg) | Settings, Account Health › completeness, event detail |
| [before-after-profile.jpg](evidence/before-after-profile.jpg) | Profile, Account Health › notices, Safety |
| [before-after-more.jpg](evidence/before-after-more.jpg) | Likes, Messages, Events explore, onboarding location, Help, Notifications |
| [device-swipe-hold-like.jpg](evidence/device-swipe-hold-like.jpg) | Pixel 10 emulator (API 36.1): a right swipe held mid-drag (stamp on the photo), then released by a split adb gesture (Android cancels it, and the card springs back, FP-09) |
| [device-swipe-left-right.jpg](evidence/device-swipe-left-right.jpg) | Same device: a real left swipe passes Maya (Undo appears), and a real right swipe likes Sam (Noor is next) |

The settled screenshots are the regenerated goldens in
`apps/numaya_mobile/test/screenshots/goldens/`.

## Issues found and fixed
| # | Issue | Kind | Fix | Test |
|---|---|---|---|---|
| 1 | A pointer cancel mid-swipe liked or passed a card already past the line | UX (functional) | Listener flags the cancel; the drag end springs back | `final_polish_test`: pointer cancel |
| 2 | A double tap could decide twice in the frame before the rebuild | UX (functional) | `_deciding` guard plus a check against `seen` | double tap; button during exit |
| 3 | No way to change your mind after crossing the line | UX | A firm fling back cancels | fling-back test |
| 4 | Swipe stamp was a small text badge | Hierarchy | Disc with check or cross, plus the word | drag-right and drag-left tests |
| 5 | Match showed your own avatar and a scalloped frame | Brief | One square photo of them (FP-05) | three Match tests, plus the size matrix (route added) |
| 6 | Grey, undifferentiated lists | Hierarchy | Semantic icon tiles and inset dividers | tile and divider tests; tone contrast |
| 7 | Settings: half the groups had icons | Consistency | Every row tiled (FP-11) | renders |
| 8 | Account Health parts list (open item from the last QA) | Hierarchy | Status-toned tiles (FP-04) | renders; size matrix |
| 9 | Tab indicator was a 16pt square inside the pill | Consistency | Concentric circle, 26 (FP-06) | nested-corner test |
| 10 | RSVP bar corner (24) smaller than its pill button (28) | Consistency | 40 | renders |
| 11 | Value column ignored the new tile: overflow at 320pt and 200% text on Edit Profile | Layout regression (caught by the size matrix) | Width from `LayoutBuilder` minus the tile | `size_matrix_test` |
| 12 | Event host avatar 32pt beside 40pt tiles | Alignment | 40pt | renders |
| 13 | Copy wrapping by a line (Snooze, Profile & visibility, Your area) and an orphaned "km" on Likes | Content | Shorter copy; a non-breaking space | renders |

## Scores (1–5, after; before in brackets)
Scored against the same rubric as the premium `DESIGN_REVIEW_AUDIT.md`. No 5 is awarded where a
known issue remains.

| Screen | Layout | Hierarchy | Accessibility | Consistency | Note |
|---|---|---|---|---|---|
| Discover | 4 (4) | 4 (4) | 4 (4) | 4 (4) | Swipes now safe and named. Still placeholder photos |
| Own Profile | 4 (4) | 4 (3) | 4 (4) | 4 (3) | Toned tiles separate the four areas |
| Other-user profile (Discover / preview) | 4 (4) | 4 (4) | 4 (4) | 4 (4) | Unchanged structure; already Bumble-like (photo, prompt, about, interests, location) |
| Match | 4 (3) | 4 (3) | 4 (4) | 4 (3) | Photo-led. Without real photos the initial stands in |
| Likes | 4 (4) | 4 (4) | 4 (4) | 4 (3) | Caption no longer orphans "km" |
| Messages | 4 (4) | 4 (4) | 4 (4) | 4 (4) | Not changed; avatar rows stay divider-free |
| Events (list / detail) | 4 (4) | 4 (3) | 4 (4) | 4 (3) | Detail metadata scans by colour and icon |
| Account Health | 4 (3) | 4 (3) | 4 (4) | 4 (3) | Status readable at a glance; still list-based, no invented metrics |
| Settings | 4 (4) | 4 (3) | 4 (4) | 4 (3) | One rhythm |
| Onboarding | 4 (4) | 4 (4) | 4 (4) | 4 (4) | Only the location row changed |
| Shared lists and cards | 4 (3) | 4 (3) | 4 (4) | 4 (3) | `IconTile` and `ListGroup` dividers |
| Navigation | 4 (4) | 4 (4) | 4 (4) | 4 (3) | Indicator concentric |

No major screen is at 3 or below after this pass, so no second refinement cycle was needed.

## Tests and checks
| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | clean |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` | **288 passed, 11 skipped, 0 failed** on the final code (baseline on this machine: 266 passed, 11 skipped) |
| Screenshot captures, `--update-goldens` | 17 passed; 187 goldens regenerated **after review** (FP-14) |
| `flutter build apk --debug` | built `app-debug.apk` |
| Emulator smoke (Pixel 10, API 36.1, software GPU) | App launches. Demo Hub quick start reaches Discover. Real left and right swipes decide correctly; the stamp shows mid-drag. A cold-start "isn't responding" dialog appeared once on the debug JIT build with software rendering (dismissed with Wait); not seen afterwards |
| `npm run check` (web, untouched) | **fails in this checkout for an environment reason.** `core.autocrlf=true` checks generated files out with CRLF, and `tokens:check`, `icons:check` and one unit test compare them against LF output. No web file is modified. The other 121 web unit tests pass and `vite build` succeeds |
| `npm run test:e2e` | **not run:** the Playwright browser is not installed (`npx playwright install` downloads it) |

**New tests:** `test/widget/final_polish_test.dart` (22):
- swipe right, swipe left with undo;
- dragged back, flung back, pointer cancel;
- double tap, button during exit;
- photo tap is not a swipe;
- buttons match gestures;
- Match: only them, the right person, 320pt / 200%;
- tile size and colour, bare-icon option, divider inset and count, divider opt-out;
- tone contrast;
- slot ratios at 320pt / 200%;
- `AppRadii.nested`, tab indicator, Discover photo.

**Route matrix:** `/match/amara` was added to `fullAppRoutes`, so the 4-width × 3-text-size matrix
and the tap-target guidelines cover Match. No test was deleted, skipped or loosened.

## Known issues and limits
- **Placeholder photography.** Discover, Match and Likes show grey placeholders (Match shows the
  initial). The image-first layouts are designed for real photos.
- **Long names on Match.** The sample people have short names, so Match was not exercised with a
  long name. The body text wraps naturally (`BalancedText`, no truncation), but this is not
  verified with a 25-character name.
- **Emoji in goldens.** Emoji render as tofu in the test renderer; on the device they render
  correctly. This predates the pass.
- **Not verified on a physical phone.** Haptics, real-device performance and font hinting are not
  checked; the emulator used software rendering.
- **Undo is pass-only by design (FP-10).** Bumble's Backtrack behaves the same way.
- **`ScallopPortrait` is now unused** by screens. It is kept in the design system in case the
  Design Lab or a later screen wants it; delete it if it stays unused.

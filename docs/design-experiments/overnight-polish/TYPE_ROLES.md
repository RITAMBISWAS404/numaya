# Type roles: 14/20 body, 12/16 pills, one larger scale

**Run:** 2026-11-04. Cloud worktree `/home/user/numaya-overnight`, branch
`experiment/numaya-overnight-polish`, HEAD `6b23c85`.

**Status:** local only, uncommitted. **Evidence:** golden-harness renders (Linux, real fonts). No
emulator and no device (no Android SDK here).

## Final roles
| Role | Size / line | Face and weight | Used for |
|---|---|---|---|
| `body` | **14/20** (`height` 20/14) | Figtree 400 | descriptions, bios, chat messages, empty and result bodies, ledes |
| `bodySm` | 14/20 | Figtree 400 | secondary-colour copy (same size as body) |
| `pill` (new) | **12/16** | Figtree 500; 600 when selected | view tabs and filters (`ViewTabs`), selectable chips (`NumayaChip`) |
| `chip` | **12/16** | Figtree 500, ink | informational profile facts (`InfoChip`, Profile chips) |
| `StatusBadge` (uses `micro`) | **12/16** | Figtree 600 | status badges ("Verified", "Going", "New", "Few spots left") |
| `card` | 18/24 | Jakarta 700 | lead: card titles |
| `section`, `sheetTitle`, `emptyTitle` | **20/26** | Jakarta 700 | section, sheet and empty-state titles |
| `promptAnswer` | **20/26** | Jakarta 600 | prompt answers |
| `flowTitle`, `headline` | **24/30** | Jakarta 700 | screen titles: onboarding and editorial headings, result titles, Profile name |
| `pageTitle` | **28/34** | Jakarta 800 | prominent: tab-root titles, event and help-article titles (24/30 above 160% text, OP-04) |
| `hero` | **32/38** | Jakarta 800 | display: profile names (Discover and preview) |

**Kept on purpose (exceptions):**

| Role | Size / line | Why |
|---|---|---|
| `row` | 16/22 | list and option rows (OP-02) |
| `input` | 16/22 | typed text (OP-03) |
| `button` | 16/20 | actions |
| `headerCaps` | 17/22 | modal titles |
| `label`, `fieldLabel` | 14/18 | form labels |
| `caption` | 13/18 | metadata |
| `micro` | 12/16 | eyebrows, dates |
| `welcomeTitle` | 36–44 | marketing hero |
| `metric` | 40/44 | Bevel-style number |

No new unused roles. The rejected "compact" switch was removed from the code. The 16/24 body is
still reproducible with `--dart-define=NUMAYA_TYPE_SCALE=base`.

## Traced to the resolved style (widget tests)
Checked in `test/widget/type_roles_test.dart`, which merges each `Text` style with the ambient
`DefaultTextStyle`:

| Resolved style | Widgets |
|---|---|
| **14/20, weight 400** | the Discover bio ("Designer by day, crate-digger by night."), chat messages (Priya thread), an empty-state description |
| **12/16** | `NumayaChip` (500 idle, 600 selected), `ViewTabs` labels on Events, `InfoChip`, `StatusBadge` |

The pill and tab heights are asserted to stay at `AppSizes.chip` or more. The 48dp tap-target and
label guidelines pass on every route (`accessibility_test`).

**Regression check:** the same file run with `--dart-define=NUMAYA_TYPE_SCALE=base` fails all four
body checks (+3 −4). It would catch the old 16/24 default coming back.

## The 8/12 micro-badge trial: rejected
`artifacts/type-roles/badge-8-vs-12-at-1x.png` (phone size) and `…-at-2x.png`:
- At 8/12, "Sample profile", "New here" and "4 photos" are barely legible at 1x, and the 26pt badge
  looks empty.
- Every badge in the app carries status or a disclosure, and none is purely decorative.

**8pt is used nowhere.**

## Matched comparison (same demo data, viewport, theme, frosted bar)
`test/screenshots/compare_type_scale_test.dart` renders 7 screens at 320×693 and 390×844, at 100%
and 200% text:
- Discover;
- Discover scrolled to the bio;
- Profile;
- a worst-case long bio;
- Chat with a multiline message;
- the interests editor (longest interests);
- Events (view tabs, filters and badges).

| Sheet (rows: before, after) | Path |
|---|---|
| 390pt, 100% | `artifacts/type-roles/sheet-390-100.jpg` |
| 320pt, 100% | `artifacts/type-roles/sheet-320-100.jpg` |
| 390pt, 200% | `artifacts/type-roles/sheet-390-200.jpg` |
| 320pt, 200% | `artifacts/type-roles/sheet-320-200.jpg` |
| Golden review across families | `artifacts/type-roles/goldens-review-1.jpg`, `goldens-review-2.jpg` |

The individual renders are not committed (the sheets above show them); regenerate them with `flutter test --tags comparison --run-skipped --update-goldens` into `test/screenshots/comparison/`. **Findings:**
- **Fixed by the new sizes:** at 320pt and 200%, the Events view tabs had been clipped vertically
  ("Explore", "My ever…" cut by the pill), and interest chips broke onto two lines ("Natural /
  wine", "Board / games"). With 12/16 pills both fit on one line.
- **No new clipping or overflow:** the size matrix (34 routes × 4 widths × 3 text sizes) and the
  route-gap sweep pass.
- **Trade-off:** 12pt labels sit in unchanged 36pt pills (needed for the hit areas), so pills read
  airier than before. A visual-height reduction with an expanded hit area is a possible follow-up,
  outside this pass's scope.

## Contrast (unchanged colours, rechecked for these roles)
| Pair | Ratio |
|---|---|
| Selected pill: white on `#7262C7` | 4.90 |
| Idle pill: ink on white | 17.72 |
| Idle pill on the fill | 14.78 or better |
| Neutral badge: text2 on fill | 7.44 |
| Brand badge: `#5B4BB0` on tint | 6.00 |
| Badge on a photo: `#5B4BB0` on white | 6.82 |

No pill or label sits on glass (the tab bar is icon-only).

## Tests
| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date (the generated web tokens are not involved; Flutter type is hand-authored in `app_typography.dart` and `monochrome_tokens.dart`) |
| `flutter test` | **323 passed, 14 skipped, 0 failed** (before this pass: 316 / 14 / 0) |
| `flutter test test/widget/type_roles_test.dart --dart-define=NUMAYA_TYPE_SCALE=base` | fails as intended (+3 −4) |
| Captures (`--tags screenshots --run-skipped --update-goldens`) | 20 passed; 176 goldens changed (titles and pills on most screens), reviewed by family; 6 renderer-only restored |
| Emulator, device, TalkBack, VoiceOver | **Not run:** no Android SDK or device in this environment |

Pinned values updated, not loosened:
- `foundation_test`: the heading sizes;
- `frosted_navigation_experiment_test`: chip 14 changed to 12.

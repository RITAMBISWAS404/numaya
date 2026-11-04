# Spacing, padding and corner radius

**Run:** 2026-11-04. Cloud worktree `/home/user/numaya-overnight`, branch
`experiment/numaya-overnight-polish`, HEAD `6b23c85`. **Local only, uncommitted.**

**Evidence:**
- golden-harness renders (Linux, real fonts);
- widget geometry tests;
- a source scan.

No emulator, device or Flutter Inspector session: the Dart MCP server failed to start here, and
there is no device. Widget diagnostics are therefore the measured rects in widget tests.

**Kept fixed:**
- 14/20 body and 12/16 pills;
- palette;
- navigation and the frosted bar.

## Method
1. **Source scan** of every literal `SizedBox`, `EdgeInsets` and radius in `lib/features` and
   `lib/core/design_system/widgets`. Values not on the scale, or not tokenised, were traced to
   their owner.
2. **Doubled-gutter scan:** horizontal gutter padding inside `NumayaScreen` bodies. Three hits, all
   single owners: the chat thread's own scroll view, the Discover header and the tab header.
   **No doubling.**
3. **Nested-radius check:**

   | Container | Inner + inset | Outer |
   |---|---|---|
   | Discover hero card | photo 24 + 8 | 32 ✓ |
   | Composer tray | field 24 + 6 | 30 ✓ |
   | Event card | cover clipped by the card's own 24 radius | ✓ |
   | `AppRadii.nested` | used where cards nest | ✓ |

4. **Touch targets:** `Pressable` enforces a 44pt minimum in layout, so expanded areas cannot
   overlap. The Android 48dp and labelled-target guidelines pass on onboarding, dating and the 34
   full-app routes (`accessibility_test`).
5. **Captures:** 7 screens at 320/390pt and 100%/200% text, plus the full golden set, before and
   after.

## Findings
| # | Component (route) | Evidence | Source | Fix |
|---|---|---|---|---|
| SP-01 | Pills disagreed on insets: `NumayaChip` 14 left, 12 right, 5 down; `ViewTabs` 14; `InfoChip` and Profile chips 12/4 | source scan | three widgets hard-coding their own values | One pill inset: 12 × 4 (`pillInsetX/Y`) |
| SP-02 | The icon-to-label gap was 6 in chips (`NumayaChip`, `InfoChip`, Profile chips, Health status pill), 4 in badges and 10 in the search field, while the token `iconLabelGap` is 8 | source scan; `spacing_rules_test` | literals at call sites | Two tiers: **4** in compact controls (`compactIconGap`), **8** in rows, fields and buttons (`iconLabelGap`); the search field moves 10 → 8 |
| SP-03 | Discover photo badges wrapped at 6 while chip groups wrap at 8; stacked badges at large text used 4 | `person_profile.dart`; sheet 320-200 | literals | One group gap: 8 (`groupGap`) for chip and badge groups |
| SP-04 | Chat bubble inset 14 × 10 (off-grid) | `MessageBubble` | literal | 12 × 8 |
| SP-05 | Toast padding 16/9/16/10 and radius 20 | `toast.dart` | literals | 16 × 12 and `AppRadii.card` (it clamps to a pill on one line and stays soft when wrapped, as before) |
| SP-06 | `ResultPanel` title → body 10, `EmptyState` 8 | `content.dart` | literal | 8, matching `EmptyState` |
| SP-07 | The setup "Up next" tag 10 × 4 against the badge variant's 8 × 4 | `_SetupStepTile` | literal | Badge inset 8 × 4 |
| SP-08 | Phone screen: 10 between the country badge and the number field | `phone_screen.dart` | literal | 8 |

## Rules (tokens in `lib/core/design_system/foundations/app_layout.dart`)
**Spacing scale:** 4 · 8 · 12 · 16 · 20 · 24 · 32 (also 28, 40, 48 in `AppSpacing`).

| Job | Token | Value |
|---|---|---|
| Screen gutter (owned by `NumayaScreen` and tab headers) | `screenGutter` | 20 |
| Section gap | `sectionGap` | 40 |
| Field gap (form fields in a stack) | `fieldGap` | 20 |
| Heading → its content | `headingGap` | 12 |
| Item gap (cards in a list) | `itemGap` | 12 |
| Card padding / hero card padding | `cardPadding` / `heroPadding` | 20 / 24 |
| Icon → label in rows, fields and buttons | `iconLabelGap` | 8 |
| Icon → label in pills and badges | `compactIconGap` (new) | 4 |
| Pill inset (tabs, filters, chips, fact chips) | `pillInsetX` × `pillInsetY` (new) | 12 × 4, in a 36pt pill |
| Badge inset (status badges, tags) | `badgeInsetX` × `badgeInsetY` (new) | 8 × 4 |
| Siblings in a chip or badge group | `groupGap` (new) | 8 |
| Title → body in empty and result panels | `s2` | 8 |
| Label → its detail line | literal | 2 (optical; kept) |

Labels sit closer to their content than to the next group:
- 2 from a label to its detail;
- 8 between a title and its body;
- 12 from a heading to its content;
- 40 between sections.

**Radius scale:**

| Radius | Used for |
|---|---|
| 8 | tag |
| 12 / 14 | icon tiles 40 / 48 |
| 16 | controls, icon buttons |
| 18 | fields, tiles |
| 24 | cards, images, toast |
| 28 | dialogs |
| 32 | hero cards, sheets |
| pill | buttons, chips, tabs, search, the tab bar |

Nested surfaces follow outer = inner + inset.

## Intentional exceptions (kept, with their job)
| Value | Where | Why |
|---|---|---|
| 2 | label → detail (rows, cards), the bubble group margin | optical tie between two lines of one item |
| 3 | toast typing dots | decorative animation spacing |
| 5 / 6 across | `CountryCodeBadge`, `CountBadge` (22pt numerals) | centres a numeral in a 22pt circle or pill |
| 8 × 2 | `PhotoGrid` "Main" label | fits a 2-line-safe label on a thumbnail |
| 13 down | text fields, search, country rows | centres 22pt-line text in a 58 or 52pt field |
| 30 / 24 | composer tray / field | outer = inner + 6 |
| 20 | welcome scene tiles | decorative illustration composition |

## Variants checked
| Group | Variants |
|---|---|
| Pills and controls | `NumayaChip` (idle, selected, unavailable), `ViewTabs` (tabs, filters with counts, segmented), `InfoChip` (page and card), Profile chips, `StatusBadge` (neutral, brand, on photo, warning, danger), setup tag, Health status pill |
| Buttons | primary, secondary, brand, quiet, destructive, small, icon buttons |
| Lists and cards | `ListRow` (value, switch, chevron, stacked value), `OptionCard`, `WhiteCard`, `InfoCard`, `EmptyState`, `ResultPanel` |
| Messaging | `MessageBubble`, composer |
| Overlays | toast, sheets, tab bar (opaque and frosted) |

## Routes
- **Fixed through shared components:**
  - Discover (photo badges, fact chips);
  - Profile (chips);
  - Chat (bubbles);
  - Inbox (filters);
  - Events (tabs and filters);
  - onboarding (interest and pronoun chips; setup tag; phone);
  - Likes (filters);
  - Account Health (status pill);
  - every toast.
- **Checked unchanged:** settings and safety lists, sheets and dialogs. Their geometry was already
  on tokens.
- **Open:**
  - device-only checks: the keyboard on real hardware and the gesture/three-button bar;
  - Inspector traces on a running app.

## Evidence (stable paths)
| Path | Shows |
|---|---|
| `artifacts/spacing/sheet-390-100.jpg`, `sheet-320-200.jpg` | Before (the type-roles state) and after: Discover, the bio, Profile, Chat, the interests editor and Events |
| `test/screenshots/comparison/` (regenerated, not committed) | The individual renders: `flutter test --tags comparison --run-skipped --update-goldens` |
| `artifacts/spacing/goldens-review.jpg` | The toast, the setup tag, the Health status pill and chat bubbles, before and after |

## Tests
| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date (the new tokens are hand-authored Flutter layout roles, outside the web generator) |
| `flutter test` | **326 passed, 14 skipped, 0 failed** (+3 in `test/widget/spacing_rules_test.dart`) |
| Drift check | Putting one chip's icon gap back to 6 makes `spacing_rules_test` fail; it passes once restored |
| Captures | 20 passed; 89 goldens changed and reviewed; 6 renderer-only restored |
| Size matrix (34 routes × 4 widths × 3 text sizes), route-gap sweep, tap-target guidelines, keyboard-over-tab test | pass (in the full suite) |
| Emulator, device | **Not run:** no Android SDK or device here |

## Pill gaps (2026-11-04, follow-up)
**Root cause:** `ViewTabs` laid its pills in a plain `Row` with no gap, so adjacent pill
backgrounds touched ("Unread 1" ran into "Your move 2"). It is shared by 11 callers:
- Conversations filters;
- Likes filters;
- the Events Explore / My events tabs, date filters and My events sub-filters;
- the Discover filters sheet's Basic / Advanced choice;
- Account Health and others.

**Fix:**
- **`ViewTabs`:** the row owns the gap, 8 (`AppLayout.groupGap`) between pills; each pill keeps its
  12pt inset. The horizontal scroll and the gutter bleed are unchanged, so the first pill stays on
  the gutter.
- **Event card badges:** the `Wrap` moves from 6/6 to 8/8 (`groupGap`).

**Final values:**

| Measure | Value |
|---|---|
| Horizontal gap between pills | 8 |
| Run gap between wrapped rows | 8 |
| Inset | 12 × 4 |
| Icon gap | 4 |
| Label → count | two spaces (about 6pt at 12pt) |

**Already compliant:** `ChipSet` (interests, categories), Profile and fact chip `Wrap`s, Discover
photo badges, and pronoun chips (all 8/8).

**Not pills (exempt):**
- the verify code-cell row (4);
- event attendee avatars (4);
- the Likes and Profile tile grids (12);
- Design Lab button rows;
- the true segmented control (`_Segment`): its segments share one track by design.

**Tests:**
- `spacing_rules_test`: the adjacent-pill gap is 8, and edge taps 2pt inside the shared gap select
  the correct pill. It fails when the gap is 0.
- Suite: **338 passed, 15 skipped, 0 failed**.
- Captures: 28 goldens changed (every screen with `ViewTabs` or event badges), reviewed.

**Evidence:** `artifacts/pill-gaps/pill-gaps-before-after.png` (Conversations, Events tabs and
filters, Likes filters).

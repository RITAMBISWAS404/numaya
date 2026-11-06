# Tabler MVP pass: QA

**Evidence labels:**
- *Test* means an automated Flutter widget test.
- *Harness* means a Flutter golden render on Linux.
- No Android emulator (no KVM) and no physical device was available in this cloud session, so **nothing here is device evidence**.

## Checks (Linux, Flutter 3.47.8 / Dart 3.13.7)
| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `python3 tool/sync_tabler_icons.py --check <@tabler/icons 3.50.0>` | 109 SVGs checked, 0 problems |
| `flutter test` (full suite) | **473 passed, 21 skipped, 0 failed**. The skips are the opt-in `comparison` and `screenshots` capture suites. |
| `test/widget/tabler_mvp_test.dart` (new) | 19 passed |

## What the tests cover
- **Icons:**
  - The `TablerSvg` asset path is correct for outline and filled.
  - A role without a filled twin falls back to the outline.
  - Tinting uses `srcIn`.
  - The glyph is excluded from semantics.
  - Every shared icon name has a bundled outline (and its filled file, if mapped).
  - Every alert icon has filled artwork.
- **Navigation:**
  - The four destinations are Home, Likes, Messages and Profile; there is no Events tab.
  - The selected tab is announced as a selected button.
  - Filled vs outline flags, and `iconSelected` vs `iconInactive`.
  - Tile geometry: 38pt tiles, 15pt from the ends, 82pt apart.
  - The full 48×44 slot is tappable, not just the glyph.
  - At 320pt with 200% text, all four tiles fit (this test fails without the gap fix: 315 > 294).
- **Stacks and restore:**
  - Each tab keeps its own stack (chat → back → Profile → Messages).
  - Android back on a non-Discover root goes to Discover.
- **Alerts:**
  - The `StatusBanner` icon is centred within 1pt for short, multiline and with-action copy.
  - The `InfoCard` stays centred at 320pt and 200% text.
  - The updated UI-010 and OV-01 expectations.
- **Events:**
  - Direct routes land on Discover with no loop or exception: `/events`, `?view=mine`, `/event/new`, `/event/e-jazz`, `/people` and `/edit`.
  - A pushed event link lands on Discover too.
  - The Demo Hub has no Events shortcuts.
  - EXP-003 A/B have no Events path.
  - With the gate on, the tab returns and opens.
  - The preserved Events suite passes with the gate on.

## Visual sweep (harness)
- **Views:** 58 views × {390×844, 320×693 at 200% text}.
- **Experiments:** 4 experiments × {Current, A, B, C} × {phone, narrow, tall}, plus the lab.
- **Component boards:** 5.

Every capture asserts that no exception was thrown. The sweep covers onboarding and verification, Discover and filters, match, Likes, messaging and chat sheets, profile and editing, settings, safety, account holds, premium, the Demo Hub, and the (now redirected) Events routes.

**Found and fixed during the sweep:**
1. The tab bar clipped Profile at 320pt (TB-05).
2. The `pending` alert tone drew an outline because Tabler has no filled `progress`. It now uses `clock`.
3. A first attempt to use `hourglass` for `pending` misread on the completeness rows, so it was reverted.
4. The asset sync skipped map entries that `dart format` had wrapped onto several lines. The test caught it and the parser was fixed.

**Before/after boards:** `artifacts/ente-design-system/tabler-mvp/before-after/`. In each pair, V4 is on the left and Tabler on the right.

## Accessibility
- **Tabs:** each tab is `Semantics(selected, button)` with its label, and the badge count is in the label. Tooltips carry the label for long press.
- **Selected state** is shape plus colour: a filled glyph on a tile versus an outline.
- **Inactive grey** `#8A8A8A` is 3.46:1 on white, which meets the 3:1 minimum for non-text UI.
- **Alert glyphs** keep their semantic colours (accent, warning, positive, negative) on white cards. The text carries the meaning.
- **Focus:** the existing `Pressable` focus ring is unchanged. Keyboard focus order was not re-verified on a device.

## Still needed on a real device
- Visual weight of Tabler's 2px stroke at real pixel density next to photos.
- TalkBack reading the four tabs, including the selected state and badge counts.
- Back gesture and restoring the app after process death on a tab other than Discover.
- An Events deep link from outside the app, if one is ever registered (no intent filter exists today).
- Contrast of the light grey glyphs in bright light.

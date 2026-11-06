# UI consistency pass (2026-11-07)

| | |
|---|---|
| Branch | `experiment/numaya-ui-consistency-20261107` |
| Starting checkpoint | `f6614fa009de56b771926c5b29ba4140d6fafb7f` (typography and copy pass, on `origin`) |
| Preserved edits | `b0194d4`: the interrupted screenshot run's handoff reconciliation and the harness `final` set, committed separately before this pass |
| Brief | `NUMAYA_FINAL_UI_CONSISTENCY.zip` (phases 00–05), sha256 `86162fc2…ef224472d` |
| Carried forward unchanged | Tabler icons and their outline/filled rules; Figtree text and Plus Jakarta Sans headings, 14/20 body and the TC type roles; centred alert icons; Events gated off; EXP-001–004 pending, with every variant kept |
| Device evidence | `C:\Users\biswa\OneDrive\Desktop\Numaya Final Screenshots\UI consistency 2026-11-07\` (before, after, compare, INDEX.md); the boards are also in `artifacts/ente-design-system/ui-consistency/before-after/` |

## Figma access
The Figma MCP server needs authorisation in this session (`/mcp`), so nodes **were not re-read live**. This pass used the measurements recorded from the same file in earlier passes:
- `overnight-v2/FIGMA_SOURCE_MAP.md`;
- `../TOKENS.md`;
- `../README.md`;
- `../tabler-mvp/DECISIONS.md`.

Node IDs are cited from those records. Measurements Figma would add and the records lack are marked *not verified* below. No values were guessed:
- Ente's knob size and inset (the switch geometry stays 46 × 27 with a 23pt knob);
- Ente Header v2's exact action gap (the existing 8pt FD-D1 rule is applied).

## Ledger
| ID | Route / component | State | Source | Finding | Fix | Evidence |
|---|---|---|---|---|---|---|
| UC-01 | `NumayaSwitch` (every `ListRow` switch: Settings, Notifications, Privacy, Filters sheet) | off, on, disabled; 1.0 and 2.0 text | Ente Toggle Switch 2482:6644, Selected=False 2482:6647 (recorded: solid #969696 track, white knob, no outline) | The off track was #DEDEDE with a hairline-edged knob, and faded against both the white card (1.3:1) and the #F4F4F4 page | `AppColors.switchOff` → control grey #8A8A8A (ED-06: the nearest token at 3:1; 3.45:1 on white, 3.14:1 on the page). The knob outline is removed (Ente has none) and its shadow kept. On state, geometry, semantics and the full-row target are unchanged; the switch has no gesture of its own, so a row tap toggles once | `component_cleanup_test` (contrast on both surfaces, no outlines); C04, C05, C07 |
| UC-02 | Header actions: `NumayaTopBar`, `TabHeader`, the Discover header | 0, 1 and 2 actions; 320pt at 200% | Ente Header v2 11439:5076 (38pt Icon Button tiles, action group); FD-D1 8pt rule | Gaps varied because each action lays out as a 44pt hit box around a 38pt tile. Discover's 8pt layout gap showed 14pt between tiles. Profile passed its own `SizedBox` as an extra "action", which `TabHeader` spaced again, showing 30pt | New shared `HeaderActions`. `AppLayout.headerActionGap` (8pt visible) with `headerActionLayoutGap` (2pt between hit boxes, which never overlap). All three header families use it, and Profile's stray spacer is gone. The trailing inset was already the 16pt gutter everywhere | `ui_consistency_test` (8pt on Discover and Profile, same trailing edge, 320pt/200% top bar with separate targets and a wrapping title); `final_design_run_test` D1 updated; C01, C06 |
| UC-03 | `NumayaTabBar` (Ente surface) | all four selections; 390 and 320pt; 2.0 text; gesture nav | Brief: 8 inside the outer pill, 4 inside each item, stadium shapes | The bar was a 20pt-corner rectangle, with 38pt square tiles in 48pt slots separated by 34pt gaps | A stadium bar with 8 on all four sides holds four equal item surfaces edge to edge: 48 tall, 48–72 wide, each its own tap target. The selected stadium pill sits 4 in on all sides (a 64 × 40 pill at 390pt). The bar is 64 tall and 304 wide, narrowing items to 68 at 320pt. The screen margin and safe area stay outside the bar, applied once. The filled near-black glyph on the light pill, the grey outlines, the labels and the selected semantics are kept. Events stays gated | `ui_consistency_test`, `discover_match_review_test`, `tabler_mvp_test`, `frosted_navigation_experiment_test`, `final_polish_test`, `foundation_test`; C03, C07 |
| UC-04 | Tab-root header height | Discover vs Likes, Messages, Profile | — | Discover's header was 56pt and the other roots 64, so the header actions jumped about 4.5dp between tabs | `AppSizes.tabHeader` (64), shared by `TabHeader` and the Discover header | C01 |
| UC-05 | Chat header | open conversation | V16 legacy rule | The chat header kept V16's 8pt drop, so Back sat about 7.6dp lower than on every other pushed page | Same height and centre line as `NumayaTopBar` | C02, C06 |
| UC-06 | Country sheet | dial code beside the country name | Type roles | The secondary dial code was forced to 16pt, above the 14pt country name | Body role (14/20), muted; spacing token for the 12pt gap | source scan |
| UC-07 | Visibility status pill | account health header | Pill inset rule (12 × 4) | A one-off 10/6/14/6 inset | `AppLayout.pillInsetX/Y` | source scan |

## Audit coverage (phase 04)
- **Device-reviewed at 1.0 text:** 29 major screens (`Device review 2026-11-07`), plus the 9-screen comparison set.
- **Device-reviewed at 2.0 text:** the comparison set (Discover, Likes, Messages, Profile, Edit profile, Settings ×2, Chat, Filters).
- **Source scan:** every raw `fontSize`, `TextStyle(`, numeric `EdgeInsets` and `SizedBox` in `lib/features`.
- **Kept as meaningful variants:**
  - the person-card name at 28 on a photo vs 32 without one;
  - the Messages list labels in `headerCaps` (Bumble-style list labels, recorded earlier);
  - the prompt answer role in Edit profile and Profile;
  - Large vs Small buttons in the Profile hero;
  - the photo viewer's prev/next buttons (a control row, not a header).
- **Not reached on the device:** the onboarding steps after Photos (they need two photos; see the device review index). They were covered by the existing harness and tests.

## Tools
- adb screencap/pull on the Pixel 10 AVD;
- Python/PIL for the comparison boards;
- `flutter analyze`, `dart format`, `flutter test`, the token check.

Impeccable and break-ui were not invoked: the findings came from the measured comparisons and the source scan, and adverse text is covered by the existing 320pt/200% and worst-case fixtures. Flutter Inspector was not attached; geometry was asserted in widget tests instead.

## Exceptions and open items
- The live Figma re-read is pending authorisation; the knob geometry and Ente's header gap are not verified against Figma.
- The off track is #8A8A8A, one step darker than Ente's #969696 (2.96:1), for 3:1.
- The full-width nav bar at 320pt is not device-checked (the emulator ran at its default 411dp); it is covered by widget tests at 320pt.
- Three-button navigation and the keyboard over the bar were not re-run on the device in this pass.
- Goldens were not regenerated (they are Linux renders of the older look).

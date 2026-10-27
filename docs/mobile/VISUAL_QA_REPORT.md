# Visual QA report: Flutter V16 against the V16 web captures

Branch `experiment/numaya-flutter-v16-complete`. Every comparison below is between a Flutter render and the
matching V16 web capture, both at 393 × 852 (small-screen checks at 375 × 667). These were compared visually, side
by side. **No pixel-perfect parity is claimed.** Flutter renders come from widget-test screenshots (the real app,
the bundled Hanken Grotesk, Noto Color Emoji), not from a phone.

- V16 references: `artifacts/version-16-design-experiment/final-polish/screenshots/states/NNN-*.png`
- Flutter renders: `apps/numaya_mobile/test/screenshots/goldens/` (`NN-*` onboarding and shell, `dNNN-*` dating
  screens named after the V16 capture they match, `qNNN-*` small-screen QA)
- Side-by-side sheets (V16 left, Flutter right, red divider): `docs/mobile/screenshots/v16-compare-*.png`

Regenerate the renders:

```bash
cd apps/numaya_mobile
flutter test --tags screenshots --run-skipped --update-goldens test/screenshots
```

## Screens compared

| V16 capture | Flutter render | Result |
|---|---|---|
| 001, 013, 015, 016, 017, 018 onboarding | `01`–`15` | Matched in the previous pass ([VISUAL_COMPARISON.md](VISUAL_COMPARISON.md)); re-checked after the field changes below: no visible change |
| 019 Discover | `d019-discover` | Matches after fixes D-1, D-2 |
| 021 Discover, you both like | `d021-discover-you-both-like` | Matches (scroll position differs) |
| 022 Discover, actions | `d022-discover-actions` | Matches after fix D-3 |
| 023 Filters sheet | `d023-discover-filters-sheet` | Matches; Flutter adds the live "Show N people" count and an outlined Reset (spec B-34) |
| 024 No one fits | `d024-discover-no-one-fits` | Matches |
| 027 Profile options | `d027-home-profile-options` | Matches without "Share profile" (R-2) |
| 030 / 032 Match | `d030-match`, `d032-match-typing` | Matches after fixes D-4, D-5, D-6 |
| 034 Messages | `d034-chats` | Matches; "Unread" and "Your move" are always 0 because no one replies (honest demo) |
| 037 Messages empty | `d037-chats-empty` | Matches after fix D-9 |
| 038 Conversation | `d038-chat-conversation` | Matches after fixes D-7, D-8; adds the "Demo · saved on this device, not sent" status |
| 042 New match chat | `d042-chat-new-match` | Matches after fix D-8 |
| 044 Chat options | `d044-chat-options-menu` | Matches |
| 045 Unmatch sheet | `d045-chat-unmatch-sheet` | Matches (R-3) |
| 047 Report sheet | `d047-chat-report-sheet` | Matches after fix D-10 |
| 052 Conversation filter empty | `d052-chats-filter-empty` | Matches |
| 054 Likes | `d054-likes` | Matches; no "Activity" filter (Activity not built) |
| 059 Like profile | `d059-like-profile` | Matches after fix D-2 |
| 113 Settings, snooze on | `d113-settings-snooze-on` | Matches after fix D-11; age/distance live in the Filters sheet (R-4) |
| 145–149, 157, 158 small screen | `q145`–`q158` | No overflow, nothing clipped; the match fits above the composer |

## Defects found and fixed

| # | Screen | Defect (Flutter vs V16) | Fix |
|---|---|---|---|
| D-1 | Discover | Photo card was a fixed 4:5 photo plus a band; V16 fills the screen above the tab bar (`100cqh`) with an 8pt margin | `PersonHeroCard(height:)` fills `TabPage.viewportOf`; Discover uses the 8pt `gutterTight` |
| D-2 | Discover, Like profile | The dark name band sat below the photo; in V16 it is inside a 3:4 photo box (at least 420pt) | Band inside the box; 3:4 / 420pt default |
| D-3 | Discover | Pass/SuperSwipe/Like row at 8pt from the edge; V16 insets the action bar a further 8pt | Row padded by `AppSpacing.s2` |
| D-4 | Match | Frame had 20 sharp scallops (`abs(cos)`); V16 `scallop(10, 46.5, 3)` is ten soft lobes | Clipper uses V16's formula |
| D-5 | Match | Portrait fixed at 240pt; V16 is `min(264, 66vw, 32svh)` (25svh on short phones) and its frame is 10% larger than the photo box | Same formula; frame drawn at 1.1× around the box; "you" avatar at −9% / −3% |
| D-6 | Match | Body text 15.5pt, max 260pt, ragged; V16 is 16pt, max 300pt, balanced | `BalancedText.rich` (new), input size |
| D-7 | Conversation | Messages started at the top; V16 anchors the conversation by the composer | Bottom-aligned when there are messages; the new-match intro stays at the top as in 042 |
| D-8 | Chat | Header 8pt higher than V16; "Need an opener?" was ink medium, V16 secondary semibold | Header padded 8pt; label restyled |
| D-9 | Empty states | Card 16pt too high; illustration 132pt, V16 160pt; 20pt gap under the art, V16 12pt | `EmptyState` margin-top 16, art gap 12, illustration 160 |
| D-10 | Report sheet | Fixed at 80% height; V16 sheets are as tall as their content, up to the screen less 8pt | Sheets size to content with that cap; the report form scrolls inside |
| D-11 | Settings | Notifications were "New matches / New messages" with no state; V16 lists New messages, New likes with On/Off underneath | Rows and copy aligned (Activity updates omitted: no Activity) |

## Accessibility defects found by the new guideline tests

| # | Defect | Fix |
|---|---|---|
| A-1 | The tap-to-dismiss-keyboard area was announced as an unlabelled full-screen button (Home, chat) | `excludeFromSemantics: true` |
| A-2 | Text inputs were only 22pt tall as tap targets (the text line) inside 54pt fields | Single-line inputs padded to a 48dp target; the field outline is drawn on top, so focus (2pt) no longer shifts the text by 1pt |
| A-3 | Search field 46pt, composer 44pt (V16 sizes) below Android's 48dp | Both 48dp on Android; the send circle stays 44pt inside a 48dp target; the search clear button has a 48dp target |
| A-4 | Chat "Back to messages" (and Android back) returned to Home after a match | Always goes to Messages |

A-2 and A-3 are deliberate 2–4pt deviations from V16's iOS-sized 44/46pt controls, for Android's 48dp minimum.

## Remaining differences (not fixed, with reason)

| # | Difference | Reason |
|---|---|---|
| R-1 | No Activity tab; Likes has no "Activity" filter | Activity is out of scope (inventory C-5) |
| R-2 | Profile options have no "Share profile" | Sharing needs real profile links; a dead action would mislead |
| R-3 | The "report instead" InfoCard puts its icon beside the title; V16 045 uses an icon column | Same component as 059, where V16 puts the icon beside the title; low impact |
| R-4 | V16 Settings repeats the age and distance sliders | They live in the Filters sheet (B-34); one place to change them |
| R-5 | Sample profiles carry a "Sample profile" badge and footnotes | Required by PRODUCT.md; never present real-looking people as real |
| R-6 | Sample data differs (V16 shows Priya, Jo, Rafa with replies) | A new account starts with no matches and no one replies (C-3, C-4) |
| R-7 | Page titles sit about 3pt higher than V16's | Within tolerance |
| R-8 | Photo placeholder icon in secondary photos is darker and larger than V16's | Low impact; same placeholder everywhere |

## Test evidence

- `flutter test`: 84 passed, 1 skipped (the opt-in capture test).
- Capture tests: `flutter test --tags screenshots --run-skipped --update-goldens test/screenshots`: 3 passed (24
  onboarding/shell + 20 dating + 7 small-screen renders).
- `test/widget/accessibility_test.dart`: `labeledTapTargetGuideline` and `androidTapTargetGuideline` on every
  onboarding screen and on Home, Match, Chat, Messages, Likes and a like's profile; and both journeys at 375 × 667
  with 130% text, which fails on any overflow.

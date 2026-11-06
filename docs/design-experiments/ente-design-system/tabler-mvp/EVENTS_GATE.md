# Events: unavailable in the MVP

Events is **off by default**. Its implementation, data model and demo data are preserved untouched in `lib/features/events/`, so it can launch later without being rebuilt.

## The gate
| Piece | Where | What it does |
|---|---|---|
| `ReleaseScope.events` | `lib/app/release_scope.dart` | `bool.fromEnvironment('NUMAYA_EVENTS')`. It is a compile-time constant and defaults to `false`. |
| `eventsAvailableProvider` | `lib/app/providers.dart` | Reads `ReleaseScope.events`. Every UI check goes through this provider, so tests can override it. |
| `Routes.isEvents(path)` | `lib/app/routes.dart` | Matches `/events`, `/events/...`, `/event` and `/event/...`. Query strings are ignored, because the check uses the path. |

## Behaviour with Events off
- **Tab bar.** The Events branch is not added to the `StatefulShellRoute`, and `HomeShell` builds no Events tab item.
  - Four destinations remain: Home (Discover), Likes, Messages and Profile.
  - Branch indices come from the same list, so no index is left dead or stale.
  - The bar spreads the four tiles to Ente's spacing (`AppSizes.tabGap`), and the gaps shrink on narrow screens.
- **Routes.** The router's top-level redirect sends any Events path to `/home` (Discover). This covers:
  - `/events` and `?view=mine`;
  - `/event/new`;
  - `/event/:id`, `/event/:id/people` and `/event/:id/edit`.

  The event routes stay registered, so a pushed link, a restored location or a deep link is redirected rather than hitting "page not found". `/home` is not an Events path, so the redirect cannot loop. Tests cover both `go` and `push`.
- **Entry points removed:**
  - **Demo Hub:** the Events group (open, full and cancelled events, My events, create).
  - **Design Lab:** the sample tab bar.
  - **Empty conversations (EXP-003):** variant A's "Find an event" button and variant B's Events row. Every variant's other routes are unchanged.
  - **Visibility:** the area-missing hint now reads "Needed for distances to people." (`visAreaMissingPeople`) instead of mentioning events.
- **No startup work.** Events state (`eventsProvider` and the repository) is lazy Riverpod and is only created by Events screens. With the screens unreachable, nothing starts.
- **Date controls kept on purpose.** "Did you meet?" in the chat menu and the Safety tips calendar row use `NumayaIcons.event` (a calendar glyph) for dates between matches. They are not the Events feature.

## Re-enabling Events later
1. Build with `--dart-define=NUMAYA_EVENTS=true`. For example: `flutter run --dart-define=NUMAYA_EVENTS=true`, or `flutter build apk --dart-define=NUMAYA_EVENTS=true`.
2. To make it the default instead, change `bool.fromEnvironment('NUMAYA_EVENTS')` to `bool.fromEnvironment('NUMAYA_EVENTS', defaultValue: true)`.
3. Everything above returns:
   - the tab, as the second destination;
   - the routes, the Demo Hub group and the EXP-003 Events options;
   - the original visibility copy.
4. The Events suites already run with the gate on: `test/widget/events_test.dart` and the tests that use `overrides: eventsOn` in `test/helpers/test_app.dart`. `tabler_mvp_test` checks that the tab returns.

# MVP Focus V5: scope delta

Events and Health are deferred. The Events PRD and earlier Events records are future-roadmap history.
Regression evidence for all rows: `test/widget/mvp_scope_test.dart`.

`eventsAvailableProvider` defaults to `ReleaseScope.events` (off). Off, the Events tab and every Events route are not built.
To bring Events back for an internal build: `--dart-define=NUMAYA_EVENTS=true`. Tests for the dormant module pass the `eventsOn` override.

| Old entry point | New behaviour | Source | Evidence |
|---|---|---|---|
| Events tab in the bottom bar | Removed. Four destinations by identity (`AppTab`), not position | `home_shell.dart`, `router.dart` | "four destinations" test |
| Direct `/events`, `/events/mine`, `/events/e/...`, `/events/r/...`, `/events/notice/...`, `/events/met/...`, `/events/proposals`, `/events/propose/...` | Lands on Discover | `Routes.isDeferredEvents`, router redirect | "every deferred Events link" test |
| Old `/event`, `/event/new`, `/event/:id` | Lands on Discover | Same | Same |
| `/staff...` internal tools | Lands on Discover | Same | Same |
| Deferred link while signed out | Discover, then Welcome, no loop | Router redirect | "signed out" test |
| Restored navigation state or a notification link | Passes through the same redirect | Router redirect | Same mechanism as direct links |
| Empty Chats "Find an event" | Not offered | `empty_conversations.dart` through the provider | "empty Chats" test |
| Demo Hub Events scenarios and staff tools | Hidden | `demo_hub_screen.dart` | Provider gate |
| Visual Lab event groups and previews | Hidden and guarded | `visual_lab_screen.dart`, `isDeferredLabGroup` | Router redirect |
| Offline note mentioning joining events | Copy removed | `app_en.arb` | "no copy" test |
| `/profile/health`, `/profile/health/about`, `/profile/insights`, `/profile/visibility` and its child | Lands on Profile with no note | `router.dart` | "retired Health" test |
| "Insights are no longer part of Numaya" note on Profile | Removed, including the `?notice=` path | `profile_screen.dart`, `routes.dart` | "retired Health" test |
| Paywall `?feature=insights` | Shows the general paywall | `router.dart` | "no copy" test |

Kept under the same name on purpose: `features/health/domain` still computes Profile setup completion. It shows no Health feature or advice to members.

No Android permission or initializer was Events-only. The manifest has no deep-link filter for these paths.

## Tests changed, with the reason
| File | Change | Reason |
|---|---|---|
| `events_mvp_test`, `ente_v4_test`, `system_states_test` offline case, `visual_lab_v2_test` preview sweep | Pass `eventsOn` | They exercise the dormant module, which is retained |
| `tabler_mvp_test`, `ui_consistency_test`, `discover_match_review_test`, `frosted_navigation_experiment_test` | Four tabs instead of five | New scope |
| `visual_lab_v2_test` Health case | Asserts the Profile destination, no note | New behaviour |

No test was skipped or deleted.

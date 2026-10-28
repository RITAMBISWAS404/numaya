# Events and Profile & visibility: roadmap

Working record for branch `experiment/numaya-events-account-health` (from
`experiment/numaya-discovery-complete` @ `02e5907`). On a restart, check `git log --oneline -5` and
`git status`, then continue from the first batch not marked Done.

Baseline on `02e5907`:
- 167 tests passed, 5 skipped;
- analyzer clean;
- captures 7 passed.

## Batches

| # | Batch | Status | Output | Tests | Commit |
|---|---|---|---|---|---|
| 1 | Competitive research and decisions | Done | EVENTS_RESEARCH, ACCOUNT_HEALTH_RESEARCH | — | with 2 |
| 2 | Event inventory and navigation | Done | EVENTS_SCREEN_INVENTORY (Events tab, EN-1), ACCOUNT_HEALTH_METRICS | — | docs commit |
| 3 | Event discovery and detail | Done | `lib/features/events/` (model, demo repository, controller), Events tab (5th tab), Explore, filters sheet, details | `events_controller_test` (20), `events_test` (12) | see git log |
| 4 | RSVP, saved, My events | Done | Join / waitlist / leave / question sheet / failure + retry; My events (Going, Waitlist, Saved, Hosting, Past) | as above | with 3 |
| 5 | Create, edit, host management | Done | Create / edit / draft / preview / publish / cancel; Who's going with remove and move up | as above; 199 passed, 6 skipped | with 3 |
| 6 | Profile & visibility model and metrics | Done | `lib/features/account_health/application/visibility_report.dart`: pure `VisibilityReport.of`, demo notice and insights sources, live provider | `visibility_report_test` (15) | see git log |
| 7 | Overview, suggestions, How this works | Done | `/profile/visibility`, `/profile/visibility/about` | `visibility_test` (7) | with 6 |
| 8 | Integration (profile, settings, Demo Hub) | Done | Profile tab row with status; Settings › Visibility row; Demo Hub Events and Profile & visibility groups; sign-out and demo reset clear both; Settings location no longer shows a sample area as yours | 221 passed, 7 skipped | with 6 |
| 9 | Visual QA, accessibility, regression, reports | Pending | | | |

## Blocked or limited

- **Official help pages could not be read.** The session's network policy blocks:
  - `help.hinge.co` and `hinge.co`;
  - `help.tinder.com`;
  - `help.meetup.com`.

  The Eventbrite help and Bumble guidelines were not attempted after those failures.
- **No Android SDK.** No APK and no device run.

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
| 3 | Event discovery and detail | Pending | | | |
| 4 | RSVP, saved, My events | Pending | | | |
| 5 | Create, edit, host management | Pending | | | |
| 6 | Profile & visibility model and metrics | Pending | | | |
| 7 | Overview, suggestions, How this works | Pending | | | |
| 8 | Integration (profile, settings, Demo Hub) | Pending | | | |
| 9 | Visual QA, accessibility, regression, reports | Pending | | | |

## Blocked or limited

- **Official help pages could not be read.** The session's network policy blocks:
  - `help.hinge.co` and `hinge.co`;
  - `help.tinder.com`;
  - `help.meetup.com`.

  The Eventbrite help and Bumble guidelines were not attempted after those failures.
- **No Android SDK.** No APK and no device run.

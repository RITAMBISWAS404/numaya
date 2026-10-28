# Profile & visibility QA report

Branch `experiment/numaya-events-account-health`. Rules and sources are in
[ACCOUNT_HEALTH_METRICS.md](ACCOUNT_HEALTH_METRICS.md); research is in
[ACCOUNT_HEALTH_RESEARCH.md](ACCOUNT_HEALTH_RESEARCH.md).

**Nothing in this pass ran on a phone or emulator.**

## What was built

| Part | Where |
|---|---|
| Rules | `lib/features/account_health/application/visibility_report.dart`: `VisibilityReport.of(...)` is a pure function of its inputs; `visibilityReportProvider` feeds it live state, so every edit, snooze, verification or filter change recalculates it immediately |
| Demo sources | `accountSignalsProvider`: account notices (none / notice / restricted / unavailable) and activity availability (live / stale / unavailable), set from the Demo Hub and labelled in the UI |
| Screens | `/profile/visibility` (overview) and `/profile/visibility/about` (How this works) in `presentation/visibility_screen.dart` |
| Entry points | Profile tab › Your profile › **Profile & visibility** (shows the current status); Settings › Visibility › Profile & visibility; Demo Hub group |
| Added to the dating controller | `likesReceivedWithin`, `matchesWithin`, `conversationsWithin`, `candidateCount` |

### Real versus demo data

| Section | Data |
|---|---|
| Visibility: paused, Incognito, Discover requirements | The member's own settings and entries (real for this device) |
| Visibility: notices and restriction | **Demo** notice source |
| Profile completeness | Real (`ProfileCompletion`, the same value as the Profile tab ring) |
| Discovery setup: area, who to meet | Real |
| Discovery setup: filters fit n of m | Real filters over the **sample** deck |
| Verification | Phone: by code (simulated SMS). Photo: **simulated** review |
| Activity counts | **Sample** likes, matches and messages; the section carries a "Sample data" badge |
| Profile views | Not measured: shown as "Not measured", no number |

## Tests

| File | Count | Covers |
|---|---|---|
| `test/unit/visibility_report_test.dart` | 15 | each visibility rule and their order (restricted beats paused; requirements named; unavailable source is "can't check", never visible; Incognito limited; a notice keeps the profile visible); activity never decides status (zero, stale, unavailable); completeness equals the shared value and rises by one sixth with a bio; at most five suggestions; filters flagged only when nobody fits (and ranked before optional parts); verification suggested only when not started or retryable; **no copy mentions a shadowban, ranking or deprioritising, and the only "score" says there isn't one** |
| `test/widget/visibility_test.dart` | 7 | reached from the Profile tab with its status, sample data labelled, views "Not measured"; snooze → Paused with end date → Resume updates Discover and the status; completeness recalculates after a bio change, a suggestion opens Edit profile and back returns; notices (can't check → Try again, a notice stays visible, restriction → appeal screen); activity live / stale / unavailable; How this works; Demo Hub notice and activity rows |
| `test/widget/accessibility_test.dart` | (routes added) | tap targets, labels and 130% text at 375 × 667 for both pages |

Results are shared with the Events report: format clean, analyze clean, `flutter test` **221 passed, 7
skipped**, captures 9 passed.

## Captures

`apps/numaya_mobile/test/screenshots/goldens/h01`–`h10`. Contact sheets:
`docs/mobile/screenshots/visibility-1.png` and `visibility-2.png`.

| Capture | State |
|---|---|
| h01 | Profile tab entry with "Visible" |
| h02–h05 | Overview: visible, completeness and discovery, verification / notices / activity, suggestions |
| h06 | Paused, with the end date and Resume |
| h07 | Hidden by a (demo) notice: Action needed, Review and appeal |
| h08 | Notice source not answering: Can't check right now |
| h09 | A notice that keeps the profile visible; activity unavailable |
| h10 | How this works |

## Defects found and fixed

| # | Found by | Defect | Fix |
|---|---|---|---|
| HQ-1 | Unit test | With five suggestions max, "Review your filters" (Discover would be empty) could be pushed out by optional profile parts | Ordered right after the Discover requirements; METRICS §8 updated |
| HQ-2 | Captures h03 vs Settings | **Settings showed "Hackney, London (sample)" as the current location when the member never chose an area**, while the dashboard said Not set | Settings shows "Not set" and opens the area picker; both read the same value |
| HQ-3 | Capture h01 | The row used the crossed-eye icon, which reads as "hidden" even when visible | Compass icon |

## Not tested or not determinable

- **Device:** TalkBack reading order across the long overview; large text beyond 130% on a phone.
- **Real backend states** (notices, enforcement, analytics) can't be tested here. The UI covers the
  states the sources may report, using the demo source.
- **No persistence:** notice and insight settings reset with the demo data or on sign-out.
- **By design, the dashboard can't determine:**
  - how other people's Discover orders profiles;
  - how many people saw a profile;
  - why a person did or didn't like someone.

# Final refinement and QA pass

**Run:** 2026-11-04, cloud container (Linux), Flutter 3.47.8 and Dart 3.13.7.

| Item | Value |
|---|---|
| Worktree | `/home/user/numaya-overnight` |
| Branch | `experiment/numaya-overnight-polish` (**local only**, not on GitHub) |
| Base and HEAD | `6b23c85aa7be16b5cfeaebdea06c36a9090243b2` (`wip/frosted-navigation-handoff`, live on GitHub) |
| Candidate | the overnight working state (uncommitted) plus this pass's fixes. Nothing staged, committed or pushed |
| Other checkout | `/home/user/numaya` (`experiment/impeccable-visual-refinement`, 14 uncommitted web files): untouched |

**Evidence labels:** every image is a **golden-harness render** (`flutter test`, Linux, real fonts,
393×852 @2x unless named). **No emulator and no physical device:** `flutter devices` lists only
Linux desktop, the app has no Linux target, and the Android SDK host `dl.google.com` is denied by
the network policy.

## Baseline (the candidate before this pass)
| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` | **312 passed, 14 skipped, 0 failed** |
| Full capture (`--tags screenshots --run-skipped --update-goldens`) | 20 passed. One capture differed from the overnight render with no code change: `m01-design-lab` (F-01) |

## Findings and fixes
| # | Severity | Route / evidence | Root cause | Expected | Fix | Status |
|---|---|---|---|---|---|---|
| F-01 | Medium (test integrity) | `/design-lab`, golden `m01` changed between runs ("TUE 3 NOV · 23:32" vs "WED 4 NOV · 03:01") | `DesignLabScreen` read `DateTime.now()`; tests pin `clockProvider`, but the Lab ignored it | Deterministic golden | The Lab uses `ref.watch(clockProvider)` (now a `ConsumerStatefulWidget`) | Fixed; regression test; `artifacts/final-qa/m01-{before,after}-crop.png` |
| F-02 | Medium (layout) | `/profile/settings` with a recovery email, golden `p05`: label "Recovery / email" and detail squeezed into a narrow column | `ListRow` let the trailing value take up to 60% of the row, even when the row has a detail line | Label on one line; the value readable | A value wider than 40% of the row, on a row with a detail, stacks under the label. Short values stay trailing. Informed by [Family](https://mobbin.com/screens/ea652c12-4d3b-4243-a8bb-842f19f12d1e) (email under the row label) and [Expedia](https://mobbin.com/screens/6fada74a-65ca-4c4b-9165-3aae27cbf940) (label above the email) | Fixed; regression test proven to fail without the fix; `artifacts/final-qa/before-after-p05.jpg` |
| — | Not a defect | `n07`, `v12`: the "Hostin…" filter pill cut at the edge | Intended edge-to-edge horizontal scroll (signals more pills) | — | — | Kept |

No blockers were found. Type review:
- `AppTypography.body` is 14/20, used through 65 call sites.
- The intended exceptions hold:
  - `row` 16/22 (list and option rows);
  - `input` 16/22 (multi-line fields 16/24);
  - `promptAnswer` 20/27;
  - headings unchanged.
- The theme's `bodyMedium` (the default for bare `Text`) was already `bodySm` 14/20.
- No accidental overrides were found. The search field's `body.copyWith(fontSize: 16)` is typed
  text, consistent with OP-03.

## Behaviour and accessibility matrix (all: method = widget test, platform = Flutter test renderer, demo data)
| Area | Scenario | Expected | Actual | Evidence |
|---|---|---|---|---|
| Discover | Swipe right likes, left passes; a double tap decides once; a button during a swipe exit does not decide again; undo one step | One decision per person | Pass | `final_polish_test`, `discovery_test` |
| Discover and events | Filters: no one fits, then widen; seen everyone, then show again; Reset (Discover filters and event filters) | List, count and empty states correct | Pass | `discovery_test`, `full_app_journeys`, `events_test` |
| Profile | Edit, preview, Opening Moves, photos (at least 2 kept) | Saved locally, preview matches | Pass | `full_app_journeys`, `photo_options` |
| Likes and match | Grid, Like back opens the match, Pass removes the tile; empty state routes to Home | — | Pass | `dating_test` |
| Chat | Long caption, pending photo, keyboard up at 200% text; **rapid double tap on Send sends one message** | — | Pass | `chat_media_test`, `overnight_polish_test` (new) |
| Chat | Unmatch; "Did you meet?"; report asks where | — | Pass | `full_app_journeys` |
| Safety | Report and block from a profile, the chat menu and an event; blocking removes the person from Home | — | Pass | `dating_test`, `events_test` |
| Account | Delete (cancel, then confirm); restore by signing in again; snooze and resume; sign in again with a code at 200% | — | Pass | `system_states`, `recovery_email`, `full_app_journeys` |
| Events | Join failure offers Try again; create (errors first, then publish); filters | — | Pass | `events_test` |
| Navigation | Android back pops a step, returns a chat to Messages and returns to Home before leaving; tabs by tooltip | — | Pass | `full_app_journeys`, `onboarding_flow` |
| Keyboard | Tapping outside dismisses; **keyboard over a tab screen with the frosted bar keeps the search field visible** | — | Pass | `system_states`, `overnight_polish_test` (new) |
| Errors and offline | Offline banner over Home and chat at 200%; Discover error retry | — | Pass | `system_states`; capture `x12` |
| Large text | 34 full-app routes at 320/375/390/430pt × 100/130/200%; 7 gap routes at 320pt and 200% | No layout exception | Pass | `size_matrix`, `overnight_polish_test` |
| Targets and labels | Android 48dp and labelled tap targets on onboarding, dating and 34 routes | — | Pass | `accessibility_test` |
| Reduced motion | Durations and sheets collapse under Remove Animations | — | Pass | `motion_test` |
| High Contrast | Frosted bar falls back to the opaque pill, with no highlight | — | Pass | `frosted_navigation_experiment_test`, `overnight_polish_test` |
| Contrast | Text 4.5:1, marks 3:1, including composites | — | Pass | below |
| TalkBack, VoiceOver, focus order on device | — | — | **Unverified** | Needs a device |
| Gesture vs three-button navigation, scroll performance, heat | — | — | **Unverified this pass** | The Windows emulator results from 2026-11-04 are historical (frosted README) |
| Deep links | `go(path)` to every route in the sweeps | Renders | Pass (in-app router only) | `route_sweep`. the Android manifest declares no link intents (`android:scheme`: 0) |

## Contrast of translucent composites (computed)
| Pair | Composite | Ratio |
|---|---|---|
| Photo badge: `brandText` on opaque white | `#5B4BB0` / `#FFFFFF` | 6.82 |
| Swipe-stamp disc: white 90% over black, ink icon | `#E6E6E6` | 14.20 |
| The same disc over brand purple | `#F1EFF9` | 15.57 |
| Glass idle icon over black (rendered, `fn01`) | `#CCCCCC` | 5.46 |
| Glass selected icon | `#5B4BB0` / `#F1EFF9` | 6.00 |

The app has no dark theme, so only light was tested.

## Results after this pass
| Check | Result |
|---|---|
| Format | exit 0 |
| `flutter analyze` | No issues found |
| Token check | Dart tokens are up to date |
| `flutter test` | **316 passed, 14 skipped, 0 failed**. The 4 new tests are in `overnight_polish_test`: ListRow stacking, double Send, Lab clock, keyboard over a tab. The 14 skips are the opt-in screenshot and comparison files. **No pre-existing failures.** |
| Captures | 20 passed. Changed against the baseline: only `m01-design-lab` (F-01) and `p05-settings-recovery-email` (F-02), both reviewed. 33 renderer-only goldens restored to their committed versions |
| Integration tests (`integration_test/`) | **Not run:** they need a device |
| Web (`npm run check`, `npm run test:e2e`) | **Not run:** no web file changed, and the worktree has no `node_modules` |
| APK | **Not built:** no Android SDK. Next action: on Windows, `flutter build apk --debug`, or allow `dl.google.com` in this environment's network settings |

## What can ship
| Target | Decision | Basis |
|---|---|---|
| **Internal demo** | **Go once an APK is built on Windows** | Every UI flow passes on demo data, and the demo is labelled as such. Blocked here only by the missing SDK |
| **Staging** | **No-go** | There is no backend or production configuration to stage against |
| **Public release** | **No-go** | See below |

| Release prerequisite | Status | Evidence | Owner / next action |
|---|---|---|---|
| Supported-device behaviour (Android 12+, iOS) | Unverified | No device this pass | Owner: the Windows emulator and a Samsung Android 12; a Mac for iOS |
| Signing | Failed | `android/app/build.gradle.kts` signs release with the debug key | Engineering: an upload key and Play App Signing |
| Production configuration | Failed | No environments, API base URL or crash reporting | Engineering |
| Real authentication | Failed | Phone codes are simulated (`DemoAuthRepository`) | Backend |
| Real data, matching, messaging | Failed | All local demo data; no networking dependency | Backend |
| Reporting and blocking | Partial | The UI works and is tested; nothing is sent anywhere | Backend and Trust & Safety: report intake and review |
| Moderation | Failed | No queue or reviewer tooling (required by the Play UGC policy) | Trust & Safety |
| Account deletion | Partial | The UI flow and restore are tested; no server deletion | Backend |
| Age eligibility | Partial | The birthday gate blocks under-18s in onboarding (`/setup/underage`); no verification beyond the entered date | Product and legal |
| Privacy | Failed | No privacy policy URL or data-safety declaration | Product and legal |
| Live backend and operations | Not applicable yet | No backend exists | — |

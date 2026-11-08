# Execution checklist: requirement → evidence

Screens = PNGs in `Desktop\Numaya Events Review\2026-11-08 1720\` (real emulator captures; `internal/`
holds the demo-role tools). Tests are under `apps/numaya_mobile/test/`.

## Navigation and removal
| Requirement | Status | Evidence |
|---|---|---|
| Five tabs Discover / Likes / Chats / Events / Profile; Events 4th | Done | 01; `tabler_mvp_test` five destinations; `discover_match_review_test` geometry; `ui_consistency_test` UC-03 at 320pt |
| Health and Insights removed; dating, streaks, wallet kept | Done | 05; [HEALTH_REMOVAL_AUDIT.md](HEALTH_REMOVAL_AUDIT.md) |
| Old Health/Insights/visibility links fall back safely | Done | 06; `visual_lab_v2_test` "Health/Insights removed" |

## Events PRD
| ID | Requirement | Status | Evidence |
|---|---|---|---|
| E01 | Feed: city, date, category, sample label, My events, empty city, suggest row (O1) | Done | 07, 08, 09; `events_mvp_test` E01 |
| E02 | Detail: when/where, host, Free, availability, report; full state with alternatives, no waitlist | Done | 10, 22 |
| E03 | Reserve: acknowledgement, event-only discoverability (off by default), confirmed with reference; duplicate-safe; uncertain → reconcile; offline error; ineligible | Done | 11, 12, 23; `events_mvp_test` (reserve once, uncertain, offline); Demo Hub `demo-ev-ineligible` |
| E04 | My events: upcoming / past / cancelled with reasons; update needing attention | Done | 13, 20, 21; `events_mvp_test` E04 |
| E05 | Reservation: status, reference, directions/calendar (demo), discoverability, cancel with confirmation (idempotent) | Done | 14, 19; `events_mvp_test` cancel |
| E06 | Notices: ordinary, material change with before/after and deadline, reconfirm/decline, superseded, cancellation, push-failed record | Done | 15, 16, 17, 18; unit: supersession, deadline expiry, decline |
| E07 | People I met: checked-in + opted-in only, private interest, 3 per event, pass, 7-day window, withdraw | Done | 24, 25; unit: listing, allowance, window, consent withdrawal |
| E08 | Mutual: through the existing chat rules; never reopens archived chats or resets timers; block/unmatch prevail | Done | 26, 27; unit: created / existingArchived / restricted |
| S01 | Report or get help, emergency note, on-device record | Done | 28 |
| M01/M02 | Proposal form and status, labelled "Pending decision O1" | Done (proposal; O1 OPEN) | 29, 30 |
| H01–H04 | Internal demo role: queue, review/publish (named host and reviewer, idempotent), check-in, announce/change/cancel | Done (demo role only) | internal/31–34; unit: publish, cancel idempotent, change under 2 h refused, attendance needs active reservation |

## Visual Lab selections
| Selection | Status | Evidence |
|---|---|---|
| New matches A: squircle ring, 3:4 portrait; likes tile removed | Done | 04; `profile_review3_test` UI-033/034, `visual_lab_v2_test` R01/R02 |
| Conversation O | Done | 04 |
| Compliment O: no inline buttons, chevron, tap opens detail; Likes/Compliments pills | Done | 02, 03; `visual_lab_v2_test` R03, `mvp_screens_test` R03 |
| Like tile A | Done | 02 |
| Profile header A: verification pill above name; subtler gradient (also Discover) | Done | 01, 05 |
| Setup D, streak O, wallet A | Done | 05 (streak and wallet sit lower on Profile; not in frame) |
| Plan O, status O (filled icons), empty O | Done | `lab_registry.dart` `proposed`; empty O seen in 09; plan and status not separately captured |
| Prompt O: purple Compliment button, white icon, bottom-right inside padding | Done | 01 |
| Discover photo O: buttons inside card padding; concentric radii | Done | 01; `final_polish_test` nested corners |
| Discover screen O; motion M1 | Done | 01; M1 from the registry (motion is not visible in stills) |
| Insights selections | Obsolete (Insights removed) | — |

## Checks
`flutter analyze`: no issues. `flutter test`: 566 passed, 42 skipped (superseded, with reasons; see
HEALTH_REMOVAL_AUDIT.md). Emulator journey: `integration_test/events_review_test.dart`, 34/34
captures, no skipped steps.

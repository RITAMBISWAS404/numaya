# Events MVP + approved visual refinements (2026-11-08)

Branch `experiment/numaya-events-selected-ui-20261108-1629` (from the selections branch; checkpoint
`bdaa659`). Source: the owner's `NUMAYA_EVENTS_COFOUNDER_PRD.md` and the Visual Lab summary
`numaya-visual-lab-summary-vl2-8510778-2026-11-08.txt`. A **frontend demo**: deterministic, local,
no backend, no real events, no payments. Not merged anywhere.

- [Execution checklist](EXECUTION_CHECKLIST.md): every requirement and its evidence
- [Reference log](REFERENCE_LOG.md): Mobbin and Figma (Ente) references used
- [Health/Insights removal audit](HEALTH_REMOVAL_AUDIT.md) (PRD D4)
- [Limitations and live-launch decisions](LIMITATIONS.md) (O1, O2, D1–D7)

## Code map
| Area | Where |
|---|---|
| Domain (lifecycle, reservation, attendance, consent, notices, proposals, policy) | `apps/numaya_mobile/lib/features/events_mvp/domain/` |
| Controller (all rules; clock-injected) | `lib/features/events_mvp/application/events_mvp_controller.dart` |
| Member screens E01–E08, S01 | `lib/features/events_mvp/presentation/events_feed_screen.dart`, `event_detail_screens.dart`, `my_events_screens.dart` |
| Proposal M01/M02 (O1 OPEN) and internal H01–H04 | `presentation/proposal_staff_screens.dart` (`/staff`, demo sign-in only, banner "Internal demo role") |
| Event connection into existing chat | `DatingController.connectFromEvent` (`EventConnection`) |
| Five tabs | `lib/features/home/presentation/home_shell.dart`; branches in `lib/app/router.dart` |
| Health/Insights fallback | `/health`, `/insights`, `/visibility` → `/profile?notice=unavailable` |
| Owner's Visual Lab selections | `lib/features/lab/lab_registry.dart` (`proposed` = owner choice) |
| Tests | `test/unit/events_mvp_controller_test.dart`, `test/widget/events_mvp_test.dart` (+ updated suites) |

# Experiments: layout alternatives for selection (alignment V3)

Track A fixes ([ISSUES.md](ISSUES.md)) are in every option. Track B alternatives live in the Visual
Lab registry (`lib/features/lab/lab_registry.dart`, ids `ea-*`) with **proposed = O**: release
builds and the default demo render O until the owner selects. Same fixtures, viewport and text
scale per group; all variants pass the 320pt / 200% text sweep (`visual_lab_v2_test`).

| Group | User task | Problem | Axis | Options | Expected benefit / tradeoff | References | Dependencies |
|---|---|---|---|---|---|---|---|
| `ea-event-card` | Pick an event from the feed | Tall cover-led cards, two per screen; Free and availability as equal badges | Density, hierarchy | O cover-led · A compact row · B date-led · C cover + date chip | A doubles events per screen, loses art; B calendar scan, no imagery; C fewer labels, same height | Apple Music, Lightyear, Swiggy (Mobbin) | Also renders E02 "Other events" |
| `ea-event-filters` | Narrow by city, date, activity | Three header rows push the first event down | Header density | O field + two pill rows · A three disclosure chips · B city chip + date pills | A one row, one more tap; B two rows | DICE, StubHub | Independent |
| `ea-event-action` | Reserve from the detail page | Availability not at the point of action | Information at action | O full-width button · A summary + compact button · B availability line above | A departs from Ente Button Large; B keeps it, taller bar | Insight Timer, Trainline | Reserve state only |
| `ea-met-card` | Decide on people met | (Pairing fixed for all.) How much each person leads | Imagery vs density | O row + paired buttons · A photo card · B compact row, icon actions | A most personal, one per screen; B whole list, icons carry the action | Hinge, Bumble | Same private actions and states |

Not varied (no real question): reservation card, notice actions (already Ente stacked), profile
summary (owner's header A selection stands).

## Promotion (later, only on the owner's export)
1. Validate the JSON: schemaVersion 1, reviewId `ea3-ba3a6fc-2026-11-08`, codeCommit, known ids.
2. Set each selected group's `proposed` to the chosen id; apply notes; keep unselected at O.
3. Surface dependency conflicts; run analyze, the full suite and the 320pt/200% sweep.
4. Recapture (`ente_alignment_review_test`), rebuild the APK, update the handoff, push.
5. Keep this gallery as the audit trail.

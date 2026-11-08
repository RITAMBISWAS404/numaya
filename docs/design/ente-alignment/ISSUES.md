# Issue register (alignment V3)

Severity: **High** = wrong behaviour or misleading UI; **Medium** = visible inconsistency;
**Low** = polish. Evidence paths are inside the review folder.

| ID | Sev | Scope | Issue | Fix | Evidence | Status |
|---|---|---|---|---|---|---|
| EA-B01 | High | App-wide (6 call sites) | Small buttons in `Expanded` stayed content-width: paired actions floated apart (owner's complaint) | `NumayaButton.expand` for small; `NumayaButtonGroup` (equal, 12pt, stacks) | qa/04, qa/05, qa/large-360-met-actions; tests | Fixed |
| EA-B02 | Medium | Cancel reservation, Compliment dismiss ×2 | Confirm sheets: main action same weight as Cancel / Primary purple for a removal | Critical (solid red) on top, Cancel secondary | qa/07 | Fixed |
| EA-S01 | Low | All sheets | Sheet corners 24 vs Ente xl 20 | `MonoRadii.sheet = 20` | qa/06, qa/07 | Fixed |
| EA-L01 | Medium | City picker (and any picker) | Selected city showed "✓" text **and** a chevron | `ListRow.selected` tick, no chevron | qa/06 | Fixed |
| EA-C01 | Medium | App-wide states | Status colours were not the owner's anchors; no semantic badges | Anchors + derived roles; badge tones | qa/01–02; tests | Fixed |
| EA-C02 | Low | Banners | Status icons used text roles | Icon roles | qa/08, qa/09 | Fixed |
| EA-Q01 | — | Capture harness | ANR "System UI isn't responding" overlay on the software-GPU emulator (recurs after boot); the guard's bounds parsing was broken | Dismiss Wait, verify 60 s, guard fixed (`sed`) | none in final captures | Fixed (recurrence documented) |
| EA-Q02 | — | Capture evidence | First run: filter screens kept feed scroll; offline shot hit an already-reserved event | Scroll to top; open event | screens/ea-event-filters, qa/08 | Fixed |
| EA-X01 | Low | Filter alternative B | Used the multi-select interest chip for a single choice | `ViewTabs` pills | screens/ea-event-filters__B | Fixed |
| EA-O01 | Low | Sign-out sheet | Uses Primary, not Critical | Not changed: reversible (sign in again) | — | Considered |
| EA-O02 | Medium | Switch | Off track 1.45:1 | Not changed (SW-01 owner decision) | — | Logged |
| EA-U01 | — | Toast, action sheets, dark mode | Not inspected in depth this pass | — | — | Unverified |
| EA-U02 | — | Discover, Likes, Chats, Profile, onboarding | Screen-by-screen re-audit not repeated; only shared-primitive changes propagated and the suite re-run | — | tests 575 passed | Partial |

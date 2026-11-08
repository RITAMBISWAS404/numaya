# Requirements register (package 10), execution ledger

DONE only with evidence; PARTIAL / UNVERIFIED stated plainly.

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| R01 | Verify state; checkpoint, branch, remote backup | DONE | `a000ff3` = origin; tag `checkpoint/pre-ente-alignment-20261108-1829` and branch pushed; DELIVERY.md |
| R02 | Inventory both Figma pages | DONE (sections) | COMPONENT_MAP "Page inventory" |
| R03 | Current vs obsolete vs experimental | DONE | COMPONENT_MAP (rules page: "not precedent") |
| R04 | Map variants to Flutter code and call sites | DONE for used families; toast/action sheet UNVERIFIED | COMPONENT_MAP C01–C17 |
| R05 | Preserve purple, fonts, 15px, Tabler, prior selections | DONE | No typography/icon/brand change; lab `proposed` of earlier groups unchanged |
| R06 | Exact anchors + derived roles | DONE | FOUNDATIONS.md; `monochrome_tokens.dart` |
| R07 | Computed contrast; no white-small-text failure | DONE | FOUNDATIONS table; EA-C01 tests |
| R08 | Paired buttons: width, gap, hierarchy, large-text fallback | DONE | EA-B01/B02; qa/04, 05, 07, large-360-met-actions |
| R09 | Search/filter/pill composition | PARTIAL | Picker tick fixed; filter density offered as `ea-event-filters`; no search exists in Events |
| R10 | Cards, groups, spacing | PARTIAL | Event and People I met cards aligned and varied; no app-wide spacing re-audit |
| R11 | App bar, sheets, five-tab safe area | DONE (sheets, nav) | EA-S01; qa/11; UC-03 test |
| R12 | Filled status icons; icon/text geometry | DONE (banners, badges) | qa/01–02, 08–09 |
| R13 | Screen-by-screen audit Events + dating | PARTIAL | Events captured at default and 360dp/200%; dating flows covered by tests, not re-captured (ISSUES EA-U02) |
| R14 | Skills inventory; install relevant missing | PARTIAL | Inventory done; nothing installed (SKILLS_AND_REFERENCES) |
| R15 | Two-component pilot first | DONE | Paired actions + event card, then propagated |
| R16 | Mobbin references per decision | DONE | SKILLS_AND_REFERENCES; gallery shows them per group |
| R17 | Alternatives in the Flutter Lab | DONE | 4 groups, 13 options, `proposed = O` |
| R18 | Choices-only gallery, crops/screens, notes, stable ids | DONE | Review folder index.html |
| R19 | Persist/export/import; zero-selection; dependencies | DONE | VALIDATION gallery row |
| R20 | Preserve product/privacy rules; no Health | DONE | No controller/policy changes; full suite passes |
| R21 | Plan/Status evidence; Events large text | DONE | qa/10 plan, qa/08–09 status, qa/large-360-* |
| R22 | Navigation overlap; primary actions reachable | DONE for captured screens | qa/11; pinned footers in screens/* |
| R23 | Illustration placeholders; restrained motion | DONE (unchanged) | No motion added; placeholders kept |
| R24 | Analyze/tests; skips explained | DONE | VALIDATION.md |
| R25 | APK build/install, SHA, paths | DONE | DELIVERY.md |
| R26 | Handoff, push, verify remote; disclose local-only | DONE at final commit | handoff files; remote SHA checked after push |

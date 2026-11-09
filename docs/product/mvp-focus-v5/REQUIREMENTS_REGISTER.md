# MVP Focus V5 requirements register

App source: `36407b3`. Pre-V5 checkpoint tag: `checkpoint/pre-mvp-v5-20261109-2303` (`ca0ff57`). Device evidence is from the Pixel 10 AVD emulator.

| ID | Requirement | Affected | Commit | Evidence | Status | Remaining action |
|---|---|---|---|---|---|---|
| M01 | Latest work preserved, checkpoint pushed, isolated branch | Git | `ca0ff57` tag | `git ls-remote` | passed | None |
| M02 | Events removed and direct routes guarded | Shell, router, Demo Hub, Chats empty | `2cdb054` | `mvp_scope_test` | passed | None |
| M03 | Health removed across routes, benefits, copy | Router, Profile, paywall | `2cdb054` | `mvp_scope_test` | passed | None |
| M04 | Navigation rebalanced | `AppTab`, home shell | `2cdb054`, `57dd78e` | Tab tests | passed | None |
| M05 | Scope, docs and capture inventory reconciled | Docs, harness | `36407b3` | `MVP_SCOPE`, `SCOPE_DELTA`, `COVERAGE` | passed | None |
| C01 | References and Numaya policy documented | Compliments | `16d5562` | `COMPLIMENT_CONTRACT`, `REFERENCE_LOG` | passed | Bumble received-Note detail not found on Mobbin |
| C02 | Photo and prompt entry, context composer, limit | Composer | `16d5562` | Captures, contract tests | passed | None |
| C03 | One-send, credit and retry semantics | Controller | `16d5562` | Contract tests | passed | Local demo only, see launch readiness |
| C04 | Received in Heart, safe reply, chat unlock | Request | `16d5562` | Contract tests, captures | passed | None |
| C05 | Missing target, block, no credit, already matched | Composer, request | `16d5562` | Contract tests, captures | passed | Deleted-target state is unit-covered, not screenshotted |
| D01 | Ente two-page inspection and map | Design | V4 map, `16d5562` | `BENCHMARK`, V4 `COMPONENT_MAP` | passed | V5 re-read Settings and Menu Item only, relying on the V4 two-page audit for the rest |
| D02 | Hierarchical shared spacing | `MonoSpace.section` and roles | `16d5562` | Settings captures | passed | None |
| D03 | Intentional solid purple, readable roles | Tokens | V4, `16d5562` | Audit captures | passed | None |
| D04 | Smooth shared gradient, readable image cases | `PhotoScrim`, identity | `16d5562` | Bright, busy and dark crops | passed, with exception | Under 25% cannot reach 4.5:1 on white; shadow carries it. Owner may choose glass in the gallery |
| D05 | Intentional icons, type, corners, restrained motion | Icon colour | `16d5562` | Captures | passed | Motion was not changed |
| D06 | Every active journey audited | All | `36407b3` | 132 screens and states viewed in flow sheets; 4 changed captures re-opened | passed | Contact-sheet scale for most normal states |
| S01 | Named skills verified or limitation recorded | Docs | This commit | `SKILL_USAGE` | passed | rad-spacing and audit-design-system have no licence on GitHub |
| S02 | Mobbin viewed per family; no fabricated evidence | Docs | This commit | `REFERENCE_LOG` | passed, partial | Filter, conversation row and streak card reused earlier references with no new search |
| Q01 | Baseline-compared checks, no new skips | Tests | `36407b3` | 600 passed, 42 skipped, 0 failed; analyze 1 older info | passed | None |
| Q02 | Narrow, large text, keyboard, native accessibility | Key screens | `36407b3` | 11 screens each at 1.5, 2.0, 360 dp; keyboard captures; guideline tests | passed for those | Physical phone and screen reader not run |
| A01 | Flat numbered phone folder and coverage | Delivery | `36407b3` | 188 PNGs, byte-verified | passed | None |
| A02 | Real variant gallery with tested persistence | Delivery | `36407b3` | Browser test | passed | None |
| A03 | Installable APK with SHA, hash, config | Delivery | `36407b3` | Installed over existing, launched | passed | Emulator only |
| B01 | Handoff, push, exclusions listed | Git | This commit | `git ls-remote` | passed | Private assets backup missing |
| R01 | Demo, internal and public readiness distinguished | Docs | This commit | `LAUNCH_READINESS` | passed | Not launch-ready |

Baseline web results, unchanged: `npm test` 121 of 122, build passes, token and icon checks fail on line endings only, browser e2e cannot run because Playwright's browser is not installed.

Not run: physical phone, iOS, screen reader, blur profiling on hardware.

# V4 requirements register

Candidate app code `25e145f`. Baseline `6fad2d1` (tag `checkpoint/pre-ente-v4-20261108-1928`).
Device evidence is from a Pixel 10 AVD (API 36) emulator. Nothing was tested on a physical phone.

| ID | Requirement | Implementation | Evidence | Status |
|---|---|---|---|---|
| A01 | Latest code preserved locally and on the remote checkpoint; same checkout | Tag and V4 branch pushed before edits | `git ls-remote`, handoff | Passed |
| A02 | Figma pages inspected; component map and references | Both pages read through the connector | [COMPONENT_MAP.md](COMPONENT_MAP.md), review `references/figma` | Passed |
| A03 | Skill usage demonstrated | Critiques run on real screenshots | [SKILL_USAGE.md](SKILL_USAGE.md) | Passed |
| A04 | No decorative tint in audited normal states | Primitives moved to neutral or solid | [TINT_AUDIT.md](TINT_AUDIT.md) | Passed |
| A05 | Solid labels readable; semantic roles tested | Solid badge roles | Rules table; `ente_v4_test` | Passed |
| A06 | Photo pills black, blurred, white, clipped | `PhotoPill`, `PhotoGlass` | `ente_v4_test`, QA images | Passed |
| A07 | Touch target retained on photo controls | Edit and Compliment controls keep their targets | Widget tests, screenshots | Passed |
| A08 | Gradient smooth and under 25%; bright and busy crops readable | 10% edge plus compact backing | Five photo captures, `ente_v4_test` | Passed |
| A09 | About separated from logistics; counts, privacy and states intact | Variant G, `EvAboutCard`, count only | Screens, `ente_v4_test` | Passed |
| A10 | Actions clear of floating navigation | Anchored action; Heart shortened | Major-screen captures | Passed |
| A11 | Actions accessible near the keyboard | Existing composer unchanged | Widget tests only; keyboard not opened on the emulator capture | Not run on device |
| A12 | Icons purposeful; no proliferation | Globe replaced with `info` | Event detail capture | Passed, gap logged (no wheelchair glyph) |
| A13 | Normal, about 360 dp and large text 1.5 and 2 | Seven key screens each | Gallery QA section; 320 dp at 200% widget test for V4 groups | Passed for those screens; other routes not captured at these settings |
| A14 | Long, empty, error and disabled cases | Long event, empty, banners, cancelled, disabled confirm | QA images | Passed |
| A15 | Flows preserved; no route removal or revived Health | No route changes | Test suite; [ROUTE_INVENTORY.md](ROUTE_INVENTORY.md) | Passed |
| A16 | Gallery matches variants; export and import tested; major screens indexed | `tool/ente_v4_gallery` | Browser test below | Passed |
| A17 | Analyze, format, tests classified | See below | See below | Passed, baseline items noted |
| A18 | Goldens reviewed | No golden file changed in V4 | `git diff` | Passed (none to review) |
| A19 | APK from final app source with hash | `flutter build apk --debug` at `25e145f` | Install and launch on emulator | Passed |
| A20 | Blur profiled in a real scene | Blur is clipped and grouped by construction | Flutter profile mode does not run on emulators and no phone was attached | Blocked: needs a physical phone |
| A21 | Reduced motion and transparency fallback | High contrast removes blur (tested). Motion unchanged | `ente_v4_test` | Passed for high contrast; motion not changed |
| A22 | Handoff accurate; remote SHA checked | Handoff files and `ACCOUNT_HANDOFF.md` | `git ls-remote` after push | See the final report |

## Test classification
- `flutter analyze`: 1 info, pre-existing (`containsSemantics` deprecated in a test).
- `flutter test`: 586 passed, 42 skipped, 0 failed. Baseline 575 and 42. The 11 extra passes are the new V4 tests. No skip added.
- `dart format`: 1 file differs, `tool/dump_lab_registry.dart`, not changed in V4.
- Tabler icon check: 130 SVGs, 0 problems.
- Web: `npm test` 121 of 122, `vite build` passes. `tokens:check`, `icons:check` and the token unit test fail on CRLF only, as at baseline. `test:e2e` cannot run because Playwright's browser is not installed. No web file changed.

## Gallery test (in-app browser, served from localhost)
Real choice and note through the page controls, reload (kept), JSON and TXT export, reset, re-import
(restored). Refused without changing state: wrong review ID, unknown group, unknown variant, invalid
JSON. Empty export warns and exports nothing when declined. 149 images, 0 broken, no external
resources. Test choices were cleared afterwards.

## Emulator capture
91 of 91 at `25e145f`, 0 skipped. Font 1.5, font 2.0 and 360 dp runs (7 screens each) used the same `lib/`.

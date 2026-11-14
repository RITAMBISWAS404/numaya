# Test results

- `flutter test` 674 passed, 44 skipped (opt-in comparison renders and dormant Events suites), 0 failed, at `fe44b27`. New: `v8_review_test.dart` (9), `type_settings_test.dart` (5). 22 earlier test files were updated where they encoded replaced designs (listed in TEST_RESULTS.md); none was deleted.
- **Analyzer:** one older deprecation info (`test/widget/ente_alignment_test.dart`, `containsSemantics`).
- **Stress renders:** the new and changed layouts at 320dp with 200% text (87 scenes). Found and fixed: StatCard T4/T6 overflow (also caught by the Visual Lab registry test) and the Photo tips sheet overflow.
- **Emulator capture:** 226 shots, 2 skipped by design (Messages Unread / Your move filters: the filter row was removed by UI-068).
- **Device walk (installed APK, Pixel 10 emulator):** Welcome with the real sign-in and Explore the demo; Prototype tools > Typography: 14pt chosen, saved, still chosen after a force-stop and relaunch, Reset back to 15 (file removed); a Compliment from Discover opened Maya's chat in reply mode, sent once, then "Sent. You can keep chatting once Maya replies."; the paywall shows five durations with 3 and 6 months "Not available yet"; Sign out asks first and returns to Welcome.
- **Defect found on the device and fixed:** a cold start could stay on the launch screen while the saved settings were read before the first frame. They are now read after it (`fe44b27`).
- **Gallery checks (localhost):** 96 images, none missing or broken; one option selected with a note containing `<b>`, quotes, `&` and `;` kept as text; choices survive a reload; import into empty storage reproduces the choice, note and typography exactly; a stale revision, an unknown option, a concept-only option, a duplicate group and a 13pt body are rejected; the earlier selections export is explained, not imported; nothing preselected.

## Tests updated to the V8 rules (not deleted)
foundation_test, ente_design_system_test, component_cleanup_test, ente_v4_test, discover_match_review_test, frosted_navigation_experiment_test, tabler_mvp_test, ui_consistency_test, final_polish_test, chat_review3_test, chat_media_test, compliment_contract_test (pins the separate page), mvp_screens_test (pins the separate page), dating_test, full_app_journeys_test, onboarding_edge_cases_test, onboarding_flow_test, profile_review3_test, selections_test, v16_screens_test, visual_lab_v2_test.

## Not run
Physical phone; backend contract tests against a live server (no server exists); screen-reader walk on the device (semantics checked in widget tests and uiautomator labels only).

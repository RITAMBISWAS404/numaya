# Requirements register

**Final app source:** `ee87648`. **Branch:** `experiment/numaya-v8-premium-rebuild-20261112-1945`.

Status values: passed, failed, blocked, not run, partial.

| Requirement | Implementation | Evidence | Status | Next action |
|---|---|---|---|---|
| Baseline protection | Built from the selected V7 `b5e5245`; V8 and V9 archived on `archive/superseded-v8-v9-20261112` and `archive/superseded-v8-20261112`; `version-8` and `version-9` untouched | DECISIONS.md, `git ls-remote` | passed | — |
| Owner selections kept | All 36 V7 decisions are still `proposed`, checked by script against the export | DECISIONS.md | passed | — |
| Reconciliation recorded before edits | DECISIONS.md | DECISIONS.md | passed | — |
| Figma evidence | Six Ente nodes read live (variables and screenshots) | REFERENCE_LOG.md | passed (partial inventory) | Desktop plugin needs `/mcp` sign-in for deeper reads |
| Mobbin evidence | Reused from this session's earlier searches (WhatsApp, Hinge, Bumble, happn, Airbnb, Uber, Apple Health, Binance); Tiimo from the V8 run | REFERENCE_LOG.md | passed (not re-run) | — |
| Typography roles | V7 roles unchanged; editorial comparison behind a build flag | DESIGN_CONTRACT T-01/T-02, gallery `r8-type` | passed | Owner choice in the gallery |
| Spacing, card and radius consistency | V7 tokens unchanged; single-column; owner-selected cards kept | 210-screen review | passed | Owner choices `r8-wallet-value`, `r8-profile-bar` |
| Control, icon and divider roles | Outlined secondary buttons; no decorative icon discs; Messages hairline at the content edges; Ente-style dividerless grouped cards | `ui_review_handoff_test`, `v3_fidelity_test`, measured 52–1026px | passed | — |
| Smooth, readable photos | Adaptive scrim, 24–52%, limited to the text band | `ente_v4_test`, gallery `r8-photo-scrim` | passed | Owner choice in the gallery |
| Unified Compliments: list, thread, links | Heart is likes only; one row per person; photo-led thread; reply once; sender blocked from writing; Dismiss, report and block in the menu; `/request/:id` and `/likes?tab=compliments` resolve | `conversation_contract_test` (5 tests), `compliment_contract_test`, `visual_lab_v2_test` | passed | Real push routing needs a backend |
| Artwork provenance | V7 assets only (`mascotWaiting`, `noChats`) | FONT_ASSET_INVENTORY.md | passed | The 3D reference was never supplied |
| Motion | V7 roles kept; reduced motion zeroes them | DESIGN_CONTRACT M-01 | passed (no hardware profiling) | Profile on a phone |
| Active-screen coverage | 210 captures, 0 skipped, at `ee87648` | SCREEN_LEDGER.md, CAPTURE_MANIFEST.md | passed | — |
| Narrow and large text | 19 key screens at font 1.5, font 2.0 and 360dp, 0 skipped. Two 200% defects fixed, with a regression test. | `large_text_regression_test` | passed | — |
| Analyzer and tests | `flutter analyze`: one older deprecation info in a test file. `flutter test`: 646 passed, 42 skipped (the same as V7), 0 failed. No skips added. | test logs | passed | — |
| Web checks (`npm run check`, e2e) | No web change | — | not run | — |
| APK | Release mode, debug-key signed (no release keystore), 0.1.0+1, from `ee87648`; installed with `-r` and launched without a crash | ACCOUNT_HANDOFF.md | passed | Physical phone install |
| Gallery | 7 groups and 15 variants. 81 of 81 images return 200; selection and notes persist across a reload; JSON and TXT export work; an import with another review ID is refused | Desktop review folder | passed | Owner review |
| Git backup | Normal push; remote SHA checked | ACCOUNT_HANDOFF.md | passed at handoff commit | — |
| Physical phone, iOS, screen reader | — | — | not run | Owner |
| Real OTP, persistence, delivery, push, billing, moderation, release signing | Not in this front-end demo | — | not present | Backend work |

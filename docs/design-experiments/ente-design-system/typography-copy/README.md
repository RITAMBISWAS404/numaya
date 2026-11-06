# Typography and UI copy pass

| | |
|---|---|
| Branch | `experiment/numaya-typography-copy-20261106` (local, no upstream) |
| Parent | `9f61314c052fef88b646c063f667c43bc76e3c1d` (Tabler MVP, restored from the recovery bundle and verified) |
| Code commit | `332c2b47864f78838d16a811c73908ac60f1c6a7` (all app code and tests) |
| Evidence commit | the commit that adds this folder: docs and boards only, no code |
| Carried forward unchanged | Figtree for text and Plus Jakarta Sans for headings; body 14/20 medium; Tabler icons and outline/filled rules; centred alert icons; Events gated off (`NUMAYA_EVENTS`); EXP-001 to EXP-004 pending, with every Current/A/B/C variant kept and none selected |

Files:
- [TYPE_ROLES.md](TYPE_ROLES.md): the Figma-to-Flutter role map, with what was measured and what was decided.
- [FONTS.md](FONTS.md): font metadata and rendered-weight verification.
- [COPY_CHANGES.md](COPY_CHANGES.md): every substantive string change with its reason, plus strings held for review.
- Before/after boards: `artifacts/ente-design-system/typography-copy/before-after/`.

## What changed
| ID | Change | Where |
|---|---|---|
| TC-01 | Section headings 20/28 → 18/24 (Ente H2) | `AppTypography.section` |
| TC-02 | Button labels 500 → 600 (Ente Body-Bold) | `AppTypography.button`, `buttonSm` |
| TC-03 | Metadata 12/16 → 13/18 (Ente Mini adapted to Figtree's x-height); eyebrows get +0.04em; doc comments match the shipped values; the stale "Hanken Grotesk" comment is fixed | `AppTypography.caption`, `labelCaps`; `widgets/content.dart` |
| TC-04 | Top-bar titles wrap to two lines and the bar grows, instead of "Safety and w…" at 200% | `NumayaTopBar` (`widgets/layout.dart`) |
| TC-05 | The visibility score's badge moves below it instead of breaking "28" / "%" | `visibility_screen.dart` |
| TC-06 | Day/Month/Year drawn as subordinate captions under "Birthday" | `NumayaTextField(subLabel:)`, `about_you_screens.dart` |
| TC-07 | `PhotoScrim`: a fade plus a solid panel that grows with text on a photo. Applied to the person card, the EXP-001 match photo (variant with photo) and the EXP-002 cover. The panel ignores touches. | `widgets/people.dart`, `person_profile.dart`, `match_variants.dart`, `profile_variants.dart` |
| TC-08 | 16 copy edits | `app_en.arb` ([list](COPY_CHANGES.md)) |

UI-012 (one type scale), UI-020 (card hierarchy: muted label, then larger primary text) and UI-045 (muted list metadata) are all kept.
- Row values and details were already #666 at 0 and stay muted.
- `caption` is still the only metadata role.

## Contrast
WCAG 2.2 relative luminance, computed after compositing. Each colour pair is also asserted in `test/typography`.

| Foreground | Worst real surface | Ratio |
|---|---|---|
| ink #000 | field fill #EAEAEA | 17.46 |
| muted #666 (metadata, placeholders) | successSubtle #DDEEDF | 4.75 |
| brandText #5B4BB0 | successSubtle | 5.64 |
| danger #C52E2E (errors) | successSubtle | 4.57 |
| white on brand #7262C7 (buttons) | — | 4.90 |
| white on `photoPanel` over a white photo | composited #474747 | 9.29 |
| white on the **old** fixed gradient at the name's position, 320pt / 200%, white photo | ≈ #DADADA | ≈ 1.4 (fixed by TC-07) |

- Disabled text (#8A8A8A, 2.87–3.45:1) is exempt under 1.4.3 and is used only for disabled controls.
- Ente's hint grey #969696 (2.96:1) was not adopted.
- Flutter's `textContrastGuideline` was not used as the gate. It samples rendered pixels and cannot judge text over gradients and photos; the composited calculation above replaces it.

## Commands and results (Linux cloud container)
Toolchain: Flutter 3.47.8, Dart 3.13.7, Node 22.23.4, Python 3.13.18.

| Command (from `apps/numaya_mobile` unless noted) | Result |
|---|---|
| Recovery ZIP `sha256sum` | `5694f17c…f1ff0`, matches |
| `sha256sum -c SHA256SUMS` (inside the ZIP) | bundle, both handoffs and the Tabler tgz: OK |
| `git bundle verify` + fetch + checkout | HEAD `9f61314c…`, tree `286b4c7e…`, clean |
| Baseline at `9f61314`: `flutter pub get`, format, `flutter analyze`, token check, `sync_tabler_icons.py --check` | OK; 0 changed; no issues; up to date; 109 SVGs, 0 problems |
| Baseline `flutter test test/widget/tabler_mvp_test.dart` | 19 passed |
| Baseline `flutter test` | **473 passed, 21 skipped, 0 failed** |
| After: `dart format --set-exit-if-changed lib test` | exit 0 (207 files) |
| After: `flutter analyze` | No issues found |
| After: `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| After: `flutter test` | **484 passed, 21 skipped, 0 failed** (473 + 11 new in `test/typography`) |
| New guards run against the `9f61314` code | the role ladder, TC-04 and TC-05 **fail** there, as intended |
| Captures: `capture_v3_test.dart` with `V3_SET=type-before` (in a detached worktree at `9f61314`) and `type-after`, `V3_VIEW=phone` and `narrow`; plus `capture_v3_experiments_test.dart` and `capture_v3_components_test.dart` | 58 + 58 + 54 renders each side, no exceptions. These are Linux golden renders, not device screenshots. |
| `flutter test --run-skipped --update-goldens test/screenshots/capture_worst_case_test.dart` | Passed: long hyphenated name, long link and long previews, no exceptions. The tracked `goldens/w0*.png` it rewrote were stale from earlier passes (they still show the Events tab), so they were reverted, not updated. |
| Repo root: `npm run check` | 122/122 Vitest tests, token, icon and Vite build OK (web untouched) |
| Repo root: `npm run test:e2e` (pinned Playwright 1.56.1, run against the pre-installed Chromium 1243 headless shell) | 143/144. The one failure, "no squircle corner-shape", counts 2,275 elements and depends on the Chromium version: no web file changed in this pass. |

## Coverage per flow
"Rendered" means captured at 390pt/1.0× and 320pt/2.0× with no exception. "Inspected" means looked at on a board.

| Flow | Routes rendered | Inspected | Notes |
|---|---|---|---|
| Welcome, phone, onboarding (a01–a15) | 15 | a01, a04 | TC-06; Confirm age now "That's right" |
| Discover, For you, person, like, match (b01–b05) | 5 | b01, b03 | TC-07 |
| Likes, Messages, chat (c01–c04) | 4 | c01–c03 | Likes subtitle trimmed; "Try again" on failed messages |
| Profile, edit, completion, preview, verify, visibility (d01–d11) | 11 | d01, d02, d10 | TC-05; Snooze wording |
| Settings, notifications, privacy, blocked, delete, help, safety, account blocked (e01–e09) | 9 | e01, e03, e05, e08 | TC-04; Sign out |
| Premium, paywall (f01–f02) | 2 | f02 | No copy change (costs are held for review) |
| Events (g01–g05) | 5 | — | Gated off: all redirect to Discover, as before |
| Demo Hub, filters, chat menu, sheets, attach, recovery email (h01, o01–o06) | 7 | o01, o04 | — |
| Experiments EXP-001 to EXP-004, Current/A/B/C | 16 variants × 3 views | all, on boards 10–12 | Changes apply equally; none selected |

## Remaining exceptions
- **Placeholder photo icon.** At 200%, the demo's placeholder photo icon overlaps the "New here" pill on the person card. The icon is centred in the photo, and the pill rises with the larger identity block. This affects placeholders only (real photos have no icon) and predates this pass.
- **Unsupported scripts.** Names in Devanagari, Cyrillic or Greek fall back to a system face (FONTS.md). No harness fixture renders them.
- **Partial Figma check.** Ente's `Small/Regular` 14/17 and its photo-overlay type were not traced to instances (TYPE_ROLES.md).
- **Impeccable.** The `clarify` and `typeset` guidance was read and applied to the captures and the ARB. Its `detect` script reads web CSS and was not run on Flutter source.
- **break-ui.** The skill was not invoked. Adverse text was covered by the existing worst-case member (`test/helpers/worst_case.dart`) and the 320pt/200% harness.

## Device-only checks (not done)
There is no Android SDK, emulator or device in this environment, and `dl.google.com` is blocked by its network policy, so no APK was built. Still to check on a device:
- the largest system font setting, including Android 14's non-linear scaling, which the 2.0× linear harness does not reproduce;
- text around the keyboard on the name and report sheets;
- TalkBack reading the two-line titles;
- the photo scrim's look over real photos.

The device items from the Tabler handoff still apply.

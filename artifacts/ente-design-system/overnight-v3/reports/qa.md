# Overnight v3: QA

**Evidence labels:**
- *Harness* means a Flutter golden render on Linux.
- *Test* means an automated widget test.
- No Android emulator or device was available in this cloud session, so nothing here is device evidence.

## Checks (Linux, Flutter 3.47.8 / Dart 3.13.7)
| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` (full suite) | **443 passed, 20 skipped, 0 failed**. Skips are the opt-in `comparison` and `screenshots` capture suites |
| New tests | `v3_fidelity_test` (2; D01 proven to fail without its fix); `v3_experiments_test` (23: release gating, independence, lab chips, and the main, secondary and back actions for every variant) |
| Captures | 58 views × {Current, refined} × {390x844, 320x693 at 200%}; 4 experiments × {Current (frozen), refined control, A, B, C} × {phone, narrow, tall}; 5 component boards; mascot board; Experiment Lab |
| Overflow / exceptions | Every capture asserts no exception. Two variant overflows found on the narrow view were fixed |
| Screenshot goldens (`--tags screenshots`) | Not regenerated. The committed goldens are Windows renders from before these passes |

## Interactions exercised (test, not device)
- Every match variant: Open chat, View profile and Close.
- Every profile header: Edit, plus the verification pill to verification; Preview in C.
- Every completion card: reaches the hub; B's Continue opens the photos editor.
- Every empty-conversations option: reaches Discover; B reaches Events.
- Lab: changing a chip changes only that experiment; Copy produces the reply format.
- Release builds (no demo auth) always render the refined candidate.

## Accessibility
- **Mascot semantics.** The cat is excluded from semantics (test checks no label is added). Copy carries the meaning.
- **Large text.** All variants were checked at 200% text on 320pt. Mid-word breaks and overflows found there were fixed.
- **Contrast.** White names on photos sit on the photo-panel fade; at large text the fade starts earlier.
- **Motion.** Match tilts are dropped under reduced motion. No new animation was added.

## Needs a real device (not done)
- Android emulator or phone:
  - the action sheet's drag-to-dismiss;
  - the keyboard over sheets;
  - TalkBack reading order on the four experiments;
  - back gesture in sheets and the lab;
  - chat swipe feel;
  - Experiment Lab "Copy my choices" (clipboard).
- Real photos instead of placeholders, especially for EXP-001 A/B and EXP-002 A.
- Regenerating the `screenshots` goldens on the target platform.
- Backend: everything remains demo data, with no delivery, verification or purchase.

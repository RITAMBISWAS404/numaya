# Skill usage, MVP V5

| Skill | Source and status | Target | Advice applied | Outcome | Evidence |
|---|---|---|---|---|---|
| rad-spacing | github.com/nolanperk/rad-spacing. **Not installed:** GitHub reports no licence, so it was not copied. Its public guide was read | Spacing roles | Proximity: each level clearly larger than the one inside it; use the library's variables first | Roles 4, 8, 12, 16, 32 from Ente's variables. Its 1.4x formula was not applied, since the brief forbids an invented formula on nested components | `BENCHMARK.md`, Settings captures |
| audit-design-system | edenspiekermann/Skills. **Not installed:** GitHub reports no licence, and it audits Figma drift, not Flutter | None | Not used | Replaced by the code-to-Ente mapping in `BENCHMARK.md` | Not applicable |
| design-review | humbleteam/design-review @bdc9204, MIT, installed in V4. Its scoring rubric was applied in this run | Compliment sent state | Plain-text sent state lacked a visible result (Nielsen #1, visibility of system status) | Added the solid check | Sent state capture |
| flutter-figma-workflow | thienqo/flutter-skills @8312286, BSD-3, installed in V4 | Ente node to widget mapping | Map nodes to existing widgets first | No new parallel components; `ComplimentContextRow` uses the system | Code |
| Flutter accessibility guidance | Existing `accessibility_tools` and guideline tests | Native checks | Semantics, tap target and contrast guidelines rather than web checkers | Suite passes | `flutter test` |

Not used in this run, though available: Impeccable, Emil Kowalski motion skills and frontend-design. V5 did not change motion, and the existing approved type and brand rule out frontend-design's originality guidance.

Rejected suggestion: moving the received-Compliment Reply field directly under the message. The anchored composer matches Chat and keeps the keyboard behaviour consistent.

Skill critiques are suggestions, not proof of quality.

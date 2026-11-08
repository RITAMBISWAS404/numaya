# Skill usage, V4

Only skills actually read or run are listed as used. Installing a skill is not recorded as using it.

| Skill | Source and version | Installed or reused | Target | Advice applied | Changed widget | Evidence | Rejected suggestion and reason |
|---|---|---|---|---|---|---|---|
| design-review | humbleteam/design-review @bdc9204, MIT | Installed, project-local | Event detail G, emulator screenshot | Score 3/4. Two issues: globe glyph means the wrong thing (Nielsen #2, match with the real world); uneven gap after Directions (Nielsen #4, consistency) | `EvFact`, event detail fact rows | `screen__event.png` before and after in the review folder | None |
| impeccable critique | Installed copy in `.claude/skills/impeccable`, reused | Reused | Events feed, event detail, Discover | Run as a single-context design assessment. Its automated detector reads web markup and does not apply to Flutter screenshots, so it was not run. Finding: the feed header is dense, which is why `ea-event-filters` stays an owner choice | None beyond the choice | Gallery group `ea-event-filters` | "Merge New here with the name label": rejected, they are different facts |
| flutter-figma-workflow | thienqo/flutter-skills @8312286, BSD-3 | Installed, project-local; `SKILL.md` read | Memory card, Badges, Header v2 | Map each node to an existing widget before writing anything; compare the rendered result | `PhotoScrim`, `StatusBadge` | [COMPONENT_MAP.md](COMPONENT_MAP.md) | Generating new components from Figma code: rejected, the design system already had the families |
| flutter-ui-design | thienqo/flutter-skills @8312286, BSD-3 | Installed, project-local; `SKILL.md` read | Event detail, event card | Cover complete states and judge from rendered proof | `v4-event-detail`, `ea-event-card` P | Gallery | Distinctive new art direction: rejected, V4 preserves the approved identity |

Not used in this pass, although installed: Emil Kowalski's motion and Apple-design skills. V4 did not
change motion; the existing press feedback was kept. These skills are not added to `skills-lock.json`,
so the versions above are the record.

Skill critiques are suggestions, not proof of quality.

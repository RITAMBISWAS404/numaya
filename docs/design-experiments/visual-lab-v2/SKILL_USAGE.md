# Skills, tools and sources used (Visual Lab V2)

Inventory first (brief 09): the project has 39 skills in `.claude/skills/` (accessibility-as-code,
adaptive-layout, animate, animation-performance, apple-design, apple-hig, emil-design-eng,
impeccable, improve-animations, motion-and-haptics, prototype, review-animations, ui-ux-pro-max,
widget-golden-and-a11y-testing and others). They already cover critique, motion, accessibility and
Flutter testing, so **no new skill, library or package was installed** in this run. Installation
was not needed to close any gap; the unverified `mattpocock/prototype` path was not pursued.

| Source | Kind | How it was applied here (evidence) |
|---|---|---|
| Ente Figma `22AeTw6QiPj2fNYHLhC7MK` via the Figma MCP | Reference | Header v2, Tabs, Bottom sheet, Segments, Banners, Icon Button read live; mapped in RESEARCH.md; implemented as `LargeTitlePage`, `NumayaSegmented`, `SquircleIconButton`, wallet variant A, `LabStatusBanner` A. |
| Mobbin MCP (6 targeted searches) | Reference | Patterns recorded in RESEARCH.md with links; applied to compliment cards (Reddit/Insight Timer requests), insights period lines (Brainly, Reddit), match ring (Bumble), name badge (Hinge), profile header variants. |
| Skill principles: restraint, purposeful motion, interruptibility, reduced motion (apple-design, emil-design-eng, motion-and-haptics, animate) | Skills (inventoried; their rules were followed, the skill files were not re-loaded in this run) | Brief 08 numbers implemented as MotionTokens; no decorative loops; scroll-driven (not timed) title collapse; data-keyed one-time chart reveal. |
| Skill principles: accessibility-as-code, widget-golden-and-a11y-testing | Skills (inventoried, rules followed) | Every variant has one spoken label; 48pt targets; layout tested at 320/360/411dp and 200% text; a dense variant falls back instead of truncating (VL-D21). |
| impeccable critique loop | Skill (inventoried, method followed) | Screenshot critique → fix → recapture: Material ancestor missing (yellow underlines), white squircle invisible on white cards, stretched count badge, empty bar under an expired match, inline weekday labels cramped. See CRITIQUE.md. |
| Flutter API docs (CupertinoSliverNavigationBar, MediaQueryData.disableAnimations) | Primary docs | Large title behaviour and reduced-motion signal handling. |
| Tinder / Hinge help pages (brief 04) | Behaviour evidence | No claim that non-reply or blocking lowers reach; advice states uncertainty. |

Claims are limited to what was actually done in this run. No skill "generated" or "validated" a
design preference; owner choice decides.

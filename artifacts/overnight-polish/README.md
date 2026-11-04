# Overnight polish evidence

Flutter test renders on Linux (cloud); not emulator or device captures. See
`docs/design-experiments/overnight-polish/README.md` for conditions and decisions.

| Folder / file | Contents |
|---|---|
| `type-comparison/sheet-*.jpg` | Rows: 16/24, 14/20, compact. Columns: Discover, bio, Profile, long bio, Chat. One sheet per width/text size |
| `type-comparison/{base,body14,compact,body14-fixed}/` | The individual renders (`<width>-<text%>-<screen>.png`) |
| `direction/sheet-direction-390.jpg` | Calm (kept) against expressive (removed) |
| `glass/glass-before-after.png` | The tab bar over stress backgrounds, before and after the top highlight |
| `before-after/1-…5-*.jpg` | The 16/24 baseline (HEAD) against the final state, by family |
| `op01-…op03-*.png` | The mascot empty state; Discover and Profile at 320pt and 200% text |

# Motion guidelines

**Unchanged foundation:**
- Every duration goes through `AppMotion.duration(context, role)`. It returns `Duration.zero` when
  `MediaQuery.disableAnimations` is set (reduced motion).
- This round's diff adds **no other motion path**. It was audited with
  `git diff 0003d17 -- lib | grep duration`: all three new animations use `AppMotion`.

| New or changed motion | Role | Under reduced motion |
|---|---|---|
| Tab indicator cross-fade (`AnimatedContainer`) | `base` | Instant |
| Code-cell, field and focus colour change | `base` | Instant |
| Account Health completeness bar fill | `progress` | Drawn at its final value |
| Discover card swipe, sheets, toasts | Unchanged | Unchanged (instant or none) |

**Rules (from `apple-design`):**
- Motion explains a change of state or place; it is never decoration.
- Presses respond immediately (scale on `Pressable`).
- No bounce on data. No looping animation.

**Haptics:**
- They stay gated through `AppHaptics.fire(context, moment)`. Its one gate is the in-app haptics
  setting (`HapticsScope`); the operating system also applies its own vibration setting.
- No new haptic moments were added.

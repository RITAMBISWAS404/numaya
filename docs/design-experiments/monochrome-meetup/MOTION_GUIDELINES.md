# Motion guidelines

**What was kept:** the centralised motion system is preserved unchanged:
- `foundations/app_motion.dart` and `app_transitions.dart`;
- the audit in `docs/mobile/MOTION_DESIGN_AUDIT.md`.

The experiment only adapts components to it.

## Roles (unchanged)
| Role | Duration | Curve | Used for |
|---|---|---|---|
| `press` | fast | ease-out | press-scale on every `Pressable` (default 0.98; chips and view tabs 0.97, icon buttons 0.92, the step button 0.94) |
| `state` | base | ease-out | fills, borders and thumbs changing state; **the tab bar's grey capsule** fading in on the new tab; switch track and thumb; pill selection |
| `exit` | 200ms | | a profile leaving after a decision |
| `sheetIn` / `sheetOut` | slow / base | emphasised / flipped ease-out | bottom sheets (`AppMotion.sheet`) |
| `progress` | 560ms | | progress bars and rings filling |
| `celebrate` | 560ms | | the match moment and verified badge: rare moments only |
| `stagger` | 60ms | | lists entering |
| page push | `push` | `NumayaPageTransitionsBuilder` | Android; iOS keeps its native swipe-back transition |

## Rules
| Rule | Detail |
|---|---|
| **Reduced motion** | Every duration goes through `AppMotion.duration(context, …)`, which returns zero when the system asks to remove animations. Sheets use `AnimationStyle.noAnimation`. |
| **No springs, bounces or loops** | New monochrome components (tab capsule, switch, RSVP bar, metric tiles, slots) add no new motion types. |
| **Shadows don't animate** | Elevation is fixed per component. |
| **No blur** | No animated blur or glass. |

# Visual Lab V2: motion system (brief 08)

All values are Numaya tuning proposals, not Apple or Material requirements.

## MotionTokens (`lib/core/design_system/foundations/app_motion.dart`)
| Role | M1 (proposed) | M2 (quicker) | M0 (reduced/static) |
|---|---|---|---|
| Feedback (press) | 120 ms | 100 ms | 0 |
| State (segments, fills, thumbs, list items) | 200 ms | 160 ms | 0 |
| Route push and sheet in | 280 ms | 240 ms | 0 |
| Sheet out / route back | 200 ms (state) | 160 ms | 0 |
| Decision exit (Discover) | 200 ms | 200 ms | 0 |

Curves are unchanged tokens: decelerating `easeOut` for arriving surfaces, `emphasized` for routes and
sheets, accelerating reverse on exit. Gesture-following movement (Discover swipe, sheet drag) follows
the finger and is not timed.

`AppMotion.duration(context, d)` maps the raw tokens (140/220/380/460 ms) onto these roles, so every
existing caller moves to the preset without per-screen edits. `AppMotion.preset` is set from the app
root by the Lab group `motion` (debug only); release builds always use M1.

## Reduced motion (MOT07)
`AppMotion.reduced(context)` is true when any of these hold:
- the platform flag Flutter exposes as `MediaQuery.disableAnimations` (Android "Remove animations";
  on iOS Flutter reports "Reduce Motion" through the same flag),
- the in-app Reduce motion setting (the app root sets the same MediaQuery flag),
- the M0 preset.
Reduced motion removes translation, scale and springs: routes and sheets appear without sliding,
the segment thumb jumps, chart reveals are skipped, the large title switches at the threshold instead
of cross-fading. Every outcome stays understandable without motion, colour or haptics.

## Interaction matrix (implemented)
| ID | Interaction | Implementation |
|---|---|---|
| MOT01 press | `Pressable` scale 0.95–0.98 over the press role on buttons and squircles; list rows and cards use 1.0 (no whole-list scaling). | Existing `Pressable`, roles remapped. |
| MOT02 tabs | `NumayaSegmented` thumb slides over the state role; labels never animate; per-part scroll offsets are saved and restored on switch. Activation is immediate. | `segmented.dart`, `likes_screens.dart`. |
| MOT03 sheets | Native drag-to-dismiss kept; programmatic in 280 ms / out 200 ms; close squircle tappable throughout. | `AppMotion.sheet`. |
| MOT04 titles | Large title collapse driven by scroll offset, not time; stable leading and trailing controls. | `large_title_page.dart`. |
| MOT05 list updates | Archive/active moves happen through the normal list rebuild (no animated reorder that could lose the scroll anchor). | Chats, Archive. |
| MOT06 charts | One 220 ms bar reveal, keyed by the data so rebuilds with the same numbers don't replay it; skipped under reduced motion; exact values always in the semantics label. | `ExposureBars`. |
| MOT07 reduced motion | As above. | `AppMotion.reduced`. |
| MOT08 performance | No new packages; only implicit animations, `AnimatedPositionedDirectional`, `TweenAnimationBuilder` and `ValueListenableBuilder`; no blur or `saveLayer` added to scrolling lists. Profile-mode measurement on a physical device was **not done** (no device connected); emulator debug clips show behaviour only, not frame timing. | — |

Match ring: static, no pulse, fraction recalculated on rebuild (VL-D04). Compliment submit keeps the
existing locked-while-sending button; no celebration before the server accepts. Streak keeps the
approved card; no confetti.

## Evidence
Clips (no autoplay, no audio) for tabs, title collapse, sheet and route under M1, M2 and M0 are in the
gallery's Motion section (`clips/`), recorded with `adb shell screenrecord` from the debug build on the
emulator. Interrupted animations (back during a push, rapid segment taps, sheet dismissed mid-rise)
were exercised in the capture script and widget tests; see VALIDATION.

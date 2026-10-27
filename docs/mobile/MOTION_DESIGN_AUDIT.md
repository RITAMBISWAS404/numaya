# Motion design audit

An audit of every animation in `apps/numaya_mobile/lib` at `84481d5`, before the quality pass. The criteria
come from the installed skills: `animate`, `review-animations` and `emil-design-eng` decide whether
something should animate, how often it is seen and which curve it uses. `motion-and-haptics` and
`design-system-structure` set the moment catalogue, the haptic map and the reduced-motion collapse.

## What existed

| Where | Motion | Verdict |
|---|---|---|
| `foundations/app_motion.dart` | Four duration tokens (fast 140, base 220, slow 380, push 460 ms), three curves (ease-out `0.22,1,0.36,1`, emphasized `0.32,0.72,0,1`, in-out `0.65,0,0.35,1`), `AppMotion.duration()` returns zero under *Remove animations* | Good base. It had no names for what each duration is *for*, and some widgets bypassed it |
| `Pressable` | Scale to 0.92–0.98 over 140 ms on press | Correct: same-frame acknowledgement, the press curve, reduced-motion aware |
| Buttons, FAB, chips, options, switch, fields, composer | `AnimatedContainer` colour and border, 220 ms | Correct. The switch thumb had a curve, but its track used the default linear curve |
| `CodeInput` | 440 ms shake on a wrong code, blinking caret that runs only while the caret shows | Shake is the right "reject" moment. The caret kept blinking under reduced motion, and the durations were raw literals |
| Toast | 380 ms fade and slide in, 220 ms out, dots loop while busy | Correct. The dots kept looping under reduced motion, and a `CurvedAnimation` was allocated on every build |
| Progress segment, success badge | 560 ms fill and fade-scale, raw literals | Right purpose (state indication). The literal duration should be a named role |
| Discover swipe card | Follows the finger and rotates up to the threshold, then snaps back on release | **Defect.** Committing a like snaps the card back to the centre before the profile is replaced. A fling is ignored unless the distance passes 96 pt |
| Discover Like / Pass / SuperSwipe buttons | None: the next profile replaces the current one in the same frame | **Defect.** A jarring content swap on the most frequent action in the app, with nothing to say which way the decision went |
| Route transitions | `CupertinoPageTransitionsBuilder` on Android and iOS, Cupertino's own timing | Inconsistent with the tokens (V16's push is 460 ms on the drawer curve). The match screen, paywall and verification pushed sideways like ordinary pages, although they are modal moments |
| Bottom sheets | Material default (250 ms in, 200 ms out, `Curves.easeOutCubic`); not reduced-motion aware | Should use the drawer curve and collapse under reduced motion |
| Tabs | Instant `IndexedStack` switch | Correct, and kept: tabs are used dozens of times a day ("frequent → near-imperceptible or nothing") |
| Match screen | No entrance; appears with the page push | The rare, high-value moment the delight budget is for. It needs a bounded entrance and one success haptic |
| Chat send | `animateTo(maxScrollExtent)` called before the new bubble is laid out; raw 220 ms ignoring reduced motion; the new bubble pops in | **Defect.** The jump stops short of the new message, and the scroll ignores the platform setting |
| Completion ring | Jumps to the new percentage | Missed state indication: the payoff after editing a profile |
| Haptics | None anywhere | Missing channel. The skills require one central gate and an event map |
| Reduced motion | Read from `MediaQuery.disableAnimations` | There was no way to try it in the demo without changing system settings, and no test |

## The moment catalogue (implemented in this pass)

Durations are roles in `AppMotion`. Haptics are slots in `AppHaptics`, which an in-app switch can turn off
(Settings → *Vibration*). Each row also says what happens under the platform's *Remove animations* setting.

| Moment | Trigger | What changes | Role / curve | Haptic | Reduced motion |
|---|---|---|---|---|---|
| Press | finger down on any `Pressable` | scale 0.92–0.98 | `press` 140 ms, ease-out | none (declared silence: presses are too frequent) | no scale |
| Toggle / select | switch, chip, option, filter chip, tab chip | fill and thumb | `state` 220 ms, ease-out | `selection` | instant |
| Reject | wrong code, invalid submit | bounded shake | `reject` 440 ms | `reject` (light) | message only |
| Swipe threshold | the card crosses ±96 pt | Like/Pass stamp appears | follows the finger | `selection`, once per crossing | stamp only |
| Decide | Like, Pass, SuperSwipe (button or release) | card flies out in the decision's direction, next profile settles in | exit 200 ms ease-out, enter `state` 220 ms | `commit` (light) | instant replace |
| Match | mutual like | portrait scales from 0.92, title and text fade in with a 60 ms stagger | `celebrate` 560 ms, emphasized | `success` (medium), once on arrival | appears complete |
| Modal route | match, paywall, verification, premium | rises 8% and fades | `push` 460 ms, emphasized | none | instant |
| Page route | everything else | slides from the right, previous page drifts 30% left | `push` 460 ms, emphasized | none | instant |
| Sheet | every bottom sheet | rises from the bottom | in `slow` 380 ms emphasized, out `state` 220 ms | none | instant |
| Message sent | send in a chat | bubble rises 8 pt and fades in; list follows to the end after layout | `state` 220 ms, ease-out | `commit` (light) | instant |
| Progress | completion ring, onboarding segment | arc or bar fills from the old value | `progress` 560 ms, ease-out | none | final value |
| Success | purchase done, photo verified, saved | result panel badge | `celebrate` 560 ms | `success` | appears complete |
| Toast | toast shown | fade and 8 pt rise | `slow` in, `state` out | none | fade only |

Rules applied throughout:

- **The state never waits for an animation.** Disabling animations gives the same end state, and the tests
  check that (`test/widget/motion_test.dart`).
- **Every animation can be interrupted.** Starting a drag during the enter animation takes over from the
  current value, and taps are never blocked for longer than the 200 ms exit.
- **Nothing loops without a stop condition.** The caret and the toast's busy dots stop under reduced
  motion and when they are disposed.
- **No `ease-in` on UI**, no `scale(0)`, and UI motion stays under 300 ms except page pushes (460 ms, the V16
  token), sheets entering (380 ms) and the match celebration.

## Rejected opportunities

| Idea | Why not |
|---|---|
| Animated tab switches | Used dozens of times a day; an instant switch is faster |
| Stacked "next card" peeking under the current one (seen in Bumble's *Swiping to get matches* on Mobbin) | Numaya's Home is a scrolling profile, not a card stack (V16 019). A peeking card would need a new layout V16 doesn't define |
| Confetti or particles on a match | Exceeds the celebration budget; the portrait's scale and one haptic carry the moment |
| Shimmer on skeletons | A looping animation on every load; the static skeleton already states "loading" |
| Hero photo from card to profile | The person profile is already a scroll of the same card; a hero would move data the person is reading |
| Animated counters in Likes and Messages | The numbers are read, not watched |

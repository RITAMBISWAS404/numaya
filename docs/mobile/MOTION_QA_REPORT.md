# Motion QA report

Branch `experiment/numaya-quality-motion`. This checks the motion catalogue in
[MOTION_DESIGN_AUDIT.md](MOTION_DESIGN_AUDIT.md) against the code. Each check is labelled with how it
was made:

- **Automated:** a widget test in `test/widget/motion_test.dart`, run with `flutter test`.
- **Code review:** read against the `review-animations` and `motion-and-haptics` rules.
- **Not checked:** needs a phone.

Nothing here was seen moving on a phone or emulator. Feel has not been judged: spring bounce, whether 200 ms
reads as quick enough, and haptic strength on real hardware.

## Moments

| Moment | What is verified | How |
|---|---|---|
| Page push | Mid-push the new page is still off to the right, and it lands at x = 0. Under reduced motion the same push lands in one frame | Automated |
| Modal (match, paywall, Premium, verification) | Uses `modalTransition` through `CustomTransitionPage` | Code review; the match test covers its arrival |
| Sheets | `AppMotion.sheet()` is 380 ms in and 220 ms out, and has no animation under reduced motion. Applied to both sheet helpers, so every sheet in the app uses it | Automated (values) and code review (coverage) |
| Decide (Home) | Mid-exit the profile is still the current one and a second tap is ignored. The next profile then appears. Exactly one `lightImpact` | Automated |
| Decide under reduced motion | The next profile appears on the next frame, and the state is already updated | Automated |
| Swipe | A slow 40 pt drag springs back with no haptic. A 60 pt flick at 1500 pt/s passes. Crossing the threshold and back ticks twice | Automated |
| Match | The title starts transparent, and touching it finishes the entrance (opacity 1). Haptics are `lightImpact` (the like), then `mediumImpact` (the match), once each. Under reduced motion it appears complete | Automated |
| Message sent | The chat opens with the newest message on screen and the oldest off it, at 375 × 667 and 130% text. After scrolling up, sending brings the new message on screen. One `lightImpact` | Automated |
| Selection haptics | A switch row ticks once (`selectionClick`). With *Vibration* off, nothing fires | Automated |
| Silence | Ordinary buttons and links (opening Help) fire no haptic | Automated |
| Reject | Wrong code: the shake plays unless motion is reduced, and the haptic fires either way | Code review |
| Success / reject results | Simulated purchase and photo review: one haptic per result | Code review |
| Progress | The completion ring and onboarding segment fill on the `progress` role, collapsed under reduced motion | Code review |
| Demo Hub reduced motion | The switch makes `AppMotion.reduced` true for the whole app | Automated |
| Idle | After settling, Home, Likes, Messages, a chat, Profile, Settings, Premium, verification and the Demo Hub schedule no frames, so nothing loops off-screen | Automated |

## Rules checked across the code

| Rule (source skill) | Result |
|---|---|
| No `ease-in` on UI (animate) | Pass: entrances use `easeOut` or `emphasized`, and exits use the flipped curve so they leave fast |
| No `scale(0)` (animate) | Pass: the smallest scale is 0.92 (match portrait) |
| UI motion under 300 ms unless justified (animate) | Pass: page push 460 ms (the V16 token), sheet entrance 380 ms, match 560 ms (a rare moment); everything else 140–220 ms |
| Frequent actions near-instant (animate) | Pass: tab switches are instant. Decisions take 200 ms and can't block for longer |
| State never lives in an animation (motion-and-haptics 2) | Pass: decisions apply on completion, or at once under reduced motion. The match screen and its composer work at any point of the entrance |
| Haptics from one map behind one gate (5, 8) | Pass: `AppHaptics.fire(context, HapticMoment.*)` behind `HapticsScope`, with no direct `HapticFeedback` calls elsewhere |
| One haptic per commit, never in an animation callback (6) | Pass: haptics fire in tap, drag and result handlers. None fire in `AnimationController` listeners |
| No `heavyImpact` for errors (7) | Pass: `heavyImpact` is unused, and a rejection is `lightImpact` |
| Interruptible (9) | Pass: page and sheet transitions use Flutter's interruptible routes. The match entrance ends on touch, and a drag can start during a profile's entrance |
| Repeating animations have stop conditions (11) | Pass: the caret blinks only while visible and not reduced. The toast dots loop only while shown and not reduced. The idle test confirms nothing else loops |
| Reduced motion declared per moment (4) | Pass: see the catalogue's last column |

## Not verified

- **Frame timing.** No profile-mode run was possible, so no frame-time numbers are claimed. The worst case
  checked by code is the Home exit: a full-page `Opacity` for 200 ms, applied only while it runs.
- **Haptic feel on hardware, gesture velocity on a real touchscreen, TalkBack announcements during
  transitions.**
- **iOS:** it keeps Flutter's Cupertino page transition with the edge swipe back, and was not checked.

# Selected designs: final review (13 November 2026)

## Status

1. **Design selections applied:** yes. These are the app defaults with development tools off. Owner export `fx-da197b7-2026-11-13`, with every note.
2. **Demo APK usable:** yes, on the Pixel 10 emulator. It was installed and walked past Welcome through every selected screen (see the device walk below). It has not been run on a physical phone.
3. **Real backend:** BLOCKED. No development backend exists, so nothing here was verified against one. See [BACKEND_BOUNDARY.md](BACKEND_BOUNDARY.md).
4. **Production readiness:** not implied. This is a debug review build with sample data. Prices are provisional and no store is connected.

## Source

- **Folder:** `C:\Users\biswa\Projects\Numaya-fable-lab`
- **Branch:** `experiment/numaya-selected-20261113-0232`, from the Fable lab head `c6a31a4`. The pre-pass checkpoint is tag `checkpoint/fable-lab-20261113-0232`.
- **App source:** `ae10663`. Later commits change only records and tooling.
- **APK:** `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Selected-20261113-ae10663-debug-demo.apk` (debug, SHA-256 `e66250087cb0bf488038f7bd0ae0f6ca808e11ca5e5e0701c7225222ba29aa31`). The earlier build from this pass is renamed `SUPERSEDED-…-cf2a6af-…`.
- **Screenshots:** `C:\Users\biswa\OneDrive\Desktop\Numaya Selected Design Screenshots\2026-11-13 ae10663` (203 PNGs from 207 captures; the builder keeps only the top of Discover out of likes).
- **Review page:** `C:\Users\biswa\OneDrive\Desktop\Numaya Selected Design Review\2026-11-13 ae10663\index.html` (offline; device-walk images in `journey/`).

## What changed

| Group | Selected | Implementation, including the notes |
|---|---|---|
| Discover | O, with notes | The name has no text shadow. A smooth gradient fades from the bottom of the photo upward. It adapts to each photo: 32 to 62% at the bottom edge, or 40% when the photo is not yet measured. There is no blur: a blur band without a soft mask leaves a hard edge, and the note asked for blur only if possible. The Compliment button stays on every photo and prompt. The job line has a briefcase icon, the same as the other metadata rows. |
| Profile | A, with notes | A completion pill that matches Complete your profile. A larger circular photo (88pt). The credits and streak tiles share one anatomy: an outline icon, the number, a label and one short line. Neither tile has a bar, because a credit balance has no denominator. |
| Messages | A | Your turn and Waiting on them replace the filter row, using the existing your-move state. Small icons use their filled versions where Tabler has one. Tabler 3.50.0 has no filled Compliment (message-heart), so that mark stays outline. |
| Received Compliment | A, with notes | The Compliment is the sender's incoming message. It quotes your photo, with a thumbnail, or your prompt answer inside the bubble. There is no separate card above it and no sender photo card. |
| Credits | O, with notes | A purple summary card: icon and heading, the balance, a bar of its parts in spend order, then which part is which. |
| Streak | O, with notes | The same summary card: icon and heading, the streak, seven day marks, then the day and today's state. |
| Photo scrim (r8, undecided) | Custom, per the Discover note | Same as Discover. |
| Welcome | Demo entry (requested) | An "Explore the demo" link under the real sign-in buttons, with a note that it is a sample account on this phone and nothing is sent to a server. |

**Shared component added:** `SummaryCard` and `SummaryBar` in the design system, used by Credits and Streak.

**Corrections made during the pass:**
- The Profile identity row overlapped at large text on a 320pt screen. It now stacks the photo above the name there.
- The streak bar was read twice by screen readers.
- The first full capture showed the completion pill at 83% while Complete your profile showed 45%. They used different measures. The pill now uses the same measure (`3264e94`), and a test checks that the two agree.
- In the recapture, the verification pill sat lower than the completion pill (its 44pt tap target), and a tick showed beside an incomplete percentage. The pills are now centred on one line, and the tick shows only at 100% (`ae10663`).
- Old tests that encoded the replaced layouts now pin those layouts through the Design Lab. Behaviour tests follow the new defaults.

**Kept, not removed:** the replaced options (Messages O filter row, Profile O cover, the separate Compliment card B) remain in the Design Lab behind development tools.

## The demo

1. Install the APK and open Numaya.
2. On Welcome, tap **Explore the demo**. "Create an account" and "I have an account" are the real phone sign-in flow. In this build they reach the demo code screen, because no SMS provider is connected.
3. The demo account lives in memory on the phone. Closing the app clears it, and Welcome shows again.

The demo entry appears only when the demo sign-in service exists. It does not exist in release builds or in live builds on the backend branch. No network calls are made.

## Real backend

**BLOCKED.** The backend branch `experiment/numaya-backend-20261112-2255` (`bbbe8af`) has Supabase adapters, but:
- No Supabase project exists (backend blocker A1).
- The phone OTP provider is not configured (A3), and real SMS is blocked.
- The app has no billing client and no push token capture.

The branch is not merged here. This pass changed no shared controller, repository or provider. Details are in [BACKEND_BOUNDARY.md](BACKEND_BOUNDARY.md).

## Journeys

Evidence: [JOURNEY_EVIDENCE.csv](JOURNEY_EVIDENCE.csv). A PASS in one context (installed demo, widget test) does not carry over to another (backend).

### Device walk

**Delivered APK (`ae10663`), fresh install on the Pixel 10 emulator:** Welcome showed the real sign-in buttons, Explore the demo and its note. The demo entry opened Discover. Profile showed Not verified, Profile 45% complete (the same figure as Complete your profile), 2 credits and a 1-day streak, matching the Credits and Streak screens. Messages showed Your turn and Waiting on them. Sam's Compliment was his incoming bubble quoting Your photo. One reply moved Sam to Waiting on them. Sign out returned to a clean Welcome, and re-entry worked.

**Earlier walk, with the full journeys,** on the Pixel 10 emulator, using the installed demo APK from `cf2a6af`, which has the same screens apart from the Profile pills:
- **Welcome → Explore the demo → Discover.**
- **Profile:** Profile A appeared, with the pill and both tiles. Credits 2 and Streak 1 matched their own screens.
- **Messages:** Messages A appeared, with Your turn and Waiting on them.
- **Sam's received Compliment:** shown as an incoming bubble quoting Your photo.
  - One reply opened the chat, with the Compliment kept first.
  - Credits did not change.
  - Sam moved to Waiting on them as a single row.
- **Sending a Compliment to Maya:**
  - Close asked to discard, and Keep writing kept the 33/150 draft.
  - The send worked once, and Profile then showed 1 credit.
  - Maya appeared once, under Waiting on them.
- **Sign out:** it asked first, then showed Welcome with no account detail. Re-entry worked.
- **Back:** closed sheets and returned from Credits and Streak to Profile. Back on Home leaves the app, which is the existing rule.

### Not walked on the device in this pass

These are covered by widget tests only:
- profile edit;
- Dismiss;
- archive and expiry;
- Premium and purchase states;
- rapid taps and interrupted loading;
- report, block and unmatch.

## Screens

- **Coverage:** the full emulator capture at `ae10663`. The flat folder holds 203 PNGs, numbered 001 to 203 by section, at 1080 × 2424, density 420, font scale 1.0.
- **Removed by design:** the Unread and Your move filter states. Messages A has no filter row.
- **Excluded:** Events, Health and Follow, as before.

## Limitations

- Emulator only; no physical phone.
- Debug build. A release APK has no demo entry by design.
- No backend, OTP, billing or push verification.
- Lab choices and the demo session are in memory only.
- Tabler has no filled Compliment glyph.

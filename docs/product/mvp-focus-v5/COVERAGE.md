# Screen coverage, MVP V5

Inventory built from `lib/app/router.dart`, the Demo Hub and every sheet call site.

## How these were captured
- Real `adb screencap` images from the Pixel 10 AVD emulator, API 36, 1080 x 2424, density 420, font scale 1.0. No golden renders. Not a physical phone.
- The current app source runs through an integration-test harness with the demo world, default variants and a fixed demo clock of 27 Oct 2026, so in-app dates are demo dates and the status-bar clock is the emulator's own.
- The AVD hides the on-screen keyboard by default. It was on for this capture and restored afterwards.

## Not captured
| Screen or state | Why |
|---|---|
| Events, Health, Insights | Deferred. Their direct links are regression-tested in `mvp_scope_test.dart`, not screenshotted. |
| Demo Hub, labs, specimen, staff tools | Development tools. |
| Opening Moves | Off for the first release. |
| Chat attachments and voice recorder | Off in the MVP. |
| Empty Likes, Compliments and Chats | Edge state: needs the fresh demo world. |
| Invalid phone, wrong or expired code, simulated errors | Error variants of captured screens. |
| Photo verification results after the selfie | Needs the simulated review. |
| Purchase outcomes for other products | Same outcome screen. |
| Restore deleted account | Needs an account deleted and signed in to again. |
| "No account found" sheet | Needs the sign-in path with an unknown number. |
| Unmatch reason sheet | Appears after confirming, which would end the sample match. |
| Filters detail pickers | Premium only, opened from each Advanced row. |
| Settings area, status and quick legal sheets | Not triggered. The area sheet is captured from onboarding. |
| Report and Block from Discover or a Compliment | Same sheets as those from Chat. |
| Real Android permission dialogs, camera, photo picker | The demo uses in-app primers. |

## Capture notes
- `Discover-out-of-likes` keeps only its top section, since the rest repeats Discover.
- `Edit-prompt` matches `Prompt-browser`: the same screen reached from a different place.
- `Photo-verification-pose` shows a black viewfinder because the build has no live camera preview.
- Scrolling screens use sections with overlap. No stitched overviews were made.

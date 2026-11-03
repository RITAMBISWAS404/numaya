# V16 screen inventory

**Scope:** V16 restyles every screen that V11 themes (`TIIMO_SCREENS` in `src/flows/Flows.jsx`), plus
the welcome screen. Nothing else changes.

**Activation:**
- `flows.html?screen=<id>&theme=withings` for one screen;
- `flows.html?theme=withings` for all of them;
- `?theme=withings` for the welcome screen.

**Captures:** every one of the 29 gallery states below exists for V11 (`screenshots/v11/screens/`),
for V16 (`screenshots/v16/screens/`) and as a side-by-side (`screenshots/compare-v11-v16/`).

## Screens

| Screen (`id`) | States captured (gallery number) | Geometry-checked | Notes |
|---|---|---|---|
| Welcome | | a11y only | wordmark in Fraunces, Hanken title |
| Basics, Photos, Interests (onboarding) | | via the E2E scope check | themed with V11; not in the 29-state set |
| Discover (`discovery`) | 019 default, 020 full page, 022 actions, 023 filters sheet, 145 at 375 × 667 | yes; also with the filters sheet open | SuperSwipe blue, Like black, Pass outline |
| Like back (`like-profile`) | 059 | yes | info card in the tint; Pass outline, Like back black |
| Likes (`likes`) | 054 default, 058 empty, 157 at 375 × 667 | yes | tinted current filter, accent "New" badges |
| Match (`match`) | 030 default, 032 typing, 033 no match, 146 at 375 × 667 | yes; seeded and empty | tinted scallop, your avatar white |
| Messages (`chats`) | 034 default, 037 empty, 052 filtered empty, 147 at 375 × 667 | yes | red unread counts, "Your move" in the tint |
| Chat (`chat`) | 038 conversation, 045 unmatch sheet | yes | blue bubbles for you, white for them; red Unmatch |
| Activity (`activity`) | | via the E2E scope check | themed with V11; not in the 29-state set |
| Profile (`profile`) | 099 default, 100 full page, 158 at 375 × 667 | yes | circle avatar, eyebrows, black "Write a bio" |
| Edit profile (`edit`) | 102 default, 103 full page | yes | tinted Edit / Preview, track-grey photo slots |
| Prompt editor (`prompt`) | 108 | yes | black radios, ink edge on the chosen card, taupe disabled Save |
| Settings (`settings`) | 111 default, 112 full page, 113 snooze on, 149 at 375 × 667 | yes | green switches, blue slider fill, uppercase eyebrows |

## Viewports
- 393 × 852 for every state above;
- 375 × 667 for gallery states 145–158;
- the layout check also runs every geometry-checked screen at both sizes.

## Not in scope
Unchanged at every URL without `?theme=withings`:
- the production default;
- V11 (`?theme=tiimo`);
- screens outside `TIIMO_SCREENS`;
- the design-system showcase.

The E2E suite verifies this, and the gallery comparisons under Verification in
[../README.md](../README.md) confirm it pixel for pixel.

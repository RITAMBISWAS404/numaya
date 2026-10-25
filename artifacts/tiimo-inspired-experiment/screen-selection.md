# Screen selection

I chose twelve distinct, implemented screens. They come from the route definitions
(`src/flows/Flows.jsx` and the prototype in `src/prototype/App.jsx`) and the project gallery. Each
target in the brief maps to one existing screen; no route was invented.

The theme turns on with `?theme=tiimo` and applies to these screens only. It is set in
`TIIMO_SCREENS` in `src/flows/Flows.jsx` and, for Welcome, in `src/prototype/screens/Welcome.jsx`.
Gallery numbers refer to the [baseline](screenshots/baseline/README.md) and the
[Tiimo-inspired](screenshots/tiimo-inspired/README.md) captures, which share the same numbering.

| # | Brief target | Screen (route) | Captured states (gallery #) | Components exercised | Why this screen |
|---|---|---|---|---|---|
| 1 | Welcome / entry | Welcome (`index.html?theme=tiimo`) | 001, 140 (375) | Wordmark, display headline, primary + quiet buttons, reserved hero slot | The first brand moment, with display type and an action hierarchy. |
| 2 | Basic profile setup | The basics (`?screen=basics`) | 013, 015 (error) | Text fields, radio and checkbox option cards, step progress, FAB, field error | Forms and selection controls. |
| 3 | Photo management | Add photos (`?screen=photos`) | 018 | Photo grid, filled and empty slots, remove buttons, info card | Media containers and "add" affordances. |
| 4 | Interest selection | Interests and prompt (`?screen=interests`) | 016, 017 (max), 144 (375) | Chip sets with group labels, selected / unavailable chips, the prompt card | The most colour- and emoji-relevant screen. |
| 5 | Discover feed | Home (`?screen=discovery`) | 019, 020 (full), 021, 022, 023 (filters sheet), 145 (375) | Profile card with photo and scrim, profile sections, "You both like", action bar, tab bar, sheet | Core identity and actions. |
| 6 | Full profile detail | Like back (`?screen=like-profile`) | 059, 060 | Info card, full profile card, profile sections, Pass / Like back | A complete profile with a primary/secondary pair. Distinct from Discover. |
| 7 | Incoming likes | Likes (`?screen=likes`) | 054, 058 (empty), 157 (375) | Filter chips, person tiles with "New" tags, empty state | A dense collection of profiles. |
| 8 | Match confirmation | It's a match (`?screen=match`) | 030, 031 (full), 032 (typing), 146 (375) | Organic portrait pair, shared-interest chips, composer, quiet action | The emotional moment. |
| 9 | Chat list | Messages (`?screen=chats`) | 034, 035 (many matches), 037 (empty), 147 (375) | Search, new-match rail, filter chips, conversation rows, unread and "Your move" | Avatars, previews and unread states. |
| 10 | Conversation | Conversation (`?screen=chat`) | 038, 039 (typing), 042 (new match), 045 (unmatch sheet), 148 (375) | Message bubbles, composer, send, chat header, openers, sheet | Text-heavy reading and composing. |
| 11 | Profile / prompt editor | Edit prompt (`?screen=prompt`) | 108, 109 (focused), 110 (changed) | Option rows, text area with character count, primary save | Editing with a character limit. |
| 12 | Supporting screen | Activity Explore (`?screen=activity`) | 061, 062 (full), 064 (filters sheet), 153 (375) | Segmented tabs, category filter chips, activity cards with status tags, sheet | The most component diversity not covered above: cards with media, categories, statuses. |

**Coverage:** 12 of 12 screens and 39 captured states, including 8 at 375 × 667. Status by screen
is in the [README](README.md#screens).

Screens outside the experiment keep the approved design even with `?theme=tiimo`. These include
phone number, verification, profile setup intro, My profile, Edit profile, Settings, Activity
details and every account screen.

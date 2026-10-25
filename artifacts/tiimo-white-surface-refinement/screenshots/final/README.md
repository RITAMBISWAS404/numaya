# Numaya UI gallery

Every designed screen and meaningful state, numbered in the order a person meets them. Generated
by `npm run gallery` (`scripts/gallery.mjs`) from the running prototype, so it can be regenerated
after any change.

- **Mobile:** 393 × 852 CSS pixels (iPhone 15 size) at 2× pixel density, so each image is 786 × 1704.
  Flow screens are captured in single-screen mode (`flows.html?screen=<id>`); onboarding comes from
  the prototype (`index.html`) on a phone context.
- **Full page** (`-fullpage-393w`): long, scrolling screens captured with all their content.
- **Desktop** (`-1440x900`): the prototype, flow previews and design system at desktop width.
- **Small-phone QA** (`-375x667`): the screens most at risk of crowding, at iPhone SE size.
- States are reached by interaction, or by seeding the preview's saved session for states that take
  many steps (see `state` in [manifest.json](manifest.json)). Captured with reduced motion so
  animations show their settled frame; the demo verification code is fixed.
- Photo areas are neutral placeholders until licensed photography is supplied. Outcome, empty-state
  and spot illustrations are Numaya's own SVG scenes (`Illustration`); the Welcome hero stays a
  reserved, empty slot until its artwork is supplied.

## Contact sheets

- [All screens](contact-sheet-all.png)
- [Onboarding](contact-sheets/01-onboarding.png)
- [Home: profiles and filters](contact-sheets/02-home-profile-filters.png)
- [Likes, matches and messages](contact-sheets/03-likes-matches-messaging.png)
- [Small-phone QA (375 × 667)](contact-sheets/07-qa-375.png)

## Onboarding

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 001 | Welcome | Viewport · `index.html (onboarding prototype)` |  | [001-welcome-393x852.png](screens/001-welcome-393x852.png) |
| 013 | The basics | Viewport · `flows.html?screen=basics&theme=tiimo` |  | [013-basics-393x852.png](screens/013-basics-393x852.png) |
| 014 | The basics: first-name field focused | Viewport · `flows.html?screen=basics&theme=tiimo` |  | [014-basics-name-focused-393x852.png](screens/014-basics-name-focused-393x852.png) |
| 015 | The basics: under-18 error | Viewport · `flows.html?screen=basics&theme=tiimo` | Birth year 2012 typed. | [015-basics-underage-error-393x852.png](screens/015-basics-underage-error-393x852.png) |
| 016 | Interests and prompt | Viewport · `flows.html?screen=interests&theme=tiimo` |  | [016-interests-prompt-393x852.png](screens/016-interests-prompt-393x852.png) |
| 017 | Interests: five chosen, the rest locked | Viewport · `flows.html?screen=interests&theme=tiimo` | Seeded with five interests; unselected chips are disabled at the maximum. | [017-interests-max-393x852.png](screens/017-interests-max-393x852.png) |

## Home: profiles and filters

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 019 | Home: profile card | Viewport · `flows.html?screen=discovery&theme=tiimo` |  | [019-discover-393x852.png](screens/019-discover-393x852.png) |
| 021 | Home: “You both like” card | Viewport · `flows.html?screen=discovery&theme=tiimo` |  | [021-discover-you-both-like-393x852.png](screens/021-discover-you-both-like-393x852.png) |

## Likes, matches and messages

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 030 | It’s a match | Viewport · `flows.html?screen=match&theme=tiimo` | Seeded as right after liking Maya, who liked you. | [030-match-393x852.png](screens/030-match-393x852.png) |
| 032 | It’s a match: first message typed | Viewport · `flows.html?screen=match&theme=tiimo` |  | [032-match-typing-393x852.png](screens/032-match-typing-393x852.png) |
| 038 | Conversation | Viewport · `flows.html?screen=chat&theme=tiimo` |  | [038-chat-conversation-393x852.png](screens/038-chat-conversation-393x852.png) |
| 039 | Conversation: typing (send pill active) | Viewport · `flows.html?screen=chat&theme=tiimo` |  | [039-chat-typing-393x852.png](screens/039-chat-typing-393x852.png) |
| 043 | Conversation: long messages (edge case) | Viewport · `flows.html?screen=chat&theme=tiimo` | Edge case: seeded thread with long messages. | [043-chat-long-messages-393x852.png](screens/043-chat-long-messages-393x852.png) |

## Small-phone QA (375 × 667)

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 140 | QA 375: Welcome | Viewport · `index.html (onboarding prototype)` |  | [140-qa-welcome-375x667.png](screens/140-qa-welcome-375x667.png) |
| 144 | QA 375: Interests and prompt | Viewport · `flows.html?screen=interests&theme=tiimo` |  | [144-qa-interests-375x667.png](screens/144-qa-interests-375x667.png) |
| 145 | QA 375: Home profile card | Viewport · `flows.html?screen=discovery&theme=tiimo` |  | [145-qa-discover-375x667.png](screens/145-qa-discover-375x667.png) |
| 146 | QA 375: It’s a match | Viewport · `flows.html?screen=match&theme=tiimo` |  | [146-qa-match-375x667.png](screens/146-qa-match-375x667.png) |
| 148 | QA 375: Conversation with long messages | Viewport · `flows.html?screen=chat&theme=tiimo` |  | [148-qa-chat-long-messages-375x667.png](screens/148-qa-chat-long-messages-375x667.png) |

18 captures: 18 viewport, 0 full page (2 MB of screenshots; all-screens sheet 263 KB).

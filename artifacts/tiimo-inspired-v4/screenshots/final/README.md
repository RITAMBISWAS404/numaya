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
- [Activity](contact-sheets/04-activity.png)
- [Small-phone QA (375 × 667)](contact-sheets/07-qa-375.png)

## Onboarding

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
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
| 034 | Messages: search, new matches, filters and conversations | Viewport · `flows.html?screen=chats&theme=tiimo` |  | [034-chats-393x852.png](screens/034-chats-393x852.png) |
| 038 | Conversation | Viewport · `flows.html?screen=chat&theme=tiimo` |  | [038-chat-conversation-393x852.png](screens/038-chat-conversation-393x852.png) |
| 042 | Conversation: new match intro with opening prompts | Viewport · `flows.html?screen=chat&theme=tiimo` | Seeded with Jo (no messages yet) as the open chat. | [042-chat-new-match-393x852.png](screens/042-chat-new-match-393x852.png) |
| 054 | Likes: all | Viewport · `flows.html?screen=likes&theme=tiimo` |  | [054-likes-393x852.png](screens/054-likes-393x852.png) |
| 059 | Likes: a person who liked you (like back or pass) | Viewport · `flows.html?screen=like-profile&theme=tiimo` |  | [059-like-profile-393x852.png](screens/059-like-profile-393x852.png) |

## Activity

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 061 | Activity: Explore | Viewport · `flows.html?screen=activity&theme=tiimo` |  | [061-activity-393x852.png](screens/061-activity-393x852.png) |

## Small-phone QA (375 × 667)

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 144 | QA 375: Interests and prompt | Viewport · `flows.html?screen=interests&theme=tiimo` |  | [144-qa-interests-375x667.png](screens/144-qa-interests-375x667.png) |
| 145 | QA 375: Home profile card | Viewport · `flows.html?screen=discovery&theme=tiimo` |  | [145-qa-discover-375x667.png](screens/145-qa-discover-375x667.png) |
| 146 | QA 375: It’s a match | Viewport · `flows.html?screen=match&theme=tiimo` |  | [146-qa-match-375x667.png](screens/146-qa-match-375x667.png) |
| 147 | QA 375: Chats | Viewport · `flows.html?screen=chats&theme=tiimo` |  | [147-qa-chats-375x667.png](screens/147-qa-chats-375x667.png) |
| 148 | QA 375: Conversation with long messages | Viewport · `flows.html?screen=chat&theme=tiimo` |  | [148-qa-chat-long-messages-375x667.png](screens/148-qa-chat-long-messages-375x667.png) |

17 captures: 17 viewport, 0 full page (1 MB of screenshots; all-screens sheet 246 KB).

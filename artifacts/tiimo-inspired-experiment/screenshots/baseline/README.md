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
- [Profile, readiness, settings and account](contact-sheets/05-profile-settings.png)
- [Small-phone QA (375 × 667)](contact-sheets/07-qa-375.png)

## Onboarding

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 001 | Welcome | Viewport · `index.html (onboarding prototype)` |  | [001-welcome-393x852.png](screens/001-welcome-393x852.png) |
| 013 | The basics | Viewport · `flows.html?screen=basics` |  | [013-basics-393x852.png](screens/013-basics-393x852.png) |
| 015 | The basics: under-18 error | Viewport · `flows.html?screen=basics` | Birth year 2012 typed. | [015-basics-underage-error-393x852.png](screens/015-basics-underage-error-393x852.png) |
| 016 | Interests and prompt | Viewport · `flows.html?screen=interests` |  | [016-interests-prompt-393x852.png](screens/016-interests-prompt-393x852.png) |
| 017 | Interests: five chosen, the rest locked | Viewport · `flows.html?screen=interests` | Seeded with five interests; unselected chips are disabled at the maximum. | [017-interests-max-393x852.png](screens/017-interests-max-393x852.png) |
| 018 | Add photos | Viewport · `flows.html?screen=photos` |  | [018-photos-393x852.png](screens/018-photos-393x852.png) |

## Home: profiles and filters

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 019 | Home: profile card | Viewport · `flows.html?screen=discovery` |  | [019-discover-393x852.png](screens/019-discover-393x852.png) |
| 020 | Home: the full profile scroll | Full page · `flows.html?screen=discovery` |  | [020-discover-fullpage-393w.png](screens/020-discover-fullpage-393w.png) |
| 021 | Home: “You both like” card | Viewport · `flows.html?screen=discovery` |  | [021-discover-you-both-like-393x852.png](screens/021-discover-you-both-like-393x852.png) |
| 022 | Home: Pass / SuperSwipe / Like at the end of the profile | Viewport · `flows.html?screen=discovery` |  | [022-discover-actions-393x852.png](screens/022-discover-actions-393x852.png) |
| 023 | Home: filters sheet | Viewport · `flows.html?screen=discovery` |  | [023-discover-filters-sheet-393x852.png](screens/023-discover-filters-sheet-393x852.png) |

## Likes, matches and messages

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 030 | It’s a match | Viewport · `flows.html?screen=match` | Seeded as right after liking Maya, who liked you. | [030-match-393x852.png](screens/030-match-393x852.png) |
| 031 | It’s a match (full page) | Full page · `flows.html?screen=match` | Seeded right after liking Maya back. | [031-match-fullpage-393w.png](screens/031-match-fullpage-393w.png) |
| 032 | It’s a match: first message typed | Viewport · `flows.html?screen=match` |  | [032-match-typing-393x852.png](screens/032-match-typing-393x852.png) |
| 034 | Messages: search, new matches, filters and conversations | Viewport · `flows.html?screen=chats` |  | [034-chats-393x852.png](screens/034-chats-393x852.png) |
| 035 | Messages: several new matches (portrait previews, horizontal rail) | Viewport · `flows.html?screen=chats` | Seeded with four unopened matches. | [035-chats-many-matches-393x852.png](screens/035-chats-many-matches-393x852.png) |
| 037 | Messages: empty | Viewport · `flows.html?screen=chats` | Seeded with no matches. | [037-chats-empty-393x852.png](screens/037-chats-empty-393x852.png) |
| 038 | Conversation | Viewport · `flows.html?screen=chat` |  | [038-chat-conversation-393x852.png](screens/038-chat-conversation-393x852.png) |
| 039 | Conversation: typing (send pill active) | Viewport · `flows.html?screen=chat` |  | [039-chat-typing-393x852.png](screens/039-chat-typing-393x852.png) |
| 042 | Conversation: new match intro with opening prompts | Viewport · `flows.html?screen=chat` | Seeded with Jo (no messages yet) as the open chat. | [042-chat-new-match-393x852.png](screens/042-chat-new-match-393x852.png) |
| 045 | Unmatch confirmation sheet | Viewport · `flows.html?screen=chat` |  | [045-chat-unmatch-sheet-393x852.png](screens/045-chat-unmatch-sheet-393x852.png) |
| 054 | Likes: all | Viewport · `flows.html?screen=likes` |  | [054-likes-393x852.png](screens/054-likes-393x852.png) |
| 058 | Likes: empty (every like handled) | Viewport · `flows.html?screen=likes` | Seeded with every like handled. | [058-likes-empty-393x852.png](screens/058-likes-empty-393x852.png) |
| 059 | Likes: a person who liked you (like back or pass) | Viewport · `flows.html?screen=like-profile` |  | [059-like-profile-393x852.png](screens/059-like-profile-393x852.png) |
| 060 | Likes: an already-matched like (handled) | Viewport · `flows.html?screen=like-profile` |  | [060-like-profile-matched-393x852.png](screens/060-like-profile-matched-393x852.png) |

## Activity

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 061 | Activity: Explore | Viewport · `flows.html?screen=activity` |  | [061-activity-393x852.png](screens/061-activity-393x852.png) |
| 062 | Activity: Explore (full page) | Full page · `flows.html?screen=activity` |  | [062-activity-fullpage-393w.png](screens/062-activity-fullpage-393w.png) |
| 064 | Activity: date and distance filters | Viewport · `flows.html?screen=activity` |  | [064-activity-filters-sheet-393x852.png](screens/064-activity-filters-sheet-393x852.png) |

## Profile, readiness, settings and account

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 108 | Edit prompt | Viewport · `flows.html?screen=prompt` |  | [108-prompt-editor-393x852.png](screens/108-prompt-editor-393x852.png) |
| 109 | Edit prompt: answer field focused | Viewport · `flows.html?screen=prompt` |  | [109-prompt-editor-focused-393x852.png](screens/109-prompt-editor-focused-393x852.png) |
| 110 | Edit prompt: new question and answer, ready to save | Viewport · `flows.html?screen=prompt` |  | [110-prompt-editor-changed-393x852.png](screens/110-prompt-editor-changed-393x852.png) |

## Small-phone QA (375 × 667)

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 140 | QA 375: Welcome | Viewport · `index.html (onboarding prototype)` |  | [140-qa-welcome-375x667.png](screens/140-qa-welcome-375x667.png) |
| 144 | QA 375: Interests and prompt | Viewport · `flows.html?screen=interests` |  | [144-qa-interests-375x667.png](screens/144-qa-interests-375x667.png) |
| 145 | QA 375: Home profile card | Viewport · `flows.html?screen=discovery` |  | [145-qa-discover-375x667.png](screens/145-qa-discover-375x667.png) |
| 146 | QA 375: It’s a match | Viewport · `flows.html?screen=match` |  | [146-qa-match-375x667.png](screens/146-qa-match-375x667.png) |
| 147 | QA 375: Chats | Viewport · `flows.html?screen=chats` |  | [147-qa-chats-375x667.png](screens/147-qa-chats-375x667.png) |
| 148 | QA 375: Conversation with long messages | Viewport · `flows.html?screen=chat` |  | [148-qa-chat-long-messages-375x667.png](screens/148-qa-chat-long-messages-375x667.png) |
| 153 | QA 375: Activity Explore | Viewport · `flows.html?screen=activity` |  | [153-qa-activity-375x667.png](screens/153-qa-activity-375x667.png) |
| 157 | QA 375: Likes | Viewport · `flows.html?screen=likes` |  | [157-qa-likes-375x667.png](screens/157-qa-likes-375x667.png) |

39 captures: 36 viewport, 3 full page (4 MB of screenshots; all-screens sheet 589 KB).

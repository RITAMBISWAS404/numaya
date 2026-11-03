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
- [Home: profiles and filters](contact-sheets/02-home-profile-filters.png)
- [Likes, matches and messages](contact-sheets/03-likes-matches-messaging.png)
- [Profile, readiness, settings and account](contact-sheets/05-profile-settings.png)
- [Small-phone QA (375 × 667)](contact-sheets/07-qa-375.png)

## Home: profiles and filters

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 019 | Home: profile card | Viewport · `flows.html?screen=discovery&theme=withings` |  | [019-discover-393x852.png](screens/019-discover-393x852.png) |
| 020 | Home: the full profile scroll | Full page · `flows.html?screen=discovery&theme=withings` |  | [020-discover-fullpage-393w.png](screens/020-discover-fullpage-393w.png) |
| 022 | Home: Pass / SuperSwipe / Like at the end of the profile | Viewport · `flows.html?screen=discovery&theme=withings` |  | [022-discover-actions-393x852.png](screens/022-discover-actions-393x852.png) |
| 023 | Home: filters sheet | Viewport · `flows.html?screen=discovery&theme=withings` |  | [023-discover-filters-sheet-393x852.png](screens/023-discover-filters-sheet-393x852.png) |

## Likes, matches and messages

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 030 | It’s a match | Viewport · `flows.html?screen=match&theme=withings` | Seeded as right after liking Maya, who liked you. | [030-match-393x852.png](screens/030-match-393x852.png) |
| 032 | It’s a match: first message typed | Viewport · `flows.html?screen=match&theme=withings` |  | [032-match-typing-393x852.png](screens/032-match-typing-393x852.png) |
| 033 | No new match yet | Viewport · `flows.html?screen=match&theme=withings` |  | [033-match-empty-393x852.png](screens/033-match-empty-393x852.png) |
| 034 | Messages: search, new matches, filters and conversations | Viewport · `flows.html?screen=chats&theme=withings` |  | [034-chats-393x852.png](screens/034-chats-393x852.png) |
| 037 | Messages: empty | Viewport · `flows.html?screen=chats&theme=withings` | Seeded with no matches. | [037-chats-empty-393x852.png](screens/037-chats-empty-393x852.png) |
| 038 | Conversation | Viewport · `flows.html?screen=chat&theme=withings` |  | [038-chat-conversation-393x852.png](screens/038-chat-conversation-393x852.png) |
| 045 | Unmatch confirmation sheet | Viewport · `flows.html?screen=chat&theme=withings` |  | [045-chat-unmatch-sheet-393x852.png](screens/045-chat-unmatch-sheet-393x852.png) |
| 052 | Messages: search + Unread filter with nothing to show | Viewport · `flows.html?screen=chats&theme=withings` |  | [052-chats-filter-empty-393x852.png](screens/052-chats-filter-empty-393x852.png) |
| 054 | Likes: all | Viewport · `flows.html?screen=likes&theme=withings` |  | [054-likes-393x852.png](screens/054-likes-393x852.png) |
| 058 | Likes: empty (every like handled) | Viewport · `flows.html?screen=likes&theme=withings` | Seeded with every like handled. | [058-likes-empty-393x852.png](screens/058-likes-empty-393x852.png) |
| 059 | Likes: a person who liked you (like back or pass) | Viewport · `flows.html?screen=like-profile&theme=withings` |  | [059-like-profile-393x852.png](screens/059-like-profile-393x852.png) |

## Profile, readiness, settings and account

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 099 | My profile | Viewport · `flows.html?screen=profile&theme=withings` |  | [099-profile-393x852.png](screens/099-profile-393x852.png) |
| 100 | My profile (full page) | Full page · `flows.html?screen=profile&theme=withings` |  | [100-profile-fullpage-393w.png](screens/100-profile-fullpage-393w.png) |
| 102 | Edit profile | Viewport · `flows.html?screen=edit&theme=withings` |  | [102-edit-profile-393x852.png](screens/102-edit-profile-393x852.png) |
| 103 | Edit profile (full page) | Full page · `flows.html?screen=edit&theme=withings` |  | [103-edit-profile-fullpage-393w.png](screens/103-edit-profile-fullpage-393w.png) |
| 108 | Edit prompt | Viewport · `flows.html?screen=prompt&theme=withings` |  | [108-prompt-editor-393x852.png](screens/108-prompt-editor-393x852.png) |
| 111 | Settings | Viewport · `flows.html?screen=settings&theme=withings` |  | [111-settings-393x852.png](screens/111-settings-393x852.png) |
| 112 | Settings (full page) | Full page · `flows.html?screen=settings&theme=withings` |  | [112-settings-fullpage-393w.png](screens/112-settings-fullpage-393w.png) |
| 113 | Settings: Snooze on | Viewport · `flows.html?screen=settings&theme=withings` | Seeded with Snooze on. | [113-settings-snooze-on-393x852.png](screens/113-settings-snooze-on-393x852.png) |

## Small-phone QA (375 × 667)

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 145 | QA 375: Home profile card | Viewport · `flows.html?screen=discovery&theme=withings` |  | [145-qa-discover-375x667.png](screens/145-qa-discover-375x667.png) |
| 146 | QA 375: It’s a match | Viewport · `flows.html?screen=match&theme=withings` |  | [146-qa-match-375x667.png](screens/146-qa-match-375x667.png) |
| 147 | QA 375: Chats | Viewport · `flows.html?screen=chats&theme=withings` |  | [147-qa-chats-375x667.png](screens/147-qa-chats-375x667.png) |
| 149 | QA 375: Settings | Viewport · `flows.html?screen=settings&theme=withings` |  | [149-qa-settings-375x667.png](screens/149-qa-settings-375x667.png) |
| 157 | QA 375: Likes | Viewport · `flows.html?screen=likes&theme=withings` |  | [157-qa-likes-375x667.png](screens/157-qa-likes-375x667.png) |
| 158 | QA 375: Profile home | Viewport · `flows.html?screen=profile&theme=withings` |  | [158-qa-profile-375x667.png](screens/158-qa-profile-375x667.png) |

29 captures: 25 viewport, 4 full page (2 MB of screenshots; all-screens sheet 438 KB).

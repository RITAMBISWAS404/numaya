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
- Photo areas and illustration slots are neutral placeholders until licensed photography and
  artwork are supplied.

## Contact sheets

- [All screens](contact-sheet-all.png)
- [Onboarding](contact-sheets/01-onboarding.png)
- [Discover, profile and filters](contact-sheets/02-discover-profile-filters.png)
- [Matches and messaging](contact-sheets/03-matches-messaging.png)
- [Profile, editing and settings](contact-sheets/04-profile-settings.png)
- [Desktop context](contact-sheets/05-desktop.png)
- [Small-phone QA (375 × 667)](contact-sheets/06-qa-375.png)

## Onboarding

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 001 | Welcome | Viewport · `index.html (onboarding prototype)` |  | [001-welcome-393x852.png](screens/001-welcome-393x852.png) |
| 002 | Phone number (empty, field focused) | Viewport · `index.html (onboarding prototype)` |  | [002-phone-entry-393x852.png](screens/002-phone-entry-393x852.png) |
| 003 | Country selector sheet | Viewport · `index.html (onboarding prototype)` |  | [003-country-selector-393x852.png](screens/003-country-selector-393x852.png) |
| 004 | Country search results | Viewport · `index.html (onboarding prototype)` |  | [004-country-search-393x852.png](screens/004-country-search-393x852.png) |
| 005 | Phone number (complete, Send code enabled) | Viewport · `index.html (onboarding prototype)` |  | [005-phone-entry-complete-393x852.png](screens/005-phone-entry-complete-393x852.png) |
| 006 | Verify code: simulated text-message banner (autofill) | Viewport · `index.html (onboarding prototype)` | The simulated iOS banner is part of the prototype's autofill demo; the other code states are captured after it hides. | [006-verify-code-sms-banner-393x852.png](screens/006-verify-code-sms-banner-393x852.png) |
| 007 | Verify code: first cell focused | Viewport · `index.html (onboarding prototype)` |  | [007-verify-code-focused-393x852.png](screens/007-verify-code-focused-393x852.png) |
| 008 | Verify code: three digits entered | Viewport · `index.html (onboarding prototype)` | 298 typed. | [008-verify-code-typing-393x852.png](screens/008-verify-code-typing-393x852.png) |
| 009 | Verify code: wrong code | Viewport · `index.html (onboarding prototype)` | Wrong code 111111 typed. | [009-verify-code-error-393x852.png](screens/009-verify-code-error-393x852.png) |
| 010 | Verified success sheet | Viewport · `index.html (onboarding prototype)` | Code from the simulated text message typed in; the demo code is fixed for captures. | [010-verify-success-393x852.png](screens/010-verify-success-393x852.png) |
| 011 | You’re verified → profile setup (nothing done yet) | Viewport · `flows.html?screen=intro` |  | [011-verified-intro-393x852.png](screens/011-verified-intro-393x852.png) |
| 012 | Profile setup: basics done, interests next | Viewport · `flows.html?screen=intro` | Seeded: the basics finished. | [012-verified-intro-progress-393x852.png](screens/012-verified-intro-progress-393x852.png) |
| 013 | The basics | Viewport · `flows.html?screen=basics` |  | [013-basics-393x852.png](screens/013-basics-393x852.png) |
| 014 | The basics: first-name field focused | Viewport · `flows.html?screen=basics` |  | [014-basics-name-focused-393x852.png](screens/014-basics-name-focused-393x852.png) |
| 015 | The basics: under-18 error | Viewport · `flows.html?screen=basics` | Birth year 2012 typed. | [015-basics-underage-error-393x852.png](screens/015-basics-underage-error-393x852.png) |
| 016 | Interests and prompt | Viewport · `flows.html?screen=interests` |  | [016-interests-prompt-393x852.png](screens/016-interests-prompt-393x852.png) |
| 017 | Interests: five chosen, the rest locked | Viewport · `flows.html?screen=interests` | Seeded with five interests; unselected chips are disabled at the maximum. | [017-interests-max-393x852.png](screens/017-interests-max-393x852.png) |
| 018 | Add photos | Viewport · `flows.html?screen=photos` |  | [018-photos-393x852.png](screens/018-photos-393x852.png) |

## Discover, profile and filters

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 019 | Discover profile card | Viewport · `flows.html?screen=discovery` |  | [019-discover-393x852.png](screens/019-discover-393x852.png) |
| 020 | Discover: the full profile scroll | Full page · `flows.html?screen=discovery` |  | [020-discover-fullpage-393w.png](screens/020-discover-fullpage-393w.png) |
| 021 | Discover: “You both like” card | Viewport · `flows.html?screen=discovery` |  | [021-discover-you-both-like-393x852.png](screens/021-discover-you-both-like-393x852.png) |
| 022 | Discover: Pass / SuperSwipe / Like at the end of the profile | Viewport · `flows.html?screen=discovery` |  | [022-discover-actions-393x852.png](screens/022-discover-actions-393x852.png) |
| 023 | Discover filters sheet | Viewport · `flows.html?screen=discovery` |  | [023-discover-filters-sheet-393x852.png](screens/023-discover-filters-sheet-393x852.png) |
| 024 | Discover: no one fits the filters | Viewport · `flows.html?screen=discovery` | Seeded distance 1 km. | [024-discover-no-one-fits-393x852.png](screens/024-discover-no-one-fits-393x852.png) |
| 025 | Discover: seen everyone | Viewport · `flows.html?screen=discovery` | Seeded with every sample profile already decided. | [025-discover-seen-everyone-393x852.png](screens/025-discover-seen-everyone-393x852.png) |
| 026 | Discover paused (snoozed) | Viewport · `flows.html?screen=discovery` | Seeded with Snooze on. | [026-discover-paused-393x852.png](screens/026-discover-paused-393x852.png) |

## Matches and messaging

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 027 | It’s a match | Viewport · `flows.html?screen=match` | Seeded as right after liking Maya, who liked you. | [027-match-393x852.png](screens/027-match-393x852.png) |
| 028 | No new match yet | Viewport · `flows.html?screen=match` |  | [028-match-empty-393x852.png](screens/028-match-empty-393x852.png) |
| 029 | Chats: new matches and conversations | Viewport · `flows.html?screen=chats` |  | [029-chats-393x852.png](screens/029-chats-393x852.png) |
| 030 | Chats: several new matches (capsule previews) | Viewport · `flows.html?screen=chats` | Seeded with four unopened matches. | [030-chats-many-matches-393x852.png](screens/030-chats-many-matches-393x852.png) |
| 031 | Chats: message alerts off banner | Viewport · `flows.html?screen=chats` | Seeded with new-message alerts off. | [031-chats-alerts-off-393x852.png](screens/031-chats-alerts-off-393x852.png) |
| 032 | Chats: empty | Viewport · `flows.html?screen=chats` | Seeded with no matches. | [032-chats-empty-393x852.png](screens/032-chats-empty-393x852.png) |
| 033 | Conversation | Viewport · `flows.html?screen=chat` |  | [033-chat-conversation-393x852.png](screens/033-chat-conversation-393x852.png) |
| 034 | Conversation: typing (send pill active) | Viewport · `flows.html?screen=chat` |  | [034-chat-typing-393x852.png](screens/034-chat-typing-393x852.png) |
| 035 | Conversation: new match intro | Viewport · `flows.html?screen=chat` | Seeded with Jo (no messages yet) as the open chat. | [035-chat-new-match-393x852.png](screens/035-chat-new-match-393x852.png) |
| 036 | Conversation: long messages (edge case) | Viewport · `flows.html?screen=chat` | Edge case: seeded thread with long messages. | [036-chat-long-messages-393x852.png](screens/036-chat-long-messages-393x852.png) |
| 037 | Conversation options menu | Viewport · `flows.html?screen=chat` |  | [037-chat-options-menu-393x852.png](screens/037-chat-options-menu-393x852.png) |
| 038 | Unmatch confirmation sheet | Viewport · `flows.html?screen=chat` |  | [038-chat-unmatch-sheet-393x852.png](screens/038-chat-unmatch-sheet-393x852.png) |
| 039 | Report or block sheet | Viewport · `flows.html?screen=chat` |  | [039-chat-report-sheet-393x852.png](screens/039-chat-report-sheet-393x852.png) |
| 040 | Ended: unmatched | Viewport · `flows.html?screen=chat` | Seeded: Priya unmatched. | [040-chat-unmatched-393x852.png](screens/040-chat-unmatched-393x852.png) |
| 041 | Ended: blocked and reported | Viewport · `flows.html?screen=chat` | Seeded: Priya blocked and reported. | [041-chat-blocked-393x852.png](screens/041-chat-blocked-393x852.png) |

## Profile, editing and settings

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 042 | My profile | Viewport · `flows.html?screen=profile` |  | [042-profile-393x852.png](screens/042-profile-393x852.png) |
| 043 | My profile (full page) | Full page · `flows.html?screen=profile` |  | [043-profile-fullpage-393w.png](screens/043-profile-fullpage-393w.png) |
| 044 | My profile: long name (edge case) | Viewport · `flows.html?screen=profile` | Edge case: seeded 21-character name. | [044-profile-long-name-393x852.png](screens/044-profile-long-name-393x852.png) |
| 045 | Edit profile | Viewport · `flows.html?screen=edit` |  | [045-edit-profile-393x852.png](screens/045-edit-profile-393x852.png) |
| 046 | Edit profile (full page) | Full page · `flows.html?screen=edit` |  | [046-edit-profile-fullpage-393w.png](screens/046-edit-profile-fullpage-393w.png) |
| 047 | Edit profile: photo options sheet | Viewport · `flows.html?screen=edit` |  | [047-edit-photo-options-393x852.png](screens/047-edit-photo-options-393x852.png) |
| 048 | Edit profile: empty name error | Viewport · `flows.html?screen=edit` |  | [048-edit-name-error-393x852.png](screens/048-edit-name-error-393x852.png) |
| 049 | Edit profile: Preview | Viewport · `flows.html?screen=edit` |  | [049-edit-preview-393x852.png](screens/049-edit-preview-393x852.png) |
| 050 | Edit profile: Preview (full page) | Full page · `flows.html?screen=edit` |  | [050-edit-preview-fullpage-393w.png](screens/050-edit-preview-fullpage-393w.png) |
| 051 | Edit prompt | Viewport · `flows.html?screen=prompt` |  | [051-prompt-editor-393x852.png](screens/051-prompt-editor-393x852.png) |
| 052 | Edit prompt: answer field focused | Viewport · `flows.html?screen=prompt` |  | [052-prompt-editor-focused-393x852.png](screens/052-prompt-editor-focused-393x852.png) |
| 053 | Edit prompt: new question and answer, ready to save | Viewport · `flows.html?screen=prompt` |  | [053-prompt-editor-changed-393x852.png](screens/053-prompt-editor-changed-393x852.png) |
| 054 | Settings | Viewport · `flows.html?screen=settings` |  | [054-settings-393x852.png](screens/054-settings-393x852.png) |
| 055 | Settings (full page) | Full page · `flows.html?screen=settings` |  | [055-settings-fullpage-393w.png](screens/055-settings-fullpage-393w.png) |
| 056 | Settings: Snooze on | Viewport · `flows.html?screen=settings` | Seeded with Snooze on. | [056-settings-snooze-on-393x852.png](screens/056-settings-snooze-on-393x852.png) |
| 057 | Delete account sheet | Viewport · `flows.html?screen=settings` |  | [057-settings-delete-sheet-393x852.png](screens/057-settings-delete-sheet-393x852.png) |

## Desktop context

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 058 | Desktop: onboarding prototype with brief | Viewport · `index.html (onboarding prototype)` |  | [058-desktop-prototype-1440x900.png](screens/058-desktop-prototype-1440x900.png) |
| 059 | Desktop: flow previews gallery | Viewport · `flows.html` |  | [059-desktop-flow-previews-1440x900.png](screens/059-desktop-flow-previews-1440x900.png) |
| 060 | Desktop: flow previews, Profile → Edit profile → Edit prompt | Viewport · `flows.html#profile` |  | [060-desktop-edit-profile-1440x900.png](screens/060-desktop-edit-profile-1440x900.png) |
| 061 | Desktop: design-system showcase | Viewport · `showcase.html` |  | [061-desktop-design-system-1440x900.png](screens/061-desktop-design-system-1440x900.png) |

## Small-phone QA (375 × 667)

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 062 | QA 375: Welcome | Viewport · `index.html (onboarding prototype)` |  | [062-qa-welcome-375x667.png](screens/062-qa-welcome-375x667.png) |
| 063 | QA 375: Phone number with keypad | Viewport · `index.html (onboarding prototype)` |  | [063-qa-phone-entry-375x667.png](screens/063-qa-phone-entry-375x667.png) |
| 064 | QA 375: Verify code | Viewport · `index.html (onboarding prototype)` |  | [064-qa-verify-code-375x667.png](screens/064-qa-verify-code-375x667.png) |
| 065 | QA 375: You’re verified → profile setup | Viewport · `flows.html?screen=intro` | Scrolls slightly at this height; the body becomes a tab stop. | [065-qa-verified-intro-375x667.png](screens/065-qa-verified-intro-375x667.png) |
| 066 | QA 375: Interests and prompt | Viewport · `flows.html?screen=interests` |  | [066-qa-interests-375x667.png](screens/066-qa-interests-375x667.png) |
| 067 | QA 375: Discover profile card | Viewport · `flows.html?screen=discovery` |  | [067-qa-discover-375x667.png](screens/067-qa-discover-375x667.png) |
| 068 | QA 375: It’s a match | Viewport · `flows.html?screen=match` |  | [068-qa-match-375x667.png](screens/068-qa-match-375x667.png) |
| 069 | QA 375: Chats | Viewport · `flows.html?screen=chats` |  | [069-qa-chats-375x667.png](screens/069-qa-chats-375x667.png) |
| 070 | QA 375: Conversation with long messages | Viewport · `flows.html?screen=chat` |  | [070-qa-chat-long-messages-375x667.png](screens/070-qa-chat-long-messages-375x667.png) |
| 071 | QA 375: Settings | Viewport · `flows.html?screen=settings` |  | [071-qa-settings-375x667.png](screens/071-qa-settings-375x667.png) |

71 captures: 66 viewport, 5 full page (7 MB of screenshots; all-screens sheet 931 KB).

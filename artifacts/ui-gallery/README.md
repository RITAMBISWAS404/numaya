# Numaya UI gallery

Every designed screen and meaningful state, numbered in the order a person meets them. Generated
by `npm run gallery` (`scripts/gallery.mjs`) from the running prototype, so it can be regenerated
after any change.

- **Mobile:** 393 × 852 CSS pixels (iPhone 15 size) at 2× pixel density, so each image is 786 × 1704.
  Flow screens are captured in single-screen mode (`flows.html?screen=<id>`); onboarding comes from
  the prototype (`index.html`) on a phone context.
- **Full page** (`-fullpage-393w`): long, scrolling screens captured with all their content.
- **Desktop** (`-1440x900`): the prototype, flow previews and design system at desktop width.
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

## Onboarding

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 001 | Welcome | Viewport · `index.html (onboarding prototype)` |  | [001-welcome-393x852.png](screens/001-welcome-393x852.png) |
| 002 | Phone number (empty) | Viewport · `index.html (onboarding prototype)` |  | [002-phone-entry-393x852.png](screens/002-phone-entry-393x852.png) |
| 003 | Country selector sheet | Viewport · `index.html (onboarding prototype)` |  | [003-country-selector-393x852.png](screens/003-country-selector-393x852.png) |
| 004 | Country search results | Viewport · `index.html (onboarding prototype)` |  | [004-country-search-393x852.png](screens/004-country-search-393x852.png) |
| 005 | Phone number (complete, Send code enabled) | Viewport · `index.html (onboarding prototype)` |  | [005-phone-entry-complete-393x852.png](screens/005-phone-entry-complete-393x852.png) |
| 006 | Verify code with the text-message banner | Viewport · `index.html (onboarding prototype)` |  | [006-verify-code-393x852.png](screens/006-verify-code-393x852.png) |
| 007 | Verify code: wrong code | Viewport · `index.html (onboarding prototype)` | Wrong code 111111 typed. | [007-verify-code-error-393x852.png](screens/007-verify-code-error-393x852.png) |
| 008 | Verified success sheet | Viewport · `index.html (onboarding prototype)` | Code from the simulated text message typed in; the demo code is fixed for captures. | [008-verify-success-393x852.png](screens/008-verify-success-393x852.png) |
| 009 | You’re verified → profile setup | Viewport · `flows.html?screen=intro` |  | [009-verified-intro-393x852.png](screens/009-verified-intro-393x852.png) |
| 010 | The basics | Viewport · `flows.html?screen=basics` |  | [010-basics-393x852.png](screens/010-basics-393x852.png) |
| 011 | The basics: under-18 error | Viewport · `flows.html?screen=basics` | Birth year 2012 typed. | [011-basics-underage-error-393x852.png](screens/011-basics-underage-error-393x852.png) |
| 012 | Interests and prompt | Viewport · `flows.html?screen=interests` |  | [012-interests-prompt-393x852.png](screens/012-interests-prompt-393x852.png) |
| 013 | Interests: five chosen, the rest locked | Viewport · `flows.html?screen=interests` | Seeded with five interests; unselected chips are disabled at the maximum. | [013-interests-max-393x852.png](screens/013-interests-max-393x852.png) |
| 014 | Add photos | Viewport · `flows.html?screen=photos` |  | [014-photos-393x852.png](screens/014-photos-393x852.png) |

## Discover, profile and filters

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 015 | Discover profile card | Viewport · `flows.html?screen=discovery` |  | [015-discover-393x852.png](screens/015-discover-393x852.png) |
| 016 | Discover: the full profile scroll | Full page · `flows.html?screen=discovery` |  | [016-discover-fullpage-393w.png](screens/016-discover-fullpage-393w.png) |
| 017 | Discover filters sheet | Viewport · `flows.html?screen=discovery` |  | [017-discover-filters-sheet-393x852.png](screens/017-discover-filters-sheet-393x852.png) |
| 018 | Discover: no one fits the filters | Viewport · `flows.html?screen=discovery` | Seeded distance 1 km. | [018-discover-no-one-fits-393x852.png](screens/018-discover-no-one-fits-393x852.png) |
| 019 | Discover: seen everyone | Viewport · `flows.html?screen=discovery` | Seeded with every sample profile already decided. | [019-discover-seen-everyone-393x852.png](screens/019-discover-seen-everyone-393x852.png) |
| 020 | Discover paused (snoozed) | Viewport · `flows.html?screen=discovery` | Seeded with Snooze on. | [020-discover-paused-393x852.png](screens/020-discover-paused-393x852.png) |

## Matches and messaging

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 021 | It’s a match | Viewport · `flows.html?screen=match` | Seeded as right after liking Maya, who liked you. | [021-match-393x852.png](screens/021-match-393x852.png) |
| 022 | No new match yet | Viewport · `flows.html?screen=match` |  | [022-match-empty-393x852.png](screens/022-match-empty-393x852.png) |
| 023 | Chats: new matches and conversations | Viewport · `flows.html?screen=chats` |  | [023-chats-393x852.png](screens/023-chats-393x852.png) |
| 024 | Chats: message alerts off banner | Viewport · `flows.html?screen=chats` | Seeded with new-message alerts off. | [024-chats-alerts-off-393x852.png](screens/024-chats-alerts-off-393x852.png) |
| 025 | Chats: empty | Viewport · `flows.html?screen=chats` | Seeded with no matches. | [025-chats-empty-393x852.png](screens/025-chats-empty-393x852.png) |
| 026 | Conversation | Viewport · `flows.html?screen=chat` |  | [026-chat-conversation-393x852.png](screens/026-chat-conversation-393x852.png) |
| 027 | Conversation: new match intro | Viewport · `flows.html?screen=chat` | Seeded with Jo (no messages yet) as the open chat. | [027-chat-new-match-393x852.png](screens/027-chat-new-match-393x852.png) |
| 028 | Conversation: long messages (edge case) | Viewport · `flows.html?screen=chat` | Edge case: seeded thread with long messages. | [028-chat-long-messages-393x852.png](screens/028-chat-long-messages-393x852.png) |
| 029 | Conversation options menu | Viewport · `flows.html?screen=chat` |  | [029-chat-options-menu-393x852.png](screens/029-chat-options-menu-393x852.png) |
| 030 | Unmatch confirmation sheet | Viewport · `flows.html?screen=chat` |  | [030-chat-unmatch-sheet-393x852.png](screens/030-chat-unmatch-sheet-393x852.png) |
| 031 | Report or block sheet | Viewport · `flows.html?screen=chat` |  | [031-chat-report-sheet-393x852.png](screens/031-chat-report-sheet-393x852.png) |
| 032 | Ended: unmatched | Viewport · `flows.html?screen=chat` | Seeded: Priya unmatched. | [032-chat-unmatched-393x852.png](screens/032-chat-unmatched-393x852.png) |
| 033 | Ended: blocked and reported | Viewport · `flows.html?screen=chat` | Seeded: Priya blocked and reported. | [033-chat-blocked-393x852.png](screens/033-chat-blocked-393x852.png) |

## Profile, editing and settings

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 034 | My profile | Viewport · `flows.html?screen=profile` |  | [034-profile-393x852.png](screens/034-profile-393x852.png) |
| 035 | My profile (full page) | Full page · `flows.html?screen=profile` |  | [035-profile-fullpage-393w.png](screens/035-profile-fullpage-393w.png) |
| 036 | My profile: long name (edge case) | Viewport · `flows.html?screen=profile` | Edge case: seeded 21-character name. | [036-profile-long-name-393x852.png](screens/036-profile-long-name-393x852.png) |
| 037 | Edit profile | Viewport · `flows.html?screen=edit` |  | [037-edit-profile-393x852.png](screens/037-edit-profile-393x852.png) |
| 038 | Edit profile (full page) | Full page · `flows.html?screen=edit` |  | [038-edit-profile-fullpage-393w.png](screens/038-edit-profile-fullpage-393w.png) |
| 039 | Edit profile: photo options sheet | Viewport · `flows.html?screen=edit` |  | [039-edit-photo-options-393x852.png](screens/039-edit-photo-options-393x852.png) |
| 040 | Edit profile: empty name error | Viewport · `flows.html?screen=edit` |  | [040-edit-name-error-393x852.png](screens/040-edit-name-error-393x852.png) |
| 041 | Edit profile: Preview | Viewport · `flows.html?screen=edit` |  | [041-edit-preview-393x852.png](screens/041-edit-preview-393x852.png) |
| 042 | Edit profile: Preview (full page) | Full page · `flows.html?screen=edit` |  | [042-edit-preview-fullpage-393w.png](screens/042-edit-preview-fullpage-393w.png) |
| 043 | Edit prompt | Viewport · `flows.html?screen=prompt` |  | [043-prompt-editor-393x852.png](screens/043-prompt-editor-393x852.png) |
| 044 | Edit prompt: new question and answer, ready to save | Viewport · `flows.html?screen=prompt` |  | [044-prompt-editor-changed-393x852.png](screens/044-prompt-editor-changed-393x852.png) |
| 045 | Settings | Viewport · `flows.html?screen=settings` |  | [045-settings-393x852.png](screens/045-settings-393x852.png) |
| 046 | Settings (full page) | Full page · `flows.html?screen=settings` |  | [046-settings-fullpage-393w.png](screens/046-settings-fullpage-393w.png) |
| 047 | Delete account sheet | Viewport · `flows.html?screen=settings` |  | [047-settings-delete-sheet-393x852.png](screens/047-settings-delete-sheet-393x852.png) |

## Desktop context

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 048 | Desktop: onboarding prototype with brief | Viewport · `index.html (onboarding prototype)` |  | [048-desktop-prototype-1440x900.png](screens/048-desktop-prototype-1440x900.png) |
| 049 | Desktop: flow previews gallery | Viewport · `flows.html` |  | [049-desktop-flow-previews-1440x900.png](screens/049-desktop-flow-previews-1440x900.png) |
| 050 | Desktop: flow previews, Profile → Edit profile → Edit prompt | Viewport · `flows.html#profile` |  | [050-desktop-edit-profile-1440x900.png](screens/050-desktop-edit-profile-1440x900.png) |
| 051 | Desktop: design-system showcase | Viewport · `showcase.html` |  | [051-desktop-design-system-1440x900.png](screens/051-desktop-design-system-1440x900.png) |

51 captures: 46 viewport, 5 full page (6 MB of screenshots; all-screens sheet 699 KB).

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
- [Desktop context](contact-sheets/06-desktop.png)
- [Small-phone QA (375 × 667)](contact-sheets/07-qa-375.png)

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

## Home: profiles and filters

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 019 | Home: profile card | Viewport · `flows.html?screen=discovery` |  | [019-discover-393x852.png](screens/019-discover-393x852.png) |
| 020 | Home: the full profile scroll | Full page · `flows.html?screen=discovery` |  | [020-discover-fullpage-393w.png](screens/020-discover-fullpage-393w.png) |
| 021 | Home: “You both like” card | Viewport · `flows.html?screen=discovery` |  | [021-discover-you-both-like-393x852.png](screens/021-discover-you-both-like-393x852.png) |
| 022 | Home: Pass / SuperSwipe / Like at the end of the profile | Viewport · `flows.html?screen=discovery` |  | [022-discover-actions-393x852.png](screens/022-discover-actions-393x852.png) |
| 023 | Home: filters sheet | Viewport · `flows.html?screen=discovery` |  | [023-discover-filters-sheet-393x852.png](screens/023-discover-filters-sheet-393x852.png) |
| 024 | Home: no one fits the filters | Viewport · `flows.html?screen=discovery` | Seeded distance 1 km. | [024-discover-no-one-fits-393x852.png](screens/024-discover-no-one-fits-393x852.png) |
| 025 | Home: seen everyone | Viewport · `flows.html?screen=discovery` | Seeded with every sample profile already decided. | [025-discover-seen-everyone-393x852.png](screens/025-discover-seen-everyone-393x852.png) |
| 026 | Home: Undo after a pass (top left) | Viewport · `flows.html?screen=discovery` | Seeded: Sam was just passed. | [026-home-undo-393x852.png](screens/026-home-undo-393x852.png) |
| 027 | Home: profile options (share, report, block) | Viewport · `flows.html?screen=discovery` |  | [027-home-profile-options-393x852.png](screens/027-home-profile-options-393x852.png) |
| 028 | Home: share sheet (honest: nothing is shared in the preview) | Viewport · `flows.html?screen=discovery` |  | [028-home-share-sheet-393x852.png](screens/028-home-share-sheet-393x852.png) |
| 029 | Home: paused (snoozed) | Viewport · `flows.html?screen=discovery` | Seeded with Snooze on. | [029-discover-paused-393x852.png](screens/029-discover-paused-393x852.png) |

## Likes, matches and messages

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 030 | It’s a match | Viewport · `flows.html?screen=match` | Seeded as right after liking Maya, who liked you. | [030-match-393x852.png](screens/030-match-393x852.png) |
| 031 | It’s a match (full page) | Full page · `flows.html?screen=match` | Seeded right after liking Maya back. | [031-match-fullpage-393w.png](screens/031-match-fullpage-393w.png) |
| 032 | It’s a match: first message typed | Viewport · `flows.html?screen=match` |  | [032-match-typing-393x852.png](screens/032-match-typing-393x852.png) |
| 033 | No new match yet | Viewport · `flows.html?screen=match` |  | [033-match-empty-393x852.png](screens/033-match-empty-393x852.png) |
| 034 | Messages: search, new matches, filters and conversations | Viewport · `flows.html?screen=chats` |  | [034-chats-393x852.png](screens/034-chats-393x852.png) |
| 035 | Messages: several new matches (portrait previews, horizontal rail) | Viewport · `flows.html?screen=chats` | Seeded with four unopened matches. | [035-chats-many-matches-393x852.png](screens/035-chats-many-matches-393x852.png) |
| 036 | Messages: message alerts off banner | Viewport · `flows.html?screen=chats` | Seeded with new-message alerts off. | [036-chats-alerts-off-393x852.png](screens/036-chats-alerts-off-393x852.png) |
| 037 | Messages: empty | Viewport · `flows.html?screen=chats` | Seeded with no matches. | [037-chats-empty-393x852.png](screens/037-chats-empty-393x852.png) |
| 038 | Conversation | Viewport · `flows.html?screen=chat` |  | [038-chat-conversation-393x852.png](screens/038-chat-conversation-393x852.png) |
| 039 | Conversation: typing (send pill active) | Viewport · `flows.html?screen=chat` |  | [039-chat-typing-393x852.png](screens/039-chat-typing-393x852.png) |
| 040 | Conversation: composer with four lines (grows to its maximum, then scrolls) | Viewport · `flows.html?screen=chat` |  | [040-chat-composer-multiline-393x852.png](screens/040-chat-composer-multiline-393x852.png) |
| 041 | Conversation: composer with a long URL (wraps inside the field) | Viewport · `flows.html?screen=chat` |  | [041-chat-composer-url-393x852.png](screens/041-chat-composer-url-393x852.png) |
| 042 | Conversation: new match intro with opening prompts | Viewport · `flows.html?screen=chat` | Seeded with Jo (no messages yet) as the open chat. | [042-chat-new-match-393x852.png](screens/042-chat-new-match-393x852.png) |
| 043 | Conversation: long messages (edge case) | Viewport · `flows.html?screen=chat` | Edge case: seeded thread with long messages. | [043-chat-long-messages-393x852.png](screens/043-chat-long-messages-393x852.png) |
| 044 | Conversation options menu | Viewport · `flows.html?screen=chat` |  | [044-chat-options-menu-393x852.png](screens/044-chat-options-menu-393x852.png) |
| 045 | Unmatch confirmation sheet | Viewport · `flows.html?screen=chat` |  | [045-chat-unmatch-sheet-393x852.png](screens/045-chat-unmatch-sheet-393x852.png) |
| 046 | Block confirmation sheet | Viewport · `flows.html?screen=chat` |  | [046-chat-block-sheet-393x852.png](screens/046-chat-block-sheet-393x852.png) |
| 047 | Report: reason, optional details, also block | Viewport · `flows.html?screen=chat` |  | [047-chat-report-sheet-393x852.png](screens/047-chat-report-sheet-393x852.png) |
| 048 | Ended: unmatched | Viewport · `flows.html?screen=chat` | Seeded: Priya unmatched. | [048-chat-unmatched-393x852.png](screens/048-chat-unmatched-393x852.png) |
| 049 | Ended: blocked | Viewport · `flows.html?screen=chat` | Seeded: Priya blocked. | [049-chat-blocked-393x852.png](screens/049-chat-blocked-393x852.png) |
| 050 | Ended: reported and blocked (report kept on this device) | Viewport · `flows.html?screen=chat` | Seeded: Priya reported. | [050-chat-reported-393x852.png](screens/050-chat-reported-393x852.png) |
| 051 | Messages: search by message text | Viewport · `flows.html?screen=chats` |  | [051-chats-search-393x852.png](screens/051-chats-search-393x852.png) |
| 052 | Messages: search + Unread filter with nothing to show | Viewport · `flows.html?screen=chats` |  | [052-chats-filter-empty-393x852.png](screens/052-chats-filter-empty-393x852.png) |
| 053 | Conversation: an opener inserted into the composer | Viewport · `flows.html?screen=chat` |  | [053-chat-opener-inserted-393x852.png](screens/053-chat-opener-inserted-393x852.png) |
| 054 | Likes: all | Viewport · `flows.html?screen=likes` |  | [054-likes-393x852.png](screens/054-likes-393x852.png) |
| 055 | Likes: Activity filter | Viewport · `flows.html?screen=likes` |  | [055-likes-activity-393x852.png](screens/055-likes-activity-393x852.png) |
| 056 | Likes: New filter | Viewport · `flows.html?screen=likes` |  | [056-likes-new-393x852.png](screens/056-likes-new-393x852.png) |
| 057 | Likes: Nearby filter (within 5 km) | Viewport · `flows.html?screen=likes` |  | [057-likes-nearby-393x852.png](screens/057-likes-nearby-393x852.png) |
| 058 | Likes: empty (every like handled) | Viewport · `flows.html?screen=likes` | Seeded with every like handled. | [058-likes-empty-393x852.png](screens/058-likes-empty-393x852.png) |
| 059 | Likes: a person who liked you (like back or pass) | Viewport · `flows.html?screen=like-profile` |  | [059-like-profile-393x852.png](screens/059-like-profile-393x852.png) |
| 060 | Likes: an already-matched like (handled) | Viewport · `flows.html?screen=like-profile` |  | [060-like-profile-matched-393x852.png](screens/060-like-profile-matched-393x852.png) |

## Activity

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 061 | Activity: Explore | Viewport · `flows.html?screen=activity` |  | [061-activity-393x852.png](screens/061-activity-393x852.png) |
| 062 | Activity: Explore (full page) | Full page · `flows.html?screen=activity` |  | [062-activity-fullpage-393w.png](screens/062-activity-fullpage-393w.png) |
| 063 | Activity: Music category | Viewport · `flows.html?screen=activity` |  | [063-activity-category-393x852.png](screens/063-activity-category-393x852.png) |
| 064 | Activity: date and distance filters | Viewport · `flows.html?screen=activity` |  | [064-activity-filters-sheet-393x852.png](screens/064-activity-filters-sheet-393x852.png) |
| 065 | Activity: nothing matches the filters | Viewport · `flows.html?screen=activity` |  | [065-activity-filtered-empty-393x852.png](screens/065-activity-filtered-empty-393x852.png) |
| 066 | Activity: choose an area (no device location) | Viewport · `flows.html?screen=activity` |  | [066-activity-area-sheet-393x852.png](screens/066-activity-area-sheet-393x852.png) |
| 067 | Activity: no area chosen (distances hidden) | Viewport · `flows.html?screen=activity` | Seeded with no area. | [067-activity-no-area-393x852.png](screens/067-activity-no-area-393x852.png) |
| 068 | Activity: feed failed to load (retry) | Viewport · `flows.html?screen=activity` | Seeded with Prototype tools › Simulate network errors on. | [068-activity-error-393x852.png](screens/068-activity-error-393x852.png) |
| 069 | Activity details: open to join | Viewport · `flows.html?screen=activity-detail` |  | [069-activity-detail-393x852.png](screens/069-activity-detail-393x852.png) |
| 070 | Activity details (full page) | Full page · `flows.html?screen=activity-detail` |  | [070-activity-detail-fullpage-393w.png](screens/070-activity-detail-fullpage-393w.png) |
| 071 | Activity details: joined | Viewport · `flows.html?screen=activity-detail` | Seeded: joined. | [071-activity-joined-393x852.png](screens/071-activity-joined-393x852.png) |
| 072 | Activity details: host approves requests | Viewport · `flows.html?screen=activity-detail` |  | [072-activity-request-393x852.png](screens/072-activity-request-393x852.png) |
| 073 | Activity details: request pending | Viewport · `flows.html?screen=activity-detail` | Seeded: request sent. | [073-activity-requested-393x852.png](screens/073-activity-requested-393x852.png) |
| 074 | Activity details: full, waitlist offered | Viewport · `flows.html?screen=activity-detail` |  | [074-activity-full-393x852.png](screens/074-activity-full-393x852.png) |
| 075 | Activity details: on the waitlist | Viewport · `flows.html?screen=activity-detail` | Seeded: waitlisted. | [075-activity-waitlisted-393x852.png](screens/075-activity-waitlisted-393x852.png) |
| 076 | Activity details: live now, joined | Viewport · `flows.html?screen=activity-detail` |  | [076-activity-live-393x852.png](screens/076-activity-live-393x852.png) |
| 077 | Activity details: long title, multi-paragraph description, no image (edge case) | Viewport · `flows.html?screen=activity-detail` |  | [077-activity-long-title-393x852.png](screens/077-activity-long-title-393x852.png) |
| 078 | Activity details: large group, no limit (edge case) | Viewport · `flows.html?screen=activity-detail` |  | [078-activity-large-group-393x852.png](screens/078-activity-large-group-393x852.png) |
| 079 | Activity details: cancelled by the host | Viewport · `flows.html?screen=activity-detail` |  | [079-activity-cancelled-393x852.png](screens/079-activity-cancelled-393x852.png) |
| 080 | Activity details: ended | Viewport · `flows.html?screen=activity-detail` |  | [080-activity-past-393x852.png](screens/080-activity-past-393x852.png) |
| 081 | Activity details: host view | Viewport · `flows.html?screen=activity-detail` |  | [081-activity-host-393x852.png](screens/081-activity-host-393x852.png) |
| 082 | Activity details: options (share, report, block host) | Viewport · `flows.html?screen=activity-detail` |  | [082-activity-options-393x852.png](screens/082-activity-options-393x852.png) |
| 083 | Activity: report sheet | Viewport · `flows.html?screen=activity-detail` |  | [083-activity-report-393x852.png](screens/083-activity-report-393x852.png) |
| 084 | Activity: leave confirmation | Viewport · `flows.html?screen=activity-detail` |  | [084-activity-leave-393x852.png](screens/084-activity-leave-393x852.png) |
| 085 | Guests: host view with requests | Viewport · `flows.html?screen=activity-people` |  | [085-activity-people-host-393x852.png](screens/085-activity-people-host-393x852.png) |
| 086 | Guests: first names only, the rest a count | Viewport · `flows.html?screen=activity-people` |  | [086-activity-people-393x852.png](screens/086-activity-people-393x852.png) |
| 087 | Create activity: empty form | Viewport · `flows.html?screen=activity-form` |  | [087-activity-form-393x852.png](screens/087-activity-form-393x852.png) |
| 088 | Create activity (full page) | Full page · `flows.html?screen=activity-form` |  | [088-activity-form-fullpage-393w.png](screens/088-activity-form-fullpage-393w.png) |
| 089 | Create activity: required-field errors | Viewport · `flows.html?screen=activity-form` |  | [089-activity-form-errors-393x852.png](screens/089-activity-form-errors-393x852.png) |
| 090 | Create activity: category picker (entered text is kept) | Viewport · `flows.html?screen=activity-form` |  | [090-activity-form-category-393x852.png](screens/090-activity-form-category-393x852.png) |
| 091 | Create activity: a past date is rejected | Viewport · `flows.html?screen=activity-form` |  | [091-activity-form-past-393x852.png](screens/091-activity-form-past-393x852.png) |
| 092 | Edit activity: existing values | Viewport · `flows.html?screen=activity-form` |  | [092-activity-form-edit-393x852.png](screens/092-activity-form-edit-393x852.png) |
| 093 | Create activity: published | Viewport · `flows.html?screen=activity-form` |  | [093-activity-published-393x852.png](screens/093-activity-published-393x852.png) |
| 094 | My activities: Upcoming | Viewport · `flows.html?screen=my-activities` |  | [094-my-activities-393x852.png](screens/094-my-activities-393x852.png) |
| 095 | My activities: Hosting (with a draft) | Viewport · `flows.html?screen=my-activities` |  | [095-my-activities-hosting-393x852.png](screens/095-my-activities-hosting-393x852.png) |
| 096 | My activities: Requests | Viewport · `flows.html?screen=my-activities` |  | [096-my-activities-requests-393x852.png](screens/096-my-activities-requests-393x852.png) |
| 097 | My activities: Past | Viewport · `flows.html?screen=my-activities` |  | [097-my-activities-past-393x852.png](screens/097-my-activities-past-393x852.png) |
| 098 | My activities: nothing upcoming | Viewport · `flows.html?screen=my-activities` | Seeded with no joins. | [098-my-activities-empty-393x852.png](screens/098-my-activities-empty-393x852.png) |

## Profile, readiness, settings and account

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 099 | My profile | Viewport · `flows.html?screen=profile` |  | [099-profile-393x852.png](screens/099-profile-393x852.png) |
| 100 | My profile (full page) | Full page · `flows.html?screen=profile` |  | [100-profile-fullpage-393w.png](screens/100-profile-fullpage-393w.png) |
| 101 | My profile: long name (edge case) | Viewport · `flows.html?screen=profile` | Edge case: seeded 21-character name. | [101-profile-long-name-393x852.png](screens/101-profile-long-name-393x852.png) |
| 102 | Edit profile | Viewport · `flows.html?screen=edit` |  | [102-edit-profile-393x852.png](screens/102-edit-profile-393x852.png) |
| 103 | Edit profile (full page) | Full page · `flows.html?screen=edit` |  | [103-edit-profile-fullpage-393w.png](screens/103-edit-profile-fullpage-393w.png) |
| 104 | Edit profile: photo options sheet | Viewport · `flows.html?screen=edit` |  | [104-edit-photo-options-393x852.png](screens/104-edit-photo-options-393x852.png) |
| 105 | Edit profile: empty name error | Viewport · `flows.html?screen=edit` |  | [105-edit-name-error-393x852.png](screens/105-edit-name-error-393x852.png) |
| 106 | Edit profile: Preview | Viewport · `flows.html?screen=edit` |  | [106-edit-preview-393x852.png](screens/106-edit-preview-393x852.png) |
| 107 | Edit profile: Preview (full page) | Full page · `flows.html?screen=edit` |  | [107-edit-preview-fullpage-393w.png](screens/107-edit-preview-fullpage-393w.png) |
| 108 | Edit prompt | Viewport · `flows.html?screen=prompt` |  | [108-prompt-editor-393x852.png](screens/108-prompt-editor-393x852.png) |
| 109 | Edit prompt: answer field focused | Viewport · `flows.html?screen=prompt` |  | [109-prompt-editor-focused-393x852.png](screens/109-prompt-editor-focused-393x852.png) |
| 110 | Edit prompt: new question and answer, ready to save | Viewport · `flows.html?screen=prompt` |  | [110-prompt-editor-changed-393x852.png](screens/110-prompt-editor-changed-393x852.png) |
| 111 | Settings | Viewport · `flows.html?screen=settings` |  | [111-settings-393x852.png](screens/111-settings-393x852.png) |
| 112 | Settings (full page) | Full page · `flows.html?screen=settings` |  | [112-settings-fullpage-393w.png](screens/112-settings-fullpage-393w.png) |
| 113 | Settings: Snooze on | Viewport · `flows.html?screen=settings` | Seeded with Snooze on. | [113-settings-snooze-on-393x852.png](screens/113-settings-snooze-on-393x852.png) |
| 114 | Profile readiness dashboard | Viewport · `flows.html?screen=insights` |  | [114-insights-393x852.png](screens/114-insights-393x852.png) |
| 115 | Profile readiness dashboard (full page) | Full page · `flows.html?screen=insights` |  | [115-insights-fullpage-393w.png](screens/115-insights-fullpage-393w.png) |
| 116 | Profile readiness: complete profile | Viewport · `flows.html?screen=insights` | Seeded with a bio and four photos. | [116-insights-complete-393x852.png](screens/116-insights-complete-393x852.png) |
| 117 | Profile readiness: account status Paused (Snooze on) | Viewport · `flows.html?screen=insights` |  | [117-insights-paused-393x852.png](screens/117-insights-paused-393x852.png) |
| 118 | Edit profile: opened from a recommendation, bio focused | Viewport · `flows.html?screen=edit` |  | [118-edit-focus-bio-393x852.png](screens/118-edit-focus-bio-393x852.png) |
| 119 | Settings: blocked people and prototype tools | Viewport · `flows.html?screen=settings` |  | [119-settings-prototype-tools-393x852.png](screens/119-settings-prototype-tools-393x852.png) |
| 120 | Blocked people | Viewport · `flows.html?screen=blocked` |  | [120-blocked-393x852.png](screens/120-blocked-393x852.png) |
| 121 | Blocked people: empty | Viewport · `flows.html?screen=blocked` |  | [121-blocked-empty-393x852.png](screens/121-blocked-empty-393x852.png) |
| 122 | Premium: Free and Plus (no prices, no billing) | Viewport · `flows.html?screen=premium` |  | [122-premium-393x852.png](screens/122-premium-393x852.png) |
| 123 | Premium: Plus isn’t on sale in this preview | Viewport · `flows.html?screen=premium` |  | [123-premium-sheet-393x852.png](screens/123-premium-sheet-393x852.png) |
| 124 | Connected accounts: none | Viewport · `flows.html?screen=connections` |  | [124-connections-393x852.png](screens/124-connections-393x852.png) |
| 125 | Connected accounts: consent before connecting (simulated) | Viewport · `flows.html?screen=connections` |  | [125-connections-consent-393x852.png](screens/125-connections-consent-393x852.png) |
| 126 | Connected accounts: Spotify connected (simulated) | Viewport · `flows.html?screen=connections` |  | [126-connections-connected-393x852.png](screens/126-connections-connected-393x852.png) |
| 127 | Help and support | Viewport · `flows.html?screen=help` |  | [127-help-393x852.png](screens/127-help-393x852.png) |
| 128 | Help: a guide | Viewport · `flows.html?screen=help` |  | [128-help-topic-393x852.png](screens/128-help-topic-393x852.png) |
| 129 | System state: service unavailable | Viewport · `flows.html?screen=maintenance` |  | [129-maintenance-393x852.png](screens/129-maintenance-393x852.png) |
| 130 | Delete account sheet | Viewport · `flows.html?screen=settings` |  | [130-settings-delete-sheet-393x852.png](screens/130-settings-delete-sheet-393x852.png) |

## Desktop context

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 131 | Desktop: onboarding prototype with brief | Viewport · `index.html (onboarding prototype)` |  | [131-desktop-prototype-1440x900.png](screens/131-desktop-prototype-1440x900.png) |
| 132 | Desktop: flow previews gallery | Viewport · `flows.html` |  | [132-desktop-flow-previews-1440x900.png](screens/132-desktop-flow-previews-1440x900.png) |
| 133 | Desktop: flow previews, Profile → Edit profile → Edit prompt | Viewport · `flows.html#profile` |  | [133-desktop-edit-profile-1440x900.png](screens/133-desktop-edit-profile-1440x900.png) |
| 134 | Desktop: design-system showcase | Viewport · `showcase.html` |  | [134-desktop-design-system-1440x900.png](screens/134-desktop-design-system-1440x900.png) |
| 135 | Desktop: flow previews scrolled to Chats and the conversation | Viewport · `flows.html` |  | [135-desktop-flow-previews-chats-1440x900.png](screens/135-desktop-flow-previews-chats-1440x900.png) |
| 136 | Desktop: flow previews scrolled to Activity | Viewport · `flows.html` |  | [136-desktop-flow-previews-activity-1440x900.png](screens/136-desktop-flow-previews-activity-1440x900.png) |
| 137 | Desktop: flow previews scrolled to Likes and Messages | Viewport · `flows.html` |  | [137-desktop-flow-previews-likes-1440x900.png](screens/137-desktop-flow-previews-likes-1440x900.png) |
| 138 | Desktop: flow previews scrolled to Profile readiness and account | Viewport · `flows.html` |  | [138-desktop-flow-previews-account-1440x900.png](screens/138-desktop-flow-previews-account-1440x900.png) |
| 139 | Desktop: design-system showcase scrolled to the illustrations and result panels | Viewport · `showcase.html` |  | [139-desktop-design-system-illustrations-1440x900.png](screens/139-desktop-design-system-illustrations-1440x900.png) |

## Small-phone QA (375 × 667)

| # | Screen or state | Capture | Notes | Image |
| --- | --- | --- | --- | --- |
| 140 | QA 375: Welcome | Viewport · `index.html (onboarding prototype)` |  | [140-qa-welcome-375x667.png](screens/140-qa-welcome-375x667.png) |
| 141 | QA 375: Phone number with keypad | Viewport · `index.html (onboarding prototype)` |  | [141-qa-phone-entry-375x667.png](screens/141-qa-phone-entry-375x667.png) |
| 142 | QA 375: Verify code | Viewport · `index.html (onboarding prototype)` |  | [142-qa-verify-code-375x667.png](screens/142-qa-verify-code-375x667.png) |
| 143 | QA 375: You’re verified → profile setup | Viewport · `flows.html?screen=intro` | Scrolls slightly at this height; the body becomes a tab stop. | [143-qa-verified-intro-375x667.png](screens/143-qa-verified-intro-375x667.png) |
| 144 | QA 375: Interests and prompt | Viewport · `flows.html?screen=interests` |  | [144-qa-interests-375x667.png](screens/144-qa-interests-375x667.png) |
| 145 | QA 375: Home profile card | Viewport · `flows.html?screen=discovery` |  | [145-qa-discover-375x667.png](screens/145-qa-discover-375x667.png) |
| 146 | QA 375: It’s a match | Viewport · `flows.html?screen=match` |  | [146-qa-match-375x667.png](screens/146-qa-match-375x667.png) |
| 147 | QA 375: Chats | Viewport · `flows.html?screen=chats` |  | [147-qa-chats-375x667.png](screens/147-qa-chats-375x667.png) |
| 148 | QA 375: Conversation with long messages | Viewport · `flows.html?screen=chat` |  | [148-qa-chat-long-messages-375x667.png](screens/148-qa-chat-long-messages-375x667.png) |
| 149 | QA 375: Settings | Viewport · `flows.html?screen=settings` |  | [149-qa-settings-375x667.png](screens/149-qa-settings-375x667.png) |
| 150 | QA 375: profile setup scrolled to the last step card | Viewport · `flows.html?screen=intro` |  | [150-qa-verified-intro-bottom-375x667.png](screens/150-qa-verified-intro-bottom-375x667.png) |
| 151 | QA 375: Chats with several new matches (horizontal rail) | Viewport · `flows.html?screen=chats` |  | [151-qa-chats-many-matches-375x667.png](screens/151-qa-chats-many-matches-375x667.png) |
| 152 | QA 375: composer at its maximum height | Viewport · `flows.html?screen=chat` |  | [152-qa-chat-composer-multiline-375x667.png](screens/152-qa-chat-composer-multiline-375x667.png) |
| 153 | QA 375: Activity Explore | Viewport · `flows.html?screen=activity` |  | [153-qa-activity-375x667.png](screens/153-qa-activity-375x667.png) |
| 154 | QA 375: activity with a long title | Viewport · `flows.html?screen=activity-detail` |  | [154-qa-activity-long-title-375x667.png](screens/154-qa-activity-long-title-375x667.png) |
| 155 | QA 375: create activity with errors | Viewport · `flows.html?screen=activity-form` |  | [155-qa-activity-form-errors-375x667.png](screens/155-qa-activity-form-errors-375x667.png) |
| 156 | QA 375: My activities | Viewport · `flows.html?screen=my-activities` |  | [156-qa-my-activities-375x667.png](screens/156-qa-my-activities-375x667.png) |
| 157 | QA 375: Likes | Viewport · `flows.html?screen=likes` |  | [157-qa-likes-375x667.png](screens/157-qa-likes-375x667.png) |
| 158 | QA 375: Profile home | Viewport · `flows.html?screen=profile` |  | [158-qa-profile-375x667.png](screens/158-qa-profile-375x667.png) |
| 159 | QA 375: readiness dashboard | Viewport · `flows.html?screen=insights` |  | [159-qa-insights-375x667.png](screens/159-qa-insights-375x667.png) |
| 160 | QA 375: readiness metrics and status | Viewport · `flows.html?screen=insights` |  | [160-qa-insights-metrics-375x667.png](screens/160-qa-insights-metrics-375x667.png) |
| 161 | QA 375: It’s a match with a person who has no prompt | Viewport · `flows.html?screen=match` |  | [161-qa-match-kemi-375x667.png](screens/161-qa-match-kemi-375x667.png) |
| 162 | QA 375: Settings scrolled to the end | Viewport · `flows.html?screen=settings` |  | [162-qa-settings-bottom-375x667.png](screens/162-qa-settings-bottom-375x667.png) |

162 captures: 152 viewport, 10 full page (18 MB of screenshots; all-screens sheet 2359 KB).

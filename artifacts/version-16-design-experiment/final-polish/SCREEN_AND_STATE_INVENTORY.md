# Screen and state inventory (coverage checklist)

From the real route table (`SCREENS` and `TIIMO_SCREENS` in `src/flows/Flows.jsx`) and the gallery's state list
(`scripts/gallery.mjs`, 162 states, numbered). V16 applies only to the 15 screens below.

- **Gallery number:** the state captured for review, saved in `screenshots/` under this pass.
- ✓: captured and inspected at full size in the final pass.

## V16 screens and states

| Area | Screen id | States (gallery number) | Shared components exercised | ✓ |
|---|---|---|---|---|
| Onboarding | Welcome (`index.html`) | 001 | Wordmark, primary and quiet buttons, emoji stickers | ✓ |
| Onboarding | `basics` | 013 default, 015 under-18 error (invalid field) | Fields, field labels, choice lists (radio and checkbox), step button (enabled and disabled), progress | ✓ |
| Onboarding | `interests` | 016 default, 017 at the limit (locked chips) | Interest chips (unselected, selected, unavailable), set marks, prompt card | ✓ |
| Onboarding | `photos` | 018 | Photo slots (filled, empty), remove button, index badge, info box | ✓ |
| Discover | `discovery` | 019 card, 020 full scroll, 021 "You both like", 022 actions, 023 filters sheet, 024 nobody fits (empty), 027 options action sheet | Header circles, photo card, name overlay, profile-section cards, static chips, action buttons, sheet, sliders, action sheet, empty-state card | ✓ |
| Likes | `likes` | 054 all, 058 empty | View tabs, person tiles, status labels, empty-state card | ✓ |
| Like back | `like-profile` | 059 | Modal header, info box, primary and secondary pair | ✓ |
| Match | `match` | 030 default, 031 full page, 032 typing | Title, scalloped portrait, avatar, shared chips, composer (empty and filled) | ✓ |
| Messages | `chats` | 034 default, 037 empty, 052 search with an empty filter | Search (empty and filled), new-match rail, view tabs, rows, outlined status label, unread count, empty-state card | ✓ |
| Conversation | `chat` | 038 default, 039 typing, 042 new match with openers, 044 options action sheet, 045 unmatch sheet, 047 report sheet | Header, bubbles, opener rows, composer, action sheet, sheets (destructive, form), radios, checkbox, textarea, disabled primary | ✓ |
| Own profile | `profile` | 099, 100 full page | Avatar plus score label, chips, small buttons, prompt card, readiness card, grouped rows with icons and values | ✓ |
| Profile editing | `edit` | 102, 103 full page, 104 photo options action sheet, 106 preview, 107 preview full page | Segmented control (both states), photo slots, prompt card, textarea, chips, fields, grouped rows | ✓ |
| Prompt editing | `prompt` | 108 default, 109 answer focused, 110 changed (primary enabled) | Choice list, textarea (focus), primary (disabled to enabled) | ✓ |
| Settings | `settings` | 111, 112 full page, 113 Snooze on, 130 delete-account sheet | Group headings, sliders, switches (on and off), info box, action rows, destructive sheet | ✓ |
| Activity | `activity` | 061, 062 full page, 064 filters sheet | Segmented control, category chips, activity cards, status labels, radio lists in a sheet | ✓ |
| Small phone, 375 × 667 | 9 screens | 144 interests, 145 discover, 146 match, 147 messages, 148 long messages, 149 settings, 153 activity, 157 likes, 158 profile | — | ✓ |

**State coverage by type:**

| State | Where |
|---|---|
| Selected | Radios, checkboxes, chips, view tabs, segmented, switches, tab bar |
| Disabled | Step button 015; Save prompt 108; Send report 047; composer send 030 / 038; locked chips 017 |
| Error | Invalid field 015 |
| Focus | Answer textarea 109, composer 032 / 039, plus a keyboard tab-through of all 14 flow screens (pass 5) |
| Empty | 024, 037, 052, 058 |
| Confirmation | 045, 047, 130 |
| Menus | 027, 044, 104 |
| Success | Prompt saved: 110 shows the enabled primary and its confirmation copy |

## Not available, or not applicable

| Item | Why |
|---|---|
| Loading states in V16 screens | Discover, Activity and Messages render seeded data synchronously; skeletons exist (`.skeleton`, restyled) but no V16 route shows one without the network-error tool. Activity's error state (`activity-detail`) is outside V16. |
| Desktop layout | V16 is a phone design. On desktop, `flows.html` shows the phone frames in a gallery; a gallery run at 1440 × 900 was checked for overflow (pass 3). There is no separate desktop layout to polish. |
| Hover and pressed states | Not capturable in a static screenshot. Checked in CSS: every pressable control has `:active` feedback (a unit test asserts this) and the hover rules resolve to V16 colours. |
| Screens outside V16 | `intro`, `activity-detail`, `activity-people`, `activity-form`, `my-activities`, `insights`, `blocked`, `premium`, `connections`, `help`, `maintenance` keep the approved design even with `?theme=withings`, by design (V11 scope). The e2e suite asserts it. |

# V16 screen inventory

V16 covers exactly V11's experiment scope, the 15 screens that carry `.theme-tiimo` (`TIIMO_SCREENS` in
`src/flows/Flows.jsx`, plus Welcome). Every state below is the real app reached through the UI by
`scripts/gallery.mjs`. The same gallery number is used for the V11 and V16 captures in `screenshots/v11/` and
`screenshots/v16/`.

| Brief item | Screen id | States captured (gallery number) | Reference patterns applied |
|---|---|---|---|
| 1. Discover | `discovery` | 019 card, 020 full scroll, 022 actions | Stone page, circular header buttons, white section cards, round actions |
| 2. Expanded profile | `discovery`, `like-profile` | 020, 021 "You both like", 059 | Stacked white cards, card titles, chips |
| 3. Likes | `likes`, `like-profile` | 054 all, 058 empty, 059 like back | Page title, period-style tabs, Share / Done button pair |
| 4. Messages list | `chats` | 034, 037 empty, 052 filter with nothing to show | Search field, navy avatars, tabs, outlined status label |
| 5. Conversation | `chat` | 038, 039 typing, 042 new match with openers, 044 options menu, 045 unmatch sheet, 047 report sheet | Bubbles, white opener rows, sheet anatomy, destructive button |
| 6. Own profile | `profile` | 099, 100 full scroll | Navy avatar, outlined pill, white cards |
| 7. Profile editing | `edit` | 102, 104 photo options, 106 preview | Modal header, segmented control, photo slots |
| 8. Prompt editing | `prompt` | 108, 109 answer focused, 110 changed | Grouped radio list, field labels, disabled to enabled primary |
| 9. Match | `match` | 030, 032 typing | Bold title, navy avatar, composer |
| 10. Filters | `discovery`, `activity` | 023 Discover filters, 064 activity filters | Sheet with header hairline, sliders, radio list, ink primary |
| 11. Settings | `settings` | 111, 113 Snooze on, 130 delete-account sheet | Group headings, grouped rows, green switches, red destructive |
| 12. Empty, dialogs, secondary | various | 024 nobody fits the filters, 027 profile options, 037, 052, 058, 104, 130 | Empty-state copy on stone, action sheet, sheets |
| Onboarding | `basics`, `interests`, `photos`, Welcome | 001, 013, 015 under-18 error, 016, 017 at the limit, 018 | Field capitals, outlined fields, grouped choices, ink step button |
| Activity | `activity` | 061 | Segmented control, chips, white activity card |
| Small phone, 375 × 667 | 9 screens | 144–149, 153, 157, 158 | — |

**49 states in total**, for both V11 and V16.

## Outside V16

These screens stay outside, as they were outside V11; `?theme=withings` does not touch them, and the tests assert
this: `intro`, `activity-detail`, `activity-people`, `activity-form`, `my-activities`, `insights`, `blocked`,
`premium`, `connections`, `help`, `maintenance`. The brief listed no screen beyond V11's scope, and CLAUDE.md forbids
building screens the spec does not describe.

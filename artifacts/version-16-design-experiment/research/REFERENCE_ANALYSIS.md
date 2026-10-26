# Withings Health Mate (iOS): reference analysis for V16

## Access: what was available, and how

- **The supplied link** is Mobbin's screen listing for Withings Health Mate iOS:
  `mobbin.com/apps/withings-health-mate-ios-7f9f815c-…/afa34ae7-…/screens`.
- **Tools.** The Mobbin connector here can search screens and flows and read collections. It cannot open an app page by URL.
  I reached the app's screens by searching with the app's name. All 30 screens and 3 flows returned are labelled
  `app_name: "Withings Health Mate", platform: ios`.
- **App version: not verified.** The connector does not return Mobbin's app-version id (`afa34ae7-…`), so I cannot prove
  these screens are the exact version in the link. They share one visual system and one UI generation (the same
  February 2024 data, the "John Smith" test account), which suggests a single capture.
- **Network.** mobbin.com is blocked by this container's proxy (HTTP 403 on `CONNECT`), and the browser connectors
  are not available in this cloud session, so the high-resolution images could not be downloaded.
- **What was used.** The connector's inline previews: JPEGs 299 × 678 px of a 393 pt wide iPhone screen, so
  1 px ≈ 1.31 pt, plus a 30 px Mobbin footer. All 37 are archived in [`reference/`](reference/) and every colour and
  measurement below comes from them.
- **Accuracy.** JPEG compression and downscaling shift colours by about ±3 per channel and make edges about ±1 px
  (±1.3 pt) uncertain. Values below are rounded with that in mind.

## Screens and flows inspected

Every screen below was seen, not inferred from metadata. Links go to Mobbin.

| Archived preview | What it shows | Mobbin |
|---|---|---|
| `01-home-welcome.jpg` | Home, first run: illustration, "Welcome John", blue "Got it", notification box, tab bar | [ff2cd673](https://mobbin.com/screens/ff2cd673-1da6-43a8-9c41-f08f87b0d28a) |
| `02-measure-all-health-data.jpg` | Measurement cards with charts, inline "Show All Workouts" row | [f1fc0288](https://mobbin.com/screens/f1fc0288-dabc-47de-a94f-8c193bae1260) |
| `03-detail-share-done.jpg` | Detail: section headings, notification card, notes field, Share (outlined) + Done (ink) | [eae097db](https://mobbin.com/screens/eae097db-32ad-4b9b-bc1b-e6949149bc42) |
| `04-body-composition-segmented.jpg` | Caps header, period tabs with the selected blue-tint pill, chart, stat tiles | [eabd26eb](https://mobbin.com/screens/eabd26eb-5c32-4e82-9387-d83f24872574) |
| `33-weight-quarter-tabs-explore.jpg` | Period tabs ("Quarter" selected), "Explore data" tint button, white panel | [dd9eb17c](https://mobbin.com/screens/dd9eb17c-bee7-4559-a530-31c0fd240231) |
| `06-notifications.jpg` | Notifications over a blurred page; a white card with a grey icon tile | [d8e923e0](https://mobbin.com/screens/d8e923e0-30e4-465a-a6c7-760d17bebb02) |
| `05-pace-solid-blue.jpg` | Pace picker: full-bleed Withings blue, white value circle | [cef67a3a](https://mobbin.com/screens/cef67a3a-3d8e-489e-bebe-d52fb9e333c0) |
| `34-home-hi-john-feature-card.jpg` | "Hi, John": circular header buttons, outlined feature card, mission rows | [ce74b474](https://mobbin.com/screens/ce74b474-c0cb-480a-888f-68f23836f63a) |
| `35-home-quiet-day.jpg` | Feature card variant, mission card with photo | [c96f8daf](https://mobbin.com/screens/c96f8daf-7231-46dd-a354-552e6009f1f1) |
| `07-home-latest-measurements.jpg` | Stacked measurement cards, a tint "Show all measurements" row | [c5eff5ea](https://mobbin.com/screens/c5eff5ea-5346-4d38-ad39-b14da7cf82b0) |
| `08-home-missions.jpg` | Good morning: notification box, mission cards, check rows | [c3703a14](https://mobbin.com/screens/c3703a14-d83b-4170-863f-fd17c6a31b2b) |
| `36-sleep-score.jpg` | Close button, outlined "Withings+" badge, score card, info icon | [c2bb840a](https://mobbin.com/screens/c2bb840a-1bbc-4f6d-abbf-d62e8c2c9e43) |
| `09-measure-tiles.jpg` | Measure: blue "Unlock" button, pastel category tiles (yellow, lavender, outlined) | [c053659b](https://mobbin.com/screens/c053659b-bd4e-4824-a41c-5272b9465986) |
| `37-body-gradient.jpg` | Body area: a gradient page variant (the one gradient seen) | [b942b2ea](https://mobbin.com/screens/b942b2ea-6f01-4105-a011-35670244dbc0) |
| `10-home-good-morning.jpg` | Home: page title, notification box, missions, tab bar with red dots | [b5edc357](https://mobbin.com/screens/b5edc357-52d7-4d2c-9340-d151b7edf4fd) |
| `31-profile-underline-form.jpg` | Profile setup with underline fields, Cancel / Next footer | [e7e01e0f](https://mobbin.com/screens/e7e01e0f-e1b4-492f-a0a4-dac6fdb7e5e2) |
| `11-profile-edit-avatar.jpg` | Navy initials avatar, tint "Edit Picture", outlined fields with caps labels | [e40add9a](https://mobbin.com/screens/e40add9a-c914-42f4-9053-d142d4c2d3cc) |
| `12-modes-list-done.jpg` | Grouped rows with round pastel icons, subtitles, chevrons; ink Done | [d2f46ce2](https://mobbin.com/screens/d2f46ce2-858c-49a1-9ac0-d3f4780f9afc) |
| `13-profile-reminders-toggle.jpg` | Goal tiles, small outlined pill "Add a Reminder", green switch, app tiles | [d1cf6b9f](https://mobbin.com/screens/d1cf6b9f-dc00-4f3d-9777-12385fa78673) |
| `15-account-security-toast.jpg` | Light-blue toast "Password created", switch on | [d0289db6](https://mobbin.com/screens/d0289db6-45fe-4f2d-9d59-05775d5abdd1) |
| (not archived) | iOS action sheet over the profile form | [cffd85c8](https://mobbin.com/screens/cffd85c8-91fa-4181-a454-e43c1aa7c043) |
| `17-devices-list.jpg` | Device card, long grouped list, tint "All settings" row | [c7f8c9fc](https://mobbin.com/screens/c7f8c9fc-6420-49d2-9e34-74465d526aec) |
| `14-account-security-toggle-off.jpg` | Grouped settings: headings, rows, dividers, helper text, switch off | [c0b11ff6](https://mobbin.com/screens/c0b11ff6-9047-4e0b-a2a3-2ea028b6e0aa) |
| `16-profile-form-delete.jpg` | Outlined fields, select chevrons, unit chip, red destructive button | [b555e0ca](https://mobbin.com/screens/b555e0ca-3676-4c22-b24f-8545b7874724) |
| (not archived) | Profile: reminders, apps, family empty state | [ab62686f](https://mobbin.com/screens/ab62686f-a709-49c3-a514-bef3b4377104) |
| `18-device-settings-toggle.jpg` | Grouped settings with section headings, value rows, switch | [a64f87d3](https://mobbin.com/screens/a64f87d3-d6d0-4c48-abf3-e15591d4fe6c) |
| `28-device-destructive.jpg` | Value rows, red destructive, help card with an outlined pill link | [9d40688f](https://mobbin.com/screens/9d40688f-2b84-47fd-aeeb-3f227a0ee74b) |
| `19-profile-header.jpg` | Profile: navy avatar, "Withings+" badge, tint info row, card sections, "Share" pill | [96549a72](https://mobbin.com/screens/96549a72-b071-4b1d-be01-179330f02702) |
| `20-profile-goals.jpg` | Goal tiles with round tint icons, empty-state card | [949cb3e9](https://mobbin.com/screens/949cb3e9-3b34-4db9-acf0-29c9c55e0017) |
| `21-sheet-radio.jpg` | Bottom sheet: grabber, medium title + Cancel, divider, radio rows, ink Done | [8c7faafe](https://mobbin.com/screens/8c7faafe-88c3-4e5d-abfb-299907bbf0eb) |

**Flows** (seen through the connector's evenly spaced previews, 3 to 16 screens each):

| Flow | Previews archived | Mobbin |
|---|---|---|
| Joining a program (13 screens) | `24-program-chips-tabs.jpg` (icon chips, week tabs), `25-achieve-segmented.jpg` (segmented control, category cards), `32-calendar-selected.jpg` (calendar, ink selected day) | [82d8eeea](https://mobbin.com/flows/82d8eeea-2021-4ce9-a6cd-bc4dd7b0f5b3) |
| Onboarding (33 screens) | `29-onboarding-get-started.jpg`, `23-privacy-checkbox.jpg` (blue checkbox on a tint row, disabled Next), `26-code-field.jpg` (code field, inline link) | [1b9c5c94](https://mobbin.com/flows/1b9c5c94-d6d6-4a61-b01b-4160881390ee) |
| Setting up cycle tracking (18 screens) | `22-cycle-radio-next-previous.jpg` (radio list, Next / Previous), `27-measure-following.jpg`, `30-log-manually-list.jpg` (icon list) | [9457f125](https://mobbin.com/flows/9457f125-95a6-4698-9a87-af594e3fea4c) |

**Sequences studied:**
- Home: first run → notifications → missions;
- Measure → a metric → period tabs → Explore data;
- Profile → edit → photo action sheet → delete;
- Device → settings → destructive action;
- the onboarding questions → bottom-sheet picker.

## Repeated patterns: the system behind the screens

1. **Two-level surfaces.**
   - Every screen is a warm off-white page. Content sits in **white cards with no border and no shadow**: the
     contrast between white and stone is the only separation (02, 07, 12, 14, 18, 19).
   - An **outlined box** (the page colour with a hairline) marks information you don't open: the notification box
     (08, 10) and the outlined feature card (34).
2. **Grouped rows.**
   - Settings-like lists are one white card with 56 pt rows and hairline dividers. The dividers are inset to the text
     on both sides, never touching the card edge (14, 17, 18, 30).
   - Each group has a **medium-weight ink heading above it on the page**: "Account Settings", "Security",
     "Advanced settings".
3. **Ink as the action colour.** Every full-width primary action is near-black with white text: Done, Next, Join,
   Continue, Get started (03, 12, 21, 22, 24, 26, 29, 32). The secondary is white with a 1 px dark outline: Share,
   Previous (03, 22).
4. **Withings blue, used sparingly.**
   - Solid: brand moments ("Got it", "Unlock with Withings+", the Pace screen), checked checkboxes, chart lines,
     status arrows.
   - Light tint: selected period tabs, "Explore data", "All settings", "Show all measurements", "Edit Picture", the
     privacy row, the toast (04, 07, 11, 15, 17, 23, 33).
5. **Navy initials avatars** in circles ("JO", "JA") (11, 13, 19).
6. **Two type registers.**
   - Tab roots open with a **heavy bold page title**: "Good morning, John", "Measure".
   - Modal and detail screens use a **white header bar with tracked capitals**: "PROFILE", "BODY SMART",
     "ACCOUNT & SECURITY", "CYCLE TRACKING". It has a hairline under it and a bare chevron or ✕.
7. **Field labels** are small bold capitals ("FIRST NAME", "DATE OF BIRTH", "CONFIRMATION CODE") above white
   fields with a 1 px dark outline (11, 16, 22, 26).
8. **Compact outlined pills** for secondary inline actions ("Add a Reminder", "Share", "Add", "Read our Privacy
   Policy", "Go to Help Center") (13, 19, 23, 28).
9. **Round icon holders.** Category and goal icons sit in pastel or tint circles (12, 20, 09, 25).
10. **Native iOS controls, recoloured.** Switches are green when on, with round thumbs. The segmented control is a
    grey track with a white selected segment. Radios are grey rings, black when selected.
11. **Tab bar.** White, a top hairline, three items with filled glyph icons. Active is black, inactive grey. Small
    labels, red notification dots.

## Measured colours

Sampled by histogram over component areas (the scripts are in the session record; the values are reproducible from
the archived JPEGs).

| Role | Sample(s) | Token value |
|---|---|---|
| Page | #F6F3F3, #F3F3F0, #F4F4F0 (10 screens) | `#F5F4F1` |
| Card | #FFFFFF / #FCFCFC | `#FFFFFF` |
| Primary button, selected radio | #0F0F0F, #0C0C0C | `#121212` |
| Body text | #242321 (darkest, anti-aliased) | ink `#121212` |
| Secondary text ("Off", helper) | #5F5D5E, #363533 | `#5E5C59` |
| Inactive tab label | #717171 | `#6B6966` (deepened for 4.5:1 on stone) |
| Field outline | #6D6C6A, #787874 | `#6D6C6A` |
| Divider in a card | #E8E8E8 / #F0F0F0 band | `#E6E5E2` |
| Notification-box border, outlined tile | #E3E2E0, #DFDEDC | `#E6E5E2` |
| Tab bar top edge | #ECECEC | `#E6E5E2` |
| Segmented track | #E4E4E4, #E0E0E4 | `#EAE9E6` (warmed) |
| Switch off track | #E8E8E8, #E4E4E4 | `#EAE9E6` |
| Withings blue | #5166CC (Pace, 80% of the frame), #5064CC ("Got it"), #4F65CB ("Unlock") | `#5066CC` |
| Blue tint | #E4EBFC, #E4ECFC (Explore data, All settings, Edit Picture, Week tab) | `#E4EBFC` |
| Text on tint | #3E4987, #414987, #475290 (darkest) | `#3E4A8F` |
| Navy avatar | #203068 | `#203068` |
| Switch on | #3C783C, #3E793D | `#3C783C` |
| Destructive | #CF3336 | `#CF3336` |
| Notification dot | #D43039, #F2414E | `#CF3336` (one red) |
| Disabled button | #C3BDBA with label #716D6A | `#D6D2CE` / `#77736F` |
| Category tiles | #FCEAB7 yellow, #E4C9ED lavender, #FCCCC4 pink | marks only |
| Grabber, empty tiles | #CCCCCC, #DCD8D4 | `#D3D0CC`, photo `#DFDDD9` |

## Measured geometry (pt = px × 1.31)

| Element | Measured | Used |
|---|---|---|
| Screen margin | 12 px | 16 pt |
| Card corner | 9–10 px | 14 pt |
| Gap between cards | 9–10 px | 12 pt |
| Single-line grouped row | 43 px pitch | 56 pt |
| Two-line row with a 40 pt icon | 55 px pitch | 72 pt (Numaya's rows come out 64–68 pt) |
| Divider inset | 12 px each side | 16 pt |
| Full-width button | 35–37 px tall, ~8 px corner | 50 pt, 12 pt corner |
| Text field | 42 px tall, ~6 px corner, 1 px outline | 54 pt, 8 pt corner |
| Header icon button | 30 px circle | 40 pt circle |
| Outlined pill ("Add a Reminder") | ~17 px tall | 36 pt visible, inside a 44 pt target |
| Page title cap-to-descender | 23 px | 30–32 pt bold |
| Section heading | 16 px | 22 pt medium |
| Tab bar | ~42 px plus home indicator | 56 pt (V11's) |

## Typography

- **One grotesk for everything.** Single-storey `g`, double-storey `a`, wide letters, a heavy bold.
- **Exact face: unknown.** It may be a proprietary or licensed brand face. I have not seen it named, so I don't
  claim one.
- **Substitute.** I rendered five SIL OFL candidates against the reference headline: Hanken Grotesk, Schibsted
  Grotesk, Instrument Sans, Figtree and Inter. **Hanken Grotesk** is closest in width, `g`, `y` and bold weight.
- **Weights seen:**
  - page titles bold (≈700);
  - section and group headings medium (≈500);
  - card titles medium;
  - body regular;
  - modal header titles bold capitals tracked about 0.16em;
  - field labels bold capitals tracked about 0.06em.

## States and variants seen

- Switch on and off.
- Radio unselected and selected; checkbox checked.
- Period tab selected; segmented selected.
- Button primary, secondary, tint, destructive and disabled.
- Toast; bottom sheet with grabber and Cancel; iOS action sheet.
- Empty states: a notification-less box, the family empty card.
- Progress segments in program detail; calendar with the selected day as an ink circle.

## Observed vs inferred

| Directly observed | Inferred (no direct evidence) |
|---|---|
| Palette, card and page relationship, grouped rows, dividers, headings, capital headers and labels, field outline, ink and outlined buttons, tint actions, period tabs, segmented control, radios, blue checkbox, green switch, round icon holders, navy avatars, tab bar, sheet anatomy, toast | Focus rings (Withings shows none, so V16 uses the blue accent at 2 px); search fields and chat composers (the app has neither, so V16 uses a white field with a hairline); message bubbles (none in the app, so yours take Withings blue and theirs a white card); sliders (none seen, so a fill rail, blue interval, round white thumbs); hover states |

## Limitations

- High-resolution images were not downloadable (proxy). Previews are about 76% scale, JPEG.
- The exact app version in the link could not be confirmed (see Access).
- No dark-mode or iPad screens were returned, so V16 has neither.
- Two screens were seen but not archived (cffd85c8, ab62686f). Their patterns appear in archived screens too.

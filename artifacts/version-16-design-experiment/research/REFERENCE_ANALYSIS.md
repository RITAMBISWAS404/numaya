# V16 reference analysis: Withings Health Mate (iOS)

**Labels used below:**

| Label | Meaning |
|---|---|
| **[O]** | observed on the screens listed here |
| **[S]** | sampled colour; approximate, from low-resolution previews |
| **[I]** | my interpretation |
| **[P]** | provisional: the evidence is thin |

## 0. Access and its limits
- **Source:** the Mobbin connector's screen search, filtered to the app "Withings Health Mate" (iOS). It
  returned **45 distinct screens across five queries**, all viewed.
- **Not verified: the version link.** The brief's link points at the app version
  `afa34ae7-e9ef-4491-a3b3-5008c0888851`. The connector does not expose version IDs, so I cannot
  confirm that every screen comes from that exact version.
  - All screens show the same generation of the design: 2024 dates, the Home / Measure / Achieve tab
    bar, the same type and colour.
  - No other Withings app or generation was used.
- **Not viewed directly:** the link itself. The proxy refuses `mobbin.com` (403), so neither the page
  nor the full-resolution images could be fetched.
- **Consequence:** every colour comes from the connector's **299 × 678 JPEG previews** and is an
  approximation (§3).
- **Fonts:** the Withings app typeface is not identified anywhere available to me, so the font choice is
  marked **[P]**.

## 1. Screens actually inspected
Mobbin screen links, grouped by what each teaches.

**Home and data cards**
- [ff2cd673](https://mobbin.com/screens/ff2cd673-1da6-43a8-9c41-f08f87b0d28a) Welcome home
- [c96f8daf](https://mobbin.com/screens/c96f8daf-7231-46dd-a354-552e6009f1f1) "Good morning" + missions
- [c5eff5ea](https://mobbin.com/screens/c5eff5ea-5346-4d38-ad39-b14da7cf82b0) Latest measurements
- [c3703a14](https://mobbin.com/screens/c3703a14-d83b-4170-863f-fd17c6a31b2b) Home with no notifications
- [c053659b](https://mobbin.com/screens/c053659b-bd4e-4824-a41c-5272b9465986) Measure
- [f1fc0288](https://mobbin.com/screens/f1fc0288-dabc-47de-a94f-8c193bae1260) All health data
- [ce74b474](https://mobbin.com/screens/ce74b474-c0cb-480a-888f-68f23836f63a) Hi John
- [eabd26eb](https://mobbin.com/screens/eabd26eb-5c32-4e82-9387-d83f24872574) Body composition chart with week / month tabs

**Settings and lists**
- [c7f8c9fc](https://mobbin.com/screens/c7f8c9fc-6420-49d2-9e34-74465d526aec) Account & security, toggle on
- [c0b11ff6](https://mobbin.com/screens/c0b11ff6-9047-4e0b-a2a3-2ea028b6e0aa) The same, toggle off
- [d2f46ce2](https://mobbin.com/screens/d2f46ce2-858c-49a1-9ac0-d3f4780f9afc) Profile: reminders toggle, outline pills, navy avatar
- [d0289db6](https://mobbin.com/screens/d0289db6-45fe-4f2d-9d59-05775d5abdd1) My devices with a tinted "All settings" row
- [d302e280](https://mobbin.com/screens/d302e280-5c48-4dac-a7e3-c7e8ecded4f2) Privacy list with blue icons
- [d2992b9c](https://mobbin.com/screens/d2992b9c-4faa-46c2-b3ba-f237b0da73b7) Body Smart modes

**Selection controls**
- [e42c6611](https://mobbin.com/screens/e42c6611-8cf6-499d-9bbc-77bc8b8c6239) Personalise: radios in a group, disabled Save, eyebrows
- [e40c2bbd](https://mobbin.com/screens/e40c2bbd-f27f-462c-94af-c469764e8e77) Subscription: selected card in blue
- [de11e1bf](https://mobbin.com/screens/de11e1bf-d9a3-426f-9ef0-f2e04c199eae) Report time frame (radios)
- [deeb49e0](https://mobbin.com/screens/deeb49e0-ca1e-4309-a876-cce1f37f9dcb) Feedback (radios, black and outline buttons)
- [aaff8377](https://mobbin.com/screens/aaff8377-abbc-4de5-b31d-e7d50001e133) Checkboxes
- [d03ffe8d](https://mobbin.com/screens/d03ffe8d-6b70-492e-acb6-194841c44c86) Text field
- [ffaabff3](https://mobbin.com/screens/ffaabff3-7e0c-4768-98cb-c98c963bd570) Athlete mode (black / outline buttons, icon circles)

**Tabs and segmented controls**
- [fd2ddf46](https://mobbin.com/screens/fd2ddf46-076c-46ac-bcfd-27732ff98979) Favourites filter tabs
- [e4b9aa29](https://mobbin.com/screens/e4b9aa29-26b1-458e-a6c4-34884ac76f23) Badges tabs
- [e0129de9](https://mobbin.com/screens/e0129de9-2592-4be5-9ccf-ce49753ddd14) Achieve: segmented Programs / Library
- [ea0fe04c](https://mobbin.com/screens/ea0fe04c-d521-454d-b8dc-2e2efa66c31b) Add activity list with tinted icon circles

**Sheets, dialogs, feedback**
- [0cb9755c](https://mobbin.com/screens/0cb9755c-dbf5-44ff-bedc-1e5221411819) Verification sheet with checkboxes
- [a2e75e79](https://mobbin.com/screens/a2e75e79-77a4-4ed7-8e44-8dbe758f5031) "Let's start" sheet
- [70792e08](https://mobbin.com/screens/70792e08-1fae-45d4-986f-1ac9d544b89a) Leave sheet, red destructive
- [ac8a2c06](https://mobbin.com/screens/ac8a2c06-98ae-4fec-9558-8ad3b1da79b7) Sign-in sheet: field, black, outline
- [9d45e1bc](https://mobbin.com/screens/9d45e1bc-de65-4ad0-814e-8de2acc8b934) Error toast
- [e8a4c0b3](https://mobbin.com/screens/e8a4c0b3-6923-431c-8130-61038da8fc92) Badge celebration
- [e86723e7](https://mobbin.com/screens/e86723e7-89d2-4925-8eba-416f1e8383a2) Rating, tinted "Saved"

**Content**
- [f2a0af9d](https://mobbin.com/screens/f2a0af9d-07a0-43f2-9fa8-6b846b6b86f2) Article with text links and arrows

## 2. Repeated patterns (observed)
1. **[O] Two surfaces.** A warm light-grey canvas carries white rounded cards. Cards have **no border
   and no visible shadow**: the tone step alone separates them, on every screen.
2. **[O] Grouped rows.** Related rows sit in one white card with full-bleed or inset hairline
   separators. Settings, devices, radios and checkboxes all use this.
3. **[O] Black is the action colour.** The primary full-width button is near-black with white bold text
   (Done, Next, Confirm, Join, Continue, Enable). It is a rounded rectangle, not a pill.
   - Secondary: white with a 1px black border and black text ("Not now", "Previous", "Share",
     "Continue with Google").
4. **[O] Blue is the accent, not the default action.**
   - Uses: the paid upgrade ("Unlock / Subscribe with Withings+"), the selected plan card (blue fill,
     white text, white radio), selected filter tabs (light blue tint with blue text), the "All settings"
     and "Show all measurements" rows (blue tint), list icons and icon circles, rating stars, chart
     lines, toasts.
5. **[O] Selection controls are monochrome.**
   - Radios: a black ring with a solid black dot when selected.
   - Checkboxes: a square with slightly rounded corners, black-filled with a white tick.
   - The **only** coloured control is the **switch**: a dark green track with a white knob when on, and
     a light grey, nearly white, track when off.
6. **[O] Navigation titles are tiny, bold, uppercase and widely tracked, centred** ("ACCOUNT &
   SECURITY", "BODY COMPOSITION"). Page titles are large, bold and tight ("Good morning, John",
   "Measure").
7. **[O] Eyebrows:** small uppercase grey labels above groups ("WEIGHT", "E-MAIL ADDRESS", "RESULT").
8. **[O] Section headings:** medium-weight, around 22px, black ("Account Settings", "Today's Missions",
   "Notes").
9. **[O] Icon buttons:** white circles with a faint edge and a solid black glyph (profile, +, device,
   back, close).
10. **[O] Tab bar:** white, three items. The selected item has a filled black glyph and a black label;
    the others are grey. Red dots mark new items.
11. **[O] Small actions:** outline pills ("Add a Reminder", "Add", "1 Notification") and an outlined
    rectangle tag ("Withings+").
12. **[O] Destructive:** a red filled button ("Exit"); the system alert has red "OK".
13. **[O] Sheets:** white, a grabber, "Cancel" on the left, an uppercase tracked title, a hairline under
    the header.
14. **[O] Restraint.** One accent per screen region; colour pastels only in illustration and category
    tiles; everything else is black, white and warm grey.

## 3. Colour (sampled, approximate)
| Role | Samples | Token |
|---|---|---|
| Canvas | `#F4F3F1`, `#F5F4F2`, `#F6F5F3` (4 screens) | `#F4F3F1` |
| Card | `#FDFDFD` to `#FFFFFF` | `#FFFFFF` |
| Ink (buttons, radios, text) | `#0B0B0B`, `#0D0D0D` | `#0D0D0D` |
| Row text | `#4A4A4A` | `#4A4A4A` |
| Caption, eyebrow | `#6D6C6A` | `#6D6C6A` |
| Separator | `#E7E7E7` | `#E7E7E7` |
| Segmented track | `#E4E4E6` | `#E4E4E6` |
| Withings blue | `#4F65CB`, `#4E65CC`, `#5566C9`, `#4F65CB` | `#4F65CB` |
| Blue tint | `#E4EAFF`, `#E7EEFF`, `#EBF3FF` | `#E6EBFF` |
| Switch on | `#3C7D40` | `#3C7D40` |
| Destructive | `#CC3034` | `#CC3034` |
| Disabled fill / label | `#C4C1BC` / `#9E9B96` | `#C4C1BC` / darkened label |
| Avatar (family) | `#1C2F5E` navy | not used (see §6) |

**Contrast:**
- **Passes AA:** the blue gives 5.18:1 with white, the green 5.00 and the red 5.20.
- **Fails AA:** the sampled blue *on its tint* (4.36), so text there uses a derived deeper blue,
  `#3D50B0` (5.95).
- **Field edges:** the reference's light grey field border is about 1.7:1. V16 darkens it to `#8E8A85`
  (3.43:1).

## 4. Typography (observed; face provisional)
- **[O] One sans family throughout,** a geometric-leaning grotesque.
  - Headings: bold, tight, large ("Let's set up Body Smart").
  - Section titles: regular-to-medium.
  - Body: regular, grey-black, about 15px.
  - Nav titles: bold uppercase, with tracking around 0.15em.
  - Metric numbers: very bold.
- **[P] The face is not identified.** Four OFL candidates were rendered against reference crops
  (`font-trial/candidates.png`): Inter, Hanken Grotesk, Figtree, Schibsted Grotesk.
  - **Hanken Grotesk** is closest for headings: open, single-storey forms, rounder bowls, the same
    friendly bold.
  - **Inter** matches the neutral body well.
- **[I] V16 assignment:**
  - **headings:** Hanken Grotesk;
  - **interface text:** Inter, which is already V11's.
- **Why Inter stays:** changing V11's interface face would resize every content-sized chip, tag and
  button, which the layout lock forbids.
- **Measured fit:** Hanken Grotesk at zero tracking is within about 1% of V11's Fraunces width on the
  real strings, so V11's heading line breaks hold.

## 5. Geometry and states (observed)
| Element | Shape |
|---|---|
| Cards | about 14–16px corners |
| Buttons and fields | about 12px corners at 44–48px height |
| Checkboxes | about 4px |
| Tabs, small action pills, icon buttons, switches | fully round |

**States:**
- **Selected tab:** blue tint with blue text.
- **Selected radio / checkbox:** black.
- **Selected plan:** blue card.
- **Switch on:** green.
- **Disabled button:** taupe fill with grey label.
- **Disabled checkbox:** grey fill.
- **Focus:** not observable on iOS screenshots **[P]**. V16 uses a 2px blue ring, the accent.

## 6. Translating to Numaya's existing components [I]
| Numaya (V11) | Withings pattern | V16 |
|---|---|---|
| White canvas | warm grey canvas + white cards | canvas `#F4F3F1`; V11's outlined groups become borderless white cards |
| Purple primary pill | black rounded-rect primary | black, 12px corners, white text |
| White outline secondary | white + black 1px | same |
| Purple filter pill / segmented | text tabs, selected = blue tint | idle tabs transparent; selected blue tint + deep-blue text |
| Purple switch | green / light-grey switch | green on; light grey + edge off |
| Purple slider | blue chart lines | blue fill on the grey track |
| Prompt-editor radios | black radios | black ring and dot |
| Purple SuperSwipe | blue accent action | blue |
| Pass / Like | black primary, outline secondary | Like black, Pass white outline |
| Top-bar title | uppercase tracked nav title | same, on V11's line-height |
| Group labels | uppercase grey eyebrows | same |
| Info cards | tinted "show all" rows | blue tint |
| Avatars and initials | blue icon circles, navy family avatar | blue tint with blue initial, which is calmer than navy for a list of people |
| My messages (purple) | blue accent | blue with white text |
| Unread count | red notification dots | red with white digits |
| Verified mark | blue icons | blue |

## 7. What must not transfer
- iOS system patterns:
  - the action-sheet alert;
  - the large-title collapse;
  - three-tab navigation (Numaya has five).
- Health-data visualisation (charts, metric tiles).
- Illustration and pastel category tiles: Numaya has no slot for them, and adding them would change
  layout.
- Any Withings logo or "Withings+" branding.

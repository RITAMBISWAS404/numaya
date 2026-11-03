# Reference audit: Meetup, Jomo, Bevel, Alan (iOS, via Mobbin)

## How the references were studied
- **Source:** the Mobbin connector's screen search, platform iOS, on 2026-11-03.
- **What was examined:** every screen listed below was returned as an image and looked at. Nothing
  here is inferred from an app's name or description.
- **Images:** previews at 299 × 678 px.
  - Contact sheets of exactly the screens inspected are in [reference/](reference/).
  - They are low-resolution previews, kept for internal design review only.

### Access limitations
- **Image resolution:** the Mobbin web app (`mobbin.com`) is blocked by this environment's network
  policy (proxy 403). Only the connector's previews could be seen, not full-resolution screens.
- **Version and completeness:** the connector does not say which app version a screen comes from,
  or whether a search covered the whole collection.
  - Five searches were run: two for Meetup and one each for Jomo, Bevel and Alan, totalling **54 distinct
    screens**.
  - Flows not covered by those searches (Meetup onboarding and its saved-events list, Jomo
    onboarding beyond one sign-up screen, Alan's chat) were **not inspected**. Nothing below
    describes them.
- **Colours:** read by eye from the previews; approximate.
- **Typefaces:** none of the four apps names its typeface anywhere visible, so faces are described,
  not identified.

## A. Meetup (primary reference): 22 screens

### Screens inspected
| Screen ID | What it shows |
|---|---|
| [ea458b63](https://mobbin.com/screens/ea458b63-9d70-4f56-9031-7a8db8697efe) | Explore feed: category icon tabs (All Events, New Groups, …), 16:9 event card, "Start a new group" tinted card, floating Map pill |
| [e73659db](https://mobbin.com/screens/e73659db-ac93-4861-af4f-46b572062baa) | Map view: search pill, date pills (Upcoming selected in purple), event card over the map, "Back to list" purple pill |
| [e560b483](https://mobbin.com/screens/e560b483-da2d-446e-b96d-ff99b2fd648c) | Home: "Your groups" 2-column cards, Meetup Pro tinted card, Events filter pills (Hosting selected purple, others grey), list row with thumbnail, floating tab bar |
| [e32776bc](https://mobbin.com/screens/e32776bc-2760-43af-b2e9-9c7d1513d353) | Event detail (host): round white icon buttons, rounded cover with purple "You're hosting" strip, date and place rows, three grey action tiles (Attendees / Edit / More), sticky "You're going!" bar |
| [dd3f5886](https://mobbin.com/screens/dd3f5886-7a92-431c-9caf-bfbbb5db4560) | Notifications: big left-aligned title, lavender promo card with an illustration and a black pill button, list rows with large avatars |
| [dc184cbe](https://mobbin.com/screens/dc184cbe-1dce-439d-8d30-3e4c0c0b5ca8) | Search: Events / Groups tabs, rounded grey fields with leading icons, a white floating search panel |
| [d424e651](https://mobbin.com/screens/d424e651-5d6b-40b9-8994-d396e1464bcd) | Group events: grey segmented control (Upcoming / Past), month eyebrow, date eyebrows in small caps, avatar stacks, share and save icons, hairline dividers |
| [ccf7a31f](https://mobbin.com/screens/ccf7a31f-7fbb-4f23-afaa-2499aceabd0a) | Event detail (attendee): attendee strip, organiser card on grey, sticky bar with a black "Ticket" pill |
| [c87e44a7](https://mobbin.com/screens/c87e44a7-434a-4081-92aa-b9e0dd456cef) | Explore with the "Today" pill selected, black 16:9 covers with icon buttons on the image |
| [ba82f21f](https://mobbin.com/screens/ba82f21f-08ea-4bfc-a40f-280fe798fe63) | Detail lower half: "See all events" grey pill, "Similar events nearby" carousel, "Report this event" text row |
| [b99188cb](https://mobbin.com/screens/b99188cb-7a5a-4d08-8bb5-fe86cd4cba50) | Events list: Your groups selected (purple), dated list rows with a right thumbnail, "Online" grey chip |
| [b90f2c78](https://mobbin.com/screens/b90f2c78-8dbb-4d60-bca2-4b1affa58fcc) | Explore with Upcoming selected, full-width image cards, "326 going" |
| [f524b867](https://mobbin.com/screens/f524b867-cbd4-407f-ae29-81b021071026) | Comments: avatars, name and time, like and Reply, threaded replies |
| [eb94768f](https://mobbin.com/screens/eb94768f-c757-4b69-9c14-510c5b506b57) | Create event, settings part: grouped white cards with a hairline and a very soft shadow, grey section titles, black toggle on, purple round confirm button |
| [e5c7fd5e](https://mobbin.com/screens/e5c7fd5e-81bb-41cd-86e0-87ef73a34f42) | Profile privacy toggles with helper text under each card; a white context menu |
| [e46189c2](https://mobbin.com/screens/e46189c2-458a-4866-89b1-494ef65ef1d2) | Waitlisted confirmation: illustration cover, status rows, black primary pill, grey secondary pill |
| [e0de3cff](https://mobbin.com/screens/e0de3cff-0079-4de9-9200-2999f271f72a) | Group page: logo tile, rating, member pill with avatars, "Read more" purple link, organiser card on grey |
| [de14d58d](https://mobbin.com/screens/de14d58d-6d4e-410f-9aaa-0c322c14f2b7) | Create event: number picker over a grouped card |
| [da067995](https://mobbin.com/screens/da067995-0b09-4958-9166-0d5a88d68214) | Event detail: dashed "Be the first to share a photo" slot, comments |
| [d792b765](https://mobbin.com/screens/d792b765-7b1b-4c30-bc4c-b9c31d6fcd43) | Create event: picker at "Not set" |
| [d557ad47](https://mobbin.com/screens/d557ad47-c6ff-4f92-96ba-14127598d24f) | Attendees: purple selected pill tab with a count, sort menu, lavender "First event" and "2 guests" badges, floating search |
| [d4ad380b](https://mobbin.com/screens/d4ad380b-6911-454a-9e59-ce449430d6c4) | Member profile: round photo, Organizer and Member sections in white rounded cards, "Discover more groups" row on the lavender tint |

### Patterns observed
1. **Canvas:** white or near-white, with soft grey (`~#F0F0F2`) for secondary fills. Colour comes from
   photos, the purple brand and small illustrations.
2. **Headings:** bold, dark, left-aligned page titles ("Events", "Notifications"). Event titles are
   bold, about 18–20pt, and wrap to two lines.
3. **Date and time eyebrows:** small, uppercase, grey ("SAT, JUL 11 • 12:30 PM EDT"). Organiser and
   distance appear on a second grey line.
4. **Event cards:**
   - a 16:9 cover with ~16pt corners;
   - round translucent share and save buttons on the image;
   - title and metadata **below** the image, never over it;
   - an avatar stack plus "326 going".
5. **Selection:** the selected date or filter pill is **filled purple with white text**. Unselected
   pills are text only or light grey. Secondary filter rows (Hosting / Going / Saved) use grey
   pills.
6. **Segmented control:** a grey track with a white selected segment (Upcoming / Past).
7. **Icon buttons:** white circles with a soft shadow, floating over content (back, share, save).
8. **Navigation:** a floating, rounded white tab bar. The active item sits on a grey capsule with a
   purple icon and label.
9. **Detail pages:**
   - icon-led info rows (date, place) with hairline dividers;
   - three equal grey action tiles;
   - a **sticky white bottom bar** with a status ("You're going!" with an "Edit attendance" link)
     and one action.
10. **Forms and settings:** grouped white cards, ~16pt corners, a hairline and a very soft shadow;
    grey section titles; helper text under each card.
11. **Badges:** a lavender tint with purple text ("First event", "2 guests").
12. **Promotional cards:** a lavender tint with a small illustration and a black pill.

### Inform Numaya
- 16:9 covers with the text below.
- Purple-filled selected pills.
- Uppercase date eyebrows.
- Avatar stacks with a "going" count.
- Icon-led info rows.
- Grey action tiles.
- The sticky RSVP bar.
- Grouped settings cards.
- Lavender badges.

### Do not copy
- Meetup's logo, mascot-style category icons and red rating stars.
- Its map.
- The black "Ticket" button: Numaya keeps purple for its one primary action.
- The large gradient-like promo artwork: Numaya allows no gradients.

## B. Jomo (supporting): 12 screens
| Screen ID | What it shows |
|---|---|
| [0054eea7](https://mobbin.com/screens/0054eea7-6a63-413f-a3e1-7f7df29d77ba) | Session sheet: centred title, image chips, collapsible white rows, near-black "Start" pill beside a light "New template" pill |
| [0082fe5c](https://mobbin.com/screens/0082fe5c-6917-4a9a-8e8c-425ad15911a5) | "Prove with a photo": large rounded image well, error banner |
| [01d99716](https://mobbin.com/screens/01d99716-54ca-4d02-bebb-c937d5d8f37f) | Rules: big title with a count, round white icon buttons, grey collapsible section headings, white card with a status pill |
| [01e400b8](https://mobbin.com/screens/01e400b8-8766-4e12-afd2-4ee62ef52868) | Create account: illustration, centred bold title, black and white full-width pills |
| [02b68f3e](https://mobbin.com/screens/02b68f3e-5ea9-4a22-90ac-280386f9f2c3) | Emoji picker sheet: grid of rounded-square tiles |
| [038d8f03](https://mobbin.com/screens/038d8f03-06de-4217-a0b5-298967ad3f5b) | Form: grey bold labels above fully rounded white fields, tinted "Tips" panel |
| [03d050ca](https://mobbin.com/screens/03d050ca-cdf9-403b-86b2-5b18672b2c83) | Select an app: list in one white card, circle radios, floating search pill, disabled grey "Continue" |
| [03e54d6e](https://mobbin.com/screens/03e54d6e-2503-4352-8c20-79bf4eb56c9e) | Unlocks: Yes / No pills, big centred number with round − / + buttons |
| [04e5baf4](https://mobbin.com/screens/04e5baf4-323e-4a0e-99be-974279f9432d) | Settings: segmented control (white selected on grey), one row card, disabled Save |
| [05f6da31](https://mobbin.com/screens/05f6da31-8779-4b5d-aaf7-b80a0b5ab82f) | Rules: limit card with a progress bar, dashed suggestion pill, floating tab bar with a grey active capsule |
| [062abce9](https://mobbin.com/screens/062abce9-a40d-4d97-9aa6-f916e299b8d1) | The same photo screen without the banner |
| [06bfad85](https://mobbin.com/screens/06bfad85-2ed0-4fef-9659-4dab236045eb) | Rules (French): 2-up cards, dashed "add" card |

### Patterns
- A cool light-grey page (`~#F2F3F5`), with white cards at ~16–20pt corners and soft, low shadows.
- Tall (~56pt) **fully rounded** buttons: near-black primary, white secondary.
- Section headings in large **muted grey** semibold, so content leads.
- Generous spacing; one idea per card.
- Big bold numbers for quantities.
- Dashed outlines for "add" affordances.
- Round white icon buttons.

### Inform Numaya
- Spacing.
- Tall rounded buttons.
- Muted section headings.
- Dashed add slots, which Numaya already has for photos.
- Big numbers in counters.

### Do not copy
- Jomo's blue accent and orange alert banners.
- Its gradient "Start blocking" button.

## C. Bevel (supporting, dashboards): 10 screens
| Screen ID | What it shows |
|---|---|
| [fff326ff](https://mobbin.com/screens/fff326ff-8742-4b0e-a96b-620c65c52a59) | Biomarker list: one white card per metric (name, trend status and value, sparkline), "Edit" link, "See all" |
| [fd782fb3](https://mobbin.com/screens/fd782fb3-7506-4a17-8086-99fe40fade75) | Nutrition dashboard: grouped cards, rings, bar chart |
| [ecf51c9c](https://mobbin.com/screens/ecf51c9c-1460-4f90-bf01-4cc13c4a0608) | Widget grid: 2-column metric tiles (several use gradients) |
| [da7207d3](https://mobbin.com/screens/da7207d3-4ff7-49b5-853c-8b6eba7cf486) | Biological age: one large centred number, comparison line, "Next update in 3 days", confidence card, "Add blood tests" card |
| [d0c8beed](https://mobbin.com/screens/d0c8beed-786e-409d-9b2d-e98d4859f03c) | Today: section titles, stress card (three numbers with labels), progress bar |
| [c4c26ac5](https://mobbin.com/screens/c4c26ac5-84f1-4e1c-9c76-19dfd00eeb2e) | Health monitor **with no data**: 2-column tiles reading "No data" in large grey |
| [c1aae3b5](https://mobbin.com/screens/c1aae3b5-b85e-4f22-9d62-431364108e74) | Biomarkers with "No trends available" and status words (Acceptable, Good, Hypertension Stage 1) |
| [bfbdc03f](https://mobbin.com/screens/bfbdc03f-3104-42c8-8d07-e900b7d974ad) | Trends list: icon and grey label, large value with a small unit, status line, arrow at the top right |
| [a4629f7a](https://mobbin.com/screens/a4629f7a-f55f-4aab-a0d2-1ae484005a8b) | "Blood Pressure Added" sheet: preview card, title, body, black primary, "Not now" |
| [9ba374b9](https://mobbin.com/screens/9ba374b9-a410-4075-8155-24d1384b2b8b) | Health monitor with data: value, unit and status per tile |

### Patterns
- **Metric card:** a small grey label with an icon, then a **large number with a small unit**, then
  one status word, with an arrow to its detail.
- **Missing data:** shown as "No data" or "No trends available", never as zero.
- **Summary:** one big number per screen, with when it updates next.
- **Explanation:** cards ("52% confidence: partial or aging data") sit next to the score.

### Inform Numaya
**Where:** Account Health and the profile-readiness score.
- Large-number metric cards.
- Explicit insufficient-data states.
- "How this is calculated" and next-update lines.

### Do not copy
- Gradients, rainbow rings and multicolour charts.
- Biological-age style claims; Numaya must not imply ranking or shadowban predictions.

## D. Alan (supporting, informational): 10 screens
| Screen ID | What it shows |
|---|---|
| [fe47ee98](https://mobbin.com/screens/fe47ee98-cd4d-43a4-95da-4fbab8db8c7d) | Insurance home: three action tiles, underline tabs (purple selected), empty state with a purple text link |
| [f54e8a5f](https://mobbin.com/screens/f54e8a5f-4d8c-4ec8-bedf-f1f9dec66f43) | Member page: small rounded-square back button, large title, tinted "Activation in progress" info card with "More details" link, rows with a grey subtitle and chevron |
| [f261ec64](https://mobbin.com/screens/f261ec64-edd7-43f1-ad75-29f11c3c16d3) | Glasses: underline tabs, tinted selected pill, tinted accordions, outlined "See all" button |
| [e4c49635](https://mobbin.com/screens/e4c49635-e6d1-4cac-bec6-d1881c582f0c) | The same, expanded: inner white chip, bold amounts |
| [e1203511](https://mobbin.com/screens/e1203511-4f31-4dac-b210-825cf7fc5e1b) | My Alan card: purple 12pt-corner primary beside a square secondary, progress steps, dark toast |
| [e063f249](https://mobbin.com/screens/e063f249-f117-4c59-b811-ddaef94cb463) | Coverage document (PDF) |
| [db2661da](https://mobbin.com/screens/db2661da-07a7-4fba-85f8-8aa47c2d546f) | Apple Health connected: illustration header, status chips, numbered steps |
| [d8bbf5a1](https://mobbin.com/screens/d8bbf5a1-c7f9-4217-ad2d-b7a14ab76cb6) | Simulate costs: question heading, purple toggle, field, tinted summary with right-aligned amounts |
| [d248e92b](https://mobbin.com/screens/d248e92b-6737-4e01-bb1c-62a044a1e4c2) | Settings: underline tabs, icon rows with title and subtitle, "Log out" in red text |
| [c897178e](https://mobbin.com/screens/c897178e-fdda-42d4-afe7-b7876aea0150) | Card details: tinted segmented pill |

### Patterns
- Editorial pages: a small **rounded-square** back button, a big left-aligned title, then an intro
  paragraph.
- Explanations in **tinted info cards** (emoji or icon, bold title, body, a link) with no border.
- Rows: a bold title, a grey subtitle and a chevron, with no dividers.
- Underline tabs; a tinted selected pill.
- Destructive actions are red **text**, not red buttons.
- The purple toggle **on**.

### Inform Numaya
- Rounded-square icon buttons.
- Editorial headers.
- Tinted info cards.
- Divider-free title and subtitle rows.
- A purple toggle.

### Do not copy
- Alan's mascot and photographic card art.
- The peach gradient header (`fe47ee98`, `e1203511`).

## E. Facts vs interpretation
| | |
|---|---|
| **Fact** (seen) | Every pattern in the "Patterns" lists above. |
| **Interpretation** (mine) | Each "Inform Numaya" choice. Also the decision that purple, not black, is Numaya's one primary action, because the brief asks for purple primary actions. Meetup's own primary CTA on its detail pages is black. |
| **Not verified** | Typefaces; exact colours; flows not listed. |

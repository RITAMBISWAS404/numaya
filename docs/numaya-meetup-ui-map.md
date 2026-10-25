# Numaya × Meetup UI map

**Bumble for UX and layout** ([reference map](bumble-reference-map.md)), **Meetup for the whole UI
system** (palette, surfaces, components, spacing), **Numaya for identity** (name, wordmark, Fraunces
headings, Inter text). Since the October 2026 migration the old pink `#F770E3` is retired:
the brand colour is Meetup's sampled purple. This map fixes one visual decision per component family.

## Meetup visual-system migration (October 2026)

### Final design decision record (convergence pass)

| Area | Decision | Evidence |
| --- | --- | --- |
| Palette | Unchanged from the sampled table below: purple `#7262C7` leads; Meetup neutrals, lavender, periwinkle; rose, yellow, orange and green by role only | Migration samples (Mobbin previews) |
| Legacy pink | Removed from every production source, including the favicon and the `theme-color` meta that page-level checks could not see. `tests/unit/legacy-colour.test.js` fails on any value in the old hue family (hex, short hex, rgb/rgba, hsl) in `src/`, `public/` and the HTML entry points, and on the retired token names. No exceptions | Source scan |
| Accent naming | The Meetup accent primitive is `rose` (`#EA698C`, `#C1486A`), so no token is named after the retired pink | — |
| Icons | **Material Symbols Rounded**, filled by default (product decision, November pass), replacing Phosphor. Unfilled only for inactive tabs. One wrapper, official symbol names, extracted from the pinned official SVGs |
| Headings | **No coloured-word emphasis** anywhere (Welcome "Better", You're verified, What are you into?, It's a match, the showcase sample): headings are one near-black colour | Product decision |
| Pills and emoji | Interest pills are text-first with plain add / remove glyphs (no circles, no leading icons); no emoji used as UI icons | Product decision |
| Controls | Checked radios, checkboxes, switches, slider intervals and selected pills share one purple `control.selected` (switches were ink) | Product decision | Tab bars, options menu, composer and spot icon crops of the screens below |
| Option rows | Single-line choice rows are full pills (Meetup radio rows); rows with a description keep 20px | Radio-row screens |
| Options menu | Action-sheet rows are left-aligned with a line icon (Meetup options menu); the sheet itself stays Bumble's bottom sheet | Options menu screen |
| Logo | **Not integrated: no logo file was attached to the session.** The current Numaya mark (purple rounded square with a rose dot) stays as a placeholder. **Logo exception (documented):** the dot is Meetup's rose `#EA698C` (hue ≈ 343°), not the retired pink `#F770E3` (hue ≈ 308°). It sits outside the legacy-colour guard's 290–330° window, so the guard needs no exception and none is configured; it is the only place rose appears in the brand mark. Replacement point: drop the supplied file at `public/brand/numaya-logo.svg` (or `.png`) and set `LOGO_SRC` in `src/design-system/components/Brand.jsx`; `Wordmark` then renders the asset at its native aspect ratio and the favicon can be regenerated from it | — |
| Illustrations | Original SVG scenes (`Illustration`), one composition each, optional in `ResultPanel`, `EmptyState` and `ScreenHeader`; see the [illustration map](numaya-illustration-map.md). Retired: the cookie success badge, droplet slots and blank grey spot boxes | Final refinement pass |
| Profile setup | Three stacked horizontal step cards; the next step is the one outlined in purple | Final refinement pass |
| Guidance cards | `InfoCard` on the light lavender wash (`surface.brand`), icon + heading row, body below (periwinkle retired here) | Final refinement pass |
| Verified mark | The single filled Material `verified` seal in purple; no check on a disc | Final refinement pass |
| Responsive | One 430px content column (`layout.content-max`), centred at desktop; QA at 393 × 852, 375 × 667 and 1440 × 900 including long scroll positions. Long pill labels wrap inside the pill; the match rail scrolls horizontally; the composer grows to 120px then scrolls; on short phones (≤ 700px tall) the setup screen drops the wordmark so the step cards stay in view | Gallery groups 5 and 6, E2E |
| Typography | Fraunces and Inter kept (Numaya exception). Display, headline and title weights raised from 440 to 520 so headings carry Meetup's firmer hierarchy | Product decision; rendered 440 / 520 / 600 comparison |

### References opened for the migration

All Meetup iOS, current generation, opened on Mobbin as screenshots (previews; the full-resolution
host was blocked by this environment's network policy, so colours were sampled from the previews:
expect ±3 per channel on flat fills; text and thin strokes were not sampled):

- Home and discovery: [Home with groups and promo card](https://mobbin.com/screens/0072c542-3013-4dd1-adfd-05501bd1076d),
  [Home organiser](https://mobbin.com/screens/662f6722-eca0-4ca7-9a3e-ba589067884b),
  [Explore feed](https://mobbin.com/screens/0e8d493f-e3f1-4597-942b-a7e7ea5a62f5),
  [Explore with promo card and Map pill](https://mobbin.com/screens/ea458b63-9d70-4f56-9031-7a8db8697efe),
  [Events list](https://mobbin.com/screens/b99188cb-7a5a-4d08-8bb5-fe86cd4cba50),
  [Map](https://mobbin.com/screens/51be1ff0-2146-486d-9c1a-6d89ff7747d3),
  [Groups for you](https://mobbin.com/screens/610a06c3-1957-4428-8a66-dde9f1bdbb5f)
- Messages: [Inbox](https://mobbin.com/screens/972d35a9-c98c-4deb-8c71-62a0fd7c77dc),
  [Conversation](https://mobbin.com/screens/e70b2111-8414-4442-ad3c-5de21640243d),
  [Options menu](https://mobbin.com/screens/8efe8c92-9b80-4f96-af11-e6ae831b4f8e),
  [Archive with blocked contact](https://mobbin.com/screens/1efededf-fe03-4d0e-a651-1b9163b0e6d1),
  [New message sheet](https://mobbin.com/screens/6c0dbe27-9374-44f8-b6b9-db3d85352967)
- Interests and onboarding: [What are your interests?](https://mobbin.com/screens/db6c8532-ffb9-4330-b7b4-97a964211985),
  [Topics, selected](https://mobbin.com/screens/618e22f6-dd11-4a89-9d0b-b45b66c61942),
  [Interests sheet](https://mobbin.com/screens/5d433f66-84c6-4f0b-b73f-42d4bbeb9793),
  [Sign-up welcome](https://mobbin.com/screens/3e2d6c66-4d14-47f3-9f4a-8f29d4356cd3),
  [How did you discover Meetup? (radio rows)](https://mobbin.com/screens/b16039cc-3074-467b-9dd3-5f56b5be9d5c),
  [Gender](https://mobbin.com/screens/cef0a642-1a8f-4541-9835-d63b311d079c),
  [Date of birth](https://mobbin.com/screens/0a4292b0-fea2-4c14-b9e1-4cd9c75d8a17),
  [Sign-up form](https://mobbin.com/screens/6760209a-dfe6-41e6-8d18-7fcff04f8c37)
- Profiles: [Member profile](https://mobbin.com/screens/40b51c15-f93b-4933-be0a-2836829bd73d),
  [Own profile](https://mobbin.com/screens/05cf9ce9-ff6e-449c-8a9a-5cf2876c43cb),
  [Shared interests card](https://mobbin.com/screens/579b6ac3-4c0c-4c6a-a32e-02449a816356),
  [Groups list](https://mobbin.com/screens/d4ad380b-6911-454a-9e59-ce449430d6c4)
- Settings and states: [Email updates (ink switches)](https://mobbin.com/screens/9ea56474-24b7-40e9-811b-aa3996dd467c),
  [Confirm dialog](https://mobbin.com/screens/b644330a-714a-49a4-b7d1-6d4af7c4d5ed),
  [Notifications empty state](https://mobbin.com/screens/b3631553-1b10-44f7-a9a2-1e0d9ba59526)
- Excluded as an older generation: the teal group-notification sheets
  ([1](https://mobbin.com/screens/09f80e63-7f4f-42be-8ac8-a5c2d05f55a1), [2](https://mobbin.com/screens/a7057490-79e6-4bda-b202-9c0212ee628e)).
- Not opened: uidiscovery.com, the Meetup design blog and Studio Frank (outbound hosts blocked here);
  the `#A888F8` candidate from a third-party collection is not confirmed. The nearest sampled value is
  the sign-up hero purple `#9C85E6`, used only as `brand.hero`.

### Sampled palette and roles

| Token | Value | Status | Sampled on | Used for in Numaya |
| --- | --- | --- | --- | --- |
| `purple.600` → `brand` | `#7262C7` | Confirmed (5 components agree within ±3) | Selected pills, interest chips, outgoing bubbles, progress segments, check FAB, Map pill | Selected chips and pills, outgoing bubbles, SuperSwipe, send, progress, verified marks, links, focus. White on it 4.90:1 |
| `purple.300` → `brand.hero` | `#9C85E6` | Confirmed | Sign-up hero wash | Decorative only (not behind small text) |
| `purple.100` → `surface.brand` | `#F0ECF9` | Confirmed | Home header wash | Welcome hero wash, lavender highlights |
| `purple.50` → `brand.tint`, `brand.soft` | `#FAF7FE` | Derived from sampled `#F8F1FD`, lifted for 4.6:1 purple text | "Sign up with email" | Soft brand button, "Next" pill, selected tints |
| `purple.200` → `brand.subtle` | `#E2DCF7` | Derived | — | Lavender hairlines and tinted placeholders |
| `purple.800` → `text.brand-deep` | `#4F4296` | Derived | — | Purple text on grey or lavender (active tab label, eyebrows) |
| `periwinkle.100` → `accent.promo` | `#D6DCFD` | Confirmed | "Start a new group" card | Avatar pastels, illustration accents (guidance cards moved to the lavender wash) |
| `neutral.800` | `#2D2C2F` | Confirmed | "Next" CTA | Primary ink buttons (with a soft sheen) |
| `neutral.900` → `text.primary`, `surface.inverse` | `#141316` | Confirmed | Switch on, checkbox | Text, switches, checkboxes, radios, selected option outline |
| `neutral.100` → `surface.soft` | `#F2F2F2` | Confirmed | Search, fields, "Joined", incoming bubbles, "About me" card | Fields, secondary buttons, incoming bubbles, prompt cards, shared-interest pills |
| `neutral.200` → `surface.sunken`, `border.subtle` | `#E9E8EB` | Confirmed (`#EEEDEE` tab pill, card hairlines) | Active tab pill | Active tab pill, hairlines, tracks |
| `pink.500` → `accent.pink` | `#EA698C` | Confirmed | Organiser badge | Wordmark dot, category marks |
| `yellow.200` → `accent.yellow` | `#FCD284` | Confirmed | Empty-state blob | Avatar and illustration framing |
| `orange.500` → `accent.orange` | `#D58B50` | Confirmed (small sample) | "In 2m" chip | Time and status icons |
| `green.500` → `accent.green` | `#5D946A` | Confirmed (small sample) | Image check badge | Confirmation marks; success text uses a deepened `#336E48` |
| `red.500` | `#DD544F` | Confirmed | Friends count badge | Danger and badge text use a deepened `#B93A36` (5.6:1) |

Not determined with confidence: Meetup's exact text greys (antialiased) and its slider styling (no
slider in the current generation). Body greys were derived as neutral (not blue-tinted) steps.


## Reference set

Meetup iOS, current generation (2025: floating frosted tab bar with Home / Friends / Explore /
Notifications / Messages, purple accent, white pages). Older generations are not used. Inspected on
Mobbin as screenshots:

- E1 [Explore, event cards](https://mobbin.com/screens/4a052d00-a5c0-4131-8ec7-9515629b4d86) ·
  E2 [Events list](https://mobbin.com/screens/b99188cb-7a5a-4d08-8bb5-fe86cd4cba50) ·
  E3 [Joined group](https://mobbin.com/screens/7445cdd7-fadc-4605-97d8-f4aad89694e6) ·
  E4 [Event detail end](https://mobbin.com/screens/ba82f21f-08ea-4bfc-a40f-280fe798fe63)
- G [Group detail flow](https://mobbin.com/flows/caf9fead-7201-44d2-9d9f-c284cae36130) (group header,
  organizer card, "About our members" tinted card, discussions) ·
  H [Home flow](https://mobbin.com/flows/00665867-69b6-4bc8-9fb7-52b942e05546) (home, groups, empty state)
- O [Onboarding flow](https://mobbin.com/flows/e35f43d2-bbfe-46dc-9c8d-f34cace68d08) (incl. the
  account-setup screen `0a4292b0`, date of birth, progress pills, check inbox, loading checklist)
- S1 [Email updates](https://mobbin.com/screens/9ea56474-24b7-40e9-811b-aa3996dd467c) ·
  S2 [Profile privacy toggles](https://mobbin.com/screens/e50ddb9b-03b7-4103-869c-0c617427c316) ·
  S3 [Member settings](https://mobbin.com/screens/c6c1231a-263e-4287-8ac1-74500dc1a38e)

- M1 [Direct message](https://mobbin.com/screens/e70b2111-8414-4442-ad3c-5de21640243d) ·
  M2 [Messages inbox](https://mobbin.com/screens/972d35a9-c98c-4deb-8c71-62a0fd7c77dc) ·
  M3 [Archive with blocked contact](https://mobbin.com/screens/1efededf-fe03-4d0e-a651-1b9163b0e6d1)

**Gaps:** no Meetup filter sheet or slider was found (search returned other apps). Those components follow the nearest Meetup pattern below.

## Visual system (from the references)

| Property | Meetup observation | Numaya decision |
| --- | --- | --- |
| Page | White pages; a faint accent wash at the top of Home / Group | White page (`surface.default`); Discover header gets a faint brand-tint wash |
| Cards / groups | White, 1px light-grey hairline, barely-there shadow, ≈ 20px corners (event cards), ≈ 16px (settings groups) | `card`: hairline + `shadow.xs`, `radius.lg` 20; list groups: hairline, `radius.md` 16 |
| Photography | Large photos ≈ 24px corners; translucent circular icon buttons on the photo | `radius.photo` 24; overlays on photos are dark translucent pills / circles |
| Accent placement | Selected filter pill, one floating action ("Map"), progress pills, promo cards, links | Purple: selected chips and pills, SuperSwipe (floating action), progress, outgoing bubbles, send, links. Periwinkle for guidance cards. Secondary colours only by role (badges, framing, status) |
| Primary button | Near-black **pill** with a soft sheen ("Next", "Continue", "Sign up") | `btn--primary`: flat brand purple with white label since D-22 (was an ink gradient), `radius.pill` |
| Secondary button | Light-grey **pill**, no border ("Joined", dialog "Cancel"); soft lavender ("Sign up with email") | `btn--secondary`: `surface.soft` grey pill; `btn--brand`: `brand.soft` lavender with a deep-purple label |
| Icon actions | White circles with a soft shadow (back, close); translucent circles on photos | `IconButton floating` for header controls; Pass / Super / Like and the floating SuperSwipe on the photo are 72×56 horizontal pills; send is a 56×44 pill beside the pill composer; compact navigation (back, close, filters) stays circular |
| Chips / tags | Interest pills: white + hairline with an add-circle; selected = solid purple with white text and a minus-circle. Filter pills: grey unselected, purple selected | Same: `Chip` toggle is white + hairline + `plusCircle`, selected `brand` + white + `minusCircle`; static chips white + hairline; shared-interest pills grey |
| Toggles | **Ink** when on | **Ink track when on** (`surface.inverse`), plain grey when off, white thumb with a soft shadow. State also carried by thumb position |
| Tab bar | Floating frosted capsule, icon over label, active item on a light-grey pill with accent icon (Numaya now draws icons only; labels are accessible names and tooltips) | Same treatment; destinations and order stay Bumble's (Profile, Discover, Chats) |
| Section headings | Bold, ≈ 20px, count in grey, "See all" link right | Fraunces 20 (Numaya type); counts grey |
| Dividers | Hairlines inside cards, inset | Kept |
| Corner hierarchy | Large photos softest, cards next, controls tighter | `radius.photo` 32 (Discover card, profile photos, match photos) ≥ sheets `xl` 28 > `radius.card` 24 (section cards, grouped rows, prompt cards, options menu, illustration areas) > `lg` 20 (bubbles, banners) > `md` 16 (inputs, option cards, photo slots) > code cells 12; pills and circles unchanged |
| Icons | Thin rounded line icons; active tab filled purple | Material Symbols Rounded, filled by default; inactive tabs use the unfilled drawing |
| Outcome visuals | Accent ring around a light centre | `ResultPanel art`: one original illustration per meaning (verified: phone with a purple message; unmatched: two conversations drifting apart; blocked: shield with a report flag). Safety outcomes are neutral, with no check or purple. The earlier cookie badge and droplet-plus-tick stack are retired |
| Motion and press feedback | Quick, quiet feedback; content never waits on animation | Every pressable has a press state (scale for buttons, circles and tiles; a background tint for rows and cards). Entrances: a new Discover profile rises in, the match photos settle into their tilt and the mark lands, a selected chip settles. Exits use the motion tokens. Under reduced motion everything becomes a fade or an instant change |
| Identity shape | Circular avatars throughout; organic blob framing behind empty-state art and hero photos | **Circular avatars** (Meetup), pastel-framed initials. The one deliberate shape exception: droplet framing on empty-state illustration slots. Match previews are 72×96 portraits with the card corner. Plain `border-radius` throughout; no squircle |
| Headline emphasis | Meetup colours one headline word | Not used: Numaya headings are one colour |
| Brand purple treatment | Purple fills are flat; only floating purple actions have a soft drop | `shadow.brand` (soft purple drop) on SuperSwipe and the match mark; chips, bubbles, progress and send stay flat. The old pink sheen and glow are retired |
| Glyphs on brand purple | White glyphs and text on purple | White on `#7262C7` is 4.90:1 (AA), so text and glyphs may sit on purple |
| Empty states | Illustration, bold title, grey text, black pill CTA | Illustration area = neutral grey placeholder (supplied later); black pill CTA |

## Component families

| Family | Where in Numaya | Role (Bumble UX) | Meetup reference | Reproduce | Deviation |
| --- | --- | --- | --- | --- | --- |
| Photo card (`ProfileCard`) | Discover | Photo-led profile card, identity bottom-left, SuperSwipe bottom-right | E1 photo cards | 24px corners, dark legibility gradient, translucent pills on photo | Photo is a neutral grey placeholder until licensed photos are supplied |
| Section card (`.card`) | Discover profile scroll, Profile | Profile sections | E2/E3 bordered cards, G group cards | White, hairline, faint shadow, 20px | — |
| Shared interests (`SharedInterests`) | "You both like" on Discover | Highlight what's shared | G "About our members" | The shared `ProfileSection` card (white, hairline, 24px), plain Fraunces title with no heart or mark, grey text-only pills | Built from the same primitive as every profile section |
| Actions (`ActionBar`) | End of Discover profile | Pass / SuperSwipe / Like | E4 ink "Ticket" button, E1 "Map" accent pill | Ink gradient pills (72×56, radius 28), accent SuperSwipe pill with a white star | Pills instead of circles, chosen from a rendered comparison: larger targets that echo the pill fields and chips. Bumble positions kept |
| Buttons (`Button`) | All screens | Primary, secondary, quiet, destructive | O, H, E4 | Ink pill, grey pill, text | — |
| Icon buttons (`IconButton`) | Headers, sheets | Back, close, filters | O back circle, G header | White circle + soft shadow | — |
| Chips (`ChipGroup`, static chips) | Interests, Edit profile, Discover | Interests, facts | Interest pills, filter pills | White + hairline pills with a plain `add` glyph; selected purple with white text and a plain `remove` glyph. Text-first: no leading interest icons | Same height selected and unselected, so selecting never reflows |
| Sliders (`Slider`, `RangeSlider`) | Filters (Settings, Discover filters sheet) | Age, distance | — (gap) | White thumbs with a soft shadow, brand-pink selected interval on a 6px grey rail, in a bordered group | No Meetup slider found; pink interval by product preference |
| List groups (`ListGroup`, `ListRow`) | Filters, Settings, Profile, report sheet | Grouped rows | S1/S2 | Hairline-bordered 16px groups, grey heading above, grey footnote below, inset dividers | — |
| Switch | Settings | Preferences | S1/S2 | Pink when on, grey when off, white thumb, no outline | Pink instead of Meetup's black |
| Tab bar (`TabBar`) | Discover, Chats, Profile | Bumble destinations | E1/H | Frosted floating capsule, grey active pill | Pink active icon, ink label (pink text fails contrast) |
| Header | Discover | Centred wordmark, filter right, progress | O/G headers | Faint top wash, white-circle icon buttons | Wordmark is Numaya's |
| Avatars | Chats, Chat, Match, Profile | Identity | Member avatars, Messages inbox | Circles (Meetup) with a pastel framing chosen from the name; the match queue uses 72×96 portraits with the 20px corner; the completion ring follows the circle | — |
| Message bubbles | Chat | Mine right, theirs left (Bumble) | M1 | Mine = soft brand tint (`brand-subtle`) with ink text, theirs = light grey (chosen over saturated pink, a paler tint and ink bubbles); ≈ 20px with a small tail corner; status under the last | Ink text on pink (contrast) |
| Composer | Chat, Match | Pill input + send | M1 | White 20px rounded rectangle (near-pill on one line, never a stretched pill), hairline + faint shadow, grows to 120px then scrolls; circular send (grey disabled, purple enabled) | — |
| Inbox rows | Chats | Avatar, name, preview, time, "Your move" (Bumble) | M2 | Plain rows, no dividers or cards; bold name, grey preview; grey "Your move" pill | — |
| Chat header | Chat | Back, avatar, name, options (Bumble) | M1 | White-circle back and options buttons | — |
| Options menu | Chat | Unmatch / Report (Bumble) | — | Floating white card, centred rows, strongest overlay shadow | Separate Cancel card |
| Sheets / dialogs | Chat, Settings, prototype | Overlays | (Bumble structure) | Rounded top, Fraunces title, X, grey info card, ink (or danger) pill CTA; destructive confirmations focus Cancel first | — |
| Fields (`TextField`, `PhoneField`, `CodeInput`) | Onboarding, Edit profile, prompt | Forms | O date of birth field | Light-grey filled **16px rounded rectangle** for form fields (phone, country, name, year), 20px for multiline text, pill for search; six separate 18px code cells. Focus: one 2px brand-pink stroke + soft pink halo, field turns white; no ink ring | Pink focus stroke is 2.51:1 on white (below 3:1); the grey→white change is the second cue. Other controls keep the ink focus ring. OTP cells stay at 18px after a rendered comparison with 24px and full pills (24px drifts toward a capsule, pills lose the six-box read) |
| Progress (`ProgressSegments`) | Onboarding | Step progress | O progress pills | Short pills, accent filled | Already matches |
| Empty states | Discover, Match, Chats | No content | H "Nothing saved yet" | Grey illustration placeholder, bold title, black pill CTA | Illustrations supplied later |

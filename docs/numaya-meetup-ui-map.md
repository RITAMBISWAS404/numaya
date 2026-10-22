# Numaya × Meetup UI map

**Bumble for UX and layout** ([reference map](bumble-reference-map.md)), **Meetup for UI and visual
styling**, **Numaya for brand** (`#F770E3`, Fraunces headings, Inter text). This map fixes one visual
decision per component family so later passes stay consistent.

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
| Accent placement | Selected filter pill, one floating action ("Map"), progress pills, tinted info card ("About our members"), links | Pink: SuperSwipe (floating action), progress, selected states, the tinted "You both like" card. Links stay ink (pink text is 2.51:1) |
| Primary button | Near-black **pill** with a soft sheen | `btn--primary`: ink gradient, `radius.pill` |
| Secondary button | Light-grey **pill**, no border ("See all events…") | `btn--secondary`: `surface.sunken`, no outline, pill |
| Icon actions | White circles with a soft shadow (back, close); translucent circles on photos | `IconButton floating` for header controls; Pass / Like ink circles (Bumble positions) |
| Chips / tags | Pills; unselected light-grey fill or white + hairline; selected = solid accent | Static chips grey pills; shared-interest chips white pills on the tint card; selected = pink fill + ink text |
| Toggles | **Black** when on | Ink switches |
| Tab bar | Floating frosted capsule, icon over label, active item on a light-grey pill with accent icon | Same treatment; destinations and order stay Bumble's (Profile, Discover, Chats) |
| Section headings | Bold, ≈ 20px, count in grey, "See all" link right | Fraunces 20 (Numaya type); counts grey |
| Dividers | Hairlines inside cards, inset | Kept |
| Corner hierarchy | Large photos softest, cards next, controls tighter | `radius.photo` 32 (Discover card, profile photos, match photos) ≥ sheets `xl` 28 > `radius.card` 24 (section cards, grouped rows, prompt cards, options menu, illustration areas) > `lg` 20 (bubbles, banners) > `md` 16 (inputs, option cards, photo slots) > code cells 12; pills and circles unchanged |
| Motion and press feedback | Quick, quiet feedback; content never waits on animation | Every pressable has a press state (scale for buttons, circles and tiles; a background tint for rows and cards). Entrances: a new Discover profile rises in, the match photos settle into their tilt and the mark lands, a selected chip settles. Exits use the motion tokens. Under reduced motion everything becomes a fade or an instant change |
| Brand pink treatment | Accent fills are flat on small elements; the primary accent action has subtle depth | Large pink actions (SuperSwipe, send, match mark, success badge, `btn--brand`): `gradient.brand-sheen` (white light only) over the exact pink + `shadow.brand` (white top highlight, soft glow in the exact pink). Chips, bubbles, badges, progress, tab icon and form controls stay flat. Pressed = flat pink; never a darker pink; ink glyphs (white fails contrast) |
| Empty states | Illustration, bold title, grey text, black pill CTA | Illustration area = neutral grey placeholder (supplied later); black pill CTA |

## Component families

| Family | Where in Numaya | Role (Bumble UX) | Meetup reference | Reproduce | Deviation |
| --- | --- | --- | --- | --- | --- |
| Photo card (`ProfileCard`) | Discover | Photo-led profile card, identity bottom-left, SuperSwipe bottom-right | E1 photo cards | 24px corners, dark legibility gradient, translucent pills on photo | Photo is a neutral grey placeholder until licensed photos are supplied |
| Section card (`.card`) | Discover profile scroll, Profile | Profile sections | E2/E3 bordered cards, G group cards | White, hairline, faint shadow, 20px | — |
| Tinted card | "You both like" on Discover | Highlight what's shared | G "About our members" | Brand-tint surface, white pill chips inside | Pink tint instead of lavender |
| Actions (`ActionBar`) | End of Discover profile | Pass / SuperSwipe / Like | E4 ink "Ticket" button, E1 "Map" accent pill | Ink gradient circles, accent SuperSwipe | Circles kept (Bumble positions) |
| Buttons (`Button`) | All screens | Primary, secondary, quiet, destructive | O, H, E4 | Ink pill, grey pill, text | — |
| Icon buttons (`IconButton`) | Headers, sheets | Back, close, filters | O back circle, G header | White circle + soft shadow | — |
| Chips (`ChipGroup`, static chips) | Interests, Discover | Interests, facts | E2 filter pills, G "looking to" pills | Pills, grey or white + hairline | — |
| Sliders (`Slider`, `RangeSlider`) | Filters (Settings) | Age, distance | — (gap) | Ink track and thumbs, grey rail, in a bordered group | No Meetup slider found |
| List groups (`ListGroup`, `ListRow`) | Filters, Settings, Profile, report sheet | Grouped rows | S1/S2 | Hairline-bordered 16px groups, grey heading above, grey footnote below, inset dividers | — |
| Switch | Settings | Preferences | S1/S2 | Ink when on | — |
| Tab bar (`TabBar`) | Discover, Chats, Profile | Bumble destinations | E1/H | Frosted floating capsule, grey active pill | Pink active icon, ink label (pink text fails contrast) |
| Header | Discover | Centred wordmark, filter right, progress | O/G headers | Faint top wash, white-circle icon buttons | Wordmark is Numaya's |
| Avatars | Chats, Chat, Match, Profile | Identity | E2 avatar stacks, M2 | Circles; neutral initials; new matches get a pink ring | — |
| Message bubbles | Chat | Mine right, theirs left (Bumble) | M1 | Mine = accent fill (pink, ink text), theirs = light grey; ≈ 20px with a small tail corner; status under the last | Ink text on pink (contrast) |
| Composer | Chat, Match | Pill input + send | M1 | White pill, hairline + faint shadow, circular send (grey disabled, pink enabled) | — |
| Inbox rows | Chats | Avatar, name, preview, time, "Your move" (Bumble) | M2 | Plain rows, no dividers or cards; bold name, grey preview; grey "Your move" pill | — |
| Chat header | Chat | Back, avatar, name, options (Bumble) | M1 | White-circle back and options buttons | — |
| Options menu | Chat | Unmatch / Report (Bumble) | — | Floating white card, centred rows, strongest overlay shadow | Separate Cancel card |
| Sheets / dialogs | Chat, Settings, prototype | Overlays | (Bumble structure) | Rounded top, Fraunces title, X, grey info card, ink (or danger) pill CTA; destructive confirmations focus Cancel first | — |
| Fields (`TextField`, `PhoneField`, `CodeInput`) | Onboarding | Forms | O date of birth field | Light-grey filled field, ≈ 16px | — |
| Progress (`ProgressSegments`) | Onboarding | Step progress | O progress pills | Short pills, accent filled | Already matches |
| Empty states | Discover, Match, Chats | No content | H "Nothing saved yet" | Grey illustration placeholder, bold title, black pill CTA | Illustrations supplied later |

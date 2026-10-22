# Bumble reference map

Baseline references for the three-pass reference fidelity work. Every existing Numaya screen, state and
overlay is listed with its closest Bumble iOS reference, as inspected on Mobbin
([app collection](https://mobbin.com/apps/bumble-ios-fefcf818-326e-4549-b2ba-1f440759e5ee/0f0dcdc7-fe1e-5a71-9eca-9ebea0add315/screens)).
Screens marked **Seen** were opened and inspected as screenshots in the Mobbin tool; links go to the
Mobbin screen. Mobbin does not show capture dates through the tool, so versions are identified by UI
generation (below), not by date.

## Reference set

Mobbin mixes two Bumble UI generations. The baseline uses **generation B** throughout:

| | Generation A (not used) | **Generation B (baseline)** |
| --- | --- | --- |
| Header | Left-aligned wordmark, undo + filter icons | Hamburger left, centred wordmark, filter icon right, short scroll-progress track under the header |
| Tab bar | 5 tabs (Profile, Discover, People, Liked You, Chats) | 4 tabs (Profile, People, Liked You, Chats) |
| Profile | Name on photo + "Things we can talk about" panel on the photo | Name on photo; details continue below as white section cards; Pass / SuperSwipe / Like at the end |

Generation-B traits used as the design authority:

- **Palette:** white and light-grey surfaces, black text and black primary controls (pill CTAs, Pass
  and Like circles, slider thumbs, toggles, selected segment). One accent (Bumble yellow) only on
  SuperSwipe, the opening-move mark, premium surfaces and "Your move"-type cues. Numaya keeps its
  accent token (`#F770E3`) in that single accent role.
- **Geometry:** photo card ≈ 8px from the screen edges, corner ≈ 16px; section cards ≈ 16px with a
  very soft shadow; chips, tags, segmented selection and primary CTAs are **pills**; icon actions are
  **circles**; text fields ≈ 12–16px corners.
- **Type:** bold geometric sans for names, section titles and headings; regular sans for body. Name
  on photo ≈ 22–24px bold white; section titles ≈ 16px bold; chips ≈ 14px.
- **Navigation:** flat white bar, grey outline icons with labels, active tab = black filled icon and
  bold label. No floating capsule.

## Screen inventory and mapping

Numaya routes: the flow previews (`flows.html`, `src/flows/Flows.jsx` → `SCREENS`) and the onboarding
prototype (`index.html`, `src/prototype`). The design-system showcase (`showcase.html`) is a specimen
library, not product UI, and is not mapped.

| # | Numaya screen (component) · states / overlays | Bumble reference | Seen | Layout and interaction notes | Numaya-driven differences / uncertainty | Pass |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | Welcome (`prototype/screens/Welcome.jsx`) · notice toast | [Landing / sign-in](https://mobbin.com/screens/88c589c0-5723-4c23-bb4c-08febbc1a87d) | Yes | Full-bleed brand colour, centred logo, stacked full-width pill buttons (Apple, Facebook, phone), legal text under | Numaya has two actions (create / log in), no social sign-in; keep its prompt-card hero only if it fits the pattern | 3 |
| P2 | Phone number (`PhoneNumber.jsx`) · country sheet, sending toast | [Phone number](https://mobbin.com/screens/05c421be-e8a8-411f-aec4-c8cdf723da29) | Yes | Back chevron, bold 2-line title, grey lede, country dropdown + bordered phone field (thick bottom edge when focused), lock note, circular next button bottom-right above keypad | Country sheet has no Bumble screenshot found (uncertain) | 3 |
| P3 | Verify code (`VerifyCode.jsx`) · checking, error, resend, SMS banner, success sheet | [Verify number](https://mobbin.com/screens/e9ff8767-cde3-401f-a525-8681513f5eec), [enabled next](https://mobbin.com/screens/79580899-f9b4-464d-a2f2-1aa610306658) | Yes | Six small bordered cells, underlined "Change number", "Didn't get a code?" left, black circular next right, dark "Loading" pill toast | Error and success states not found on Mobbin (uncertain) | 3 |
| 1 | Verified → profile setup (`SetupIntro`) | [Start building your profile](https://mobbin.com/screens/d742bced-3a20-4e4f-a856-346d76bcf983) | Yes | "% complete" title, centred heading + lede, 2-column grid of bordered tiles (illustration, title, "n of m added") | Numaya's intro is a 3-step list + CTA, not a tile grid; closest structural match only | 3 |
| 2 | The basics (`Basics`) · under-18 error | [Name + birthday](https://mobbin.com/screens/a9b6d46c-1062-4198-8ad2-b78235dff1c3) | Yes | Thin progress line at top, bold title, bold field labels, bordered rounded fields, black circular next bottom-right | Numaya asks year only plus gender / looking-for option cards; no Bumble screenshot of those cards was inspected | 3 |
| 3 | Interests and prompts (`InterestsPrompts`) | [Interests](https://mobbin.com/screens/3a879d6a-05dd-4b14-b59a-7f74136dc68c) | Yes | Centred title, grey helper line, category headings, grey **pill** chips with emoji, "Show more", floating black "Continue" pill | Numaya has no categories or emoji; prompt card section has no direct reference in this flow | 3 |
| 4 | Photos (`Photos`) · uploading slot | [Add photos](https://mobbin.com/screens/41327fa1-f50c-4bfc-8a89-cf3cd8690479), [edit photos](https://mobbin.com/screens/e2ceec9a-0ec2-4ffc-8976-7655b23a4849) | Yes | 3-column grid, ≈ 8px corners, light border on empty slots with "+", "Main" / number labels, black remove circles, reorder hint | Matches Numaya closely already | 3 |
| 5 | **Discover** (`Discovery`) · snoozed, no one fits filters, seen everyone, toast, swipe stamps | [Card](https://mobbin.com/screens/53f019f0-38d7-42ff-b365-e0a6d33afa81), [SuperSwipe](https://mobbin.com/screens/00471592-7a90-44be-a6a1-f5e274f16859) | Yes | Header B; photo card fills to the tab bar; bottom-left: "Photo verified" dark pill, **Name, age** bold white, job with briefcase icon; bottom-right: accent SuperSwipe circle; opening-move mark bottom-left | No opening moves, undo or share in Numaya (not added). Empty states: no Bumble screenshot inspected (uncertain) | **1** |
| 5a | **Full profile from Discover** (scroll of `Discovery`) | [Bio + about me](https://mobbin.com/screens/438fb535-4a1a-4c90-ba54-eecd56c2d021), [life + interests + photo](https://mobbin.com/screens/cafded2a-4ead-4615-b965-f0e743f36e0c), [location + actions](https://mobbin.com/screens/5f6d388b-f4f0-4d07-be95-d03112cb7726) | Yes | White section cards (bold title, body or grey pill chips with icons), extra photos interleaved, "My location" with pin + distance + chips, black Pass (left) / Like (right) circles and accent SuperSwipe at the end | Numaya content: prompt, shared interests, facts, distance. No separate profile route exists; the profile is the Discover scroll, as in the reference | **1** |
| 5b | **Filters** (Discover filter button → `Settings` "Who you see") | [BFF filters](https://mobbin.com/screens/df319efd-feef-436c-ad29-eb69f195a352), [with Apply](https://mobbin.com/screens/2823d597-ab84-4361-a51f-6400f4530fad) | Yes (BFF only) | X + centred title, black pill segmented control, grey question headings, white cards with bold value line, black range thumbs and track, black toggles, black Apply pill | Only the **BFF** variant was available; the Date filter screen was not found. Numaya filters live in Settings (no separate screen); restyled in place | **1** |
| 6 | It's a match (`Match`) · no match yet, composer | [What a match!](https://mobbin.com/screens/0d225721-ea2e-45c2-9f8c-5ad79376be1d), [typed](https://mobbin.com/screens/d0a3d260-6611-46c0-9eb0-5de2f7f8fdbd) | Yes | X + ⋮ header, two tilted rounded photos overlapping, dark circular mark between, bold "What a match!", grey line, pill composer at bottom with circular send (accent when enabled) | "No match yet" empty state has no reference (uncertain) | 2 |
| 7 | Chats (`Chats`) · alerts-off banner, new matches, conversations, empty | [Chats](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74), [with expired](https://mobbin.com/screens/e38f4506-4dca-4594-a3ce-d04366eeec11), [empty](https://mobbin.com/screens/83853a6b-9cf9-4fd0-abbe-562947d9e98c) | Yes | Large bold "Chats" + search icon, "Your matches (n)" horizontal ring avatars (accent rings), "Chats" list: 56px avatars, bold name, grey preview, grey "Your move" pill, no dividers, no cards | No search or timers in Numaya (not added) | 2 |
| 8 | Chat (`Chat`) · ended (blocked / unmatched), options sheet, report sheet, unmatch dialog | [Conversation](https://mobbin.com/screens/4eae8ce7-81bc-4d63-a5c4-cd3e940499da), [Report](https://mobbin.com/screens/131fde60-4190-41bc-852b-3f3817b33238), [Report reasons](https://mobbin.com/screens/1621a627-3b03-4482-a226-e96ddf1bed87) | Yes | Back, small avatar, name; mine = accent bubbles right, theirs = light grey left, ≈ 16px corners; "Delivered" under; pill composer with camera / GIF / mic; report as bottom sheet with back / X, bold title, plain rows with chevrons | No calls, GIFs or media in Numaya. Unmatch dialog and ended states have no inspected reference (uncertain) | 2 |
| 9 | My profile (`MyProfile`) | [Profile tab](https://mobbin.com/screens/d54f9b27-0e47-48b1-88ea-0bb3c349c328), [edit profile](https://mobbin.com/screens/066ebe0f-5b7b-4504-a534-ada131424d32) | Yes | Large "Profile" + help/settings icons, avatar with % ring and "Complete profile" pill; edit screen: bold section titles, grey helper, bordered rows / prompts with chevrons | Numaya has no premium plans (not added) | 3 |
| 10 | Settings (`Settings`) · toggle pending, toast, delete dialog | [Settings](https://mobbin.com/screens/b99220ec-5fa9-4ee5-9deb-ba7e7bcb6ba7), [Snooze](https://mobbin.com/screens/802b17d1-f5f5-4a7c-b6c2-c660232b0bf7) | Yes | Grey page, Cancel / title / Done, white rounded rows (≈ 12px), grey footnotes under each row, black toggles, explanatory bottom sheets with black pill CTA | Delete-account dialog and log out not inspected (uncertain) | 3 (filter group in 1) |

Screens that need no new reference: none. Screens with partial evidence: country sheet (P2), code
error / success (P3), Discover empty states (5), Date filters (5b, BFF used), match empty (6), unmatch
dialog and ended chat (8), delete dialog (10). These use the closest generation-B pattern.

## Imagery

Bumble profile photos are not reused. Network policy blocks external image hosts in this environment
and no image-generation credits are available, so Discover uses locally drawn scenic demo photos
(`src/flows/assets/scenes/`): people seen from behind in places, no identifiable faces, labelled as
illustrations for assistive tech.

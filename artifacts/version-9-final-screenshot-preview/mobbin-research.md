# Bumble research (Mobbin) for V9

**Method.** I searched Bumble's iOS screens through the connected Mobbin plugin, with six queries:

- chats list
- Discover profile card
- edit profile
- filters with toggles and sliders
- "it's a match" screen
- new-match conversation with Opening Moves

Mobbin returned low-resolution previews, and I judged each screen from the preview. Several
queries returned overlapping screens, so the list below names each distinct screen once.

## Screens inspected

| Screen | What it shows |
|---|---|
| [Chats](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74) | Matches row and chat list on white; a "Your move" label |
| [Chats with expired conversation](https://mobbin.com/screens/e38f4506-4dca-4594-a3ce-d04366eeec11) | The same list with an expiry state |
| [Chats, empty](https://mobbin.com/screens/f0fd7cdd-7d03-4035-b4a8-94aaeb6357a2) | Opening Moves banner card, empty state, dark CTA |
| [Conversation](https://mobbin.com/screens/f240ef7c-e408-4a63-ad4f-ad204ce34694) | Header with avatar, media messages, composer |
| [Liked You, "Really into you" filter](https://mobbin.com/screens/ee33fda3-1add-46fd-8c57-855f48f89c87) | Filter chips, photo cards, fixed CTA, tab bar |
| [Liked You, "Notes" filter](https://mobbin.com/screens/e4718471-7988-4148-9a30-8f54b8e7dacc) | The same screen with another active filter |
| [People (profile card)](https://mobbin.com/screens/ee54d57a-33f7-4f05-ba27-012f9f74eb48) | Full photo card with name, a "Things we can talk about" inset card, star action |
| [People (profile, scrolled)](https://mobbin.com/screens/ecc58b78-c02a-4070-8c1b-5f8e61d8344a) | Photo, "My location" section card, star, the bar under the logo |
| [Interests](https://mobbin.com/screens/ff63ca32-0913-418e-876d-120f3481074f) | Emoji chips in grey, grouped sections, floating Continue |
| [Interests at the limit](https://mobbin.com/screens/fcb3c418-a4fa-4963-9040-c1b0f3a857a6) | The selected chip state |
| [Profile info](https://mobbin.com/screens/fc35bf13-823e-4331-a922-4882f5d67e7a) | Rows with icons and chevrons, no containers |
| [Settings](https://mobbin.com/screens/fad704ee-2d0c-4bc7-af4e-2c7a9192b6b2) | White grouped rows on grey, toggles, helper text |
| [BFF filters](https://mobbin.com/screens/f70d7965-5b08-4645-95fb-2e8f59d3f743) | Segmented tabs, slider, toggles, outlined filter groups |
| ["Your life" chips](https://mobbin.com/screens/f346e6c6-b902-43c2-95b3-2f15501632a6) | Outlined chips, selected dark fill, progress bar, round next button |
| [Premium sheet](https://mobbin.com/screens/edae4f46-4eed-4930-b8bc-51c06639e6a0) | Sheet with a soft-shadow card and an outlined button |
| [Write an Opening Move](https://mobbin.com/screens/e6c00ac2-8e86-461b-a823-f7d8302bac1d) | Text-area card, disabled Save |
| [Get help](https://mobbin.com/screens/e9e1dde2-70ac-4848-b906-6480e06cf03f) | Article with a "Still have a question?" card |

**Not found.** The "it's a match" query did not return a Bumble match-moment screen, only Chats
and Liked You again. I have therefore made no claim about Bumble's match screen. Numaya's match
composition comes from its own V5 brief and is unchanged.

## What I observed

1. **White and neutral surfaces.**
   - The canvas is white almost everywhere.
   - Light grey appears in three places: recessed chips (Interests), the Settings page background
     behind white rows, and the grey bands between interest groups.
   - Text is near-black, with a mid-grey for secondary lines.
2. **Brand colour as an accent.**
   - Yellow is reserved for the star (SuperSwipe), the match-queue expiry rings, count badges on
     the matches tile, and the selected-interest outline.
   - Selected filters, the "Your life" chips, segmented tabs and toggles are **black**, not
     yellow.
   - The rest of the interface is monochrome.
3. **Selected versus unselected.**
   - Filter chips are outlined white capsules; the selected one adds a checkmark and a darker
     outline.
   - Interest chips are grey; selected adds a yellow outline.
   - "Your life" chips are outlined; selected is a solid dark fill.
4. **Cards versus direct content.**
   - Chat rows, profile info rows and help text sit directly on white.
   - Cards are used for distinct modules: Opening Moves, Premium, "Still have a question?", the
     "My location" section on a profile, and the in-photo "Things we can talk about".
5. **Outlines versus elevation.**
   - Module cards combine a hairline with a very soft shadow.
   - Filter groups are outlined.
   - Settings rows are white on a grey page, with no shadow.
   - Nothing looks heavy.
6. **Conversation rows.** Large circular avatars, bold name, grey preview, and no dividers;
   spacing alone separates the rows.
7. **Navigation.** A flat white tab bar with labels and no shadow. The active tab is a filled
   black icon and label; the inactive ones are line icons.
8. **Corners and shapes.**
   - Photo cards have roughly 12–16px corners.
   - Chips, buttons and the composer are capsules.
   - Avatars, the star button and the next button are circles.
9. **Small labels.** "Your move" is a small neutral-grey rounded rectangle with dark text. Counts
   are yellow or red circles.
10. **Shadows.** Very soft, used on module cards and sheets only.

## What fits Numaya

- **A white canvas with greys for structure.** Light grey for recessed controls and chips, and
  white outlined or grey modules for distinct content. This is the core of V9's palette.
- **One accent, used sparingly.** In Bumble, yellow carries the signature action and new things,
  and everything else is neutral. V9 does the same with purple: actions, selection, the active
  tab and counts you act on.
- **Rows directly on the canvas** for conversations and profile details. V9 keeps V8's inset
  dividers, because Numaya's rows carry a "Your move" label and an unread count that read better
  when grouped.
- **A neutral "Your move" label:** grey with dark text. V9 adopts this exactly.
- **Outlined groups** for filters and settings, and **flat information cards** in the neutral
  grey.
- **Shadows only where something sits above content.** V9 is stricter than Bumble here: modules
  are outlined, without the extra soft shadow, because Numaya's white canvas already gives
  outlines enough contrast.

## What not to copy

| Bumble | Why not | V9 instead |
|---|---|---|
| Yellow brand colour | It is Bumble's identity | Purple `#7262C7` throughout |
| Circular avatars, round star and next buttons, capsule chips | The brief asks for no circles and tighter geometry | Rounded squares and rounded rectangles on a 6/8/10/12/14 scale |
| A checkmark inside the active filter | The brief asks for the fill alone | The active filter is solid purple, with no checkmark and still `aria-pressed` |
| Black selected states | Numaya's selection language is purple | Purple stays the selection colour |
| A flat tab bar with labels | Numaya's navigation is icon-only and floats | Compact (56px), with a hairline and one soft shadow |
| A progress bar under the logo | The brief asks for it to go; in Numaya it explained nothing | Removed |
| Grey bands between interest groups | Numaya's sets are already separated by headings and spacing | Kept direct |

## Decisions for V9

Each decision is specified in [design-system.md](design-system.md).

1. **Canvas `#FFFFFF`**, with neutral greys only: secondary `#F7F7F8`, inset `#F0F0F2`, border
   `#E4E4E7`, disabled `#EAEAED`. No warm or lavender tones.
2. **Five surface treatments:**
   - direct content;
   - outlined white modules and groups;
   - secondary-grey information containers;
   - inset-grey recessed controls;
   - floating chrome with one soft shadow.
3. **No circles:**
   - rounded-square avatars, counts, radios and switch thumbs;
   - readiness shown as a bar;
   - the match scallop kept.
4. **Purple only for meaning:**
   - primary actions;
   - selected pills, filters, controls and rows;
   - the active tab icon;
   - unread counts;
   - "New" and "Live now" text;
   - your messages.
5. **Status labels** in four tones (neutral, emphasis, strong, alert) with one shape.
6. **Compact navigation:** 56px, a rounded rectangle, an inset-grey active item.

# V9 design decisions

Each decision names what changed, why, and where it lives. The alternatives are drawn in [design-exploration.html](design-exploration.html). Research is in [research-and-design-audit.md](research-and-design-audit.md).

| ID | Decision | Where |
|---|---|---|
| D-01 | **Typography returns to V7:** Plus Jakarta Sans for headings, names and numbers, and Figtree for text and controls, at the Ente text-style sizes in Figma. Bree Serif and Google Sans are unregistered; their files and licences stay in `assets/fonts/` for recovery. Kept from V8: times inside bubbles and the one-line chat header name. | `foundations/app_typography.dart`, `pubspec.yaml` |
| D-02 | **Radii return to V7:** tag 12, field 16, buttons and sheets 20 (Ente radius/xl), cards 20, hero 24, photos 16. Chips, segments and the navigation bar are pills again. The `chip` and `nav` tokens from V8 stay, pointing at the V7 values. | `tokens/monochrome_tokens.dart` `MonoRadii` |
| D-03 | **Adaptive photo scrim.** Each photo's lower 40% is decoded once at 12×16 and averaged as relative luminance. The gradient's bottom edge runs from 24% (dark photos) to 52% (white photos). It covers only the band under the text and eases to clear in five stops. Applied on Discover, the full profile, Match, the Likes grid and the member's own cover. | `widgets/people.dart` `PhotoLuma`, `PhotoScrim(sample:)` |
| D-04 | **Single-column information cards.** A small filled icon and heading in brand ink, the value (24/32 bold), one line of description, an optional visual, then metadata. Art sits beside the text in its own 96pt column, and drops under the text at large sizes. The whole card is one tap target and holds no buttons. It replaces V8's two-column tiles. | `widgets/info_tile.dart` `StatCard` |
| D-05 | **The setup card reports, and its tap opens the next step.** No button sits inside it. The art's ring fills with real progress. | `profile_setup_card.dart` |
| D-06 | **One divider rule.** A 1px `#EBEBEB` line with the same margin at both ends: the card padding inside cards, the gutter on the chat list, and 0 where the parent already insets. | `widgets/divider.dart` `NumayaDivider` |
| D-07 | **No decorative icon backplates.** Removed the tinted squares on activity tiles and the grey disc behind banner arrows. Functional backplates remain: the send button, photo action buttons, selection marks and swipe stamps. | `content.dart` `InfoCard`, `info_tile.dart` |
| D-08 | **Compliments stay in Messages,** as V8 built them: one list sorted by time, and a Compliment is the first message of its conversation. V9 adds the shared avatar from the row into the chat header. | `conversation_row.dart`, `chat_header.dart` |
| D-09 | **Tab switch fade.** All tabs stay mounted (state and scroll kept) and the selected one fades in over 200ms ease-out. Under reduced motion the switch is instant. | `widgets/tab_fade_stack.dart`, `app/router.dart` |
| D-10 | **Outlined secondary buttons kept from V8,** now at the V7 20pt corner. | `widgets/buttons.dart` |
| D-11 | **Card padding 20,** equal to the screen gutter, so cards, rows and dividers share one rhythm. | `MonoSpace.cardPadding` |
| D-12 | **Profile hub without duplicates:** Help leaves the title bar (it is a row), the Settings row goes (it is in the bar), and the prompt card goes (it is in Edit profile and Preview). | `profile_screen.dart` |

## Kept unchanged on purpose

- **Brand purple `#7262C7`** and the semantic colour tokens. The audit found no contrast failures to fix.
- **Motion tokens:**
  - Presses respond on touch-down (120ms scale).
  - Pushes take 280ms on the emphasized curve; pops take 200ms.
  - Sheets rise in 280ms and leave in 200ms.
  - All of these become zero under reduced motion. The Apple guidance (critically damped by default, quicker exits, the same path in and out) is already met.
- **No read or delivery ticks.** There is no backend to report delivery, so ticks would be false. "Not sent: saved on this device" remains the honest status.
- **The Discover photo actions** keep their solid backplates, for contrast over images.

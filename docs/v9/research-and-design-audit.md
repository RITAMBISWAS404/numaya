# V9 research and design audit

Branch `version-9`, from the V8 state `47ba247` (tagged `checkpoint/v8-baseline-20261112`). This covers the research and the audit; the decisions are in [design-decisions.md](design-decisions.md).

## 1. What was available

| Source | Status | Used for |
|---|---|---|
| Mobbin connector | Worked. 11 screen searches on iOS, 4 to 8 screens each. | Dating, messaging, consumer-app patterns |
| Figma (claude.ai connector) | Worked, but read only partly. The radius node `11112:4508` on the reference file `22AeTw6QiPj2fNYHLhC7MK` returned one colour variable, not the radius values. | The V7 values already in the code were transcribed earlier from this file (Ente text styles 10854:4420, Button Large 2207:41759, Banner 14590:125245). They are cited in `app_typography.dart` and `monochrome_tokens.dart`. |
| Figma plugin (desktop) | Needs sign-in through `/mcp`. Not used. | |
| Claude Code skills | `apple-design` read in full and applied to motion. `emil-design-eng`, `animate` and `impeccable` are installed and were not loaded; their rules overlap with what was applied. **No "ML Coval" skill is installed**, so none was used. | |
| V8 phone folder (206 captures) | Reviewed as a montage of the 12 key screens. | The audit in section 3 |

Screens were viewed as low-resolution previews. Nothing below claims more detail than those previews show.

## 2. Applications and screens reviewed

- **Hinge** (8 screens): profile with prompt cards ([fbcdd966](https://mobbin.com/screens/fbcdd966-6613-4e8e-89e0-d0947fbc4760)), the discovery feed with filter pills ([d432ba1b](https://mobbin.com/screens/d432ba1b-3753-4a06-8bed-5cefe15d7465), [c7fd5c2f](https://mobbin.com/screens/c7fd5c2f-2706-421a-b4f6-082d19206c8a)), Hinge+ profile hub with a boost sheet ([e3a435f1](https://mobbin.com/screens/e3a435f1-9117-467e-8622-27a54be3c751)), the prompt picker ([a3d7eca8](https://mobbin.com/screens/a3d7eca8-ad55-469b-97a5-c8d3cd15ddd7)), and a first-like tip dialog.
- **Bumble** (6): the People card stack ([83e93b49](https://mobbin.com/screens/83e93b49-e15d-462c-ae89-810a4613cea0), [ee54d57a](https://mobbin.com/screens/ee54d57a-33f7-4f05-ba27-012f9f74eb48)), Liked You with filter pills ([ee33fda3](https://mobbin.com/screens/ee33fda3-1add-46fd-8c57-855f48f89c87)), and a profile with a location card ([ecc58b78](https://mobbin.com/screens/ecc58b78-c02a-4070-8c1b-5f8e61d8344a)).
- **happn** (5): Explore with the name above the photo ([ff0d39f4](https://mobbin.com/screens/ff0d39f4-b5a1-4314-aa71-353f7a200223)), a place grid, a profile-completion checklist ([e642ca7d](https://mobbin.com/screens/e642ca7d-6c35-4aa1-9fc4-9c9116f78033)), and the Hub.
- **WhatsApp** (5): Chats list ([f5304ab1](https://mobbin.com/screens/f5304ab1-cd5e-4c68-b363-3900431ca4a5)), a conversation with date chips, call events and ticks ([f95b630a](https://mobbin.com/screens/f95b630a-93ca-437f-825e-86235a109257)), and Lists settings.
- **Airbnb** (4): Edit profile with plain icon rows ([fbf48374](https://mobbin.com/screens/fbf48374-237b-41b6-b40a-31308d44c8ab)), the About me sheet, and the host card with stats ([f5de44f9](https://mobbin.com/screens/f5de44f9-d5f8-4bb7-afd2-b8eceeb9ce57)).
- **Uber** (4): a safety onboarding page with a full-width illustration ([f850dfe4](https://mobbin.com/screens/f850dfe4-1570-485d-b97c-e3d45ea1b7f9)), Help with an order card, Business Hub, and Grocery shortcuts.
- **Binance** (4): the Exchange home with a balance and functional cards ([ff356e59](https://mobbin.com/screens/ff356e59-29b7-46c6-8a47-0c7ffa062688)), the Assets overview ([f8e88426](https://mobbin.com/screens/f8e88426-3957-4d55-88f9-4101c41c9925)), and Margin.
- **Apple Health** (4): Steps highlights ([ee42f048](https://mobbin.com/screens/ee42f048-62bf-4c45-af1c-9d4613c4398e)), Health Highlights, articles with large art, and Blood Pressure.
- **Tiimo** (22 screens): reviewed for V8 and recorded in [docs/design/v8/TYPOGRAPHY.md](../design/v8/TYPOGRAPHY.md). V9 reverses the serif decision (D-01), so no new Tiimo pass was made.

## 3. Patterns observed

### Profiles and discovery
- **The photo leads, and the controls are few.** Hinge, Bumble and happn all give the photo most of the width, with corners of about 16 to 24pt.
- **Name placement differs.** Hinge and happn put the name above the photo, so no text sits on the image. Bumble puts it on the photo, bottom-left, over a gradient confined to the lower band.
- **Bumble's gradient is local.** It darkens only behind the name; the top and middle of the photo are untouched. That is the model for D-03.
- **Actions over a photo do get backplates.** Hinge's heart and Bumble's star sit on solid circles. That is a functional backplate, needed for contrast over images, not decoration.
- **Facts are chips under the photo,** never on it: Bumble's "Things we can talk about", happn's "Active today".

### Cards and information
- **Apple Health highlights** use the order V9 adopts: a small coloured glyph and label, a one-line insight, a large number, then a visual. The glyph has no container.
- **Binance** separates data from actions strictly. The balance and P&L form one block, and Add Funds, Send and Transfer form their own button row.
- **Airbnb's host card** groups three stats with hairlines between them, and the icon rows below it have no icon containers.
- **happn's completion list** is the counter-example: every row has an icon on a tinted square, and the screen reads busier for it.

### Messaging
- **WhatsApp's chat list:** a 52 to 56pt avatar, the name in bold, a one-line preview, and the time top right. The time turns the accent colour and a count badge appears when there is unread activity.
- **WhatsApp's conversation:** date chips, the time inside each bubble at the bottom right, ticks for own messages, and a composer with an attachment button, a field, and camera and microphone buttons.
- **Events sit in the thread as bubbles** (calls, missed calls). This supports treating a Compliment as the first message of its conversation.

### Spacing, type and motion
- **Uber** gives illustrations the full width and a page of their own, never a thumbnail inside a busy card.
- **Every reference keeps one gutter** (16 to 20pt) and one card padding. Numaya had a 20pt gutter with 16pt card padding. V9 makes both 20.
- **The Apple skill's motion guidance:**
  - Respond on touch-down. Numaya's `Pressable` already does.
  - Use critically damped motion by default; avoid bounce unless a gesture carried momentum.
  - Make exits quicker than entrances.
  - Keep spatial consistency: enter and exit along the same path.
  - Under reduced motion, cross-fade rather than move.

## 4. Audit of V8 against the brief

| Area | V8 state | Finding |
|---|---|---|
| Typography | Bree Serif titles, Google Sans everywhere else | Departs from Figma's text styles. Breaks mid-word at 200% text. Reverted (D-01). |
| Radii | 8/10/12/16/20 scale | Reads sharper than the established look. Reverted to V7 (D-02). |
| Photo text | Fixed 24% gradient | White names fall to about 2.5:1 on bright photos. Made adaptive (D-03). |
| Profile, Your activity | Two narrow tiles | Uneven wrapping, three-line metadata. Now single-column cards (D-04). |
| Profile setup card | Progress plus a button inside | Mixes data and action. Now one tappable card (D-05). |
| Dividers | Inset to each row's text | Lines start at different places. One rule now (D-06). |
| Icons | Tinted square in activity tiles; grey disc behind banner arrows | Decorative backplates removed (D-07). |
| Profile hub | Help and Settings both in the bar and in the list; the prompt repeated from Edit profile | Duplicates removed (see the MVP table in [implementation-report.md](implementation-report.md)). |
| Tab switch | Hard cut | Fade added, with state kept (D-09). |
| Chat list to chat | Plain push | The avatar now carries into the header. |
| Cards | 16pt padding inside a 20pt gutter | Unified at 20. |
| Read and delivery ticks | Not shown | Still not shown: there is no backend to report delivery, and showing ticks would be false. |

## 5. Adapted and rejected

**Adapted**
- Bumble's local, bottom-band gradient, made adaptive per photo.
- Apple Health's highlight order for information cards.
- Binance's separation of numbers from actions.
- Airbnb's plain icon rows and near-full-width hairlines.
- WhatsApp's list anatomy (avatar, preview, time, count) and in-bubble times.
- Uber's rule of giving art real room.

**Rejected**
- Hinge's serif prompt type (Numaya keeps one family pair).
- happn's tinted icon tiles.
- WhatsApp's wallpaper, green palette and ticks without real delivery data.
- Bumble's yellow branding.
- Binance's dense multi-tab dashboards (too much for a dating hub).
- Slide transitions between tabs (they imply an order the tabs do not have).

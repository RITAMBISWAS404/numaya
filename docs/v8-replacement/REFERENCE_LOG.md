# Reference log

Every reference used in this run. "Observed" means actually opened in this session; inference is marked separately.

## Figma (claude.ai connector, read-only, source file not edited)

File `22AeTw6QiPj2fNYHLhC7MK` (ENTE VISUAL DESIGN, copy). The page list was read in full.

| Node | Page | Read as | Observed | Numaya mapping |
|---|---|---|---|---|
| `10854:4420` Text styles | Design system | Variables | Display-1 Outfit 32/40 600; Display-2 24/32; Display-3 and H1 20/28; H2 18/24; Large 16/20; Body Inter 14/20 500; Body-Bold 600; Mini 12/16; Tiny 10/12 | `AppTypography` sizes; Numaya keeps its own faces and the approved 15pt body |
| `2207:41759` Button Large | Design system | Variables | radius/xl 20; spacing sm 8, md 12, xxl 24; background/base #f4f4f4; fill/dark #eaeaea | `AppRadii.control` 20, canvas grey |
| `12099:96480` Settings | Updated screens | Screenshot | Grouped rows in white 20pt cards with no hairlines between rows; outline icons without backplates; one dark storage card at the top; a destructive row in red | Kept V7's no-hairline grouped cards (C-04) and plain icons (C-05) |
| `26580:110754` All bottom action sheets | Updated screens | Screenshot | Sheets: an icon-over-label action grid, then a hairline, then a list; Delete in red | Confirms V7's action sheets; no change |
| `26580:259932` Empty states variants | Updated screens | Screenshot | Centred mascot art, a title, two lines of body, one solid action; filter pills; floating nav pill | Confirms V7's EmptyState and nav; mascot for waiting (A-01) |
| `30286:70766` Home screen | Updated screens | Screenshot downloaded, not reviewed in detail | — | — |

The `12099:96447` page inventory was 876k characters. It was summarised to its 15 top-level frames, and the relevant frames were read individually. Frames on other pages (Rituals, Photo cluster and so on) were not used. Nothing superseded was inspected.

## Mobbin (connector)

These searches ran on 12 November 2026 in this same session, during the now-archived V9 run, on iOS. They are reused as family evidence, as document 02 allows, and are not re-run.

| App | Screens (mobbin.com/screens/…) | Useful | Rejected |
|---|---|---|---|
| WhatsApp | `f5304ab1-cd5e-4c68-b363-3900431ca4a5` (Chats), `f95b630a-93ca-437f-825e-86235a109257` (conversation) | Avatar, name, preview, time, and an unread count with the time in the accent colour; times inside bubbles; date chips; a quiet composer | Wallpaper, green palette, ticks without delivery data, calls |
| Hinge | `fbcdd966-…` (prompts), `d432ba1b-…`, `c7fd5c2f-…` (discovery), `e3a435f1-…` | The photo leads; the like action on the photo edge has a solid backplate | Serif prompt type |
| Bumble | `83e93b49-…`, `ee54d57a-…`, `ee33fda3-…` | The name sits on the photo over a gradient confined to the bottom band | Yellow branding |
| happn | `ff0d39f4-…`, `e642ca7d-…` | The name above the photo is an alternative to text on the photo | Tinted icon squares on every row |
| Airbnb | `fbf48374-…`, `f5de44f9-…` | Plain icon rows; hairlines across nearly the full content width | — |
| Uber | `f850dfe4-…` | One solid primary action, a text secondary | — |
| Apple Health | `ee42f048-…` | A highlight card: small glyph and label, one line, a large value | — |
| Binance | `ff356e59-…`, `f8e88426-…` | Used only for the wallet question: numbers kept apart from actions | Dense dashboards |

**Tiimo** (22 screens): observed in the V8 run, recorded in `docs/design/v8/TYPOGRAPHY.md` on the archive branch. It shows a soft display face for one line per screen and sans for everything functional. The fonts Tiimo actually uses were not identified, and no claim about them is made. This is used only for the T-02 comparison.

## Primary sources (from the brief, not re-fetched)

NN/g visual design principles and Gestalt proximity, which back the tighter in-group gaps (L-01). google/fonts METADATA for Bree Serif (Regular 400) and Google Sans (OFL, 400–700), which back FONT_ASSET_INVENTORY.

## Skills (installed in `.claude/skills`, instructions read)

| Skill | Use |
|---|---|
| `design-review` | Read in full, including its rubric. Used for the pilot critique (score 3/4, recorded in SCREEN_LEDGER). |
| `apple-design` | Read in this session (community guidance, not Apple-authored). Applied to motion: touch-down feedback, critically damped transitions, quicker exits, reduced motion. Already met by the V7 tokens, so no change. |
| `emil-design-eng`, `animate`, `impeccable`, `flutter-ui-design` | Installed, not loaded. Not claimed as used. |

**ML Coval:** no skill by that name is installed. `emil-design-eng` (Emil Kowalski) is the likely intended one; it was not loaded.

## Not available or not used

- **Figma plugin (desktop):** needs sign-in through `/mcp`.
- **The old V8 "3D art" image:** never supplied.
- **Live web fetches** of the brief's GitHub skill repositories: not needed, because the skills were already installed locally.

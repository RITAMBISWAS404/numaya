# Component rules

**Scope:**
- All components are in `apps/numaya_mobile/lib/core/design_system/widgets/`.
- Screens import only `design_system.dart`.
- This lists only the treatment; behaviour, semantics and states are unchanged from Monochrome
  Meetup unless noted.

**Shared behaviour:**

| Behaviour | Rule |
|---|---|
| Press | a small scale on `Pressable`, with no Material splash |
| Hit area | at least 48dp, enforced by `androidTapTargetGuideline` in tests |
| Accessible label | always present |
| Motion | through `AppMotion`, which is off under reduced motion |

## Actions
| Component | Treatment | Rule |
|---|---|---|
| `NumayaButton.primary` | Purple pill, 56pt, white 16/600 | **One per screen** |
| `.secondary` | **Filled `field` pill, ink label, no ring** | Cancel, Reset, Not now, Save draft |
| `.brand` | Tint pill, purple label | A secondary that belongs to a brand moment (Premium card) |
| `.quiet` | Text only | A second choice under a primary |
| `.destructive` / `.destructiveSolid` | Red text / red pill | Unmatch, Delete |
| `NavIconButton` floating | 46pt white rounded square (16pt corners), **no ring** | Header back and actions |
| `NavIconButton(brand)` | Tint square, purple icon | Like in For You lists |
| `DecisionBar` (56pt) | Pass: filled `field` with an ink ✕ and label. SuperSwipe: tint circle with a purple star. Like: purple pill with a white heart and label. No edges. | Discover, Like back. At 320pt the labels drop and icons stay (labels remain in semantics). |
| Profile Preview | 56pt round filled button with a globe icon, a `Tooltip`, and the semantic label "Preview profile" | |

## Fields and selection
| Component | Treatment |
|---|---|
| `InputSurface` (text fields) | Filled `field`, 18pt corners, 58pt, transparent 2pt border. **Focus:** white surface with a 2pt purple edge. **Error:** red edge plus a message. **Disabled:** fill. |
| Search | Filled pill, 52pt, muted magnifier |
| Code cells | Filled when idle; white with a purple edge when active |
| `CountryCodeBadge` | Filled, no border |
| `ViewTabs`, `NumayaChip` | Unchanged pills: white or fill when idle, purple when selected |
| Radio, checkbox, switch | Unchanged (3:1 outline when idle, purple when on) |
| Option lists (`OptionGroup`) | One white card, **no dividers** between rows (rows are 60pt) |

## Cards and content
| Component | Treatment |
|---|---|
| Hero card | White, 32pt corners, 24pt padding. One per priority screen. |
| `WhiteCard`, `ListGroup` | White, 24pt corners, rows padded 20pt. **Final polish (FP-02):** quiet `divider` hairlines between rows, starting at the row's text (after the tile) and ending at the card padding; `dividers: false` opts out |
| `ListRow` | **Final polish (FP-03):** a `leading` icon sits in a 40pt `IconTile` coloured by `tone` (neutral by default); `inlineIcon: true` keeps a bare icon for metadata. The value takes at most 60% of the space left after the tile |
| `IconTile` | Rounded square: 40pt (12 corner, 20pt icon) in rows, 48pt (14 corner, 22pt icon) in cards and tiles. Tint background, foreground ≥ 4.5:1. Tone by meaning (`AccentTone`), never decoration |
| `_Tile` (Profile grid) | White, 24pt corners, a 48pt `IconTile` in its tone (visibility blue, Opening Moves coral, verification green, Premium purple), label and status |
| `StatusBadge` | `(bg, fg, weight)`. Neutral: fill grey with no outline. Brand: tint with purple text. On a photo: white. |
| `CompletionCard` | `card` title, an 8pt purple bar |
| `MetricTile` | Unchanged; "—" plus "Not measured" when there is no data |
| `IllustrationSlot` | Dashed placeholder at a fixed ratio. **Scales its caption down** instead of overflowing at large text. |

## People and messages
| Component | Treatment |
|---|---|
| `PersonHeroCard` | **Image-first.** A 4:3 photo (24pt corners) with only white badges and the photo count on it. Below it, the name (Jakarta 32/800, 24 above 160% text), then the job with an inline icon. |
| Composer | A white tray (30pt corners, 6pt padding) holding a filled 24pt-corner field. The field gets a purple edge only when focused. Send is a purple circle. |
| Chat list | Rows with no dividers (avatars separate them) |
| Context menu | A white grouped card, no dividers, red for destructive |

## Overlays
| Component | Treatment |
|---|---|
| Bottom sheet | White, 32pt top corners, grabber, 22pt Jakarta title, **no rule under the header** |
| Event RSVP bar | Floating white card with the `floating` shadow and **no hairline**. Corner 40 = the 56pt button's 28 + the 12pt inset (FP-06) |

## Final polish additions
| Component | Treatment |
|---|---|
| Swipe stamp | While dragging the Discover photo: a 76pt white disc with a check (Like, `brandText`) or a cross (Pass, ink), plus the word. Fades in from 25% of the 96pt threshold (FP-08) |
| Match photo | One square photo of the matched person, 32 corner, up to 320pt and at most 40% of the screen height; their initial when there is no photo; a 56pt purple heart mark on the lower edge (FP-05) |

## Choosing a list pattern
| Pattern | Use when | Example |
|---|---|---|
| **Grouped list** (`ListGroup`) | Several related rows of the same kind; scanning matters | Settings, Account Health, event metadata, help |
| **Independent cards** | Each item is distinct and carries its own content or action | Profile tiles, prompts, event cards, the Premium card |
| **Avatar rows** | People | Chats, event attendees |

Never put a grouped list inside a card, and never add dividers *and* card gaps to the same list.

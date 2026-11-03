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
| `WhiteCard`, `ListGroup` | White, 24pt corners, **no row dividers**, rows padded 20pt |
| `_Tile` (Profile grid) | White, 18pt corners, icon in purple, label and status |
| `StatusBadge` | `(bg, fg, weight)`. Neutral: fill grey with no outline. Brand: tint with purple text. On a photo: white. |
| `CompletionCard` | `card` title, an 8pt purple bar |
| `MetricTile` | Unchanged; "—" plus "Not measured" when there is no data |
| `IllustrationSlot` | Dashed placeholder at a fixed ratio. **Scales its caption down** instead of overflowing at large text. |

## People and messages
| Component | Treatment |
|---|---|
| `PersonHeroCard` | **Image-first.** A 4:3 photo (24pt corners) with only white badges and the photo count on it. Below it, the name (Jakarta 32/800, 24 above 160% text), then the job with an inline icon. |
| Composer | A white tray (30pt corners, 6pt padding) holding a filled 24pt-corner field. The field gets a purple edge only when focused. Send is a purple circle. |
| Chat list | Rows with no dividers |
| Context menu | A white grouped card, no dividers, red for destructive |

## Overlays
| Component | Treatment |
|---|---|
| Bottom sheet | White, 32pt top corners, grabber, 22pt Jakarta title, **no rule under the header** |
| Event RSVP bar | Floating white card with the `floating` shadow and **no hairline** |

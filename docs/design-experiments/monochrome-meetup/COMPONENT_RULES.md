# Component rules

**Scope:** every component is in `lib/core/design_system/widgets/`; screens import only
`design_system.dart`.

**Every interactive component shares these behaviours:**

| Behaviour | Rule |
|---|---|
| Press | a small scale press on `Pressable`, with no Material splash |
| Hit area | at least 44pt |
| Accessible label | always present |
| Motion | follows `AppMotion`, which turns off under reduced motion |

## Actions
| Component | Default | Pressed | Disabled | Notes |
|---|---|---|---|---|
| `NumayaButton.primary` | brand purple pill, white 16/600 label, 52pt | scale 0.98 | grey fill, grey label | **one per screen** |
| `.secondary` | white pill with a hairline (ink 30%), ink label | scale | grey | Cancel, Reset, "Not now" |
| `.brand` | brand-subtle pill, purple label | scale | grey | a secondary that belongs to the brand moment ("Set Opening Moves") |
| `.quiet` | text only, ink | | grey text | second choice under a primary |
| `.destructive` / `.destructiveSolid` | red text / red pill with white text | | grey | Unmatch, Delete account |
| `small: true` | 38pt pill; a small primary stays purple | | | "Edit profile", "Find your people" |
| `NavIconButton` floating | 42pt white rounded square (14pt corner), hairline, ink icon | scale 0.92 | grey icon | header actions, back |
| `NavIconButton(brand: true)` | brand-subtle square, purple icon | | | Like in For You lists |
| `NavIconButton` plain / flat | bare icon / grey square | | | sheet headers / in cards |
| `NumayaFab` | purple rounded square with a white arrow | scale 0.94 | grey | onboarding Next |
| `TextLink` | purple semibold, underline at 32% | | grey | inline links |
| `DecisionBar` | Pass white with hairline · SuperSwipe brand-subtle with purple star · Like purple | | | Discover, Like back |

## Selection
| Component | Unselected | Selected | Notes |
|---|---|---|---|
| `ViewTabs` (filters, segmented choices) | white pill, ink label, muted count | purple pill, white label and count | Meetup's date pills; scrolls edge-to-edge |
| `NumayaChip` | white (on the page) or fill grey (on cards), ink label, a "+" | purple pill, white label, a "−" | unavailable: grey label |
| Radio | 22pt ring in the outline grey (3:1) | purple ring with a purple dot | |
| Checkbox | 8pt-corner box, outline ring | purple fill with a white tick | |
| `NumayaSwitch` | fill track, 1.5pt outline edge, outline-grey thumb | purple track, white thumb with a soft shadow | the off state stays a visible control |
| `OptionCard` | white row with the mark on the right | mark selected | |
| Tab bar item | muted outline icon and label | grey capsule, purple filled icon and semibold label | notification dot in red |

## Fields
| State | Treatment |
|---|---|
| Default | white, 14pt corner, 54pt tall, 1pt outline `#8B8B94` (3.38:1) |
| Focus | 2pt brand outline |
| Error | red outline, red message under the field |
| Disabled | fill grey |

**Labels:** sentence case, 14/600, secondary colour (`fieldLabel`), above the field.

## Cards and content
| Component | Treatment |
|---|---|
| `WhiteCard`, `ListGroup` | white, 20pt corner, flat on the grey page. Row hairlines are inset 16pt; the group title is `section` (20/700). |
| `ListRow` | 56pt minimum. Label `row` (16/500); detail as a secondary caption; value muted, right-aligned; ink leading icon; chevron muted. |
| `InfoCard` | brand-subtle, no border; purple icon, bold title, secondary body (Alan) |
| `StatusBanner` | tinted by tone (info purple, pending warning, error danger) with an icon, title and body |
| `MetricTile` | white card: a muted label with an icon, a `metric` number with a muted unit, a status line. A missing value shows "—" plus a reason, never 0 (Bevel). |
| `EventCard` | 16:9 cover (clipped by the card's 20pt corner) with badges and a save button. Below it: a purple uppercase date eyebrow, a 20/700 title, then place and going rows (Meetup). |
| Event RSVP bar | floating white card, hairline, `floating` shadow: the status with its detail, and one action |
| `PromptCard` | white card: the question with a purple mark, the answer in `promptAnswer` |
| `EmptyState` | white card, centred: illustration (or slot), 20/700 title, body, optional small action |
| `IllustrationSlot` | fill grey, dashed `lineStrong` edge, image glyph, "Illustration: …" caption; fixed aspect ratio; decorative |

## People and messages
| Component | Treatment |
|---|---|
| `InitialsAvatar` | fill-strong circle with a charcoal bold initial. Ring (new match): purple. Verified mark: purple. |
| Profile avatar | 176pt, same neutral treatment |
| Person photo card | 4:3 photo (20pt corner). Name and details sit on the solid `photoPanel`, inset 6pt with a 14pt corner. **No gradient.** |
| Match portrait (scallop) | brand-subtle with a purple initial: the one celebratory purple surface |
| `MessageBubble` | mine: purple with white text. Theirs: white with ink text. 20pt corners with a 6pt tail corner. |
| Composer | white field, 14pt corner. Send is a purple circle when it can send, grey when it can't. |

## Overlays
| Component | Treatment |
|---|---|
| Bottom sheet | white, 28pt top corners, scrim ink 45%. It rises on `AppMotion.sheet` (none under reduced motion). |
| Toast | brand-subtle surface with purple icon and text, floating shadow |
| Context menus | white grouped card, red for destructive rows |

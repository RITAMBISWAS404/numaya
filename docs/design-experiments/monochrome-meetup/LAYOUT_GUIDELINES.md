# Layout guidelines

## Frame
| Element | Rule |
|---|---|
| Page | `canvas` grey. Content lives on white surfaces, or directly on the page for titles and captions. |
| Gutter | **20pt** each side (`AppLayout.screenGutter`). Only horizontal carousels and filter rows bleed to the screen edge (`ViewTabs(bleed:)`), with their first item on the gutter. |
| Content width | at most 430pt, centred on wider screens (`AppSpacing.contentMax`) |
| Vertical rhythm | `screenTop` 16 · `headingGap` 12 · `itemGap` 12 · `sectionGap` **32** · `screenBottom` 24 |
| Safe areas | handled by `NumayaScreen` and the tab bar |

**Tab bar:** a floating pill, 12pt from the sides and 12pt from the bottom; above the home
indicator when present.

## Page headers
| Header | Use |
|---|---|
| **Tab roots** (Home, Events, Likes, Messages, Profile) | a left-aligned 30/700 page title with rounded-square actions on the right. The Discover home keeps the wordmark. |
| **Pushed pages** (`NumayaTopBar`) | a rounded-square back button on the gutter and a centred 17/600 sentence-case title. Actions are on the right. |
| **Editorial pages** (onboarding, safety, premium, Opening Moves) | `ScreenHeader`: an optional illustration slot or art, a 28/700 heading and a secondary lede, left-aligned |

## Patterns
| Pattern | Rule |
|---|---|
| Sections | a 20/700 heading, then the content 12pt below; an optional caption under the group |
| Grouped settings | one white card per group, hairlines inset 16, helper text under the card (Meetup) |
| Image-first cards (events) | the cover at the top, edge to edge inside the card, then the text block with 18pt padding |
| Metric grids | two tiles per row with 12pt between, equal heights (`IntrinsicHeight`) |
| Filters | a pill row under the title, and a second row for sub-filters (Meetup: Explore / My events → Going / Waitlist / Saved / Hosting) |
| Sticky actions | `NumayaScreen.footer` above the keyboard. On event detail it is a floating RSVP card. |
| Empty states | a centred card in the content column, never full-bleed |
| Sheets | a white panel with a title row (title left, close right); content uses the same gutters |

## Avoid
- Nesting cards in cards.
- Arbitrary padding: use the roles above.
- Dividers where spacing suffices.
- Decorative containers around ordinary icons.
- White-on-white without a hairline or the grey page between.
- Repeated top bars.
- More than one purple primary per screen.

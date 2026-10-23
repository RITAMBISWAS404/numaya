# Components

Import everything from `src/design-system/index.js`. Props are documented in each component's
JSDoc. Live variants and states: `showcase.html`. Tier: **P** primitive, **C** composite,
**X** product pattern.

| Component | Tier | Purpose | Key variants / states | A11y notes |
| --- | --- | --- | --- | --- |
| `Button` | P | Text action | primary, secondary, quiet, destructive, destructive-solid, brand (soft lavender with a deep-purple label, Meetup "Sign up with email"); sm; inline; icon; loading; disabled | `aria-busy` when loading; one primary per screen |
| `Fab` | P | Forward step on data-entry screens | enabled, disabled, loading | `label` required |
| `IconButton`, `BackButton` | P | Icon-only action | floating, flat, plain; sm; pressed | `label` required; `aria-pressed` for toggles |
| `TextButton`, `Link` | P | Inline action / navigation | brand, muted, danger; disabled | Real `<a>` for navigation |
| `Spinner` | P | Progress | md, sm | `label` makes it a status |
| `Field`, `TextField`, `TextArea`, `SearchField` | P | Text entry | hint, error, disabled; counter; clear | Error linked via `aria-describedby`, `aria-invalid` |
| `PhoneField`, `CountryPicker` | C | Phone entry with country | formatted per country; searchable sheet | Country button `aria-haspopup="dialog"` |
| `CodeInput` | C | One-time code | idle, checking, error, success; grouped 3+3 | Single real input, `one-time-code` autofill |
| `Chip`, `ChipGroup` | P/C | Tags and multi-select | Meetup pills: white + hairline with a plus-circle; selected purple with white text and a minus-circle; static white + hairline; max quota → unavailable | `aria-pressed`, `aria-disabled` at quota |
| `Switch` | P | Binary setting | on (ink, Meetup), off (grey), pending, disabled | `role="switch"`; pending shows a status |
| `Checkbox`, `Radio`, `OptionCards` | P/C | Choice lists | single / multi with max; card or inline | Native inputs inside labels |
| `SegmentedControl` | P | 2–3 views | Meetup filter pills: grey idle, purple selected with white text | Tabs with arrow-key movement |
| `Slider`, `RangeSlider` | P | Numeric filters | single, dual (thumbs never cross) | `aria-valuetext` formatted |
| `Screen`, `ScreenBody`, `ScreenHeader`, `ScreenFooter` | P | Screen scaffold | brand tone; keypad/keyboard aware | One `h1` per screen |
| `TopBar`, `ProgressSegments`, `TabBar`, `Note` | C | Navigation and progress | back + progress, title + actions, large title; tab badges; tab bar floats (inset, `shadow.float`) with a brand-tint active item, filled icon and ink label | Progress is a `progressbar`; current tab `aria-current` |
| `Avatar`, `VerifiedBadge`, `Badge`, `CountBadge`, `Tag` | P | Identity and status | sizes xs–xl, ring (completion/time), verified (the filled purple `verified` seal, white outline on avatars; no check on a disc); initial avatars take a Meetup pastel (pink, periwinkle, lavender, yellow) chosen from the name | Verified always has a text label; decorative avatars hidden |
| `Card`, `Section`, `Divider`, `ListGroup`, `ListRow`, `TipCard`, `InfoCard`, `ConsequenceList` | P/C | Surfaces and lists | white hairline cards and groups; `InfoCard` is the guidance card (icon + near-black heading on the top row, body below, flat light-lavender `surface.brand`); `TipCard` leads with a plain filled glyph, no tile; row kinds nav, value, action, destructive, locked; sections separate at `layout.section-gap` (28) | Rows are buttons only when pressable |
| `PromptCard`, `ImagePlaceholder`, `PhotoSlot`, `PhotoGrid` | C | Profile content | prompt answers on Meetup's flat grey quote card; empty/filled/uploading/main slots | Add/remove buttons labelled by position |
| `ProfileCard`, `ActionBar`, `ProfileSection`, `SharedInterests`, `PageDots` | X | Discovery | photo-led: identity and shared interests over a scrim on the photo, neutral slate stand-in when there is no photo, optional `actions` overlapping the bottom edge; sizing hooks `--profile-card-photo-height`, `--profile-card-photo-min`, `--profile-card-ratio`; pass / super / like as 72×56 pills; `ProfileSection` is the one profile/Discover card (white, hairline, Fraunces title, no mark); `SharedInterests` is a ProfileSection of grey text-only pills | Card labelled "Name, age"; like = brand fill |
| `Sheet`, `ActionSheet`, `Dialog` | P/C | Modal surfaces | dismissable or not; destructive dialog | Focus trap, Escape, restore focus; dialog focuses Cancel |
| `Toast`, `Banner`, `CoachMark` | P/C | Feedback | busy/status toast; info, success, warning, error, offline banners | Live regions; errors use `role="alert"` |
| `Skeleton`, `EmptyState`, `ResultPanel`, `Illustration` | C | Loading, empty, completion | neutral / error; success / neutral / danger. `ResultPanel art` draws one `Illustration` scene (verified, unmatched, blocked) above the title; without art, a plain filled glyph in the tone colour. Neutral outcomes never show a check | Skeletons hidden from AT; one next step |
| `SetupProgress` | C | Profile setup intro | a heading with "N of 3 done", then three stacked horizontal step cards: "Step N of 3", name, one short line, one filled icon, status. Done: flat grey, "Done" with a check. Active: white with a 2px purple outline and soft shadow, "Up next" pill (the most prominent). Upcoming: white hairline, muted. No connector or progress bar; state comes from the store (`setupDone`) | Ordered list; active step is `aria-current="step"`; every state is written out |
| `MessageBubble`, `SystemMessage`, `Composer`, `ConversationRow`, `MatchQueue` | X | Chat and matches | sending, delivered, failed (retry/delete); your move; unread; 72×96 portrait previews (20px corner) on a horizontal rail, photo when present, else the pastel initial, with a new-match ring or a countdown ring that follows the corner; the composer field is a 20px rounded rectangle that grows to 120px, then scrolls, and wraps long URLs; send is a 44px circle | Enter sends, Shift+Enter newline; failures announced |
| `PlanPicker`, `ComparisonTable`, `LegalText` | X | Premium | selected plan, ribbon, savings | Radio group; legal text always visible |
| `PermissionPrimer`, `MatchCelebration`, `OrganicPortrait` | X | Permissions, match | not determined / denied → Settings; the primer leads with a plain 40px glyph (no tile). Match (the Numaya sketch): white page, one-colour Fraunces "It’s a match!", the matched person's real photo in a ten-lobed organic mask over a slowly turning lavender scallop (avatar initial when there is no photo), one line of copy, the `match-hands-heart` illustration slot; actions (composer, Keep browsing) in the screen footer | Heading is the screen's `h1`; portrait is an image named by the person; motion is decorative and off under reduced motion |
| `IllustrationSlot`, `MatchHeart` | C | Registered illustration areas | the slot keeps its registered aspect ratio and shows the supplied PNG, or its fallback (an `Illustration` scene, the joining heart, or reserved space) | Always decorative (`aria-hidden`) |
| `FilterChips` | P | Single-select filters (Likes, Messages, Activity, My activities) | horizontal rail that scrolls; selected purple with a leading check; optional count | `aria-pressed`; state never colour-only |
| `ActivityCard`, `ActivityMedia`, `ActivityStatus`, `MetaRow`, `AttendeeStack`, `IdentityRow` | X | Activity feed, details, lists | card (16:9 media) and compact (88px square) variants; media is a photo, a tone placeholder with the category glyph, or the lavender fallback; status: Live now, Full, Cancelled, Ended, Draft; participation: You’re going, Requested, On the waitlist, You’re hosting; title clamps to 2 lines; place is venue · area · distance only | The whole card is one button named by its visible text; first names only, the rest a count |
| `PersonTile` | X | Likes grid | 3:4 portrait placeholder, name and age, one context line, optional New / Matched badge | One button per tile, named by its visible text |
| `ReadinessMeter`, `MetricCard`, `ProgressBar` | X | Profile readiness | radial meter (112 / 72px) with the score written in the centre; metric cards with label, value, optional bar and a context line | Meter is `role="meter"` with value text; bars are `progressbar` |
| `OverlayRootProvider`, `Portal` | P | Scope overlays to a frame | — | — |

## Extension rules

1. **Reuse first.** Compose existing components before creating new ones.
2. **New component checklist:** named in the table above, states from
   [foundations](foundations.md#interaction-states), tokens only (no raw values), an accessible
   name, a showcase specimen, and a test for its interaction contract.
3. **New variants** only for a real, recurring need named in a screen spec. Prefer props over
   copies.
4. **Specified but not yet built** (build when the first screen needs them): segmented date field,
   completion tile, feature carousel, chip tabs with counts, photo crop and camera capture, swipe
   gestures on `ProfileCard`, filter card.

# Components

Import everything from `src/design-system/index.js`. Props are documented in each component's
JSDoc. Live variants and states: `showcase.html`. Tier: **P** primitive, **C** composite,
**X** product pattern.

| Component | Tier | Purpose | Key variants / states | A11y notes |
| --- | --- | --- | --- | --- |
| `Button` | P | Text action | primary, secondary, quiet, destructive, destructive-solid, brand (ink label on the brand-pink fill); sm; inline; icon; loading; disabled | `aria-busy` when loading; one primary per screen |
| `Fab` | P | Forward step on data-entry screens | enabled, disabled, loading | `label` required |
| `IconButton`, `BackButton` | P | Icon-only action | floating, flat, plain; sm; pressed | `label` required; `aria-pressed` for toggles |
| `TextButton`, `Link` | P | Inline action / navigation | brand, muted, danger; disabled | Real `<a>` for navigation |
| `Spinner` | P | Progress | md, sm | `label` makes it a status |
| `Field`, `TextField`, `TextArea`, `SearchField` | P | Text entry | hint, error, disabled; counter; clear | Error linked via `aria-describedby`, `aria-invalid` |
| `PhoneField`, `CountryPicker` | C | Phone entry with country | formatted per country; searchable sheet | Country button `aria-haspopup="dialog"` |
| `CodeInput` | C | One-time code | idle, checking, error, success; grouped 3+3 | Single real input, `one-time-code` autofill |
| `Chip`, `ChipGroup` | P/C | Tags and multi-select | toggle, remove, static; max quota → unavailable | `aria-pressed`, `aria-disabled` at quota |
| `Switch` | P | Binary setting | on (brand), off, pending, disabled | `role="switch"`; pending shows a status |
| `Checkbox`, `Radio`, `OptionCards` | P/C | Choice lists | single / multi with max; card or inline | Native inputs inside labels |
| `SegmentedControl` | P | 2–3 views | — | Tabs with arrow-key movement |
| `Slider`, `RangeSlider` | P | Numeric filters | single, dual (thumbs never cross) | `aria-valuetext` formatted |
| `Screen`, `ScreenBody`, `ScreenHeader`, `ScreenFooter` | P | Screen scaffold | brand tone; keypad/keyboard aware | One `h1` per screen |
| `TopBar`, `ProgressSegments`, `TabBar`, `Note` | C | Navigation and progress | back + progress, title + actions, large title; tab badges; tab bar floats (inset, `shadow.float`) with a brand-tint active item, filled icon and ink label | Progress is a `progressbar`; current tab `aria-current` |
| `Avatar`, `VerifiedBadge`, `Badge`, `CountBadge`, `Tag` | P | Identity and status | sizes xs–xl, ring (completion/time), verified; tones | Verified always has a text label; decorative avatars hidden |
| `Card`, `Section`, `Divider`, `ListGroup`, `ListRow`, `TipCard`, `ConsequenceList` | P/C | Surfaces and lists | row kinds nav, value, action, destructive, locked | Rows are buttons only when pressable |
| `PromptCard`, `ImagePlaceholder`, `PhotoSlot`, `PhotoGrid` | C | Profile content | editable prompt; empty/filled/uploading/main slots | Add/remove buttons labelled by position |
| `ProfileCard`, `ActionBar`, `SharedInterests`, `PageDots` | X | Discovery | photo-led: identity and shared interests over a scrim on the photo, neutral slate stand-in when there is no photo, optional `actions` overlapping the bottom edge; sizing hooks `--profile-card-photo-height`, `--profile-card-photo-min`, `--profile-card-ratio`; pass / super / like as 72×56 pills; shared interests as a white card with icon pills | Card labelled "Name, age"; like = brand fill |
| `Sheet`, `ActionSheet`, `Dialog` | P/C | Modal surfaces | dismissable or not; destructive dialog | Focus trap, Escape, restore focus; dialog focuses Cancel |
| `Toast`, `Banner`, `CoachMark` | P/C | Feedback | busy/status toast; info, success, warning, error, offline banners | Live regions; errors use `role="alert"` |
| `Skeleton`, `EmptyState`, `ResultPanel` | C | Loading, empty, completion | neutral / error; success / danger | Skeletons hidden from AT; one next step |
| `SetupProgress` | C | Profile setup intro | steps done (pink-tint tile, ink check), active (white row, ink tile, "Next"), upcoming (muted); light-neutral 24px container, 16px rows | Ordered list; active step is `aria-current="step"`; upcoming written out for screen readers |
| `MessageBubble`, `SystemMessage`, `Composer`, `ConversationRow`, `MatchQueue` | X | Chat and matches | sending, delivered, failed (retry/delete); your move; unread; 56×70 portrait previews with a new-match ring or countdown ring | Enter sends, Shift+Enter newline; failures announced |
| `PlanPicker`, `ComparisonTable`, `LegalText` | X | Premium | selected plan, ribbon, savings | Radio group; legal text always visible |
| `PermissionPrimer`, `MatchCelebration` | X | Permissions, match | not determined / denied → Settings | Never loops; "Not now" defers |
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

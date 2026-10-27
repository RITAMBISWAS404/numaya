# V16 component rules

Implemented in `src/design-system/styles/theme-withings.css` (components) and `src/flows/theme-withings.css` (flow
screens). Each rule maps an existing Numaya component to the closest reference pattern. No component, markup or
behaviour was added or removed. **Checked** means asserted by `tests/e2e/experiment-withings.mjs`.

| Numaya component | V11 | V16 rule | Reference | Checked |
|---|---|---|---|---|
| Page (`.fl-screen`) | White | Stone `#F5F4F1` | all | ✓ |
| Cards: `.card`, `.activity-card`, `.prompt`, `.prompt-set`, `.list-group__items`, readiness card | White, 1px outline | White, **no border, no shadow**, 14 corner | 02, 07, 14 | ✓ |
| Someone's profile sections (Discover, Like back) | Direct content on white | **White cards**, 16 padding, 14 corner, between the photos | 07 (stacked measurement cards) | ✓ |
| Card title (`.profile-section__title`) | Grey label | Ink, 15 medium | "Weight", "Daily Steps" | — |
| Info box (`.info-card`, `.fl-sheet-note`) | Grey fill | Page colour plus a hairline, ink icon | Notification box (08, 10) | — |
| Grouped rows (`.list-row`) | 52 min, medium label | 56 min, 16 regular label, secondary subtitle, dividers inset 16 both sides | 14, 17, 18 | ✓ |
| Group heading (`.list-group__title`) | 14 grey | **22 medium ink** | "Account Settings" | ✓ |
| Choice rows (`.option-cards`) | Separate outlined rows, 2px ring when selected | **One white card**, dividers, no ring; focus outline kept | 22 (radio list) | ✓ |
| Choice legend, chip-set label | Grey sentence case | **Bold capitals** like field labels | "FIRST NAME" | ✓ |
| Radio | Purple fill | 22, grey ring; selected ink ring plus ink dot | 21, 22 | ✓ |
| Checkbox | Purple | 22, 6 corner, grey ring; checked Withings blue with white tick | 23 | ✓ |
| Text field (`.input`, `.textarea__input`) | Grey fill, 12 corner | **White, 1px `#6D6C6A` outline, 8 corner, 54 tall**; focus 2px blue; invalid 2px red; disabled the fill | 11, 16, 26 | ✓ |
| Field label | 13.5 grey | **11.5 bold capitals, ink** | 11, 16 | ✓ |
| Search, composer | Grey fill | White with a hairline; composer 22 corner; send button an ink circle (disabled `#D6D2CE`) | inferred | — |
| Primary button | Purple, 14 corner | **Ink, white text, 12 corner, 50 tall** | Done, Next, Join | ✓ |
| Secondary button | White with grey hairline | **White, 1px ink outline** | Share, Previous | ✓ |
| Tint button (`.btn--brand`) | Lavender | Blue tint, deep-blue text | Explore data | — |
| Destructive (`.btn--destructive-solid`) | Red | `#CF3336`, white text | Delete My Account | — |
| Stacked cancel in a sheet (`.sheet__panel .btn--quiet`) | Plain text | Outlined secondary | Previous under Next | — |
| Disabled button | Grey | `#D6D2CE` with `#77736F` text | Disabled Next (23) | — |
| Small button (`.btn--sm`) | 44 pill, purple or grey | **36 visible pill (44 hit area kept), white with ink outline**; primary ones ink | Add a Reminder, Share | — |
| Header icon button (`.nav-button--floating`) | 12-corner square, hairline | **40 white circle** with a hairline in page and tab-root headers (Discover, Profile, Activity); a bare icon in modal headers | 10, 34 (home), 14 (modal) | ✓ |
| Modal header (`.topbar`) | On canvas, 16 semibold title | **White bar, bottom hairline, tracked bold capitals** | PROFILE, ACCOUNT & SECURITY | ✓ |
| Page title (tab roots) | 26 serif | **30 bold grotesk** | Good morning, John | ✓ |
| Flow heading (onboarding) | 31 serif | 26 medium | Are your cycles regular? | — |
| Step button (`.fab`) | Purple rounded square | **Ink circle**, white arrow | Add Logs (27) | ✓ |
| Discover actions | Ink and purple 72 × 56 pills | **56 circles**: Pass outlined, Like ink, SuperSwipe blue (float shadow on the photo) | Share / Done pair; round icon actions | ✓ |
| Content chips (interests, shared, facts) | Grey fill, 12 corner | **White, 12 corner, medium label** (fill on a white card); selected blue tint with deep-blue text | Withings+ / 6 Weeks / Activity chips (24) | — |
| View tabs (Likes and Messages filters) | Grey pills, purple selected | **Plain text; selected a blue-tint pill** | Week / Month / Quarter / Year (04, 33) | ✓ |
| Segmented (Edit / Preview, Explore / My activities) | Separate pills | **Grey track, white selected segment** | Programs / Library (25) | ✓ |
| Interest-set emoji holder | Grey 8-corner square | **28 circle in a pastel** by tone (yellow, lavender, pink, tint) | Round category icons (12, 20) | — |
| Status label (`.badge`) | Grey fill | **Outlined 1px ink, 6 corner**; "New" or "Live now" blue tint; white on photos | Withings+ badge (19, 36) | — |
| Unread count | Purple pill | Blue pill | — (accent rule) | — |
| Switch | Purple, pill thumb | **51 × 31, green on, round 27 thumb** | 13, 15, 18 | ✓ |
| Slider | Purple interval, pill thumbs | Fill rail, blue interval, round 26 white thumbs | inferred | — |
| Progress segments | Purple | Ink fill on the fill grey | Program progress (24) | — |
| Tab bar | Purple active | **Ink active (filled icon, semibold label), `#6B6966` inactive**, red dots, white with a hairline | 10 | ✓ |
| Avatars | Rounded squares, grey | **Circles; initials white on navy** | JO / JA (11, 13, 19) | ✓ |
| New-match portraits | 72 × 96 rounded rectangles | **72 circles**, navy initials, a thinner blue ring when unopened (final audit) | Assign to (40), Family (13) | ✓ |
| Match portrait placeholder | Grey scallop | Warm photo grey with an ink initial (scallop kept); your avatar flat with a white ring; title 32–36 bold | — | — |
| Photos | 20 / 16 corners | 16 profile photos, 14 tiles and slots; empty slot dashed with an ink "+" circle | — | — |
| Bubbles | Purple / grey | **Yours blue with white text, theirs white**, 14 corner with V11's 6 tail | inferred | ✓ |
| Sheets | White, 20 corner | White, 16 corner, **hairline under the header**, 20 medium title, warm grabber; dismiss is a **bare ✕** (final audit) | Assigned Sex (21), Continue with (42) | ✓ |
| Action sheet | White rows; outlined pill Cancel | White row group without shadow; Cancel a **separate white block**, 14 corner, semibold (final audit) | iOS action sheet (cffd85c8) | ✓ |
| Empty state | Centred on the page | **White card**, aligned to the content column, left-aligned, 18 semibold title (final audit) | Discover now (20), Family (13) | ✓ |
| Toast (`.pill`) | Ink | **Blue-tint pill** with deep-blue text | Password created (15) | — |
| Prompt mark | 22 purple on lavender, 8 corner | 24 **circle**, blue on tint | Round icon holders | — |
| Wordmark | Fraunces, purple mark | Hanken bold ink, mark in accent blue, rose dot kept | — (Numaya identity) | — |

## States

- **Focus.** A 2px blue ring on fields, search and the composer. Choice rows show a 2px blue outline through
  `:focus-within`. Buttons keep the design system's focus ring, recoloured blue.
- **Selected.** An ink radio, a blue checkbox, a blue-tint tab or chip, a white segment.
- **Disabled.** Warm grey fill with a grey label. Locked interests at the limit use the disabled foreground.
- **Pressed.** The design system's scale and press feedback, unchanged.

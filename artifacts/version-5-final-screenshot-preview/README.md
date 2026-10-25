# Numaya V5: final Tiimo-inspired preview

**Start here:** [contact-sheet.png](contact-sheet.png)

V5 is the last Tiimo-inspired experiment. It is narrowly scoped:

1. **Pills.** Only the emoji-and-text pills changed. Unselected: a light grey fill with no border.
   Selected: light purple with a fine purple outline. Both are 12px rounded rectangles.
2. **Restored shapes.** V3 and V4 had squared off other controls; they are back to their V2 shapes.
3. **Discover fade.** Real photos get a smoother black fade. Placeholders keep their solid band.
4. **Match.** Their photo fills the scalloped shape. Your photo is a smaller rounded square
   overlapping its lower-left edge. The purple heart is removed, and its space is kept for the
   hand illustrations.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v5` |
| Starting commit | `fa1272f`, the head of `experiment/tiimo-inspired-v4`, fetched and verified |
| Implementation commit | `5fc8282` |
| Final commit | the commit that adds this folder (see the branch head) |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

Open `http://localhost:5173/flows.html?screen=interests&theme=tiimo`. Replace `interests` with
`discovery`, `like-profile`, `likes`, `chats`, `chat`, `activity` or `basics` for the other screens.

The match screen shows a match only after you like Maya on Discover (she likes you back); otherwise
it shows its empty state. Without `&theme=tiimo` you get the approved design. All 20 captured states
are byte-identical to the approved design's committed gallery.

## Tiimo research (Mobbin plugin)

I searched Tiimo's iOS screens and flows with the connected Mobbin plugin and read the returned
screenshots. Downloading the full-size images from mobbin.com was blocked by this environment's
network proxy (HTTP 403), so the measurements below are estimates from Mobbin's preview images.
I did not open the exact URL in the brief; I used the plugin's search, which returned Tiimo's own
screens.

**Observed in Tiimo:**
- [Add morning routines, with selections](https://mobbin.com/screens/37f58a3d-1e1e-48a0-8a6c-167af5250b49)
  and [without](https://mobbin.com/screens/c6ae3650-762d-41f8-af89-100e55011f0f):
  - Emoji-and-text habit chips are soft rounded rectangles, not capsules: a corner of about a
    third of the chip's height, roughly 12px.
  - Unselected chips have no border.
  - Selected chips are a light purple fill with a fine purple outline, at the same size.
- [Add task: tag picker](https://mobbin.com/screens/cf3af403-5991-4df0-bbe8-74aebcaa1b44),
  [with selections](https://mobbin.com/screens/aaf410f9-2969-401f-bc38-b9a6ff60caa5), and
  [Explore](https://mobbin.com/screens/440f7888-db7f-42cf-a155-edc4781cc9f0):
  - Tag chips are a different component: capsules with a grey outline, filled with their
    category colour when selected.
  - Tiimo does not use one chip style everywhere.
- [What should we tackle next?](https://mobbin.com/screens/71ebc858-9b7f-46e3-80aa-cd5e0f9e38e5):
  suggestion chips use a light grey fill with no border.
- Other controls keep their own shapes:
  - capsule buttons ("Continue with my routines");
  - a capsule tab bar with a capsule active item
    ([Today](https://mobbin.com/screens/39db7491-b25a-400e-9e46-d15901520672));
  - circular icon buttons;
  - capsule section labels ("MORNING", "HIGH").

**Applied to Numaya:**
- The supplied Numaya reference's light grey for unselected pills (as in Tiimo's suggestion chips).
- Tiimo's habit-chip selection: light purple, a fine outline, the same size.
- About 12px corners.
- Every other control keeps its own shape: the same split Tiimo has between chips and buttons or
  navigation.
- Not taken from Tiimo: its outlined tag capsules and its category-coloured selection.

## Exact changes

All changes are scoped to `.theme-tiimo` (`src/design-system/styles/theme-tiimo.css`) and tokens.

| Area | V4 | V5 |
|---|---|---|
| Which elements are pills | Every `.chip`: interests, all filters, fact chips | Only emoji-and-text pills: `.chip[data-emoji]`, the rail they sit in (Activity's "All"), shared-interest tags, and the activity category tag. They are matched by the emoji mark, never by a bare `.chip`. |
| Unselected pill | Light lavender, or a half-strength category pastel, with a 1px outline | Light neutral grey `#F2F2F2`, no border, dark text |
| Selected pill | Very light purple, 1.5px outline | Light purple `#E9E4FB`, 1px purple `#7262C7` outline, deep purple text (6.6:1), the existing minus or check glyph |
| Pill corner | 12px | 12px on 36px pills; 8px on the 27px activity category tag (the same proportion) |
| Locked pill (five-interest limit) | White, pale outline | The same grey pill with muted text |
| Buttons (Continue, Pass, Like back, Keep browsing) | 16px | Capsule again (V2) |
| Filters without emoji (Messages, Likes), segmented options, search | 12–16px | Capsule again (V2), approved colours |
| "Verified" / "New here" photo badges, "Your move", "New" | 8px | Capsule again (V2) |
| Tab bar and its active item | 24px / 16px | Capsule again (V2) |
| Discover Pass, SuperSwipe, Like and the star | 28px (restored in V4) | Unchanged, pinned by a test |
| Discover fade (real photos only) | 4 stops over 60% of the photo | 9 stops on a smooth ease over 60% of the photo; black; above the photo, below the text and SuperSwipe; clipped to the corners |
| Placeholder card | Solid band | Unchanged: solid band, no gradient |
| Match: their photo | A rounded square inside a butter medallion | Fills the scallop and is clipped by it (the component's own SVG-path mask) |
| Match: your photo | A circle | A rounded square (16px; 12px on short phones), on the scallop's lower-left edge, scaled with it on short phones |
| Match: heart, halo, confetti | Purple heart shown | Heart hidden; its 96px slot kept empty for the hand illustrations; no halo, no confetti |

Tokens: `color.tiimo.pill-fill` (neutral 100), `pill-selected-fill` (purple 150),
`pill-selected-outline` (purple 600) and `pill-selected-ink` (purple 800). V4's `pill-outline`
was removed. `tiimo.radius-pill` (12px) is used only by the pills.

## Screenshots

### `final/`: 20 V5 states

All are 393 × 852 unless the name says otherwise.

| File | What it shows |
|---|---|
| `013-basics-393x852.png` | Basics: fields, option cards, Continue |
| `016-interests-prompt-393x852.png` | Interests: selected and unselected pills |
| `017-interests-max-393x852.png` | Interests: five chosen, the rest locked |
| `144-qa-interests-375x667.png` | Interests at 375 × 667 |
| `019-discover-393x852.png` | Discover card: placeholder band, star, tab bar |
| `020-discover-fullpage-393w.png` | Discover: the full profile scroll, Pass/SuperSwipe/Like |
| `021-discover-you-both-like-393x852.png` | Discover: shared-interest pills |
| `145-qa-discover-375x667.png` | Discover at 375 × 667 |
| `030-match-393x852.png` | Match: scalloped photo, your rounded photo, no heart |
| `032-match-typing-393x852.png` | Match: first message typed |
| `146-qa-match-375x667.png` | Match at 375 × 667 |
| `054-likes-393x852.png` | Likes: filters, "New" badges |
| `059-like-profile-393x852.png` | Like back: shared tag, Pass and Like back |
| `034-chats-393x852.png` | Messages: search, filters, counters, rows |
| `147-qa-chats-375x667.png` | Messages at 375 × 667 |
| `038-chat-conversation-393x852.png` | Conversation: bubbles and composer |
| `042-chat-new-match-393x852.png` | Conversation: new match openers |
| `148-qa-chat-long-messages-375x667.png` | Conversation at 375 × 667 |
| `061-activity-393x852.png` | Activity: emoji category pills, category tag |
| `153-qa-activity-375x667.png` | Activity at 375 × 667 |

### `comparisons/`: V4 against V5

- [pills-only-v4-v5.png](comparisons/pills-only-v4-v5.png): just the chips and tags, cropped.
- [discover-photo-fade-bright-fixture-v4-v5.png](comparisons/discover-photo-fade-bright-fixture-v4-v5.png)
- [match-photo-fixture-v4-v5.png](comparisons/match-photo-fixture-v4-v5.png)
- Full screens:
  - [Interests](comparisons/016-interests-prompt.png)
  - [Interests at the limit](comparisons/017-interests-max.png)
  - [Discover](comparisons/019-discover.png)
  - [Match](comparisons/030-match.png)
  - [Match at 375](comparisons/146-qa-match.png)
  - [Like back](comparisons/059-like-profile.png)
  - [Likes](comparisons/054-likes.png)
  - [Messages](comparisons/034-chats.png)
  - [Activity](comparisons/061-activity.png)

### `qa/`: test fixtures

The repo has no profile photography. These captures put **canvas-drawn test patterns, not
photographs** into the photo slots:

- [discover-photo-fade-bright-fixture-393x852.png](qa/discover-photo-fade-bright-fixture-393x852.png)
  and [discover-photo-fade-dark-fixture-393x852.png](qa/discover-photo-fade-dark-fixture-393x852.png):
  the fade over a bright and a dark image.
- [discover-placeholder-solid-band-393x852.png](qa/discover-placeholder-solid-band-393x852.png):
  no photo, so no gradient, and the solid band.
- [match-scallop-photo-fixture-393x852.png](qa/match-scallop-photo-fixture-393x852.png)
  and [375x667](qa/match-scallop-photo-fixture-375x667.png): their photo clipped by the scallop,
  and your rounded-square photo.

## Validation

| Check | Result |
|---|---|
| Token freshness / icons | pass (311 tokens) / pass |
| Unit tests (Vitest) | **117 / 117** |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **50 / 50** |
| Accessibility (axe, 10 views including the themed Welcome and flows) | **0 serious or critical** |
| Default mode without the flag, 20 states | byte-identical to the approved design's committed gallery |
| Shape audit: every component's computed radius on nine screens, V5 against V2 | only the intended changes differ: emoji pills, Activity's "All", shared tags, the activity tag, your photo on Match |

**New regression tests:**
- **Shapes:** 23 component shapes are pinned to V2 on nine screens: buttons, the Discover actions,
  icon buttons, the FAB, count and status badges, photo badges, the tab bar and its items, search,
  the composer, inputs, segmented options, non-emoji filters, avatars, the match previews, photos
  and bubbles.
- **Pills:**
  - all are 12px;
  - unselected are `#F2F2F2` with no border or outline;
  - selected are `#E9E4FB` with a 1px `#7262C7` outline;
  - no pill has a gradient;
  - text is at least 4.5:1.
- **Discover fade:**
  - The rendered fade is read from screenshot pixels over a white test image. It starts 42% down,
    darkens steadily with at most a 1-level step per row (no band edge), and reaches 147/255 just
    above the badges.
  - It sits above the photo and below the text.
  - Name and detail contrast is computed over pure white.
  - Placeholders take no gradient.
- **Match:**
  - their photo fills, and is clipped by, the scallop mask;
  - your photo is a rounded square (16px), lower-left, clear of their centre;
  - the heart is not visible and its slot remains;
  - no halo, no confetti.

**Negative control:** run against the V4 code, the same test file fails 7 checks. They fail on the
selected pill, the squared shapes, the match photo, your circular photo, the heart, and the
unselected and selected pills, which shows that the tests catch these defects.

## Remaining limitations

- **No real profile photos.** The fade and the scallop crop were checked on test patterns. The
  first real photos need a look, especially faces near the lower part of the frame.
- **Mobbin access.** Only preview images were available; full-size images were blocked by the
  network proxy, so measurements are estimates.
- **The hand illustrations do not exist yet.** The match slot is intentionally empty (96px at 393
  wide), which leaves a quiet gap above the composer until the artwork arrives.
- **Locked pills use the approved muted text**, which is below 3:1 on the grey. They are inactive
  (`aria-disabled`), which contrast minimums exempt, and "5/5 selected" states the limit in full
  contrast.
- Only Chromium was tested, and emoji glyphs differ by platform.

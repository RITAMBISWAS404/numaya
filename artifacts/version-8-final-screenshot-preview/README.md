# Numaya V8: restrained colour, tighter geometry, fewer containers

**Start here:** [contact-sheet.png](contact-sheet.png). The rules are in
[design-system.md](design-system.md).

V8 refines V7 at the component level. Layout, typography, copy and behaviour are unchanged.

- **No lavender surfaces.**
  - Your prompt is a white, outlined module.
  - Their prompt and the info notes sit directly on the canvas.
  - The selected row is white with the brand ring.
  - The active tab is a neutral fill behind the purple icon.

  Purple is now only a solid fill or a mark on actions and selected states.
- **A tighter radius scale chosen by size:** tag 6, pill 10, control and item 12, feature 16, photo 20.
  - Utility circles become rounded squares: back, close and filter buttons, the FAB, send, and the
    photo add/remove controls.
  - Avatars, radios, numeric badges, the tab bar and the Discover actions keep their shapes.
- **Fewer containers.**
  - Someone's profile sections are direct content between their photos.
  - Inbox rows are a list with inset dividers.
  - Cards are outlined.
  - Only activity cards stay raised.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v8` |
| Starting commit | `8b85175`, the head of `experiment/tiimo-inspired-v7`, fetched and verified |
| Implementation commits | `3584b23` (colour, radius scale, containers, tests); `057ad66` (concentric corner for the activity-card photo) |
| Final commit | the commit that adds this folder (see the branch head) |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

Open `http://localhost:5173/flows.html?screen=interests&theme=tiimo`. To see other screens, replace
`interests` with one of these:

| Area | Screens |
|---|---|
| Onboarding | `basics`, `photos` |
| Discover and matching | `discovery`, `like-profile`, `likes`, `match` |
| Messaging | `chats`, `chat` |
| Profile and settings | `prompt`, `profile`, `edit`, `settings` |
| Activity | `activity` |

Welcome is at `http://localhost:5173/?theme=tiimo`. The match screen shows a match after you like
Maya on Discover. Without `theme=tiimo` you get the approved design.

## Screenshots

### `final/`: 30 V8 states

All are 393 × 852 unless the name says otherwise.

| Area | Screens |
|---|---|
| Onboarding | [Welcome](final/001-welcome-393x852.png), [Basics](final/013-basics-393x852.png), [Interests](final/016-interests-prompt-393x852.png), [Interests at the limit](final/017-interests-max-393x852.png), [Add photos](final/018-photos-393x852.png) |
| Discover | [Discover](final/019-discover-393x852.png), [Discover, full profile](final/020-discover-fullpage-393w.png), [You both like](final/021-discover-you-both-like-393x852.png), [Discover filters](final/023-discover-filters-sheet-393x852.png) |
| Matching | [Match](final/030-match-393x852.png), [Match, typing](final/032-match-typing-393x852.png), [Likes](final/054-likes-393x852.png), [Like back](final/059-like-profile-393x852.png) |
| Messaging | [Messages](final/034-chats-393x852.png), [Conversation](final/038-chat-conversation-393x852.png), [New match chat](final/042-chat-new-match-393x852.png), [Unmatch sheet](final/045-chat-unmatch-sheet-393x852.png) |
| Activity | [Activity](final/061-activity-393x852.png), [Activity filters](final/064-activity-filters-sheet-393x852.png) |
| Profile and settings | [Profile](final/099-profile-393x852.png), [Edit profile](final/102-edit-profile-393x852.png), [Your prompt](final/108-prompt-editor-393x852.png), [Settings](final/111-settings-393x852.png) |
| 375 × 667 | [Interests](final/144-qa-interests-375x667.png), [Discover](final/145-qa-discover-375x667.png), [Match](final/146-qa-match-375x667.png), [Messages](final/147-qa-chats-375x667.png), [Long messages](final/148-qa-chat-long-messages-375x667.png), [Settings](final/149-qa-settings-375x667.png), [Activity](final/153-qa-activity-375x667.png) |

### `comparisons/`: V7 against V8

**Essential:**
- [surfaces-and-containers-v7-v8.png](comparisons/surfaces-and-containers-v7-v8.png): cropped
  details of every lavender, container and shape change:
  - prompt and readiness;
  - the Like back note;
  - Discover sections;
  - inbox rows;
  - the selected row;
  - the Add photos tip and controls;
  - the active tab.
- [pills-only-v7-v8.png](comparisons/pills-only-v7-v8.png): the pills, cropped. The colour is
  unchanged and the corner goes from 12px to 10px.

**Full screens:**

| Area | Comparisons |
|---|---|
| Onboarding | [Basics](comparisons/013-basics.png), [Interests](comparisons/016-interests-prompt.png), [Add photos](comparisons/018-photos.png) |
| Discover | [Discover](comparisons/019-discover.png), [You both like](comparisons/021-discover-you-both-like.png), [Discover filters](comparisons/023-discover-filters-sheet.png) |
| Matching | [Match](comparisons/030-match.png), [Likes](comparisons/054-likes.png), [Like back](comparisons/059-like-profile.png) |
| Messaging | [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png), [Unmatch sheet](comparisons/045-chat-unmatch-sheet.png) |
| Activity | [Activity](comparisons/061-activity.png) |
| Profile and settings | [Profile](comparisons/099-profile.png), [Edit profile](comparisons/102-edit-profile.png), [Your prompt](comparisons/108-prompt-editor.png), [Settings](comparisons/111-settings.png) |

### `qa/`

| File | What it checks |
|---|---|
| [radius-audit-v7-v8.txt](qa/radius-audit-v7-v8.txt) | Computed radius of each component on nine screens, V7 and V8; unchanged rows are marked |
| [container-audit-v7-v8.txt](qa/container-audit-v7-v8.txt) | Every element with a fill, shadow or border on the 14 flow screens, V7 and V8 |
| [purple-usage.txt](qa/purple-usage.txt) | Every purple fill, outline, text and icon per screen, and the difference from V7 |
| [contrast-audit.txt](qa/contrast-audit.txt) | 310 text elements on 15 themed screens against the actual colour behind each one: 0 below AA |
| [default-mode-unchanged.txt](qa/default-mode-unchanged.txt) | Without the flag, 162 of 162 gallery states are byte-identical to the approved design (`944c532`) |
| [responsive-375.png](qa/responsive-375.png) | The 375 × 667 states on one sheet |
| [fade bright](qa/discover-photo-fade-bright-fixture-393x852.png), [fade dark](qa/discover-photo-fade-dark-fixture-393x852.png), [placeholder band](qa/discover-placeholder-solid-band-393x852.png) | The Discover photo fade and the solid band for a missing photo, unchanged |
| [match 393](qa/match-scallop-photo-fixture-393x852.png), [match 375](qa/match-scallop-photo-fixture-375x667.png) | The scallop-clipped photo with your rounded-square photo on its lower left; no heart, halo or confetti |

The photo captures use **canvas-drawn test patterns, not photographs**. The repo has no profile
photography.

## Validation

Run on `057ad66`:

| Check | Result |
|---|---|
| Tokens / icons | pass (331 tokens, generated files up to date) / pass |
| Unit tests (Vitest) | **117 / 117** |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **67 / 67** |
| Accessibility (axe, 10 views) | **0 serious or critical** |
| Default mode, 162 states | byte-identical to the approved design's committed gallery |

The same experiment suite **fails 11 checks against V7's code**, so the new checks do detect the V7
styling.

New and updated experiment checks:

- **No lavender surface** on any of the 15 themed screens or the match. Only identity colours are
  exempt: avatars and category holders.
- **Direct content:**
  - someone's profile sections, info notes and inbox rows have no fill, shadow or border;
  - inbox rows are separated by a 1px divider that starts after the avatar column.
- **Outlined and recessed:**
  - your prompt is white with a 1px outline;
  - cards, groups and selection rows are outlined, not shadowed;
  - only activity cards and floating or primary controls cast a shadow.
- **States:**
  - the selected row is white with the 2px brand ring;
  - the active tab is a neutral fill with the brand icon;
  - selected pills are solid `#7262C7` with white text;
  - unselected pills are `#EDEBE5` on the canvas and `#F1F0EA` inside white.
- **Shapes:**
  - 34 components are pinned to the V8 scale and to the shapes kept on purpose (Discover actions,
    tab bar, avatars, radios, numeric badges, your match photo);
  - without the flag, the approved shapes are checked.
- **Unchanged:**
  - the rendered Discover fade (pixel test);
  - the scallop clip;
  - your photo's position;
  - no heart;
  - contrast, overflow at 393 and 375, and the console.

## Remaining limitations

- **Avatar fallbacks keep their identity tones** (pink, periwinkle, butter). Your own "A" on Profile and
  Match is the periwinkle tone. It is an initial placeholder that a photo replaces, not a surface, so
  I did not change it. If the team wants neutral placeholders, that is a one-line change.
- **Category pastels stay**, including lilac, on the 24px emoji holders and the Welcome stickers. They
  code categories rather than acting as surfaces.
- **No real photography.** The fade and scallop are checked with test patterns.
- **Inset `#F8F7F3`** is defined but not used. It sits too close to the canvas to read as a step; the
  recessed fills are `#EDEBE5` and `#F1F0EA`.
- **Scope.** Insights, activity detail, blocked, premium and help are outside the experiment, as before.
- **Browsers.** Only Chromium was tested.

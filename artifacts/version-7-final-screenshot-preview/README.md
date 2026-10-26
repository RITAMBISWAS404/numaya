# Numaya V7: product design system and visual refinement

**Start here:** [contact-sheet.png](contact-sheet.png). The system itself is in
[design-system.md](design-system.md).

V7 builds on V6. I defined the visual system first, then brought every themed screen into line with
it:

- **A lighter canvas:** `#F6F5F1` instead of the beige `#F1F0EA`, chosen from a side-by-side
  study.
- **Five surface levels:** the canvas, raised cards, recessed inputs, outlined groups and floating
  controls. Each has a single rule for shadow, border and fill.
- **Neutral unselected pills and solid brand-purple selected pills.**
- **Restrained purple and button roles:** primary purple, secondary outlined white, tertiary quiet,
  destructive unchanged.
- **Profile, Edit profile and Settings now join the theme.** They were outside it in V6.

Shapes, the Discover photo fade, the placeholder band, the action buttons and the Match composition
are unchanged from V5 and V6.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v7` |
| Starting commit | `fcca9d7`, the head of `experiment/tiimo-inspired-v6`, fetched and verified |
| Implementation commit | `ef3cfbc` |
| Final commit | the commit that adds this folder (see the branch head) |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

Open `http://localhost:5173/flows.html?screen=interests&theme=tiimo`. Replace `interests` with
any of:

- onboarding and setup: `basics`, `photos`, `prompt`;
- Discover and matching: `discovery`, `like-profile`, `likes`, `match`;
- messaging: `chats`, `chat`;
- the rest: `activity`, `profile`, `edit`, `settings`.

The welcome screen is at `http://localhost:5173/?theme=tiimo`. Without `theme=tiimo` you get the
approved design.

## What changed, by component

| | V6 | V7 |
|---|---|---|
| Canvas | `#F1F0EA` (beige) | **`#F6F5F1`**: [background study](qa/background-study.png) |
| Raised cards | Profile sections, activity cards, **and** option rows, conversation rows, filter groups, the composer, the secondary button | **Only** content cards (profile sections, activity cards, readiness). A restrained diffuse shadow, no border |
| Inputs | White on the canvas, the composer with a shadow | **Recessed** `#EDEBE5` (`#F1F0EA` inside white), no border, no shadow; focus is white with the brand ring |
| Groups and selection rows | White with a shadow | White with a 1px `#E6E3DD` outline, no shadow; selected rows use the 2px brand ring |
| Floating | Tab bar, floating buttons, action bar, FAB, sheets | Unchanged; the only strong shadow |
| Unselected pills | White on the canvas, `#F8F7F3` in cards | `#EDEBE5` on the canvas, `#F1F0EA` in cards: neutral, no border, tint or gradient |
| Selected pills | Lavender tint, purple outline and glyph | **Solid `#7262C7`**, white label and glyph, same size and radius |
| Secondary button | White with a shadow | White with a 1px outline |
| Conversation rows | White cards with a shadow | Rows on the canvas |
| Profile / Edit / Settings | Approved design (outside the theme) | Themed; profile interest pills get their emoji marks |

The [surface audit](qa/surface-audit-v6-v7.txt) lists every elevated element, white surface and
input treatment per screen for V6 and V7.

## Screenshots

### `final/`: 29 V7 states

All are 393 × 852 unless the name says otherwise.

| Area | Screens |
|---|---|
| Onboarding and setup | [Basics](final/013-basics-393x852.png), [Interests](final/016-interests-prompt-393x852.png), [Interests at the limit](final/017-interests-max-393x852.png), [Add photos](final/018-photos-393x852.png) |
| Discover | [Discover](final/019-discover-393x852.png), [Discover, full scroll](final/020-discover-fullpage-393w.png), [You both like](final/021-discover-you-both-like-393x852.png), [Discover filters](final/023-discover-filters-sheet-393x852.png) |
| Matching | [Match](final/030-match-393x852.png), [Match, typing](final/032-match-typing-393x852.png), [Likes](final/054-likes-393x852.png), [Like back](final/059-like-profile-393x852.png) |
| Messaging | [Messages](final/034-chats-393x852.png), [Conversation](final/038-chat-conversation-393x852.png), [New match chat](final/042-chat-new-match-393x852.png), [Unmatch sheet](final/045-chat-unmatch-sheet-393x852.png) |
| Activity | [Activity](final/061-activity-393x852.png), [Activity filters](final/064-activity-filters-sheet-393x852.png) |
| Profile and settings | [Profile](final/099-profile-393x852.png), [Edit profile](final/102-edit-profile-393x852.png), [Your prompt](final/108-prompt-editor-393x852.png), [Settings](final/111-settings-393x852.png) |
| 375 × 667 | [Interests](final/144-qa-interests-375x667.png), [Discover](final/145-qa-discover-375x667.png), [Match](final/146-qa-match-375x667.png), [Messages](final/147-qa-chats-375x667.png), [Long messages](final/148-qa-chat-long-messages-375x667.png), [Settings](final/149-qa-settings-375x667.png), [Activity](final/153-qa-activity-375x667.png) |

### `comparisons/`: V6 against V7

- [pills-only-v6-v7.png](comparisons/pills-only-v6-v7.png): just the pills, cropped. The filter
  pills on Messages and Likes have no emoji, so they are intentionally unchanged.
- **Full screens:**
  - [Basics](comparisons/013-basics.png), [Interests](comparisons/016-interests-prompt.png),
    [Add photos](comparisons/018-photos.png)
  - [Discover](comparisons/019-discover.png), [You both like](comparisons/021-discover-you-both-like.png),
    [Discover filters](comparisons/023-discover-filters-sheet.png)
  - [Match](comparisons/030-match.png), [Likes](comparisons/054-likes.png),
    [Like back](comparisons/059-like-profile.png)
  - [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png)
  - [Activity](comparisons/061-activity.png), [Your prompt](comparisons/108-prompt-editor.png)
  - [Profile](comparisons/099-profile.png), [Edit profile](comparisons/102-edit-profile.png),
    [Settings](comparisons/111-settings.png): the V6 side is the approved design, because these
    screens were not themed in V6.

### `qa/`

| File | What it checks |
|---|---|
| [background-study.png](qa/background-study.png) | Four candidate canvases on Likes, Discover filters, Your prompt and Basics |
| [surface-audit-v6-v7.txt](qa/surface-audit-v6-v7.txt) | Elevated elements, white surfaces and input fills per screen, V6 then V7 |
| [contrast-audit.txt](qa/contrast-audit.txt) | 310 text elements on 15 themed screens against the actual solid colour behind each one: 0 below AA |
| [purple-usage.txt](qa/purple-usage.txt) | Every purple fill, outline, text and icon per screen, and the difference from V6 |
| [shape-audit.txt](qa/shape-audit.txt) | The computed radius of every component; identical to V6 |
| [responsive-375.png](qa/responsive-375.png) | The 375 × 667 states on one sheet |
| [discover-photo-fade-bright-fixture-393x852.png](qa/discover-photo-fade-bright-fixture-393x852.png), [dark](qa/discover-photo-fade-dark-fixture-393x852.png) | The V5 photo fade, unchanged |
| [discover-placeholder-solid-band-393x852.png](qa/discover-placeholder-solid-band-393x852.png) | No photo: the solid band, no gradient |
| [match-scallop-photo-fixture-393x852.png](qa/match-scallop-photo-fixture-393x852.png), [375x667](qa/match-scallop-photo-fixture-375x667.png) | Their photo clipped by the scallop, with your rounded-square photo on its lower left; no heart |

The photo captures use **canvas-drawn test patterns, not photographs**. The repo has no profile
photography.

## Validation

| Check | Result |
|---|---|
| Tokens / icons | pass (330 tokens, generated files up to date) / pass |
| Unit tests (Vitest) | **117 / 117** |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **60 / 60** (the same suite fails 13 checks against V6's code) |
| Accessibility (axe) | **0 serious or critical** |
| Default mode without the flag, 33 states | byte-identical to the approved references |

New and updated experiment checks:

- **Tokens:**
  - the canvas is `#F6F5F1`;
  - the canvas, card, recessed and border roles are four distinct values;
  - the theme's page colour resolves to the canvas.
- **Recessed inputs:** fields on Basics and Edit, search on Messages, the composer and the prompt
  answer are `#EDEBE5`, with no visible shadow and a 0px border.
- **Elevation allowlist:** on all 15 themed screens, only cards, floating controls, sheets,
  primary buttons and the match avatars may have an outer shadow. Not every card-like surface is
  elevated.
- **Outlined groups:** setting and filter groups and unselected option rows have exactly a 1px
  `#E6E3DD` inset outline.
- **Pills:**
  - unselected pills are `#EDEBE5` on the canvas and `#F1F0EA` in cards, with no border or
    tint;
  - selected pills are solid `#7262C7`, with no ring, a white label and a white glyph.
- **Scope:** Profile, Edit and Settings are now themed. Insights, activity detail, blocked,
  premium and help stay outside the theme.
- **Unchanged from V5 and V6:**
  - the pinned component shapes;
  - the rendered Discover fade;
  - the scallop clip, your rounded photo and the absent heart;
  - rendered contrast.

## Remaining limitations

- **No real photography.** The fade and the scallop are checked with test patterns. With a very
  light photo, the scallop's contour softens against the canvas, so real photos need a look.
- **Mobbin research is from preview images.** Full-size downloads are blocked from this
  environment. Only the screens linked in [design-system.md](design-system.md) were opened.
- **Two derived values:**
  - `#6B6771` keeps secondary text at AA on the canvas;
  - `#EDEBE5` is the recessed fill, the canvas darkened along its own hue.

  Neither is in the supplied palette.
- **The recessed fill is warm.** This supersedes V2's "no warm fill" rule, following the warm
  palette direction from V6.
- **Brand purple link text on the canvas** uses the deep brand purple, because `#7262C7` is 4.49:1
  there.
- **Scope.** Insights, activity detail, blocked, premium and help remain outside the experiment,
  as before.
- **Browsers.** Only Chromium was tested.

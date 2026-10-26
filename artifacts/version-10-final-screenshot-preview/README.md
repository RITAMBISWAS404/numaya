# Numaya V10: balanced geometry, traditional tab bar

**Start here:** [contact-sheet.png](contact-sheet.png). The rules are in
[design-system.md](design-system.md).

V10 is a precision pass on V9. Its monochrome palette, surfaces, typography, layouts, copy and
behaviour are unchanged. V10 changes four things:

1. **Balanced geometry.**
   - Full pills for compact actions and toggles:
     - Likes and Messages filter tabs, and segmented options;
     - small buttons;
     - Pass, Like and SuperSwipe;
     - the unread count and progress segments;
     - switch and slider handles.
   - Generously rounded rectangles for structured controls and surfaces:
     - tags 8;
     - chips, fields, rows and icon buttons 12;
     - buttons 14;
     - cards and tiles 16;
     - photographs and sheets 20.
   - **Radios are circles again; checkboxes stay squares.**
   - Switches have a 34 × 26 pill handle on a 58 × 32 track.
   - Slider handles are 20 × 28 pills.
   - Avatars stay rounded squares, at a quarter of their size.
   - Nested corners follow *inner ≈ outer − inset*.
2. **A traditional bottom tab bar.**
   - Full width, square-cornered, a 1px top divider and no shadow.
   - The home-indicator inset is padded.
   - The active tab is the purple icon with no background behind it.
   - The icons keep the approved 24px size.
3. **Red dots** replace the numbers in the tab bar. The counts stay in the accessible names, and
   numbers stay wherever they carry meaning.
4. **A larger Match portrait** (about 12%), with a softer eight-lobe scallop and your photo as a
   16px rounded square on its lower-left edge.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v10` |
| Starting commit | `b56508b`, the head of `experiment/tiimo-inspired-v9`, fetched and verified |
| Implementation commit | `bd58a31` |
| Final commit | the commit that adds this folder (see the branch head) |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

Open `http://localhost:5173/flows.html?screen=discovery&theme=tiimo`. To see other screens, replace
`discovery` with one of these:

| Area | Screens |
|---|---|
| Discover and matching | `like-profile`, `likes`, `match` |
| Messaging | `chats`, `chat` |
| Profile and settings | `profile`, `edit`, `prompt`, `settings` |
| Activity | `activity` |
| Onboarding | `photos`, `interests`, `basics` |

Welcome is at `http://localhost:5173/?theme=tiimo`. The match shows after you like Maya on
Discover. Without `theme=tiimo` you get the approved design.

## Screenshots

### `final/`: 30 V10 states

All are 393 × 852 unless the name says otherwise.

| Area | Screens |
|---|---|
| Discover | [Discover](final/019-discover-393x852.png), [Discover profile, full scroll](final/020-discover-fullpage-393w.png), [You both like](final/021-discover-you-both-like-393x852.png), [Discover filters](final/023-discover-filters-sheet-393x852.png) |
| Matching | [Likes](final/054-likes-393x852.png), [Like back](final/059-like-profile-393x852.png), [Match](final/030-match-393x852.png), [Match, typing](final/032-match-typing-393x852.png) |
| Messaging | [Messages](final/034-chats-393x852.png), [Conversation](final/038-chat-conversation-393x852.png), [New match chat](final/042-chat-new-match-393x852.png), [Unmatch sheet](final/045-chat-unmatch-sheet-393x852.png) |
| Profile and settings | [Profile](final/099-profile-393x852.png), [Edit profile](final/102-edit-profile-393x852.png), [Your prompt](final/108-prompt-editor-393x852.png), [Settings](final/111-settings-393x852.png) |
| Activity | [Activity](final/061-activity-393x852.png), [Activity filters](final/064-activity-filters-sheet-393x852.png) |
| Onboarding | [Welcome](final/001-welcome-393x852.png), [Basics](final/013-basics-393x852.png), [Interests](final/016-interests-prompt-393x852.png), [Interests at the limit](final/017-interests-max-393x852.png), [Add photos](final/018-photos-393x852.png) |
| 375 × 667 | [Interests](final/144-qa-interests-375x667.png), [Discover](final/145-qa-discover-375x667.png), [Match](final/146-qa-match-375x667.png), [Messages](final/147-qa-chats-375x667.png), [Long messages](final/148-qa-chat-long-messages-375x667.png), [Settings](final/149-qa-settings-375x667.png), [Activity](final/153-qa-activity-375x667.png) |

### `comparisons/`: V9 against V10

**Essential:**
- [geometry-details-v9-v10.png](comparisons/geometry-details-v9-v10.png): cropped details of:
  - switches and sliders;
  - radios and checkboxes;
  - filter tabs and Likes tiles;
  - Messages rows and avatars;
  - the Profile avatar and small buttons;
  - photo slots and their badges;
  - the Discover photo and SuperSwipe;
  - Activity.
- [navigation-v9-v10.png](comparisons/navigation-v9-v10.png): the tab bar on four screens.
- [match-v9-v10.png](comparisons/match-v9-v10.png): the Match at 393 and 375 px.

**Full screens:**

| Area | Comparisons |
|---|---|
| Discover | [Discover](comparisons/019-discover.png), [Discover filters](comparisons/023-discover-filters-sheet.png) |
| Matching | [Likes](comparisons/054-likes.png), [Like back](comparisons/059-like-profile.png), [Match](comparisons/030-match.png), [Match 375](comparisons/146-qa-match.png) |
| Messaging | [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png) |
| Profile and settings | [Profile](comparisons/099-profile.png), [Edit profile](comparisons/102-edit-profile.png), [Your prompt](comparisons/108-prompt-editor.png), [Settings](comparisons/111-settings.png) |
| Activity | [Activity](comparisons/061-activity.png) |
| Onboarding | [Basics](comparisons/013-basics.png), [Interests](comparisons/016-interests-prompt.png), [Add photos](comparisons/018-photos.png) |

### `qa/`

| File | What it shows |
|---|---|
| [navigation-375-and-393.png](qa/navigation-375-and-393.png) | The tab bar at both sizes, the safe-area inset, content ending at the divider, and a zoom on a notification dot |
| [match-composition.png](qa/match-composition.png) | The Match with and without synthetic photos, at 393 and 375 px |
| [match fixture 393](qa/match-scallop-photo-fixture-393x852.png), [match fixture 375](qa/match-scallop-photo-fixture-375x667.png) | The scallop-clipped photo and your rounded-square photo |
| [nested-corners-v9-v10.txt](qa/nested-corners-v9-v10.txt) | Every rounded element near a rounded parent's corner: outer radius, inset, inner radius, concentric target (V9 and V10) |
| [radius-audit-v9-v10.txt](qa/radius-audit-v9-v10.txt) | Each component's computed radius on nine screens, V9 and V10 |
| [responsive-375.png](qa/responsive-375.png) | The 375 × 667 states |
| [contrast-audit.txt](qa/contrast-audit.txt) | 300 text elements on 15 themed screens: 0 below AA |
| [accessibility-axe.txt](qa/accessibility-axe.txt) | The axe run: 0 serious or critical issues |
| [default-mode-unchanged.txt](qa/default-mode-unchanged.txt) | Without the flag, 162 of 162 gallery states are byte-identical to the approved design |
| [Fade, bright photo](qa/discover-photo-fade-bright-fixture-393x852.png), [dark photo](qa/discover-photo-fade-dark-fixture-393x852.png), [close-up](qa/discover-photo-fade-bright-closeup.png), [fade only](qa/discover-photo-fade-bright-closeup-fade-only.png), [dark close-up](qa/discover-photo-fade-dark-closeup.png), [placeholder band](qa/discover-placeholder-solid-band-393x852.png), [profile data](qa/discover-fade-profile.json) | The V9 photo fade and placeholder band, unchanged |

The photo captures use **synthetic fixtures, not photographs**. The repo has no profile
photography.

## Validation

All checks were run on `bd58a31`.

| Check | Result |
|---|---|
| Tokens / icons | pass (319 tokens, generated files up to date) / pass |
| Unit tests (Vitest) | **117 / 117** |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **88 / 88** |
| Accessibility (axe, 10 views) | **0 serious or critical** |
| Default mode, 162 states | byte-identical to the approved design's committed gallery |

The same experiment suite **fails 16 checks against V9's code**, so the V10 checks do detect the
V9 styling.

New and updated experiment checks:

- **Navigation**, at 393 × 852 and 375 × 667:
  - full width, square-cornered, at the bottom edge;
  - a 1px top divider and no shadow;
  - 56px plus the safe-area inset;
  - the content ends where the bar begins;
  - the approved 24px icons, and every item at least 44 × 44;
  - the active tab is a purple icon with no background, and inactive icons are grey;
  - labels and `aria-current` are unchanged.
- **Dots:**
  - every tab badge is an 8px red dot at the icon's upper right, with no number drawn;
  - the count stays in the badge label and the tab's name;
  - numbers stay in the filter counts and the unread count.
- **Shapes:**
  - radios are circles;
  - nothing else that is square and visible is circular;
  - switches are a 58 × 32 pill track with a 34 × 26 pill handle, purple when on;
  - slider handles are 20px pills on a pill rail;
  - nested corners follow *inner ≈ outer − inset* to within 2px;
  - 43 components are pinned to the V10 scale;
  - the approved shapes are checked without the flag.
- **Match:**
  - the portrait is 10–15% larger than the approved one;
  - its mask is a different SVG path (the soft scallop);
  - the clip, your photo's position, and the absence of a heart, halo and confetti are kept.
- **Unchanged from V9:**
  - the monochrome palette and surfaces;
  - the Discover header and fade;
  - filter tabs without checkmarks;
  - the status labels;
  - the readiness bar;
  - contrast, overflow and the console.

## Remaining limitations

- **No real photography.** The fade and the Match are checked with synthetic fixtures.
- **Navigation labels.** The tab bar stays icon-only, as in the approved design (labels are the
  accessible names). Adding visible labels would be a content change outside this brief.
- **The navigation reference screenshot** mentioned in the brief was not attached to this request.
  The bar follows the written specification.
- **The Match portrait is capped by width** on most phones (74vw), so it is 291px at 393px wide.
  The 296px cap applies only on wider screens.
- **Slider handle check.** The native slider thumb has no computed style, so the test reads the
  theme's WebKit thumb rule. Firefox's thumb rule is in the stylesheet but is not exercised by the
  Chromium-only suite.
- **Scope.** Insights, activity detail, blocked, premium and help remain outside the experiment.

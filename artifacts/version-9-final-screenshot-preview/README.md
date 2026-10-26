# Numaya V9: monochrome refinement

**Start here:** [contact-sheet.png](contact-sheet.png). Then read:
- [design-system.md](design-system.md): the palette, surfaces, geometry, navigation and labels.
- [mobbin-research.md](mobbin-research.md): the Bumble screens inspected and the decisions they
  informed.

V9 evolves V8 into a predominantly monochrome UI. Layout, typography, copy and behaviour are
unchanged.

- **Palette.** A pure white canvas, with neutral greys for hierarchy:
  - secondary `#F7F7F8`;
  - inset `#F0F0F2`;
  - border `#E4E4E7`.

  Purple `#7262C7` is the one accent. There are no warm neutrals, lavender or category pastels.
- **Surfaces.** Ordinary content sits directly on the canvas. Modules and groups are outlined.
  Information sits in flat grey containers, and fields are recessed. Only floating chrome has a
  shadow: the tab bar, the SuperSwipe on a photo, and sheets.
- **Geometry.** The scale is tag 6, pill 8, control 10, feature 12, photo 14, with **no circular
  UI**:
  - avatars, counts, radios, switch and slider thumbs, and icon buttons are rounded squares;
  - readiness is shown as a bar;
  - the match scallop is kept.
- **Navigation.** Compact: 56px instead of 64, a rounded rectangle, the same 24px icons, 72 × 48
  touch targets, one soft shadow.
- **Discover.** The bar under the logo is gone, and the photo fade is genuinely smooth and darker
  at the bottom (85%). Placeholders keep their solid band.
- **Filters and labels.**
  - Active Likes and Messages filter tabs have no checkmark.
  - Status labels share one shape in four semantic tones: neutral, emphasis, strong, alert.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v9` |
| Starting commit | `5cfd667`, the head of `experiment/tiimo-inspired-v8`, fetched and verified |
| Implementation commits | `1f5bddd` (palette, surfaces, geometry, navigation, header, fade, filters, labels, tests); `303ed51` ("Matched" is a neutral label) |
| Final commit | the commit that adds this folder (see the branch head) |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

Open `http://localhost:5173/flows.html?screen=discovery&theme=tiimo`, and replace `discovery` with
any of these screens:

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

### `final/`: 30 V9 states

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

### `comparisons/`: V8 against V9

**Essential:**
- [details-v8-v9.png](comparisons/details-v8-v9.png): cropped details of:
  - the Discover header;
  - Likes filters and labels;
  - Messages rows and avatars;
  - the conversation header;
  - the Profile avatar and readiness;
  - settings switches and sliders;
  - Basics radios;
  - the Match.
- [navigation-v8-v9.png](comparisons/navigation-v8-v9.png): the tab bar on four screens.
- [discover-photo-fade-v8-v9.png](comparisons/discover-photo-fade-v8-v9.png): the fade on bright
  and dark synthetic photos, plus the fade alone.

**Full screens:**

| Area | Comparisons |
|---|---|
| Discover | [Discover](comparisons/019-discover.png), [Discover profile](comparisons/020-discover-fullpage.png), [You both like](comparisons/021-discover-you-both-like.png), [Discover filters](comparisons/023-discover-filters-sheet.png) |
| Matching | [Likes](comparisons/054-likes.png), [Like back](comparisons/059-like-profile.png), [Match](comparisons/030-match.png) |
| Messaging | [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png), [Unmatch sheet](comparisons/045-chat-unmatch-sheet.png) |
| Profile and settings | [Profile](comparisons/099-profile.png), [Edit profile](comparisons/102-edit-profile.png), [Your prompt](comparisons/108-prompt-editor.png), [Settings](comparisons/111-settings.png) |
| Activity | [Activity](comparisons/061-activity.png) |
| Onboarding | [Basics](comparisons/013-basics.png), [Interests](comparisons/016-interests-prompt.png), [Add photos](comparisons/018-photos.png) |

### `qa/`

| File | What it shows |
|---|---|
| [discover-fade-profile.png](qa/discover-fade-profile.png) ([data](qa/discover-fade-profile.json)) | Measured darkening per row, V8 and V9: smooth, 79% just above the corners, no step above 0.9% |
| [Bright close-up](qa/discover-photo-fade-bright-closeup.png), [fade only](qa/discover-photo-fade-bright-closeup-fade-only.png), [dark close-up](qa/discover-photo-fade-dark-closeup.png) | The fade at 2× on the synthetic photos |
| [Bright, full screen](qa/discover-photo-fade-bright-fixture-393x852.png), [dark, full screen](qa/discover-photo-fade-dark-fixture-393x852.png), [placeholder band](qa/discover-placeholder-solid-band-393x852.png) | Discover with a photo, and the solid band without one (no gradient) |
| [match 393](qa/match-scallop-photo-fixture-393x852.png), [match 375](qa/match-scallop-photo-fixture-375x667.png) | The scallop-clipped photo with your rounded-square photo on its lower left |
| [geometry-audit-v8-v9.txt](qa/geometry-audit-v8-v9.txt) | Each component's radius in V8 and V9; circle and capsule counts (V8 17 and 22, V9 0 and 0) |
| [surface-audit-v8-v9.txt](qa/surface-audit-v8-v9.txt) | Every element with a fill, shadow or border on the 14 flow screens, V8 and V9 |
| [purple-usage.txt](qa/purple-usage.txt) | Every purple fill, outline, text and icon, and the difference from V8 |
| [contrast-audit.txt](qa/contrast-audit.txt) | 310 text elements on 15 themed screens: 0 below AA |
| [accessibility-axe.txt](qa/accessibility-axe.txt) | The axe run: 0 serious or critical issues |
| [responsive-375.png](qa/responsive-375.png) | The 375 × 667 states |
| [default-mode-unchanged.txt](qa/default-mode-unchanged.txt) | Without the flag, 162 of 162 gallery states are byte-identical to the approved design |

The photo captures use **synthetic fixtures, not photographs**. The repo has no profile
photography.

## Validation

All checks were run on `303ed51`.

| Check | Result |
|---|---|
| Tokens / icons | pass (316 tokens, generated files up to date) / pass |
| Unit tests (Vitest) | **117 / 117** |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **79 / 79** |
| Accessibility (axe, 10 views) | **0 serious or critical** |
| Default mode, 162 states | byte-identical to the approved design's committed gallery |

The same experiment suite **fails 29 checks against V8's code**, so the V9 checks do detect the
old styling.

New and updated experiment checks:

- **Palette.**
  - The canvas is `#FFFFFF`, and the tokens have their exact values.
  - The lavender roles resolve to the inset grey.
  - Every light background on every themed screen is a neutral grey: no beige, lavender or pastel.
- **Surfaces.**
  - Only floating chrome casts a blurred shadow.
  - Cards, activity cards, your prompt, groups and rows have exactly the 1px `#E4E4E7` outline.
  - Information containers are the flat `#F7F7F8`.
  - Profile sections and inbox rows are direct, and inbox dividers start after the avatar column.
- **Geometry.**
  - No circular UI element appears on the 15 screens or the match, pseudo-elements included.
  - 38 components are pinned to the V9 scale.
  - The approved shapes are checked without the flag.
- **Navigation.**
  - The bar is 56px (approved 64) and a rounded rectangle, with the approved 24px icons.
  - Every touch target is at least 44 × 44, and there is one shadow layer.
  - The active item is the inset grey behind the purple icon, with the same labels, `aria-current`
    and counts.
- **Header.** There is no bar under the Discover logo; onboarding progress is untouched.
- **Fade.**
  - The darkest stop is at least 80% black.
  - The rendered pixel column darkens steadily with no band.
  - It is clear in the upper 40%, layered under the text, and absent on placeholders.
- **Filters.**
  - The active Likes and Messages tabs are purple with no checkmark, still `aria-pressed`.
  - Inactive tabs are the inset grey.
  - Checkmarks remain on checkboxes and the Activity rail.
- **Labels.** "Your move" is neutral, "New" is emphasis, the unread count is solid purple, and
  tab counts are the approved red; all have a 6px corner.
- **Readiness.** It is a bar filled to the score, still a meter, with no ring around the avatar.
- **Unchanged:**
  - the match scallop clip;
  - your photo's position;
  - no heart;
  - scoping, interactions, navigation;
  - contrast, overflow at 393 and 375 px, and the console.

## Remaining limitations

- **No real photography.** The fade and the match are checked with synthetic per-pixel fixtures.
  Real photos should get a look before adoption.
- **Mobbin research uses preview images.** The Bumble match-moment screen was not returned by the
  search and is not referenced.
- **Radios are rounded squares.** This is because the brief removes circles. They stay distinct
  from checkboxes through a square inner mark versus a tick, but that convention departs from the
  platform's.
- **Two derived values:**
  - secondary text on grey (`#6B6771`);
  - muted (`#929099`), which is for disabled content only.
- **Not reshaped:** the Numaya wordmark (logo artwork) and illustrations.
- **Scope.** Insights, activity detail, blocked, premium and help remain outside the experiment.
- **Browsers.** Only Chromium was tested.

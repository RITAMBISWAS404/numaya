# Numaya V11: final product polish

**Start here:** [contact-sheet.png](contact-sheet.png). The decisions are in
[design-decisions.md](design-decisions.md); the profile research is in
[mobbin-research.md](mobbin-research.md).

V11 refines V10. Unchanged from V10:
- the monochrome palette, the white canvas and grey surfaces;
- purple `#7262C7`, the typography and the balanced geometry;
- the layouts, copy and behaviour.

What V11 changes:

1. **Tab bar with labels.**
   - Each tab is the 24px icon over a short 11px label: Home, Activity, Likes, Messages, Profile.
   - The active tab is purple and the others grey. There is no capsule.
   - Red dots now sit just outside the icon, clear of the glyph and the label.
2. **One light purple.** `#F1EFF9` is used only as the small holder of the new prompt mark. Pills,
   cards and headings stay as they were.
3. **Prompts.**
   - The decorative quotation mark is gone.
   - A 22px brand-purple speech-bubble mark sits before each prompt's question.
   - Up to three answered prompts share one outlined set with hairline dividers. Every profile holds
     one prompt today, so one is shown; nothing is invented.
4. **The Discover fade.**
   - On a real photo, a genuine black-to-clear ease: 92% at the bottom, clear by 55% of the photo,
     flat at both ends.
   - Placeholders keep their solid band.
5. **Settings dividers.** Inset 16px on both sides, so each spans exactly the content column. Before,
   they started at the text but ran into the right edge.
6. **Activity card spacing.** Title 8px above its category, 12px to the details, 6px between date
   and place.
7. **Slider handles.** White horizontal pills (30 × 22) like the switch handle (34 × 26). V10's were
   upright.
8. **Roomier small controls:**
   - header and sheet-close icon buttons 40px;
   - small buttons 44px;
   - status labels 26px;
   - the photo remove button 28px.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v11` |
| Starting commit | `f1001ef`, the head of `experiment/tiimo-inspired-v10`, fetched and verified |
| Implementation commit | `ff84175` |
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

Without `theme=tiimo` you get the approved design.

## Screenshots

### `final/`: 30 V11 states

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

### `comparisons/`: V10 against V11

**Essential:**
- [details-v10-v11.png](comparisons/details-v10-v11.png): cropped details of each change:
  - the prompt (Profile, Edit profile, Discover);
  - the Settings dividers and slider handles;
  - the Activity card;
  - the small controls.
- [navigation-v10-v11.png](comparisons/navigation-v10-v11.png): the tab bar on four screens.

**Full screens:**

| Area | Comparisons |
|---|---|
| Discover | [Discover](comparisons/019-discover.png), [Discover profile](comparisons/021-discover-you-both-like.png) |
| Matching | [Likes](comparisons/054-likes.png), [Like back](comparisons/059-like-profile.png), [Match](comparisons/030-match.png) |
| Messaging | [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png) |
| Profile and settings | [Profile](comparisons/099-profile.png), [Edit profile](comparisons/102-edit-profile.png), [Your prompt](comparisons/108-prompt-editor.png), [Settings](comparisons/111-settings.png) |
| Activity | [Activity](comparisons/061-activity.png) |
| Onboarding | [Basics](comparisons/013-basics.png), [Interests](comparisons/016-interests-prompt.png), [Add photos](comparisons/018-photos.png) |

### `qa/`

| File | What it shows |
|---|---|
| [navigation-375-and-393.png](qa/navigation-375-and-393.png) | The tab bar at both widths, with a zoom on a notification dot and its label |
| [discover-fade-v10-v11.png](qa/discover-fade-v10-v11.png) | V10 and V11 fades over the same bright and dark synthetic photos, with the measured opacity curves |
| [Fade, bright photo](qa/discover-photo-fade-bright-fixture-393x852.png), [dark photo](qa/discover-photo-fade-dark-fixture-393x852.png), [close-up](qa/discover-photo-fade-bright-closeup.png), [fade only](qa/discover-photo-fade-bright-closeup-fade-only.png), [dark close-up](qa/discover-photo-fade-dark-closeup.png), [placeholder band](qa/discover-placeholder-solid-band-393x852.png), [profile data](qa/discover-fade-profile.json) | The V11 fade at full size, and the placeholder's solid band |
| [settings-separators.png](qa/settings-separators.png) | V10 and V11 Notifications groups, with the divider and text edges marked |
| [slider-handles.png](qa/slider-handles.png) | V10 and V11 slider handles beside the switch handle, zoomed |
| [prompts-three-set-fixture-393x852.png](qa/prompts-three-set-fixture-393x852.png) | Profile with a test-only three-prompt fixture (prompt texts from `data.js`): one set, hairline dividers |
| [responsive-375.png](qa/responsive-375.png) | The 375 × 667 states |
| [contrast-audit.txt](qa/contrast-audit.txt) | Text contrast on 15 themed screens, tab labels included |
| [accessibility-axe.txt](qa/accessibility-axe.txt) | The axe run |
| [default-mode-unchanged.txt](qa/default-mode-unchanged.txt) | Without the flag, every gallery state against the approved design |

The photo captures use **synthetic fixtures, not photographs**. The repo has no profile
photography.

## Validation

All checks were run on `ff84175`.

| Check | Result |
|---|---|
| Tokens / icons | pass (325 tokens, generated files up to date) / pass |
| Unit tests (Vitest) | **119 / 119** (2 new, for `promptsOf`) |
| Production build | **pass** |
| Smoke e2e (approved contracts) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| Experiment e2e (`tests/e2e/experiment-tiimo.mjs`) | **111 / 111** (23 new, 4 updated) |
| Accessibility (axe, 10 views) | **0 serious or critical** |
| Contrast | 325 text elements on 15 themed screens, **0 below AA** |
| Default mode, 162 states | **162 / 162 byte-identical** to the approved design's committed gallery |

The same experiment suite **fails 18 checks against V10's code**, so the V11 checks do detect V10's
styling.

**New checks:**
- **Navigation**, at 393 and 375px:
  - each tab shows its label (Home, Activity, Likes, Messages, Profile) centred under the icon,
    inside the tab, unclipped, on one baseline;
  - the active tab is purple and the others grey, with no background;
  - the label is hidden from assistive tech, and names, `aria-current` and routing are unchanged;
  - without the flag the bar stays icon-only;
  - tapping each tab opens it.
- **Dots:**
  - each dot sits just outside the icon's corner, clear of the glyph and 8px or more above the label;
  - numbers stay in the filter counts and the unread count.
- **Purple:** the tint appears only on the 22px prompt mark.
- **Prompts:**
  - no decorative quotation mark on five screens;
  - the mark comes first in the question, centred, 22px, purple and decorative;
  - the question text is unchanged and the answer stays larger;
  - without the flag, the approved quote glyph is kept.
- **The prompt set:**
  - with a seeded fixture, up to three prompts in one outlined set with hairline dividers;
  - order is kept, and the unanswered entry and the fourth prompt are skipped;
  - only the first prompt can be edited, and its edit action still opens the editor;
  - with real data, exactly one prompt.
- **Settings:** dividers 16px from both edges and level with the text; toggles and row heights
  unchanged.
- **Activity:** the 8 / 12 / 6 / 12px rhythm, equal side padding, and meta icons centred on their
  first line.
- **Sliders:** 30 × 22 horizontal pill handles, smaller than the 34 × 26 switch handle. The keyboard
  still moves a slider, and a switch still toggles.
- **Sizes:** header and sheet-close buttons 40px, small buttons 44px, status labels 26px, the photo
  remove button 28px; meta icons stay 18px.
- **Fade:** 92% at the bottom, clear at 55%, an ease-in-out; placeholders keep the solid band and get
  no fade.

## Remaining limitations

- **No Couple screens.** Mobbin search returned none and the direct link could not be opened. The
  prompt decisions rest on the comparable dating-app screens that were retrieved
  ([mobbin-research.md](mobbin-research.md)).
- **One prompt per profile.**
  - The data model and every profile in the prototype hold one prompt, so screens show one.
  - The three-prompt set is exercised by a test-only fixture.
  - Only the first prompt can be edited, because the prompt editor edits that prompt. Editing more
    would need a product decision about the editor.
- **No real photography.** The fade is checked with synthetic fixtures.
- **Slider handle check.** The native slider thumb has no computed style, so the size check reads the
  theme's WebKit thumb rule. The Firefox rule is in the stylesheet but is not exercised by the
  Chromium-only suite.
- **The navigation reference screenshot** mentioned in the brief was not attached to this request.
  The bar follows the written specification.
- **Scope.** Insights, activity detail, blocked, premium and help remain outside the experiment.

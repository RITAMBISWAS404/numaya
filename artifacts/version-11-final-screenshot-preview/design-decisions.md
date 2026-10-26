# Numaya V11 design decisions

V11 is a polish pass on V10. These are unchanged:
- the white canvas and the grey surfaces (`#F7F7F8`, `#F0F0F2`, `#E4E4E7`);
- purple `#7262C7`, the typography and the layouts;
- the balanced radius scale, the scalloped Match photo, and the full-width tab bar.

See [V10's design-system.md](../version-10-final-screenshot-preview/design-system.md) for the full
system. Below is only what V11 decides.

**Where it lives:**
- tokens: `tokens/numaya.tokens.json`, then `npm run tokens`;
- theme: `src/design-system/styles/theme-tiimo.css`, scoped to `.theme-tiimo`, so it shows only with
  `?theme=tiimo`;
- components: `TabBar` (`Layout.jsx`), `PromptCard`, `PromptSet` and `ProfilePrompt` (`Content.jsx`);
- the prompt list: `promptsOf()` in `src/flows/model.js`.

**The approved design.** The new label and mark elements are hidden outside the theme
(`display: none`), so without the flag all 162 gallery states are byte-identical to the approved
design ([qa/default-mode-unchanged.txt](qa/default-mode-unchanged.txt)).

## 1. Bottom navigation: icon plus label

| | V10 | V11 |
|---|---|---|
| Structure | Full width, square, a 1px top divider, no shadow, home-indicator padding | Unchanged |
| Item | 24px icon only | **24px icon over an 11px label**, 3px apart, centred; 56px tall as before |
| Labels | Not shown (the accessible name only) | Home, Activity, Likes, Messages, Profile: the existing tab names |
| Active | Purple filled icon | **Purple filled icon and purple semibold label**; no background, capsule or pill |
| Inactive | Grey icon `#77737D` | **Grey icon and grey medium label** (`#77737D`, 4.63:1 on white) |
| Notification | 8px red dot, overlapping the icon's corner | **8px red dot just outside the icon's upper-right corner**, clear of the glyph and 8px or more above the label |

- **Accessibility.**
  - The visible label repeats the tab's accessible name, so it is `aria-hidden`; the name is
    unchanged ("Likes, 5 new").
  - The badge itself is `visibility: hidden` and the dot is its `::after`. Otherwise its hidden digit
    would count as visible text, and axe would flag the name for not containing it.
- **Unchanged:** destinations, order, routing, `aria-current`, and the 44px or larger touch targets.
- **Checked at 375 and 393px:** every label fits its tab on one line, and the labels share a
  baseline.

## 2. Purple, used on purpose

**One new token:** `--color-palette-brand-tint`, `#F1EFF9`. It is purple `#7262C7` mixed 10% into
white. Purple on it is 4.4:1.

| Use | Colour | Why |
|---|---|---|
| Primary actions, selection, the active tab, unread count, your messages | Solid brand purple (unchanged) | The important states |
| **Prompt mark** (22px holder before a prompt question) | Brand-purple icon on the tint | Marks a prompt as a conversation starter at a glance; small, so it never competes with the primary action |

Everything else stays neutral. Each candidate was put to the brief's four questions:

| Candidate | Decision | Reason |
|---|---|---|
| Information-card icons (blocking note, why they liked you) | Neutral ink | Grey says "information" as clearly; purple would compete with the primary action beside it |
| Activity meta icons (date, place) | Neutral grey | Purple on every row would be decoration, not meaning |
| Settings rows | Neutral | Forms carry no category |
| Headings | Neutral | Purple headings would add colour without meaning |
| Interest and category pills | Unchanged (grey, solid purple when selected) | Approved; the brief excludes them |

The tests check that the tint appears only on the prompt mark: 22 × 22px, on five screens.

## 3. Prompts

### The mark replaces the quotation mark

- **Removed:** the decorative closing quotation mark (`::after`) on your prompt (Profile, Edit
  profile, Interests). The theme already hid it on someone else's profile.
- **Added:** `[mark] A perfect first date`, with the answer below. The mark is:
  - a 22px holder with the 8px tag corner;
  - the existing `message` icon (Material Symbols "chat_bubble"), 14px, filled;
  - before the question, never the answer;
  - centred on the question's line, 8px from its text;
  - decorative (`aria-hidden`).
- **The same mark everywhere a prompt appears:** Profile, Edit profile, Interests (onboarding),
  Discover and Like back.
- **Unchanged:** the 14px question and the larger display-serif answer.
- **Edit chevron.** On your prompt it moves down 5px to centre on the question's line.

### Up to three prompts, as one set

The data model holds one `prompt` per profile.
- **`promptsOf(profile)`** returns the answered prompts to show:
  - from an optional `prompts` list when one exists, otherwise the one prompt;
  - unanswered entries are skipped, and at most three are kept.
- **No invented content.** Every profile in the prototype has one prompt, so every screen shows
  exactly one. Nothing is filled in.
- **Several prompts share one outlined module** (`PromptSet`), divided by 1px hairlines inset 20px
  to the text. This follows the list in the Lex screens rather than Coffee Meets Bagel's stack of
  cards ([mobbin-research.md](mobbin-research.md)).
  - The heading becomes "Your prompts" (Profile) or "Prompts" (Edit profile).
  - One prompt stays the single card, exactly as before.
- **Editing.** The prompt editor edits the first prompt, which is `prompt`, so only the first item
  has the edit chevron. Editing the others would need the editor to choose which prompt it edits. That
  is a product decision outside this brief.
- **Fixture.** [qa/prompts-three-set-fixture-393x852.png](qa/prompts-three-set-fixture-393x852.png)
  shows the set with a test-only fixture: three prompt texts from the repo's own `data.js`, seeded
  into the session.

## 4. The Discover photo fade

**What V10 did.** Black faded from 85% at the bottom edge to clear at 60%, on an ease that falls
fastest at the bottom. Over a bright photo the text sat on a band that read as a grey wash, not a
dark base.

**What V11 does.** Pure black, `opacity = 0.92 · cos²(πt/2)`, over the lower 55% of the photo,
sampled at eleven stops:

| Height above the bottom edge (% of the fade) | 0 | 10 | 20 | 30 | 40 | 50 | 60 | 70 | 80 | 90 | 100 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Black opacity (%) | 92 | 89.7 | 83.2 | 73 | 60.2 | 46 | 31.8 | 19 | 8.8 | 2.3 | 0 |

- **The curve is flat at both ends.** It holds near-black behind the name, so white text sits on dark.
  It is steepest mid-way and eases into fully transparent, so there is no band at the bottom and no
  start line at the top.
- **The upper 45% of the photo is untouched.**
- **Layering:** the fade sits above the photo and below the name, badges and SuperSwipe, and is
  clipped by the 20px photo corners.
- **Placeholders** keep their solid dark information band and get no fade.

Checked with synthetic bright and dark photo fixtures; see `qa/discover-photo-fade-*`.

## 5. Settings dividers

**Cause.** Rows after the first had `margin-left: 16px` and their own left padding removed, so the
divider (an inset shadow on the row) started at the text but ran to the group's right edge. In a
group mixing icon and plain rows, a divider also started at the icon rather than the text. Each
divider therefore looked shifted left of centre. The section heading and text were already aligned.

**Fix.** The group's rows after the first take 16px margins on both sides and no side padding.

| | Before | After |
|---|---|---|
| Divider | 16px from the left, 0px from the right | **16px from both edges**: exactly the content column |
| Text | 16px | 16px (unchanged) |
| Toggles | 16px from the edge | 16px from the edge (unchanged) |
| Row height | 68px | 68px (unchanged) |

- **Scope:** only grouped rows (`.list-group__items > .list-row`) inside the theme.
- **Unchanged:** inbox dividers, plain lists, and the dividers inside the prompt set.

## 6. Activity card rhythm

The card's structure, content and order are unchanged; only the spacing changes.

| Step | V10 | V11 |
|---|---|---|
| Photo → title | 12px | 12px |
| Title → category | 4px (the category was pulled up into the title's margin) | **8px** |
| Category → date | 8px | **12px** |
| Date → place | 4px | **6px** |
| Place → host and attendees | 12px | 12px |
| Side padding | 16px both sides | 16px both sides |

The 18px meta icons were already centred on the first line of their text (within 0.5px); this is
now tested. Only the full card changes; the compact card in My activities keeps its spacing.

## 7. Slider handles

The switch handle and the slider handle are now one shape, a white horizontal pill, set by tokens:

| Token | Value | Used by |
|---|---|---|
| `--tiimo-handle-width` / `--tiimo-handle-height` | 34 / 26px | Switch handle (unchanged size, now tokenised) |
| `--tiimo-handle-slider-width` / `--tiimo-handle-slider-height` | **30 / 22px** | Age and distance slider handles (V10: 20 × 28, upright) |

- **The slider handle is one step smaller** so it sits on the 6px rail.
- **It keeps the soft thumb shadow** to lift it off the purple interval and the grey rail.
- **Unchanged:** the rail and interval colours, the 28px row, value labels, ranges, and native
  keyboard behaviour (tested with ArrowRight).

## 8. Component sizes

I measured every control on 13 themed screens and changed only those that were undersized or out of
step with their neighbours:

| Control | V10 | V11 | Why |
|---|---|---|---|
| Small header icon buttons (settings, options, create) and sheet close buttons (Discover filters) | 36 × 36 | **40 × 40** | One size with the back button |
| Small buttons ("Edit profile", "Write a bio", "See insights") | 40px tall | **44px** (20px side padding) | The visible button is the whole touch target |
| Status labels ("Live now", "You're going", "New", "Matched") | 24px | **26px** | Level with the 27px activity category |
| Photo remove button | 26 × 26 | **28 × 28** | Easier to see and hit; still 8px inside the tile corner |

**Left as they are, because they are meant to be compact:**
- metadata icons (18px);
- notification dots (8px);
- radios and checkboxes (24px, inside 44px rows);
- filter chips and segmented options (36px, with 44px hit areas);
- the prompt edit chevron (36px, plain).

## 9. Icons and emoji

- **The one new icon** is the prompt mark, taken from the existing set at the set's weight.
- **Emoji are unchanged:** interest and activity categories only. None were added to Settings, forms
  or navigation.

## 10. Contrast

[qa/contrast-audit.txt](qa/contrast-audit.txt) checks 325 text elements on 15 themed screens: 0 are
below AA. The tab labels are included even though they are `aria-hidden`, because they are visible
text. Results for the new elements:

| Element | Contrast | Requirement |
|---|---|---|
| Tab labels, grey on white | 4.63:1 | AA for text (4.5:1) |
| Tab labels, purple on white | 4.90:1 | AA for text (4.5:1) |
| Prompt mark, purple on the tint | 4.4:1 | 3:1 for non-text graphics |

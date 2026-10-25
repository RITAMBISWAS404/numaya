# Tiimo reference analysis

## Evidence and its limits

- **Source.** I studied Tiimo's iOS screens through the Mobbin research connector, filtering four
  searches to Tiimo. The tool cannot load the exact page URL supplied in the brief, so the searches
  were the route in. They returned **27 distinct screens** across 8 flows:
  - Today timeline (empty, filled, with a context menu, with confetti after completing a task);
  - onboarding (questions, notifications, updates consent, sign-in);
  - add and edit task (form, sub-tasks, tag picker, the "Choose visuals" colour and emoji picker);
  - the AI assistant (prompt, chat, task picker, loading);
  - Me / Weekly insights;
  - Focus timer and widgets;
  - settings (list, notifications, fonts dialog, delete-profile sheet);
  - community Q&A and a lesson course.
- **Resolution.** Mobbin returns about 300 px-wide previews. Sizes, radii and colours below are
  **estimates from previews** (marked ≈), not measured values. Font names could not be identified.
- **Repository evidence.** `docs/research/tiimo-typography-audit.md` (an earlier audit of 8 Tiimo
  onboarding screens) agrees with the typography observations below.
- **Not committed.** No Tiimo screenshot, asset or copy is stored in this repository. Screen links
  are listed at the end.

Labels used below:
- **O**: directly observed in several screens.
- **O¹**: observed on one or two screens only.
- **I**: inferred from the pattern.

## 1. Colour system

| Observed | Consistency | Numaya decision | Implemented by | Constraints |
|---|---|---|---|---|
| The canvas is not white. It is an off-white with a faint lilac cast behind cards (Today, the AI screens, Add task) **O**. Settings lists sit on a slightly warmer grey **O¹**. | High | The themed screens sit on a lilac-white canvas. White is kept for cards, so they read without borders. | `--color-tiimo-canvas` reassigns `--color-surface-page` inside `.theme-tiimo`, and the themed flow screen and sheet backgrounds use it | Text on the canvas keeps ≥ 4.5:1 (ink and secondary greys are unchanged). |
| Pastels **code categories**, not decoration: Morning is peach, Afternoon powder blue, Evening lilac (section capsules). The colour picker offers lilac, blue, sage/mint, pink, peach and butter **O**. One category = one tint, used for its label capsule and emoji holder. | High | Interest categories each get one pastel family: Food and nights in → peach, Culture → lilac, Out and about → mint. Butter is used for "new" tags and stat tiles, powder blue for informational tags. | `--color-tiimo-{peach,butter,mint,sky}-{tint,ink}`; lilac reuses `purple.100/150` | Each pastel has a dark "ink" partner for text on it (≥ 4.5:1). Pastels are never text colours themselves. |
| The signature purple appears as the **confirm** affordance (filled check circle in Add task), toggles, progress bars, the mascot and confetti **O**. Main CTAs are near-black pills **O**. | High | Numaya keeps purple primary CTAs (decision D-22, brand brief). This is a deliberate deviation from Tiimo's ink CTA. Purple also carries selection, progress and confirmation, as in Tiimo. | existing `--color-brand` | The brief requires keeping purple brand identity. |
| Destructive actions are red text (Delete task), a red trash icon, or an ink "Yes, delete" with a quiet "No, cancel" **O**. | Medium | Destructive styles are unchanged. | existing `danger` tokens | — |

## 2. Typography

| Observed | Consistency | Numaya decision | Implemented by | Constraints |
|---|---|---|---|---|
| A display **serif at regular weight** for page and moment titles ("Wednesday", "My Weekly Insights", "Morning routine"), about 30–34 px, sometimes centred **O**. | High | Keep Fraunces (soft serif, regular weight), which is already the closest match. Large moment titles stay centred where the layout already centres them. | existing `--font-display`, `--type-*` | Fonts are pinned in tokens. Changing them would not make the result more faithful. |
| A neutral grotesk for everything operational: list titles semibold ≈ 15 px, meta regular ≈ 12–13 px muted **O**. | High | Inter, unchanged. | existing | — |
| **Uppercase tracked micro labels inside tinted capsules** for group headers ("ANYTIME (0)", "MORNING (4)") and stat labels ("DAYS IN A ROW") **O**. | High | Interest category headers become tinted capsules with uppercase tracked micro text. Activity categories use the sentence-case tag (row below). Activity status badges ("Live now") were left unchanged. They are **group labels for chips, not kickers above a heading**, so the Impeccable no-eyebrow rule still holds. | `.tiimo-capsule` style on the existing category label element | Contrast uses the pastel's ink partner. |
| Sentence-case tags in small tinted pills ("Question of the day", "Meet your expert") **O¹**. | Medium | The "New" and "Your move" tags and the activity category become sentence-case tinted pills. | `.tag` / `.badge` variants inside the theme | — |
| Large serif numerals for stats ("3", "5", "30:12") **O**. | Medium | Not applied: none of the 12 screens has a stat block. Profile readiness would be the place. | — | — |

## 3. Spacing and density

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Generous outer gutters (≈ 16 px) and **tight stacks of separate cards** with ≈ 8–10 px gaps (task rows) **O**. | High | Lists of items (likes, chat rows, prompt options) become separate white cards with an 8 px gap, instead of hairline-divided groups. The 16 px gutter is unchanged. | `.theme-tiimo .list-group` and option rows |
| Section headers sit close above their cards (≈ 8 px) with larger space before the next section (≈ 20 px) **O**. | High | Unchanged: Numaya already follows this rhythm. | — |

## 4. Corner radii and geometry

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Item cards ≈ 14–16 px radius; large containers (insights, the Add task sheet, widgets) ≈ 22–28 px **O**. | High | Two card sizes: **item card 16 px**, **feature card 24 px** (profile sections, the prompt object). | `--tiimo-radius-item`, `--tiimo-radius-feature` |
| Emoji holders are **small rounded squares** (≈ 28–32 px, ≈ 8–10 px radius) or circles in the picker **O**. | High | **Revised during implementation.** In chips and tags the emoji sit inline, before the label. A 32 px holder inside a 36 px chip crowded the label. Holders appear only on Welcome, as 76 px tinted stickers with the feature radius. Tokens `tiimo.emoji-size` and `tiimo.emoji-radius` are reserved for list rows. | `.welcome__sticker`, `[data-emoji]::after` |
| Buttons and value chips are full pills. Option buttons on onboarding questions are outlined pills **O**. | High | Pills for buttons, chips, tags and value pills. Cards are never pills. | existing `radius.pill` |
| Sheets have very large top radii (≈ 32 px) with a grabber **O**. | High | Sheets keep their existing large radius. | — |

## 5. Card surfaces, borders and elevation

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Cards are **white on the tinted canvas with a very soft, diffuse shadow and no border** (task rows, insights cards, the Add task groups) **O**. | High | Profile sections, list groups and option rows lose their hairline and gain a soft diffuse shadow. | `--shadow-tiimo-card` |
| **Nested tinted tiles inside a white card** (the "3 days in a row" lilac tile and the "5 total days" blue tile inside the insights card) **O¹**. | Medium | Shared-interest pills and stat-like tags nest as tinted tiles inside white cards. No card-in-card. | pills and tiles |
| **Dashed outlines** mark empty or "add" slots ("Anytime today works +", "ADD NEW") **O**. | High | Empty photo slots become dashed outlines with a small white "+" disc. | `.theme-tiimo .photo-slot--empty` |
| Floating chrome (circular icon buttons, the "Today" pill, the bottom nav capsule) is white with a stronger, wider shadow **O**. | High | Two elevation levels in the theme: **card** (diffuse, low) and **float** (top-bar buttons, tab bar). Sheets keep the existing modal level. | `--shadow-tiimo-card`, `--shadow-tiimo-float` |

## 6. Pill controls and buttons

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Primary CTA: full-width near-black pill, semibold label, often a trailing → arrow. Disabled is a light grey pill with grey text **O**. | High | Purple full-width pill (brand rule, see 1). Disabled stays grey. No arrow is added: Numaya's labels already name the action. | existing `Button` |
| Secondary: **white pill with a soft shadow** ("Start task", "Done") or a light grey pill ("No, cancel") **O**. | High | Secondary buttons become white pills with the float shadow, instead of a grey fill, so they read as tappable on the tinted canvas. | `.theme-tiimo .btn--secondary` |
| Choice options on onboarding questions are **outlined pills**. The selected option gets a **darker, thicker outline**, not a fill **O¹**. | Medium | Radio and option cards keep Numaya's selected purple outline (≥ 1.5 px) and move to white cards with no hairline when unselected. | `.theme-tiimo .choice` |
| Value pills in forms ("Morning", "Jan 15, 2026", "1h 15m") are light grey with a leading icon **O**. | High | Not applied: no selected screen has value pills. | — |

## 7. Icons and emoji

| Observed | Consistency | Numaya decision | Implemented by | Constraints |
|---|---|---|---|---|
| Emoji carry **content identity**: a task's emoji, tag emoji ("🧹 Household", "💼 Work"), suggestion chips ("🧑‍🍳 Create a morning routine") **O**. | High | Emoji label **interests** (🍷 Natural wine, 🎷 Jazz, 📷 Film photography …) and activity categories, wherever the interest or category appears: Interests, Discover "You both like", Match, Like back, Activity filters. | `data-emoji` on the existing chip, shown by CSS only inside the theme | Emoji are decorative (`content: attr(data-emoji) / ""`). The interest label stays the accessible name. |
| Utility controls stay **line icons** (×, ⋯, +, back, settings gear); emoji never replace them **O**. | High | Material Symbols stay for every utility control and the tab bar. | existing `Icon` | — |
| A purple **mascot** and illustrated people for big moments **O**. | Medium | Not copied: proprietary illustration, and Numaya's own illustration slots are unsupplied. | — | Truthful-by-default. |

## 8. Navigation

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| A **floating white bottom capsule** with icon + label. The active item has a light grey pill **O**. | High | Numaya's icon-only floating capsule (decision Y2) keeps its information architecture. It takes the theme's float shadow, and the active pill takes a lilac tint. | `.theme-tiimo .tab-bar` |
| Top bars are not bars: **floating circular white buttons** at the corners, with an optional centred title **O**. | High | Already Numaya's pattern. It takes the float shadow. | `.theme-tiimo .nav-button--floating` |

## 9. Inputs and selection states

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Text areas and answer fields are **warm light-grey fills with no border**, ≈ 16 px radius ("Write your answer here", "Write your notes here…") **O**. | High | Fields use a warm stone fill instead of cool grey, with no border. The focused purple ring is unchanged. | `--color-tiimo-field` |
| Toggles are purple when on **O**. Tag chips selected = **tinted fill, no border** ("🧘 Self care" on pink) **O¹**. Completed = filled black check circle **O**. | Medium | Selected interest chips fill with their **category tint** and use the category ink text, keeping the "−" glyph and `aria-pressed`. Selection is never conveyed by colour alone. | `.theme-tiimo .chip.is-selected[data-tone]` |

## 10. Photography and profile presentation

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Tiimo has little photography. People appear as **initials in pastel circles** (community answers) or as circular photos **O¹**. | Low (not a photo-led app) | Numaya's photo slots, aspect ratios and placeholders are unchanged. The theme changes only their **container**: feature radius and soft shadow. Initials avatars keep their pastel framing, which already matches. | existing `Avatar`, `ProfileCard` |

## 11. Empty and success states

| Observed | Consistency | Numaya decision | Implemented by |
|---|---|---|---|
| Empty slots are dashed placeholders with a hint line **O**. Loading is a soft lilac orb with a serif line **O¹**. Success is **lilac confetti** over the page header after completing a task **O¹**. | Medium | The match moment gets a quiet, static scatter of lilac and butter dots behind the heading: the celebratory confetti principle, without motion or copied artwork. Empty states keep their existing illustrations. | `.theme-tiimo .match` decoration (CSS only, `aria-hidden`) |

## 12. Motion and interaction feedback

| Observed | Consistency | Numaya decision |
|---|---|---|
| Static previews cannot show motion. Confetti implies a celebratory burst on completion **I**. | — | No new motion. The theme is static, and Numaya's reduced-motion behaviour is unchanged. Press feedback (scale on `:active`) is unchanged. |

## Screens studied (Mobbin)

- [Today, empty](https://mobbin.com/screens/f6a61b24-612d-4536-8ca0-375231808968)
- [Today, filled](https://mobbin.com/screens/d990d02c-e750-43b7-a814-d46ac783592d)
- [Today, confetti](https://mobbin.com/screens/c98c5605-7b0e-4687-8aff-3d8b461931da)
- [Context menu](https://mobbin.com/screens/ecb6c710-108e-4056-893f-4aacc9b557a7)
- [Weekly insights](https://mobbin.com/screens/dbb619b5-05e1-44cb-a1c3-b7b4e5e2cf18)
- [Focus timer](https://mobbin.com/screens/d48bf436-41ec-411f-b88d-273fae504f68)
- [AI assistant](https://mobbin.com/screens/ed164b6c-6952-48e5-b56b-32a747e08c73)
- [Pick tasks](https://mobbin.com/screens/fd2c2149-cba5-4d55-9fbc-dae3352f8513)
- [Lessons](https://mobbin.com/screens/f1a52db2-2724-406c-82bb-5bcba8bd7707)
- [Question of the day](https://mobbin.com/screens/ee88c59c-59c3-4a88-9878-435eae614904)
- [Notifications onboarding](https://mobbin.com/screens/edec19f7-e515-437d-9ea6-2bd731be0d8c)
- [Updates consent](https://mobbin.com/screens/e4d51357-f83e-49f8-ad20-04de0e6c58e7)
- [Neurodivergent question](https://mobbin.com/screens/e2345aec-25d2-4584-9bcc-266601eaf9de)
- [Add task](https://mobbin.com/screens/fcf39ab1-1c59-4b6c-b0dd-781663ca7b7a)
- [Edit task](https://mobbin.com/screens/eeda77c3-d3cd-4f8c-bb61-c6a7a93644f0)
- [Tag picker](https://mobbin.com/screens/defe1eb0-8426-4110-a9f1-478790cecdf5)
- [Assistant chat](https://mobbin.com/screens/e0a60bfe-a3b8-4f24-91b9-7a498e53b5f5)
- [Notifications settings](https://mobbin.com/screens/edaf755a-fa6a-4f9d-89cb-bd7392fce5e9)
- [Settings](https://mobbin.com/screens/e824a18f-ebeb-489e-9b3c-aedc2a0fd9ba)
- [Choose visuals](https://mobbin.com/screens/e5969fea-bad1-4de8-aeb8-fd7586a24587)
- [Delete profile sheet](https://mobbin.com/screens/e4d13e43-8d7a-4445-890c-40db9ccf8b83)

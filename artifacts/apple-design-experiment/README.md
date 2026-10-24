# Apple-design experiment: baseline audit and direction

Baseline: commit `934f767` (branch `claude/apple-design-experiment`). Captures:
`node scripts/apple-design-experiment.mjs before` (393 × 852, 375 × 667, 1440 × 900, 2× DPR,
reduced motion, seeded sessions identical to `npm run gallery`).

Constraint found in the audit: **no profile photography exists in the repo** (`src/assets` holds no
photos; every photo is an honest grey placeholder) and the welcome hero and match illustration are
unsupplied slots. Nothing below invents either.

Desktop: only the onboarding prototype has a designed desktop layout (brief + phone frame). The
flow screens in single-screen mode (`flows.html?screen=…`) simply stretch the phone UI to 1440 px;
that is captured for evidence but it is not a designed layout, and designing one is out of scope.

## 1. Onboarding / Welcome (`index.html`, `src/prototype/screens/Welcome.jsx`)

Ranked problems
1. **No visual anchor in the top 60 %.** The hero slot is reserved and invisible, so the screen is a
   lavender void above a bottom sheet. The brand never appears on the first screen: no wordmark.
2. **The panel reads as a modal sheet over nothing.** A raised white sheet with a drop shadow and
   24 px top corners implies something sits behind it; nothing does.
3. **Centred, mid-size type in a small block.** The 34 px headline, lede, two buttons and legal all
   share one centred axis at the bottom; nothing ties them to the top of the screen.
4. Secondary action and legal are well judged; CTA treatment is fine.

Direction: keep the reserved hero slot (product decision) but give the screen a spine. Wordmark top
left; the wash continues into white with no sheet edge; a left-aligned editorial headline, larger and
tighter (size-specific tracking, §15), sharing one left axis with the wordmark, lede and actions.
Reuse `Wordmark`, `Button`, tokens. No new artwork.

## 2. Discovery / profile card (`flows.html?screen=discovery`)

Ranked problems
1. **Prompt hierarchy is inverted.** The prompt question is the Fraunces title and Maya's answer is
   plain Inter body, the opposite of `PromptCard` on Profile and Interests, where the answer is the
   expressive voice. The most personal content on the card is the least prominent.
2. **Placeholder photo reads as a broken image.** Flat grey plus a 62 % ink gradient makes a muddy
   grey-to-charcoal slab; the scrim starts too high for a card this tall.
3. **Name is undersized for a full-height card** (31 px on a 680 px tall photo).
4. **Every section is the same hairline card**, so the scroll is a stack of identical boxes.

Direction: answer in Fraunces as the hero of each prompt with the question as a small label; lighter
dimensional placeholder and a shorter, softer scrim (still dark enough for white text); larger name;
quieter section containers on the white page. Reuse `ProfileCard`, `ProfileSection`, chips.

## 3. Match (`flows.html?screen=match`, seeded match with Maya)

Ranked problems
1. **The composition falls apart vertically.** Title, portrait, copy, then a small heart floating in a
   128 px tall 5:2 slot, then ~200 px of nothing before the composer. The heart reads as a stray icon.
2. **Too many pastels at once:** lavender scallop + yellow fallback fill + purple heart.
3. **Title is a section title size (31 px) for the product's biggest emotional moment.**
4. Copy does not name the other person with any emphasis.

Direction: larger hero title, the portrait as one confident unit (thinner, calmer scallop ring), the
person's name emphasised in ink, and the illustration slot kept at its contract (5:2) but pulled into
the group so title → portrait → copy → slot reads as one composition, optically centred. Keep the
sketch order, white page, existing slot and fallback.

## 4. Profile (`flows.html?screen=profile`)

Ranked problems
1. **Readiness is shown twice** (avatar ring with "73" badge, and a card with a second 73 ring), so
   the top half is about a score, not the person.
2. **Nothing personal besides the name**: no interests, no "looking for", no age-in-context; it reads
   as a settings page with an avatar.
3. **Three heading styles** (Fraunces "Prompt" + description, grey "Activity" / "Account" labels).
4. Edit profile is a grey pill competing with two other grey pills in the card below.

Direction: an identity block (avatar ring per spec B-23, name large, a quiet facts line, the
person's interests as static chips), a single readiness row without the duplicate ring, and one
section-label style. Reuse `Avatar`, `Chip`, `ListGroup`, `PromptCard`, `Button`.

## 5. Interests (`flows.html?screen=interests`)

Ranked problems
1. **Selected chips are heavy solid purple slabs**; with five chosen the screen is mostly purple, and
   the − glyph reads as "remove" rather than "selected".
2. **The maximum state looks broken**: locked chips lose their outline and become loose grey words,
   so the grid's rhythm collapses.
3. **Count is said twice** ("2/5 selected" header and "Pick 1 more" footer).
4. Chip size (36 px, 17 px type, wide padding) makes the cloud ragged with uneven line ends.

Direction: selected = brand-tint fill, deep-purple text and a check (clear, lighter, still
purple-coded and ≥ 7:1); unselected = hairline outline with a muted +; locked = same outline,
muted, never shape-less. Tighter chip metrics for an even cloud. Keep `ChipGroup` API.

---

# Results

After captures: `node scripts/apple-design-experiment.mjs after`; side-by-side sheets:
`node scripts/apple-design-experiment.mjs compare` → `compare-393x852.png`, `compare-375x667.png`,
`compare-1440x900.png`. Files are named `<screen>-<before|after>-<WxH>.png`.

Scores are design judgements (1–5) on the same captures, static, reduced motion. H = hierarchy,
C = composition, T = typography, Cr = craft, D = distinctiveness, R = restraint, U = usability.

| Screen | H | C | T | Cr | D | R | U | Mean |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Welcome, before | 3 | 2 | 3 | 3 | 2 | 4 | 4 | 3.0 |
| Welcome, after | 4 | 3 | 4 | 4 | 3 | 4 | 4 | 3.7 |
| Discover, before | 3 | 3 | 3 | 3 | 2 | 4 | 4 | 3.1 |
| Discover, after | 4 | 3 | 4 | 4 | 3 | 4 | 4 | 3.7 |
| Match, before | 3 | 2 | 3 | 3 | 3 | 3 | 4 | 3.0 |
| Match, after | 4 | 3 | 4 | 3 | 3 | 3 | 4 | 3.4 |
| Profile, before | 2 | 2 | 3 | 3 | 2 | 3 | 3 | 2.6 |
| Profile, after | 4 | 4 | 4 | 4 | 3 | 3 | 4 | 3.7 |
| Interests, before | 3 | 3 | 3 | 2 | 2 | 3 | 3 | 2.7 |
| Interests, after | 3 | 4 | 3 | 4 | 3 | 3 | 4 | 3.4 |

## What changed

- **Welcome:** wordmark as a brand header (outside the reserved hero slot); wash settles into white
  so the copy sits on the page, not on a shadowed sheet; left-aligned 36–42px headline with tighter
  tracking and leading; larger lede. Hero slot unchanged and still empty.
- **Discover:** new `ProfilePrompt`: question as a label, answer in Fraunces 26px. Section titles in
  `ProfileSection` become quiet labels, so Fraunces is reserved for the person (name, answers).
  Name scales to 40px. Eased scrim; lit placeholder gradient (colour still photo grey); subtler glyph;
  fact-chip icons muted.
- **Match:** title at display size; thinner halo; person's name in ink; height-aware spacing so the
  whole moment fits 375 × 667; illustration slot narrowed to 240px (5:2 contract kept).
- **Profile:** centred identity (ring avatar per B-23, 34px name, facts line, interests chips, Edit);
  readiness card meter 72 → 56 with an Inter title and a quiet "See insights"; prompt heading in the
  same label style as Activity / Account.
- **Interests:** `ChipGroup groups` splits the ten options into three labelled sets; locked chips keep
  a hairline. Selected stays solid brand purple (Meetup map product decision, asserted by e2e).

## Still weak

- Welcome: the top half is still empty by product decision until the hero artwork arrives.
- Match: without the hands artwork, the heart fallback leaves space under it on tall phones.
- Profile: readiness still appears twice (spec B-23 badge + the card's meter, asserted by e2e).
- Discover: every photo is a placeholder, so the card's real quality cannot be judged.
- Desktop: flow screens stretch to 1440px in single-screen mode; not designed, not changed.

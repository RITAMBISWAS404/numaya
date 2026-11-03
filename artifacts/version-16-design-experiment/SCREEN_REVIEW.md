# V16 screen review

**Captures:** the 29 gallery states, each as a V11 / V16 pair in `screenshots/compare-v11-v16/`, with
the contact sheets in `screenshots/`.

**Pass structure:**
- Each pass looked at full-size captures, not only the contact sheet.
- Fixes were recaptured and checked again before the next pass.
- **Substantive refinement passes: 1, 2 and 3.** Each changed `theme-wth.css` or the tokens.

## Pass 1: reference fidelity
**Method:** compare V16 with the Health Mate previews ([compare-reference-v16.png](screenshots/compare-reference-v16.png))
on five paired patterns: settings, single choice, tabs, sheet, cards.

**Matches the reference:**

| Pattern | Reference | V16 |
|---|---|---|
| Canvas and cards | warm grey canvas, white 16px cards, no edges or shadows | matches; the strongest single signal of the reference |
| Primary action | black, 12px rectangles (not pills) | "Show 3 people", "Write a bio", "Like back" |
| Selection | black radios; green switches; blue only for selection and accents | matches |
| Navigation title | small, bold, uppercase, tracked ("ACCOUNT & SECURITY") | "SETTINGS", "EDIT PROFILE", "YOUR PROMPT" |
| Group labels | eyebrows ("WEIGHT", "BODY COMPOSITION") | "HOW OLD ARE THEY?", "VISIBILITY", "YOUR PROMPT" |
| Current tab | tinted blue pill ("Weight") | the current Likes and Messages filters |

**Defects found and fixed:**
1. **Slider fill was black, not blue.** V11 draws the slider with pseudo-elements that read
   `--color-control-selected`, which V16 sets to ink for radios. Fixed by setting `::before` (track)
   and `::after` (fill) directly.
2. **Chat header name was uppercased** by the navigation-title rule, and resetting its size moved the
   verified mark 1.1px. Removed `.fl-chat-head__name` from the rule: a person's name is not a
   navigation title.

**Differences kept on purpose:**
- **Tab bar:** V11's five-item tab bar is not Health Mate's three-item iOS bar. It is locked by the
  [layout contract](design-system/V11_LAYOUT_CONTRACT.md).
- **Sheet header:** "Cancel" stays where V11 puts it (a close button on the right).

## Pass 2: consistency
**Method:** read every screen against the [component rules](design-system/COMPONENT_RULES.md).

**Defects found and fixed:**
1. **Match (030, 032, 146):** your own avatar, tint on the tinted scallop, merged into the shape. V11
   separated the two with a white ring and a shadow. **Fix:** your avatar takes the white surface, with
   a canvas ring.
2. **Filters sheet (023):** the slider track `#E4E4E6` on the canvas-tone groups inside sheets was
   1.15:1 and nearly invisible. **Fix:** a new token `wth.track-deep` `#D6D4D0` for sliders inside
   sheets: 1.33:1, matching V11's track on white (1.32:1).

**Checked and consistent:**
- **Buttons:** every primary is ink, every secondary has an ink edge, every disabled is taupe (Save
  prompt, the composer's send).
- **Chips:** interest chips are white with a hairline edge on all of Profile, Match and Like back.
- **Signals:** red is used only for unread counts, notification dots and Unmatch.
- **Purple:** none on any themed screen (also asserted by the E2E suite).

## Pass 3: layout preservation
**Method:** side-by-sides with V11, and the geometry diff (every element's box, 12 states, 2
viewports).

**Defect found and fixed:**
- **Prompt editor (108):** "Pick a prompt" is a group legend but stayed sentence case while every
  other group label is an eyebrow. Added `.option-cards__legend` to the eyebrow rule.
  - The geometry diff confirmed the legend's box did not move.
  - The only drift on that screen is the centred navigation title's text run, which the rule allows.
  - "Your answer" stays sentence case: it is a field label, as in the reference ("Select a time frame").

**Geometry results:**
- **Non-text elements:** none moved or resized by more than 1px.
- **Text runs:** they changed width only, from:
  - uppercase navigation titles;
  - Hanken headings: the profile name 8px, the match title 10px.

  None changed its line, height or line count.
- **Full-page captures:** 020, 100, 103 and 112 have the same heights as V11's.
- **375 × 667 states** (145–158): nothing new clips or wraps.

**Noted, not changed:**
- **Like back (059):** while scrolled, the white "You both like" card is cut flat by the canvas
  action bar.
  - V11 has the same structure, but there both surfaces are white, so the cut does not show.
  - Fixing it would mean a new surface on the action bar or moving the card. The first changes V11's
    sticky bar treatment; the second is out of scope.

## Pass 4: product quality and accessibility
**Accessibility:**
- **axe-core:** 0 serious or critical violations on the V16 welcome screen, all flow previews and the
  open filters sheet. The full suite has 13 targets, all clean.
- **Text contrast:** every pairing is ≥ 4.5:1; the lowest is grey-600 on canvas, at 4.73:1.
  - Blue text on the tint would be 4.36:1, so text there uses the deep blue (5.95:1).
- **Control edges:** fields, switch-off and chip-group edges are ≥ 3:1 (3.43:1 on white, 3.09:1 on
  canvas).
- **Focus:** a visible 2px blue ring on every control, checked by the E2E suite.

**Product quality (judgement):**
- **Execution:** V16 is calm, orderly and very legible.
  - The black primary gives every screen one clear action.
  - The eyebrows and white cards make Settings and Profile easier to scan than in V11.
- **Fit for Numaya:** it reads as **health and utility software**.
  - Blue, black and taupe on warm grey is clinical next to V11's purple and Fraunces serif, which
    carried Numaya's warmth and its brand.
  - The emotional moments lose the most: the Match screen, the Welcome screen and Discover.
- **Brand conflict:** V16 retires the brand purple `#7262C7`, which `CLAUDE.md` lists as a
  non-negotiable. Adopting V16 would need that decision reversed.

**Assessment:** V16 is a faithful, accessible, layout-safe reconstruction. It does not clearly improve
Numaya as a dating product.

**Smaller ideas that could transfer to V11 separately:**
- uppercase eyebrows for group labels;
- edge-free white cards on a warm canvas;
- the green "on" switch.

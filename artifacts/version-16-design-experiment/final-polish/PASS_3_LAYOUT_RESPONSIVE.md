# Pass 3: layout, alignment and responsive QA

## Method

- **Automated layout audit** (`qa/audits.txt`) on Welcome plus the 14 flow screens at **360 × 740, 375 × 667,
  393 × 852 and 430 × 932**. It checks:
  - page overflow;
  - elements outside the viewport that aren't in a horizontal scroller;
  - text clipped by `overflow: hidden` without an ellipsis;
  - the tab bar overlapping the scroll body;
  - console errors.
- **Desktop gallery** (`flows.html?theme=withings`) at 1440 × 900.
- **Visual inspection** at full size: all 49 states at 393 / 375, full-page scrolls of Discover, Match, Activity,
  Profile, Edit, Preview and Settings, and six screens each at 360 and 430 (`screenshots/comparisons/responsive-*.png`).

## Results

| Check | 360 | 375 | 393 | 430 | 1440 gallery |
|---|---|---|---|---|---|
| Page overflow | 0 | 0 | 0 | 0 | 0 |
| Off-screen elements | 0 | 0 | 0 | 0 | — |
| Clipped text | 0 (only `.visually-hidden` screen-reader labels, intended) | 0 | 0 | 0 | — |
| Tab bar over content | no | no | no | no | — |
| Console errors | 0 | 0 | 0 | 0 | 0 |

## Defects found and fixed

| # | Defect | Fix | Verified |
|---|---|---|---|
| 3.1 | **Likes grid at 430px:** tiles in one row had different photo sizes (257 against 243px) because a tile's width followed its caption | The tile fills its column (see 2.5) | 257 / 257 at 430; e2e check; `responsive-430.png` |

## Checked and consistent

- **Margins:** a 16pt gutter on every screen except Discover and Like back, whose photo layout uses V11's 8pt tight
  gutter. Their cards and empty state align to that same 8pt edge.
- **Vertical rhythm:** 28pt between sections, 12pt between cards, 20pt between fields (V11's tokens). Group heading to
  group is 12pt.
- **Label to field:** 8pt everywhere: field, choice and chip-set labels.
- **Text wrapping:**
  - long prompt answers and activity titles wrap within their cards;
  - the inbox preview truncates with an ellipsis at 360;
  - "Looking for (up to 2)" fits on one line at 360.
- **Photos:** Discover's 3:4 crop, tile and slot crops unchanged from V11; placeholders centred.
- **Fixed elements:**
  - the tab bar is the last flex row (never overlaps);
  - the composer and step-button footers sit above the scroll area;
  - sheets cover the tab bar with their scrim.
- **Safe area:** the tab bar pads `--safe-bottom` (V11, unchanged).

## Not changed (would alter the product)

- **Edit profile mixes section headings with capital field labels.** "Photos" and "Prompt" are 22pt headings; "BIO",
  "INTERESTS" and "FIRST NAME" are capital field labels; "About you" is a 22pt group heading. This reflects V11's real
  structure (fields against groups) and the reference's form pattern. Making it uniform would mean regrouping the
  form, which is a product decision, so it is recorded rather than changed.
- **The Discover gutter** (8pt) stays V11's: the photo is the composition.

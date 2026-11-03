# Typography guidelines

## Typeface: Figtree
| | |
|---|---|
| **File** | `apps/numaya_mobile/assets/fonts/Figtree-Variable.ttf` (variable `wght` 300–900, 62 KB) |
| **Source** | github.com/google/fonts, `ofl/figtree/Figtree[wght].ttf` |
| **Licence** | SIL Open Font License 1.1: `assets/fonts/OFL-Figtree.txt`. Copyright 2022 The Figtree Project Authors (Erik Kennedy). |

**Registration and loading:**
- `pubspec.yaml` registers the family `Figtree`.
- `test/helpers/test_app.dart` loads it for goldens.
- The baseline's Hanken Grotesk file remains in `assets/fonts/` but is no longer registered.

### Why Figtree
The candidates were rendered side by side on the same content (titles, a name, metadata, body,
numbers, a pill); see [font-trial/candidates.png](font-trial/candidates.png).

| Candidate | Result |
|---|---|
| Hanken Grotesk (baseline) | crisp but narrow and mechanical at body sizes; it did not deliver the "rounded and spacious" brief |
| **Figtree** | **chosen:** geometric with soft, rounded terminals, open counters, friendly but adult; the closest in feel to Meetup's soft geometric headings; clear numerals (good for metrics); a small file |
| Plus Jakarta Sans | handsome but wider and more stylised: long names wrap sooner |
| DM Sans | close to Figtree; slightly more mechanical "a" and "g" |
| Manrope | crisp but technical |
| Nunito Sans | the roundest; tipped towards childish at display sizes |

**Reference faces are not identified:** none of the four reference apps names its typeface, and
none is claimed here.

## Roles
The scale is in [TOKENS.md](TOKENS.md#type). The rules:

| Rule | Detail |
|---|---|
| **Headings** | bold (700), slightly tightened (−0.01 to −0.02em); larger sizes tighter |
| **Body** | 16/24 regular: generous 1.5 leading for reading |
| **Metadata** | 13/18 regular muted (`caption`) |
| **Sentence case** | everywhere, including modal titles and field labels. The baseline's uppercase titles and labels were removed. |
| **Uppercase** | only `labelCaps` eyebrows (12/600, +0.06em): event date eyebrows (in purple), "SELECTED" counters, small group eyebrows |
| **Numbers** | `metric` uses tabular figures, so counts don't jitter as they change |
| **Weights in use** | 400, 500, 600, 700. No light weights (legibility on grey). |

## Behaviour
- All sizes are logical pixels and scale with the system text size. Nothing is capped.
- `BalancedText` keeps multi-line headings balanced.
- Long names wrap; they never truncate in headings.

**Tested renders:**
- 320pt at 1×;
- 375pt at 1× and 2×;
- small phones at 130% and 150% text;
- sign-up at 200% text (existing worst-case and accessibility tests).

**Known limit:** at 200% text on a 375pt phone, an 11-letter single word in a name
("Maximiliana-") cannot fit the photo card and breaks inside the word. The baseline did the same,
one letter later ("Maximilian|a-"). See QA_REPORT.md.

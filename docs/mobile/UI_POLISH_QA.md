# UI polish QA

Branch `experiment/numaya-quality-motion`. What was checked, how, and what it showed. The defect list is in
[UI_POLISH_BACKLOG.md](UI_POLISH_BACKLOG.md).

## How it was checked

| Check | Kind | Where |
|---|---|---|
| Worst-case member data (a 25-character hyphenated first name; prompt, bio, about fields and Opening Moves at their limits; a bio with an unbreakable link; the five longest interests; every detail; five languages; a long unbroken link in a chat) on Profile, completion, Edit profile, preview, Opening Moves, Messages, a chat, Settings and Premium | Automated: any layout error fails, and the test names the widget | `test/widget/break_ui_test.dart` |
| The same at 320 × 568 (100%), 375 × 667 (130%) and 393 × 852 (200% text) | Automated | same |
| Tap targets and labels on onboarding, the dating screens and 24 full-app routes | Automated (`labeledTapTargetGuideline`, `androidTapTargetGuideline`) | `test/widget/accessibility_test.dart` |
| Captures of every screen, compared with the previous commit pixel by pixel; every change looked at | Automated capture, **human inspection** of the differences | `test/screenshots/`; `goldens/` |
| Worst-case captures `w01`–`w06` | Automated capture, **human inspection** | `capture_worst_case_test.dart` |
| Phone, emulator, TalkBack, real keyboard | **Not done**: there is no Android SDK in this environment | — |

## What the comparisons showed

Every capture that changed in this pass was compared with the previous commit before it was accepted.

| Captures | Change | Verdict |
|---|---|---|
| `d113`, `f28`, `22`, `q149` (Settings) | New **App** group with the *Vibration* switch | Intended |
| `02`, `05` | Caret blink phase | Timing only |
| `f25` | Spinner phase | Re-captured at a legible phase |
| `16`, `d019`, `f02`, `q145`, `d059`, `f21`, Likes and chat captures with badges | Badge text 1 pt lower (line height 1.1) | Accepted (O-03) |
| First attempt: `01-welcome` | The Demo badge dropped to a second line | **Regression caught and fixed** before commit (the badge's centring widget took the full width inside the new wrapping header) |
| First attempt: `f30` notifications, `22` settings | Labels wrapped ("Matches about to / expire") because values were given a fixed half of the row | **Regression caught and fixed**: a value takes its natural width up to 60% |
| First attempt: Home and preview cards | The photo icon centred on the whole card instead of the photo | **Regression caught and fixed**: back to photo-above-band layout, with a measured minimum height |

## Worst case, by eye (`w01`–`w06`)

- **Profile:** the name wraps at its hyphen across two lines; interests wrap in centred rows; the prompt shows
  in full.
- **Preview:** the name band grows; job and school lines wrap; the card keeps its photo.
- **Edit profile:** "Verify my profile · Not verified" fits; long values truncate after two lines with an
  ellipsis (the full value is in the editor one tap away).
- **Opening Moves:** three 160-character questions wrap inside their cards.
- **Chat:** the unbroken link breaks at its slashes inside the bubble; "Demo · saved on this device, not
  sent" stays under it.
- **Messages:** the preview line ellipsizes the link; "Your move" stays legible beside a preview.

## Not covered here

Right-to-left layouts (no RTL locale ships), landscape (portrait app), tablets, and anything that needs a
device (see backlog O-04).

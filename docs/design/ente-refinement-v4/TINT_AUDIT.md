# Tint audit by purpose, and defect ledger

Method: every `*Tint` and `*Subtle` use in `lib/` was read and classified by what it does, not by a
text replacement. `accentOnTint` is the brand **text** colour despite its name, so its uses are not tints.

## Remaining tinted fills
| Site | Purpose | Reachable in normal product state? | Verdict |
|---|---|---|---|
| `app_theme.dart` `primaryContainer`, `errorContainer` | Material theme slots | Only if a framework widget reads them | Functional |
| `app_theme.dart` `selectionColor` | Text selection highlight | Yes, while selecting text | Functional |
| `navigation.dart:406` | Tab indicator tint | Lab variant only | Baseline kept for comparison |
| `welcome_screen.dart:221` | Welcome variant O | Lab variant only | Baseline kept for comparison |
| `lab_banners.dart:169` | Banner variant D | Lab variant only | Baseline kept for comparison |
| `profile_prompt_card.dart:136` | Prompt card variant | Lab variant only | Baseline kept for comparison |
| `semantic_specimen_screen.dart`, `design_lab_screen.dart` | Palette specimen | Lab and demo only | Documentation |

## Removed from normal states
Icon tiles, code-cell error and success fills, brand button fill, brand nav icon button, heart action
buttons, tinted badges, event covers, date tiles, verification pose panels, setup "done" rows.

## Defect ledger (baseline renders)
| ID | Defect | Result |
|---|---|---|
| D1 | Tinted event covers with a debug caption | Fixed: demo photos or a neutral fallback |
| D2 | Event detail was one long list | Fixed: variant G groups |
| D3 | Sample banner pushed events down | Fixed: quiet caption |
| D4 | 55% panel darkened photos | Fixed: 10% gradient and compact label |
| D5 | Heart action peeked behind floating nav | Fixed: one row of locked tiles |
| D6 | Image glyph drew behind the lock | Fixed |
| D8 | Lavender heart buttons and badges | Fixed in primitives |
| D10 | Setup "Done" rows looked disabled | Fixed: white surface |
| D15 | Wallet read "2 2 credits" | Fixed |
| D26 | Accessibility row used a globe | Fixed: `info`; dedicated glyph is a known gap |
| D27 | Larger gap after Directions link | Fixed |
| D25 | Purple Compliment control over photo | Kept: it is an action, approved earlier |

# Onboarding edge cases

Each case lists the onboarding screen (from [ONBOARDING_MASTER_INVENTORY.md](ONBOARDING_MASTER_INVENTORY.md)),
the input, the expected behaviour, and where it is checked.

Test files are in `apps/numaya_mobile/test/`:
- `unit/profile_rules_test.dart` (**rules**)
- `unit/onboarding_controller_test.dart` (**ctrl**)
- `widget/onboarding_flow_test.dart` (**flow**)
- `widget/onboarding_edge_cases_test.dart` (**edge**)
- `widget/onboarding_complete_test.dart` (**complete**)
- `widget/accessibility_test.dart` (**a11y**)
- `widget/break_ui_test.dart` (**break**)
- `widget/motion_test.dart` (**motion**)

A dash means the case was checked only by reading the code, or still needs a device.

## Name and birthday (OB-06, OB-07)

| Case | Input | Expected | Test |
|---|---|---|---|
| Empty name | `` or `   ` | No error shown; Next disabled; caption "Add your name and birthday" | rules, edge |
| Name characters | `Sam2`, `Sam 😀`, `-Sam`, `@sam` | "Use letters only, without numbers or emoji." | rules, edge |
| Unicode names | `Zoë`, `José María`, `明美`, `Сергей`, `O'Neill`, `Mary-Elizabeth` | Accepted | rules, edge |
| Long name | 30 characters (field limit) | Accepted; wraps on the profile card | break |
| Incomplete date | `12/04/96`, an empty field | No error; Next disabled | rules |
| Date that doesn't exist | 31/02/1996, 29/02/1997, 00/05, month 13 | "That date doesn't exist…" | rules, edge |
| Leap day | 29/02/1996 | Accepted ("You're 30") | rules, edge |
| Future date | 28/10/2026 (one day after the test date), 2030 | "That date is in the future." | rules, edge |
| Over 100 | 26/10/1925 | "Check the year…"; exactly 100 (27/10/1926) is accepted | rules, edge |
| 18 boundary | Born 27/10/2008 on 27/10/2026, and born 28/10/2008 | The first is 18 and accepted; the second is 17 and gets the under-18 note | rules |
| Under 18, typo | 01/06/2012 → Next → confirm card "You're 14" → **Edit** | Card closes and the answers are kept | edge |
| Under 18, confirmed | → **Confirm** | Under-18 screen; system back stays; `/home`, `/setup/gender` and `/setup` all redirect there; only Sign out leaves | edge, ctrl |
| Repeated Next | Two taps in a row | One confirm card | complete |
| Keyboard | Tap outside a field | Keyboard closes | edge |
| Date fields | Typing a full day | Focus moves to month, then year | — |

## Gender and pronouns (OB-08)

| Case | Expected | Test |
|---|---|---|
| No gender | Next disabled, "Choose one to continue" | flow |
| Fifth pronoun | Ignored; other chips unavailable at 4/4 | ctrl |
| Gender changed after a detail was chosen | Detail cleared | — |
| Pronouns hidden | Not shown on the review or profile card | — |

## Who to meet and intentions (OB-09, OB-10)

| Case | Expected | Test |
|---|---|---|
| Nothing picked | Next disabled, "Pick at least one" | flow |
| All three groups picked | Treated as Everyone | ctrl |
| Last group untoggled | Back to "no answer" (Next disabled) | ctrl |
| Age range under 2 years | Slider refuses the move | — |
| Range default | Own age −5 to +7, kept on later visits | flow (`dating_test` filters: 26–38 for a 31-year-old) |
| Third intention | Ignored; third option unavailable | ctrl, flow captures (`o11`) |

## Height (OB-11)

| Case | Expected | Test |
|---|---|---|
| Not added | Next allowed; "You can skip this" | flow |
| Units | 170 cm = 5′ 7″ | complete |
| Minimum or maximum | − disabled at 140, + disabled at 210 | complete |
| Skip after adding | Height cleared | complete |

## Location (OB-12, OB-13)

| Case | Expected | Test |
|---|---|---|
| First ask | Labelled stand-in prompt (approximate, precise, don't allow) | complete |
| Denied once | "Location is off" banner; Try again | complete |
| Denied twice | "Location is blocked" banner; Use my location hidden; Open settings shows the demo message | complete |
| Approximate granted | Sample area set, labelled "(sample area)"; no coordinates stored | complete |
| Manual area | Search; "No areas match…"; pick | complete |
| Skipped | Next allowed; area "Not set" on the review | flow |

## Photos (OB-14)

| Case | Expected | Test |
|---|---|---|
| 0 or 1 photo | Next disabled | flow |
| Sixth photo | + hidden (grid full) | ctrl (cap at 6) |
| Camera denied | No photo added; banner points to the library | complete |
| Source sheet cancelled | Nothing changes | complete |
| Reorder, make main, remove, replace | As in Edit profile | `photo_options_test` |
| Back to Photos from Interests | Photos kept | `photo_options_test`, edge |

## Interests (OB-15)

| Case | Expected | Test |
|---|---|---|
| Fewer than 3 | Next disabled, "Pick N more" | flow |
| Sixth pick | Ignored; unavailable | `v16_screens_test` |
| Search narrows | `ja` shows Jazz only | complete |
| No results | Message and Clear search | complete |

## Prompts (OB-16, OB-18)

| Case | Expected | Test |
|---|---|---|
| None answered | Next disabled | complete |
| Whitespace answer | Save disabled; counts as no answer | rules, `v16_screens_test` |
| 150 characters | Counter reaches 0; the field stops at 150 | `v16_screens_test` (counter) |
| Same question twice | "Already answered", unavailable | complete |
| Leave without Save | Nothing kept | complete |
| Three answered | "3 of 3 answered"; Add a prompt hidden | complete |

## Bio (OB-19)

| Case | Expected | Test |
|---|---|---|
| Whitespace only | Stored as empty; no preview | complete |
| Text | Trimmed; preview shown | complete, flow |
| 300 characters | Field stops; counter 0 | — |
| Skip | Bio cleared | — |

## Finish (OB-20 to OB-23)

| Case | Expected | Test |
|---|---|---|
| Verify now | Opens the simulated verification flow; back returns | complete |
| Maybe later or Skip | Step marked done; next step | complete |
| Notifications denied, then allowed | Message changes; push switches off, then on | complete |
| Review with missing items | Each named with a link; Create disabled | complete |
| Edit from the review | Continue returns to the review | complete |
| Create fails (Demo Hub › Simulate connection problems) | Error banner; draft kept; not signed up; retry works | complete |
| Double tap Create | One creation (`creating` guard) | complete |
| Back from All set | Home, never setup | complete |

## Navigation, resume, layout, motion

| Case | Expected | Test |
|---|---|---|
| Back from Interests to the first step | Every answer kept | edge |
| Android system back | One step back | edge |
| Leave setup and come back | The hub continues at the first unfinished step | complete |
| Deep link to a step (Demo Hub) | Opens; back returns to the hub | complete |
| App killed mid-setup | **Lost.** In memory only (OD-15) | — |
| 375 × 667 at 130% text | No layout error on any onboarding screen | a11y |
| Tap targets and labels | Pass on every onboarding screen | a11y |
| Reduced motion | Page transitions instant; confirm card sheet instant | motion (app-wide) |
| Real keyboard insets, TalkBack, real permission dialogs | Not tested: no Android device or SDK here | — |

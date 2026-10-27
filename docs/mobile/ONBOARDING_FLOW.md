# Onboarding flow

Source of truth: `docs/research/screen-specs.md` (Bumble reference, B-xx ids), `decision-log.md`, and the approved web
screens (`src/prototype/screens/*.jsx`, `src/flows/screens.jsx`), whose copy is reused word for word.

```
Welcome ──Create an account──▶ Phone ──▶ Verify ──▶ Setup hub ──▶ Basics ──▶ Interests + prompt ──▶ Photos ──▶ Home
   │                             ▲  │        │
   │                             │  └ Country sheet
   │                             └── Change number (number kept)
   └──I have an account──▶ Phone (sign-in copy) ──▶ Verify ──┬─ account with profile ──▶ Home ("You're signed in")
                                                             └─ no account ──▶ sheet: Create an account │ Use a different number
```

Progress in the top bar (sign-up only): Phone 1 · Verify 2 · Basics 3 · Interests 4 · Photos 5 of 5. The web prototype
used 4 segments on the phone steps and 6 on profile steps; Flutter uses one consistent count.

## Screens and states

| Screen | Spec | Rules | States covered |
|---|---|---|---|
| Welcome | B-02 | No fields. Terms / Privacy open a sheet (documents not yet published). Hero slot left empty until artwork exists (D: no fake art). | default, demo badge in development builds |
| Phone | B-04 | Number field auto-focused, numeric keypad, formatted per country; next disabled until complete; changing country trims digits | empty, typing, valid, submitting (busy toast, input locked), error (unusable number, offline, sign-in unavailable) |
| Country sheet | B-05 | 14 countries with ISO badge and dial code, search by name / ISO / dial code | list, filtered, no results, selected tick |
| Verify | B-07 | 6 cells, paste and SMS autofill (`oneTimeCode`), auto-check at 6 digits, wrong code clears after 650 ms, 5 wrong tries expire the code, resend after 30 s, "Change number" | empty, partial (active cell + caret), checking, incorrect, expired, success, resend countdown, resend available, new code sent |
| No account sheet | B-03 (Numaya form) | Sign-in found no profile for the number | create, use another number |
| Setup hub | B-21 (Numaya form) | "You're verified" + three steps; first step not done is "Up next" | 0–3 done, button label and caption follow |
| Basics | B-10/B-11 | First name; birth year (18–100, digits only); gender (radio); looking for (checkbox, up to 2) | empty, partial, underage error, unrealistic year, complete; edit mode |
| Interests + prompt | B-17, B-27 | 3–5 interests, taps past 5 ignored (others shown unavailable, counter "5/5 SELECTED"); one prompt answer up to 150 characters required ("Three interests and one answer") | pick N more, answer prompt, N/5, maximum reached, prompt empty / answered; edit mode |
| Prompt editor ("YOUR PROMPT" screen, as V16) | B-27 | 6 questions, "N characters left", Save disabled until an answer exists and something changed | write an answer to save, no changes yet, saved hint |
| Photos | B-15, V16 104 | Minimum 2, recommended 4, maximum 6; first is "Main"; tap a photo for options: Make main photo (not on the main one), Remove; in Edit profile removing below 2 is refused with "Keep at least 2 photos" | 0–6 photos, captions follow, options sheet, cancel; edit mode |
| Home shell | B-30, B-42, B-46, B-23 | Four tabs, badges for unanswered likes and unopened matches | Home: labelled sample profiles; Likes, Messages: see [SCREEN_INVENTORY.md](SCREEN_INVENTORY.md) C; Profile: the member's own data |
| Filters | B-34 | Age 18–80 range, distance 1–160 km; the button counts the sample profiles that fit ("Show 5 people") | saved toast, reset, none fit |
| Edit profile | B-24 | Reuses Basics, Interests and Photos; leaving without saving restores the profile | saved toast |
| Settings | B-70 | Phone number, snooze, notification switches (session only), blocked people, prototype tools (demo builds), sign out, delete account with confirmation | snooze on/off, cancel and confirm delete |

## Deviations from the web prototype (deliberate)

| Prototype | Flutter | Reason |
|---|---|---|
| Profile pre-filled with "Alex, 1995…" | Starts empty | Real onboarding |
| Interests step requires only interests | Also requires the prompt answer | Setup step copy promises "Three interests and one answer" |
| "+" adds a sample photo | Adds a placeholder tile and says so | No upload service; no stock people |
| Discover shows sample people | Also shows sample people, each badged "Sample profile", with a footnote | PRODUCT.md: mock data labelled as such |
| Activity tab | Not built | Not part of the onboarding brief; needs real events data |
| Seeded matches and replies; "Delivered" | A new account has no matches; messages say "Demo · saved on this device, not sent"; no replies | Never claim delivery or a real match |
| Paywall | Not built | Business decision (P-05) |

## Demo sign-in (development builds only)

- Shows the "texted" code in a banner at the top of Verify ("Demo text message"); tapping it fills the code like SMS
  autofill.
- Rejects numbers whose digits are all the same (e.g. `000 000 0000`) to show the error state.
- Accounts exist only in memory: sign up, finish the profile, sign out, then "I have an account" with the same number
  to see the returning-member path.
- Never present in release builds (compile-time guard, see ARCHITECTURE.md).

## Keyboard, back navigation and edge cases (tested)

| Case | Behaviour | Test |
|---|---|---|
| Under 18, then corrected | Inline error, Next disabled, fixed in place (C-2 in the inventory) | `onboarding_edge_cases_test` |
| Unrealistic year (e.g. 1850) | "Enter a real year, like 1995." | same |
| Back from Interests, then forward | Basics keeps name, year, gender; Interests keeps picks | same |
| Android system back between steps | Pops one step | same |
| Tap outside a field | Dismisses the keyboard (`NumayaScreen`) | same |
| Sixth interest | Unavailable at 5/5 | `v16_screens_test` |
| Prompt Save | Disabled until written, "No changes yet." when reopened | `v16_screens_test` |
| Photos below 2 | Next disabled until 2 again | `photo_options_test` |
| Full sign-up, wrong code, underage, prompt, photos | Welcome to Home and Profile | `onboarding_flow_test` |
| Every onboarding screen | Tap-target and label guidelines; 375 × 667 at 130% text without overflow | `accessibility_test` |

Not covered: a real keyboard on hardware (the footer above the keyboard is only checked in widget tests),
resuming after the app is killed (deferred, inventory C-7).

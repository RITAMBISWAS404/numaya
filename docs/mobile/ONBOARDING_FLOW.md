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
| Interests + prompt | B-17, B-27 | 3–5 interests, taps past 5 ignored (others shown unavailable); one prompt answer up to 150 characters required ("Three interests and one answer") | pick N more, answer prompt, N/5, maximum reached, prompt empty / answered; edit mode |
| Prompt editor | B-27 | 6 questions, answer counter, save disabled until an answer exists | — |
| Photos | B-15 | Minimum 2, recommended 4, maximum 6; first is "Main"; remove any | 0–6 photos, captions follow; edit mode |
| Home shell | B-30, B-42, B-46, B-23 | Four tabs | Home, Likes, Messages: honest empty states; Profile: the member's own data |
| Filters | B-34 | Age 18–80 range, distance 1–160 km | saved toast, reset |
| Edit profile | B-24 | Reuses Basics, Interests and Photos; leaving without saving restores the profile | saved toast |
| Settings | B-70 | Phone number, notification switches (session only), sign out, delete account with confirmation | — |

## Deviations from the web prototype (deliberate)

| Prototype | Flutter | Reason |
|---|---|---|
| Profile pre-filled with "Alex, 1995…" | Starts empty | Real onboarding |
| Interests step requires only interests | Also requires the prompt answer | Setup step copy promises "Three interests and one answer" |
| "+" adds a sample photo | Adds a placeholder tile and says so | No upload service; no stock people |
| Discover shows sample people | Empty state saying matching isn't connected | Don't present mock people as real |
| Activity tab | Not built | Not part of the onboarding brief; needs real events data |
| Match, chat, report, paywall | Not built | Unreachable without a backend; building them would mean dead or fake screens |

## Demo sign-in (development builds only)

- Shows the "texted" code in a banner at the top of Verify ("Demo text message"); tapping it fills the code like SMS
  autofill.
- Rejects numbers whose digits are all the same (e.g. `000 000 0000`) to show the error state.
- Accounts exist only in memory: sign up, finish the profile, sign out, then "I have an account" with the same number
  to see the returning-member path.
- Never present in release builds (compile-time guard, see ARCHITECTURE.md).

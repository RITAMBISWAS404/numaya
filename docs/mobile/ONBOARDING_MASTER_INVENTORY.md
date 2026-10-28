# Onboarding master inventory

The definitive checklist for Numaya's onboarding, from first launch to the first Home screen. Branch
`experiment/numaya-onboarding-complete` (from `experiment/numaya-android12-compat` @ `e5184e1`).

- Edge cases: [ONBOARDING_EDGE_CASES.md](ONBOARDING_EDGE_CASES.md).
- What was built and tested: [ONBOARDING_IMPLEMENTATION_REPORT.md](ONBOARDING_IMPLEMENTATION_REPORT.md).
- Captures: [ONBOARDING_VISUAL_QA.md](ONBOARDING_VISUAL_QA.md).

## Counting rules

- **Screens** are distinct pages or sheets with their own purpose. Their loading, error, empty, permission
  and success variants are **states**. States are listed per screen and counted separately.
- **Classification:** **Required** blocks finishing; **Recommended** is in the flow but can be skipped;
  **Optional** is skippable and not needed to start; **Post-onboarding** lives in the app (Edit profile,
  Settings) and is not in the sign-up flow.
- **Evidence labels:** **[O]** observed in a Mobbin capture; **[D]** officially documented (product help
  pages, as cited in `docs/research/`); **[I]** inferred; **[U]** unverified. A screen missing from Mobbin
  is not evidence that a screen doesn't exist.

## Mobbin research used (this pass)

All iOS. Mobbin's library had no Android captures for these apps.

| App | Flow (Mobbin) | Screens | What it showed |
|---|---|---|---|
| Hinge | [Onboarding](https://mobbin.com/flows/5a57eafe-09b8-45c5-b02a-fff23bfd8b7d) | 25 | Consent line on Welcome; email step; **birthday as three fields (MM DD YYYY) with a confirm card "You're 31 · Born … · Make sure your age is correct · Edit / Confirm"**; "Here's how some of what you share will appear" (per-field visibility preview); **height wheel with FT/CM toggle, "Always visible on profile"**; **"Who are you open to dating?" (Men, Women, Nonbinary people, Everyone; "Hidden on profile")**; Work (optional, "Visible on profile" checkbox); interstitial "Now let's bring your profile to life with photos and Prompts"; "Pick Prompts" with writing tips; **Face Check consent** (biometric, "required in your region") [O] |
| Hinge | [Pronouns screen](https://mobbin.com/screens/cc96b236-9a92-4603-bd8b-7dc84b72fcd9) | 1 | **"What are your pronouns? Optional. Pick up to 4"**, chips of the picks, "Visible on profile" [O] |
| Hinge | [Location](https://mobbin.com/screens/ebca8465-5168-420c-a00e-aa4fe21c8e92) | 1 | "Where do you want to meet people?", map pin, locate button, address field; **"Only the neighborhood will appear on your profile"** [O] |
| Hinge | [Notifications banner](https://mobbin.com/screens/19fdb096-1bda-4abf-b7e2-5e1926c980f4) | 1 | Asks for push in context (Matches tab banner "Enable"), not at sign-up [O] |
| happn | [Onboarding](https://mobbin.com/flows/38cae6c2-5cf0-42ca-882a-e542fe20f88e) | 25 | Single-field code entry with a call-back fallback after 2 minutes; date of birth wheel; gender (two options, "change later by contacting customer service"); "I'm based in…"; favourite Spots (Skip); **interests "My selection 0/10" by category with "See more"** (Skip); "Do you have kids?" (Skip); **"Add your first 2 photos"** (6 slots, advice link); **"Move and zoom to reframe your photo"** crop [O] |
| happn | [Location primer](https://mobbin.com/screens/14ac5002-d0be-4c0a-829d-764041bafff9) and [system prompt](https://mobbin.com/screens/73f537c3-4950-4f97-8247-81877dccc2a4) | 2 | **Primer first** ("Select 'Allow only while using the app'… your exact location is never revealed"), then the iOS prompt (Allow Once / While Using / Don't Allow) [O] |
| happn | [City fallback](https://mobbin.com/screens/11d82a94-4aca-4267-9f64-88fe2d8d29f4) | 1 | **"Find Crushes in your city: Enter your city of residence"**, Skip [O] |
| happn | [Adding photos](https://mobbin.com/flows/6db2ec9b-039e-4e75-8e8d-9974ae0c63be) | 6 | Picker → crop → grid [O] |
| Bumble | [Onboarding](https://mobbin.com/flows/42730eed-79ec-4019-91b2-c65cdef86851) | 20 | Country search, verify by SMS and by call, tracking pre-prompt; **interests "Choose 5 things you're really into", search "What are you into?", "You might like…", Skip, "0/5 selected"** [O] |
| Bumble | [Completing an account setup](https://mobbin.com/flows/795ff2ae-e5a9-4684-a24c-cdd2ea4bce63) | 10 | Relationship status (BFF), mode intro [O] |
| Bumble | [Location](https://mobbin.com/screens/07fc8e08-812f-45eb-8458-536dbe569d1a), [notifications](https://mobbin.com/screens/be42614b-6115-4fe0-ac7b-4ef7f7954397) | 2 | "Now, can we get your location?" → "Set location services"; **"Don't miss a beat, or a match" → "Allow notifications" / "Not now"** [O] |
| Earlier passes | `docs/research/flow-catalogue.md` B-01–B-28, B-50–B-57 | — | Bumble intro, gender detail sheet (B-12), show gender (B-13), intentions (B-20), photos (B-15), photo verification (B-55–B-57) |

**Limitations:**
- No Android captures exist for these apps.
- Hinge's and happn's photo-verification capture screens beyond the consent were not captured in these
  flows [U].
- What happens after a denied location or notification prompt is not captured for any of the three apps
  [U]. Numaya's handling follows Android's own behaviour (a second denial stops the prompt).

## Decisions taken for this pass

All are configurable in `OnboardingRules` / `ProfileRules` / `DetailRules`.

| # | Decision | Value | Why |
|---|---|---|---|
| OD-1 | Minimum age | 18, no bypass once confirmed | Dating service; existing `ProfileRules.minAge` and decision C-2 |
| OD-2 | Date of birth | Full date (day, month, year) replaces birth year; age derived; only the age is shown publicly | Hinge "We'll only show your age" [O]; a year alone can't decide 18 |
| OD-3 | Age confirmation | Confirm card before continuing. Confirming an age under 18 locks the account for this session | Hinge confirm card [O]; prevents a "try again with another year" bypass |
| OD-4 | Pronouns | Optional, up to 4, visible by default with a switch | Hinge [O] |
| OD-5 | Who you want to meet | Women / Men / Nonbinary people / Everyone, at least one; hidden on profile; sets the Discovery filter | Hinge [O]; existing filter model |
| OD-6 | Height | Optional, 140–210 cm, cm or ft/in display | Hinge [O]; existing `DetailRules` |
| OD-7 | Location | Optional. Primer, then the system prompt (simulated), approximate area only, manual area fallback, skip | happn primer and city fallback [O]; no location plugin in this build |
| OD-8 | Photos | Minimum 2, recommended 4, maximum 6 (unchanged) | Existing `ProfileRules`; happn "Add your first 2 photos" [O] |
| OD-9 | Interests | 3 to 5, with search | Existing rule; Bumble search [O] |
| OD-10 | Prompts | At least 1, up to 3, no duplicate questions | Hinge "Pick Prompts" [O]; existing `DetailRules.maxPrompts` |
| OD-11 | Bio | Optional, up to 300 characters | Existing `DetailRules.bioLength` |
| OD-12 | Photo verification | Offered, skippable, simulated and labelled | Bumble B-55 [O]; Hinge requires Face Check only "in your region" [O]; no verification service |
| OD-13 | Notifications | Primer near the end, optional, never blocks finishing | Bumble "Not now" [O] |
| OD-14 | Progress | Five sections in the top bar (Account, About you, Looking for, Your profile, Finish) | Fifteen segments don't fit a phone header |
| OD-15 | Resume | Kept for the session; not across an app restart | Architecture rule: no personal data in plain local storage, and no secure store in this build |

## Final order

```
OB-01 Welcome ─▶ OB-02 Phone (OB-03 country sheet) ─▶ OB-04 Code ─▶ OB-05 Setup hub
 About you:   OB-06 Name and birthday (confirm card; OB-07 Under 18) ─▶ OB-08 Gender and pronouns (OB-08a detail sheet)
 Looking for: OB-09 Who you want to meet ─▶ OB-10 Intentions ─▶ OB-11 Height ─▶ OB-12 Location (OB-13 area sheet)
 Your profile: OB-14 Photos (OB-14a source sheet, OB-14b tips) ─▶ OB-15 Interests ─▶ OB-16 Prompts (OB-17 question picker, OB-18 answer editor) ─▶ OB-19 Bio
 Finish:      OB-20 Verify your photos (→ simulated verification) ─▶ OB-21 Notifications ─▶ OB-22 Review ─▶ OB-23 All set ─▶ Home
 Returning:   OB-01 ─▶ OB-02 (sign-in copy) ─▶ OB-04 ─▶ Home, or OB-24 No-account sheet
```

## Screens

Columns:
- **Class:** R required, Rec recommended, Opt optional.
- **Exists:** E existed and unchanged, I existed and improved, N new.
- **Tests:** files in `apps/numaya_mobile/test/`.

### Account (section 1)

**OB-01 Welcome** · R · I · `/`
- **Purpose:** choose to create an account or sign in. **Evidence:** B-02 [O]; Hinge consent line [O].
- **Fields and controls:** Create an account, I have an account, Terms and Privacy links, Demo build badge
  (development builds only; opens the Demo Hub).
- **Rules:** no permission or personal data is asked for here.
- **States:** default; large text scrolls.
- **Navigation:** Back leaves the app.
- **Accessibility:** heading, labelled links, 48 dp targets.
- **Tests:** `onboarding_flow_test`, `accessibility_test`.

**OB-02 Phone number** · R · E · `/phone`
- **Purpose:** identify the account by phone. **Evidence:** B-04 [O].
- **Fields and controls:** country picker, number field (numeric, formatted).
- **Rules:** Next is disabled until the number is valid for the country; changing country trims digits.
- **States:** empty, typing, valid, submitting (busy toast, input locked), invalid number, offline, sign-in
  unavailable.
- **Navigation:** Back to Welcome keeps nothing.
- **Accessibility:** autofocus, numeric keyboard, error announced.
- **Tests:** `onboarding_flow_test`.

**OB-03 Country sheet** · R (supporting) · E · sheet
- **Evidence:** B-05 [O]; Bumble country search [O].
- **Fields and controls:** search, 14 countries.
- **States:** list, filtered, no results, selected.
- **Navigation:** Close keeps the previous country.
- **Tests:** `onboarding_flow_test`.

**OB-04 Verification code** · R · E · `/verify`
- **Purpose:** prove the number. **Evidence:** B-07a [O]; happn code [O].
- **Fields and controls:** 6 cells (paste, SMS autofill), resend, Change number. In development builds a
  banner shows the demo code: no SMS is sent.
- **Rules:** auto-check at 6 digits; 5 wrong tries expire the code; resend after 30 s.
- **States:** empty, partial, checking, incorrect (shake and reject haptic), expired, success, resend
  countdown, resend available, new code sent, offline.
- **Navigation:** Change number returns with the number kept.
- **Tests:** `onboarding_flow_test`.

**OB-24 No account found (sign-in)** · R (supporting) · E · sheet
- **Fields and controls:** Create an account, Use a different number.
- **Tests:** `onboarding_flow_test`.

**OB-05 Setup hub** · R · I · `/setup`
- **Purpose:** show what's left and resume. **Evidence:** B-21 [O] (Numaya form).
- **Fields and controls:** four sections (About you, Looking for, Your profile, Finish) with status;
  Build / Continue.
- **Rules:** Continue opens the first unfinished step.
- **States:** 0–4 sections done; age-locked accounts are sent to OB-07.
- **Tests:** `onboarding_complete_test`.

### About you (section 2)

**OB-06 Name and birthday** · R · N (replaces part of Basics) · `/setup/name`
- **Purpose:** first name and date of birth. **Evidence:** B-10 [O]; Hinge birthday and confirm card [O].
- **Fields and controls:** first name (given-name autofill, words capitalised, max 30); day, month, year
  (digits, next-field focus); derived "You're N" hint; Continue.
- **Rules:**
  - Name is trimmed, must not be empty, and allows letters, spaces, hyphens and apostrophes in any script
    (no digits or emoji).
  - The date must be real (31 Feb is refused) and not in the future.
  - Age 18–100. Under 18 shows an inline note; Continue asks for confirmation.
- **States:** empty, partial, invalid date, future date, unrealistic age, under 18 (inline), confirm card
  (age and date, Edit / Confirm), confirmed.
- **Navigation:** Back to the hub keeps the values.
- **Accessibility:** each date field labelled ("Day", "Month", "Year"); the error is announced; the
  keyboard's Next moves between fields.
- **Tests:** `onboarding_complete_test`, `onboarding_rules_test`.

**OB-07 Under 18** · R · N · `/setup/underage`
- **Purpose:** stop an underage person, without a way back in. **Evidence:** OD-1/OD-3 [I].
- **Fields and controls:** explanation, Help centre link, Sign out.
- **Rules:** once the age is confirmed, every route goes here until sign-out.
- **States:** single.
- **Navigation:** system back stays here.
- **Tests:** `onboarding_complete_test`.

**OB-08 Gender and pronouns** · R (gender) / Opt (detail, pronouns) · N · `/setup/gender`
- **Evidence:** B-11, B-12, B-13 [O]; Hinge pronouns [O].
- **Fields and controls:** Woman, Man, Nonbinary (radio); "Add more about your gender" (opens OB-08a);
  pronouns (up to 4, chips); "Show gender on profile" and "Show pronouns on profile" switches.
- **Rules:** gender required; pronouns optional, max 4; the detail resets when gender changes.
- **States:** none chosen, chosen, detail chosen, pronouns at maximum (others unavailable).
- **Tests:** `onboarding_complete_test`.

**OB-08a Gender detail sheet** · Opt · I (existed in Edit profile) · sheet
- **Fields and controls:** identities for the chosen gender, "None of these".
- **Navigation:** Close keeps the previous choice.

### Looking for (section 3)

**OB-09 Who you want to meet** · R · N · `/setup/meet`
- **Evidence:** Hinge "Who are you open to dating?" [O].
- **Fields and controls:** Women, Men, Nonbinary people, Everyone (multi-select; Everyone clears the
  others); age range (18–80); "Hidden on profile" note.
- **Rules:** at least one; minimum age ≥ 18 and range ≥ 2 years.
- **States:** none, some, everyone.
- **Saves to:** Discovery filters.
- **Tests:** `onboarding_complete_test`.

**OB-10 Relationship intentions** · R · I (was in Basics) · `/setup/intentions`
- **Evidence:** B-20 [O].
- **Fields and controls:** Long-term, Open to either, Something casual (up to 2).
- **States:** none, one, two (others unavailable).
- **Tests:** `onboarding_complete_test`.

**OB-11 Height** · Opt · N · `/setup/height`
- **Evidence:** Hinge height wheel and FT/CM [O].
- **Fields and controls:** − / + steppers and slider (140–210 cm); cm or ft/in; Skip.
- **States:** not set, set, minimum, maximum.
- **Saves to:** profile details.
- **Tests:** `onboarding_complete_test`, `onboarding_rules_test`.

**OB-12 Location** · Opt · N · `/setup/location`
- **Evidence:** happn primer and prompt [O]; Bumble "Set location services" [O]; Hinge "only the
  neighborhood" [O].
- **Fields and controls:** why location helps; Use my location; Choose my area instead; Skip.
- **Rules:**
  - Asks only after the explanation.
  - Only an area name is kept, never coordinates.
  - This build has no location service: "Use my location" opens a clearly labelled stand-in for Android's
    prompt, and a granted result sets the **sample** area and says it wasn't read from the phone.
- **States:** not asked; asking; granted (approximate); granted (precise, still stored as an area); denied
  (retry and manual); permanently denied (Open settings stand-in and manual); manual area chosen; skipped.
- **Tests:** `onboarding_complete_test`.

**OB-13 Area sheet** · Opt · N · sheet
- **Fields and controls:** search areas; list.
- **States:** list, filtered, no results.

### Your profile (section 4)

**OB-14 Photos** · R · I · `/setup/photos`
- **Evidence:** B-15, happn "first 2 photos" and crop [O].
- **Fields and controls:** 6 slots; + opens OB-14a; tap a photo for Make main, Move earlier/later,
  Replace, Remove; photo tips (OB-14b).
- **Rules:** 2 required, 4 recommended, 6 maximum; the first is Main.
- **States:** 0–6 photos; camera denied (banner with library fallback); picker cancelled (nothing
  changes); full (+ hidden).
- **Note:** a placeholder tile stands in for the image: no picker or upload in this build.
- **Tests:** `photo_options_test`, `onboarding_complete_test`.

**OB-14a Add photo sheet** · R (supporting) · N · sheet
- **Fields and controls:** Take a photo, Choose from library, Cancel.
- **Rules:** camera asks for permission (simulated) the first time.
- **States:** camera allowed, denied, permanently denied.

**OB-14b Photo tips sheet** · Rec · N · sheet
- **Content:** clear face, recent, just you in the first photo, no group as Main. Guidance only, not
  automatic checks.

**OB-15 Interests** · R · I · `/setup/interests`
- **Evidence:** B-17, Bumble search, happn categories [O].
- **Fields and controls:** search; three categories of chips; "N/5 selected".
- **Rules:** 3 to 5; taps past 5 are ignored and other chips show unavailable.
- **States:** pick N more, valid, maximum, search results, no results (with clear search).
- **Tests:** `v16_screens_test`, `onboarding_complete_test`.

**OB-16 Prompts** · R · N · `/setup/prompts`
- **Evidence:** Hinge "Pick Prompts" [O].
- **Fields and controls:** three slots (first required); a filled slot opens its answer; an empty slot
  opens OB-17; remove (slots 2–3).
- **Rules:** at least 1, up to 3; no question twice.
- **States:** 0, 1, 2, 3 answered.
- **Tests:** `onboarding_complete_test`.

**OB-17 Question picker** · merged into OB-18
- The answer editor already listed the six questions, so the picker is that list rather than a separate
  sheet. Questions used in another slot show "Already answered" and are unavailable.
- Not counted as a screen.

**OB-18 Answer editor** · R (supporting) · I · `/setup/prompt?slot=` (and `/profile/edit/prompt`)
- **Fields and controls:** question (change), answer (multiline, 150 characters), counter, Save, back.
- **Rules:** Save is disabled while the answer is empty or unchanged; whitespace is trimmed; leaving
  without Save discards the change.
- **States:** empty, writing, at limit, no changes yet, saved.
- **Tests:** `v16_screens_test`, `onboarding_complete_test`.

**OB-19 Bio** · Opt · N · `/setup/bio`
- **Fields and controls:** multiline field, counter (300), writing tips, preview line; Skip.
- **Rules:** trimmed; whitespace-only counts as empty.
- **States:** empty, writing, at limit.
- **Tests:** `onboarding_complete_test`.

### Finish (section 5)

**OB-20 Verify your photos** · Opt · N (entry) + existing simulated flow · `/setup/verify` → `/profile/verify`
- **Evidence:** B-55–B-57 [O]; Hinge Face Check consent [O].
- **Fields and controls:** why verify, what happens to the selfie, Verify now, Maybe later.
- **Rules:** the result is simulated and labelled ("Demo"); it never marks a real account verified.
- **States:** not started, pending, verified, not approved (retry), later.
- **Tests:** `onboarding_complete_test`, `full_app_journeys_test`.

**OB-21 Notifications** · Opt · N · `/setup/notifications`
- **Evidence:** Bumble "Don't miss a beat" [O].
- **Fields and controls:** what you'd be told about; Allow notifications; Not now.
- **Rules:** never blocks finishing. A labelled stand-in for Android 13+'s prompt; the choice sets the
  in-app notification switches.
- **States:** not asked, allowed, denied, permanently denied (Settings stand-in), not now.
- **Tests:** `onboarding_complete_test`.

**OB-22 Review your profile** · R · N · `/setup/review`
- **Evidence:** Hinge "Here's how what you share will appear" [O]; B-21 [O].
- **Fields and controls:**
  - checklist of required items, each with Edit;
  - the profile as others see it (photos in order, name and age, gender and pronouns if shown, height,
    area, intentions, bio, interests, prompts);
  - private settings (who you want to meet, age range), marked "Only you see this";
  - verification status;
  - Create my profile.
- **Rules:** Create is disabled while a required item is missing, and each missing item is named. One tap
  creates; repeated taps are ignored.
- **States:** missing items, ready, creating (busy), failed (retry; simulated in the Demo Hub).
- **Tests:** `onboarding_complete_test`.

**OB-23 All set** · R · N · `/setup/done`
- **Content:** "You're all set, {name}", what happens next, Start discovering (to Home).
- **Rules:** back goes to Home, never into setup again.
- **Tests:** `onboarding_complete_test`.

## Counts

| | Count | IDs |
|---|---|---|
| Required screens | 14 | OB-01, 02, 04, 05, 06, 07, 08, 09, 10, 14, 15, 16, 22, 23 |
| Required supporting sheets and editors | 4 | OB-03, 14a, 18, 24 |
| Optional or recommended screens | 6 | OB-11, 12, 14b, 19, 20, 21 |
| Optional sheets | 2 | OB-08a, OB-13 |
| **Total screens** | **26** | OB-17 is part of OB-18 |
| Post-onboarding (in the app, not in sign-up) | — | Edit profile (Basics now edit-only, with the birthday read-only), completion hub, Opening Moves, more details, Settings |
| **States** across the screens above | **109** | Counted from each screen's States list |

Status, as built on this branch:
- **New:** 16 screens (OB-06, 07, 08, 09, 10, 11, 12, 13, 14a, 14b, 16, 19, 20, 21, 22, 23), plus the
  merged OB-17 behaviour.
- **Improved:** 5 (OB-01, 05, 14, 15, 18).
- **Unchanged:** 5 (OB-02, 03, 04, 08a, 24). OB-08a's sheet existed in Edit profile and is reused.

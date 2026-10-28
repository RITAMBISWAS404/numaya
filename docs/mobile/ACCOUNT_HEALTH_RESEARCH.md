# Account health and visibility research

Research for **Profile & visibility**, Numaya's account-health dashboard. Metrics and formulas are in
[ACCOUNT_HEALTH_METRICS.md](ACCOUNT_HEALTH_METRICS.md); QA is in
[ACCOUNT_HEALTH_QA_REPORT.md](ACCOUNT_HEALTH_QA_REPORT.md).

**Evidence labels:**
- **[O]** observed in a Mobbin capture;
- **[D]** documented in this repository;
- **[P]** a public product statement that was actually read;
- **[I]** inferred;
- **[U]** unverified.

## Sources

**First-party pages: none could be opened.**
- These failed to resolve: the network policy of this session blocks those hosts:
  - Hinge "What is Signals" (`help.hinge.co`);
  - Hinge "How we connect daters" (`hinge.co`);
  - Tinder "My profile is hidden" (`help.tinder.com`).
- Bumble's guidelines (`bumble.com`) were not attempted after those failures.
- **Nothing below is quoted from them**, and nothing about their ranking systems is stated as fact. Allowing those hosts in the
  environment's network settings would let a later pass check this document against them.

**Repository:**
- `docs/product/numaya-feature-expansion-spec.md` §7 "Profile readiness": scored from visible profile
  elements only; verification shown separately and never scored; "Nothing about attractiveness,
  replies, unmatches or visibility is scored"; Active / Paused from Snooze, shown apart from the score.
  **[D]**
- The Flutter app's existing pieces:
  - profile completion (`ProfileCompletion`, the Profile tab ring and the completion hub);
  - Snooze;
  - Incognito (Premium);
  - simulated photo verification;
  - the moderation-block screen with appeal (`/account-blocked`). **[D]**

**Mobbin (iOS):**

| App | Screen | Observed |
|---|---|---|
| Hinge | [Profile tab with Signals card](https://mobbin.com/screens/e341f5d7-d9df-4ecf-aa2f-d2fd524edbaf) | "Signals · Be seen for how you connect · Check your Signals"; tabs Get more / Safety / My Hinge [O] |
| Hinge | [Your Signals](https://mobbin.com/screens/18a2766f-21cb-4cf0-9553-c6764eed1427) | "Your badge is active. You've engaged with thoughtfulness and followed things through on Hinge." "Your badge reflects your activity over the past **30 days**. When **4 of these** are met, it becomes active." Criteria shown as tiles: **Selfie Verification** ("You're verified"), **Move forward** ("A match confirmed as 'We Met', or the chat moved off Hinge") [O] |
| Hinge | [Settings: Pause](https://mobbin.com/screens/fd70e2d2-81d3-4808-8d4b-efc87e0e6662) | "Pause · Pausing prevents your profile from being shown to new people. You can still chat with your current matches." Selfie Verification "You're not verified yet" [O] |
| Tinder | [Paused Discover](https://mobbin.com/screens/dc1a56d1-25a2-487f-8cd1-1d97c2f7a314) | "You're on pause… and your profile is hidden. You can't Like new people, but whenever you're ready… just unpause your account." · Jump back in [O] |
| happn | [Pause mode](https://mobbin.com/screens/e8071571-0eb1-4cb5-a058-f615fb144880) | Pause makes you "totally invisible to other happners until the next time you log in"; data is kept; Pause vs Delete [O] |
| Plenty of Fish | [Take a break](https://mobbin.com/screens/b7fee2f0-0b2e-4c9b-9854-dd7dbc140da6) | Break length; "Your profile will be visible again on Mar 12" [O] |
| Badoo | [Invisible mode](https://mobbin.com/screens/5f724d4b-b82b-44c8-886b-9ec5bd333684) | Each visibility switch says exactly what others won't see [O] |
| Bumble | Completing a profile (earlier pass, FULL_APP_SCREEN_INVENTORY) | Completion ring with a percentage on the Profile tab [O] |

**Not found [U]:**
- a competitor screen that tells members their profile is hidden by moderation;
- an engagement-analytics screen (views, likes over time) in these dating apps.

## What the evidence supports

1. **Visibility caused by a setting is stated plainly, with the undo next to it** (Hinge, Tinder,
   happn, Plenty of Fish [O]). Numaya:
   - says "Paused: new people can't see you" with **Resume**;
   - when Snooze has an end, gives the date it ends.
2. **Criteria-based status is shown as the criteria themselves**, not a hidden score (Hinge Signals:
   named criteria, a stated window, a stated threshold [O]). Numaya shows each check by name with
   its rule. There is **no combined health score**.
3. **Completeness as a percentage is common** (Bumble [O]) and Numaya already has one built from the member's
   own entries. The dashboard reuses it unchanged, so the Profile tab and the dashboard always agree.
4. **Verification is a separate state** (Hinge [O]; spec §7 [D]): Not started / In review / Verified /
   Not approved. It is never folded into completeness.

## What Numaya deliberately does not do

- **No shadowban detection, risk percentage or "visibility score."** Numaya can't see anyone's
  ranking (its own demo has none), and a drop in likes has many ordinary causes:
  - fewer people in range;
  - your filters;
  - time of year;
  - who is using the app.
- **No claim of being deprioritised or penalised** unless a trusted Numaya service sends that status.
  In this build that source is a labelled demo source, and a failed check shows **"Can't check right
  now"**, never an all-clear.
- **No inference from engagement.** Likes and matches are shown as counts with their period. Low
  numbers say nothing about the person or their account, and no metric is presented as a cause.
- **No nudges to swipe more, like more or message more.** Breaks are fine; a paused account is
  described as a choice, not a problem.
- **Events don't change dating visibility.** No rule links them, so the dashboard doesn't suggest one.
- **No enforcement thresholds or detection details.** Notices link to community guidelines and the
  existing appeal screen only.

## Product decisions

| # | Decision |
|---|---|
| AH-1 | Name: **Profile & visibility**. "Health" can read as a judgement of the person; this name says what it covers |
| AH-2 | Entry points: a row on the Profile tab with the current visibility status, and a row in Settings › Account. Recommendations deep-link to the existing editors and settings |
| AH-3 | Sections: Visibility · Profile completeness · Discovery setup · Verification · Account notices · Your activity (counts) · Suggestions · How this works |
| AH-4 | Statuses (each from a named source, see METRICS): Visible · Paused · Limited (Incognito) · Action needed · Can't check · Not enough data · In review |
| AH-5 | Demo data is labelled on every section that uses it, and the "How this works" page says which sources are demo |
| AH-6 | Profile views and impressions are **not shown**: this build can't measure them. The section says so instead of inventing numbers |

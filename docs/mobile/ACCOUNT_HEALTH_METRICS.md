# Profile & visibility: metrics, rules and sources

Every value the **Profile & visibility** dashboard (`/profile/visibility`) shows, how it is worked out,
where its data comes from, when it updates and what it can't tell you.

- **Code:** `lib/features/account_health/`.
- **Research:** [ACCOUNT_HEALTH_RESEARCH.md](ACCOUNT_HEALTH_RESEARCH.md).

## Ground rules

1. **No combined score.** Each section has its own status from its own source. Nothing is averaged
   across sections.
2. **No ranking, shadowban or penalty is shown or inferred.** Only the notice source (§5) may say an
   account is hidden by Numaya, and only because that source says so.
3. **Unknown is shown as unknown.** If a source fails, its section says "Can't check right now"; the
   overall status never turns into an all-clear because data is missing.
4. **Every number has a period and a source label.** In this build the activity counts come from
   sample data and carry a **Sample data** badge.
5. **Recalculated on every change.** The dashboard reads live app state through Riverpod, so editing
   the profile, snoozing, resuming, verifying or changing filters updates it immediately. There is no
   cache.

## Data sources

| Source | Provider | Real or demo in this build | Future backend |
|---|---|---|---|
| Profile entries | `onboardingProvider` (draft), `profileDetailsProvider` | The member's own entries on this device | Profile service |
| Snooze | `accountPrefsProvider`, `datingProvider.snoozed` | The member's own setting on this device | Account settings service |
| Incognito | `premiumProvider` (`active && incognito`) | Own setting; Premium is simulated | Subscriptions and settings |
| Discovery filters | `discoveryFiltersProvider` | Own setting | Same |
| Sample deck size | `datingProvider` (`candidates`, `queue`) | **Demo:** the sample profiles | Not exposed by a real service (counts of real members in range would be a product decision) |
| Phone verification | `sessionProvider` (signed in with a code) | Simulated code | Auth service |
| Photo verification | `photoVerificationProvider` | **Simulated** review | Verification service |
| Account notices | `accountNoticesProvider` | **Demo source** (Demo Hub sets it) | Trust and safety service |
| Activity counts | `datingProvider` (likes, matches, threads) | **Demo:** sample likes, matches and messages | Analytics service |

## 1. Visibility (overall status)

**Inputs:**
- R = notice is `restricted`;
- P = paused;
- Q = Discover requirements not met (§2);
- U = notice source `unavailable`;
- I = Incognito on.

**Result:** the first rule that applies.

| Order | Condition | Status | What the card says |
|---|---|---|---|
| 1 | R | **Action needed** | "Numaya has hidden your profile from Discover." + the notice title; Review notice |
| 2 | P | **Paused** | "New people can't see you while you're paused." + end date when Snooze has one; Resume |
| 3 | Q | **Action needed** | "Your profile is missing something Discover needs." + the missing items |
| 4 | U | **Can't check** | "We couldn't check for account notices, so we can't confirm your visibility. Your own settings are shown below." Try again |
| 5 | I | **Limited** | "Incognito: only people you like can see you." Privacy settings |
| 6 | none | **Visible** | "Your profile can appear in Discover." (demo label: "Based on your settings and a demo notice source") |

"Visible" means none of the known blockers apply. It does **not** mean "shown to many people": the
card says that how often a profile is shown also depends on who is nearby and their preferences, which
this dashboard can't see.

## 2. Discover requirements

The same rules sign-up enforces (`ProfileRules`):

| Requirement | Rule | Action |
|---|---|---|
| Photos | `photos.length ≥ ProfileRules.minPhotos` (2) | Edit photos |
| Interests | `interests.length ≥ ProfileRules.minInterests` (3) | Edit interests |
| Prompt | at least one prompt answered (non-blank) | Edit prompt |
| Profile created | the sign-up review was completed (`session.hasProfile`) | Finish setup |

## 3. Profile completeness (%)

This is the existing `ProfileCompletion.of(draft, details)`, the same value as the Profile tab ring and the
completion hub.

```
part score = clamp(done / total, 0, 1)
percent    = round(mean(part scores) × 100)
```

| Part | done | total |
|---|---|---|
| Photos | min(photos, 4) | 4 (recommended) |
| Prompts | answered prompts | 3 |
| Interests | interests | 5 |
| About you | filled `AboutKey` answers | number of `AboutKey`s |
| Bio | 1 if the bio isn't blank | 1 |
| More about you | `DetailKey` answers + height set | number of `DetailKey`s + 1 |

Each part has equal weight, so one long list can't dominate. **Not included:** verification (§5),
who you want to meet, filters, settings and anything private. Every incomplete part opens its editor.

**Status:** Complete (100%) or Incomplete (below 100%). There is no "bad" level.

## 4. Discovery setup (your side)

| Check | Rule | Status | Action |
|---|---|---|---|
| Area | `details.area != null` | Set / Not set ("people won't see a distance, and event distance filters can't work") | Choose area |
| Who you want to meet | answered in setup (`draft.openTo != null`) | Set / Not set | Edit in setup |
| Filters | `n = queue(filters).length` out of `m = candidates` (sample profiles not yet decided) | "Your filters fit n of m sample profiles" | Review filters |

These describe **who you see**, not who sees you; the section says so. A filter is only flagged
("Worth a look") when **n = 0**, because only then is the effect certain: Discover would be empty.

## 5. Verification

| Item | Source | States |
|---|---|---|
| Phone number | sign-in by code | Verified |
| Photo | `photoVerificationProvider.status` | Not started · In review · Verified · Not approved (attempts left) |

Shown separately and never scored. Not started and Not approved link to verification.

## 6. Account notices

| Source state | Shown as | Action |
|---|---|---|
| `none` | "No notices" with the **source label** (demo: "Demo notice source: no notices") | — |
| `notice` | A notice title and body (e.g. a photo removed for breaking a guideline). The account stays visible | Community guidelines (Help), Contact support |
| `restricted` | "Your profile is hidden from Discover while this is reviewed." | Review and appeal (existing `/account-blocked` screen) |
| `unavailable` | "Can't check right now" | Try again (clears the simulated failure) |

No thresholds, detection methods or reasons beyond the notice text are shown.

## 7. Your activity (counts)

Each count covers **the last 7 days** up to *now* (the app clock), from sample data.

| Metric | Formula |
|---|---|
| Likes received | Sample likes whose time is within 7 days (`DatingController.likesReceivedWithin`) |
| New matches | Matches whose `matchedAt` is within 7 days |
| Conversations with messages | Active matches with at least one message in the last 7 days |
| Profile views | **Not measured in this build.** Shown as "Not available", with no number |

**Availability** (`accountNoticesProvider.insights`, set from the Demo Hub):

| State | Display |
|---|---|
| live | the counts, "Updated just now" |
| stale | the counts, "Last updated 3 days ago: these may be out of date" |
| unavailable | no numbers; "Activity counts aren't available right now" |
| not enough data | all three counts are 0: "Not enough activity yet to show anything useful" |

**Never** shown:
- trends framed as good or bad;
- comparisons with other people;
- "your visibility dropped";
- any link between counts and account status.

The section ends with: "Counts depend on who is nearby, their preferences and the time of year. They
don't measure you, and a quiet week isn't a penalty."

## 8. Suggestions

Built from the checks above, in this order, at most five:

1. a restricted notice → Review notice;
2. a notice → Read the notice;
3. paused → Resume;
4. a missing Discover requirement → that editor;
5. filters fit 0 → Review filters (Discover would be empty, so it comes before optional items);
6. photo verification not started or not approved → Verify your photos;
7. incomplete completeness parts, in the order Photos, Prompts, Bio, Interests, About you, More about you → that editor;
8. area not set → Choose area.

Each shows **why it appears** (the rule that triggered it). There are no suggestions to like, swipe,
message or use the app more.

## 9. "How this works" page

The page (`/profile/visibility/about`) answers:
- what is measured;
- how it is calculated (the rules above, in plain words);
- what information is used;
- when it updates (immediately, on this device);
- what you can change;
- what this page can't determine. It can't see:
  - how other people's apps rank you;
  - how many people saw your profile;
  - why a particular person did or didn't like you.

## Update rules

- **Live:** every section recomputes when its provider changes.
- **"Updated just now"** refers to the moment the screen built.
- **Demo Hub:**
  - set a notice, a restriction or an unavailable source;
  - make insights stale or unavailable;
  - reset all to defaults (`none` / `live`).

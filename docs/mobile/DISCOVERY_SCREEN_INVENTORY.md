# Discovery screen inventory

The checklist for Discovery, from the first card after onboarding to a like, a pass, a match or a
report. Branch `experiment/numaya-discovery-complete` (from `experiment/numaya-onboarding-complete` @
`e4f0f5f`).

- QA and captures: [DISCOVERY_QA_REPORT.md](DISCOVERY_QA_REPORT.md).
- App-wide context: [FULL_APP_SCREEN_INVENTORY.md](FULL_APP_SCREEN_INVENTORY.md) §C.

## Counting rules

These follow [ONBOARDING_MASTER_INVENTORY.md](ONBOARDING_MASTER_INVENTORY.md).

**Screens** are pages or sheets with their own purpose. A card's tip, an empty feed or an error are
**states** of the screen they appear on, listed and counted separately.

**Evidence labels:**
- **[O]** observed in a Mobbin capture;
- **[D]** documented in `docs/research/`;
- **[I]** inferred;
- **[U]** unverified.

## Research used

Inputs from the repo:
- `docs/research/screen-specs.md` B-30–B-37;
- `journey-map.md` §3 (F9–F17);
- `states-and-recovery.md` (Discovery rows);
- `decision-log.md` D-14 and D-15;
- `unknowns.md` P-05 and P-08;
- the [onboarding inventory](ONBOARDING_MASTER_INVENTORY.md), which sets "who to meet" and the age range.

**Mobbin (this pass, all iOS; there are no Android captures of these apps):**

| App | Flow or screen | What it showed |
|---|---|---|
| Hinge | [User profile](https://mobbin.com/flows/f8f0e6c7-5331-4c8f-a446-eb8c266d31d7) (10) | A profile is one long scroll (photos interleaved with prompts and a details table). A **floating × stays bottom-left while scrolling** [O]. Undo arrow in the header, greyed when unavailable [O]. Quick filter chips (Age, Height, Dating intentions) above the profile [O] |
| Hinge | [User profile (standout)](https://mobbin.com/flows/d911ec0b-7704-4987-af8e-cac5459b2cc4) (5) | "Standouts": curated, refreshed daily, opened as a full profile with Back [O] |
| Hinge | [Changing dating preferences](https://mobbin.com/flows/3204d272-4c33-4b5c-8147-b8495e96116a) (8) | Preferences list (interested in, neighbourhood, distance, age with *Dealbreaker*); subscriber preferences locked [O] |
| Bumble | [Using a backtrack](https://mobbin.com/flows/7efe81d4-c814-4880-ae45-8067601d4c57) (2) | Backtrack in the header (↶) brings back the **last pass**; on For You a passed card offers "Backtrack" [O] |
| Bumble | [Not liking a user](https://mobbin.com/flows/07731ad2-ccc0-4ee6-8102-1c5237ed3cda) (3) | A pass shows a large × on the card as it leaves; the next card is underneath [O] |
| Bumble | [Swiping to get matches](https://mobbin.com/flows/b87cf3cd-a092-41ea-9c6c-828c05487fd0) (6) | Card: name and age, verified, "New here", "We have things in common" chips, ★ SuperSwipe on the photo [O]. A top banner after several swipes ("we've got a sense of what you like") [O]. A **thin progress bar under the header** fills as the profile is scrolled [O] |
| Bumble | [People card](https://mobbin.com/screens/ee54d57a-33f7-4f05-ba27-012f9f74eb48), [profile scrolled](https://mobbin.com/screens/ecc58b78-c02a-4070-8c1b-5f8e61d8344a) | Photos are part of the scroll, not a horizontal carousel; "My location" section with distance [O] |
| happn | [Profile preview](https://mobbin.com/flows/d7cd21b5-b227-45bc-8338-8468babf3d5f) (6) | A horizontal photo carousel with page dots; a full-screen profile sheet with a close × [O] |
| happn | [Recent crossing](https://mobbin.com/flows/32df79f5-3a54-4953-a622-8d3ca451e441) (3) | **Exhausted list:** "There are no more profiles in this list · Come back later… · Explore" [O]. A floating action bar (⚡ × ♥ ★) over the profile [O] |
| happn | [See user profile](https://mobbin.com/flows/b0d3f667-4822-4f0f-abe0-3cd1205beb07) (3) | **"Report & block" as a text link at the end of the profile** [O] |
| Hinge | [Matches empty](https://mobbin.com/screens/c16ac5e1-73fd-4581-996e-0c0cdfa2871a) | An empty state names why it's empty and offers a next action [O] |

**Not found [U]:**
- a Bumble "out of profiles" capture (B-37);
- what any app shows when loading the deck fails;
- a first-run coach mark on Mobbin for these versions (B-31 was observed in an earlier pass).

## Decisions

| # | Decision | Evidence |
|---|---|---|
| DD-1 | The expanded profile stays an inline scroll below the card (no separate page from Home) | Bumble, Hinge [O]; B-32 [D] |
| DD-2 | A thin bar under the header shows how far through the profile you are | Bumble [O] |
| DD-3 | Pass, SuperSwipe and Like float over the profile once the photo card has scrolled away, and hide again near the inline row | Hinge, happn [O] |
| DD-4 | Photos open a viewer: swipe or Previous / Next, "Photo N of M", back closes. A photo count shows on the card | happn carousel [O]; B-30 photo progress [D]. Tap zones on the card edges stay out: Bumble doesn't use them [O], and they would fight the swipe |
| DD-5 | Undo works for the last pass only and is free in the demo. The person returns to the front with "{name} is back". A like or SuperSwipe can't be undone (it's sent) | Bumble Backtrack [O]; P-05 premium scope still open [D] |
| DD-6 | Out of people: "No one fits your filters" (widen), "seen everyone" with **Show them again** when there are passes, and without it when everyone was liked (pointing to Likes) | happn exhausted list [O]; D-15 [D] |
| DD-7 | Show them again brings back passes only. Liked people never return | Defect found (see QA) |
| DD-8 | "Report or block {name}" at the end of every profile, as well as ⋯ in the header | happn, Bumble [O]; journey §4 [D] |
| DD-9 | First-visit tip on the card ("Swipe right to like, left to pass…"), dismissible, gone after the first decision. It isn't a dimmed overlay, so the profile stays visible | B-31 [O, earlier pass]; deferred before because an overlay hid the card |
| DD-10 | Reset in Filters returns to the preferences from sign-up, and the filters button shows a mark when they differ | Defect found (see QA); Hinge preferences [O] |
| DD-11 | A failed retry says it failed again | states-and-recovery [D] |
| DD-12 | In a profile, Android back returns to the top first; at the top it leaves Home as before | [I], platform convention |
| DD-13 | Discover's toasts sit under the header, not over the name or the tab bar | Defect found (see QA) |

**Not built, deliberately:**
- Hinge-style likes on a specific photo or prompt, and Bumble's "note with a like" (both need a message model and product decisions);
- "Recommend to a friend" or share (no real sharing);
- quick filter chips above the card (the Filters sheet covers them; adding them would change V16's header);
- photo edge-tap paging (DD-4).

## Flow

```
Onboarding: All set ─ Start discovering ─▶ DS-01 Discover (first card, tip)
DS-01 ─ swipe right / Like ─▶ liked (toast) or DS-10 Match ─▶ Chat or back
DS-01 ─ swipe left / Pass ─▶ next card; Undo (header) ─▶ the pass returns first
DS-01 ─ ★ SuperSwipe ─▶ like with a credit, or DS-11 Paywall when none are left
DS-01 ─ tap the photo / any photo ─▶ DS-02 Photo viewer ─ back ─▶ DS-01 (same place)
DS-01 ─ tap the name band / scroll ─▶ expanded profile (floating actions, progress)
DS-01 ─ Filters ─▶ DS-03 Filters sheet (DS-04 add-filter sheet) ─ Show N people ─▶ DS-01
DS-01 ─ ⋯ or "Report or block" ─▶ DS-07 options ─▶ DS-08 Report / DS-09 Block ─▶ next card
DS-01 ─ ✦ ─▶ DS-05 For you ─ open ─▶ DS-06 Person profile (Pass / Like)
```

## Screens

| ID | Screen | Class | Route or entry | Before this branch | Now | States | Tests |
|---|---|---|---|---|---|---|---|
| DS-01 | Discover (card and expanded profile) | Required | `/home` | Existed | **Improved** | first card with tip · card · dragging (Like / Pass stamp) · deciding (exit) · reading with floating actions and progress · end of profile with report link · undo available · undo toast · liked toast · SuperSwipe toast (credits left) · fallback banner · no one fits · seen everyone (passes) · seen everyone (all liked) · loading skeleton · error · error after a failed retry · paused (snoozed) · filters changed mark | `discovery_test`, `dating_test`, `motion_test`, `break_ui_test`, `accessibility_test` |
| DS-02 | Photo viewer | Required | `/person/:id/photos?start=N` | — | **New** | photo N of M · first (Previous unavailable) · last (Next unavailable) · unknown person | `discovery_test` |
| DS-03 | Filters (Basic / Advanced) | Required | sheet | Existed | **Improved** | basic · advanced locked · advanced (Premium) · live count · none fit · fallback in use · reset to sign-up preferences · saved toast | `full_app_journeys_test`, `dating_test`, unit |
| DS-04 | Add-filter sheet | Supporting | sheet from DS-03 | Existed | Unchanged | options · none picked | unit |
| DS-05 | For you (curated picks) | Recommended | `/for-you` | Existed | Unchanged | picks with refresh countdown · empty | `full_app_journeys_test`, unit |
| DS-06 | Person profile (from For you) | Supporting | `/person/:id?decide=1` | Existed | Improved (a pass here can be undone and returns first) | decide · already decided · unknown person | `full_app_journeys_test`, unit |
| DS-07 | Profile options (Report, Block) | Required | ⋯ and end-of-profile link | Existed (⋯ only) | **Improved** (second entry point) | options · cancelled | `discovery_test`, `dating_test` |
| DS-08 | Report sheets | Required | from DS-07 | Existed | Unchanged | reasons · which part · details · also block · reported | `dating_test`, `full_app_journeys_test` |
| DS-09 | Block confirmation | Required | from DS-07 | Existed | Unchanged | confirm · cancel · blocked toast | `discovery_test`, `dating_test` |
| DS-10 | Match | Required | `/match/:id` | Existed | Unchanged | staged entrance · typing · sent · keep browsing | `dating_test`, `motion_test` |
| DS-11 | Paywall (SuperSwipe credits) | Supporting | `/paywall?feature=superSwipes` | Existed | Unchanged | names the trigger | `discovery_test`, `full_app_journeys_test` |

## Counts

| | Count | IDs |
|---|---|---|
| Required screens | 7 | DS-01, 02, 03, 07, 08, 09, 10 |
| Supporting or recommended screens | 4 | DS-04, 05, 06, 11 |
| **Total screens** | **11** | |
| New / improved / unchanged | 1 / 4 / 6 | new DS-02; improved DS-01, 03, 06, 07 |
| **States** across these screens | **53** | DS-01 19 · 02 4 · 03 8 · 04 2 · 05 2 · 06 3 · 07 2 · 08 5 · 09 3 · 10 4 · 11 1 |

## Interaction checklist

| Interaction | Behaviour | Status |
|---|---|---|
| Swipe right / left past 96 pt, or a firm flick | Like / Pass with a stamp while dragging, a tick at the line, exit in that direction | Existed |
| Short drag | Springs back, nothing decided | Existed |
| Like someone who liked you | Match screen; otherwise "You liked {name}" | Existed |
| SuperSwipe | Uses a credit, toast with credits left; none left: paywall naming SuperSwipes | Existed |
| Undo | Last pass only; returns at the front; toast; one step | **Improved** |
| Show them again | Passes only | **Fixed** |
| Photo viewer | Swipe, Previous / Next, counter, dots, back | **New** |
| Expanded profile | Name band or scroll; floating actions; progress; back to top | **New** |
| Filters | Count updates live; Apply changes the cards; Reset to sign-up preferences; changed mark | **Improved** |
| Report and block | ⋯ and the end of the profile; blocked person leaves the deck | **Improved** |
| Error and retry | Skeleton, then error; a second failure says so | **Improved** |
| Reduced motion | Decision, floating bar, viewer paging and scrolls are instant | **Extended** to the new parts |
| Android back | Viewer closes; deep in a profile goes to the top; Home's back leaves the app as before | **New** for the profile |

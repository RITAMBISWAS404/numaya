# Numaya review batch 2: implementation tracker

This file tracks implementation separately from the issue register. [NUMAYA_UI_REVIEW.md](NUMAYA_UI_REVIEW.md) and its issue IDs are unchanged.

## Baseline

- **Worktree:** `C:\Users\biswa\Downloads\numaya\numaya-ente`, branch `experiment/numaya-ente-design-system`.
- **Base commit:** HEAD `f2e18e6`.
- **Starting point:** the working tree of the latest intended implementation, which carries uncommitted changes. These are the Ente experiment plus batch 1, UI-001 to UI-012; batch 1's recovery patch is `artifacts/ente-design-system/patches/ui-review-handoff.patch`.
- **Assets:** A-007 to A-014 match that build, so they serve as this batch's before state. They show the same header, chips, decision row and composer that the batch-1 device run captured. No separate before-capture was taken.
- **Device:** Pixel 10 emulator, Android 16 (API 36), 390 × 875 dp (density 443).
- **Git:** nothing committed, nothing pushed.

## Tracker

| Issue | Requirement | Actual usages | Planned or done change | Verification | Status | Remaining |
|---|---|---|---|---|---|---|
| UI-013 | Logo left; Backtrack then Filter; no sparkle, no strip; Backtrack restores a left swipe | Discover header (the only one) | Header rebuilt as wordmark, Backtrack, Filter. The sparkle (For You entry) and the read-progress strip are removed. Backtrack reuses the existing one-step undo of the last pass and is now always shown: disabled, with a spoken reason, until there is someone to restore. Restoring also refuses, and clears, a person blocked or reported since (new guard). Report with block also clears the slot | Widget tests: header order; left swipe, Backtrack, single restore, no duplicate; repeat tap; right swipe not restorable; blocked person not restored. Device: in-progress swipe, ready, restored | Implemented and verified | History depth stays one step, as before (no new product rule) |
| UI-014 | Identity grouped at the foot of the photo; status tag above the name; no photo count | `PersonHeroCard`, used in Discover, liked profile and person profile (overlay layout), and the own preview (plain layout) | Overlay order is tags ("Sample profile", "New here"), then name and tick, then designation. The photo-count chip is removed from the shared card, so every layout drops it | Widget test (tag directly above name, no count); device A-007 | Implemented and verified | **College:** the data model has no college field, so none is shown. Nothing invented |
| UI-015 | Shared interests out of the photo, in their own section after the bio | `personSections` (all profile scrolls), `PersonHeroCard` | Removed from the overlay and from under the plain card. A "You both like" card follows About me, only when interests exist | Widget tests; device | Implemented and verified | None |
| UI-016 | No decision buttons; left and right swipes keep their meaning; no Super Swipe | Discover inline and floating `DecisionBar`, the Super Swipe flow | Both bars and every Super Swipe path removed from Discover. Swipe semantics unchanged. Non-gesture paths: Like and Pass screen-reader actions on the photo, and the right and left arrow keys | Widget tests (no bar, actions decide, double action ignored, mid-exit action ignored); device | Implemented and verified | `DecisionBar` stays in the design system for the internal Design Lab only, which is never reachable in release |
| UI-017 | Ellipsis on the photo opens actions for that person | Discover photo action | Kept; it opens Report and Block for the current person, using the existing sheets | Widget test; device | Implemented and verified | None |
| UI-018 | Bio separated from detail pills | About me card | One card: bio first, a divider, then the pills | Widget test; device A-008 | Implemented and verified | None |
| UI-019 | Emoji in profile-detail pills, consistent gap | `InfoChip` emoji pills in About me and location (all profile scrolls) | One mapping, `ProfileFactEmoji`; one emoji size (16) and gap (6) on `InfoChip`; emoji are excluded from semantics | Widget test; device | Implemented and verified | Emoji metrics on iOS not checked |
| UI-020 | Small muted label above emphasised content | `ProfileSectionCard` in About me, You both like, location, event answer and bio preview; `PromptCard` (UI-007) | Label is the muted 14 role; content uses the new `AppTypography.cardPrimary` (18/24 medium) | Widget tests; device | Implemented and verified | Exclusion: the help-style visibility explainers keep a real heading (`explainer: true`) |
| UI-021 | Gender rows with round indicators; keep multi-select | Discover Filters, Basic | Separate white rows with `OptionKind.multiCircle`, announced as checked and not exclusive. Multi-select, Apply, Reset and the unfiltered state are unchanged | Widget test (select two, clear one, apply, reopen, reset); device | Implemented and verified | **Cardinality decision pending** |
| UI-022 | Inactive pill tab has a visible boundary | `ViewTabs`: Filters, prompt categories, Likes, Messages and events tabs | Inactive pill is white with a hairline drawn on top, so the label inset is unchanged | Widget test, both directions; device | Implemented and verified | None |
| UI-023 | Sheets use the grey surface; settings in white cards | `showNumayaSheet` (26 call sites), `ListGroup`, `OptionGroup` | Sheet background is the canvas grey. Groups always draw white cards; the white-sheet flush mode is removed. Filters: verification, height and intentions are now in cards. Profile height sheet: the read-out and slider share one card. Language chips are white | Widget tests; device | Implemented and verified | The action sheet (white groups floating over the scrim, no sheet surface) and system dialogs are excluded |
| UI-024 | Sliders use the available width | Age (Meet and Filters), distance, height filter, profile height | Shared `numayaSliderTheme` with a half-thumb horizontal inset and a 44pt height. `AgeRangeSlider` thumb detection follows | Widget test (track equals card content width, 44 tall); device at both ends | Implemented and verified | None |
| UI-025 | Figma off-state switch | `NumayaSwitch` (every switch) | Figma 2482:6647 inspected: a solid #969696 track, no outline, white knob. Implemented as a solid control-grey track (#8A8A8A, the nearest token that reaches 3:1), no outline; the on state is unchanged | Widget tests; device off and on | Implemented and verified | Token is 1 step darker than Figma for contrast (documented) |
| UI-026 | 8pt padding, 4pt gaps, about 48 × 38 items, fully rounded, content-sized | `NumayaTabBar` (Ente surface, the shipped one), one consumer (`HomeShell`) | New compact layout: bar 272 × 54, items 48 × 38, pill radius. Hit targets are 48 × 44, extending 3pt into the padding without overlapping | Widget test (exact geometry, all destinations); device, each tab | Implemented and verified | The frosted and opaque variants (Design Lab comparisons) keep their old geometry |
| UI-027 | Soft, light shadow | Same bar | `AppElevation.navigation`: 2pt at 4% plus 24pt at 6% | Widget test; device | Implemented and verified | None |
| UI-028 | App bar with title and Close; image below; no heart | `MatchScreen` | Shared `NumayaTopBar` (Close returns to browsing); the photo is in the 3:4 profile frame; heart removed | Widget tests; device A-014 | Implemented and verified | None |
| UI-029 | "You both like" card | `MatchScreen` | `ProfileSectionCard` with interest pills, only when interests exist | Widget test; device | Implemented and verified | None |
| UI-030 | View profile and Open chat; no composer; exit to browsing | `MatchScreen` | Composer and Send removed. Open chat replaces the match with `/chat/:id`; a thread is created only when a message is sent. View profile pushes `/person/:id`, and back returns to the match | Widget tests (right person, no thread created, Close, 320pt at 200% text reachable); device | Implemented and verified | None |
| UI-031 | No Opening Moves in the first release | Match line, Messages promo card, chat Opening Move prompt, Edit profile row, Profile row, Demo Hub link, `/profile/opening-moves` route | New `ReleaseScope` flags (off by default). Every entry point is gated; the route redirects to Profile, deep links included. Data and controller are kept dormant | Widget tests (route redirect; no text on Messages, Profile, Edit profile, chat); device | Implemented and verified | None |
| UI-032 | No Follow in the first release | Searched all of `lib/` | No Follow feature exists. `ReleaseScope.follow = false` documents it | Widget test (no "Follow" text on main surfaces) | Implemented and verified (nothing to remove) | None |
| UI-016 (scope) | No Super Swipe anywhere | Discover, Premium list and extras row, paywall feature copy and benefits, help article | All gated or reworded; a stale `?feature=superSwipes` link shows the general paywall | Widget tests; device Premium | Implemented and verified | Controller credits are kept dormant |

## Earlier issues UI-001 to UI-012 (re-verified against this build)

| Issue | State in this build | This batch |
|---|---|---|
| UI-001 | Implemented; final artwork **blocked** (temporary brand image) | Unchanged |
| UI-002 | Implemented and correct | Unchanged |
| UI-003 | Implemented; on sheets it used dividers | Now cards on the grey sheets too, consistent with UI-023 |
| UI-004 / UI-005 | Implemented and correct | Width corrected by UI-024; active-thumb pop-up re-verified at both ends |
| UI-006 | Implemented and correct | Unchanged (the profile-editor height sheet is a slider, now carded) |
| UI-007 | Implemented and correct | Discover prompt card re-verified (A-008); the chat Opening Move prompt card is hidden (UI-031) |
| UI-008 | Implemented; the phrase "three-day-to-time-driven response" is **awaiting clarification** | Unchanged |
| UI-009 / UI-010 | Implemented and correct | Unchanged |
| UI-011 | Implemented | Extended to the New Match photo (3:4) |
| UI-012 | Implemented | New `cardPrimary` role added to the scale for UI-020 (no one-off sizes) |

## Open decisions

1. **UI-021:** should gender stay multi-select, or become single-select? Multi-select is kept for now.
2. **UI-013:** removing the sparkle leaves For You (curated picks) with no entry point in the main app; it is reachable only from the Demo Hub. Keep it hidden for the first release, or give it a new entry?
3. **UI-001:** approved Welcome artwork is still needed.
4. **UI-008:** what does "three-day-to-time-driven response" mean?

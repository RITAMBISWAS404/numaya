# Branching rules, interaction states and recovery paths

The first part records what the reference does ([O]/[C]). Where the reference shows nothing
([U]), the **Numaya rule** column states the behaviour Numaya adopts. Each Numaya rule is a design
decision, not an observation.

## 1. Branching rules

| Area | Condition | Reference behaviour | Ev. | Numaya rule |
| --- | --- | --- | --- | --- |
| Entry | Valid session exists | Opens straight to the People stack | [I] | Same. Resume an unfinished onboarding step if the profile is incomplete |
| Entry | Returning user on Welcome | *I have an account* → last-used method first | [O] | Phone sign-in with "Welcome back" copy. Other methods open |
| Phone | Number incomplete for country | Next disabled | [O] | Same. Length per country pattern |
| Phone | Country changed | — | [U] | Keep digits, trim to the new maximum |
| Verify | SMS not received | *Didn't get a code?* → resend / call alternative | [O] entry · [I] options | Resend after a 30 s cooldown; call fallback reserved |
| Verify | Wrong code | — | [U] | Error state, cells clear after 650 ms, focus stays |
| Verify | Wrong number | *Change number* → phone step, number kept | [O] | Same |
| Eligibility | Under 18 | — | [U] | Block with a neutral explanation. No retry with another date in-session |
| Onboarding | Optional step | *Skip* on email, interests | [O] | Skippable steps are marked and counted as incomplete in the hub |
| Photos | Fewer than the minimum | "Add at least 4 photos"; next blocked | [O] copy · [I] block | Minimum 2 to continue, 4 recommended (open decision) |
| Interests | Quota reached | "0/5 selected" counter | [O] | Further chips become unavailable (`aria-disabled`) with a counter hint |
| Discovery | Premium action without entitlement (undo, SuperSwipe without credit) | Paywall | [O] | Contextual paywall that names the triggering feature |
| Discovery | Filters too narrow | Per-filter fallback switch "Show other people if I run out" | [O] | Same pattern; an empty state offers to widen filters |
| Match | Mutual like | Match screen with timer | [O] | Celebration sheet, composer focused, no countdown pressure in copy (open decision) |
| Match | No first message within window | Expires (72 h current / 24 h older) | [C] | Timer behaviour is an open decision |
| Match | Extend / Rematch | 1 free Extend per day; Rematch for paid tiers | [C] | Open decision |
| Chat | Unmatch | Confirm with consequences → optional reason | [O] | Same, and the conversation is removed for both |
| Chat | Report | Always blocks; anonymous | [O] | Same. Report from profile, card and chat |
| Verification | Rejected | Retry or contact support | [C] | Retry with tips; after 3 failures route to support |
| Premium | Purchase success | System alert → active state | [O] | In-app result panel plus active state |
| Premium | Purchase cancelled / failed | — | [U] | Return to the paywall with the plan still selected; an inline error explains the failure without blame |
| Settings | Disable a mode | Consequence copy under the switch | [O] | Confirm dialog for destructive visibility changes |
| Lifecycle | Delete account | Reason → confirm; 28-day restore | [C] | Same. Warn about active subscriptions before confirming |
| Moderation | Account blocked | In-app notice, appeal within 6 months | [C] | Blocked-state screen with appeal link |

## 2. Interaction state model

Every interactive component implements the applicable subset. Visual treatments are defined in
[`../design-system/foundations.md`](../design-system/foundations.md#interaction-states).

| State | Trigger | Reference example | Numaya requirement |
| --- | --- | --- | --- |
| Default | — | — | — |
| Hover | Pointer over (web only) | — | Subtle surface shift, never the only signal |
| Focus | Keyboard / programmatic | Active code cell (B-07) | 2px brand ring, 2px offset, always visible with keyboard |
| Pressed | Pointer/touch down | Scale on buttons [I] | Scale 0.98 (buttons) / 0.92–0.94 (round controls) |
| Selected | Option chosen | Selected chip, radio card, plan card | Brand border or tint plus a check icon (not colour alone) |
| Disabled | Not yet valid | Grey next button | Sunken fill, subtle text, `disabled` or `aria-disabled` |
| Loading | Async in progress | "Loading" pill, row spinner | Spinner in place of the label/icon, `aria-busy`, input locked |
| Success | Completed | Check icon on confirmation | Result panel or inline success note |
| Warning | Needs attention | Consequence copy | Warning text colour plus icon |
| Error | Failed / invalid | — | Danger colour, message tied with `aria-describedby`, recovery action |
| Empty | No data | Empty chats (B-43) | `EmptyState` with one primary next step |
| Locked | Requires premium | Lock icon on Travel; blurred Liked You | Lock icon plus explanation; tapping opens a contextual paywall |
| Pending | Awaiting review | Verification review [C] | `StatusBanner` with expected time |

## 3. System states and recovery

None of these were captured in the reference ([U]). The Numaya rules below are binding for future
screens.

| Situation | Detection | Numaya UI | Recovery |
| --- | --- | --- | --- |
| Initial load | Request in flight > 300 ms | Skeletons matching the final layout (no spinner-only screens) | Auto-retry once; then error state |
| Offline | `navigator.onLine` false / request fails with a network error | Top `StatusBanner` "You're offline. We'll keep trying." | Queue sends (chat) and toggles; auto-resume on reconnect |
| Request error | 5xx / timeout | Inline `ErrorState` with *Try again* | Retry with backoff; keep user input |
| Validation error | Client or server rule | Field `error` with a specific message | Focus the first invalid field |
| Message failed | Send failed | Bubble with failed status and *Retry* / *Delete* | Retry keeps order; never lose text |
| Permission denied | OS denied | Explain impact plus *Open Settings*; feature degrades | Re-check on return to foreground |
| Permission not determined | First use | `PermissionPrimer` before the OS prompt | *Not now* defers; no loop |
| Session expired | 401 | Sheet "Please sign in again" | Return to the same screen after sign-in |
| Interrupted onboarding | App killed mid-flow | Resume at the last incomplete step with entered data | Server or local draft per step |
| Unavailable feature | Region / flag off | Hide the entry point; never show a dead control | — |
| Destructive action | Unmatch, delete, block | `ConfirmDialog` or sheet listing the consequences | *Cancel* is the default focus |
| Rate limit | Too many attempts (code, likes) | Inline message with time to retry | Countdown, then re-enable |

## 4. Recovery principles

1. **Never lose input.** Drafts survive errors, navigation and backgrounding.
2. **Say what happened and what to do.** Specific copy and one clear recovery action.
3. **Recover in place.** Prefer inline errors and banners over dead-end screens.
4. **No blame, no alarm.** Neutral tone, especially for safety and moderation outcomes.
5. **Back is always safe.** Back never discards data without a confirmation.

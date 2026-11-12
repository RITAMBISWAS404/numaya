# Implementation report (replacement V8, premium candidate)

- **Branch:** `experiment/numaya-v8-premium-rebuild-20261112-1945`.
- **Baseline:** the selected V7, `b5e5245`, with all 36 export decisions.
- **Candidate app source:** `aaaa1aa`. Later commits change only records.

## What changed

| Area | Change | Ref |
|---|---|---|
| Compliments | One conversation system. The Heart tab is likes only. Pending Compliments are rows in Messages, sorted with chats and counted on the Messages badge. `/chat/:id` shows the Compliment as message one. The received thread opens with the sender's photo (your V7 `v7-request` B), then a private reply (free). The sent thread shows `mascotWaiting` and has no composer. Replying converts it once. `/request/:id` and `/likes?tab=compliments` resolve to the thread or to Messages. One row per person. The menu label is Dismiss, matching its confirmation. | CV-01, CV-02 |
| Chat | Times inside bubbles. A one-line header name with the avatar opening the profile (`ChatHeader`), shared by chat and the Compliment thread. A near-full hairline between Messages rows, from the avatar's edge to the time's. | C-04 |
| Buttons | Secondary, quiet and brand buttons are outlined with no fill. The primary is solid; disabled stays a filled grey. | C-03 |
| Photos | The adaptive scrim (`PhotoLuma`) on Discover, the full profile, Match, the Likes grid and your own cover. | C-07 |
| Icons | The grey disc behind the actionable-banner chevron is gone. | C-05 |
| Type | Unchanged V7 type. Bree Serif plus Google Sans exists only as a compile-time comparison (`NUMAYA_EDITORIAL_TYPE`). | T-01, T-02 |
| Comparisons (Design Lab, dev builds only) | `r8-secondary-button`, `r8-photo-scrim` and `r8-chat-dividers` (proposed = recommended A). `r8-wallet-value` and `r8-profile-bar` (proposed = your V7 O). The build-flag `r8-type` and `r8-compliment-home` (V7 render versus candidate) appear in the gallery only. | — |

## Deliberately unchanged

- **V7 geometry, spacing, motion tokens and colours.**
- **Grouped settings cards with no hairlines,** which is the Ente pattern.
- **Your 36 V7 selections,** including the wallet A and streak O cards and the setup card's single action.
- **Safety and access rules:** consent, safety sheets, credit rules, pricing and eligibility.
- **Events and Health** stay inaccessible.

## Removed or hidden

- **The Compliments part of Heart.** The old inbox and request screens are now unreachable, since their routes redirect. Their code stays for the lab and for recovery.
- **Nothing else removed.**

## Motion

No new motion was added. The V7 roles meet the `apple-design` guidance that was read:
- Press feedback on touch-down.
- Critically damped transitions.
- Exits quicker than entrances.
- Reduced motion takes every duration to zero.

The adaptive scrim animates its strength change over the state duration, which is zero under reduced motion. Nothing was profiled on physical hardware.

## Verification

See [REQUIREMENTS_REGISTER.md](REQUIREMENTS_REGISTER.md) and [SCREEN_LEDGER.md](SCREEN_LEDGER.md).

## Not real integrations

The following are all on-device demo or not present:
- OTP sign-in.
- Remote persistence.
- Message and media delivery.
- Push notifications.
- Billing.
- Moderation.
- Release signing.

The notification routing tested here is in-app link routing only.

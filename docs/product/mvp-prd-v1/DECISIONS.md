# MVP PRD v1: implementation decisions

Branch `experiment/numaya-mvp-prd-20261107`, from checkpoint `c56e36b` (tag
`checkpoint/pre-mvp-prd-20261107`). Source package: [`source/`](source/START_HERE.md). These are the
decisions made while implementing; each is reversible and named so the owner can overrule it.

| ID | Decision | Why |
|---|---|---|
| MVP-D01 | Kept Riverpod + go_router and the existing feature folders; added `commerce`, `compliments`, `likes`, `matches`, `streaks`, `health` features with pure `domain/` rule classes. No wholesale move into the PRD 05 tree. | PRD 05: "retain existing state management/router if adequate; no wholesale rewrite". |
| MVP-D02 | All PRD rules live in pure Dart domain classes with an injected clock, mirrored by SQL functions in `backend/`. The demo controllers are the deterministic demo implementation; `NumayaApi` / `UnconfiguredNumayaApi` is the live contract. | Rules testable without a backend; live build can never fall back to demo data. |
| MVP-D03 | IST (UTC+05:30, no DST) for every day and week boundary, computed from UTC: likes reset at 00:00 IST; the free extension week starts Monday 00:00 IST. | PRD 02. |
| MVP-D04 | Prices come only from `Catalog` (`kProvisionalCatalog`): ₹99 / ₹299 / ₹1,999, pack ₹79, recovery ₹19, each shown with "provisional, nothing is charged". `billingLive` is false. | PRD 06: provisional, server-configurable, no hard-coding in widgets. |
| MVP-D05 | Demo checkout is a sheet that says no store is connected and lets the tester choose success / pending / cancelled / failed. Builds without demo sign-in use `UnconfiguredStoreGateway`, which always returns "unavailable". | PRD 06: never fake payment success; still lets reviewers see S37 states. |
| MVP-D06 | Paywall shows the full billed amount and term for each plan, no "Save x%" tags, no countdowns. Old GBP plans and "SuperSwipes" removed from the paywall. | PRD 06. |
| MVP-D07 | Compliments are separate from likes: sending one spends a credit, not a like, and takes the profile out of the deck (counts as a decision). A pending incoming Compliment counts as interest: liking that person makes a match and the Compliment becomes message 1. | PRD 02 "a simultaneous mutual like converts the request". |
| MVP-D08 | Reconnection applies to both expiry kinds (no first message within 24 h, and 14 quiet days). | PRD 02 state machine: expired → reconnect_pending → active. |
| MVP-D09 | Premium "Rematch" is removed; reconnection is free and needs the other person's acceptance. The demo never accepts for the other person; a seeded incoming request (Ade) shows S25. | PRD 01/02; existing rule "the demo never invents a reply". |
| MVP-D10 | Extension adds 24 h to the current deadline (not 24 h from now), one per match. Free: one per IST week; Premium: one per IST day. | PRD 01. |
| MVP-D11 | One-sided spam guard: 10 consecutive unanswered messages, then "wait for a reply". | PRD 02 asks for a rate limit; 10 is a pilot default to monitor. |
| MVP-D12 | The check-in sheet appears once per quiet period when the chat is opened; the optional reason is not stored anywhere and never affects ranking. | PRD 02. |
| MVP-D13 | Streak "once per seven-day cycle" is implemented as "no other repaired day within 7 days". Awards are keyed by (run start, cycle number), so a repaired run never pays a cycle twice. Review completion counts only when the deck, new matches and chats are all empty. | PRD 01/02; simplest reading that is testable. |
| MVP-D14 | Earned bank cap (5) covers welcome + streak credits. A capped award is skipped and explained on the Streak page; nothing to buy. | PRD 01 delegated default. |
| MVP-D15 | Profile Health replaces the "Profile & visibility" row on the Profile tab. The older visibility page stays reachable from Settings (it still owns suggestions and notices). | S27 asks for a health preview; avoids two competing scores. |
| MVP-D16 | Insights: 7 days free; 28 and 90 days and the views-to-likes rate are Premium, low-sample under 20 exposures. Exposure counts in the demo are fixed sample numbers, labelled "Sample data in this demo build". | PRD 04; never present synthetic analytics as real. |
| MVP-D17 | Likes tab (S18): free members see the count and locked tiles plus Premium and "keep going in Discover"; Premium sees the grid. Opening a liker's profile as free shows the locked state. | PRD 01/06 "incoming profiles" are Premium. |
| MVP-D18 | Pending matches in Chats show their time left under each tile. This supersedes UI-033's hidden countdown. | PRD S20 "pending matches timers". |
| MVP-D19 | Chat is text and emoji only: the attachment control is hidden behind `ReleaseScope.chatAttachments` (default false); attachment code stays dormant and tested. | PRD 01. |
| MVP-D20 | Onboarding: bio is required (1–300, no Skip); interests are optional (none, or 3–5). Age range already lives on the "who to meet" step. | PRD 01 minimums; interests are not required by the PRD. |
| MVP-D21 | Photo moderation: the demo approves photos instantly and says so on the Photos step; Health counts all demo photos as approved. Live counts only server-approved photos (schema `photos.moderation`). | PRD S08 without fabricating moderation. |
| MVP-D22 | Legal (S45) shows draft summaries marked "Draft for review. Not the final legal text." Safety contacts list 112, 181 and 1930 / cybercrime.gov.in with a "check before launch" line. Welcome's Terms and Privacy links open these pages signed out. | PRD 04 legal review pending. |
| MVP-D23 | Support requests (S43) are recorded on the device and labelled "Demo: not sent to a team". | No support backend. |
| MVP-D24 | Photo verification (selfie) screens from earlier work were left in place, not expanded. The PRD's MVP verification is phone-only; whether to keep the selfie flow is an owner decision. | Out of PRD scope; removal not requested. |
| MVP-D25 | Sample people and places are still the London-flavoured demo set (names, neighbourhoods); Travel cities switched to Indian cities. | Localising every sample string was out of proportion; flagged for the pitch demo. |
| MVP-D26 | Twelve new Tabler 3.50.0 glyphs (message-heart, flame, wallet, gift, chart-bar, receipt, scale, bell-off, clock-plus, heart-handshake; hourglass already bundled) added through `tool/sync_tabler_icons.py`, unmodified official SVGs. | Keep the approved Tabler system. |

## Research used
- Figma (Ente, file `22AeTw6QiPj2fNYHLhC7MK`, read live 2026-11-07): Bottom sheet `4809:8074` (title, close,
  icon, primary and secondary buttons) for the checkout, dismiss and check-in sheets; Banners
  `14590:125265` (icon, title, subtitle, round arrow; progress card) for status banners and the Health
  score card. Existing tokens already map these (x15 README); no new measurements were invented.
- Mobbin (read 2026-11-07): LinkedIn "Add note to invitation" (character counter, one primary action),
  Bumble "What a match… 24 hours" (timer framing), WHOOP "Day Streak" (week row), Cal AI "streak lost"
  and paywalls (full billed amount and renewal line), Locket and Flo plan lists, Hinge Roses/paywall
  (weekly vs purchased allowances). Patterns only; no branding copied.

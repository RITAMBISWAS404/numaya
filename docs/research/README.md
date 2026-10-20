# Research: method, evidence and sources

This folder documents the reference research behind Numaya. It maps the major journeys of a
mature dating product (Bumble Dating, iOS), the visual patterns we borrow from Meetup, and the
typography direction taken from Tiimo. It is research, not Numaya's specification. The product
specification lives in [`../design-system/`](../design-system/README.md) and the decisions that
translate research into Numaya live in the [decision log](decision-log.md).

## Documents

| Document | Contents |
| --- | --- |
| [journey-map.md](journey-map.md) | End-to-end journey map (Mermaid) across all ten areas |
| [flow-catalogue.md](flow-catalogue.md) | Flow catalogue and deduplicated screen inventory with reference links |
| [screen-specs.md](screen-specs.md) | Screen-level specifications for the major journeys |
| [states-and-recovery.md](states-and-recovery.md) | Branching rules, interaction states, error and recovery paths |
| [pattern-inventory.md](pattern-inventory.md) | Components and patterns derived from the journeys |
| [meetup-visual-audit.md](meetup-visual-audit.md) | Meetup visual audit: surfaces, spacing, components, hierarchy |
| [tiimo-typography-audit.md](tiimo-typography-audit.md) | Tiimo typography audit and the Numaya type decision |
| [decision-log.md](decision-log.md) | Reference → Numaya decisions, with rationale |
| [unknowns.md](unknowns.md) | Unknowns, assumptions and unresolved product decisions |

## Evidence legend

Every material finding carries one of these tags.

| Tag | Meaning |
| --- | --- |
| **[O]** | **Observed** in a Mobbin reference screen or flow preview |
| **[C]** | **Confirmed** by an official public Bumble source (support centre, feature pages, terms) |
| **[I]** | **Inferred** from the available evidence; plausible but not shown directly |
| **[U]** | **Unverified / not accessible**: no evidence found in this research pass |

## Sources

**Mobbin (primary, screen-level).** Accessed through the Mobbin MCP: `search_flows` and
`search_screens`, iOS.

- Bumble app: <https://mobbin.com/apps/bumble-ios-fefcf818-326e-4549-b2ba-1f440759e5ee/0f0dcdc7-fe1e-5a71-9eca-9ebea0add315/screens>
- Meetup app: <https://mobbin.com/apps/meetup-ios-9866ea6d-c9b7-49a5-acb6-1b6e8e8c9cbd/f1a4823a-e8cb-43e3-b5de-154b04f6f243/screens>
- Tiimo app: <https://mobbin.com/apps/tiimo-ios-92e196c8-3689-45c1-8869-449f9b7207c4/dc39e0c5-e9cb-4411-a8c4-75cc3a5e8169/screens>

The individual flow and screen links are listed in [flow-catalogue.md](flow-catalogue.md).

**Official Bumble sources (supplementary).**

- Expired matches: <https://support.bumble.com/hc/en-us/articles/28424238819357-Expired-matches>
- Extend a match: <https://bumble.com/en/the-buzz/bumble-extend-match>
- Rematch: <https://bumble.com/en-us/the-buzz/rematch-bumble>
- Taking a break (Snooze): <https://support.bumble.com/hc/en-us/articles/28537106111261-Taking-a-break-from-online-dating>
- Snooze Mode: <https://bumble.com/en-us/features/snooze-mode/>
- Deleting your account: <https://bumble.com/en-us/help/how-do-i-delete-my-profile>
- Verification help: <https://support.bumble.com/hc/en-us/sections/28055471602461-Verification>
- Photo verification not working: <https://bumble.com/en-us/help/why-is-my-photo-verification-not-working>
- Verifying your phone number: <https://support.bumble.com/hc/en-us/articles/28949524382877-Verifying-your-phone-number>
- Account blocks and DSA disputes: <https://support.bumble.com/hc/en-us/articles/28537563012381-Digital-Services-Act-Disputes-about-content-removal-and-account-blocks>
- Why was I blocked: <https://bumble.com/en/help/why-was-i-blocked-from-bumble>
- Safety moderation: <https://bumble.com/en/the-buzz/bumble-safety-moderation>

## Limitations

- **Low-resolution previews only.** Mobbin's MCP returns small inline previews. Downloading the
  high-resolution `image_url` files failed: the container's network policy returns HTTP 403 for
  `mobbin.com`. Small text, exact spacing and exact type sizes are therefore approximate.
- **Flow previews are sampled.** `search_flows` shows evenly spaced screens from each flow, so some
  intermediate steps are missing. Where order matters it was confirmed from the per-flow
  `position` metadata, or it is marked [I].
- **Captures span app versions.** Mobbin captures cover several Bumble releases. Tab names
  ("People", "Discover", "For You"), the timer length and settings labels differ between captures.
  Both variants are recorded where they conflict.
- **No system or failure captures.** No OS permission dialogs (location, notifications, camera),
  StoreKit purchase sheets, offline states or message failures were found. These are [U] and
  Numaya's behaviour for them is specified from platform conventions in
  [states-and-recovery.md](states-and-recovery.md).
- **Official copy may lag the app.** The match-expiry window is 72 hours in the current support
  article and 24 hours in older pages and in the captured screens. Both are recorded.

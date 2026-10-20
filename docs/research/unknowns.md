# Unknowns, assumptions and unresolved decisions

## Unverified reference behaviour [U]

| # | Topic | What is unknown | How to resolve |
| --- | --- | --- | --- |
| U-01 | OS permission dialogs | Timing and pre-prompts for location, notifications, camera and photos | Hands-on test of current Bumble build |
| U-02 | Store purchase | StoreKit sheet, cancel, failure, pending (Ask to Buy) and restore results | Hands-on test; Apple guidelines |
| U-03 | Offline and errors | Offline banners, retry, server errors, message send failure | Hands-on test with network conditioning |
| U-04 | Out of profiles | Empty stack screen and copy | Hands-on test with narrow filters |
| U-05 | Expired match UI | Exact grey-ring and Extend/Rematch interaction | Hands-on test; official copy is [C] only |
| U-06 | Underage / ineligible | Age-gate failure screen | Official help; hands-on test |
| U-07 | Interrupted onboarding | Resume behaviour after the app is killed mid-flow | Hands-on test |
| U-08 | Photo moderation | Upload rejection reasons and states | Hands-on test |
| U-09 | Read receipts | Whether a "read" state exists beyond "Delivered" | Hands-on test |
| U-10 | Delete-account screens | The in-app reason and confirm screens (steps are [C], UI is not) | Hands-on test |
| U-11 | Account recovery | Lost-number recovery UI | Official help says a secondary login method is needed [C] |
| U-12 | Expiry window | 24 h (screens, older docs) vs 72 h (current support article) | Current build |

## Assumptions used in the Numaya spec

| # | Assumption | Impact if wrong |
| --- | --- | --- |
| A-01 | Launch is iOS-first, portrait, phone sizes 375–430 pt | Layout tokens need tablet and landscape rules |
| A-02 | Phone number is the primary identifier | Auth patterns change if email or social login is primary |
| A-03 | Minimum age 18 | Copy and eligibility rules |
| A-04 | English-only at launch, with copy written for later localisation (no text in images, flexible widths) | Localisation effort |
| A-05 | Light theme only at launch; tokens are structured so a dark theme maps semantic tokens only | Dark theme work later |
| A-06 | Photos are required to appear in discovery | Discovery gating |

## Product decisions still open

| # | Decision | Options | Owner |
| --- | --- | --- | --- |
| P-01 | Production framework | Native Swift/SwiftUI · React Native (Expo) · Flutter · PWA | Engineering + product |
| P-02 | Who can message first | Either person (proposed) · Bumble-style rule | Product |
| P-03 | Match expiry | None · 24 h · 72 h; Extend/Rematch availability | Product |
| P-04 | Minimum photos | 2 / 3 / 4 | Product |
| P-05 | Premium scope | Which of: see who liked you, undo, advanced filters, travel, incognito, boosts | Product + business |
| P-06 | Photo verification | At sign-up vs later; required for messaging? | Trust and safety |
| P-07 | Sign-in methods | Phone only · + Apple · + Google | Product |
| P-08 | Discovery format | Card stack (swipe) · curated daily list · both | Product |
| P-09 | Tracking pre-prompt | Omit (proposed) · include | Product + legal |
| P-10 | Notifications default | Opt-in primer timing (after first match proposed) | Product |

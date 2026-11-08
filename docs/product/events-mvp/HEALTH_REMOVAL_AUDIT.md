# Health and Insights removal audit (PRD D4)

**Finding:** Numaya has no production release, no real accounts and no paying subscribers. All
Health, Insights and visibility data was demo data generated on the device. Nothing needs migrating
or refunding today. **A live release still needs this audit repeated against real data** (D4).

## Removed
| Item | Was | Now |
|---|---|---|
| Insights tab/screens (`lib/features/insights/`) | Demo charts with labelled samples | Deleted |
| Health screens (`lib/features/health/presentation/health_screens.dart`) | Profile Health detail | Deleted; the Profile setup card remains (`profile_setup_card.dart`) |
| Visibility screen (`lib/features/account_health/presentation/visibility_screen.dart`) | Visibility score | Deleted; Settings row removed |
| Premium "Insights" benefit and comparison row | Listed as a Premium benefit | Removed from the paywall and comparison |
| Profile "Your insights" row and header variant D | Entry point | Removed |
| Visual Lab Insights groups | Selections | Obsolete (owner); not shown |

## Kept
Dating (Discover, Likes, Compliments, Chats, archive rules), streaks, wallet, Premium, profile setup
guidance and the Demo Hub.

## Old links
`/health`, `/health/about`, `/insights`, `/visibility` (and their children) redirect to
`/profile?notice=unavailable`, which shows a calm "This feature is no longer available" note
(`profile-unavailable`). Covered by `visual_lab_v2_test.dart` ("Health/Insights removed").

## Tests superseded (skipped with reasons, not deleted)
`test/widget/visibility_test.dart`, `test/widget/events_test.dart` (old Events module), TC-05
visibility score, FD-D Event detail header, EXP-003 "no Events path", and the "Events unavailable in
the MVP" group.

# Card inventory and coverage (Visual Lab V2)

Every distinct card family found in the app, where it is used, what was wrong, the Ente reference,
priority and the variants built. "Built" means implemented in Flutter behind the registry and
rendered on the emulator (component crop and in context). Families marked **not varied** were
audited but deliberately left without alternatives in this run; that is listed honestly below.

## Families with alternatives (15 families, O + A–D each = 75 renders)
| ID | Family | Used in | Issues found (before) | Ente reference | Priority | Variants |
|---|---|---|---|---|---|---|
| match-avatar | New match avatar | Chats new matches row | Time-left caption under tile (MVP) contradicted R02; no ring | Avatar `2482:6547` | P1 | O circle ring · A squircle ring · B ring + name · C compact · D portrait + pie |
| conversation-row | Conversation row | Chats, Archive | Badge on avatar corner (R06) | Menu Item `4055:18734` | P1 | O Ente row · A your turn first · B separated cards · C large avatar · D dense line |
| compliment-card | Compliment card | Heart › Compliments | Lived in Chats as a plain row (R03) | Banners `14590:125265`, Bottom sheet buttons | P1 | O sender, quote, actions · A quote-led · B with what they noticed · C compact row · D photo-led |
| like-tile | Like tile | Heart › Likes (Premium) | Verified tick drawn ad hoc | Memory card grid `9439:7274` | P2 | O photo + name below · A name on photo · B list rows · C three columns · D large cards |
| profile-header | Own profile header | Profile | Identity only; activity spread over cards | Header v2, Avatar | P1 | O round photo (approved) · A photo cover · B compact row · C identity + streak · D identity + insights |
| insights-summary | Insights summary | Your insights | Score-led hero (R11) | Banners, Segments | P1 | O status card · A chart-led · B widget grid · C funnel-led · D sentence |
| metric-widget | Insight metric | Your insights, Profile | One bare list per period | Menu Item, Count Badge | P1 | O value tile · A value + weekly bars · B row · C change card · D large number |
| profile-setup | Profile setup | Profile, Insights | Percentage score as hero | Banners (progress) | P1 | O title/bar/button · A Ente banner · B next task · C checklist · D slim row |
| prompt-card | Prompt answer | Discover, profile detail, previews | Compliment anchor overlapped text (R05) | — (card on Ente surface) | P1 | O card + action footer · A open editorial · B quote · C question chip · D compact |
| discover-photo | Discover photo | Discover card | Compliment top-right next to overflow (R05); verified tick ad hoc | Icon Button `2207:42075` | P1 | O name on scrim · A name below · B name chip · C fact pills · D framed |
| streak-card | Streak card | Profile, Streak | Approved baseline (kept as O) | Stepper `7449:29872` | P3 | O approved · A week row · B next reward bar · C large number · D illustration slot |
| wallet-card | Credit wallet | Profile, Wallet | Only list rows | Segments `7585:3118` | P2 | O balance + buckets · A stacked bar · B hero balance · C chips · D recent activity |
| plan-card | Plan choice | Paywall | — | Radio `2482:6625`, Tabs | P2 | O plan cards · A segmented term · B radio rows · C comparison · D featured term |
| status-banner | Status banner | Chat archive note, Insights status | Several ad-hoc banners | Banners `14590:125265` | P2 | O tinted · A Ente arrow · B inline note · C outlined · D strip |
| empty-state | Empty state | Compliments, (Archive uses the shared EmptyState) | Hidden illustration slots (R10) | Empty states page `20943:133321` (not inspected) | P2 | O centred box · A side box · B text only · C card · D next steps |

Usage map: each family is rendered through one widget (`MatchAvatarTile`, `ConversationRow`,
`ComplimentCard`, `LikesGrid`, profile headers, `InsightsSummary`, `MetricWidget`,
`ProfileSetupCard`, `ProfilePromptCard`, `PersonHeroCard.layout`, `StreakSummaryCard`,
`WalletSummaryCard`, `PlanPicker`, `LabStatusBanner`, `LabEmptyState`). Every usage location takes the
same variant, so a choice propagates; nothing is patched per screen.

## Screens with directions (5 priority screens, O + A–C = 20 renders, plus scrolled states)
Profile, Your insights, Likes and Compliments, Chats, Discover. Each direction is a composition
of the shared families; dependencies are declared in the registry (`requires`).

## Audited, not varied in this run (one-off or conventional)
| Family | Where | Why not varied |
|---|---|---|
| Event card / event parts | Events (gated off in MVP) | Feature not in release scope |
| Chat message bubble, composer | Chat | Conventional; brief says chat is not a mechanical large-title target |
| Match moment hero | Match screen | Already has EXP-001 O/A/B/C in the older Experiment Lab |
| Empty conversations | Chats empty | Already has EXP-003 alternatives in the older Experiment Lab |
| Onboarding option cards, fields | Setup flow | Conventional form controls; only R07 sentence-case applied |
| Settings rows, safety sheets, report/block | Settings, sheets | Conventional safety UI keeps understandable behaviour (brief 02) |
| Verification, legal, support pages | Various | Text pages; R07 and R08 applied through shared components |
| Store outcome, Compliment pack, recovery | Store | Text + plan; plan family covers the paywall choice |

Unfinished items are listed in [OPEN_ITEMS.md](OPEN_ITEMS.md).

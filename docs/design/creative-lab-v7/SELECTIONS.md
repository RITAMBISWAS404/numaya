# Selection application checklist

Export `v7-71564be-2026-11-10` (source `71564be`). 36 explicit decisions, 12 undecided deferred groups.
Each decision is the group's `proposed` value in `lab_registry.dart`, which is what the normal app renders.
`selected_candidate_test.dart` asserts all 36. "Changed" means the default moved in this pass.

| Group | Selected | Changed | Implementing widget | Evidence (screen in the flat folder) |
|---|---|---|---|---|
| v6-composer | O Microphone becomes Send | No | `Composer` | Chat-Typed, Chat-Voice-recording |
| v6-quote-style | O Block with inset stripe | No | `_QuotedReply` | Chat-Quoted-photo, Chat-Reply-to-long-text |
| v6-voice-bubble | O Play, position, length | No | `VoiceMessage` | Chat-Voice-sent, Chat-Voice-playing |
| discover-photo | O Name on scrim | No | `PersonHeroCard` | Discover-profile |
| prompt-card | O Card with action footer | No | `ProfilePromptCard` | Discover-profile |
| screen-discover | O Current-rules baseline | No | `DiscoverScreen` | Discover-profile |
| v4-photo-label | G Smooth gradient | No | `PhotoScrim` in `PersonHeroCard` | Discover-profile |
| v6-discover-margin | O Page margin 20 | No | `TabPage` gutter | Discover-profile |
| v7-discover | keep-baseline (O) | No | `DiscoverScreen` | Discover-profile |
| v7-filters | O Basic and Advanced tabs | No | `FiltersSheet` | Filters-sheet-basic, advanced |
| compliment-card | B With what they noticed | **Yes** | `ComplimentCard` case B | Compliments-populated |
| like-tile | A Name on photo | No | `likes_grid.dart` | Likes-premium-grid |
| screen-heart | O Current-rules baseline | No | `LikesScreen` | Likes-free-locked |
| v7-compliment | keep-baseline (O) | No | `ComplimentComposerScreen` page | Send-compliment-* |
| v7-likes-locked | O Locked tiles | No | `_LockedLikes` | Likes-free-locked |
| v7-request | B Photo-led | **Yes** | `RequestScreen`, 4:3 photo | Compliment-request-* |
| conversation-row | O Ente list row | No | Messages row | Messages-all |
| match-avatar | O Circle with ring | **Yes** | `MatchAvatarTile`, `CountdownAvatar` | Messages-all |
| screen-chats | O Current-rules baseline | No | `MessagesScreen` | Messages-all |
| v4-welcome | S Solid purple | No | `WelcomeBrandImage` | Onboarding-Welcome |
| plan-card | O Plan cards | No | `PlanPicker` | Premium-Paywall |
| v7-paywall | O Benefits first | No | `PaywallScreen` | Premium-Paywall |
| profile-header | A Banner and avatar | No | `ProfileHeaderCover` (matches the gallery render) | Profile-hub |
| profile-setup | O Title, bar, button | **Yes** | `ProfileSetupCard` default | Profile-hub |
| screen-profile | O Current-rules baseline | No | `ProfileScreen` | Profile-hub |
| v7-profile | keep-baseline (O) | No | `ProfileScreen` | Profile-hub |
| v6-settings-plan | A Plan card first | **Yes** | `SettingsScreen` plan card | Settings |
| empty-state | O Centred illustration slot | No | Empty-state widget | Discover-no-one-fits |
| status-banner | C Outlined | **Yes** | `StatusBanner` (shared) and `LabStatusBanner` | Streak, Send-compliment-failed, Chat-expiring, Paywall |
| v6-page-title | O Bold 30 | No | `LargeTitlePage` | Profile-hub, Settings |
| v7-nav | O Floating icons | No | `NumayaTabBar` | Every tab |
| streak-card | O Approved streak card | **Placed** | `StreakSummaryCard` in Profile, Your activity | Profile-hub |
| v6-streak-hero | O White card | No | `StreakScreen` | Streak |
| v7-streak | keep-baseline (O) | No | `StreakScreen` | Streak |
| v6-wallet-header | A Solid purple | **Yes** | `WalletScreen` header | Wallet-free, Wallet-premium |
| wallet-card | A Stacked bar | **Placed** | `WalletSummaryCard` in Profile, Your activity | Profile-hub |

## Overlaps resolved together

- Discover: structure O, margin 20 and the G gradient are independent parts of `PersonHeroCard` and `TabPage`, so all apply.
- Profile: `v7-profile` keep-baseline renders the `profile-header` selection, A.
- Streak: `v7-streak`, `v6-streak-hero` and `streak-card` all keep O.
- Wallet: `wallet-card` and `streak-card` were not drawn by the selected Profile (`screen-profile` O used plain rows). They now fill the Your activity section, inside that baseline composition. The Wallet page keeps the selected purple header, so its balance is not repeated.

No selections truly conflict.

## Decisions that replace earlier approvals

- `match-avatar` O replaces the earlier squircle selection (A).
- `status-banner` C replaces the white, centred-icon banner from the Tabler pass, and titles are now ink for every tone. The status colour stays in the icon. Info banners keep the V6 blue icon. Tests that encoded the old look were updated, not skipped.
- `compliment-card` B has Reply and Not now on the card. The card itself no longer opens the request.

## Undecided, deferred, not applied

Insights summary, Insight metric, Insights screen, Event card, Event filters, Event detail action bar, People I met (ea3 and v4 sets), Event detail layout. Events and Health stay off.

## Development controls

Demo Hub, Visual Lab, Design Lab and the Settings prototype section need `--dart-define=NUMAYA_DEV_TOOLS=true`. The normal app has no entry to them, their routes redirect, and stored Lab choices are ignored. The gallery and alternatives stay in the code for recovery.

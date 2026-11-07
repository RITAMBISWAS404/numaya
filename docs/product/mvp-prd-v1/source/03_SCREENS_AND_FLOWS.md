# Screen and flow contract
Each entry is a distinct route or reusable modal state, not necessarily a separate Dart file. Every screen supports loading, empty, offline, retry, accessibility and session-expiry handling where relevant. Preserve draft form data on recoverable errors. Back/cancel must not spend credits.

## Onboarding
### S01 Welcome
Content: Value proposition; sign in; terms/privacy links.
Actions/outcome: Continue to phone.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S02 Phone
Content: Country code, number, consent links.
Actions/outcome: Send OTP with rate limit.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S03 OTP
Content: Code, resend timer, edit number.
Actions/outcome: Verify; show invalid/expired/throttled states.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S04 Eligibility
Content: Date of birth,18+ notice.
Actions/outcome: Reject underage without creating dating profile.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S05 Identity
Content: Display name, gender, optional pronouns.
Actions/outcome: Save and continue.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S06 Preferences
Content: Who to meet, age range, relationship intention.
Actions/outcome: Validate preferences.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S07 Location
Content: Explanation, permission CTA, manual city.
Actions/outcome: Coarse location or city fallback.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S08 Photos
Content: 2–6 slots, reorder, crop, moderation status.
Actions/outcome: Require2 approved photos before discovery.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S09 About
Content: Required bio1–300 chars, prompt picker and answer1–150 chars.
Actions/outcome: Require one prompt; up to3.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S10 Review
Content: Profile preview, missing fields, notification explanation.
Actions/outcome: Complete; grant welcome credits once.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

## Discovery
### S11 Discover
Content: Photo card, name/age, intention, bio/prompts, pass/like, compliment anchors, quota.
Actions/outcome: Open details, pass, like or compose.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S12 Profile detail
Content: Full gallery, prompts, interests, approximate location, report menu.
Actions/outcome: Like/pass/compliment.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S13 Filters
Content: Free and Premium groups, apply/reset, entitlement markers.
Actions/outcome: Apply supported values; explain paid controls.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S14 Compliment composer
Content: Referenced content,150 character counter, balance.
Actions/outcome: Send once; insufficient credits opens store.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S15 Match
Content: Both profile summaries,24h timer, message CTA.
Actions/outcome: Open conversation.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S16 Supply empty
Content: No eligible profiles, filters/city adjustment.
Actions/outcome: Never imply payment creates profiles.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S17 Allowance used
Content: Next reset, remaining benefits, Premium CTA if free.
Actions/outcome: Return to chats or wait.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

## Likes
### S18 Likes
Content: Incoming count; Premium profile grid; free locked state.
Actions/outcome: Upgrade or open permitted profile.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S19 Incoming profile
Content: Profile, like back/pass/report.
Actions/outcome: Create match on reciprocal like.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

## Chats
### S20 Chats
Content: Requests, pending matches timers, active conversations, expired entry.
Actions/outcome: Open thread/request.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S21 Request
Content: Context and one intro, reply/dismiss/report.
Actions/outcome: Reply opens conversation.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S22 Conversation
Content: Header/menu, history, composer, sending status, expiry state.
Actions/outcome: Send text; retry failed without duplicate.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S23 Check-in
Content: Quiet chat reminder, optional reason, pause/preferences shortcuts.
Actions/outcome: Skip or act; no ranking penalty.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S24 Expired chats
Content: Read-only histories and reconnect state.
Actions/outcome: Request reconnection once.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S25 Reconnect request
Content: Requester, prior thread, accept/decline.
Actions/outcome: Mutual acceptance reopens.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S26 Chat actions
Content: Mute/unmatch/block/report confirmations.
Actions/outcome: Execute selected action safely.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

## Profile
### S27 Profile hub
Content: Photo/name, edit, health preview, credits/streak, settings.
Actions/outcome: Navigate.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S28 Edit profile
Content: Existing mandatory fields, photos/prompts/interests.
Actions/outcome: Save validates; incomplete profile hides discovery.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S29 Health dashboard
Content: 0–100 readiness, discovery status, free weekly counts, Premium depth.
Actions/outcome: Explain score and open improvements.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S30 Health explanation
Content: Score factors, actual restrictions, action links.
Actions/outcome: Resolve missing setup; appeal restrictions.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S31 Insights
Content: Views/likes/matches/conversations, date range, sample caveats.
Actions/outcome: Free7day summary; Premium28/90day history.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S32 Streak
Content: Seven-day progress, qualifying actions, reward, recovery eligibility.
Actions/outcome: Review or recover.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S33 Credit wallet
Content: Weekly/earned/purchased balances and dates.
Actions/outcome: Open purchase.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

## Commerce
### S34 Premium
Content: Weekly/monthly/yearly offers, full renewal amount, benefits, restore.
Actions/outcome: Native store checkout.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S35 Compliment pack
Content: Three-credit pack, exact price and balance.
Actions/outcome: Native purchase.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S36 Recovery purchase
Content: Eligible missing day, deadline, outcome and exact price.
Actions/outcome: Native purchase with eligibility recheck.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S37 Purchase outcome
Content: Success/pending/cancelled/failure, restore/help.
Actions/outcome: Server-verifiable entitlement only.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

## Settings and safety
### S38 Settings
Content: Account, preferences, notifications, privacy, support, subscription, signout/delete.
Actions/outcome: Navigate.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S39 Notifications
Content: Messages/matches/check-ins/rewards preferences.
Actions/outcome: Respect OS permission and opt-out.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S40 Privacy and pause
Content: Pause discovery, blocked list, data export/delete links.
Actions/outcome: Show effects before change.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S41 Blocked accounts
Content: Blocked entries without contact/reconnect.
Actions/outcome: Unblock does not recreate match.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S42 Report
Content: Reason, optional detail, selected message evidence, block choice.
Actions/outcome: Submit receipt; never reveal reporter.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S43 Support and appeal
Content: Issue form, ticket status, restriction appeal.
Actions/outcome: Submit and track.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S44 Delete account
Content: Consequences, subscription management link, reauthentication.
Actions/outcome: Hide immediately; deletion job.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S45 Legal
Content: Privacy notice, terms, community standards, safety contacts.
Actions/outcome: Accessible before login.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.
### S46 Account restricted
Content: Reason where appropriate, appeal, support.
Actions/outcome: No paid bypass.
Acceptance: render correct entitlement and real data; valid action reaches documented destination; invalid/repeated action cannot corrupt state; back navigation preserves appropriate state.

Inventory: 7 flow groups, 46 screen/modal contracts. Shared states do not inflate route count. Implementation must maintain a mapping from each S-ID to route/widget, test and screenshot.
# Screen ledger

App source `ee87648`, Pixel 10 AVD (API 36, 1080 × 2424, density 420). Every capture is a real Flutter render of this source on the emulator.

## Normal-size coverage (font 1.0)

The full capture harness `integration_test/final_screens_capture_test.dart` produced 210 captures, 0 skipped. They become the flat folder `Numaya Replacement V8 Screenshots/<timestamp>/`, with long screens in overlapping top, middle and bottom sections.

| Flow | Screens and states |
|---|---|
| 01 Onboarding | Welcome, phone and country sheet, code, setup hub, name and birthday (age sheet, under 18), gender (detail sheet), who to meet, intentions, height, location (permission, area sheet), photos (add, tips, options), interests, prompts (browser, answer sheet), bio, verify offer, notifications, review, all set |
| 02 Discover | Profile card in sections, filters basic and advanced, profile options, For you, person profile (decide and view), photo viewer, allowance used, no one fits, out of likes |
| 03 Likes | Free locked, Premium grid, incoming like profile, match |
| Messages and Compliments | Messages with Compliments among chats; the Compliment conversation on a photo and on a prompt (photo-led); its menu; the Dismiss confirmation; the send composer on a prompt and a photo, typed, keyboard, discard, sent, already sent, failed, no credits |
| 04 Messages | All, unread, your move, search, archive |
| 05 Chat | Active, keyboard, new match, expiring, archived, expired, options, date details, did you meet, unmatch, report, block, message actions, replying, attach, photo pending, sent, viewer, quoted replies, voice recording, preview, sent, playing, send failed |
| 06 Profile | Hub, edit profile and its sheets, basics, interests, photos, prompts, setup hub, preview, photo verification |
| 07 Streaks, 08 Wallet | Streak and repair, wallet free and Premium, the pack and every purchase result |
| 09 Premium | Overview free and active, paywall, the yearly plan selected, checkout sheet |
| 10 Settings, 11 Safety and help, 12 Account states | Settings in sections and its sheets, notifications, privacy, blocked people, delete account and confirmation, safety centre, help centre, article, contact support, support requests, legal pages, restricted, not found, session expired |

**Not reachable, by design:** Events and Health (deferred), the old Compliments inbox and request page (their routes redirect), and the development Lab screens (development builds only).

## Representative stress coverage (separate ledger)

19 key screens from `ente_v4_review_test.dart` `key`, run at three settings, 0 skipped at each:
- Font 1.5.
- Font 2.0.
- Density 480, which gives a 360dp-wide screen.

The screens: chat, Compliments in Messages, composer, Discover, filters, help, likes, Messages, paywall, person, Premium, profile, profile activity, request link, settings, streak, received thread, sent thread, wallet.

## Review log

| Pass | Finding | Action |
|---|---|---|
| Pilot (`design-review` skill, 3/4) | Credits card: the value is not the leading line. Help and Settings appear twice on Profile. | Both are your earlier V7 choices, so they are offered as comparisons (`r8-wallet-value`, `r8-profile-bar`) and not changed |
| Full 210 at 1.0, contact sheets per flow | The Compliment menu said "Not now" but its confirmation said "Dismiss" | Fixed: the menu says Dismiss (`f60b692`) |
| `r8-chat-dividers` render, measured | The near-full hairline sat 40dp in, not at the content edges | Fixed to 20dp at both ends (`aaaa1aa`); measured 52–1026px on 1080 |
| 200% key screens | "Compliment Noor" broke mid-word; the unread badge clipped its digit | Fixed in shared widgets: `BalancedText` keeps the longest word whole, and `CountBadge` has a minimum height (`ee87648`); regression test added |
| 360dp key screens | No defect found | — |

After the last fix, every capture was re-run on `ee87648`. No delivered screenshot predates the source it shows.

## Not covered

- Physical phone, iOS, screen reader (TalkBack), keyboard focus traversal on a hardware keyboard.
- Profiling on supported hardware.

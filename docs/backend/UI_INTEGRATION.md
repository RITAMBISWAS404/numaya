# UI integration notes for the frontend session

**Live mode is off by default.** A build is live only with:

`--dart-define=NUMAYA_SUPABASE_URL=… --dart-define=NUMAYA_SUPABASE_PUBLISHABLE_KEY=… [--dart-define=NUMAYA_BACKEND_LABEL=development]`

Demo builds behave exactly as before; the full Flutter suite passes unchanged.

## Shared files the backend changed (minimal, reviewable)
| File | Change |
|---|---|
| `lib/main.dart` | `await initLiveBackend()` before `runApp`. It does nothing when not configured. |
| `lib/app/providers.dart` | Live auth and profile repositories. No demo sign-in in live builds. Chat attachments off in live builds. |
| `lib/app/app.dart` | Listens for server-confirmed matches (pushes `/match/:id`) and server quota refusals (pushes `/allowance`). |
| `lib/features/dating/application/dating_controller.dart` | `datingProvider` builds `LiveDatingController` in live mode. |
| `lib/features/compliments/application/compliments_controller.dart` | `complimentsProvider` builds `LiveComplimentsController` in live mode. |
| `lib/features/commerce/application/economy_controller.dart` | `economyProvider` builds `LiveEconomyController` in live mode. |
| `lib/features/dating/domain/sample_people.dart`, `live_directory.dart` | `personById` checks live members first. |
| `lib/core/media/local_image.dart` | `https://` sources become `NetworkImage` (signed URLs). |
| `pubspec.yaml` | `supabase_flutter: ^2.18.3`. |

## Behaviour differences in live mode (for review; no new screens added)
- **Likes:** a like shows the existing "liked" feedback at once. The match screen opens only when the server confirms the match, which can take about a second longer than in the demo.
- **Daily cap:** when the server refuses a like for the daily allowance, the person returns to the front of the deck and the allowance page opens.
- **Distance:** the server sends a band (under 5, 10, 25, 50, or over 50 km). The app shows the band's upper bound with the current "km away" copy. **Suggested copy follow-up:** "within 5 km".
- **Height:** unknown height is `0`, which hides the row (nothing is invented).
- **Attachments:** photos and voice notes in chat are hidden (`chatAttachmentsProvider` is false). They have no server storage yet.
- **Purchases:** the store gateway is the unconfigured one, so purchases fail with the existing failure state. Nothing is granted on the device.
- **Session:** the app does not restore a session on cold start yet; the member signs in again. A follow-up will restore the Supabase session into `SessionController` at start.
- **Pending Compliments:** loaded from the server into the existing Compliment thread UI. The target index shown is the first photo or prompt (the server keeps the exact target).
- **Errors:** server refusals reach the UI only as existing states (failed, waiting, not allowed, insufficient credits). An expired session triggers the existing re-sign-in screen.

## States still needing frontend copy or design (not added by the backend)
| # | State |
|---|---|
| U1 | Photo "in review" and "rejected, with reason" on Edit photos (`photos.status`, `reject_reason`). |
| U2 | Account restricted (suspended or under age) after sign-in (`account_restricted`); today it falls back to the generic failure. |
| U3 | Rate-limited ("Too many actions, try again shortly") for messages, Compliments, reports and exports. |
| U4 | Backend label badge on the Demo Hub for development and staging builds. |

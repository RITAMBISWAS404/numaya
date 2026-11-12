# Owner checklist (one list; work continues around every open item)

Status: ☐ open · ☑ done. Never paste credentials into chat; put them in `supabase/.env.local`.

## Credentials and accounts
**Superseded by [MANUAL_SETUP.md](MANUAL_SETUP.md)**, which gives exact steps, costs and verification commands. The list below is kept for history.

- ☐ **Supabase dev project** (free, no payment method): URL, publishable key, secret key, DB password, session-pooler URL in `supabase/.env.local`. *Blocks: applying migrations, all live tests, the dev APK.*
- ☐ **Phone provider** enabled with two **test numbers + OTPs** (Auth → Sign In / Providers → Phone → Test Phone Numbers and OTPs, with an expiry date). Add them as `NUMAYA_TEST_PHONE_A/B`, `NUMAYA_TEST_OTP_A/B`. *Blocks: phone sign-in in the APK.*
- ☐ **SMS provider and budget** for real OTP delivery (and India DLT sender registration if applicable). Until then only test numbers sign in.
- ☐ **Push:** Firebase project (FCM) and, later, APNs. Until then notifications are queued in `private.outbox` and not delivered.
- ☐ **Store sandbox accounts** (Google Play Console, App Store Connect) before any billing work. Premium is grantable only by server-side test provisioning, labelled `staff_test`.
- ☐ **Docker Desktop + WSL2** (optional, admin install) to run the full local Supabase stack and `supabase db diff`.

## Policy decisions (not guessed; marked FIXTURE in code where a dev value is needed)
| # | Decision | Dev value used | Where |
|---|---|---|---|
| P1 | Rate limits: messages, Compliments, decisions, feed, reports, exports | 30/min, 20/h, 120/min, 120/h, 20/day, 5/day | `rpc_core.sql` FIXTURE |
| P2 | Rematch after unmatch | Never (one thread per pair, ever) | `conversations` unique pair |
| P3 | History after unmatch / block | Neither member can read it; report evidence copied at report time | RLS `can_see_conversation` |
| P4 | Retention: report evidence, audit log, deleted-account tombstones, messages of deleted members | Kept indefinitely in dev | RETENTION (to write) |
| P5 | Purchased-credit expiry | None (kept while the account exists) | ledger |
| P6 | Paid streak recovery | Deferred (needs billing) | not implemented |
| P7 | Launch countries, minimum age above 18, beta size | India, 18, unknown | — |
| P8 | Read receipts visible to the other member | Not shown (own unread state only) | `conversation_reads` |
| P9 | Photo moderation staffing (manual review queue) | Owner/moderator by hand | `staff_photo_queue` |

## People (cannot be supplied by an AI)
- ☐ Privacy/safety owner, moderation lead, support contact, designated child-safety contact.
- ☐ Approval of Terms, Privacy Policy, Community Guidelines (versions recorded as `2026-11` in dev).
- ☐ Who may hold the staff (moderator/admin) role; staff MFA.

## Added in the continuation (FIXTURE values in code until decided)
| # | Decision | Dev value used | Where |
|---|---|---|---|
| P10 | Monitor thresholds: photo review age, report age, dead outbox, overdue deletions, failed photos per day, pending exports | 240 min, 24 h, 0, 0, 50, 10 | `scripts/monitor.mjs` |
| P11 | Distinct reporters in 24 h that place an automatic review hold | 3 | `private.settings.report_hold_threshold` |
| P12 | Chat media limits: image ≤ 10 MB, voice ≤ 15 MB and ≤ 120 s, 30 uploads/hour, no video | as listed | `register_attachment` |
| P13 | Product IDs and prices (`numaya_premium_weekly/monthly/yearly`, `numaya_compliments_3`) | IDs only; no prices | `_shared/store/common.ts` |
| P14 | Worker schedule host: GitHub Actions (secrets in GitHub) or this PC | none | MANUAL_SETUP A6 |

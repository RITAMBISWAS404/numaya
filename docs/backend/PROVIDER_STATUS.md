# Provider and feature status

Statuses: not started · local verified · provider sandbox verified · staging verified · production approved · blocked · deferred. An adapter stub is not an integration.

| Capability | Status | Evidence / prerequisite |
|---|---|---|
| Database schema, RLS, RPCs | written; **blocked** for verification | Needs the dev project (`supabase/.env.local`). |
| Phone OTP (Supabase Auth, test numbers) | adapter written; **blocked** | Needs Phone provider + test numbers on the dev project. |
| Real SMS delivery | **blocked** | SMS provider, budget and India DLT sender registration (owner). |
| Photo storage (private bucket, quarantine) | written; **blocked** | Dev project. |
| Photo moderation | manual staff queue (`staff_photo_queue`) | No automated moderation vendor. A human approves photos. |
| Image processing (EXIF strip, resize) | **device-side only** (unit-tested) | The app re-encodes every photo before upload: no EXIF/GPS, ≤1600 px (`sanitizePhoto`, `test/unit/live_photo_sanitize_test.dart`). A server-side worker that re-checks bytes is still required, because a modified client could skip it. **Launch blocker.** |
| Realtime chat | written; **blocked** | Dev project. |
| Chat attachments, voice notes | **deferred** | Hidden in live builds; needs a storage + moderation design. |
| Push notifications (FCM/APNs) | **blocked** | Outbox rows are written; no sender. Needs a Firebase project and credentials. |
| Purchases / entitlements | **not started** (no billing) | Entitlement table is server-only; dev test grants are labelled `staff_test`. |
| Selfie / liveness verification | **deferred** | Not approved for MVP; the `verified` flag is server-only. |
| Calls | **deferred** | Not approved MVP scope. |
| Backups | scripts written; **blocked** | Dev project + `NUMAYA_BACKUP_KEY`. |
| Privacy deletion worker | written; **blocked** | Dev project. Must be scheduled (cron) before any beta. |

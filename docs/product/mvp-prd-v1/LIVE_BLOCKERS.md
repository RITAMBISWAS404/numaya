# Live-release blockers (MVP PRD v1)

The debug APK is a **demo**: sample people, sample analytics and a demo store, all labelled. None of
the items below is done. Each must be finished and verified before any real member uses Numaya
(PRD 06 release gates). Owner column: who must act.

| # | Blocker | What exactly is missing | Owner |
|---|---|---|---|
| 1 | Backend project | No Supabase (or other) project exists. Create it, apply `backend/migrations/0001` and `0002`, run `backend/tests/rls_cross_user.sql` and add tests for every function. | Co-founder (backend) |
| 2 | Phone OTP | No SMS provider (e.g. MSG91/Twilio via Supabase Auth). Needs DLT registration for India, sender ID and template approval, cost review, and the throttles in CONTRACTS.md. The app's live auth is `UnconfiguredAuthRepository`. | Co-founder |
| 3 | Live API wiring | `numayaApiProvider` returns `UnconfiguredNumayaApi`. Implement the Supabase client calls and switch controllers to call them when `ApiConfig.configured`; keep demo strictly for `BackendMode.demo`. | Engineering |
| 4 | Store billing | No Play Console app, no products for ₹99/₹299/₹1,999/₹79/₹19, no Billing Library integration, no `verify-purchase` / `claim-recovery` Edge Functions, no RTDN (Pub/Sub). Prices are unvalidated hypotheses: validate willingness to pay, Play price points, GST and fees first. | Owner + co-founder |
| 5 | Photo storage and moderation | No storage bucket, upload, EXIF stripping, signed URLs, automated screening or human review queue. The demo approves photos instantly. | Co-founder |
| 6 | Trust and safety operations | No report queue, responsible human reviewer, response-time target, admin audit tooling, appeal handling or underage escalation path. | Owner + co-founder |
| 7 | Age assurance | DOB self-declaration only. Decide on additional checks and the escalation for suspected minors. | Owner |
| 8 | Legal | Privacy notice, terms and community standards are drafts. DPDP Act 2023 obligations and the notified Rules' commencement need launch-date legal review: consent/purpose, processors, cross-border transfer, withdrawal, export, deletion, grievance officer, breach response. Retention periods are proposals. Safety numbers (112, 181, 1930) must be rechecked. | Owner (with counsel) |
| 9 | Account deletion | Hide-immediately and the deletion job exist only as contracts; backups and restore are not set up. | Co-founder |
| 10 | Push notifications | No FCM project, no outbox worker; notification settings are switches only. | Co-founder |
| 11 | Location | Approximate device location is not requested; manual city is a sample picker. Implement coarse location with `ACCESS_COARSE_LOCATION` and city fallback. | Engineering |
| 12 | Crash and error monitoring | None configured (e.g. Crashlytics/Sentry) and no privacy review of it. | Engineering |
| 13 | Analytics | No event pipeline, no qualified-impression tracking, no aggregates; Insights shows labelled sample numbers. | Co-founder |
| 14 | Signing and release | Debug APK only, signed with the debug key. Needs an upload key held by the owner, Play App Signing, a release build with `NUMAYA_ENV=production`, store listing and the dating-app and child-safety policy declarations. | Owner |
| 15 | Real supply | A pilot needs enough local, eligible members; the deck here is 10–17 sample profiles. Invite-only recruitment plan per PRD 06. | Owner |
| 16 | Device checks not done this pass | Physical phone, iOS, three-button navigation and Android font size 2.0 on a real device were not checked (the emulator run and widget tests at 200% text were). | Owner |
| 17 | Owner decisions carried over | SW-01 switch contrast, EXP-001–004, UI-001 artwork, UI-008 phrase, selfie verification (MVP-D24), localising the sample people (MVP-D25), and which branch becomes the shipping line. | Owner |

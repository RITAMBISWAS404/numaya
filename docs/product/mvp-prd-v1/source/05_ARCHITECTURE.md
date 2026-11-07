# Incremental Flutter and backend architecture
Inspect current tree before moving files. Follow Flutter separation of views/view models/repositories/services; retain existing state management/router if adequate. No wholesale framework rewrite. Feature-first boundaries, shared design primitives in core.
```text
apps/numaya_mobile/lib/
  app/                 # bootstrap, router, environment, dependency wiring
  core/design_system/  # tokens, typography, Tabler adapter, shared controls
  core/network/        # errors, auth transport, retry policy
  features/<feature>/
    presentation/      # screens/widgets/view models
    domain/            # models/rules/repository contracts when justified
    data/              # DTOs, repository implementations, service adapters
  l10n/
apps/numaya_mobile/test/ # mirrors features; unit/widget/golden
apps/numaya_mobile/integration_test/
backend/migrations/
backend/functions/
backend/tests/
docs/product/ docs/engineering/ docs/agent-handoff/
```
Features auth,onboarding,discovery,likes,compliments,matches,chat,profile,health,streaks,commerce,safety,settings. Abstract repositories with deterministic demo and live implementations. Explicit demo/staging/production configuration; never silently substitute fake metrics into live mode.
Backend candidate: managed PostgreSQL/Auth/Storage/Realtime (Supabase if compatible with existing partner stack). Phone OTP requires SMS provider setup and cost review. Confirm existing backend before selecting provider. Keep atomic business rules server-side, not mobile.
Tables: users_private, profiles, photos, prompts, preferences, likes(unique pair), compliments(unique pair), matches(unique unordered pair), conversations, members, messages(client UUID unique), blocks, reports, moderation_actions, credit_ledger, subscriptions, purchases(store transaction unique), streak_days(user/date unique), reward_cycles, recovery_events, notifications_outbox, analytics_events and aggregates.
Every table specifies ownership and row policies. Phone/DOB/coordinates inaccessible to other clients. Message access requires membership and current authorization. Storage signed URLs, file validation, metadata stripping and moderation. Server service-role secret never bundled. Test cross-user denial, not just happy-path reads.
Transactional endpoints: submitLike, sendCompliment, replyToRequest, sendMessage, extendMatch, reconnectRequest/accept, claimRecovery, verifyPurchase. Each has auth, idempotency key, validation, atomic debit/state transition, durable response and outbox event. Retry network requests with same key. No direct client balance updates.
Jobs: expire initial matches, quiet-chat reminders/expiry, weekly credit rollover, streak awards, deletions, purchase reconciliation. Jobs idempotent and transaction-safe; deadline evaluated on write even if job delayed. Push notifications carry minimal content, honor opt-out; routing rechecks access.
Security: per-user/pair/IP rate limits; OTP resend throttles; report queue and admin audit log; revoke sessions on deletion; verify purchase webhooks and replay resistance. Notification failure never reverses successful message.

# Threat model (backend V1)

**Scope:** Flutter client, Supabase (Auth, PostgREST, Storage, Realtime) and operator scripts.

**Assets:** phone numbers, birth dates, approximate location, photos, messages, reports and their evidence, the credit ledger, entitlements and staff roles.

| Threat | Control in this build | Test | Residual risk / follow-up |
|---|---|---|---|
| Broken object-level authorization (API1) | RLS on every exposed table; RPCs derive the actor from the JWT; no actor parameters. | `permissions.test.mjs` (cross-user reads and writes, private schema, storage folders). | Every new table or RPC needs the same test. |
| Mass assignment of server fields | Column-level UPDATE grants exclude `verified`, `onboarding_complete` and the ledger. | "server-owned columns" test. | — |
| Privilege escalation to staff | `private.staff_members` is only writable by the owner through SQL; every `staff_*` RPC checks the role and audits. | "staff entry points are refused" test. | Staff MFA and just-in-time access are owner tasks. |
| Stalking or triangulation | Coordinates rounded to 0.1° before storage; only a distance band leaves the server; the feed is rate-limited. | Feed-fields test. | Bands near city edges can still narrow position over many accounts; monitor and add jitter if needed. |
| Birth date or private data exposure | Kept in `private.accounts`; cards carry the age only. | Feed-fields test; `export` test. | — |
| EXIF/GPS in photos | Device re-encodes before upload. | `live_photo_sanitize_test`. | **A server-side re-check is required (launch blocker).** |
| Unsafe or illegal media | Private bucket; pending photos visible only to the owner; a human approves; never auto-approved. | Storage test (pending versus approved). | No automated CSAM or nudity scanning vendor. **Launch blocker** for a public launch. |
| Photo access after a block | New signed URLs refused at once. | Block test. | URLs already issued stay valid up to 300 s (disclosed). |
| Replay or double spend (likes, credits) | Idempotency keys with a payload check; per-member advisory locks; unique ledger source keys. | Matching and credits concurrency tests. | — |
| Race conditions (duplicate match or thread) | Pair advisory lock plus a unique unordered pair. | 5-round simultaneous-like test. | — |
| Message spoofing or reordering | Sender is `auth.uid()`; per-conversation sequence under a row lock; client-ID dedupe. | Sequence/retry test. | No E2E encryption (and none claimed); staff read only reported evidence. |
| Harassment after block or unmatch | Conversation closed; messages unreadable; sends refused; no rematch. | Block and unmatch tests. | — |
| Under-age users | 18+ check on the server at onboarding; restricted status; audit; a report category. | Under-18 test. | DOB entry is not age assurance. Escalation process and age assurance are owner decisions. |
| Account takeover | Supabase phone OTP; rate limits by Supabase Auth. | Phone OTP test (test numbers). | SIM-swap risk; device/session management UI not built. |
| Secrets leakage | Only the publishable key in the app; secrets in a git-ignored `.env.local`; tools redact URLs. | — | Add secret scanning to CI. |
| Spam and abuse | Per-action rate limits (fixture values); a one-sided message guard in the app. | Rate-limit behaviour not yet load-tested. | Approve values (DECISIONS P1). |
| Deletion not honoured after restore | Tombstones replayed by the restore drill. | `backup_restore.test.mjs`. | Automate the worker schedule. |

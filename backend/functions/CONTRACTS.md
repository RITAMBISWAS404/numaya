# Numaya MVP endpoint contracts

Status: **contracts only. No backend project, credentials or deployment exist.** The Flutter app
runs these rules locally in its deterministic demo implementation (`lib/features/*/application`),
labelled as demo. A live build must call these endpoints and must never fall back to the demo.

Common to every endpoint
- Auth: a valid session (Supabase Auth phone OTP or equivalent). `401 unauthenticated` otherwise.
- `idempotency_key`: client-generated, unique per user and endpoint. Replaying it returns the stored
  response; retries after a network error reuse the same key. Messages use the client message UUID.
- Responses are JSON: `{ "result": ... }` or `{ "error": "<code>" }`. Codes are stable; the app
  maps them to copy.
- Every state change writes `notifications_outbox`. Push carries ids only and honours opt-out;
  opening a push rechecks access.
- Rate limits (per user, per pair, per IP): proposed defaults below, tune in pilot.

| Endpoint | SQL / function | Request | Results | Errors |
|---|---|---|---|---|
| `submitLike` | `submit_like(key, recipient, positive)` | recipient uuid, positive bool | `liked`, `passed`, `matched` + match id, `already_decided` | `out_of_likes` (+ `resets_at`), `recipient_unavailable` |
| `sendCompliment` | `send_compliment(key, recipient, target_kind, target_id, body)` | photo or prompt id, body 1–150 | `sent` + id | `invalid_length`, `pair_already_introduced`, `insufficient_credits`, `recipient_unavailable` |
| `replyToRequest` | `reply_to_request(key, compliment, message_id, body)` | message UUID, body | `opened` + match id | `request_unavailable` |
| `sendMessage` | `send_message(message_id, conversation, body)` | client UUID, text and emoji only | `accepted` (`duplicate: true` on retry) | `not_a_member`, `chat_closed` (+ state), `wait_for_reply` |
| `extendMatch` | `extend_match(key, match)` | match id | `extended` | `not_extendable`, `already_extended`, `needs_premium`, `used_today` |
| `reconnectRequest` | `request_reconnect(key, match)` | match id | `requested` | `not_expired`, `already_requested` |
| `reconnectRespond` | `respond_reconnect(key, request, accept)` | request id, bool | `reopened`, `declined` | `request_unavailable` |
| `claimRecovery` | Edge Function `claim-recovery` | missed IST day, purchase token | `repaired` + new streak length | `not_eligible` (store purchase voided/refunded, never charged), `verification_failed` |
| `verifyPurchase` | Edge Function `verify-purchase` | store, product id, purchase token | `verified` + entitlement | `pending`, `invalid_receipt`, `replayed`, `refunded` |

## Purchase verification (`verify-purchase`)
1. Look up `store_txn_id`; a known id returns the stored outcome (replay-resistant).
2. Verify with Google Play Developer API (`purchases.subscriptionsv2.get` / `purchases.products.get`)
   using the service account held by the backend only. Never trust the client's claim.
3. Pending purchases grant nothing; the app shows S37 "Payment pending".
4. Subscriptions: upsert `subscriptions` (`activated_at` anchors weekly credits; `paid_through` from
   the store). Compliment pack: `credit_ledger` grant to `purchased` with key `purchase:<txn>`.
5. Acknowledge the purchase with the store only after the database commit.
6. Real-time developer notifications (Pub/Sub) drive renewals, cancellations (keep entitlement until
   `paid_through`) and refunds (reverse remaining purchased credits; conversations are untouched).

## Streak recovery (`claim-recovery`)
1. Recheck eligibility server-side **before** acknowledging the purchase: a missed IST day within 48
   hours of its end, the day before qualified, every day since qualified, no repair in the previous
   7 days.
2. If no longer eligible: do not acknowledge (Play refunds unacknowledged purchases within three
   days), record `recovery_events.outcome = 'refused_not_charged'`, return `not_eligible`.
3. Days lost to a Numaya outage are repaired automatically by an operator job, free.
4. Awards are unique per `(user, run_start, cycle)`; a repaired run never pays a cycle twice.

## Jobs (idempotent, transaction-safe)
| Job | Schedule | Work |
|---|---|---|
| `expire-matches` | every 5 min | `refresh_match` on awaiting/active matches past their deadline (writes also evaluate deadlines, so a late job changes nothing) |
| `quiet-check-ins` | hourly | 7 quiet days: one check-in per member per quiet period (`check_in_seen_for`) |
| `weekly-credits` | hourly | for each subscription week boundary since `activated_at`: expire unused weekly credits, grant 3 |
| `streak-awards` | after each qualifying event and nightly | grant 1 earned credit per completed 7-day cycle; at the cap of 5 record `skipped_at_cap` |
| `account-deletion` | hourly | hide immediately on request; delete primary data within 30 days (proposed); revoke sessions |
| `purchase-reconciliation` | daily | compare `purchases` with store records; fix drift |
| `analytics-retention` | daily | raw events 30 days, aggregates 90 days (proposed, legal review pending) |

## Proposed rate limits
- OTP: 3 sends per number per 15 min, 10 per day; 5 verify attempts per code; per-IP caps.
- Likes: allowance (5/15 a day) plus 60 decisions per minute.
- Messages: 30 per minute per user; 10 consecutive unanswered per conversation.
- Reports: 20 per day per user.

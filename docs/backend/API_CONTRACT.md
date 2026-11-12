# API contract (typed RPC over the Supabase Data API)

Transport is **Supabase PostgREST**, not a custom `/v1` server:
- RPC calls: `POST {SUPABASE_URL}/rest/v1/rpc/<name>` with a JSON body of named parameters.
- Table reads: `GET /rest/v1/<table>?...`.

Every call needs `apikey: <publishable key>` and `Authorization: Bearer <user access token>`. The actor is always `auth.uid()` from that verified token; no endpoint accepts an actor id.

Source of truth: `supabase/migrations/20261113000300_rpc_core.sql`. Errors are HTTP 400 with `code: "P0001"` and `message: <error code>`; the Flutter layer maps them in `lib/data/live/live_errors.dart`.

## Common error codes
`not_authenticated`, `account_missing`, `onboarding_incomplete`, `account_restricted`, `account_deleted`, `forbidden`, `not_found`, `unavailable`, `self_action`, `rate_limited`, `idempotency_conflict`.

## Idempotency
Every side effect carries a caller-generated key, unique per actor:
- `decide`: `p_key`.
- `send_compliment`: `p_key`.
- `send_message` and `reply_compliment`: `p_client_message_id` (UUID).

Replaying the same key with the same payload returns the original result with `replayed: true`. The same key with a different payload returns `idempotency_conflict`.

## Endpoints
| RPC | Params | Returns | Rules / errors |
|---|---|---|---|
| `complete_onboarding` | `p_birth_date date, p_terms_version, p_privacy_version, p_community_version text` | `{result: active\|underage}` | 18+ (IST day). Birth date is then locked (`birth_date_locked`). Requires name, gender, bio, a prompt and ≥2 photos (`*_required`). Records consents. Grants 3 welcome credits once. |
| `set_location` | `p_lat, p_lng float, p_city text` | — | Stored rounded to 0.1°. `location_invalid`. Rate-limited. |
| `register_photo` | `p_object_path text, p_position int` | `{photo_id, status: pending}` | Path must be `<uid>/…` (`forbidden`). Object must exist (`object_missing`). JPEG/PNG/WebP only (`type_not_allowed`). Size `size_not_allowed`. Limit `photo_limit` (6, locked). `position_taken`. |
| `remove_photo` / `reorder_photos` | `p_photo uuid` / `p_photo_ids uuid[]` | — | Own photos only; reorder needs the complete active set (`photo_set_mismatch`). |
| `discovery_feed` | `p_limit int` (≤20) | `[card]` | Active member. Excludes self, blocked, decided, existing pair and incompatible members. Card has no birth date or coordinates. |
| `member_card` | `p_user uuid` | `card` | Counterpart or a compatible discoverable member only. |
| `decide` | `p_target uuid, p_kind like\|pass, p_key text` | `{result: recorded\|matched, conversation_id, likes_left}` | `quota_exhausted` (5 free / 15 Premium per IST day). `already_decided`, `unavailable` (blocked, hidden or incompatible). Simultaneous reciprocal likes make one conversation. |
| `send_compliment` | `p_target, p_target_kind photo\|prompt, p_target_ref uuid, p_body ≤150, p_key` | `{result: sent\|matched, conversation_id, spent_from}` | `no_credits`, `target_unavailable`, `already_sent`, `already_matched`, `reply_instead`, `already_decided`. Debit, request, message one and outbox are one transaction. |
| `reply_compliment` | `p_conversation, p_client_message_id, p_body` | `{result: replied, seq}` | Recipient only (`forbidden`). `not_pending`. Free. |
| `dismiss_compliment` | `p_conversation` | `{result: dismissed}` | Recipient only. No refund. The sender still sees it as pending. |
| `send_message` | `p_conversation, p_client_message_id uuid, p_body ≤1000` | `{result: sent, message_id, seq, created_at}` | `awaiting_reply` (pending Compliment), `match_expired`, `unavailable` (blocked or unmatched), `rate_limited`. |
| `mark_read` | `p_conversation, p_seq` | — | Own read pointer only. |
| `extend_match` | `p_conversation` | `{result: extended, deadline}` | `already_started`, `already_extended`, `match_expired`, `extension_allowance_used`. |
| `list_conversations` | — | `[{conversation_id, other_*, state, deadline, extended, last_message, unread, compliment}]` | `state`: `pending_incoming`, `pending_outgoing`, `new_match`, `expired`, `active` or `archived` (7 quiet days; reversible). |
| `likes_summary` | — | `{count, premium, people\|null}` | Identities only with a server-side Premium entitlement. |
| `my_wallet` | — | `{weekly, earned, purchased, total, premium, likes_left_today, streak:{run, today_qualified, decisions_today, cycle_progress}}` | Grants the Premium weekly credits lazily (once per IST week). |
| `unmatch` / `block_member` / `unblock_member` | `p_conversation` / `p_other` | — | Free. A block closes the pair for good; unblocking never reopens it. |
| `report_member` | `p_subject, p_category, p_note, p_conversation?, p_message?` | `{report_id}` | Evidence is copied at report time. Rate-limited. |
| `register_device` | `p_platform, p_token` | — | Push token (delivery not configured). |
| `account_state` | — | `{status, has_profile, birth_date, restorable_until}` | The member's own data only. |
| `request_export` | — | own data JSON | Only messages the member wrote. Rate-limited. |
| `request_account_deletion` / `restore_account` / `purge_account` | — | `{result}` | Hidden at once. Restorable for 28 days. Purge runs on the next worker pass. |
| `staff_*` | see SQL | | Moderator role only (`forbidden`). Every action is audited. |

## Direct table access (RLS)
| Table | Member access |
|---|---|
| `profiles` | Own row: read and update allowed columns. Counterparts: read. |
| `preferences` | Own row: read and update. |
| `prompts` | Own rows: read and write. Counterparts: read. |
| `photos` | Own rows: read. Counterparts' approved photos: read. |
| `messages`, `conversations` | Read when the conversation is visible to you (pending or open; dismissed for the sender). |
| `blocks`, `consents`, `devices`, `privacy_requests`, `conversation_reads` | Own rows: read. |
| `decisions`, `compliments`, `reports` | No direct access. |

**Storage:** the private bucket `photos`, with uploads only into `<uid>/`. Signed URLs are issued per object while visibility holds; the app asks for 300-second URLs.

**Realtime:** `postgres_changes` on `messages` and `conversations`, filtered by the same RLS.

## Added in the continuation
| RPC | Params | Returns | Rules / errors |
|---|---|---|---|
| `register_attachment` | `p_conversation, p_object_path, p_kind image\|voice, p_duration_ms?` | `{attachment_id, processing: pending}` | Path `<conversation>/<uid>/…` in `chat-media`; open conversation only. Sniffed type (`type_not_allowed`), `size_not_allowed`, voice ≤120 s, `kind_not_supported` (video), rate-limited. |
| `attachment_status` | `p_attachment` | `{processing, failure_reason}` | Uploader only. |
| `send_attachment` | `p_conversation, p_client_message_id, p_attachment, p_caption?` | `{result: sent, seq, …}` | Attachment must be `ready` (`attachment_not_ready`); idempotent on the client id. |
| `set_notification_prefs` | `p_matches, p_messages, p_compliments bool` | — | Own preferences. |
| `unregister_device` | `p_token` | — | Own device. |
| `request_export` | — | `{request_id, status: pending}` | Now **asynchronous**. Requires a sign-in within 15 minutes (`reauth_required`); the worker writes a 7-day object to `exports/<uid>/`. |
| `staff_photo_queue` / `staff_decide_photo` | | | Only `processing = ready` photos. |
| `staff_clear_hold`, `staff_ops_health` | | | Moderator; audited. |
| `service_apply_purchase_state`, `service_record_store_event`, `service_purchase_by_key` | | | `service_role` only (Edge Functions). |

**Edge Functions:**
- `POST /functions/v1/verify-purchase`, with a member JWT and body `{store: google_play | app_store, product_id, purchase_token | signed_transaction}`.
- `POST /functions/v1/store-notifications/google` (Pub/Sub push, OIDC) and `/apple` (signed payload).

Both answer 503 `store_not_configured` until enabled.

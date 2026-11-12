# Conversation contract: Compliments are conversation events

Implements document 04 on the existing on-device demo repository. There is no backend in this project, so this describes front-end and repository-boundary behaviour only.

## Model (existing, not migrated)

- **Event:** `Compliment`
  - Fields: `id` (stable), `personId` (the other member), `fromMe` (direction, which gives sender and recipient), `target` (photo or prompt, with index), `text`, `sentAt`, `referenceText` (the context snapshot) and `status` (pending, replied, dismissed, blocked).
  - Unavailable media is handled by `referenceAvailable`, which shows "No longer available".
- **Thread identity:** keyed by the other member's stable `personId` (`DatingState.threads[personId]`).
  - Before a reply, there is no thread: the chat route `/chat/:personId` renders the pending Compliment as the conversation (`ComplimentThread`).
  - Replying calls `openFromRequest`. That creates the match and the thread with the Compliment as message one, and its `context` is kept.
  - The route stays the same, so nothing navigates and no duplicate is created.
- **Compatibility map:** existing pending Compliments need no data change.
  - `convertOnMatch` already turns a pending Compliment into the first message when the pair matches another way.
  - The Messages list derives its rows from the same state, so the conversion is deterministic and repeatable.
  - There is no schema migration, and no live data exists.

## State contract

| State | Behaviour | Where |
|---|---|---|
| Draft | Editable and cancellable; no credit spent; leaving with words asks first. | `ComplimentComposer` (V7) |
| Sending | A per-pair in-flight guard (`_sending`); repeated taps cannot send twice. The debit key is `compliment:<personId>`, so a retry can never charge twice. | `ComplimentsController.send` |
| Pending | Shown in both members' Messages, sorted by time. The recipient's row is unread until opened and counts on the Messages badge. The sender's thread has no composer. | `MessagesScreen`, `ComplimentThread` |
| Recipient actions | Open the context (photo-led sender card, then the quoted photo or prompt), reply privately (free), Not now, report, block. | `ComplimentThread` menu and composer |
| Accepted | `reply` succeeds once: the status becomes `replied`, and a second call returns false. The thread keeps the Compliment first. | `ComplimentsController.reply` |
| Failed | The words are kept, nothing is spent, and Retry is offered. | V7 composer failure state |
| Blocked or unavailable | `hideFrom` marks pending Compliments blocked; the row disappears; `/request/:id` goes to Messages; a chat route for a non-match with nothing pending shows no composer. | `end(..., EndReason.blocked)`, router, `ChatScreen` guard |

**Rules unchanged:**
- One Compliment per pair.
- The credit is spent only once the send is accepted.
- Replying is free.
- Dismissing gives no refund.
- The sender cannot write until the recipient replies.
- There is no timer.

## Routes

| Link | Resolves to |
|---|---|
| `/request/:id` (notifications, saved links) | `/chat/:personId` while the Compliment is pending or the pair has matched; `/messages` otherwise (blocked, dismissed, unknown) |
| `/likes?tab=compliments` (old R03 notification link) | `/messages` |
| Heart tab | Likes only |

Signed-out links go through the existing auth redirect first. Local notification routing is not live push delivery.

## One row per person

The Messages list lists threads, then pending Compliments for people with no thread. A person who already has a thread never gets a second, Compliment row. This was added in this run.

## Verified

- `test/widget/conversation_contract_test.dart`, written for this brief:
  - Heart without Compliments; the old link goes to Messages.
  - One row per person.
  - The same thread on repeated links, with the photo-led sender card.
  - The sender cannot write.
  - Reply exactly once, free, with the Compliment first.
  - Block removes the row and the link.
- `test/widget/compliment_contract_test.dart`, from V7: one credit after acceptance; a failure keeps the words and retries; a second send is refused and not charged; no credits leads to the pack; the discard prompt.
- `test/widget/visual_lab_v2_test.dart`, V8 group, ported: reply from Messages and Not now.

## Server guarantees still missing

The demo repository is in-process. A real backend must provide:
- Atomic send-plus-debit and an idempotency key across devices.
- Recipient-side delivery.
- Server-enforced reciprocity.
- Moderation and abuse limits.
- Push routing.
None of these exist here.

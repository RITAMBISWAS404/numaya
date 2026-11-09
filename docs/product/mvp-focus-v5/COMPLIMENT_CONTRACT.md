# Compliment contract

The user-facing name stays Compliment. These transitions run through the existing demo controller, `ComplimentsController`. **They are local demo transitions, not server guarantees.** A real service must enforce the same rules.

Bumble's documented behaviour, from its Sending Notes help page: Notes are limited to 150 characters and a Note does not open chat by itself.
**Numaya's approved difference:** the recipient's reply opens the chat, atomically. No second mutual-swipe gate is added.

## Rules
| Rule | Behaviour |
|---|---|
| Length | Up to 150 characters a member sees, counted as graphemes after trimming. An emoji counts as one. Whitespace-only is empty. |
| Target | One photo or one prompt answer. Not bio or interests. |
| Limit per pair | One. A second send is refused and not charged. |
| Debit | One credit, only after the send is accepted. The debit key is per pair, so it cannot charge twice. |
| Repeated taps | The button locks, and the controller refuses a second in-flight send for that person. |
| Failure or offline | Words stay, no credit is used, retry is available. |
| Closing with words | Asks first. Nothing is spent either way. |
| No credits | Offers the Compliment pack in place of Send. Words are not lost. |
| After sending | One confirmation in place, stating what happens next. No chat opens. |

## States
| State | Sender sees | Recipient sees | Chat |
|---|---|---|---|
| Pending | "You've sent [name] a Compliment" when reopening | Item in Heart, Compliments, with sender and target | Locked |
| Replied | Chat with the original Compliment first | Chat | Open, one thread |
| Dismissed | Nothing | Item gone. One introduction per pair, so no resend | Locked |
| Blocked | Unavailable | Item gone | Locked |
| Mutual match while pending | Converted to the first message of that chat | Same | Open, one thread |
| Target removed | Honest "no longer available" line | Same | Unchanged |

Report and block are free and sit in the request's menu. New matches stay in Messages, not in Heart.

Tests: `test/widget/compliment_contract_test.dart`, `mvp_screens_test.dart`.

# V8 design system changes

Branch `version-8`, from tag `checkpoint/v7-selected-baseline-20261111` (`b5e5245`). V7 is untouched.

## Foundations

- **Type:** Google Sans for every functional element, and Bree Serif for one expressive line per page. See [TYPOGRAPHY.md](TYPOGRAPHY.md).
- **Radius scale (`MonoRadii`):** tag 8, chips/segments/icon tiles 10, buttons/fields/tiles 12, cards 16, hero cards/sheets/the navigation bar 20, dialogs 16, media 14. Pills remain only for progress bars, dots and badges.
- **Buttons:** primary stays solid purple. Secondary and quiet buttons are a 1pt low-opacity ink outline on a near-transparent wash. The brand button is a purple label in a faint purple outline. Disabled, loading and pressed states are unchanged.
- **Separators:** grouped rows draw an inset hairline between rows, inside the card too. The conversation list is rows on the page with hairlines inset to the text.
- **Colour:** brand purple and the existing semantic tokens are unchanged. `MonoArt` holds illustration colours (secondary marks only, never text). `MonoButtons` holds the outline and wash.

## Components

- **`InfoTile`:** icon, heading, primary value, visual and metadata, in that order. `InfoTilePair` places two side by side, stacking them at narrow widths or large text. It is used for Profile's Your activity.
- **`SegmentBar` and `StepMarks`:** card visuals (credit buckets, streak days).
- **`SceneArt`:** code-drawn, lit, rounded scenes (conversation, waiting, discover, celebrate, premium, flame, heart, profile). They can follow real state through `progress` and `level`. `IllustrationView` maps the earlier illustration names to scenes centrally. The flat drawings remain only for unmatched, blocked and the deferred Events art.
- **`ChatHeader`:** shared by chat and the Compliment thread.
- **`MessageBubble`:** shows its time inside the bubble, and its quote can carry a Compliment's context.

## Messaging (WhatsApp-inspired)

- **No Compliments tab.** The Heart tab is likes only. A pending Compliment appears in Messages as a conversation row with a Compliment mark, sorted by time with the chats. It is unread until opened and counts on the Messages tab badge.
- **Received:** the chat route shows the Compliment as the first message, quoting your photo or prompt. You reply privately in the composer, and the same route becomes the conversation, with the Compliment kept as its first message.
- **Sent:** the chat route shows your Compliment and a waiting state. The sender still cannot write until the recipient replies.
- **Links:** `/request/:id` (notifications and saved links) opens the conversation while the Compliment is pending or answered, and goes to Messages otherwise. `/likes?tab=compliments` goes to Messages.
- **Safety:** View profile, Not now, Report and Block stay in the conversation menu. A chat route for someone you are not matched with, and who has no pending Compliment, shows nothing to write in.
- **Rules unchanged:** one Compliment per pair, the credit is spent only when the send is accepted, replying is free, and dismissing gives no refund.

## Motion

The existing tokens already respect reduced motion: a 280ms route push on an emphasized curve, a 200ms pop, rising sheets and new messages settling in. V8 adds a 600ms ease-out for scene state changes. It does not add tab cross-fades, because the shell keeps each tab's state, and wrapping it would rebuild those trees.

## Not done in V8

- **Backend:** the message model is the existing on-device demo. No schema migration was needed, because a Compliment converts into the thread's first message exactly as before.
- **Read and delivery receipts:** not shown, because no backend reports them. The existing "Not sent: saved on this device" status remains.

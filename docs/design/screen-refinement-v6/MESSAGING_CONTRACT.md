# Messaging contract, V6

Local adapters only. No message, photo or voice note leaves the device. The app shows "Not sent: saved on this device" on sent messages.

| Feature | Behaviour | Boundary |
|---|---|---|
| Text | Mic becomes Send in the same slot once there is text | Local demo thread |
| Quoted reply | Rounded block, inset capsule stripe that cannot reach the corners, sender and excerpt, wraps safely | Tap moves to the original when it exists |
| Original removed | "Original message unavailable" | `removeMessage` simulates moderation or deletion |
| Reply to a photo | Thumbnail in composer preview and in the sent quote | Local |
| Photo | Choose from library or take a photo; preview with remove; caption; full-screen view | Real picker; file stays on device |
| Permission denied or cancelled | Explained, nothing attached | Real picker |
| Failed send | Retry from the bubble | Simulated failure |
| Voice | Tap mic to record; shows real elapsed time; bin discards; stop previews; Send sends; leaving discards | `record` plugin on the device. **Not verified with a real microphone** on the emulator |
| Voice permission | Requested when recording starts, with a clear message if refused | `RECORD_AUDIO` in the manifest |
| Voice playback | Play and pause with a position bar, not a fake waveform | `audioplayers` for real files; silent demo player for sample notes, which say "Demo note, no sound" |
| Video | Removed from the menu; an older video still shows as a file card | No player in this build |
| Compliments | See `docs/product/mvp-focus-v5/COMPLIMENT_CONTRACT.md`, unchanged | Local |

Interaction references: WhatsApp reply preview and sent quote, voice recording, photo preview.
Tests: `test/widget/chat_v6_contract_test.dart`, `chat_media_test.dart`.

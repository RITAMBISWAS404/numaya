# Scope matrix: active screens and actions → API, permission, data and test

Events and Health are excluded (not routed in the V8 app; no APIs). Opening Moves, SuperSwipe and Follow are release-gated off; they have no APIs.

| Screen / action (route) | API | Permission | Data | Test | Status |
|---|---|---|---|---|---|
| Phone, Verify (`/phone`, `/verify`) | Supabase Auth OTP | anon → member | auth.users | `auth_phone.test` | adapter written |
| Setup: name, gender, open to, intentions, pronouns, interests, prompt, bio, height | `profiles`, `prompts` (RLS) | own | profiles, prompts | permissions (own-only writes) | written |
| Setup photos (`/setup/photos`) | Storage upload + `register_photo` | own folder | photos | storage + 6-cap tests | written |
| Setup location (`/setup/location`) | `set_location` | own | private.locations | feed-fields test | **not wired in app** (location screen still on-device) |
| Setup review → create | `complete_onboarding` | own | accounts, consents, ledger | under-18 test, welcome credits test | written |
| Discover: deck, like, pass | `discovery_feed`, `decide` | member | decisions, conversations | matching tests | written |
| Discover filters (Premium advanced) | client-side on the server feed | member | — | — | partial: the server applies preferences; advanced filters are client-side |
| Undo | — | — | — | — | **not supported live** (no server undo; decision is final) |
| Likes tab (count; Premium list) | `likes_summary` | member; identities need Premium | decisions | Premium test | written |
| Compliment send | `send_compliment` | member, credits | compliments, ledger, messages | credit concurrency tests | written |
| Compliment reply / Not now | `reply_compliment`, `dismiss_compliment` | recipient | same | compliment tests | written |
| Messages list, archive, new matches | `list_conversations` | member | conversations | archive/expiry tests | written |
| Chat send, retry, offline | `send_message` (client id) | member of an open conversation | messages | sequence/retry tests | written |
| Chat realtime | Realtime `postgres_changes` | RLS | messages | realtime test | written |
| Extend match | `extend_match` | member | conversations | expiry test | server written; app still uses its local rule |
| Unmatch / block / unblock / report | RPCs | member | blocks, reports | safety tests | written |
| Wallet, streak | `my_wallet` | member | ledger, daily_usage | streak/cap tests | written |
| Store: Premium, credit packs, streak recovery | none (no billing) | — | — | — | **not started**; purchases fail in live builds |
| Settings: notifications, privacy toggles | — | — | — | — | on-device only |
| Delete / restore / delete for good | RPCs + worker | member; service | tombstones | privacy test | written |
| Export my data | `request_export` | member | — | export test | server written; **no app entry point** in V8 |
| Photo verification (`/profile/verify`) | — | — | — | — | deferred (vendor) |
| Help, legal | static | — | — | — | unchanged |

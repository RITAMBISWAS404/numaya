# Permission matrix

Roles:
- **anon:** publishable key, not signed in.
- **member:** signed in, active.
- **counterpart:** a member in a visible conversation with the row's owner.
- **other:** any other member.
- **moderator:** `private.staff_members`.
- **service:** secret key or database owner (server tools only).

| Resource | anon | member (own) | counterpart | other | moderator | service |
|---|---|---|---|---|---|---|
| `profiles` | – | read; update allowed columns | read | – (cards via RPC) | via queues only | all |
| `preferences` | – | read/write | – | – | – | all |
| `prompts` | – | read/write | read | – (cards) | – | all |
| `photos` rows | – | read | read approved | – (cards) | approve/reject (RPC) | all |
| Photo objects | – | upload/read/delete own folder | signed URL if approved and unblocked | signed URL if approved, discoverable and unblocked | queue paths | all |
| `decisions` | – | via `decide` only | – | – | – | all |
| `conversations`, `messages` | – | read when visible; write via RPC | same | – | reported evidence only | all |
| `compliments` | – | via RPCs and `list_conversations` | – | – | – | all |
| `blocks` | – | read own; write via RPC | – | – | – | all |
| `reports` | – | create via RPC | – | – | read queue, resolve | all |
| Ledger, entitlements, accounts, locations (private) | – | own summary via `my_wallet` / `account_state` | – | – | – | all |
| Staff role | – | – | – | – | – | owner SQL only |
| Realtime `messages`/`conversations` | – | own visible rows | same | – | – | – |
| RPC execute | none | all member RPCs | – | – | `staff_*` | – |

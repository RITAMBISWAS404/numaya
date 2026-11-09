# Launch readiness

**Status: internal front-end test build only. Not ready for public launch.** A polished APK does not make this a live dating platform. The app has no network layer, and no backend is connected.

| Stage | Status |
|---|---|
| Demo for the team | Ready, using the debug APK and demo data |
| Internal test with real people | Blocked by everything below: two phones cannot see each other |
| Public launch | Blocked |

| Area | Actual status in the code | Consequence | Who is needed |
|---|---|---|---|
| Phone OTP | `DemoAuthRepository`; no SMS is sent. Release builds use `UnconfiguredAuthRepository`, so sign-in fails | No one can sign in on a release build | Backend owner, SMS provider |
| Server authentication and authorization | None | No accounts exist | Backend owner |
| Consent and age gating | Client checks only (date of birth, under-18 stop, terms links) | Not enforceable; legal text is marked draft | Legal, backend |
| Persistence | In memory only (`InMemoryProfileRepository`; no local database) | Everything resets on restart | Backend owner |
| Matching and message delivery | Local sample people and local messages | No real matches or delivery | Backend owner |
| Compliment send, credits, entitlements | Local rules, see the contract | Not fraud-resistant without a server | Backend owner |
| Abuse reporting and moderation | Report, block and unmatch work locally; nothing reaches a team | Unsafe to open to the public | Trust and safety owner |
| Photo moderation and verification | Simulated | No review happens | Trust and safety owner |
| Account deletion | Local simulation with restore messaging | No real data deletion | Backend, legal |
| Permissions and privacy disclosures | Manifest requests none; the in-app primers are simulated. Privacy text is a draft | Store listing cannot be completed | Legal, product |
| Billing | `DemoStoreGateway`; release builds use an unconfigured gateway. Prices are provisional | No purchases possible | Product, Play billing |
| Notifications | None delivered | Reminders do not reach phones | Backend owner |
| Signing and release config | Release uses the debug signing config | Cannot ship to Play | Release owner |
| Physical device, iOS, screen reader | Not run | Blur, keyboard and gesture feel are unverified on hardware | QA |

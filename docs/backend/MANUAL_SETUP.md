# Manual setup: the owner actions an agent cannot do

Only actions that need **your** account, identity, money, legal authority or judgement are listed.
Everything else is automated by `tools/backend/scripts/activate.mjs` ([ACTIVATION_RUNBOOK.md](ACTIVATION_RUNBOOK.md)).

**Rules for every item**
- Put values only in `supabase/.env.local`. It is git-ignored; copy `supabase/.env.example` to create it.
- Never paste a value into chat, an issue, a commit or a screenshot.
- Optional groups are all-or-nothing: fill every variable in a group or leave the whole group empty.
- Check after each step with `cd tools/backend && npm run activate -- --check`. It validates shapes only, without touching the network.

Part A is technical setup. Parts B–D are launch requirements that credentials do not satisfy.
**Finishing Part A does not make the app launch-ready.**

---

## Part A: Technical setup

### A1. Supabase development project (required: unlocks almost everything)

| | |
|---|---|
| **What** | A free Supabase project used only for development. Do not reuse it for production. |
| **Where** | supabase.com/dashboard → *New project*, on the Free plan, region *South Asia (Mumbai)*. Choose a strong database password and keep it in your password manager. |
| **Collect** | `SUPABASE_PROJECT_REF`: the 20-character id in the project URL.<br>`SUPABASE_URL`: `https://<ref>.supabase.co`.<br>`SUPABASE_PUBLISHABLE_KEY` (`sb_publishable_…`) and `SUPABASE_SECRET_KEY` (`sb_secret_…`): *Project Settings → API Keys*. Use *Create new API keys* if only the legacy anon/service_role keys are shown.<br>`SUPABASE_DB_PASSWORD`.<br>`SUPABASE_DB_URL`: *Connect* (top bar) → *Session pooler*, with the password filled in. Use this, not the direct string: free-plan direct connections are IPv6-only. |
| **Store** | `supabase/.env.local`. The secret key and DB password are server-only and never go into the app or Git. |
| **Enables** | Migrations, RLS and RPC verification, storage, realtime, workers, real-service tests, the dev APK. |
| **Cost / approval** | Free. No payment method. Free projects pause after about a week without activity; *Restore* in the dashboard brings them back. |
| **Verify** | `npm run activate -- --confirm-project=<ref> --only=connect` |

Leave the dashboard defaults alone:
- *Settings → Data API → Exposed schemas* stays `public` (and `graphql_public`). The `schema` step fails if `private` is exposed.
- *Authentication → Sign In / Providers → Email* stays enabled. The test harness creates confirmed email test users.

### A2. Personal access token (required for Edge Functions, optional otherwise)

| | |
|---|---|
| **What** | `SUPABASE_ACCESS_TOKEN`. |
| **Where** | supabase.com/dashboard/account/tokens → *Generate new token*, named "numaya-dev-activation". Set an expiry. |
| **Store** | `supabase/.env.local`. |
| **Enables** | Deploying `verify-purchase` and `store-notifications`, and setting function secrets. Migrations do not need it. |
| **Cost / approval** | Free. The token can manage **all** your Supabase projects: revoke it when activation is done. |
| **Verify** | `npm run activate -- --confirm-project=<ref> --only=functions` |

### A3. Phone sign-in with test numbers (required for the APK)

| | |
|---|---|
| **What** | The Phone provider enabled with two test numbers and fixed OTPs. Test numbers never send an SMS. |
| **Where** | *Authentication → Sign In / Providers → Phone*. Enable it. The dashboard requires an SMS provider before it saves; a **Twilio trial account** works (twilio.com, free trial, phone verification needed): enter its Account SID, Auth Token and a Messaging Service SID. Under *Test Phone Numbers and OTPs*, add two entries such as `919000000001=123456` and `919000000002=654321`, and set a far expiry date. |
| **Collect** | `NUMAYA_TEST_PHONE_A` and `NUMAYA_TEST_OTP_A`, `NUMAYA_TEST_PHONE_B` and `NUMAYA_TEST_OTP_B`: digits only, country code first, no `+`. |
| **Store** | Twilio credentials stay in the Supabase dashboard only. Test numbers go in `supabase/.env.local`. |
| **Enables** | Phone OTP sign-in in the APK, and the `auth_phone` real-service test. |
| **Cost / approval** | Test numbers are free. **Real SMS costs money** and, for Indian numbers, needs DLT sender and template registration (Part D). Do not top up the trial for development. |
| **Verify** | `npm run activate -- --confirm-project=<ref> --only=auth` should report `"phone":true`. Then `--only=tests`. |

### A4. Backup encryption key (required before any real data)

| | |
|---|---|
| **What** | `NUMAYA_BACKUP_KEY`: 32 random bytes, base64. |
| **Where** | Generate it locally: `node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"`. |
| **Store** | `supabase/.env.local`, plus a second copy in your password manager. Without the key, backups cannot be restored. |
| **Enables** | `npm run backup` (AES-256-GCM) and `npm run restore:drill`. |
| **Cost / approval** | Free. |
| **Verify** | `npm run backup`, then `npm run restore:drill` (non-destructive: restores into a throwaway schema). |

### A5. Staff (moderator) account (required for photo review)

New photos stay hidden until a moderator approves them, so a dev project without a staff account has no visible profiles.

| | |
|---|---|
| **What** | An email/password user holding the moderator role. |
| **Where** | 1. *Authentication → Users → Add user → Create new user*, with *Auto Confirm User* ticked. Use an address you control.<br>2. In *SQL Editor*, as the owner, run:<br>`insert into private.staff_members (user_id, role, granted_by) select id, 'moderator', 'owner' from auth.users where email = '<that email>';` |
| **Collect** | `NUMAYA_STAFF_EMAIL` and `NUMAYA_STAFF_PASSWORD`. |
| **Store** | `supabase/.env.local`, on the machine of whoever moderates. |
| **Enables** | `npm run staff -- photos | approve | reject | reports | resolve | clear-hold | health`. |
| **Cost / approval** | Free. Choosing who holds the role is a Part C decision. MFA for staff is a launch requirement. |
| **Verify** | `npm run staff -- health` |

### A6. Worker schedule (required for a usable beta)

Photo and attachment processing, exports, push and the purge run in the Node worker (`npm run worker`). Postgres housekeeping runs in pg_cron, which needs no action. Pick **one** schedule for the worker.

| | |
|---|---|
| **Option 1: GitHub Actions** (the repository is public; standard runners are free) | 1. Repository *Settings → Environments → New environment* `development`.<br>2. Add secret `NUMAYA_DEV_ENV_LOCAL` containing the whole of `supabase/.env.local`.<br>3. *Settings → Secrets and variables → Actions → Variables*: add `NUMAYA_WORKER_SCHEDULE` = `on`.<br>The worker then runs every 15 minutes. GitHub disables schedules after 60 days without repository activity. |
| **Option 2: this PC** | Windows Task Scheduler: run `node worker/run.mjs --once` in `tools\backend` every 5 minutes. It only runs while the PC is on. |
| **Cost / approval** | Free. Option 1 puts dev-project secrets in GitHub's secret store: your call. |
| **Verify** | Option 1: the *backend* workflow's *worker* job is green. Option 2: `npm run monitor` shows no `oldest_review_minutes` alert caused by unprocessed photos. |

### A7. Push notifications: Firebase Cloud Messaging (optional; push stays off without it)

| | |
|---|---|
| **What** | A Firebase project with the Android app registered, and a service-account key. |
| **Where** | console.firebase.google.com → *Add project* (Spark plan). *Add app → Android*, package `com.numaya.numaya_mobile`; download `google-services.json` and keep it out of Git. Then *Project settings → Service accounts → Generate new private key*, and base64 it: `node -e "console.log(require('fs').readFileSync(process.argv[1]).toString('base64'))" key.json`. Delete the downloaded key file afterwards. |
| **Collect** | `FCM_SERVICE_ACCOUNT_JSON` (base64). Hand `google-services.json` to the engineer building the app; it is not a secret but stays private. |
| **Store** | `supabase/.env.local` (and the `NUMAYA_DEV_ENV_LOCAL` secret if you use Option 1). |
| **Enables** | The server push sender, which is implemented and contract-tested. **Device delivery still needs engineering work** (`firebase_messaging` token capture in the app): adding the key alone does not deliver notifications. |
| **Cost / approval** | FCM is free. Your Google organisation policy may block service-account key creation. |
| **Verify** | `npm run activate -- --confirm-project=<ref> --only=worker`: `push` no longer reports `disabled`. |

### A8. Store purchases (optional; purchases stay off without it)

The server verification is implemented and contract-tested with fixtures. The **app has no billing UI yet**, so these items only matter once that work is scheduled.

| | Google Play | Apple App Store |
|---|---|---|
| **Account** | Play Console developer account. **One-time USD 25 fee, identity verification.** | Apple Developer Program. **USD 99 per year.** |
| **Products** | In-app products and subscriptions with IDs `numaya_premium_weekly`, `numaya_premium_monthly`, `numaya_premium_yearly` and `numaya_compliments_3`. **Prices are a business decision.** | The same product IDs in App Store Connect. |
| **Credential** | 1. Google Cloud: enable *Google Play Android Developer API*.<br>2. Create a service account and a JSON key, base64 it → `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`.<br>3. Play Console → *Users and permissions*: invite the service account with *View financial data* and *Manage orders and subscriptions*.<br>4. `GOOGLE_PLAY_PACKAGE_NAME` = the app's package name. | `APPLE_BUNDLE_ID`.<br>`APPLE_ROOT_CA_G3_SHA256`: download *Apple Root CA - G3* from apple.com/certificateauthority, then run `openssl x509 -inform der -in AppleRootCA-G3.cer -noout -fingerprint -sha256`. |
| **Notifications** | Pub/Sub topic. Play Console → *Monetization setup → Real-time developer notifications*: set the topic. Push subscription to `https://<ref>.supabase.co/functions/v1/store-notifications/google` with authentication enabled: service account → `GOOGLE_PUBSUB_PUSH_SERVICE_ACCOUNT`, audience → `GOOGLE_PUBSUB_PUSH_AUDIENCE`. | App Store Connect → App → *App Store Server Notifications*, version 2, Sandbox URL `https://<ref>.supabase.co/functions/v1/store-notifications/apple`. |
| **Store** | `supabase/.env.local`, then `npm run activate -- --confirm-project=<ref> --only=secrets --with-function-secrets`. | Same. |
| **Turn on** | Manual and deliberate: `npx supabase secrets set --remote=<ref> STORE_VERIFICATION_ENABLED=true`. To let sandbox purchases grant benefits on the dev project: `--only=store-env --store-env=sandbox`. | Same. |
| **Verify** | A sandbox purchase from a licence-tester account, then `npm run staff -- health`. Not automatable today: no billing client exists. | Sandbox tester purchase; same limitation. |

### A9. Docker Desktop (optional)
Runs the full local Supabase stack (`supabase start`, `supabase db diff`). It needs administrator rights and WSL2, and is free for personal and small-business use. Hosted-dev activation does not need it.

---

## Part B: Legal and policy approvals (before any external tester)
- ☐ Terms of Service, Privacy Policy and Community Guidelines approved by counsel. Dev records consent version `2026-11-draft`; bump `kConsentVersion` when approved.
- ☐ India DPDP Act 2023: notice and consent text, data-principal rights (export and deletion are implemented), breach notification process, grievance contact.
- ☐ IT Rules 2021 intermediary duties: grievance officer, complaint timelines, takedown process.
- ☐ Retention periods ([DECISIONS_REQUIRED.md](DECISIONS_REQUIRED.md) P4): report evidence, audit log, tombstones, backups.
- ☐ Age assurance: 18+ self-declaration is implemented; counsel confirms whether that suffices.
- ☐ SMS: DLT entity, header and template registration before real OTP SMS to Indian numbers.
- ☐ Store listings: privacy labels and data-safety forms.

## Part C: Moderation and safety staffing
- ☐ Named moderation lead and back-up. Photo-review coverage hours: the monitor alerts after 240 minutes in the queue (P10).
- ☐ Safety-report response target: the monitor alerts after 24 hours (P10). Escalation path for threats, minors and non-consensual imagery (child-safety contact, law-enforcement requests).
- ☐ Who holds staff roles; staff MFA; quarterly role review.
- ☐ Report hold threshold (3 distinct reporters in 24 hours places a review hold; FIXTURE) confirmed or changed.

## Part D: Operational launch requirements
- ☐ Production Supabase project on a paid plan (point-in-time recovery, no pausing), created separately, with its own keys. **Costs money; needs approval.**
- ☐ Real SMS provider with budget and rate alarms. **Costs money.**
- ☐ On-call owner for monitor alerts, and an incident runbook.
- ☐ Support channel (email or in-app) and the response target.
- ☐ Signed release build (upload key in a secure keystore, never in Git) and store review.
- ☐ Load and abuse testing on the production-shaped project; penetration test or security review.
- ☐ Backup restore drill on the production project, with the result recorded.

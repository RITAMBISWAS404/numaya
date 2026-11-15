# Activation runbook: Numaya development backend

Run this after the Part A items in [MANUAL_SETUP.md](MANUAL_SETUP.md) that you want active (A1 is the minimum; A3 and A5 are needed for a usable APK).
It targets the **development** project only. Production activation is a separate, owner-approved process (MANUAL_SETUP Part D).

## 0. Prerequisites (once per machine)
```bash
cd C:/Users/biswa/Projects/Numaya-backend/tools/backend
npm ci
npm run check:local      # SQL lint, local Postgres semantic checks, contract tests: must be green
npm run activate -- --check   # validates supabase/.env.local shapes, no network
```

## 1. Run the activation
```bash
npm run activate -- --confirm-project=<your dev project ref> --plan-only
npm run activate -- --confirm-project=<your dev project ref>
```
The first run applies nothing: it shows the pending migrations so you can review them. The second applies them and runs every step below.

| Step | What it does | Changes the project? | Fails when |
|---|---|---|---|
| `config` | Shape-checks `.env.local` (key prefixes, ref/URL/DB match, optional groups all-or-nothing) | no | anything malformed |
| `confirm` | Refuses unless `--confirm-project` equals the configured ref | no | ref differs |
| `connect` | Auth health, DB connection, secret key accepted by the Admin API (retries) | no | wrong keys / password / pooler |
| `auth` | Reads public Auth settings: Email must be on, Phone should be on | no | Email disabled |
| `migrate` | `db push --dry-run`, then `db push --include-all` (retries; never resets) | **yes**: schema | SQL error |
| `schema` | All migrations recorded; RLS on every public table; 3 private buckets; `private` not exposed; anonymous reads nothing | no | any check |
| `store-env` | Only with `--store-env=sandbox` or `production`: which store environment may grant benefits (audited) | **yes**: one setting | bad value |
| `secrets` | Only with `--with-function-secrets`: pushes store secrets from `.env.local` (never `STORE_VERIFICATION_ENABLED`) | **yes**: function secrets | CLI error |
| `functions` | Only when `SUPABASE_ACCESS_TOKEN` is set: deploys `verify-purchase`, and `store-notifications` with `--no-verify-jwt`; probes both | **yes**: functions | deploy error |
| `schedules` | pg_cron job `numaya-housekeeping` present and active; runs `private.housekeeping()` once | runs housekeeping | job missing |
| `worker` | One pass of every worker job (photos, attachments, push, exports, purge, sweep) | processes queues | any job throws |
| `monitor` | Queue ages and backlogs; prints alerts (does not fail the run) | no | — |
| `tests` | Real-service suite `tools/backend/tests/` against the project (creates and deletes labelled test users) | test data, cleaned up | any failure |
| `apk` | Debug APK with the dev URL and **publishable** key; records SHA-256 and commit (`--attachments` turns live chat media on; `--skip-apk` skips) | no | build error |

**Report:** each run writes `docs/backend/evidence/activation-<time>.json`, redacted, with the commit SHA. Commit it with the handoff records as evidence.

**Resume:** a failed step prints the exact command, for example `npm run activate -- --confirm-project=<ref> --from=tests`. `config` and `confirm` always re-run. Every step is safe to repeat: migrations already applied are skipped, deploys overwrite, and tests create fresh users.

**Never automated:** reset, drop, prune, deleting functions or users, enabling paid add-ons, turning on `STORE_VERIFICATION_ENABLED`, and anything against a project not labelled development.

## 2. After a green run
1. **Install the APK** on the emulator or a phone. The report has its path and SHA-256. It is a private dev build: do not upload it publicly.
   ```bash
   adb install -r apps/numaya_mobile/build/app/outputs/flutter-apk/app-debug.apk
   ```
2. **Two-user check:** sign in on two devices or emulators with test numbers A and B, and complete onboarding with photos.
3. **Approve the photos** (they stay hidden until approved), then run the worker and staff commands:
   ```bash
   npm run worker && npm run staff -- photos
   ```
   ```bash
   npm run staff -- approve <photo id>
   ```
4. Like each other, chat (realtime), send a Compliment, extend a match, then block or unmatch, and confirm both sides update.
5. **Chat media** (optional): rebuild with `--only=apk --attachments`, send a photo and a voice note, and run `npm run worker` to process them.
6. **Backups:** run `npm run backup`, then `npm run restore:drill`. Record the result in `VALIDATION.md`.
7. **Schedule the worker** (MANUAL_SETUP A6) and check `npm run monitor` the next day.

## 3. Turning features on (each one deliberate)
| Feature | Command | Verify |
|---|---|---|
| Push (server side) | Add `FCM_SERVICE_ACCOUNT_JSON` to `.env.local`; the worker picks it up | `--only=worker` shows `push` processed, not `disabled`. Device delivery also needs app-side token capture (not built). |
| Store verification | `--only=secrets --with-function-secrets`, then `npx supabase secrets set --remote=<ref> STORE_VERIFICATION_ENABLED=true` (with `SUPABASE_ACCESS_TOKEN` exported) | Sandbox purchase; needs the billing client (not built). |
| Sandbox purchases grant benefits (dev only) | `--only=store-env --store-env=sandbox` | `npm run staff -- health` |
| Live chat media in the app | `--only=apk --attachments` | Step 2.5 |

To turn store verification off again: `npx supabase secrets unset --remote=<ref> STORE_VERIFICATION_ENABLED`. Functions then answer 503 `store_not_configured`.

## 4. Errors you may see
| Message | Meaning / fix |
|---|---|
| `Backend not configured: … .env.local is missing` | Copy `supabase/.env.example` to `supabase/.env.local` and fill A1. |
| `target not confirmed` | Pass `--confirm-project=<ref>`, after checking that it is the dev project. |
| `publishable key rejected` / `secret key rejected` | Wrong or rotated key: copy again from *Project Settings → API Keys*. |
| `ENETUNREACH` / `ENOTFOUND` on the DB | You used the direct (IPv6) string: use *Connect → Session pooler*. A paused project: *Restore* it. |
| `Email provider is disabled` | Re-enable Email under *Authentication → Sign In / Providers*. |
| `the private schema is exposed` | *Settings → Data API*: remove `private` from exposed schemas. |
| `pg_cron not readable` | *Database → Extensions*: enable `pg_cron`, then `--from=migrate`. |
| `worker job failed: photos …` | Usually the secret key or storage: rerun `--only=worker` and read the job error. |
| Tests fail on `auth_phone` | Test number or OTP mismatch, or the Phone provider is off (A3). |
| `flutter build failed` | Run `flutter doctor`; the build log tail is printed. |

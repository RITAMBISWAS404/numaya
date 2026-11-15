# Backup, restore and operations runbook

Git backs up source code only. The database, photos and secrets are backed up separately:

- **Supabase Free has no automatic backups or PITR.**
- Supabase platform backups never include storage objects.

## Manual encrypted backup (development)
1. Put `NUMAYA_BACKUP_KEY` in `supabase/.env.local`. It must be 32 random bytes, base64. Keep a copy offline: without it the backup cannot be read.
2. Run `node tools/backend/scripts/backup.mjs`. This writes `backups/<timestamp>/`, which is git-ignored and encrypted per file. It contains every `public`/`private` table, auth user ids, the photo objects and `manifest.json` (counts and SHA-256).
3. Copy the folder to private offline storage. Never put it in Git, chat or a public drive.

## Restore drill (isolated)
`node tools/backend/scripts/restore_drill.mjs [<backup folder>]`:
- Restores into a throwaway schema.
- Checks counts and checksums, and checks that every photo decrypts to its recorded hash.
- Replays completed deletions (tombstones from the backup and from the live database), then proves no deleted member's rows remain.
- Drops the schema.

Exit code 0 means pass. Automated by `tests/backup_restore.test.mjs`.

## Full environment restore (not yet rehearsed)
1. Create a new project.
2. Run `npm run db:push` against it.
3. Re-create the auth users (owner; phone numbers come from Supabase's auth export, never from these backups).
4. Load tables in FK order from the decrypted JSON lines.
5. Re-upload objects.
6. Replay tombstones, then the privacy worker.
7. Only then switch the app URL.

**RPO/RTO:** an owner decision with budget. Today, RPO equals the age of the last manual backup.

## Operations
| Task | How | Schedule (needed before beta) |
|---|---|---|
| Purge deletions after 28 days | `node tools/backend/scripts/privacy_worker.mjs` | Daily (cron on a trusted machine or a scheduled function) |
| Photo review | `staff_photo_queue` / `staff_decide_photo` as a moderator | Within the agreed SLA |
| Report triage | `staff_report_queue` / `staff_resolve_report` | Within the agreed SLA; critical cases immediately |
| Outbox delivery (push) | Not built: no provider | — |
| Migrations | `npm run db:push` (development only; refuses non-development) | On merge, by the single migrator |
| Credential rotation | Supabase dashboard: rotate the secret key and DB password, then update `.env.local` | On any suspicion; on staff change |
| Compromised account | `staff_resolve_report … suspend` or SQL status `suspended`; revoke sessions in Auth | Incident |

**Incident owner:** to be named (DECISIONS_REQUIRED).

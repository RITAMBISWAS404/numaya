# Active task: backend V1, waiting for dev project credentials

**Owner action:**
1. Create the free Supabase dev project.
2. Enable Phone with two test numbers.
3. Fill `supabase/.env.local` from `.env.example`, adding `NUMAYA_BACKUP_KEY` (32 random bytes, base64).

The full list is in [DECISIONS_REQUIRED.md](DECISIONS_REQUIRED.md).

**Then the backend session:**
1. `npm run db:push`.
2. `npm test`.
3. Fix platform findings.
4. Build the dev APK:

   `flutter build apk --debug --dart-define=NUMAYA_SUPABASE_URL=… --dart-define=NUMAYA_SUPABASE_PUBLISHABLE_KEY=… --dart-define=NUMAYA_BACKEND_LABEL=development`

5. Run the two-user journey (emulator plus phone, or two emulators).
6. Record evidence in VALIDATION.
7. Merge the latest completed frontend commit only at a FILE_OWNERSHIP checkpoint.

**Do not:** apply migrations to any non-development project, enable billing, or publish the APK.

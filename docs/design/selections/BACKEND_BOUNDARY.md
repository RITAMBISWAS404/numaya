# Frontend and backend boundary (checked read-only, 13 November 2026)

## Branches

| Checkout | Branch | Head | Relationship |
|---|---|---|---|
| `C:\Users\biswa\Projects\Numaya-fable-lab` (this pass) | `experiment/numaya-selected-20261113-0232` | see FINAL_REVIEW | From the Fable lab `c6a31a4` → replacement V8 `c890d02` |
| `C:\Users\biswa\Projects\Numaya-backend` (not modified) | `experiment/numaya-backend-20261112-2255` | `bbbe8af` | Also from `c890d02`; 11 commits of its own |

The two branches share `c890d02` and have not been merged in either direction. This pass did not merge the backend branch. Its own rule (`docs/backend/FILE_OWNERSHIP.md`) is to merge a completed, pushed frontend commit at a recorded checkpoint, by hand.

## What the backend branch adds to the app (not present in this build)

From `docs/backend/UI_INTEGRATION.md` on the backend branch:
- **Supabase adapters:** in `lib/data/live/` (auth, profile, dating, Compliments, economy, session restore), behind `--dart-define=NUMAYA_SUPABASE_URL` and `NUMAYA_SUPABASE_PUBLISHABLE_KEY`.
- **Small edits to shared files:** `main.dart`, `providers.dart`, `app.dart`, the three application controllers, `sample_people.dart`, `local_image.dart`, `voice_service.dart` and `session_controller.dart`.
- **A new dependency:** `supabase_flutter` in `pubspec.yaml`.

## Files this pass changed that the backend branch also edits

- **`lib/app/app.dart`:** this pass did not change it.
- **`lib/features/lab/lab_registry.dart`, `welcome_screen.dart`, presentation files, the design system and l10n:** frontend-owned; the backend branch does not touch them.
- **None of the shared application controllers, providers or repositories** were changed. The demo entry uses the existing `SessionController.quickStart()` behind the existing `demoAuthProvider`. That provider is null in release builds and, on the backend branch, in live builds. So the demo entry cannot appear in a live or release build.

**Expected merge conflicts:** none in the files listed above. `pubspec.yaml` is untouched here, so the backend's dependency line will merge cleanly.

## Real backend status

Taken from the backend's `PROVIDER_STATUS.md`, not re-tested:
- **No Supabase project exists** (its blocker A1). Every live capability is "adapter written; blocked" or "local verified" against PGlite fixtures.
- **Phone OTP:** blocked (A3: Phone provider and test numbers). Real SMS is blocked (budget and India DLT registration).
- **Push:** no app-side token capture. **Billing:** no billing client in the app.

Nothing in this pass was verified against a backend. Every journey result in `JOURNEY_EVIDENCE.csv` comes from the on-device demo or from widget tests.

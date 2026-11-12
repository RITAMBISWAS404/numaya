# File ownership and integration checkpoints

Two sessions work in parallel. One writer per file set; shared files change only at recorded
checkpoints.

| Area | Owner | Notes |
|---|---|---|
| `supabase/` (migrations, seed, functions, config, tests) | Backend | Only the backend applies migrations to the dev project. Never two agents migrating one database. |
| `docs/backend/`, `tools/backend/`, `tests/backend/` | Backend | |
| `apps/numaya_mobile/lib/data/live/` (Supabase adapters) | Backend | New folder; implements existing repository interfaces. |
| `apps/numaya_mobile/lib/app/backend/` (`numaya_api.dart`, config) | Backend | Existing stub, replaced by the live client. |
| `apps/numaya_mobile/lib/features/*/presentation/`, `core/design_system/`, tokens, fonts, l10n copy | **Frontend** | Backend adds new auth, privacy, safety, loading and error states only with existing components, listed in [UI_INTEGRATION.md](UI_INTEGRATION.md) for review. |
| `pubspec.yaml`, `pubspec.lock` | Shared | Backend adds `supabase_flutter` only; recorded below. |
| `lib/app/router.dart`, `lib/app/providers.dart` | Shared | Backend changes are minimal guards and provider overrides, listed in UI_INTEGRATION. |
| `lib/features/*/application/*_controller.dart` | Shared | Backend switches them to repositories in live mode; demo behaviour stays the default. |
| `docs/agent-handoff/` | Shared | Backend appends a short pointer, never rewrites frontend entries. |

## Checkpoints
| # | Date | Frontend SHA taken | Backend SHA | Conflicts / reruns |
|---|---|---|---|---|
| 0 | 2026-11-12 | `c890d02` (base) | `c890d02` | none |

Integration rule: merge a **completed, pushed** frontend commit into this branch only at a
checkpoint row, inspect conflicts by hand, rerun `flutter analyze`, the full Flutter suite and the
backend suite, then record it here. No automatic rebases of shared branches.

## Shared-resource rules
- **Emulator:** the frontend's captures have priority. The backend uses the emulator only when
  no `qemu` process belongs to a frontend capture, and records its use in WORK_LOG.
- **Dev database:** single migrator (this branch).

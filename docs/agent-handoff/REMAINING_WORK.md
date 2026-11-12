# Remaining work

State on 13 November 2026. Branch `experiment/numaya-selected-20261113-0232`, app source `ae10663`.

## Waiting on the owner

- Review `C:\Users\biswa\OneDrive\Desktop\Numaya Selected Design Review\2026-11-13 ae10663\index.html` and install `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Selected-20261113-ae10663-debug-demo.apk` (tap Explore the demo on Welcome).

## External blockers (not frontend work)

- A development Supabase project (backend A1), the phone OTP provider and test numbers (A3), a billing client and push token capture. Until then, real sign-in, server debits, purchases and notifications cannot be verified. See [BACKEND_BOUNDARY.md](../design/selections/BACKEND_BOUNDARY.md).
- Merging the backend branch is a separate, recorded step (its FILE_OWNERSHIP rule). No conflicts are expected in the files this pass changed.

## Not walked on the device in this pass

Profile edit, Dismiss, archive and expiry, Premium and purchase states, rapid taps, report, block and unmatch. Each is covered by widget tests. See [JOURNEY_EVIDENCE.csv](../design/selections/JOURNEY_EVIDENCE.csv).

## Known limitations

| Item | State |
|---|---|
| Device | Pixel 10 emulator only; no physical phone. |
| Release builds | The demo sign-in is compiled out, so a release APK stops at Welcome. Review builds are debug. |
| Icons | Tabler has no filled Compliment glyph; that mark stays outline. |
| Artwork | The mascot is still a stand-in wherever it appears. |

## Private photos

The demo photos are local and git-ignored. They appear in the screenshots, the review page and the APK, which therefore stay local. **No private backup exists.**

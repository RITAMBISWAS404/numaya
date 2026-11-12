# Remaining work

State on 13 November 2026. Branch `experiment/numaya-fable-design-20261113-0048`, app source `da197b7`.

## Waiting on the owner

- Review `C:\Users\biswa\OneDrive\Desktop\Numaya Fable Lab Review\2026-11-13 da197b7\index.html` and export choices (JSON or TXT). Seven decisions: six lab groups and the still-open photo scrim.
- Install `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Fable-Lab-20261113-da197b7-debug-lab.apk` to try the options on a phone: tap the purple area on Welcome → Demo hub → Quick start; then Demo hub → Visual Lab V2.
- Decide whether to commission artwork for the feature card (Profile B/C, Credits B, Streak B).

## Then

Follow [QA_HANDOFF.md](../design/fable-lab/QA_HANDOFF.md): apply the choices, run the unchecked items, capture the chosen screens on the emulator.

## Backlog (not built)

Reply composer (R1/R2), sent confirmation (S1/S2), sheet headers, alert cards, settings groups, welcome composition, paywall comparison, a motion clip. See [EXPERIMENTS.md](../design/fable-lab/EXPERIMENTS.md).

## Known limitations

| Item | State |
|---|---|
| Artwork | The mascot is a stand-in in every feature card. |
| Renders | Flutter test renders, not emulator screenshots; no status bar. |
| Release builds | Demo sign-in is compiled out of release builds, so a release APK stops at Welcome. Use debug builds until real auth exists. The 12 November replacement V8 APK is affected. |
| Real integrations | None: on-device demo only. |

## Private photos

The demo photos are local and git-ignored. They appear in the gallery, the render folder and the APK, which therefore stay local. **No private backup exists.**

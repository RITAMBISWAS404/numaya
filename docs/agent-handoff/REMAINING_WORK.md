# Remaining work

State on 12 November 2026. Branch `experiment/numaya-v8-premium-rebuild-20261112-1945`, app source `ee87648`.

## Waiting on the owner

- Review the gallery `C:\Users\biswa\OneDrive\Desktop\Numaya Replacement V8 Review\2026-11-12 ee87648\index.html`. It uses relative image paths and is meant to open directly in Chrome or Edge, but that was not tested; it was tested over a localhost server (`.claude/launch.json` `r8-gallery`, port 8772). Choices are saved per browser and origin. Then export JSON or TXT. Seven decisions, none pre-selected:
  - **Recommended:** adaptive scrim, near-full chat hairline, outlined secondary buttons, unified Compliments, V7 type.
  - **Your V7 choices offered with a critique alternative:** credits card emphasis, Profile title bar.
- Install `C:\Users\biswa\OneDrive\Desktop\Numaya Test Builds\Numaya-Replacement-V8-20261112-ee87648.apk` on a phone.

## Known limitations

| Item | State |
|---|---|
| Real integrations | OTP, persistence, delivery, push, billing, moderation and release signing are not present (on-device demo). Notification routing is in-app links only. |
| Server guarantees | Atomic send plus debit, cross-device idempotency and server-enforced reciprocity must come from a backend (CONVERSATION_CONTRACT.md). |
| Read and delivery ticks | Not shown, because no backend reports them. |
| Old Compliments inbox and request page | Unreachable (routes redirect); code kept for the lab and recovery. |
| Editorial fonts | Bundled for the comparison (about 5 MB). Unregister them if the comparison is rejected. |
| Figma | Six nodes read; the desktop plugin was not used (needs `/mcp` sign-in). |
| Art | V7 assets only; the old V8 "3D art" reference was never supplied. |
| Quirky direction | Deferred to a later branch. |

## Not verified

Physical phone, iOS, screen reader, hardware profiling, web checks (no web change).

## Private photos

The demo photos (`pics/`, `apps/numaya_mobile/assets/demo/photos/`) are local and git-ignored. They appear in the screenshots, the gallery and the APK. **No private backup exists.**

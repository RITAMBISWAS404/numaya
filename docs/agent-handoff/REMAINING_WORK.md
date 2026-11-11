# Remaining work

State on 12 November 2026. Branch `version-9`, app source `fb9e5cb`.

## Waiting on the owner

- Install `build/v9/namaya-v9.apk` (also on the Desktop as `Numaya Test Builds/Numaya-V9-20261112-fb9e5cb-release.apk`) on an Android phone.
- Review `docs/v9/design-exploration.html` and confirm the ten decisions.

## Known issues

| Item | State |
|---|---|
| Unread count badge at font 2.0 | The digit clips inside the badge circle on Messages. Seen in this pass and not fixed. |
| Pills at font 1.5 and 2.0 | The third filter pill runs off the edge and scrolls sideways (since V8). |
| Profile setup line | "Next: A second prompt answer (optional)" takes two lines, the maximum allowed. |
| Flat illustrations | Unmatched, blocked and the deferred Events art keep the older flat drawings. |
| Chat avatar hero | Built, but the flight was not inspected frame by frame on a device. The Messages tab sits in a nested navigator, so the flight may not animate there; the avatar still shows normally. |
| Read and delivery ticks | Not shown: no backend reports delivery. |

## Not verified

- Physical phone, iOS, screen reader.
- The deeper journeys on the release build (they were run on the debug build).
- A full Figma comparison: the radius node returned only one variable through the connector. The V7 values came from the earlier transcription of that file.

## Release blockers

This is a front-end demo build only. There is no backend, real sign-in, real purchases, push notifications or release keystore. The APK is release-mode, signed with the debug key.

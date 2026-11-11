# Remaining work

State on 11 November 2026. Branch `version-8`, app source `45eadc1`.

## Waiting on the owner

- Test the APK on an Android phone and review the phone folder.
- The visual references mentioned in the first V8 message were not attached. The illustration style was built from the written direction.

## Known issues

| Item | State |
|---|---|
| Composer title at font 2.0 | "Compliment" in "Compliment Noor" breaks mid-word in Bree Serif. Page still works. |
| Pills at font 1.5 and 2.0 | The third filter pill runs off the edge and scrolls sideways. |
| Flat illustrations | Unmatched, blocked and the deferred Events art keep the earlier flat drawings. |
| Profile tiles | "Compliment credits" wraps to two lines beside a one-line "Streak". |
| Lab groups | Compliment card, Request and Heart directions no longer have a place in the app; kept for recovery behind `NUMAYA_DEV_TOOLS`. |

## Not verified

- Physical phone, iOS, screen reader.
- Live Figma comparison for V8. The existing tokens and Ente references were used; no new Figma nodes were inspected.
- Web checks: not run, because nothing on the web side changed.

## Release blockers

Front-end test build only: no backend, real sign-in, real purchases, push notifications or production signing. Notification routing is implemented for in-app links (`/request/:id`), not real push.

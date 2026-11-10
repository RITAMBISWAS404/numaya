# Remaining work

State on 10 November 2026. App source `014ac35`, selections applied. See [SELECTIONS.md](../design/creative-lab-v7/SELECTIONS.md).

## Waiting on the owner

- Test the APK on an Android phone.
- Events and Health: 12 gallery groups remain undecided and deferred.

## Known issues

| Item | State |
|---|---|
| Compliment composer title at font 2.0 | "Compliment" breaks mid-word. Page still works. |
| Pills at font 1.5 and 2.0 | The second or third pill runs off the edge and scrolls sideways. |
| Unread count badge at font 2.0 | Digit looks cramped in Messages. |

## Not verified

- Physical phone, iOS, screen reader.
- Live Figma comparison for the selections. The owner chose from rendered app screens.
- Web `npm run check` and e2e. No web change; CRLF failures and the missing Playwright browser predate V7.

## Release blockers

Front-end test build only: no backend, real sign-in, real purchases, push notifications, file upload or production signing. Legal text is draft and safety contacts need checking. See `docs/product/mvp-focus-v5/LAUNCH_READINESS.md`.

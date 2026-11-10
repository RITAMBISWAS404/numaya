# Remaining work, Creative Lab V7

State at delivery on 10 November 2026. App source `71564be`.

## Waiting on the owner

- Review the gallery, export choices and send them back. Nothing is applied until then.

## Not done or not verified

| Item | State |
|---|---|
| V7 alternatives at font 1.5, font 2.0 and 360 dp on a device | Not rendered. The capture steps exist in `ente_v4_review_test.dart` (`ONLY=key`). |
| Compliment arrangement C, full journey | Entry only, so it is left out of the journey comparison. Its screen render is in the gallery. Harness step fixed, not re-run. |
| Per-screen sweep | 203 default screens reviewed as contact sheets only. 34 are tied to an experiment or earlier option; 169 had no V7 alternative explored. See `docs/design/creative-lab-v7/SCREEN_REVIEW_LEDGER.csv`. |
| Ente Figma for V7 | Page list read; Rituals seen only as an unreadable overview. V6 node inspections carried forward. |
| Discover direction C | Only appears when the two people share something. |
| Streak directions A and C | Do not show today's status. Should return if chosen. |
| `v7-nav` A | Rendered on Discover only. Large text unchecked. |
| Physical phone, iOS, screen reader | Not done. |
| Web `npm run check`, e2e | Not run in V7. No web change. CRLF failures and missing Playwright browser predate V7. |
| V6 deliverables | V6 never got its own screenshots, gallery or APK. They are folded into V7. |

## Not launch ready

Front-end test build: no backend, real purchases or production signing. See `docs/product/mvp-focus-v5/LAUNCH_READINESS.md`.

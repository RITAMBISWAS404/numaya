# PRD v1 amendments from Visual Lab V2 (2026-11-08)

The owner's `NUMAYA_VISUAL_LAB_V2` brief (01_REQUIRED_CHANGES) overrides PRD v1 **only** for the
items below. Every other approved PRD rule stands. Implemented on `experiment/numaya-visual-lab-20261108`
(record: `docs/design-experiments/visual-lab-v2/`).

| PRD v1 rule | Amended to | Ref |
|---|---|---|
| Started conversation: 7-day check-in, 14-day expiry, history kept, sending disabled; reconnection once per episode with acceptance (S23, S24, S25) | No expiry. After 7 days without a genuine accepted message the chat moves to **Archive**; either person may send as usual and an accepted send returns it to active for both. No request, fee or restore timer. Blocked, unmatched or deleted chats cannot be revived. System notices don't reset inactivity. The 7-day expiry-warning notification and every reconnect route and string are cancelled. A quiet archive is never labelled expired. | R01 |
| Expired initial match offers reconnection (MVP-D08) | An initial match that runs out (24 h, or the one extension) shows a simple ended state with no reconnection. The 24 h window and extension policy are unchanged. | R02 |
| New-match tiles show time left under each tile (MVP-D18) | A ring around the avatar shows the fraction of the original or extended window left; no number below. The exact end time and Extend are inside the chat; the spoken label includes time left. | R02 |
| Compliment requests live in Chats › Requests (S20, S21) | The Heart tab has two parts, **Likes** and **Compliments**. Compliments are readable and answerable free, each on its own card; reply opens the same single conversation. Deep link `/likes?tab=compliments`; the tab badge counts likes and Compliments. No third Matches tab. | R03 |
| Discover shows "x of y likes left today" (S11) | No persistent line; the limit is still enforced and explained (with reset time) once reached. | R04 |
| Profile Health score page (S29) and score on Profile | **Your insights**: visibility status, activity and connection measures with explicit periods and denominators, one evidence-linked suggestion; profile setup is a supporting card counted in parts, never a combined score. Samples labelled; no shadowban diagnosis; advice never promises results. | R11 |

Design-level changes with no PRD rule impact: Compliment action placement (R05), verified badge after
the name (R06), sentence case and one Figtree answer role (R07), squircle sheet close (R08), spacing
and radii from Ente (R09), illustration placeholder boxes (R10), collapsing large titles (R12).

Backend contracts in `backend/` still describe the PRD v1 lifecycle and must be updated before a live
build (OPEN_ITEMS 1).

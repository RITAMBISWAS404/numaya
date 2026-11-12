# Replacement V8 decisions

Branch `experiment/numaya-v8-premium-rebuild-20261112-1945`. Base: the selected V7 `b5e5245`, plus the return-to-V7 handoff commit `3941b88`, which changes records only. Brief: `NUMAYA_V8_REPLACEMENT_PREMIUM.zip` (documents 01–07). The old V8 and V9 briefs are historical; where they conflict, the reconciliation in document 01 wins.

Recorded before any app edit, as document 01 requires.

## Baseline

| Item | Value |
|---|---|
| Selected V7 | `b5e5245`. V7 lab `71564be` → handoff `2fb12f9` → selection pass (`3ca3b67` applied the export, `014ac35` placed the wallet and streak cards, `b5e5245` added records). |
| Owner selections | Export `v7-71564be-2026-11-10`. All 36 decisions match the `proposed` values in `lab_registry.dart` at `b5e5245` (checked by script). The 12 undecided groups stay deferred. |
| Other candidate checked | `origin/experiment/tiimo-inspired-v7` (October). It is already an ancestor of V7, so it is not a newer candidate. |
| Archives | `archive/superseded-v8-v9-20261112` (`eb38d9f`, V8 and V9) and `archive/superseded-v8-20261112` (`47ba247`). Both pushed and verified. `version-8` and `version-9` are untouched. |
| Baseline tests | V7's recorded run at the same app source `014ac35`: 638 passed, 42 skipped, 0 failed. A fresh baseline run was started and then stopped, because files changed during it. |

## Reconciliation (document 01) applied

| Topic | Decision | ID |
|---|---|---|
| Type | V7 mapping kept: Plus Jakarta Sans headings and names, Figtree text and controls, 15pt body. Bree Serif titles with Google Sans text is built only as an isolated comparison (`NUMAYA_EDITORIAL_TYPE`); the recommended build never uses it. | T-01, T-02 |
| Corners | V7 / Ente radius roles unchanged: buttons and sheets 20, cards 20, hero 24, field 16, pills only for chips, tags and navigation. | G-01 |
| Structure | Single-column information flow (already true in the selected V7 Profile). No two-column cards. | L-01 |
| Compliments | One conversation system. No Compliments part in Heart. See [CONVERSATION_CONTRACT.md](CONVERSATION_CONTRACT.md). | CV-01 |
| Received Compliment | The owner's V7 choice `v7-request` **B, photo-led** is carried into the conversation: the received thread opens with the sender's photo, then their Compliment. | CV-02 |
| Cards | Role-specific anatomy; no compulsory five-part card. The owner-selected wallet A, streak O and profile-setup O are kept. The setup card's one relevant action stays inside it (document 03 permits that) and is now outlined. | K-01 |
| Secondary buttons | Outlined: 1pt ink at 20%, no fill. Brand: purple label, purple edge at 45%. Primary stays solid purple; disabled stays filled grey, so the two states remain distinct. V7 filled is kept as comparison `r8-secondary-button` O. | C-03 |
| Dividers | Grouped settings-style cards keep V7's no-hairline rows: Ente Settings `12099:96480` groups rows without hairlines. The Messages list gains a near-full hairline (gutter at both ends); comparison `r8-chat-dividers`. | C-04 |
| Icons | Tabler only. The decorative grey disc behind the banner chevron is removed. Functional backplates are kept: send, photo actions, selection marks, swipe stamps. | C-05 |
| Photos | The adaptive scrim measures each photo's lower 40% once and sets the gradient edge between 24% (dark) and 52% (white), local to the text band. V7's fixed 24% is kept as comparison `r8-photo-scrim` O. | C-07 |
| Artwork | V7's own assets only. `mascotWaiting` (its stated purpose: waiting on someone else) marks a sent Compliment; `noChats` marks empty Messages. No new generated art. | A-01 |
| Motion | V7 motion tokens unchanged (press 120ms, state 200ms, route and sheet 280ms, reduced motion makes them zero). No shared-element or tab transitions are added. | M-01 |
| Quirky direction | Deferred to a later branch. | Q-01 |

## Superseded from V8/V9 and not imported

Bree Serif and Google Sans as the default type, the tighter radius scale, code-drawn SceneArt, the two-column InfoTile, the 20pt card padding, the tab fade and the chat avatar hero.

## Ported from the archive with review

These behaviours were ported, reviewed against documents 03 and 04, and tested:
- The Compliment conversation behaviour: `ComplimentThread`, `ChatHeader`, the merged Messages list, the routes and the Messages badge. One new guard was added: one row per person.
- The adaptive scrim (`PhotoLuma`).
- The OFL font files, used for the comparison only.

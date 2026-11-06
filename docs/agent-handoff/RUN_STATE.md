# Run state: Ente design system experiment (2026-11-05), implemented, uncommitted

> **Overnight v2 (2026-11-06, cloud/Linux, uncommitted):** package `NUMAYA_OVERNIGHT_V2.zip`
> executed in `/home/user/numaya-ente` (base `f2e18e6`, local branch
> `experiment/numaya-ente-design-system`). Figma primary pages fully indexed and inspected;
> shared fixes OV-01 alerts → Ente Banner, OV-02 grouped menu cards (Updated screens Settings),
> OV-03 Action Sheet v2, OV-04 neutral toast; 58-route before/after inventory (28 changed) with a
> second visual review. Tests: **418 passed, 17 skipped, 0 failed**. Records:
> `docs/design-experiments/ente-design-system/overnight-v2/` (FIGMA_SOURCE_MAP, COMPONENT_MAP,
> COVERAGE, DECISIONS); gallery `artifacts/ente-design-system/overnight-v2/gallery/index.html`.
> **Next:** Windows emulator pass (sheets, keyboard, TalkBack, back); regenerate goldens.


> **Review batch 3 (2026-11-06, cloud/Linux, uncommitted):** UI-033 to UI-046 reconciled and
> completed in `/home/user/numaya-ente` (restored from the Windows recovery ZIP). Tracker:
> `docs/design-experiments/ente-design-system/UI_REVIEW_BATCH3_TRACKER.md`. Tests: 416 passed,
> 16 skipped. UI-043 deferred (optional). **Next:** run on the Windows emulator (gestures,
> keyboard, TalkBack), regenerate the goldens, and review the UI-041 "kept on purpose" list.


> **Review batch 2 (2026-11-06):** implemented and verified; uncommitted, not pushed.


> **UI review handoff (2026-11-05):**
> - Implementation and verification are complete.
> - Uncommitted, not pushed.
> - Open items:
>   - UI-001 artwork (blocked);
>   - the UI-008 phrase (needs clarification).


**Workspace:** `C:\Users\biswa\Downloads\numaya\numaya-ente` (git worktree), branch
`experiment/numaya-ente-design-system`.

**Base:** `f2e18e627af9f06e9563db5bf09828995dcde5c4` plus the reviewed, uncommitted final-design-run
patch (the newest intended candidate). **All work is uncommitted and local**: no commit or push was
authorised for this run.

**Export:** `artifacts/ente-design-system/patches/ente-design-system.patch` (`git apply` on
`f2e18e6`; includes the final-design-run changes). APKs: `artifacts/ente-design-system/Numaya-ente-debug.apk`
and `Numaya-ente-release-debugsigned.apk` (release build, debug-signed). **Do not commit the APKs.**

**Record:** `docs/design-experiments/ente-design-system/README.md`, `TOKENS.md` and `TRACKER.md` (the route-by-route checkpoint).

**Recovery:** the pass-1 state is in `artifacts/ente-design-system/patches/ente-pass1-checkpoint.patch`.

**Untouched:**
- `..\numaya` (`experiment/numaya-first-ui-improvement`, local edits);
- `..\numaya-final-design` (`experiment/numaya-final-design-candidate`, uncommitted);
- `..\numaya-frosted-navigation`.

| Batch | Result | Evidence |
|---|---|---|
| 0: recovery | Worktree from `f2e18e6`, final-design patch applied (23 files) | `git status` |
| 1: Figma | Tokens, type, spacing, radius and 14 components read with their descriptions | README source map |
| 2: tokens and icons | Ente values in the hand-authored token file; Lucide 4.0.1 replaces the Material map | TOKENS.md |
| 3: components | Buttons, icon buttons, header, nav bar, rows as cards, glyph icons, switch, checks, filter and tag chips, inputs, sheet, bubbles, decision bar | `sheets/E1-*.jpg` |
| 4: Bumble | Discovery, Likes, profile editing checked on Mobbin; structure kept | README |
| 8: reconstruction (ER) | Discovery, liked and person profiles, Chats, Likes, Profile and Filters rebuilt on the Bumble structure; content pass; 10 tests moved to the new structure. **361 passed, 15 skipped**; release builds | `sheets/R3-*.jpg`, `TRACKER.md` |
| 5 and 7: QA | Fixed tab-bar overflow at 320pt, wordmark overlap, field and composer tap targets, and the search hint clipped at 320dp/150%; old-spec tests moved to the Ente contract. **361 passed, 15 skipped** | `sheets/E2-*.jpg`, `device/E2-320dp-150/` |

**Next action:**
1. The owner reviews the before/after sheets.
2. The owner authorises a commit and push, if wanted.
3. Regenerate the goldens on Linux.
4. Run a physical-phone pass.

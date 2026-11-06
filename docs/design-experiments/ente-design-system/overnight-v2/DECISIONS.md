# Overnight v2: decisions, defect ledger and checkpoint

**Package:** `NUMAYA_OVERNIGHT_V2.zip` (SHA-256 `7f7014b2…6885`). Its review register and brief are
byte-identical to the batch-3 package, so UI-001 to UI-046 status is as recorded in
`../UI_REVIEW_BATCH3_TRACKER.md`, with UI-043 optional and deferred.

**Starting snapshot:** taken before any edit and verified by a clean restore:
`numaya-ente-recovery-20261105-232115-batch3-f2e18e6.zip` (SHA-256 `c290dea0…a3b0`).

## Defect ledger (prefix OV-, separate from the review's UI- IDs)
| ID | Family / routes | Problem seen (baseline sheet) | Source | Change | Acceptance check | Status |
|---|---|---|---|---|---|---|
| OV-01 | Alerts: `InfoCard`, `StatusBanner` (phone, photos, verify, like, chat expiry, delete account, unmatch, preview, premium, event, visibility, account on hold) | Lavender or red tinted boxes with a 1pt border; they competed with real cards and read as panels | Banners 14590:125245 | White r20 card, no tint or border; the icon in the status colour, top-aligned (UI-010; superseded by Tabler MVP TB-03: filled and centred); title ink, or the status colour for error and success; muted body | `component_cleanup_test` OV-01 (surface, no border, icon colour, error title colour, top alignment); harness `ov2/after` | Done |
| OV-02 | Menus: `ListGroup` (Settings, Profile, Edit profile, Help, Safety, Visibility, Notifications, Privacy, Event detail/form, completion, Demo Hub) | Every row in its own card, 8pt apart: long menus became stacks of separate buttons | Updated screens: Settings DS 12099:96480 | Related rows share one white r20 card, no hairlines, insets unchanged (UI-044). Selectable option lists keep separate cards (UI-003) | `final_polish_test` OV-02; route and size sweeps pass | Done |
| OV-03 | Action sheets (chat menu, attach, Discover more, event more, photo options, settings) | A floating card with a separate floating Cancel card | Action Sheet (v2) 25316:7380 | One white sheet attached to the bottom, grabber, muted glyph + Body rows, destructive in red, hairline, quiet Cancel row | `ov2_components_test` OV-03; 6 existing Cancel-tapping tests pass | Done |
| OV-04 | `NumayaToast` (71 call sites) | Purple-tint pill | Toast 9409:4000 (neutral variant) | White pill, ink text, shadow; busy dots purple | `ov2_components_test` OV-04 | Done |

## Decisions
- **Grouping rule (OV-02).** The newer Updated-screens Settings wins over the older menu item list.
  Ente groups related settings into one card. Numaya's `ListGroup` already *is* the "related" boundary
  (a titled section), so one group becomes one card. No dividers, because Ente draws none and the
  60pt rows separate themselves. *Alternative considered:* grouped with inset hairlines. Rejected
  because the source has none and the denser menus already read clearly at 60pt.
- **Cancel stays (OV-03).** Ente's v2 sheet has no Cancel. A visible Cancel is the explicit exit for
  switch-access and screen-reader users, so it stays as a quiet row below Ente's own divider.
- **Status title colour (OV-01).** Error and success titles take their status colour, as Ente's
  "Subscribe" and "Enable" banners do. Info and pending titles stay ink, as in the source's
  "Confirm your recovery key".
- **Toast tone (OV-04).** Every current toast is a neutral confirmation, so the neutral Ente variant
  applies. The tinted status pills are not needed.
- **Kept as they were** (inspected and consistent with the source): buttons, fields, chips, tabs,
  switches, sliders, headers, sheets, bubbles, the nav bar and empty states. These were mapped by the
  Windows run (`../README.md`) and batch 3.

## Mobbin and skills
- **Mobbin:** no new composition was unresolved in this pass. Messaging and completion research was
  done in batch 3 (Bumble chat; Bumble and happn completion, cited in the batch-3 tracker).
- **Skills:** the installed `impeccable` critique checklist (hierarchy, grouping, redundancy) framed the
  defect ledger. Flutter changes followed the existing project conventions. **No new skill was
  installed**, since the existing ones covered every task.

## Checkpoint (end of pass)
- **Worktree:** `/home/user/numaya-ente`, local branch `experiment/numaya-ente-design-system`, base
  `f2e18e627af9f06e9563db5bf09828995dcde5c4`. Uncommitted; not pushed.
- **Evidence:**
  - `apps/numaya_mobile/test/screenshots/comparison/ov2/{before,after}/` (58 routes, gitignored;
    regenerate with `capture_ov2_test.dart`);
  - gallery `artifacts/ente-design-system/overnight-v2/gallery/index.html`;
  - coverage `COVERAGE.csv`; components `COMPONENT_MAP.csv`; sources `FIGMA_SOURCE_MAP.md`.
- **Tests:** see the final report in `../../../agent-handoff/ACTIVE_TASK.md`.
- **Next action:** run on the Windows emulator: the action sheet drag and dismiss, keyboard, TalkBack,
  and back in each sheet. Then regenerate the screenshot goldens on the target platform.

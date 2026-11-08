# Visual Lab V2: open items and limitations (honest list)

## Not done or partial in this run
1. ~~Backend contracts~~ **Done 2026-11-08** on `experiment/numaya-visual-lab-selections-20261108`:
   migrations, CONTRACTS.md and the app's `NumayaApi` now describe 7-day archiving with no
   reconnection or check-in (SQL still not executed: no database).
2. ~~Notification settings~~ Done in `8510778`: the check-in category was removed.
3. **R09 token drift**: new and varied components use shared tokens only; older one-off screens outside
   the 15 families (events, onboarding fields, verification, legal, store outcome) were not re-audited
   pixel by pixel.
4. **Older illustration slots** (`IllustrationSlot`, hidden outside the Lab) remain on some screens; R10
   grey boxes were added where this run touched empty states and the streak variant.
5. **Performance (MOT08)**: no physical device was connected, so no profile-mode frame timing. Emulator
   clips show behaviour, not production frame rate.
6. **Physical device, iOS, three-button navigation**: not checked. iOS "Reduce Motion" handling relies on
   Flutter mapping it to `disableAnimations` (not run on iOS here).
7. **Ente Header v2 text styles** were not extracted numerically (frame geometry and screenshots only);
   the large title uses the approved Plus Jakarta Sans 30/36 bold.
8. **Ente Empty states page** (`20943:133321`) was not opened; the empty-state family is grounded in the
   brief's R10 rules and the existing approved empty state.
9. **Insights are samples**: there is no event tracking, aggregation, consent or retention design yet;
   brief 03's data rules are recorded, not implemented server-side.
10. **Old Experiment Lab** (EXP-001…004) still exists; EXP-002 and EXP-004 are superseded on Profile
    (VL-D20). Decide whether to retire it.
11. **Selfie verification**: the badge means photo verification in the sample data; whether the selfie
    flow stays is still an owner decision (MVP-D24).
12. **Sample people are London-flavoured** (MVP-D25), unchanged.

## Owner decisions this gallery asks for
Every group in the gallery (15 card families, 5 screens, motion preset). Proposed defaults are listed
in DECISIONS VL-D19; none is an owner approval.

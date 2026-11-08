# Limitations and live-launch decisions

## What this build is not
- **A demo, not a launch.** All events, venues, hosts, attendees and notices are labelled samples.
  State lives in memory and resets on restart (Demo Hub → Events demo scenarios → reset).
- **No backend.** Reservation atomicity, capacity, eligibility, deadlines, notification delivery,
  attendance, consent and block checks are enforced in the local controller and marked "Live: server"
  in code comments. A live build must enforce every one on the server.
- **No push notifications.** Notices are in-app; one sample notice shows "push failed" handling.
- **No maps, calendar or directions integration**: the buttons are labelled demo actions.
- **Covers are labelled illustration placeholders**, not artwork or photography.
- **Phone verification** is assumed true for the demo session (`sessionPhoneVerifiedProvider`).
- **Internal tools (`/staff`)** are reachable from the Demo Hub only with demo sign-in, carry a
  "Demo role, not real access" banner, and are not a real role or permission system.
- **Nationwide is sample only**: eight cities appear (Jaipur deliberately empty); this is not a claim
  of live supply anywhere.
- The APK contains the local, private demo photos: **do not publish it**.

## Open decisions (from the PRD; none resolved here)
| # | Decision | State in this build |
|---|---|---|
| O1 | Member submission versus no public hosting screens | M01/M02 built as the PRD's *recommended* reconciliation and labelled "Pending decision O1". Submitting member gets no host or attendee access. |
| O2 | Nationwide day-one supply versus invited pilot | OPEN. Nationwide discovery is sample data only. |
| D1 | Cities, budget, launch date, venues, accessibility, must-haves | Unknown; nothing invented. |
| D2 | Named host, report reviewer, publication reviewer, technical owner | Unassigned. Publishing in the demo requires a typed host and reviewer name, which are samples. |
| D3 | Venue arrangements and verified operating information | Per-event; sample venues only. |
| D4 | Existing subscribers / Health and Insights data | See [HEALTH_REMOVAL_AUDIT.md](HEALTH_REMOVAL_AUDIT.md): no real users exist; live audit still required. |
| D5 | Exact chat timing / archival / reactivation | Preserved: an event connection reuses the existing chat, never reopens an archived chat or resets timers; block/unmatch always prevail. Expired-match reactivation (`existingEnded`) left OPEN: shown, not reopened. |
| D6 | Privacy/retention, reports, support, emergency info, legal obligations | Live dependency; S01 report is stored on device with a reference only. |
| D7 | Recommended defaults (tab order, reminders, deadlines, opt-in, allowance) | Implemented as recommended: Events 4th of 5 tabs; reconfirm deadline = earlier of +24 h and start −2 h (none under 2 h); People I met opt-in per event, 7-day window, 3 interests per event. Not separately approved. |

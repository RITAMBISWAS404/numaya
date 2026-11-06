# Design contract: Bumble UX × Meetup visual language

**Status:** 2026-11-04. Cloud worktree `/home/user/numaya-overnight`, branch
`experiment/numaya-overnight-polish`, HEAD `6b23c85`. **Local only, uncommitted; not on GitHub.**
The other checkout, `/home/user/numaya` (14 Impeccable files), is untouched.

## Assessment of "90% complete"
- **UI layer:** a fair estimate for the demo. Every inventoried route renders and passes the
  route, size and text matrix. The shared components have one treatment each (this session's
  passes TR, SP, CL, DX, pill gaps).
- **Product:** not 90%. No backend, authentication, moderation, release signing or device
  verification (FINAL_QA.md, "What can ship").

## Translation table
| Numaya task | Bumble (layout and behaviour) | Meetup (visual) | Numaya component | Behaviour | Verification |
|---|---|---|---|---|---|
| Decide on a person | [People](https://mobbin.com/screens/83e93b49-e15d-462c-ae89-810a4613cea0): dominant photo, identity, "things in common" first | — | `PersonHeroCard`: 4:3 photo, identity, **You both like** in the hero (DX-02), `DecisionBar` | Preserved: swipe, Pass, Like, SuperSwipe, undo | `core_journey_test`, size matrix |
| Choose interests | [Interests](https://mobbin.com/screens/ff63ca32-0913-418e-876d-120f3481074f): categories, disclosure | Rounded pills | `ChipSet` plus `NumayaChip` (12/16, 12 × 4 inset, 8 gap) | Preserved: max 5 | `spacing_rules_test`, `type_roles_test` |
| Edit profile rows | [Edit profile](https://mobbin.com/screens/fc35bf13-823e-4331-a922-4882f5d67e7a): line icons, label, trailing value | — | `ListRow`: plain monochrome icon, 16/22 label, trailing value or stacked long value (CL-02, F-02) | Preserved | `final_polish_test`, `overnight_polish_test` |
| Inbox | [Chats](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74): matches, then chats, "Your move" | — | New-matches row, `ViewTabs` filters (8 gap), conversation rows; Opening Moves after the list (DX-03) | Preserved | `core_journey_test` |
| Conversation | [Chat](https://mobbin.com/screens/f240ef7c-e408-4a63-ad4f-ad204ce34694): flat composer | [Comments](https://mobbin.com/screens/f524b867-cbd4-407f-ae29-81b021071026): restrained rows, quiet metadata | `MessageBubble` (14/20, 12 × 8), `Composer` without a tray (CL-06), one demo notice (CL-07) | Preserved; the state stays truthful ("Not sent") | `component_cleanup_test` |
| Join an event | — | [Event](https://mobbin.com/screens/fa7b4936-53a7-421d-ac90-53ef110093c3): floating status + one primary action; white header buttons | Event RSVP bar (floating, status + detail + one action); `NavIconButton` floating | Preserved | `events_test` |
| Focused task in a sheet | — | [Announcement](https://mobbin.com/screens/edeeabc9-6a4e-42c1-90e3-da44f13b74e2), [registration](https://mobbin.com/screens/ec972fea-0cf4-4006-a80c-a2de330fbdd5) (owner's seeds; not reopened this pass) | `showNumayaSheet`: 32 radius, 20/26 title, no header rule, full-width primary above secondary | Preserved | `v16_screens_test` (delete sheet) |
| Settings | [Cursor](https://mobbin.com/screens/ef2cf22a-e8b3-4139-9b5e-23c0562c4718), [Venmo](https://mobbin.com/screens/c9e32778-c869-4879-8982-878356e69632) | Grouped rounded surfaces | `ListGroup` (24 radius, inset dividers), `NumayaSwitch` (CL-01) | Preserved | `component_cleanup_test` |

**Resolved conflicts:**
- **Primary colour:** Meetup's black primary informs prominence only. Numaya keeps purple
  `#7262C7` for the single primary action.
- **Tab labels:** Bumble's labelled tabs are not adopted. The owner's earlier icon-only
  decision stands; tooltips and labels are in semantics.
- **Glass:** frosted is kept over solid on identical content (DX-04).

## Contract (follow for new screens)
| Area | Rule |
|---|---|
| Type | `body` 14/20 · `pill`/`chip` 12/16 · `row`/`input`/`button` 16 · `section` 20/26 · `flowTitle`/`headline` 24/30 · `pageTitle` 28/34 · `hero` 32/38 |
| Spacing | gutter 20 · section 40 · heading → content 12 · title → body 8 · label → detail 2 · card padding 20 (hero 24) |
| Pills | inset 12 × 4, 36pt tall, at least a 44pt target; group gap 8 both ways; icon gap 4 |
| Badges | inset 8 × 4 |
| Rows | plain 24pt icon, then 12 to the label; dividers start at the label; a long value stacks under the label when a detail exists |
| Radius | tag 8 · control 16 · field/tile 18 · card/image 24 · dialog 28 · hero/sheet 32 · pill; outer = inner + inset |
| Colour | purple: one primary action, selection, "yours". Tint: status only, with a 1pt border in its hue at 15%. Text ≥ 4.5:1, marks ≥ 3:1 |
| Metadata | `MetaText.join` with a vertical bar; never split user text. On a coloured surface pass `separatorColor` (sent bubbles use the muted foreground at 50%). Copy never joins fragments with " · ": use a colon or brackets ("Demo: no sound recorded", "Pronouns (optional)") |
| Identity | Name, then a 20pt purple verified tick on its last line (Bumble). The photo carries only the sample/preview notice, "New here" and the photo count |
| Sheets | A `ListGroup` inside `showNumayaSheet` is flush (`SheetSurface`): rows start on the sheet gutter with the headings, with no card. Off a sheet it keeps its white card and 20pt inset |
| Demo truth | one concise notice where data stays local; no implementation commentary on product screens |

## Implementation batch (2026-11-04, continued)
Representative surfaces: Discover (`/home`) and the Discover filters sheet, at 390pt and at
320pt/200%, with identical demo data. Evidence is **golden-harness renders** (Linux), not a device.

| # | Surface | Finding (current) | Change | Test |
|---|---|---|---|---|
| BM-01 | Discover hero, Likes profile, preview | Four badges on the photo ("Sample profile", "Verified", "New here", "4 photos") competed with the photo | Verified becomes a tick at the end of the name's last line, in the name's semantics ("Maya, 29 Verified"). A long name that wraps keeps the tick beside its final word | `bumble_meetup_test` BM-01 |
| BM-02 | Filters sheet, unmatch-reason sheet, every `ListGroup` in a sheet | Switch rows sat in an invisible white card, 20pt inside the headings and slider above them | `ListGroup` is flush inside `showNumayaSheet` (new `SheetSurface` marker); explicit `flush:` overrides | BM-02, proven to fail with flush disabled |
| BM-03 | Chat attachments (pending tile, video card) | " · " joins in file metadata | `MetaText.join`; the bar takes `separatorColor` on sent bubbles | `component_cleanup_test` |
| BM-04 | Voice note, pronouns label, permission demo tag, verify footer | Copy joined with " · " | Colon or brackets | `chat_media_test` |

**Kept as is, with reasons:**
- "Continue with {plan} · {price}": a price on a button, read as one phrase.
- Android permission labels ("While using the app · approximate"): they mirror the system prompt.
- Profile identity chips ("Woman · she/her"): one chip, one fact.

**Captures:** 24 goldens changed and reviewed (Discover family, filters, chat media, onboarding copy,
large-text sweeps); 5 renderer-only goldens restored. Sheets:
`artifacts/bumble-meetup/representative-before-after.jpg`,
`copy-and-large-text-before-after.jpg`, `current-representative.jpg`.

**Route coverage this batch:**

| Status | Routes |
|---|---|
| Implemented and verified | `/home`, the filters sheet, `/likes/:id`, `/chat/:id` (attachments), `/setup` gender, location and verify |
| Reviewed, sound | `/profile/settings`, the unmatch sheet, `/messages`, `/events` |
| Deferred | Illustration art (Safety, Premium, Opening Moves) |
| Blocked | Device, TalkBack, iOS: no SDK or device here |

## Remaining, ranked by user impact
1. **Device pass (Windows):** TalkBack (including the merged "Verified" announcement), the
   keyboard over the frosted bar, off-switch visibility, frame times, both navigation modes.
2. **Illustration placeholders** dominate the tops of Safety, Premium and Opening Moves: commission
   the art, or shrink the placeholder ratio.
3. **At 320pt and 200% text** the photo-count badge overlaps the placeholder glyph (it is cosmetic:
   real photos have no glyph).
4. **Product readiness:** backend, auth, moderation, signing, privacy (FINAL_QA.md).

## Readiness
| Target | Decision |
|---|---|
| Internal demo | **Go** once a debug APK is built on Windows |
| Staging | **No-go:** no backend |
| Public release | **No-go:** see FINAL_QA.md |

## Contract additions: final design run (2026-11-05, device-verified)
| Area | Rule |
|---|---|
| Art | Never show an unfinished illustration on a product screen: an `IllustrationSlot` without `asset` collapses. Placeholders appear only inside `IllustrationPlaceholders` (the Design Lab, slot tests) (FD-A1) |
| Switch | Off: light track plus a 1.5pt `control` edge (≥ 3:1 on white and on the page). On: purple track. The thumb is always white (FD-A2) |
| Buttons | Never truncate a button label: up to two centred lines; the height is a minimum (56 / 40) (FD-B1) |
| Header actions | 8pt between adjacent header buttons; every header action uses the floating filled square (FD-D1, FD-D2) |

Record: [../final-design-run/README.md](../final-design-run/README.md).

# UI review batch 3: Messages, Chat, Profile and app-wide consistency (UI-033 to UI-046)

**Pass:** 2026-11-06, cloud session (Linux).
**Worktree:** `/home/user/numaya-ente`, restored from `numaya-ente-recovery-20261106-032818-f2e18e6.zip`.
**Branch:** local `experiment/numaya-ente-design-system`.
**Base:** `f2e18e627af9f06e9563db5bf09828995dcde5c4`. **Uncommitted; not pushed.**

**Sources:**
- `NUMAYA_UI_REVIEW.md` and `CLAUDE_MESSAGES_CHAT_PROFILE_IMPLEMENTATION_BRIEF.md` (package `NUMAYA_MESSAGES_CHAT_PROFILE_HANDOFF.zip`, SHA-256 `f1f7304b…7400`);
- assets A-015 to A-025.

The issue IDs, wording and source documents are the reviewer's; nothing here replaces them.

**Evidence labels:**
- *Harness* means a Flutter golden-harness render on Linux at 390 × 844 (2x), or 320 × 693 at 200% text.
- *Test* means an automated widget test.
- No emulator or device was available in this session. The earlier Windows emulator run (emulator-5554) covered the restored source **before** this pass.

**Evidence paths:**

| Path | Contents |
|---|---|
| `artifacts/ente-design-system/review3/r3-before-after.jpg` | A-015, A-017, A-018, A-020 and A-021, restored state against this pass |
| `artifacts/ente-design-system/review3/r3-interactions.jpg` | Time reveal, reply preview, sent reply, keyboard with a multi-line draft, verified Profile, and the Filters tooltip and switch (A-022, A-025) |
| `artifacts/ente-design-system/review3/r3-320-200.jpg` | 320pt at 200% text |
| `artifacts/ente-design-system/review3/before/`, `after/` | The individual renders |

**Capture command:** `flutter test --tags comparison --run-skipped --update-goldens --dart-define=R3_SET=after test/screenshots/capture_review3_test.dart`.

## Tracker
| Issue | Scope | Matching usages | Status | Verification evidence | Remaining |
|---|---|---|---|---|---|
| UI-033 | Messages New matches row | `_MatchTile` (the only use) | **Implemented (restored), verified** | Test: `profile_review3_test` (equal squares ≥ 80pt, no names or countdowns, spoken label keeps name and time left); `dating_test` journeys open the match by its label. Harness: a015 | Corner value is Numaya's card radius; the Figma node for A-016 is unidentified |
| UI-034 | Likes tile | `_LikesTile` | **Implemented (restored), verified** | Test: the tile's spoken count equals `unansweredLikes()`. Harness: a015 | Uses the existing mascot artwork; a dedicated illustration is the reviewer's call |
| UI-035 | Chat: left swipe reveals the time | Every message (text and attachment) through `SwipeableMessage` | **Implemented, verified (harness and test)** | Test: `chat_review3_test` (hidden at rest and day line kept; a left drag reveals that message's time, bounded, hidden on release, no reply started; long press, then Show time pins it). Harness: i1 | Device gesture feel (Android/iOS) not checked |
| UI-036 | Chat: right swipe replies | Same | **Implemented, verified (harness and test)** | Test: a right swipe past 56pt replies to exactly that message (`replyToId` checked); short and vertical drags don't; cancel clears it; changing the target replaces it; double Send sends once; a Reply semantics action exists. Proven to fail when the target is dropped. Harness: i2, i3 | Attachment replies store the target, but the quote is drawn only in text bubbles |
| UI-037 | Inactive text fields | `InputSurface` (all `NumayaTextField`s), search field, code cells, chat `Composer` | **Implemented, verified** | Figma Text Input (2275:11526) read: Default is white with no stroke. Shared fields already matched; the chat composer, the one bypass, now has no idle stroke and a 2pt purple edge when focused. Test: `chat_review3_test` UI-037. Harness: a017, i4 | None |
| UI-038 | Full-width composer | Chat only | **Implemented, verified** | One white bar, edge to edge, holding Plus, field and Send, plus the reply and pending-attachment previews. It extends under the system inset and sits above the keyboard. Test: bar width = screen; controls inside. Harness: a017, i2, i4, s320 | Device keyboard behaviour not checked |
| UI-039 | Up-arrow Send | Chat `Composer` | **Implemented, verified** | `NumayaIcons.arrowUp`; disabled grey when empty, purple when sendable; duplicate sends prevented. Test: icon check, double-Send test. Harness: a017, i4 | None |
| UI-040 | White incoming bubbles | `MessageBubble` | **Implemented (restored), verified** | Test: incoming fill is the surface (white), yours is purple. Harness: a017 | No dark theme exists |
| UI-041 | App-wide demo copy | About 40 strings in 20 files: badges, notes, footers, demo tags | **Implemented; verified on the sampled routes** | Removed (copy, widget and spacer): chat footer, "Sample profile" badge, Likes/Match/Events/photo-viewer/finish sample notes, onboarding location/notification/verification demo cards, permission demo tag, photo-source/notification/settings footnotes, visibility demo badge/notes/section, recovery-email and verification demo cards, event host "Sample host" and RSVP demo detail, attachment "Sample" metadata, offline "Simulated" note, the Edit photos note. Reworded: about 30 strings that mixed real information with a demo clause. Test: `profile_review3_test` UI-041 (Discover, Likes, Chat, Profile); 19 older tests updated to the new copy | **Kept on purpose** (they would otherwise imply an outcome that didn't happen): chat delivery state "Not sent: saved on this device"; paywall/purchase disclosures; "(simulated)" verification results; safety report, appeal, support-contact and share-date notes ("nothing is sent or reviewed"); Demo Hub, Design Lab and Settings › Prototype tools (developer surfaces). Recorded for the reviewer |
| UI-042 | Profile summary | Profile tab | **Implemented, verified** | 128pt circular photo, centred, overlapping the card's top edge; name and age; verification pill (Verified, In review, Try again, Not verified; unverified opens verification); Edit profile. Interests, demographics and the globe are gone. **Globe:** it opened Preview, which Edit profile also opens, so it was redundant. Test: geometry, removed items, verified state, Edit profile navigation. Harness: a018, i5, s320 | None |
| UI-043 | Illustrated completion card (optional) | Profile tab | **Optional, deferred** | The current card is acceptable (per the review) and no suitable illustration exists | Artwork, if wanted |
| UI-044 | List-card padding | `ListRow` (16 × 12), `ListGroup` flush rows, `OptionCard`, `InputSurface` | **Implemented (restored), verified** | Birthday label and date sit 16pt inside the card, matching field and option rows. Test: `profile_review3_test` UI-044; 3 restored tests updated to 16pt. Harness: a020 | None |
| UI-045 | Muted metadata and helper copy | `ListGroup` footnote (caption, `textMuted`), `ListRow` detail (`textMuted`), conversation read previews (`#1A1A1A` → `textMuted`), completion counts | **Implemented, verified** | Birthday note colour test; harness a015, a020, a021 | Sheet body ledes use `textSecondary` (`#1A1A1A`) on purpose: they are content, not metadata (UI-048 review) |
| UI-046 | Complete your profile | The completion hub | **Implemented, verified** | A summary card (muted label; percentage in the `metric` role 40/44 with a "complete" unit; 8pt bar; muted lede), then one list card of six rows (name in `row`, count as a muted caption, Done or chevron). The header illustration slot is gone. Each row keeps its editor. References: Mobbin [Bumble completion](https://mobbin.com/screens/6fda00e7-80c4-491f-b6ae-0021249ed16d) and [happn](https://mobbin.com/screens/e642ca7d-6c35-4aa1-9fc4-9c9116f78033); Ente Menu Item rows. Test: six parts with counts, metric role, every destination opens, Bio completion updates the percentage and shows Done. Harness: a021, s320 | None |

## Shared follow-up (from the brief)
| Issue | Status | Evidence |
|---|---|---|
| UI-005 | **Implemented, verified (harness)** | The black paddle is replaced by Ente's Tooltip with a bottom pointer (A-024): white, dark semibold value, soft shadow, kept inside the slider. It covers both age-range sliders (Filters and onboarding). Harness: a022 capture; an isolated render was checked while debugging |
| UI-025 | **Implemented, verified** | The off track uses the lighter existing neutral `switchOff`, with no outline; the thumb has a hairline edge and shadow. It covers every `NumayaSwitch`. Two tests were updated to the 2026-11-06 decision (they had pinned the earlier 3:1 control grey). Harness: a022 |
| UI-022, UI-047 | **Implemented, verified** | `ViewTabs` inactive pills are white with no stroke on grey pages and sheets (every caller). A new `onWhite` flag adds the subtle edge where the surface is white. `NumayaChip` already followed this rule. Test: the Filters tabs |
| UI-048, UI-049 | **Partial** | This batch's neutrals and paddings are reconciled (the switch, read previews, list-card inset). No full app-wide audit was run |

## Found and fixed along the way
- `_QuotedReply` and `ReplyPreview` drew a one-sided border with rounded corners, which Flutter rejects when it paints. Nothing exercised them until UI-036. Both now use a clipped bar surface.
- Lucide icons rendered as boxes in every golden-harness render: the test font loader didn't register the package font. `loadAppFonts` now loads it. **The committed goldens predate this**, so they show boxes.
- Day separators showed only in the scripted sample threads. They now show in every thread, since exact times are hidden.

## Tests (this pass, Linux)
| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` | **416 passed, 16 skipped, 0 failed** (the restored source started at 388 passed, 5 failed) |
| New tests | `chat_review3_test` (10), `profile_review3_test` (13), `capture_review3_test` (15 opt-in captures) |
| Updated tests | 5 stale restored tests (UI-044, UI-033); 19 copy or spec assertions (UI-041, UI-042, UI-025, UI-047, UI-035); none removed or skipped |
| Screenshot goldens (`--tags screenshots`) | **Not regenerated.** The committed goldens are Windows renders that predate this pass and the Lucide font fix. Regenerate on the target platform and review |
| Emulator or device | **Not run here.** Needs the Windows emulator: gesture feel, keyboard, TalkBack |

## Remaining simulated behaviour (unchanged; copy removed only where safe)
Local demo data, scripted replies, no backend delivery, simulated verification and purchases, and reports that are kept locally. See the "kept on purpose" list under UI-041.

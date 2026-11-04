# Core journey: research, wireflow and decisions (checkpoint)

**Run:** 2026-11-04. Worktree `/home/user/numaya-overnight`, branch
`experiment/numaya-overnight-polish`, HEAD `6b23c85`. **Local only, uncommitted.**

## WP1: research (live Mobbin, iOS; images inspected)
| Question | Reference | Observation | Suggests for Numaya |
|---|---|---|---|
| What do people need before liking? | [Bumble, People](https://mobbin.com/screens/83e93b49-e15d-462c-ae89-810a4613cea0) | Name, age and verified on the photo; a "We have things in common" card directly under the photo, ahead of anything else | Put shared ground (You both like) right after identity, before the deeper profile |
| (Alternative) profile hub | [Hinge, profile](https://mobbin.com/screens/e3a435f1-9117-467e-8622-27a54be3c751), [Hinge, profile 2](https://mobbin.com/screens/e341f5d7-d9df-4ecf-aa2f-d2fd524edbaf) | Own profile: avatar first, then tabbed sections and upsell cards; not a discovery screen | Our own Profile's hero plus tiles is consistent; no change |
| Choosing interests | [Bumble, Interests](https://mobbin.com/screens/ff63ca32-0913-418e-876d-120f3481074f) | Categorised pills, "Show more" disclosure, one primary action | Our categorised `ChipSet` already matches; no change |
| What deserves prominence in an inbox? | [Bumble, Chats](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74) | A matches carousel, then a flat chat list; no promo card in between; a quiet "Your move" pill | The Opening Moves promo card should not sit between new matches and conversations |
| Composer | [Bumble, chat](https://mobbin.com/screens/f240ef7c-e408-4a63-ad4f-ad204ce34694); [Discord](https://mobbin.com/screens/5590805e-aea0-4148-9973-9bd079e91c2f) | Bare action icons beside one pill field; no tray | Already applied (CL-06) |
| Bottom navigation | Bumble (labelled tabs, solid white); Hinge (solid dark bar); Tinder and Coffee Meets Bagel (translucent pill), see the frosted-navigation README | Solid bars favour clarity; floating pills favour content continuity | Compared in WP4 |

## Wireflow: discovery → profile → match → conversation
```
Discover (card: photo, identity, decision row)
  ├─ scroll ↓ → full profile (bio, facts, prompts, You both like) ─ floating Pass / Like
  ├─ Pass ─→ next card ─→ [Undo toast: one step back]
  ├─ Like ─→ (no mutual) next card
  │        └→ (mutual) Match screen ─┬─ type an Opening Move → Chat
  │                                   └─ Keep browsing → Discover
  ├─ Filters (sheet) ─ Apply / Reset / dismiss
  ├─ ⋯ → Report / Block (sheet) → confirm → person removed
  └─ States: loading · error ("Still can't load" → Try again) · no one fits (widen) · seen everyone (show again)
Messages ─ new matches row → Chat;  conversation row → Chat
Chat ─ composer (attach / field / send) ─ ⋯ (Did you meet? / Unmatch / Report) ─ back → Messages
  └─ States: expiring (Extend) · expired (Rematch) · offline banner · not sent (demo, truthful)
Android back: pops the step → returns a chat to Messages → returns to Home before leaving
```

## WP2: Discover, A against B (DX-02)
`artifacts/direction-2/discover-A-vs-B.jpg`: identical content, at 390pt 100% and 320pt 200%.
- **A (previous):** a 4:3 photo, identity, then the decision row; "You both like" far down the
  scroll, after the prompt and About me.
- **B (chosen):** shared ground moves into the hero card, under identity and before Pass/Like
  (Bumble's "things in common"); the body no longer repeats it.
- **Tested and rejected:** a 4:5 photo. On 320×693 it would push the decision row under the tab
  bar.
- **Large text:** at 320pt and 200%, B first hid the decision row under the bar. Fix: above 160%
  text the chips return to the body (`artifacts/direction-2/discover-B2/`). Tests:
  `core_journey_test`.
- **Trade-off:** one more line in the hero at normal size.

## WP3: Inbox and Chat (DX-03)
- **Moved:** the Opening Moves suggestion now follows the conversation list instead of sitting
  between New matches and Conversations (Bumble Chats: matches, then chats).
- **Verified unchanged (current renders, `journey-before-after.jpg`):**
  - conversation rows: name, a bold preview when unread, time, count, "Your move";
  - the composer without a tray (CL-06);
  - one truthful demo notice plus a "Not sent" status (CL-07).
- **Interactions:** covered by the existing suite: send, double send, long messages, the keyboard
  at 200%, back to Messages, unmatch, report.

## WP4: Navigation and consistency (DX-04)
**Solid against frosted** on identical Discover, Messages and Events content
(`artifacts/direction-2/nav/nav-frosted-vs-solid.png`):
- Selection is equally clear in both (tint circle, filled purple icon); contrast is unchanged.
- The solid bar cuts content off on a page-coloured strip. The frosted pill lets content continue
  beneath it, which answers "navigation feels disconnected".
- **Kept:** frosted by default, solid under High Contrast. **Performance:** device-only.

**Separator migration:** the Likes tile caption and the event venue line now use `MetaText`
(semantic labels read the joiner as a comma). Attachment details remain.

**Illustration placeholders:** the dashed slots (Safety, Premium, Opening Moves headers) are
development placeholders at 16:9. The asset backlog in ILLUSTRATION_ASSET_BACKLOG.md stands; no
new art this pass.

## WP5: verification
| Check | Result |
|---|---|
| Format, analyze | clean |
| `flutter test` | see VALIDATION.md (final run) |
| New tests | `core_journey_test` (3) |
| New opt-in comparison harness | `compare_navigation_test` |
| Captures | 27 goldens changed; all intended (Discover hero, Messages order, separators) and reviewed |

**Device-only checks still open:**
- frame times with the frosted blur (profile mode);
- the off-switch visibility on a real screen;
- the keyboard over the frosted bar;
- TalkBack and VoiceOver reading the `MetaText` lines;
- gesture and three-button navigation;
- iOS.

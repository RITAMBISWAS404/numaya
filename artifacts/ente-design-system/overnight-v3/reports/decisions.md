# Overnight v3: decisions

Branch `experiment/numaya-ente-delight-v3-20261106-0624`, from checkpoint `e60504e` (tag
`numaya-ente-design-system-finalized-20261106-0624`). All A/B/C options are **proposals waiting for
your choice**. Nothing was merged on your behalf.

## 1. Baseline corrections (these apply to the refined candidate)
| ID | Kind | Problem (seen in the frozen Current) | Change | Evidence |
|---|---|---|---|---|
| V3-D01 | Defect | Unmatch sheet overflowed by 31pt at 320pt, 200% text (yellow stripes; Unmatch button cut) | The consequences and "report instead" card scroll above a pinned Unmatch action; same for Block. A shared scroll wrapper was tried first and **rejected**: it unpinned the Filters and Report footers | `v3_fidelity_test` (fails without the fix: 1227px overflow); `screens/*/overlays/o03-unmatch-sheet` |
| V3-D02 | Defect | Empty-state titles broke inside a word ("Connection s") at 320pt, 200% text | `EmptyState` narrows its side insets from 24 to 16pt at large text | `screens/*/settings-safety/e04-blocked__…320x693`; EXP-003 refined control |
| V3-F01 | Ente fidelity | The tappable "Think they've broken our guidelines?" card had no tap affordance | `InfoCard.trailingArrow`: Ente's actionable banner arrow (Banners 14590:125245) | `components/banners`, `v3_fidelity_test` |

Kept as they were: buttons, fields, chips, switch, lists, banners, toast and action sheet. They were checked against the
fresh Figma renders and match the overnight-v2 decisions (`components/*`).

## 2. Experiments (pending your choice)
| Experiment | Recommended | Why | Main trade-off |
|---|---|---|---|
| EXP-001 match moment | **A · Paired portraits** | Adds the mutual "you and them" meaning while the person stays the hero | Shows your own photo too; placeholder-heavy until real photos exist |
| EXP-002 own-profile header | **Current** | UI-042 is an approved decision and the refined header meets it | If you want change, C (quick actions) is closest to UI-042 |
| EXP-003 empty conversations | **A · Cat says hello** | Keeps Ente's EmptyState card, adds character and a second honest route | Two buttons in an empty state |
| EXP-004 completion card | **A · Ente progress banner** | Ente's own component for this job; leaves Edit profile as the single primary action | The action is an arrow rather than a labelled button |

These are model recommendations from visual review, not user-test evidence.

**How to reply:** `EXP-001 A; EXP-002 Current; EXP-003 C; EXP-004 B`. You can also export from the
gallery or fill `USER_CHOICES.csv`. In the app, open Demo Hub › Experiment Lab to try each option live.
"Copy my choices" there produces the same text.

### Test questions for each option (if you run a quick test)
Framed with the ux-researcher-designer skill's usability guidance. No personas were generated.
- Match: "Who did you match with, and what would you do next?" Measure time to Open chat, and whether they recall the shared interests.
- Profile header: "Change your bio. Then check how others see you." Measure taps to Edit and to Preview.
- Empty conversations: "You're new. How would you start talking to someone?" Measure the first tap target.
- Completion: "What's missing from your profile?" Measure whether they name a specific part.

## 3. Revisions made during review
- **First review (390x844):**
  - EXP-001 B fell back to an image glyph, so it now shows the initial.
  - A and C repeated "You and Maya", so the body line is now "You liked each other".
  - EXP-002 C tiles didn't stretch.
  - EXP-004 B's full-width Continue was a second large primary, so it is now small.
- **Second review (320pt at 200% text):**
  - EXP-001 B: the initial overlapped the name.
  - EXP-002 A: the name met the initial and the Edit pill, and the fade was too weak; the cover is now taller with an earlier fade.
  - EXP-002 B: Edit overflowed by 11pt, so it now stacks.
  - EXP-002 C: labels broke mid-word, so the actions are now rows.
  - EXP-003 C: the hero title broke mid-word.
  - EXP-004 C: the title broke mid-word, so the cat now sits above it.
- **Rejected:**
  - A "Likes, empty" mascot panel. The state isn't reachable with the demo data, and the capture showed the full Likes grid, so it was removed rather than mislabelled.
  - A shared sheet scroll wrapper (see V3-D01).

## 4. Mascot
- **Ente reference.** The Ente Ducky catalog (Figma 14583:6595) names one pose per product state. Each pose holds a prop that tells the story: a shovel for no matches, a sign for an offer, a camera for shared photos. Some states deliberately have no duck ("Hidden: no duck").
- **Numaya's cat.** It follows the same rule. It reuses the approved purple cat (`mascot-waiting.svg`) and adds three provisional poses drawn from the same geometry: celebrate, hello, and cheer with a star.
- **Shared slot.** The poses are reached through one slot, `MascotArt(MascotPurpose…)`. It bounds the width and the share of screen height, is decorative to screen readers, and has no animation.
- **No cat in:** Settings, Safety, Report, Unmatch/Block, account holds, delete account, consent or permissions, and errors.
- **Duck untouched.** Ente's duck was not copied or recoloured.
- **Manifest:** `mascot.csv`.

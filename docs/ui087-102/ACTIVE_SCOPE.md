# Active scope: UI-087 to UI-102 review phase

Written 2026-11-15 before implementation. Sources: `NUMAYA_NEW_VERSION_REVIEW_HANDOFF.zip` (original register,
NEW_PHASE_SCOPE, brief, open questions, QA plan, tracker) and `NUMAYA_CORRECTED_EXECUTION_UI087_102.zip`
(scope rules, coverage matrix, execution plan, final QA contract).

**Baseline.** Worktree `C:\Users\biswa\Projects\Numaya-fable-lab`, branch `experiment/numaya-v8-review-20261114-0321`
at `96c7872` (app source `fe44b27`, the V8 review build). Clean before work. Checkpoint tag
`checkpoint/pre-ui087-102-20261115-0309` and implementation branch `experiment/numaya-ui087-102-20261115-0309`, both
pushed to `origin` and verified with `git ls-remote`. Flutter 3.47.8. `Numaya`, `Numaya-backend` and the two protected
branches are not touched.

Latest decisions override older text. The 72 other register entries are context, not a backlog.

## 1. New issues (16)

| ID | Requirement in force | Batch |
| --- | --- | --- |
| UI-087 | Identity and information pills, and their selection chips, are fully rounded capsules in every state (read-only, selected, unselected, with icon or add/remove). Buttons and tabs keep their own rules. | 2 |
| UI-088 | Leading icons in menu rows and comparable list-card rows (Profile menu, Streak tasks, Repair, credit balance and history, Premium "What's included") are outline glyphs. Takes precedence over UI-070 in those rows. | 1 |
| UI-089 | Birthday keeps the group label; Day/Month/Year labels go; placeholders DD, MM, YYYY; distinct accessible names and the existing validation stay. | 2 |
| UI-090 | Every slider (age, distance, height; single and range) uses the onboarding "Their age" vertical clearance, measured around the full thumb and touch area. | 2 |
| UI-091 | Image reply preview: the thumbnail fills the preview height inside top, bottom and right insets equal to the quote line's top, bottom and left spacing; dismiss sits outside the tinted panel, vertically centred. Chat and Compliments. | 4 |
| UI-092 | Compliment composer: credit usage and balance at the leading edge, character count at the trailing edge of the field. | 4 |
| UI-093 | Enabled Send is brand-filled with a white up arrow, vertically centred on the field. Empty mic and Plus keep their outlined state. | 4 |
| UI-094 | One centred status template (icon or reserved illustration, heading, optional copy, actions) for payment failed, pending and success, Discover no-results and comparable states; white card explored as a shared surface option. Actions keep working. | 2 |
| UI-095 | Dev Mode brand colour: Default (current `#7262C7`), `#7E77F8`, `#A07ADD`, applied to brand roles only (not neutral or semantic roles), live, without restart. | 3 |
| UI-096 | Dev Mode button shape: Default (existing radii) and Fully rounded. No third option is invented. | 3 |
| UI-097 | One Dev Mode reset restores every Dev Mode setting (font pairing, brand, shape, secondary surface, plus the existing body-size toggle) and never touches account or profile data. | 3 |
| UI-098 | Dev Mode secondary surface: Outline (current default) and subtle Filled (about 5-10% black over the background), active, inactive and disabled defined in both. | 3 |
| UI-099 | Two-phase onboarding (required, then optional). **Field split, step order and completion rules blocked** (see section 4). | 5 |
| UI-100 | Discovery benefits of completion. **Blocked** (see section 4). | 6 |
| UI-101 | Header step progress is one continuous track with one fill that follows the active path. Not statistics charts. | 2 |
| UI-102 | No scroll-triggered bottom stroke on any top app bar. Content dividers (UI-003) and the Discover bar (UI-013) are separate. | 2 |

## 2. Amended or reaffirmed issues (14): current required change

| ID | What is in force now | Superseded text not to rebuild |
| --- | --- | --- |
| UI-010 | Informational cards: icon top-left, aligned with the heading (via UI-060). | The stacked icon-above-heading alternative for this family. |
| UI-012 | Finite type catalog by role (display, page, sheet, subheading, body, metadata); metadata smaller than body; three text-colour roles (primary near-black, secondary dark grey, tertiary lighter readable grey); verified under every UI-085 preset. | Nothing removed. The 14 px wording does not overrule the existing 14/15 review toggle; the current default (15) is kept and recorded as an unresolved baseline conflict. |
| UI-026 | Floating nav: larger tiles through internal padding, same glyph size, fully rounded shell and tiles (outer = inner + inset), visible clearance above the bottom safe area. | 38x48 tiles, 20/12 radii. |
| UI-033 | New matches: circular photos at the conversation-avatar diameter with a real, shrinking expiry ring. | Large rounded-square tiles without rings. |
| UI-049 | Image overlays use the standard card padding on all four edges (Likes, Discover and every comparable overlay). | Nothing removed. |
| UI-060 | One informational card: white surface, shared shadow, heading-aligned top-left icon, optional supporting text on the same text edge. | Grey fill for passive callouts. |
| UI-067 | Filled grey preview icons per type (photo, video, voice, Compliment); unread is a dot on the avatar's bottom-right, cleared when read; Archive rows too. | Numeric unread badge. |
| UI-068 | One list; "Your move" pill at the trailing edge when it is the user's move; coexists with the unread dot. | Grouped lists and waiting labels (already removed in V8). |
| UI-070 | Shared compact cutoff, filled glyphs below it; conversation previews and chat media controls (play, pause, download) filled. Menu rows follow UI-088. | Filled icons in menu rows and credit history. |
| UI-072 | Plus and the right-hand control keep the shared circular outline in the empty (mic) state. | Outlined enabled Send (now UI-093). |
| UI-073 | Composer field and reply preview both use the standard app-background token, in empty and typed states. | The neutral fill token. |
| UI-074 | Category audits in order: type, colour, gradients, spacing, shape, strokes and elevation, icons, illustrations, component states, whole-app check. This phase runs them for the families touched above. | Nothing removed. |
| UI-085 | Four fixed pairs, display first: Default (Plus Jakarta Sans / Figtree), Halant + Nunito Sans, Yeseva One + Josefin Sans, Bree Serif + DM Sans; persisted; real bundled weights. | The independent display and UI selectors (Fraunces, Instrument Serif, DM Serif Display, Manrope, Poppins). |
| UI-086 | Countdown is one inline line (clock icon and remaining time) under the match name on the screen background. No Extend control, no Instant. | The separate white countdown card. |

## 3. Historical dependencies (inspect, do not rerun)

| Dependency | Linked active issue | Narrow reason |
| --- | --- | --- |
| UI-002, UI-057 | UI-098 | Default secondary outline and disabled-button rules that the Filled variant must keep. |
| UI-050 | UI-026, UI-087, UI-096 | Nested-radius rule; its fixed nav radii are replaced. |
| UI-003, UI-013 | UI-102 | Content dividers and the Discover bar stay. |
| UI-011 | UI-033 | Full profile photos stay portrait; match avatars are outside it. |
| UI-007, UI-020 | UI-012 | Prompt answer/label hierarchy and placeholder-equals-value metrics. |
| UI-035, UI-071, UI-038, UI-039 | UI-067, UI-091, UI-093 | Timestamp visibility, quoted content, composer container, Send glyph. |
| UI-052, UI-055 | UI-089 | Age confirmation sheet and redundant copy. |
| UI-005, UI-024 | UI-090 | Active value feedback and track width stay. |
| UI-009, UI-023, UI-047, UI-048 | UI-060, UI-010 | Verification card content, sheet surfaces, outlines, neutral greys. |
| UI-053, UI-077 | UI-094, UI-088 | Intentional icon choice; illustration slots stay reserved (no artwork invented). |
| UI-046, UI-058, UI-059, UI-078 | UI-099, UI-101 | Completion page, preview, content order and summary cards: progress must stay separate from completion. |
| UI-063 | UI-100 | No standalone For you. |
| UI-066 | UI-049, UI-095 | Photo gradients are neutral and do not follow the brand selector. |

## 4. Unresolved decisions and what they block

| Decision | Blocks | Does not block |
| --- | --- | --- |
| UI-099 field split, step order, completion rules. Searched the repo (`docs/product/**`) and the owner's package folder on 2026-11-15: only PRD v1 (`docs/product/mvp-prd-v1`) exists, which predates the two-phase split and the reviewer says the updated PRD was not supplied. | Which screens are Phase 1 or Phase 2, the publish-early path, the optional continuation, resume and the path-specific step counts. | UI-101 continuous track on the existing path. |
| UI-100 personalization and visibility rules. PRD v1 says completion "never changes ranking"; no newer approval exists. | Any ranking or visibility change and any in-app benefit claim. | Nothing else. |
| UI-096 third shape. | A third option (not built). | Default and Fully rounded. |
| UI-026 exact Figma geometry. The Figma connector needs authorisation in this session, so nodes 7634:54339 and 2513:47854 could not be re-read live. | Exact Figma numbers. Values chosen from the stated relationships are recorded as design decisions. | The relational requirements. |
| UI-094 artwork. Mascot/illustration artwork is pending (UI-076/077). | Final artwork. Slots stay reserved. | The template. |
| Production font, body size, palette, shape and secondary surface. | Choosing a winner. All Dev Mode defaults stay the verified baseline. | The comparisons. |
| UI-070 compact cutoff value: not approved. | An "approved" number. A documented design decision is used. | Filled categories named by the reviewer. |
| UI-012 14 vs 15 body baseline. | Changing the default. | The existing 14/15 toggle stays. |

Additional directly related defects found during the work are logged separately as DEF-nn in the tracker.

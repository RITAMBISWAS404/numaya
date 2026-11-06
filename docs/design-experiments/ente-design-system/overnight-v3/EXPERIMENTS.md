# Overnight v3: experiments

Every experiment is implemented in Flutter. In debug and demo builds, open **Demo Hub › Experiment Lab** to switch each one independently. Release builds always show the refined candidate (Current). Selection is pending: reply like `EXP-001 A; EXP-002 Current; EXP-003 C; EXP-004 B`.

Code:

- Lab and choices: `lib/features/experiments/`.
- Variants: `match_variants.dart`, `profile_variants.dart` and `empty_conversations.dart`.
- Mascot slot: `core/design_system/widgets/mascot.dart`.

Evidence:

- `artifacts/ente-design-system/overnight-v3/experiments/<id>/`.
- Captured by `test/screenshots/capture_v3_experiments_test.dart`.

## EXP-001-match-moment · Match moment

**Where:** `/match/maya`

**User task:** Someone liked you back: recognise who it is, feel the moment, then open the chat (or view their profile, or keep browsing).

**Opportunity:** The refined match screen is clear but shows only the other person; the moment of mutual interest is not expressed as a pair, and the screen is visually plain.

**Figma:** [Ducky product catalog](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=14583-6595); [Buttons Large](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=2207-41759); [Banners](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=14590-125245).

**Mobbin (inspected images, iOS):** [Bumble · What a match! (paired tilted photos)](https://mobbin.com/screens/d0a3d260-6611-46c0-9eb0-5de2f7f8fdbd); [Bumble · match with send field](https://mobbin.com/screens/0d225721-ea2e-45c2-9f8c-5ad79376be1d); [Bumble · you sent a note (illustration in a sheet)](https://mobbin.com/screens/b15493f3-1516-46b8-9c60-d86be2cce234).

| Option | Name | Axis | Strength and cost |
|---|---|---|---|
| Current | Refined candidate | (pre-run layout) | Approved baseline |
| A | Paired portraits | relationship: both people as two tilted portrait cards with a heart on the seam; headline names both | Says "the two of you" without words; familiar from Bumble. Costs: shows your own photo too (placeholder-heavy until real photos exist) and two cards are smaller than one. |
| B | Identity-led photo hero | scale and immersion: the person's photo fills 54% of the height with name, age and verification on it, as on their Discover card | Most recognisable: the match looks exactly like the card you liked. Costs: the photo dominates, the moment reads like a profile, and shared interests drop below the fold on short phones. |
| C | Restrained cat celebration | emotional tone through illustration: the celebrating cat leads; small round avatars and shared interests in one card | Warmest and lightest; the cat never covers a face. Costs: people are small, so the identity is weaker; the cat may feel playful for some users. |

**Recommendation (not selected):** A. Paired portraits keeps the person as the hero while adding the mutual "you and them" meaning, with no new feature. B is a safe fallback if photo recognisability matters most; C is best kept for empty states.

## EXP-002-own-profile-header · Own-profile upper section

**Where:** `/profile`

**User task:** Check how you come across and get to editing quickly; see verification state.

**Opportunity:** The approved UI-042 header is clear but tall; Edit profile and Complete profile are two large purple actions close together, and Preview is two taps away.

**Figma:** [Settings DS (updated screens)](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=12099-96480); [Account](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=12099-96630); [Header v2](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=11439-5040).

**Mobbin (inspected images, iOS):** [Hinge · profile tab (photo ring, edit pencil)](https://mobbin.com/screens/a290666b-b4af-4ebc-81fa-1dda2823a270); [Bumble · profile tab (compact avatar, Complete profile pill)](https://mobbin.com/screens/d54f9b27-0e47-48b1-88ea-0bb3c349c328); [CapCut · Me tab (avatar + name row)](https://mobbin.com/screens/6f8a990b-fb94-4737-8b64-35097f520073).

| Option | Name | Axis | Strength and cost |
|---|---|---|---|
| Current | Refined candidate | (pre-run layout) | Approved baseline |
| A | Photo-led cover | photo emphasis: a wide cover photo with the name on it and Edit as a white pill | Shows how others first see you. Costs: departs from the approved UI-042 round photo; weak with no photo (initial on grey). |
| B | Compact identity row | density: 72pt photo beside name and verification, Edit as a small button; profile rows move up a third of a screen | Most efficient; everything important above the fold. Costs: less personal, departs from UI-042. |
| C | Identity with quick actions | action access: centred photo with an edit badge, then Edit, Preview and Verify as three equal actions | Keeps UI-042's centred round photo and adds Preview one tap away. Costs: Edit loses its full-width primary button; three tiles add visual weight. |

**Recommendation (not selected):** Current. UI-042 is an approved review decision and the refined header already meets it. If you want change, C is the closest to UI-042 and adds one-tap Preview.

## EXP-003-empty-conversations · Empty conversations

**Where:** `/messages (fresh account)`

**User task:** New member with no matches opens Messages: understand why it is empty and know what to do next.

**Opportunity:** The refined empty card is generic (a chat-bubble drawing) and offers one way forward.

**Figma:** [Empty states variants](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=26580-259932); [Ducky product catalog](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=14583-6595); [Menu item list](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=5906-38912).

**Mobbin (inspected images, iOS):** [Bumble · empty Chats (left-aligned art, large title, one pill)](https://mobbin.com/screens/f0fd7cdd-7d03-4035-b4a8-94aaeb6357a2); [Luma · It's Quiet Here (illustrated chat preview)](https://mobbin.com/screens/5572330d-1f5e-4f71-bc60-4e83b8bd403c); [Phantom · no chats to show yet (minimal)](https://mobbin.com/screens/6b155c02-d876-419a-9be5-464d6f7b5e82).

| Option | Name | Axis | Strength and cost |
|---|---|---|---|
| Current | Refined candidate | (pre-run layout) | Approved baseline |
| A | Cat says hello | character: the waving cat replaces the generic drawing; Discover plus a quieter Events path in the same card | Friendly and still contained in Ente's EmptyState card; adds a second real route. Costs: two buttons in an empty state. |
| B | Next steps list | actionable choices over mood: no art, short explanation, then Discover, Likes (when there are any) and Events as one list card | Most useful for someone who wants to act now; shows the real Likes count. Costs: no warmth; reads like a menu. |
| C | Open page, one action | page-level editorial composition: no card; left-aligned cat, large title, one pill-width primary | Calm and confident, like Bumble. Costs: a lot of open page; a single action. |

**Recommendation (not selected):** A. Cat says hello keeps the Ente card, adds the brand character where nothing sensitive is happening, and gives a second honest path.

## EXP-004-profile-completion-card · Profile completion card

**Where:** `/profile`

**User task:** Understand how complete your profile is and finish the next part.

**Opportunity:** The completion card is a title, bar and purple button directly under the purple Edit profile button; the next step is not named.

**Figma:** [Banners (progress variant "Pick up again · 40% reviewed")](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=14590-125245); [Buttons Large](https://www.figma.com/design/22AeTw6QiPj2fNYHLhC7MK/?node-id=2207-41759).

**Mobbin (inspected images, iOS):** [Bumble · completion (Complete profile pill on the avatar)](https://mobbin.com/screens/d54f9b27-0e47-48b1-88ea-0bb3c349c328); [Bumble · completion page](https://mobbin.com/screens/6fda00e7-80c4-491f-b6ae-0021249ed16d); [happn · completion page](https://mobbin.com/screens/e642ca7d-6c35-4aa1-9fc4-9c9116f78033).

| Option | Name | Axis | Strength and cost |
|---|---|---|---|
| Current | Refined candidate | (pre-run layout) | Approved baseline |
| A | Ente progress banner | the number leads: muted label, large percentage, round arrow, bar; the whole card opens the hub (Ente banner) | Directly from the Ente source; removes a second purple button. Costs: the action is an arrow, less explicit than a labelled button. |
| B | Next single task | specificity: names the next unfinished part with its count; Continue opens that editor; See all opens the hub | Most actionable; one tap to the exact editor. Costs: more text; Bio opens the hub because its editor is a sheet there. |
| C | Cat encouragement | warmth through illustration: the cheering cat beside the existing title, bar and action (optional UI-043 idea) | Encouraging, small, and reuses the approved cat. Costs: one more illustration on a busy tab. |

**Recommendation (not selected):** A. The progress banner is the Ente component for exactly this job and leaves Edit profile as the single primary action.

## Behaviour kept in every option

- Same data and the same destinations.
- No new features: Opening Moves, Follow and SuperSwipe stay excluded.
- Completion percentages keep their meaning.
- Switching an option never sends, buys, edits or navigates.
- Covered by `test/widget/v3_experiments_test.dart`.

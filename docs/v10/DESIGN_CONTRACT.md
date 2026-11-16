# V10 design contract: People first (direction A)

Written from the round-2 winning renders (393 × 852 logical, 3x, full demo world; files listed in
[EVIDENCE_INDEX.md](EVIDENCE_INDEX.md)). Direction A is what ordinary launches render
(`v10-direction`, `proposed: 'A'`). O (the 42b8dba baseline) and C (Editorial) stay selectable in
the Design Lab, in dev builds only.

Every row names its code and the test that holds it. A row with no test is a review item, not a
contract.

| ID | Rule | Code | Held by |
|---|---|---|---|
| C-1 | **Identity.** Numaya purple `#7262C7` is the only action colour. Secondary accents mark and frame things; they are never used for text. Finite radii ≤ 20 (card 16, sheet 20). Circles and pills are the only exceptions. | `AppColors`, `AppRadii` (tokens) | `ente_design_system_test`, `spacing_rules_test` |
| C-2 | **One About sheet per person.** A white card (padding 20, radius 16) holds the bio, a hairline, the labelled facts and a hairline. Then comes "You both like" (or "Interests" on your own profile) as 14/20 tint pills. The bio uses the card-primary role, 18/24. Labels are 14/20 medium in the supporting grey; values are 15pt body. Facts sit in two columns, and a value too long for its column takes the full row. Gender and pronouns come first when shown. | `v10_person_sections.dart` `_peopleFirst`, `_facts` | `discover_match_review_test` "V10 A: bio, a divider, then labelled facts"; `v10_direction_test` PR-004 contrast; `core_journey_test` UI-015; `type_roles_test` TR-01; `onboarding_flow_test` review |
| C-3 | **Prompt card.** Each prompt is its own white card with the question label, a balanced 18pt answer and an optional action, separated by 16pt gaps. Photos and prompts alternate in the V8 content order (UI-059). | `V10PromptCard` | `visual_lab_v2_test` "a prompt reserves a footer" |
| C-4 | **One Compliment action.** It is labelled "Compliment", never a bare glyph. On a photo it is a dark glass pill; on a prompt it is a tint pill. The minimum height is 48 and the screen-reader label is "Compliment <name>". The hero's name block reserves the pill's width. | `V10ComplimentButton` | `visual_lab_v2_test` "V10 A: the labelled Compliment pill…" |
| C-5 | **Own Profile.** The prompt uses the C-3 card. The whole card opens the editor, with a trailing chevron and no text link, and it is read once by screen readers. Premium stays a row of "Your profile" (D7). Compliment credits and the streak stay above "Your profile" because that order is the owner's earlier selection (see D6). | `profile_screen.dart` | `v10_direction_test` C-5 |
| C-6 | **Received Compliment.** A sender block (72pt photo, "X sent you a Compliment", "about your photo/prompt") replaces the small system line. The photo is dropped at ≥130% text, where the header already shows it. The quoted bubble is unchanged. The reply field sits on a white tray (DEF-V10-01). A visible Dismiss link (44pt target) asks before removing. | `compliment_thread.dart` | `v10_direction_test` C-6, device trace 007–014; `visual_lab_v2_test` "Dismiss asks first" |
| C-7 | **Motion and feedback.** Press feedback is the shared `Pressable` scale (0.98) at `AppMotion.press`. Every duration goes through `AppMotion.duration`, which returns zero when reduced motion is on. No new animation was added in V10. | `primitives.dart` `Pressable`, `app_motion.dart` | `visual_lab_v2_test` "Motion presets M0 is reduced everywhere"; `motion_test` |
| C-8 | **Text never breaks inside a word or gets clipped.** Balanced text never goes narrower than its longest word. Tab titles stack or hyphenate (PR-008). Overflow is not suppressed. | `BalancedText`, `HyphenatedText` | `large_text_regression_test`, `size_matrix_test`, V10 stress renders |

## What did not change (product truth)
- Business rules: credits, the Compliment cost, reply-is-free, Dismiss-asks-first, block and report.
- Events, Health, Follow and SuperSwipe stay off. No decision buttons; swiping has non-gesture paths.
- Riverpod providers, go_router routes and backend contracts are untouched. V10 is presentation only.

## Not yet rolled out (honest scope)
- Likes grid cards, the chats list and Settings already use the shared `ListGroup`/`ListRow` system. V10 does not change them; the critic flagged no defects there.
- C stays a lab alternative. It was not carried to Profile or Chat (D3).

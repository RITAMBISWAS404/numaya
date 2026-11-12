# Fable design lab: experiments

Branch `experiment/numaya-fable-design-20261113-0048`, based on the replacement V8 (`c890d02`). Briefs: `NUMAYA_FABLE_FRONTEND_LAB_V2.zip` and `NUMAYA_FABLE_RESEARCH_SUPPLEMENT.zip`.

Every option is real Flutter, switchable in the Design Lab of a development build. **The app default is O (your selected baseline) in every group.** Recommendations are suggestions; nothing is applied until you export choices from the gallery.

## Foundations kept

- **Type and controls:** Plus Jakarta Sans headings, Figtree text, 15pt body; brand purple; Tabler icons; V7 radii; outlined secondary buttons.
- **Your r8 export, applied as defaults:** chat separators inset to the text, Help and Settings in the Profile bar, number-first credits, quiet outline buttons, V7 type, Compliments as conversations.
- **Still undecided:** `r8-photo-scrim`. It is shown again in the gallery with its earlier renders.
- **Excluded:** Events and Health stay off. No Follow UI exists in active screens: the only "follow" strings are guideline sentences and one deferred Events string.
- **Rules unchanged:** credits, streak, consent, reply-once, block and report.

## Groups

Options A and B each differ from O in at least two of: information order, grouping, action placement, emphasis.

| Group | O (baseline) | A | B | Recommended | Why |
|---|---|---|---|---|---|
| `fx-discover` | Name on photo; icon button for a Compliment; prompt card | **Essentials first:** bio, distance, intent and common ground as one block; a labelled Compliment button | **Photo-led:** pills and the Compliment button on the photo; purple Common ground card; two-column fact tiles | A | The deciding facts and the action are visible without scrolling, and less of the photo is covered. |
| `fx-profile` | Large cover; setup card; list groups; activity cards | **Compact hub:** identity row; Edit and Preview pair; two stat tiles; next step row | **Credit hero:** short cover; one dark feature card with labelled balances and one action; two quiet blocks. **C** is B in purple (a palette study). | B, provisional | One focal card with labelled balances. It is artwork-pending; if no art is commissioned, A is the finished option. |
| `fx-messages` | Time-sorted list with filters; a glyph marks a Compliment | **Whose turn:** two groups replace the filter row; a Compliment states its condition in words | **Context rows:** one list with filters; a Compliment row says what it was about and shows that photo | A | "Who needs a reply" becomes the structure of the list. It loses the Unread filter. |
| `fx-compliment-thread` | Sender photo, name, bubble with a small quote, reply field always open | **Compact context card:** no sender photo; your photo or own answer quoted; their words in reading size | **Decide first:** name on their photo; their words large; Dismiss and Reply as a pair; Reply opens the composer | B | Declining is as visible as replying, and it keeps the photo-led opening you chose in V7. A drops that opening, so it is opt-in. |
| `fx-wallet` | Purple balance card; bucket rows; action in the footer | **Number-led card:** large number with art; labelled buckets; action inside the card | **Credit hero and tiles:** dark feature card with the action; buckets as three tiles | A | Number, breakdown and action form one group, and it is finished. B is artwork-pending and moves bucket details one tap away. |
| `fx-streak` | Flame, count, seven bars, status | **Week strip:** large count; seven numbered days (checked, next ringed, reward on day 7); days remaining | **Next credit:** dark feature card leading with days to the next credit | A | Today and the reward are explicit, and it is finished. |

**Coherent candidate:** Discover A, Profile B, Messages A, Compliment B, Credits A, Streak A. That puts one dark feature card in the app (the Profile tab) and keeps the detail screens quiet.

## Shared pieces and compatibility

- **`FxHeroCard`** (`fx_profile.dart`) is shared by Profile B/C, Credits B and Streak B.
  - Copy zone on the left; a 136-wide art zone at the top right that rises 28 above the card; facts at full width; one action across the foot.
  - The art never takes touches. At large text it gives its room to the words.
  - Art brief: one subject, about 136 × 112, sitting on the slot's bottom edge, transparent background. The mascot used now is a stand-in.
- **Choosing Credits B or Streak B with Profile B** puts the same dark card on three screens. That is allowed, but the art should then differ per screen.
- **`fx-compliment-thread` A** conflicts in spirit with your V7 `v7-request` B (photo-led). Choose it only on purpose.
- **All other choices are local** to their screen and can be mixed.

## Code map

| Group | Variant switch | Widgets |
|---|---|---|
| `fx-discover` | `discover_screen.dart`, `person_profile.dart` | `lib/features/fable_lab/fx_discover.dart` |
| `fx-profile` | `profile_screen.dart` | `fx_profile.dart` (`FxIdentityRow`, `FxStatTiles`, `FxCreditHero`, `FxQuietPair`) |
| `fx-messages` | `messages_screens.dart` (`fx`), `ConversationRow` variants `FA`, `FB` | `conversation_row.dart` |
| `fx-compliment-thread` | `compliment_thread.dart` (`fx`) | `fx_thread.dart` (`FxComplimentCard`, `FxIntroduction`) |
| `fx-wallet` | `wallet_screen.dart` (`fx`) | `fx_wallet_streak.dart` (`FxWalletSidecar`, `FxBucketTiles`), `FxHeroCard` |
| `fx-streak` | `streak_screen.dart` (`fx`) | `fx_wallet_streak.dart` (`FxWeekStrip`), `FxHeroCard` |

**To apply a choice:** set that group's `proposed` in `lib/features/lab/lab_registry.dart`, then delete the unchosen branches and their widgets.

**To render:** `flutter test --tags comparison --run-skipped --update-goldens test/screenshots/fx_lab_capture_test.dart` (add `--dart-define=FX_SCALE=1.5` or `FX_WIDTH=360` for stress samples). Then `python tool/fable_lab/build_review.py --commit <sha> --out-gallery <dir> --out-shots <dir>`.

## Backlog (not built)

From the supplement's recipes, in priority order:
1. **Reply composer:** R1 one clipped quote-plus-input surface; R2 a separate quote inset.
2. **Sent confirmation:** S1 inline pending state; S2 one brief sheet on the first send.
3. **Sheet headers, alert cards, settings groups and button pairs.**
4. **Onboarding welcome composition, and the paywall feature comparison.**
5. **A short motion clip.** No motion was added or recorded in this run.

# Three-screen visual benchmark

Baseline: the V4 candidate (`269de9d`) in `Desktop\Numaya Phone Review - 2026-11-09`. Rendered on the Pixel 10 AVD at 1080 x 2424, font scale 1.0.

## 1. Discover and profile first photo
- **User task:** decide whether this person is interesting. **Primary action:** swipe. Compliment is secondary.
- **Needed now:** face, name and age, verification, job. **Deferred:** prompts, details, further photos.
- **Grouping:** identity is one block at the foot of the photo. Metadata pills stay above it.
- **Evidence:** Bumble (`mobbin.com/screens/53f019f0-38d7-42ff-b365-e0a6d33afa81`, `e45ff2bc-3230-49f0-988e-b2369438bbad`) sets the name straight on the image. Ente Memory card `6352:38350` uses a bottom gradient.
- **Chosen hierarchy:** an eased gradient with no backing, 24% at the lower edge and fading to zero with no visible stop. White type has a tight and a wide shadow. The job glyph is dropped because it added noise on the image.
- **Why:** the owner asked for no dark name rectangle. Roughly 76% of the lower photo's brightness stays, and the image remains the subject.
- **Readability exception, recorded:** on a pure white patch a 24% scrim alone gives white text about 1.9:1. The shadows carry it. Checked at full size on Léa and Alex (bright pink and pale wall), Inés (busy printed menu) and Maya (mid-tone wood), all legible. A strict contrast check would still fail on the brightest patches, so the compact glass label (`v4-photo-label` P, 4.74:1 worst case) stays in the gallery as the owner's alternative.

## 2. Compliment composer and received item
- **User task:** say one specific thing about one photo or prompt. **Primary action:** Send.
- **Needed now:** who, what it refers to, the field, the count, the credit cost. **Deferred:** the one-per-person rule moves to the sent state.
- **Evidence:** Bumble composer `mobbin.com/screens/1c4a9679-bac7-4772-b06b-d44e72ab1ca9` uses a compact context row with the thumbnail at the end, the field, a counter and credits. Sent state `b15493f3-1516-46b8-9c60-d86be2cce234` says what happens next. Viewed screens were limited to the composer, sent state and photo entry.
- **Chosen hierarchy:** one compact white context row, then a text area that takes the focus, then one line for credit and consequence, with Send anchored above the keyboard. The received item puts the sender's words first, with the context beneath in the same card.
- **Differences from Bumble:** full screen rather than a sheet, because the approved route is a page. A reply opens the chat. The received item was not found on Mobbin, so it is an original Numaya composition.

Corrections made from the first render: the sent state was plain text, so it gained a solid purple check to show what happened.

## 3. Profile and Settings grouping
- **User task:** find one setting. **Primary action:** depends on the row.
- **Evidence:** Ente Updated screens Settings `12099:96480` and Menu Item `2513:51496`. Library variables `spacing/xs 4, sm 8, md 12, lg 16` and `radius/md 12, xl 20`.
- **Spacing roles (proximity, each level clearly larger than the one inside it):** 4 label to value, 8 icon to label and within a group, 12 heading to its content, 16 card inset and page gutter, 32 between sections. This replaces a 24 section gap that sat too close to the 12 and 16 inside it.
- **Numaya differs from Ente on purpose:** Ente separates its Settings groups by only 8, relying on card edges alone. The owner asked for larger section separation.
- **Icons:** supporting icons move from #8A8A8A to #666666 (5.74:1 on white), matching Ente's `text/light` and removing the pale-icon problem.

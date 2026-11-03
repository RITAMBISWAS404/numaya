# Numaya final UX polish

**Branch:** `experiment/numaya-final-ux-polish`, from `experiment/numaya-monochrome-premium-refinement`
at `e70135c`. The baseline branch is unchanged.

**Scope:** the Flutter app (`apps/numaya_mobile/`) only. The web prototype is untouched.

This pass refines the approved Monochrome Premium design; it is not a redesign. Kept unchanged:
- the cool grey page and white surfaces;
- `#7262C7` purple for actions;
- Plus Jakarta Sans over Figtree;
- the role radius scale;
- the floating icon-only tab pill;
- filled controls and no gradients.

## What changed
1. **Semantic accent tones** (FP-01):
   - Blue, green, amber, coral and red, in contrast-safe tint/foreground pairs.
   - Used only in icon tiles and status marks. Purple is still the only action colour.
   - Tokens: `info`, `infoSubtle`, `social`, `socialSubtle`, `divider` in `monochrome_tokens.dart`;
     `AccentTone` in `widgets/icon_tile.dart`.
2. **Icon tiles** (FP-03, FP-11): `ListRow.leading` now renders a 40pt rounded-square `IconTile`.
   Applied across:
   - Settings, every row;
   - Help, Safety and Profile › Safety & support;
   - event metadata;
   - Account Health;
   - filters, Premium and onboarding location.
   - The Profile tiles and Premium card use the 48pt size.
3. **Grouped lists** (FP-02): quiet hairlines between rows, inset to the text, never through the
   tile.
4. **Account Health status** (FP-04): each row's tile shows done (green check), missing (amber) or
   pending (blue). The value text says the same in words.
5. **Discover swipes** (FP-08, FP-09):
   - The decision now shows on the photo as you drag: a check with "Like", or a cross with "Pass".
   - A system pointer cancel no longer commits a swipe (a real bug, found by the new tests).
   - A firm fling back toward the centre cancels.
   - A person can never be decided twice.
6. **Match** (FP-05): one large square photo of the matched person with a purple heart mark. Your
   own avatar and the scalloped composition are gone.
7. **Nested corners** (FP-06, FP-07): `AppRadii.nested(outer, inset)`.
   - The tab indicator is a concentric circle.
   - The RSVP bar's corner is 40.
   - The Discover photo was already correct.
8. **Copy that wrapped** (FP-12), rewritten:
   - Snooze;
   - Profile & visibility;
   - Your area;
   - the Likes card caption, which now keeps "4 km" together.
9. **Illustration slots:** named ratios (`IllustrationSlot.header` 16:9, `.empty` 4:3), and a
   mascot plan in [ILLUSTRATION_ASSET_BACKLOG.md](ILLUSTRATION_ASSET_BACKLOG.md).

## Documents
| File | Contents |
|---|---|
| [DECISIONS.md](DECISIONS.md) | FP-01 to FP-14 |
| [VISUAL_REVIEW_REPORT.md](VISUAL_REVIEW_REPORT.md) | Scores, evidence, tests run, known issues |
| [ILLUSTRATION_ASSET_BACKLOG.md](ILLUSTRATION_ASSET_BACKLOG.md) | Every slot, its ratio and the mascot's purpose there |
| [evidence/](evidence/) | Before/after sheets (both sides rendered on the same Windows machine), plus device screenshots |

**Updated guidelines in the premium folder:**
- [TOKENS.md](../monochrome-meetup-premium/TOKENS.md): semantic colours, tile radii, contrast rows;
- [COMPONENT_RULES.md](../monochrome-meetup-premium/COMPONENT_RULES.md): `IconTile`, `ListRow`,
  dividers, list patterns;
- [LAYOUT_GUIDELINES.md](../monochrome-meetup-premium/LAYOUT_GUIDELINES.md): geometry and spacing
  rules;
- [NAVIGATION_SPEC.md](../monochrome-meetup-premium/NAVIGATION_SPEC.md): indicator radius.

## References used (Mobbin)
- **Bumble:**
  - [swipe with check on the photo](https://mobbin.com/screens/83e93b49-e15d-462c-ae89-810a4613cea0);
  - [discover card](https://mobbin.com/screens/ee54d57a-33f7-4f05-ba27-012f9f74eb48);
  - [match](https://mobbin.com/screens/d0a3d260-6611-46c0-9eb0-5de2f7f8fdbd);
  - [profile editor icon rows](https://mobbin.com/screens/fc35bf13-823e-4331-a922-4882f5d67e7a).
- **Feeld:** [single-photo match](https://mobbin.com/screens/50025de4-1b77-4439-923f-556430ffd76c).
- **Alan:** [mascot on the dashboard and in explanatory cards](https://mobbin.com/screens/fc70fe25-5fdc-4ab8-8c99-416546c33a23).
- **Meetup, Jomo and Bevel:** the earlier research in `../monochrome-meetup/REFERENCE_AUDIT.md`
  still applies.

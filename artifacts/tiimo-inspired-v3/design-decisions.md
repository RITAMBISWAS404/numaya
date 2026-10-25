# Design decisions: Tiimo-inspired V3

Every change is scoped to `.theme-tiimo`, in `src/design-system/styles/theme-tiimo.css`, and to
tokens in `tokens/numaya.tokens.json`. No shared component, approved style or approved token
changed.

## 1. Geometry: a shape for each size class, not one radius

**Problem.** In V2 almost every control was a capsule: chips, buttons, tags, the tab bar, the
Pass/Like buttons and the photo badges. Next to 16–24px cards, the screen read as a pile of
capsules.

**Decision.** There are three control corners, plus the two existing card corners:

| Token | Value | Why this value |
|---|---|---|
| `tiimo.radius-item` (existing) | 16 | Buttons are 54px tall. At 16 the corner is about 30% of the height: flat sides, still soft. It matches the option cards and fields, so a form reads as one family. |
| `tiimo.radius-control` (new) | 12 | Chips are 36px tall. 12 is a third of the height, the same proportion as the buttons, so chips look like small buttons rather than lozenges. |
| `tiimo.radius-tag` (new) | 8 | Tags are 22–24px tall. At 8 they are clearly rectangles; anything larger turns them back into pills. |
| `tiimo.radius-feature` (existing) | 24 | Feature cards and the floating tab bar (64px). Its items use 16: an outer 24 less the 6px inset gives about 18. |

**Exceptions, on purpose:**
- **Circles:** avatars, icon buttons (back, close, filters, more), the FAB and the send button.
  These are single icons, and a circle reads as "one tap".
- **Pills:** progress bars, switches, slider tracks and count badges. Their pill shape is part of
  what they are.
- **Bubbles, cards and sheets:** they keep their own shapes.

**Rejected:** one global radius override. It would have squared avatars and icon buttons, and
turned progress bars into blocks.

## 2. Photo fade: the one gradient

**Rule.** Black, bottom to top, only on the overlay that holds text on a real photograph. It is
implemented on the existing overlay layer (`.profile-card__overlay`), which already sizes itself to
the name block and sits inside the clipped photo container. That means it:
- fades over the overlay's own height, with the clear 136px top padding first;
- respects the photo's 32px corners;
- appears only where text sits over the photo.

**Stops.** The opacities follow an ease-out curve so the fade has no visible start line: 72% → 59%
→ 32% → 10% → 0, at 0 / 30 / 58 / 82 / 100% of the overlay height. The detail line sits around
65% opacity and the name around 55%.
- Over a pure-white photo that gives 6.90:1 for the detail line and 4.81:1 for the name.
- Over any darker photo the contrast is higher.

**Placeholders.** With no photo there is no gradient: the brief rules out decorating a grey
placeholder. White text on the light placeholder still needs a dark backing, so the name block
keeps V2's solid translucent ink band. The two cases are selected with `:has(.profile-card__img)`.

**Colour.** Pure black (new primitive `alpha.black-72`, semantic `color.tiimo.photo-fade`). The
approved scrim uses the brand ink, which has a faint cool cast; black keeps a photo's own colours.

## 3. Match: two portraits

- **Their photo is a circle.** The shared `OrganicPortrait` masks the photo with an inline scallop.
  Its narrowest radius is 43.5% of the box, so `clip-path: circle(43%)` gives an exact circle
  without editing the component. The lavender halo (`organic-portrait__backdrop`) is hidden.
- **Your avatar sits on the edge.** Its centre is placed at 95% of their circle's radius at 45°
  lower-left: `left` and `bottom` are `calc(21% - size / 2)`, where
  21% = 50% − 0.95 × 43% × 0.707. That gives a clear overlap at every size, without covering the
  middle of their photo, where a face would be.
- **Your avatar scales with their portrait.** It is 64px normally. On phones up to 700px tall it is
  7.5svh (50px at 667), mirroring the portrait's own short-phone rule.
- **Removed:** the confetti dots and the halo.
- **Kept:** the white ring on your avatar, which separates the two faces where they overlap. The
  heading, the copy, the shared interests, the illustration and the composer are unchanged.

## 4. Colour: headings are neutral

| Element | V2 | V3 | Reason |
|---|---|---|---|
| Interest set label | Coloured uppercase capsule (peach / lilac / mint text on its tint) | Neutral ink, sentence case; the tint sits in a 24px holder behind the emoji | It is a heading. The category still shows through the holder and the selected chips. |
| Prompt question ("A perfect first date") | Brand-deep purple | Neutral secondary, like the other section titles | The lavender tile already marks the prompt; purple text added nothing. |
| Selected interest | Category tint and ink, with ring and minus | Unchanged | It is a state, and the category is meaningful. |
| Shared interests, activity category tags | Category tint and ink | Unchanged | The colour is the category. |
| "Live now", "You're going", "Full", "Your move", "New" | Semantic tints | Unchanged | States. |
| Primary actions, selection, your messages | Brand purple | Unchanged | Brand and action colour. |

A runtime audit of the eight screens lists every visible text element whose colour has a hue. After
V3 it finds only category chips, category tags and state tags.

## Tokens

| Token | Value | New |
|---|---|---|
| `primitive.color.alpha.black-72` | `rgb(0 0 0 / 0.72)` | yes |
| `color.tiimo.photo-fade` | `{alpha.black-72}` | yes |
| `component.tiimo.radius-control` | 12px | yes |
| `component.tiimo.radius-tag` | 8px | yes |

There are 306 tokens in total (V2 had 302). All V2 tokens are unchanged.

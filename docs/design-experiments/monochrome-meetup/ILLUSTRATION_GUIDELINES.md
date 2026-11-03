# Illustration guidelines

## When a slot belongs
Add an illustration only where it carries the moment:
- an empty or "gone" state;
- an editorial header that introduces a topic (safety, premium, Opening Moves);
- a celebration.

Typography and whitespace are preferred everywhere else. Do not put illustrations in lists, forms or
settings.

**Existing illustrations stay:**
- the SVGs in `assets/illustrations/mobile/` (Messages, Events and Discover empty states, onboarding
  headers, the verification phone);
- the `IllustrationView` widget.

Slots are only for places that had **no** art.

## The slot component
`IllustrationSlot(slot:, label:, aspectRatio:, width:, asset:)` in
`widgets/illustration_slot.dart`.

| Parameter | Meaning |
|---|---|
| `slot` | stable code name, used in the backlog and as the widget key `illustration-slot-<slot>` |
| `label` | what the art should show; rendered as "Illustration: <label>" until the asset arrives |
| `aspectRatio` | width ÷ height, fixed: the final asset must match it so nothing moves |
| `asset` | an SVG path; when set, the placeholder is replaced by `SvgPicture` with `BoxFit.contain` |

**Accessibility:** always decorative (`ExcludeSemantics`). The surrounding copy carries the meaning.

**Placeholder look:**
- fill grey with a dashed `lineStrong` edge and a 20pt corner;
- a muted image glyph and caption;
- monochrome, so it never competes with real content.

## Art direction for the final assets
| Rule | Detail |
|---|---|
| Palette | monochrome line or flat shapes in ink and greys, with **one** purple accent (`#7262C7`) per drawing |
| Forbidden | gradients, drop shadows, photographic textures |
| Background | none: transparent, sitting on the slot's surface |
| Stroke | about 2pt at 1× for line work; rounded joins, to match Figtree's terminals |
| Mood | warm, human, calm. People and objects at small scale; no mascots. |
| Format | SVG, `viewBox` matching the slot ratio (16:9 headers, 4:3 empty states) |

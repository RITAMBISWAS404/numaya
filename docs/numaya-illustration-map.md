# Numaya illustration map

Reserved slots for artwork supplied separately. Each slot is an `IllustrationPlaceholder`
(`src/design-system/components/Content.jsx`) with a stable `id`; pass `src` (or `artSrc` on
`EmptyState`) to drop the artwork in without any layout change. Slots are decorative (`aria-hidden`
/ empty `alt`): the surrounding text carries the meaning.

Placeholders are a quiet `surface.sunken` block with the card corner (24px; 20px for spot slots), no
border, shadow or pink. Profile **photo** placeholders (Discover card, photo grid, profile strip, match
photos) are a different thing and are never illustration slots.

**Art direction for all slots:** Numaya pink `#F770E3` as the single accent (never a darker pink),
ink and warm neutrals otherwise; simple, friendly line-and-shape style with Fraunces-like softness;
transparent background; people abstract (no realistic faces), inclusive and ungendered.

| Slot id | Screen / component | Size | Placement | Concept and purpose | Type |
| --- | --- | --- | --- | --- | --- |
| `welcome-hero` | Prototype › Welcome (`Welcome.jsx`) | Square, up to 320 × 320; shrinks with the hero's free height | The whole upper hero, above the headline panel. **Reserved and invisible** (`IllustrationPlaceholder reserved`): no logo, grey box or ribbon is drawn until the multi-illustration composition is supplied | Two people, abstract, meeting over a conversation (a shared speech bubble or prompt card between them): Numaya is built around conversation, not swipes | Hero |
| `verified-success` | Prototype › Verify code › success sheet (`VerifyCode.jsx`) | 200 × 120 (5:3) | Centred at the top of the sheet, above the existing check badge and "You're verified" | Two abstract figures waving across a phone-shaped arch: "you're in, someone's on the other side". The moment the user stops filling forms and joins people | Success |
| `basics-spot` | Flows › The basics (`Basics`, `ScreenHeader art`) | 72 × 72 (1:1) | Right of the two-line title, top-aligned; fields untouched | A name tag or "hello" speech bubble: introducing yourself, light and friendly | Decorative |
| `interests-spot` | Flows › Interests and prompts (`InterestsPrompts`) | 72 × 72 (1:1) | Right of the title, top-aligned; chips and prompt untouched | A small cluster of things people love (record, wine glass, climbing hold) bumping together: interests as conversation starters | Decorative |
| `discover-seen-everyone` | Flows › Discover › "You've seen everyone for now" | 160 × 128 (5:4) | Above the title, replacing the icon | An open door or horizon with a few faint new silhouettes arriving: possibility, more people tomorrow | Empty state |
| `discover-paused` | Flows › Discover › "Discover is paused" (snooze) | 160 × 128 (5:4) | Above the title, replacing the icon | A figure resting in a hammock or a "do not disturb" moon: a calm, guilt-free break | Empty state |
| `match-empty` | Flows › It's a match › "No new match yet" | 160 × 128 (5:4) | Above the title | Two paper planes or hearts on curving paths that haven't met yet: anticipation, a match on its way | Empty state |
| `chats-empty` | Flows › Chats › "Connections start here" | 160 × 128 (5:4) | Above the title | A speech bubble waiting for a reply, or a path leading to two benches: where conversations begin | Empty state |

## Intentionally without a slot

- **Verified → profile setup** (flows intro): tried and removed. A slot pushed the setup progress
  below the fold at 375px; the success badge and the `SetupProgress` card (done / next / upcoming,
  filled icons) already tell the story. The celebration lives on the prototype's success sheet.
- **Match**: the two photos and the heart mark are the artwork; the ribbon fills the whitespace below.
- **Photos**: the photo grid is the content; artwork would compete with it.
- **Phone number / verify code screens**: the keypad leaves no free space.
- **"No one fits your filters"**: keeps its filter icon, which is functional (it names the cause).
- **Ended conversation (blocked / unmatched)**: a safety outcome; kept calm and text-led.
- **Profile empty interests**: a one-line caption is enough.

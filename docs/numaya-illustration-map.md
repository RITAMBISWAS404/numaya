# Numaya illustration map

Numaya's illustrations are original SVG scenes drawn for the product (no third-party artwork),
rendered by one component: `Illustration` (`src/design-system/components/Illustration.jsx`).
Components take them optionally: `ResultPanel art`, `EmptyState art` and `ScreenHeader art`.
Every scene is decorative (`aria-hidden`); the title and copy beside it carry the meaning.

> **Asset catalog:** every illustration slot, its future PNG and its exact placement on annotated
> screenshots lives in [`illustrations/index.html`](illustrations/index.html) (manifest:
> [`illustrations/illustration-manifest.json`](illustrations/illustration-manifest.json)). Screens
> use slots by id through `IllustrationSlot` (`src/design-system/illustrations/registry.js`); the SVG
> scenes below are the slots' fallbacks until the PNGs are supplied.

## Style

- **One composition per scene.** Never a badge or tick stacked on a blob; a check, when there is
  one, is part of the drawing (the message on the verified phone).
- **Canvas:** 160 × 120 for outcome and empty-state scenes; 80 × 80 for the two header spots.
  Rendered at 160 (128 compact) and 72 px wide.
- **Colour by role, through tokens** (`.ill__*` classes in `content.css`, so the scenes follow the
  palette): 2.5px ink outlines (`text.primary`), white paper, a soft ground shadow, grey bars for
  text. Brand purple at most once per scene, and only where the moment is positive (verified, the
  basics name tag, a match on its way). Meetup's periwinkle and yellow appear only as one small
  framing mark or sparkle.
- **Safety outcomes stay neutral:** unmatched and blocked use greys only, with no purple, sparkle
  or check, so ending a conversation never reads as a success.
- No people with faces, no gradients, no shadows beyond the flat ground ellipse.

## Scenes

| Scene | Where | Concept |
| --- | --- | --- |
| `verified` | Verify code success sheet (`VerifyCode.jsx`), Verified → profile setup (`SetupIntro`, compact) | A phone whose code message arrived with a check: verification done |
| `unmatched` | Chat ended: unmatched | Two conversations drifting apart (neutral) |
| `blocked` | Chat ended: blocked and reported | A shield carrying a report flag (neutral) |
| `seen-everyone` | Discover: "You've seen everyone for now" | A small fanned stack of profile cards, the front one still to come |
| `paused` | Discover: "Discover is paused" (snooze) | A crescent moon and a quiet "z": a guilt-free break |
| `no-match` | It's a match: "No new match yet" | Two paper planes on curving paths, heading towards each other |
| `no-chats` | Chats: "Connections start here" | A conversation waiting for its first message (typing dots) |
| `hello` | The basics (header spot) | A "hello" name tag: introducing yourself |
| `interests` | Interests and prompts (header spot) | A record and a small peak: things people love |

Supplied artwork can replace an empty-state scene without a layout change: `EmptyState artSrc`.

## Intentionally without a scene

- **Welcome hero** (`welcome-hero`): a reserved, invisible `IllustrationPlaceholder` by product
  decision until the multi-illustration composition is supplied. The wash and the headline panel
  carry the screen.
- **Match**: the two photos and the heart mark are the artwork. The heart on a white disc that
  bridges the photos is the one icon-on-disc kept on purpose: it sits on photography and needs the
  disc to stay legible.
- **Photos**: the photo grid is the content. Photo placeholders are never illustration slots.
- **Phone number / verify code screens**: the keypad leaves no free space.
- **"No one fits your filters"**: keeps its plain filter glyph, which names the cause.
- **Danger results** ("We couldn't verify you") and the location primer: a plain filled glyph in the
  tone's colour, no disc.

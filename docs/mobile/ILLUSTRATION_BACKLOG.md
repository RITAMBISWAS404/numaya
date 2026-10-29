# Illustration backlog

Where an illustration helps someone understand a moment or makes it warmer. Each entry has a slot
in the code that works with or without final art.

**How illustrations work in the app:**
- Spot illustrations are `NumayaIllustration` values drawn by `IllustrationView`. They are decorative:
  the copy beside them carries the meaning, and screen readers skip them.
- Canvas: 160 × 120 (4:3), or 1:1 for `hello` and `interests`. Usually shown at 128–160 pt wide.
- **Style:**
  - 2.5 px ink (`#121212`) strokes, round caps;
  - white fills;
  - one accent-blue (`#5066CC`) shape;
  - one warm-yellow (`#FCD284`) detail;
  - dotted grey (`#8A8784`) motion paths;
  - no gradients, no people, no text.
- **Sources:**
  - `assets/illustrations/*.svg` is exported from the web design system (`tool/export_assets.mjs`). Don't
    edit those files.
  - `assets/illustrations/mobile/*.svg` holds mobile-only scenes drawn by hand in the same style. Move a
    scene to the web set before the web uses it.

**Generation:** no illustration-generation tool was used. The three mobile scenes below are simple
original vectors written by hand, to be replaced or refined by a designer.

## In place

| Asset | Where | Purpose |
|---|---|---|
| `no-match` | Likes empty | Nobody yet |
| `seen-everyone` | Discover: seen everyone, nobody fits filters; For you empty | End of the deck |
| `paused` | Discover while snoozed | Hidden on purpose |
| `no-chats` | Messages empty | Conversations start here |
| `unmatched`, `blocked` | Ended conversation | What happened |
| `verified` | Photo verification, sign-up done | Trust |
| `hello` | Welcome back, intro step | Greeting |
| `interests` | Interests step | Picking what you like |
| **`mobile/no-events`** (new) | Events: no results; My events: Waitlist, Saved, Hosting, Past empty | Nothing here yet, go and look |
| **`mobile/event-going`** (new) | My events: Going empty | Something to go to |
| **`mobile/not-enough-data`** (new) | Profile & visibility: "Not enough activity yet" | Counts appear once there is activity; no judgement |

## Proposed (slot exists, art not drawn)

| # | Moment | Location | Size | Brief | Why it isn't done |
|---|---|---|---|---|---|
| IL-1 | Event cancelled | Event detail, cancelled banner (`event_detail_screen.dart`) | 128 × 96 | A calendar page with a soft fold or a crossed corner. Calm, not alarming | The banner already explains it; art is optional. Wait for a designer |
| IL-2 | Your event is live | Event detail with `?published=1` | 160 × 120 | The event-going calendar with a small flag or spark | Reuse `event-going` once a designer approves it |
| IL-3 | Profile complete (100%) | Profile › completion card at 100%, completion hub | 96 × 72 | A finished profile card with a check | The card's check icon is enough at this size |
| IL-4 | Recovery email saved | Settings sheet | — | Not recommended: a toast is enough | — |
| IL-5 | Chat: no photos on the device | Attachment picker returns nothing | — | Not recommended: the system picker shows its own empty state | — |
| IL-6 | Offline | Connection banner | — | Not recommended: a banner must stay compact | — |
| IL-7 | Onboarding: location primer | `/setup/location` | 160 × 120 | A map pin over a neighbourhood outline, no real map | Needs a designer; the step works without it |
| IL-8 | Onboarding: notifications primer | `/setup/notifications` | 160 × 120 | A phone with one soft notification card | Same |

## Rules

- **Don't decorate blank space.** An illustration must explain a state, mark an ending, or make a
  pause friendlier.
- **No illustration in a toast, banner, sheet header or list row.**
- **Keep the copy complete without the art.** Screens must read correctly with `IllustrationView` removed.

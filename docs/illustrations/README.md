# Numaya illustration catalog

Open **[index.html](index.html)** in a browser (it works offline). It shows every place a Numaya
illustration belongs, on screenshots of the real app with the area outlined and numbered, and gives
each future PNG its exact file name, purpose, art direction, palette, size and export settings.

| File | What it is |
| --- | --- |
| [index.html](index.html) | The visual catalog (generated) |
| [illustration-manifest.json](illustration-manifest.json) | Machine-readable inventory: one entry per PNG, with its placements |
| [asset-guidelines.md](asset-guidelines.md) | Naming, export, transparency and consistency rules |
| `screenshots/` | Annotated full screens (`NN-id[-n].png`) and close-ups (`…-crop.png`) |

## At a glance

- **14 PNG assets, 18 placements.** Assets are reused where the meaning is the same (one file for
  verification success and the profile-setup intro, one for "no likes" and "no match yet", one
  for block and report outcomes, one for the activity empty states).
- **P0 (1):** `numaya-match-hands-heart.png`, the Match screen's two hands forming a heart.
- **P1 (8):** welcome hero, verification success, empty conversations, empty likes, empty
  activities, Home caught up, unmatch outcome, safety confirmation.
- **P2 (5):** Home paused, activity published, maintenance, the two profile-creation spots.
- **Not illustrations:** profile photos (the Match portrait is the person's real photo), navigation
  and utility icons, the readiness meter and progress bars, photo placeholders.

## Supplying an asset

1. Export the PNG at the **@3x** size listed for it (see the catalog), transparent unless stated.
2. Name it exactly as listed, e.g. `numaya-match-hands-heart.png`.
3. Put it in `src/assets/illustrations/`.
4. Run the app or `npm run build`. The slot picks it up automatically (Vite `import.meta.glob`) and
   shows it instead of its fallback, at the same size and position.

Nothing else changes: screens ask for slots by id (`IllustrationSlot id="match-hands-heart"`,
`EmptyState art="empty-likes"`, `ResultPanel art="safety-confirmation"`), and the file names live
in one place, `src/design-system/illustrations/registry.js`. A missing file is simply absent: no
broken image and no build error.

## Fallbacks until the art arrives

| Fallback | Used by |
| --- | --- |
| Original SVG scene (`Illustration`) | verification success, empty conversations, empty likes, Home caught up, unmatch, safety, Home paused, the two spots |
| Joining purple heart (`MatchHeart`) | match hands heart |
| Plain glyph, no reserved box | empty activities, activity published, maintenance |
| Reserved, nothing drawn | welcome hero |

## Updating the catalog

Edit `illustration-manifest.json` (and the registry when an id or file changes), then run
`npm run illustrations`. The script checks that every manifest entry exists in the registry,
drives each placement in Chromium at 393 × 852, saves annotated screenshots and rewrites
`index.html`.

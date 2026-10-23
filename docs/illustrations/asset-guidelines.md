# Illustration asset guidelines

## Naming

- `numaya-<purpose>.png`, lowercase kebab-case, one canonical name per asset (listed in the
  manifest and the registry). No version suffixes (`-new`, `-final`, `-v2`): replace the file.
- The registry id is the name without the prefix and extension where possible
  (`numaya-empty-likes.png` → `empty-likes`).

## Size and export

- Each asset has its own aspect ratio, taken from the space it fills:
  - **5:2 wide** for the Match hands (a horizontal band under the copy);
  - **4:3** for empty states and outcomes (160 × 120 on screen, 128 × 96 compact);
  - **1:1** for the welcome hero (up to 320 × 320) and the 72 × 72 form spots.
- Deliver **@3x** (for example 960 × 384 for the hands, 480 × 360 for 4:3 scenes, 960 × 960 for the
  hero, 216 × 216 for spots). The app scales down; @1x and @2x sizes are listed for reference.
- sRGB colour profile, 8-bit PNG with alpha. Keep files under about 400 KB (hero under 800 KB).

## Background and edges

- **Transparent** by default: scenes sit on white pages, the lavender welcome wash and white sheets.
- Respect the safe margin listed per asset (about 10% for 4:3 scenes, 6% for spots, 8% for the
  hero). The Match hands may bleed off the left and right edges.
- Shadows: only a flat ground shadow drawn into the artwork where noted. The UI adds no shadow or
  frame around illustrations.

## Style

- One family: friendly, simplified shapes; near-black outlines (#141316); white paper fills.
- Purple #7262C7 is the one strong accent, used once or twice per scene; lavender #F3F0FD and
  #E9E4FB for soft fills. Meetup's periwinkle, yellow and rose only as small marks.
- Safety and ending outcomes (unmatch, block, report) stay **neutral**: greys and ink, no purple,
  no sparkles or celebration.
- People are abstract and inclusive: simplified faces, varied skin tones, no gendered clichés.
- **No text** inside illustrations. Headings, labels and buttons stay live text in the UI.
- Must read at its smallest rendered size (72px for spots, 96px tall for compact outcomes).

## Source files and animation

- Keep layered source files (Figma, Illustrator or Procreate) with each moving part on its own
  layer, named by part.
- The Match hands are planned to animate (hands slide in and meet): keep each hand, sleeve and
  accessory on separate layers so they can be exported as separate PNGs or as Lottie later.
- All other assets are stills; an optional subtle loop is noted where it would help.

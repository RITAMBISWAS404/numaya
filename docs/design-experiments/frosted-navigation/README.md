# Frosted navigation experiment

**Branch:** `experiment/numaya-frosted-navigation`, in its own worktree at
`C:\Users\biswa\Downloads\numaya\numaya-frosted-navigation`, from `eb0b37b`
(`experiment/numaya-final-ux-polish`). **Uncommitted**, awaiting the owner's decision.

**Scope:** the Flutter app only; the web prototype is untouched.

## Objective
- Polish typography and compact layout where the running app shows a real problem (stage B).
- Separately, prototype a frosted bottom navigation and judge whether it earns a place (stage C).

## Baseline (A) and method
- **Device:** Pixel 10 emulator, Android 16 (API 36), x86_64, 1080×2424, software GPU
  (`-gpu swiftshader_indirect`).
- **Widths:** 390dp (`wm density 443`) and 320dp (`wm density 540`).
- **Conditions:** font scale 1.0; light theme (the app is light only); deterministic demo data
  via Demo Hub › Quick start.
- **Journey:** one script replays the same steps for A, B and C: Discover, the profile scrolled in
  two steps, Likes, Messages, Chat, Events, Profile (scrolled) and Filters. The screenshots are in
  `artifacts/frosted-navigation-experiment/{A-baseline,B-refined,C-frosted}/{390dp,320dp}/`.

## Findings
| Finding | Evidence | Impact | Source | Treatment |
|---|---|---|---|---|
| Discover's wordmark runs under Filters at 320dp | A/320dp `01-discover` ("numay") | The brand looks broken on small phones | `discover_screen.dart`: the centred `Wordmark` had no width limit | B: `Wordmark(maxWidth:)` shows the mark alone when the word does not fit |
| Profile-fact chips truncate the user's own data | A/320dp `03` "Undergraduate degr…" | Dynamic content cut off | `InfoChip`: fixed height, ellipsis, and the **card heading** style (Plus Jakarta Sans 18/24 bold) | B: shared `AppTypography.chip` (Figtree 14/18 medium, ink); chips grow instead of truncating |
| Three chip type sizes | `InfoChip` 18 bold display; Profile `_StaticChip` hard-coded 15; `NumayaChip` 14 | Inconsistent hierarchy | as above | B: one chip role, 14/18 |
| Bottom bar on an opaque page strip; content stops above it | A, every tab | Navigation and content read as separate slabs | `NumayaTabBar` `ColoredBox(canvas)`; shell not extended | C: frosted pill, `extendBody`, content scrolls beneath |
| Unselected tab icons would be too faint on glass | composite maths, then measured on the render | muted `#696972` drops to 3.38:1 over a dark photo | `NumayaTabBar` idle colour | C: idle icons `text2` (#4A4A53) on glass, 5.46:1 or better |
| With glass, content ran behind Android's own three buttons | C device check (shot `05` before the fix) | System controls unreadable over photos | content extended under the system inset | C: a 95% page-colour strip under the system inset only |

Typography was otherwise healthy: about a dozen hard-coded sizes app-wide, most of them
deliberate (avatar initials).

## Mobbin research (live connector; links are Mobbin's)
| App | Platform | Screen | Pattern | Numaya adaptation |
|---|---|---|---|---|
| [Tinder](https://mobbin.com/screens/e2532228-cd02-4d77-9356-e4de2777302d) | iOS | Discover | Floating translucent pill; the selected tab is a lighter fill inside it; the photo runs beneath | Kept the pill and an inner selected fill (the existing concentric tint circle) |
| [Coffee Meets Bagel](https://mobbin.com/screens/7b7a245c-fd59-4aa2-9f7a-1ca7de589496) | iOS | Suggested | Translucent bar with content blurred beneath; selection shown by colour and label | Content blurred beneath; selection by shape, filled icon and colour (icon-only bar kept) |
| [Hinge](https://mobbin.com/screens/3af8068d-0ef7-49b1-83ce-2029094a6601) | iOS | Discover | Solid dark icon-only bar; content stops above | The counter-example: the opaque fallback |
| [Hinge](https://mobbin.com/screens/fbcdd966-6613-4e8e-89e0-d0947fbc4760) | iOS | Profile | Small regular-weight icon fact chips | Fact chips moved to a quiet 14pt body role |
| [Yubo](https://mobbin.com/screens/a59f7025-036f-42db-90ad-ee08b56e5bd4) | iOS | Swipe | Plain white bar | n/a |

**Not found:** Mobbin's iOS results returned no Android examples for this pattern; Android was
judged on the emulator.

## Typography and spacing (stage B)
| Role | Before | After |
|---|---|---|
| Content chips (`InfoChip`, Profile chips) | 18/24 Plus Jakarta Sans bold (`card`), or 15 Figtree medium | **`AppTypography.chip`**: Figtree 14/18 medium (height 1.286), ink |
| Chip box | fixed 36pt, ellipsis | min 36pt, 4pt vertical padding, wraps at large text |
| Body, headings, screen titles | 16/24 body, 21/28 section, 32/38 page title | **Unchanged** (see below) |

**Why the brief's 14pt body default was not applied:** the existing scale is coherent and
consistent (16/24 body for profile prose, 14/20 `bodySm`, 13/18 caption). Shrinking all body text to
14 would hurt readability in profiles and chat, and the running app showed no evidence of a body
size problem. The evidence was in the chips, so only the chips changed.

**Spacing:** no token changes. The one compact-layout defect was the unbounded wordmark. (The header
action-gap fix from the previous task is on `experiment/numaya-first-ui-improvement`, not here.)

## Palette and contrast
Computed with WCAG 2.x relative luminance (Python), and cross-checked by measuring rendered pixels
in `goldens/fn01-glass-backgrounds.png`.

| Role | Token | Foreground / background | Ratio | Result |
|---|---|---|---:|---|
| Primary action label | `onBrand` on `brand` | #FFFFFF / #7262C7 | 4.90 | pass (AA text) |
| Brand fill as text | `brand` on `#F5F3FA` | #7262C7 / #F5F3FA | 4.45 | fail for text, so brand is never used as text |
| Purple text (existing) | `brandText` | #5B4BB0 / #F5F3FA | **6.20** | pass |
| Purple text on white | `brandText` | #5B4BB0 / #FFFFFF | 6.82 | pass |
| Trial purple (not adopted) | — | #6553B7 / #F5F3FA | 5.49 | pass, but weaker than `brandText` |
| Selected tab icon | `brandText` on `brandSubtle` | #5B4BB0 / #F1EFF9 | 6.00 | pass |
| Idle tab icon, glass over black (rendered) | `text2` on composite | #4A4A53 / #CCCCCC | **5.46** | pass |
| Idle tab icon, glass over busy stripes (rendered) | `text2` | #4A4A53 / #DBDCDE | 6.39 | pass |
| Idle tab icon, glass over purple content (rendered) | `text2` | #4A4A53 / #E3E0F4 | 6.78 | pass |
| Idle tab icon, glass over white (rendered) | `text2` | #4A4A53 / #FFFFFF | 8.77 | pass |
| Old idle grey on glass over black | `muted` | #696972 / #CCCCCC | 3.38 | thin, so replaced on glass |
| Badge dot on white | `danger` | #C8383B / #FFFFFF | 5.14 | pass |

**Decision:** the palette is unchanged. Brand purple `#7262C7` stays the fill; the existing
`#5B4BB0` text token already beats the `#6553B7` trial.

## Frosted navigation (stage C)
- **Built-in Flutter only:** `ClipRRect(pill)` around `BackdropFilter(ImageFilter.blur(20))`
  around a container with a white 80% tint (`MonoGlass.tint`) and an 8% ink hairline drawn as a
  foreground decoration, so it takes no layout room. One filter, bounded to the 64pt pill.
- **Active tab:** the existing opaque purple-tint circle (concentric with the pill) with a filled
  purple icon. Idle tabs show outline icons in `text2`. Selection is carried by shape, fill and
  colour.
- **Navigation preserved:** the same `NumayaTabBar` widget, items, order, tooltips, semantics,
  48dp minimum targets, `goBranch` behaviour and routes. Only `HomeShell` gains
  `extendBody: true`. `TabPage` and Profile add the bar's height to their bottom padding, and
  Discover's floating Like/Pass row is lifted above the bar.
- **System navigation:** a 95% page-colour strip (`MonoGlass.systemInset`) sits under the
  gesture handle or three buttons only.
- **Fallback:** `TabBarSurface.opaque` is the approved pill. It switches on automatically under
  **High Contrast** (`MediaQuery.highContrastOf`). This Flutter SDK has **no
  reduce-transparency setting**, so none is claimed.
- **Package decision:**
  - `liquid_glass_widgets` 1.16.1 (MIT, Flutter ≥ 3.41) was **not adopted**. Its own guide requires
    `await LiquidGlassWidgets.initialize()` in `main()`, `LiquidGlassWidgets.wrap()` around the
    app and `GlassScaffold` on every screen with glass bars: an app-wide migration.
  - Its lightweight tier, `GlassQuality.minimal`, is plain `BackdropFilter`, which is what this
    prototype already uses.
  - `flutter_liquid_glass` was not installed either.
- **Performance:** **unverified on hardware**. The emulator renders in software. The design keeps
  cost low (one bounded filter, no shadow, no opacity layers), but frame times and heat need a
  physical phone.

## Evidence
These images are **not committed** (bulky). They are on the owner's machine under
`artifacts/frosted-navigation-experiment/comparisons/` in the worktree. Only the stress-background
golden is in git (`test/screenshots/goldens/fn01-glass-backgrounds.png`).

| File | Shows |
|---|---|
| `abc-390dp-discover-profile.jpg` | A / B / C: Discover and the profile scroll at 390dp |
| `abc-390dp-tabs.jpg` | A / B / C: Likes, Messages, Profile |
| `abc-320dp-discover-profile.jpg` | A / B / C at 320dp: wordmark and chip fixes |
| `nav-closeup-390dp.png`, `nav-closeup-390dp-profile.png` | Bottom bar close-ups |
| `glass-over-stress-backgrounds.png` | The bar over black, white, page grey, busy stripes and purple, plus the High Contrast fallback |
| `C-device-checks-200pct-threebutton.jpg` | C at 200% text, and in three-button mode (after the strip fix) |

**Patches:** `patches/B-typography-compact-header.patch` and `patches/C-frosted-navigation.patch`.

## Recommendation
| Experiment | Recommendation | Why |
|---|---|---|
| Typography (chip role) | **Keep** | Fixes truncation of user data and unifies three chip sizes; no regression in the 4 × 3 size matrix |
| Spacing / compact header | **Keep** | Fixes a visible 320dp defect; 390dp unchanged |
| Palette | **Keep as is** (no change) | The tokens already pass; the trial purple is weaker |
| Built-in frosted navigation | **Tune, then decide on a phone** | Legible and reversible, and content-under-bar works. On a flat page it looks slightly flatter than the shadowed pill. Needs a hardware performance check and a look over real photos |
| Liquid Glass package | **Defer** | App-wide wrapper and scaffold migration for no visible gain over the built-in blur |

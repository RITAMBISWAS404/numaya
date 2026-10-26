# V12 Liquid Glass: design decisions

V12 tests one idea: does a restrained glass material on a few layers make Numaya feel more premium
without costing legibility? The experiment has its own flag, `?theme=liquid-glass`.

**What it is:** V11 plus glass.
- A themed screen renders `.theme-tiimo .theme-liquid-glass`. V11 is the base, and the glass rules
  only add.
- The V11 flag (`?theme=tiimo`) and the default design are untouched, so the glass can be dropped
  completely by deleting one stylesheet and one flag value.

**Where it lives:**
- tokens: `tokens/numaya.tokens.json` → `component.glass` (`--glass-*`);
- rules: `src/design-system/styles/theme-liquid-glass.css`;
- flag: `src/lib/theme.js` (`themeClassName`);
- tests: `tests/e2e/experiment-liquid-glass.mjs`.

## 1. References: what is Apple's, what is mine

**Apple's guidance.** From [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass),
quoted:
- **What it is for:** Liquid Glass "forms a distinct functional layer for controls and navigation
  elements", and "applies to the topmost layer of the interface, where you define your navigation".
- **Restraint:** "Avoid overusing Liquid Glass effects… Liquid Glass seeks to bring attention to the
  underlying content, and overusing this material in multiple custom controls can provide a subpar
  user experience by distracting from that content. Limit these effects to the most important
  functional elements in your app."
- **No stacking:** "avoid overcrowding or layering Liquid Glass elements on top of each other."
- **Legibility:** "Optimize for legibility when content scrolls beneath controls." Scroll views
  offer a scroll edge effect that "helps maintain sufficient legibility and contrast for controls by
  obscuring content that scrolls beneath them."
- **Sheets:** "half sheets are inset from the edge of the display to allow content to peek through
  from beneath them. When a half sheet expands to full height, it transitions to a more opaque
  appearance to help maintain focus on the task."
- **Accessibility:** people "can… turn on accessibility settings that reduce transparency or motion
  in the interface. These settings can remove or modify certain effects."

**Mobbin.** Two searches: "iOS 26 Liquid Glass tab bar" and "Liquid Glass bottom sheet with filters
over content". I looked at each image:

| Screen | What it actually shows |
|---|---|
| [Luma](https://mobbin.com/screens/a8facd4e-7215-4fac-aaaa-41f1fb5f017f), [Calm](https://mobbin.com/screens/28636a9e-a222-42a0-9570-1310d6245a9e), [TIDE](https://mobbin.com/screens/ed413bc9-2772-4650-b2fd-81a3e89bd964), [GitHub](https://mobbin.com/screens/fab73273-02cf-4d6f-b928-ac52c87b4a6b), [Apple Fitness](https://mobbin.com/screens/021d6e62-8a5b-4974-9dcf-4474275a7f49), [Public](https://mobbin.com/screens/97ac39bb-5c76-4104-b7c9-668f9ef6eba9), [Brink](https://mobbin.com/screens/83902ce8-378f-481a-8c2b-7235e7e488eb) | The iOS 26 tab bar: a floating, inset capsule of glass with the active tab on a lighter lozenge. On white (GitHub, Public, Brink) the glass is almost white, with a soft edge. On imagery (TIDE, Calm) it takes the colour beneath. |
| [Speak](https://mobbin.com/screens/9ed82b20-9d9d-40ba-8a9b-285b7c94866a) | A conventional full-width tab bar, near-opaque white over scrolling content. |
| [Mesh](https://mobbin.com/screens/30d2e090-036b-4f3b-9b57-aca7b1c48e4d) | A filter menu in light glass over a list, with dark text on a near-white glass. |
| [Breathwrk](https://mobbin.com/screens/2985a69e-a120-4863-be0e-e9d7a30d27cb), [Revolut Business](https://mobbin.com/screens/59892370-55d1-402a-9d76-22d0b307ae34) | Dark glass sheets: opaque-looking groups set on a translucent panel. |
| [Netflix](https://mobbin.com/screens/2343cde1-8d5d-4e8c-9b19-63d4576807e7), [Posh](https://mobbin.com/screens/d6225217-568a-43f2-852d-115fb9fcc8e8) | Full-screen dark blurs behind a list. Heavy, and hard on the content beneath. |

**My interpretation** (not taken from any one reference):
- **Keep the full-width bar.** V11's conventional bar was a deliberate decision, and the brief keeps
  it. The floating iOS 26 capsule would be a redesign, not a material.
- **Opaque groups on a glass sheet.** As in the Breathwrk and Revolut sheets, but light.
- **A web scroll edge.** Apple's scroll edge effect, rebuilt as a CSS mask so the labels keep their
  contrast.

## 2. Where glass goes, and where it does not

| Layer | Material | Why |
|---|---|---|
| **Tab bar** (Home, Activity, Likes, Messages, Profile) | **Regular glass** | The one persistent functional layer above content. Content now scrolls beneath it, so the glass has something to show and the bar reads as a layer, not a row of the page. |
| **Sheets** (Discover and Activity filters, unmatch, photo options) | **Thick glass** | A task over the page. The dimmed page stays faintly present, and the groups inside stay opaque white, so the controls read as content set on the glass. |
| **Controls on photographs** (the photo remove button) | **Dark glass** | A small control on an image. Dark glass lets the photo show around the control instead of covering it with a solid black square. |
| Header controls (filters, more, settings, back) | Opaque (V11) | They sit on the white canvas with nothing behind them, so glass would be invisible: decoration with no function. |
| Cards, groups, pills, tags, inputs, info containers, prompts | Opaque (V11) | Content, not the functional layer. Glass would lower contrast and make everything look alike. |
| Buttons (primary purple, secondary white) | Opaque (V11) | A primary action must look solid and pressable. No secondary button sits over content, where translucency would help. |
| Discover photo text (name, job, badges, SuperSwipe) | V11 (the black-to-clear photo fade; the solid band on placeholders) | A glass panel behind the name would be a second scrim over the fade and would blur the photo it is meant to show. |
| **Match** | **None: an intentional exception** | The scalloped portrait and your rounded-square photo are the moment. No glass, halo, border or reflection. The composer and "Keep browsing" stay as in V11. |
| Chat composer | Opaque (V11) | It grows as you type, so an overlay would cover the newest message. |

## 3. Material tokens

One small scale, in `component.glass`:

| Token | Value | Used by |
|---|---|---|
| `--glass-fill` | `rgb(255 255 255 / 0.88)` | Regular glass: the tab bar |
| `--glass-fill-thick` | `rgb(255 255 255 / 0.9)` | Thick glass: sheets |
| `--glass-fill-dark` | `rgb(20 19 22 / 0.5)` | Dark glass: controls on photos (white icon) |
| `--glass-filter` | `blur(24px) saturate(1.2)` | The one backdrop, for every glass layer |
| `--glass-edge` | `rgb(20 19 22 / 0.10)` | The hairline where glass meets content (the bar's top) |
| `--glass-highlight` | `rgb(255 255 255 / 0.70)` | A 1px lit line just inside the top edge (light glass only) |
| `--glass-shadow` | `0 -8px 28px -12px rgb(20 19 22 / 0.16)` | Sheets only: a soft upward shadow. Bars have none |
| `--glass-edge-fade` | `0.2` | Scroll edge: content passing under the bar fades to 20% |
| `--glass-fallback` | white (`palette.surface`) | Opaque fallback for light glass |
| `--glass-fallback-dark` | `alpha.ink-62` | Opaque-enough fallback for dark glass |

**How the rules use them.**
- The theme maps the tokens onto four working properties: `--lg-fill`, `--lg-fill-thick`,
  `--lg-fill-dark` and `--lg-filter`, plus `--lg-edge-fade` for the scroll edge.
- Every glass rule reads only those properties, so a fallback swaps the whole material in one place.
- Blur and opacity are never hard-coded per component.

**Not used:** inner shadows, white outlines thicker than 1px, glows, refraction or rainbow edges, and
tinted (purple) glass.

## 4. How I tuned it, from the rendered screens

I didn't tune by reading the CSS; I inspected every value below in screenshots at full size.

1. **First pass:** fill 72%, `blur(20px) saturate(1.6)`, sheets at 86%.
   - The Discover "next profile section" showed through the bar as a soft smear. That is acceptable,
     and it hints that there is more to scroll.
   - The **unmatch sheet turned the purple messages behind it into a lavender cloud.** The saturation
     lift was amplifying colour. I lowered it to 1.2, made the blur 24px and sheets 90%.
2. **Contrast over dark content.** With 72% white over a black photo, the grey tab labels fell to
   about 2.5:1.
   - Apple's answer is the scroll edge effect, so I added a mask: content fades to 20% only where it
     passes under the bar.
   - The fill went up to 88%, and inactive icons and labels on glass take the stronger grey `#6B6771`
     (5.5:1 on white). Brand purple stays brand purple.
   - Measured on the rendered pixels:

     | Fill | Edge fade | Purple label over solid black |
     |---|---|---|
     | 85% | 25% | 4.41:1 |
     | 88% | 25% | 4.49:1 |
     | **88%** | **20%** | **4.53:1** (inactive grey 5.11:1) |

     [qa/tab-bar-contrast.txt](qa/tab-bar-contrast.txt) has the full results.
3. **Sheet labels.** V11's grey section labels ("How old are they?") measured 4.1–4.25:1 on the glass
   sheet.
   - Inside sheets, muted labels now take `#6B6771` too (measured 4.9–5.1:1).
   - My first version also changed the secondary text colour, which turned the unmatch sheet's
     consequence rows grey. Reviewing the screenshots caught it (`cf9844e`), and a test now pins all
     other sheet text to V11's colours.

**The result:** on a white page the bar is visually white with a fine edge. When content scrolls
beneath it, the bar shows a soft, faded ghost of that content and stays legible. That is the
intended restraint: you should notice a polished bar, not an effect.

## 5. Purple and geometry

- **Purple stays solid** where it is meaningful: the active tab, primary actions, selection. No glass
  is tinted purple, and the saturation lift is kept low so purple content beneath can't bloom
  through the glass.
- **Geometry is V11's:**
  - the full-width square-cornered bar;
  - sheets with the 20px photo corner;
  - the 28px photo remove button with its 8px corner.
- **The monochrome palette is unchanged.** Glass is white or ink at an opacity, never a new colour.

## 6. Accessibility, fallbacks and performance

- **Reduced transparency** (`prefers-reduced-transparency: reduce`) and **increased contrast**
  (`prefers-contrast: more`): every glass layer becomes the opaque fallback, with no backdrop and no
  scroll-edge fade. Tested by emulating both media features.
- **No `backdrop-filter` support:** an `@supports not (backdrop-filter…)` block applies the same
  opaque fallback.
- **Contrast:**
  - tab labels are 4.5:1 or better over white and over solid black (rendered);
  - sheet headings and labels are 4.5:1 or better (rendered);
  - the photo remove icon is 3:1 or better over a pure white photo.
- **Active state** is shown by colour and the filled icon, not by transparency. `aria-current`,
  accessible names, the 44px or larger targets and keyboard focus are V11's.
- **Layering:**
  - one backdrop layer per screen (the tab bar), plus one per open sheet;
  - glass is never stacked on glass in view: a sheet covers the bar under its scrim;
  - the tab bar sits at `z-index: sticky`, under overlays and sheets.
- **Performance:**
  - one `blur(24px)` backdrop per bar, which is the cost iOS-style bars always carry;
  - nothing in scrolling content has a backdrop;
  - the scroll-edge mask is on the scroll container, not on each row.
  - On a phone this is within what Safari and Chrome handle routinely. I did not profile frame times
    on hardware.

## 7. What worked, what did not

**Worked:**
- **The tab bar as a layer.** Content scrolls under it and stays faintly visible, and the bar stays
  crisp and legible.
- **Sheets as glass with opaque groups.** This is the clearest improvement: the sheet reads as a
  layer over Discover, and the white groups inside gain hierarchy.
- **Dark-glass photo controls** are quieter than solid black squares.

**Did not work, or was not worth it:**
- **A higher saturation lift (1.6)** made purple content bloom through the sheets.
- **A thin bar (72%)** failed AA over dark photos. A legible bar is necessarily mostly opaque, so on
  Numaya's white canvas the effect is subtle by design.
- **Glass on the white-canvas header controls** would change nothing visible, so I didn't apply it.
- **Glass on the Discover name block or the Match portrait** would hide the photo and add a second
  scrim, so I didn't apply it.
- **Glass on the chat composer** would cover the newest message as the field grows, so I didn't
  apply it.

## 8. To remove the experiment

Delete:
- `theme-liquid-glass.css` and its import;
- the `liquid-glass` entry in `EXPERIMENT_THEMES` / `themeClassName`;
- the `component.glass` tokens;
- `tests/e2e/experiment-liquid-glass.mjs`, with its entries in `package.json` and `a11y.mjs`.

V11 and the default design don't depend on any of it.

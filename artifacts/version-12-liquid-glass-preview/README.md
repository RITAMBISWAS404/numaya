# Numaya V12: restrained Liquid Glass

**Start here:** [contact-sheet.png](contact-sheet.png), then
[comparisons/sheets-and-controls-v11-v12.png](comparisons/sheets-and-controls-v11-v12.png) and
[comparisons/navigation-scrolled-v11-v12.png](comparisons/navigation-scrolled-v11-v12.png). The design
specification, references and tuning are in [design-decisions.md](design-decisions.md).

V12 is an **experiment behind its own flag**, `?theme=liquid-glass`. It is V11 with one glass
material on three selected layers:

1. **The tab bar.** Regular glass (white 88%, `blur(24px) saturate(1.2)`).
   - Content now scrolls beneath it, with a scroll-edge fade so labels keep 4.5:1 or better over any
     content.
   - The V11 structure is unchanged: full width, icon over label, red dots.
2. **Sheets** (Discover and Activity filters, unmatch, photo options). Thick glass (white 90%) over the
   dimmed page, with the groups inside kept opaque white.
3. **The photo remove button.** Dark glass (ink 50%) instead of solid ink.

Everything else is V11: content, cards, pills, inputs, buttons, the Discover photo fade and band, the
Match (an intentional exception), headers and the chat composer.
- With reduced transparency or increased contrast, each glass layer becomes opaque.
- It also becomes opaque where `backdrop-filter` is unsupported.

## Verdict for the team

- **Sheets: worth keeping.** This is the clearest gain. The sheet reads as a layer over the page, and
  the opaque white groups get more hierarchy on the glass.
- **Photo controls: a small, safe refinement.**
- **Tab bar: subtle, and less important.** To keep its labels at AA over dark photos, the bar has to
  be mostly opaque (88%) and fade what passes beneath it. On Numaya's white canvas, the result is a
  bar that looks almost like V11 at rest and shows a faint ghost of content while scrolling. It's
  polished, but on its own it doesn't justify the experiment.
- Nothing became less usable. V11 and the default design are untouched, so the material can be
  adopted per layer, or discarded entirely.

| | |
|---|---|
| Branch | `experiment/tiimo-inspired-v12-liquid-glass` |
| Starting commit | `59e06e8`, the head of `experiment/tiimo-inspired-v11`, fetched and verified |
| Implementation | `79fd316` (the experiment), `cf9844e` (sheet body text keeps its V11 colour) |
| Final commit | the commit that adds this folder (see the branch head) |
| V11 | `experiment/tiimo-inspired-v11` at `59e06e8`, untouched |
| Approved fallback | `design/apple-impeccable-full-app` at `944c532`, untouched |

## Preview

```
npm install
npm run dev
```

| What | URL |
|---|---|
| **Liquid Glass (V12)** | `http://localhost:5173/flows.html?screen=discovery&theme=liquid-glass` |
| V11, for comparison | `http://localhost:5173/flows.html?screen=discovery&theme=tiimo` |
| Approved design | `http://localhost:5173/flows.html?screen=discovery` |

To see other screens, replace `discovery` with one of these:
`chats`, `chat`, `likes`, `like-profile`, `match`, `profile`, `edit`, `prompt`, `settings`, `activity`,
`photos`, `interests`, `basics`.

**What to try:**
- Open the filters on Discover, Activity filters, or Unmatch from a conversation's options to see the
  glass sheets.
- Scroll Profile, Likes, Activity or the Discover profile to see content pass under the bar.
- Turn on Reduce Transparency (macOS: Accessibility → Display) in a browser that supports
  `prefers-reduced-transparency` to see the opaque fallback.

Welcome is at `http://localhost:5173/?theme=liquid-glass`. It has no glass layer, so it matches V11.

## Screenshots

All are 393 × 852 at 2×, unless the name says 375 × 667.
- **`baseline/`:** V11 (`?theme=tiimo`), 30 states.
- **`final/`:** V12 (`?theme=liquid-glass`), the same 30 states.

| Area | Screens (V11 → V12) |
|---|---|
| Discover | Discover [V11](baseline/019-discover-393x852.png) → [V12](final/019-discover-393x852.png); full profile [V11](baseline/020-discover-fullpage-393w.png) → [V12](final/020-discover-fullpage-393w.png); filters sheet [V11](baseline/023-discover-filters-sheet-393x852.png) → [V12](final/023-discover-filters-sheet-393x852.png) |
| Matching | Likes [V11](baseline/054-likes-393x852.png) → [V12](final/054-likes-393x852.png); Like back [V11](baseline/059-like-profile-393x852.png) → [V12](final/059-like-profile-393x852.png); Match [V11](baseline/030-match-393x852.png) → [V12](final/030-match-393x852.png) |
| Messaging | Messages [V11](baseline/034-chats-393x852.png) → [V12](final/034-chats-393x852.png); Conversation [V11](baseline/038-chat-conversation-393x852.png) → [V12](final/038-chat-conversation-393x852.png); Unmatch sheet [V11](baseline/045-chat-unmatch-sheet-393x852.png) → [V12](final/045-chat-unmatch-sheet-393x852.png) |
| Profile and settings | Profile [V11](baseline/099-profile-393x852.png) → [V12](final/099-profile-393x852.png); Edit profile [V11](baseline/102-edit-profile-393x852.png) → [V12](final/102-edit-profile-393x852.png); Settings [V11](baseline/111-settings-393x852.png) → [V12](final/111-settings-393x852.png) |
| Activity | Activity [V11](baseline/061-activity-393x852.png) → [V12](final/061-activity-393x852.png); filters sheet [V11](baseline/064-activity-filters-sheet-393x852.png) → [V12](final/064-activity-filters-sheet-393x852.png) |
| Onboarding | Add photos [V11](baseline/018-photos-393x852.png) → [V12](final/018-photos-393x852.png); Interests [V11](baseline/016-interests-prompt-393x852.png) → [V12](final/016-interests-prompt-393x852.png) |
| 375 × 667 | [Messages](final/147-qa-chats-375x667.png), [Settings](final/149-qa-settings-375x667.png), [Activity](final/153-qa-activity-375x667.png), [all of them](qa/responsive-375.png) |

### `comparisons/`

- [sheets-and-controls-v11-v12.png](comparisons/sheets-and-controls-v11-v12.png): the Discover
  filters, unmatch and Activity filters sheets, and the photo remove buttons, side by side.
- [navigation-scrolled-v11-v12.png](comparisons/navigation-scrolled-v11-v12.png): the tab bar on
  Profile, Likes, the Discover profile and Activity, scrolled so content meets the bar.
- Full screens, V11 against V12 at the same viewport:

  | Area | Comparisons |
  |---|---|
  | Discover | [Discover](comparisons/019-discover.png), [Discover filters](comparisons/023-discover-filters-sheet.png) |
  | Matching | [Likes](comparisons/054-likes.png), [Like back](comparisons/059-like-profile.png), [Match](comparisons/030-match.png) |
  | Messaging | [Messages](comparisons/034-chats.png), [Conversation](comparisons/038-chat-conversation.png), [Unmatch sheet](comparisons/045-chat-unmatch-sheet.png) |
  | Profile and settings | [Profile](comparisons/099-profile.png), [Edit profile](comparisons/102-edit-profile.png), [Settings](comparisons/111-settings.png) |
  | Activity | [Activity](comparisons/061-activity.png), [Activity filters](comparisons/064-activity-filters-sheet.png) |
  | Other | [Add photos](comparisons/018-photos.png), [Messages at 375](comparisons/147-qa-chats.png) |

### `qa/`

| File | What it shows |
|---|---|
| [reduced-transparency.png](qa/reduced-transparency.png) | The tab bar and the filter sheet with and without `prefers-reduced-transparency: reduce` |
| [tab-bar-contrast.txt](qa/tab-bar-contrast.txt) | Rendered label contrast over white and over solid black under the bar |
| [responsive-375.png](qa/responsive-375.png) | The 375 × 667 states |
| [accessibility-axe.txt](qa/accessibility-axe.txt) | The axe run, including the glass flow previews and the glass filter sheet |
| [v11-and-default-unchanged.txt](qa/v11-and-default-unchanged.txt) | V11 30/30 and the default design 162/162 byte-identical |

## Validation

All checks were run on `cf9844e`.

| Check | Result |
|---|---|
| Tokens / icons | pass (335 tokens: 9 glass tokens plus the scroll-edge fade; generated files up to date) / pass |
| Unit tests (Vitest) | **121 / 121** (new: the theme flags) |
| Production build | **pass** |
| Smoke e2e (approved design) | **144 / 144** |
| Product e2e (journeys) | **88 / 88** |
| V11 experiment e2e (`experiment-tiimo.mjs`) | **111 / 111**, unchanged |
| **Liquid Glass e2e** (`experiment-liquid-glass.mjs`, new, in `npm run test:e2e`) | **27 / 27** |
| Accessibility (axe, 12 views including the glass flow previews and the glass filter sheet) | **0 serious or critical** |
| V11 (`?theme=tiimo`), 30 states | **30 / 30 byte-identical** to V11's committed screenshots |
| Default, 162 states | **162 / 162 byte-identical** to the approved design |

**What the Liquid Glass suite checks:**
- **Scoping:**
  - `?theme=liquid-glass` themes the 15 screens;
  - `?theme=tiimo` and the default never carry the glass;
  - screens outside the experiment stay approved.
- **The material:**
  - the token values;
  - glass is added only to the tab bar, sheets and photo controls, never to content, buttons, the
    Discover photo text or the Match, compared screen by screen with V11.
- **Tab bar:**
  - full width at the bottom edge, 56px plus the inset, regular glass with an edge and no shadow;
  - content scrolls beneath it and its last row clears the bar, with the scroll-edge mask;
  - 24px icons, labels, 44px targets and red dots;
  - active purple, inactive `#6B6771`;
  - **rendered** label contrast of 4.5:1 or better over white and over solid black;
  - it visibly reads as glass over dark content.
- **Sheets:**
  - thick glass above the scrim, with a soft shadow and V11's corners;
  - opaque white groups, and a solid purple primary action;
  - **rendered** heading and label contrast of 4.5:1 or better;
  - text keeps V11's colours except muted labels;
  - the sheet still closes.
- **Photo controls:** dark glass at 28px, and 3:1 or better over a white photo.
- **Unchanged from V11:** the Discover fade and placeholder band; the Match scallop, size and halo,
  with no glass.
- **V11 itself:** its bar stays in flow and opaque.
- **Fallbacks:** `prefers-reduced-transparency` and `prefers-contrast` make everything opaque, and
  the `@supports not` fallback exists.
- **Interaction:** tabs keep the flag, with a keyboard focus ring.
- **Narrow width and errors:** no overflow at 375px, and no console errors.

Against V11's code the suite fails at once: V11 has no `liquid-glass` flag, so 2 of its 3 scoping
checks fail, and the run stops on the first glass lookup.

## Browser and performance notes

- **Headless capture.** In this environment's headless Chromium, the default GPU path left
  `backdrop-filter` blur **unrendered** over scrolling content: content beneath the bar showed sharp,
  only washed out. A minimal page confirmed that the CSS is valid and that it is a renderer issue.
  - All V12 screenshots, and the glass test suite, use SwiftShader
    (`--use-angle=swiftshader --enable-unsafe-swiftshader`; `GALLERY_CHROMIUM_ARGS` in
    `scripts/gallery.mjs`).
  - The V11 baseline uses the same flags, so the comparison is like for like.
  - Real Safari and Chrome on phones render backdrop blur natively, but I haven't checked them on a
    device.
- **Support.**
  - `backdrop-filter` is supported in current Safari, Chrome and Firefox, and the
    `@supports not (backdrop-filter…)` fallback covers the rest.
  - `prefers-reduced-transparency` is supported in Chromium and Safari, and emulated in the tests.
- **Performance.**
  - One backdrop layer per tab screen, plus one per open sheet; nothing in scrolling content has a
    backdrop.
  - The scroll-edge mask is a single gradient on the scroll container.
  - I didn't profile frame times on real devices.

## Remaining limitations

- **The tab bar effect is deliberately faint.** Legibility over dark photos caps its transparency
  ([design-decisions.md](design-decisions.md) §4).
- **No real photography.** The worst case under the bar is a solid black block, and the Discover fade
  is checked against V11's computed gradient.
- **Sheets are not inset** from the screen edges as iOS 26 half sheets are. I kept V11's geometry; an
  inset sheet would be a layout change to test separately.
- **The navigation reference screenshot** mentioned in the V11 brief was never attached. V12 keeps
  V11's conventional bar rather than iOS 26's floating capsule.

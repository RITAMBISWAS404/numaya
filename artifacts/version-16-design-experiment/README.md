# Numaya V16: Withings Health Mate reconstruction

**Start here:** [screenshots/final-review/contact-sheet-final.png](screenshots/final-review/contact-sheet-final.png), then the
Reference | V11 | V16 sheets in [screenshots/final-review/](screenshots/final-review/) and
[FINAL_FIDELITY_AUDIT.md](FINAL_FIDELITY_AUDIT.md). (The first-delivery sheets in `screenshots/` are kept for history;
`screenshots/v16/` holds the final captures.)

V16 keeps V11's screens, layouts, copy and behaviour. It replaces the visual system with one reconstructed from the
Withings Health Mate iOS screens on Mobbin:
- a warm stone page with white cards that have no border or shadow;
- ink primary actions;
- Withings blue and its tint for accents and selection;
- green switches;
- one grotesk (Hanken Grotesk), with bold page titles and tracked capital modal headers;
- grouped lists;
- outlined fields with capital labels;
- circular header buttons and navy initials avatars.

| | |
|---|---|
| Base | `experiment/tiimo-inspired-v11` at `59e06e8`, verified ([BASELINE.md](BASELINE.md)) |
| Branch | `experiment/numaya-v16-withings` |
| Activation | `npm install && npm run dev`, then `http://localhost:5173/flows.html?screen=discovery&theme=withings` (or `/?theme=withings` for Welcome). `?theme=tiimo` still shows V11; no parameter shows the approved design. |
| Scope | V11's 15 screens: `basics`, `interests`, `photos`, `discovery`, `like-profile`, `likes`, `match`, `chats`, `chat`, `prompt`, `activity`, `profile`, `edit`, `settings`, plus Welcome |

## Where it lives

- **Tokens:** `tokens/numaya.tokens.json`, under `primitive.color.withings`, `semantic.color.withings`,
  `font.withings`, `shadow.withings-*` and `component.withings`; generated with `npm run tokens`.
- **Styles:** `src/design-system/styles/theme-withings.css` (components) and `src/flows/theme-withings.css`
  (flow screens), scoped to `.theme-withings`.
- **Activation:** `themeClasses()` in `src/lib/theme.js`. V16 screens carry `.theme-tiimo.theme-withings`: V11
  provides the layout and V16 restyles it.
- **Font:** `@fontsource-variable/hanken-grotesk` (SIL OFL).
- **Tests:** `tests/e2e/experiment-withings.mjs` (47 checks, part of `npm run test:e2e`) and
  `tests/unit/theme.test.js`.

## Documents

| File | Contents |
|---|---|
| [BASELINE.md](BASELINE.md) | Verified V11 state, architecture, inventory, baseline test results |
| [research/REFERENCE_ANALYSIS.md](research/REFERENCE_ANALYSIS.md) | 30 screens and 3 flows inspected, with Mobbin links, measured colours and geometry, observed vs inferred, access limits; 44 previews in `research/reference/` (38–44 added by the final audit) |
| [design-system/DESIGN_PRINCIPLES.md](design-system/DESIGN_PRINCIPLES.md) | The eight principles |
| [design-system/TOKENS.md](design-system/TOKENS.md) | Every V16 token with HEX, use and contrast |
| [design-system/COMPONENT_RULES.md](design-system/COMPONENT_RULES.md) | V11 → V16 rule per component, with reference and test coverage |
| [design-system/SCREEN_INVENTORY.md](design-system/SCREEN_INVENTORY.md) | Screens and the 49 captured states |
| [design-system/V11_LAYOUT_AND_UX_BASELINE.md](design-system/V11_LAYOUT_AND_UX_BASELINE.md) | What was kept, what changed and why, what was rejected |
| [SCREEN_REVIEW.md](SCREEN_REVIEW.md) | Three review passes: problems found and corrections |
| [FINAL_FIDELITY_AUDIT.md](FINAL_FIDELITY_AUDIT.md) | Final audit: reference revisited, category-by-category traceability matrix, fixes |
| [ACCEPTANCE_REVIEW.md](ACCEPTANCE_REVIEW.md) | Final 1–10 scores with evidence, remaining discrepancies |

## Screenshots

| Path | Contents |
|---|---|
| `screenshots/v16/` | 49 V16 states (393 × 852 at 2×; `qa-*` at 375 × 667) |
| `screenshots/v11/` | The same 49 states in V11, captured before any V16 CSS |
| `screenshots/comparisons/v11-v16-*.png` | 24 side-by-side pairs |
| `screenshots/comparison-v11-v16.png` | Overview, 8 screens |
| `screenshots/comparison-reference-v16.png` | Reference beside V16, 8 pairs |
| `screenshots/responsive-375.png` | Small-phone states |
| `qa/` | Isolation report, axe results, V16 e2e output |

## Validation (final code, in this container)

| Check | Result |
|---|---|
| `npm run check` (tokens, icons, Vitest, build) | **pass**: 386 tokens, 67 icons, **122/122** unit tests (3 new), build ok |
| Smoke e2e | **143/144**; the one failure is the same on untouched V11 ([BASELINE.md](BASELINE.md)): this Chromium reports `corner-shape: superellipse(1)` by default |
| Product e2e | **88/88** |
| V11 experiment e2e | **111/111** |
| V16 experiment e2e | **47/47** (the 7 added by the final audit fail on the pre-audit code) |
| a11y e2e (approved design) | 0 serious or critical |
| axe on the 15 V16 screens | 0 serious or critical |
| Default mode, 162 states | **162/162 pixel-identical** to `59e06e8` rendered in the same browser |
| V11, 49 states | **49/49 pixel-identical** before and after V16 |

## Recommendation

**Keep V16 as an experiment branch alongside V11.** Don't replace V11.

Its strengths:
- V16 is the more mature and calmer system: grouped settings, real field anatomy, a clear ink and outline action
  hierarchy.
- It is fully isolated and tested.

What argues against making it the default:
- It is a health-tracker language. On a dating product the warm-stone, utilitarian character reads as trustworthy
  but less expressive than V11.
- Its strength shows most on settings and forms, and least on the photo-led screens, which still lack real
  photography.

The next step is to test both with real photos and users before choosing.

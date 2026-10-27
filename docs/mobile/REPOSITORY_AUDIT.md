# Repository audit (Phase 0)

Done before any Flutter code was written, on 2026-10-27.

## Git state

| | |
|---|---|
| Starting point | `experiment/numaya-v16-withings` at `2c11a6d` (clean working tree) |
| Default branch | `claude/pensive-newton-glyzjr` (`7954fa3`, an ancestor of `2c11a6d`) |
| Work branch | `experiment/numaya-flutter-foundation`, created from `2c11a6d` after checking it existed neither locally nor on `origin` |
| Other experiments | `experiment/tiimo-inspired-v11` (V11), `experiment/numaya-v16-withings` (V16): untouched |

The Flutter work adds only `apps/numaya_mobile/` and `docs/mobile/`. No existing file outside them was changed. The web
prototype, its tokens, its default theme and the V11/V16 experiments are byte-for-byte as they were.

## What exists

| Area | Finding |
|---|---|
| Product | Vite + React 19 prototype of a premium dating app (`src/`), onboarding and the main app screens |
| Mobile code | **None.** No Flutter, React Native or native project existed. |
| Design system | `tokens/numaya.tokens.json` → `npm run tokens` → `src/design-system/tokens.{css,js}` (437 tokens), components in `src/design-system/` |
| UX research | `docs/research/`: Bumble screen specs (B-02 … B-74), flow catalogue, states and recovery, decision log, open unknowns |
| Product rules | `PRODUCT.md`, `CLAUDE.md` non-negotiables |
| Assets | Fraunces and Inter via Fontsource (SIL OFL), 67 Material Symbols Rounded paths (Apache-2.0), 9 original spot illustrations drawn in code, the Numaya mark drawn in code. **No photography**, no supplied logo file, illustration PNG slots reserved but empty. |
| Backend | None. No auth provider, API or database is chosen ([architecture](../engineering/architecture.md): "No production framework is chosen yet"). |

## Which design is canonical

Three visual systems exist in the repo:

| System | Where | Status |
|---|---|---|
| Approved default | No `?theme` parameter | **Canonical.** Defined by `PRODUCT.md` and the `CLAUDE.md` non-negotiables: Meetup visual system, brand purple `#7262C7`, Fraunces headings + Inter text, purple pill buttons and round purple next button, soft grey fields, lavender guidance cards. Present on the default branch. |
| V11 "Tiimo" | `?theme=tiimo` | Opt-in experiment |
| V16 "Withings" | `?theme=withings` | Opt-in experiment; its own README recommends keeping it as an experiment, not the default |

The Flutter app follows the **approved default**. Reasons: it is what the product documents require, it is what the
default branch ships, and both experiments are explicitly opt-in. Because the Flutter tokens are generated from the
same token file, a V16-style theme could be added later as a second token set without touching screens.

## Decisions taken from the audit

1. **Location:** `apps/numaya_mobile/`, leaving the web prototype at the repo root untouched.
2. **One source of truth for design:** a generator reads the compiled web tokens and writes Dart
   (`tool/generate_tokens.mjs`); icons and illustrations are exported from the same web sources
   (`tool/export_assets.mjs`). Nothing visual is re-typed by hand.
3. **Copy and rules are ported, not invented:** every string and validation rule comes from the web screens
   (`src/prototype/screens/*.jsx`, `src/flows/screens.jsx`) and `docs/research/screen-specs.md`.
4. **No fake backend:** sign-in uses a clearly labelled demo service in development builds only; release builds have
   no sign-in until a real provider is chosen.
5. **No stock people:** photos are labelled placeholder tiles until upload exists.

## Environment limits found

| Need | Result |
|---|---|
| Flutter SDK | Installed from `storage.googleapis.com` (Flutter 3.47.8 stable, Dart 3.13.7) |
| pub.dev packages | Reachable |
| Android SDK (`dl.google.com`) | **Refused by this cloud environment's network policy.** So no Android SDK, no `flutter build apk` here. |
| Google Fonts site | Unreachable; fonts were converted from the Fontsource files already in `node_modules` instead |

# Tiimo typography audit (iOS)

**Role:** typography inspiration only. Based on Mobbin previews of Tiimo onboarding screens:
[notifications](https://mobbin.com/screens/edec19f7-e515-437d-9ea6-2bd731be0d8c),
[morning routines](https://mobbin.com/screens/c6ae3650-762d-41f8-af89-100e55011f0f),
[biggest need](https://mobbin.com/screens/da18f710-765d-4312-8be3-23d9c0a25b92),
[neurodivergent](https://mobbin.com/screens/e2345aec-25d2-4584-9bcc-266601eaf9de),
[updates](https://mobbin.com/screens/e4d51357-f83e-49f8-ad20-04de0e6c58e7),
[sign in](https://mobbin.com/screens/910a4c23-17b5-4615-aab3-7d2de619d855),
[calendars](https://mobbin.com/screens/ae95ea5c-716a-4903-b039-75aed9dc237d),
[import calendar](https://mobbin.com/screens/2ce22544-adb8-48d0-908c-05b57d063c0d).
All findings are [O] at preview resolution.

## Observations

| Role | Observed treatment |
| --- | --- |
| Headline | Serif with moderate contrast and soft, slightly rounded terminals. **Regular weight**, not bold. ~30–32 px, line height ≈ 1.1, slight negative tracking. Two or three lines, balanced breaks |
| Lede / body | Neutral grotesk, ~15–16 px regular, near-black or dark grey, line height ≈ 1.4 |
| Button label | The same sans, semibold ~16 px, sentence or title case |
| Option label (outlined pill buttons) | Sans semibold ~15 px, centred |
| Eyebrow / tag | Sans, uppercase, ~11–12 px, wide tracking (~0.1 em), set in a small tinted pill ("MORNING") |
| Top-right utility ("SKIP") | Sans uppercase, tracked, muted grey |
| Legal | Sans ~12 px with bold underlined links |

**Relationship.** Hierarchy comes from **size and family contrast** (serif display vs sans text),
not from weight. Whitespace is generous: the headline block sits alone, followed by a short lede,
then controls. Weight is reserved for actions.

**Typeface identity.** The exact Tiimo display face could not be established from the previews
[U]. Numaya does not guess its name or try to replicate it.

## Numaya decision

| Role | Family | Why |
| --- | --- | --- |
| Display (headlines, wordmark, prompt answers, sheet titles) | **Fraunces** (variable; `opsz`, `wght`, `SOFT`, `WONK`). Weight ~440, `SOFT 50`, `WONK 0` | The closest open match to a soft, moderate-contrast display serif. Optical sizing keeps small sizes sturdy. SIL OFL 1.1 |
| Text (body, labels, inputs, buttons, numerals) | **Inter** (variable) | Neutral grotesk with tabular figures for codes, phone numbers and prices. SIL OFL 1.1 |

Both fonts are self-hosted via `@fontsource-variable/*`, so there are no runtime requests to font
CDNs. No other families are permitted without a token change
([implementation guide](../engineering/implementation-guide.md#changing-tokens)).

## Rules carried into the design system
1. Serif for **expression** (headlines, names, prompt answers); sans for **operation**.
2. Display weight stays at **400–460**. Never bold the serif for emphasis; use size or brand colour.
3. Emphasis inside a headline is **colour only** (`color.text.brand-display`, exact `#F770E3`), applied to one meaningful
   word or short phrase.
4. Uppercase is limited to eyebrows and tags, always tracked at `tracking.eyebrow`.
5. Numbers in inputs and prices use Inter with `tabular-nums`.

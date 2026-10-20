# Meetup visual audit (iOS)

**Role:** visual patterns, composition, surfaces, spacing, component treatment and hierarchy.
Not flows, not brand. Based on Mobbin previews of the
[Meetup onboarding flow](https://mobbin.com/flows/e35f43d2-bbfe-46dc-9c8d-f34cace68d08), the
[Joining a group flow](https://mobbin.com/flows/5731d7db-2003-437e-9024-3155f50a344a) and the
[Member dues flow](https://mobbin.com/flows/d65003e2-eb56-406d-abeb-6af8f7578e47). All findings
are [O] at preview resolution; pixel values are estimates.

## Observations

### Composition and spacing
- A single column with a ~16 px gutter on a 393 pt width. Content is left-aligned on form screens
  and centred on welcome and success screens.
- Generous vertical rhythm: title → lede ≈ 12–16 px, lede → first control ≈ 24–32 px.
- One primary action per screen, pinned to the bottom as a full-width pill.
- Floating chrome: back, close, share and ⋯ are white circles (~36–40 px) with a soft shadow,
  floating over content rather than sitting in a bar.

### Surfaces
- White page background. Secondary surfaces are a very light cool grey (~#F3F4F6).
- Cards are white with a hairline border or a very soft shadow and a large radius (~16–20 px).
- An organizer card uses a soft grey fill with small decorative sparkles. Tip cards use a hairline
  border with an icon and a bold title.
- A floating tab bar: a translucent rounded capsule over content, with icon + label items.

### Components
- **Buttons:** primary is a near-black pill (~52 px) with a subtle top-to-bottom gloss and
  depth. Disabled is a light grey pill with grey label. A secondary tinted button uses a light
  brand tint fill with a dark label. Text buttons are underlined.
- **Auth stack:** Google (white, outlined) · Apple (black) · Facebook (brand fill) · "or" divider ·
  *Sign up with email* (tinted) · *Log in with email* (underlined text).
- **Fields:** soft-filled, borderless, ~52 px, radius ~16, placeholder in mid-grey, optional
  trailing icon (calendar). Focus moves to white with a ring [I].
- **Progress:** short segmented pills centred at the top (~16×8 px); filled segments in brand.
- **Selection:** radio rows as outlined rounded rows with the radio on the left. Chips are outlined
  with a ⊕ icon, compact (~32 px). Collapsible category headers have a round chevron toggle in
  brand.
- **Lists of content:** event cards with a large rounded image, overlay icon buttons (share,
  heart) in white circles, a bold title, an uppercase date line, a meta line and an attendee avatar
  stack ("326 going").
- **Loading:** a spinner replaces the button label inside the sticky CTA. The post-onboarding
  "Thanks! Just a second…" screen uses a checklist with brand check circles.
- **Success:** "Joined!" tag on a tilted logo card, centred title, then related content.
- **Accordion:** an FAQ in a rounded card with dividers and chevrons.

### Hierarchy and type
- Headlines are bold, compact grotesk at ~28 px with tight leading and slight negative tracking.
- Body copy is ~15–16 px regular in mid-grey. Labels are ~14 px semibold.
- **Colour emphasis on a single word** in the welcome headline ("The **people** platform"),
  instead of an underline or ornament.

## What Numaya adopts

| Meetup pattern | Numaya adaptation |
| --- | --- |
| Floating white circular nav buttons | `IconButton` variant `floating` (white, `shadow.float`) |
| Glossy ink primary pill | `Button` primary uses `button.primary.*` component tokens (ink gradient) |
| Soft-filled borderless fields | `TextField`, `PhoneField`, `SearchField` share `field.*` tokens |
| Segmented progress pills | `ProgressSegments` in brand `#63AFE9` |
| Hairline-border cards with large radius | `Card` surface (`radius.lg`, `border.subtle`) |
| Tip card | `TipCard` |
| Colour emphasis on one headline word | Welcome headline emphasis via `color.text.brand` |
| Spinner replacing the CTA label | `Button loading` |
| Floating capsule tab bar | `TabBar` spec (floating variant), future work |

## What Numaya does not adopt
- Meetup purple, sparkles and doodle decorations, and its illustration style.
- Social-login brand buttons in Numaya's palette: provider buttons follow provider guidelines.
- Heavy bold grotesk headlines: Numaya uses Fraunces at regular weight
  ([Tiimo audit](tiimo-typography-audit.md)).

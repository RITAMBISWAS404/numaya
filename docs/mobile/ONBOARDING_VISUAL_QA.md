# Onboarding visual QA

Branch `experiment/numaya-onboarding-complete`.

**How the captures are made:** renders of the real app (bundled Hanken Grotesk) at 393 × 852 @2x, from
`test/screenshots/capture_onboarding_test.dart`:

```bash
cd apps/numaya_mobile
flutter test --tags screenshots --run-skipped --update-goldens test/screenshots
```

**How they were reviewed:** inspected by eye, screen by screen, against the V16 parts they're built from.
Nothing was run on a phone or emulator.

## Captures

`apps/numaya_mobile/test/screenshots/goldens/o01`–`o39`. Contact sheets are in `docs/mobile/screenshots/`:
`onboarding-1.png`–`onboarding-5.png`.

| Captures | Screen and states |
|---|---|
| o01 | Setup hub, nothing done |
| o02–o06 | Name and birthday: empty, a date that doesn't exist, under 18, valid ("You're 31"), the confirm card |
| o07, o08 | Gender; with pronouns picked |
| o09, o10 | Who you want to meet: none, two picked, with the age range |
| o11 | Intentions at the maximum (third unavailable) |
| o12, o13 | Height: not added, added |
| o14–o19 | Location: primer, denied, blocked, the stand-in prompt, sample area set, the area sheet |
| o20–o23 | Photos: empty, source sheet, two photos with the camera off, tips |
| o24–o26 | Interests: empty, 5/5, no search results |
| o27–o29 | Prompts: none, one, the editor with a used question |
| o30, o31 | Bio: empty, with preview |
| o32 | Verify your photos |
| o33, o34 | Notifications: primer, denied |
| o35–o37 | Review: ready, with a missing item, creation failed |
| o38 | All set |
| o39 | Under 18 |

## V16 consistency

Every new screen is built only from existing V16 parts:
- the stone page and white top bar with progress segments;
- the 26pt flow heading with its lede and spot illustration;
- white option cards (radio and checkbox);
- chips with + and −;
- list groups, tint status banners, info cards and V16 sheets;
- the round ink next button with its caption;
- ink primary and outlined secondary buttons.

No new colours, type sizes or radii were added, and no competitor visuals were copied.

## Defects found by inspection and fixed

| # | Capture | Defect | Fix |
|---|---|---|---|
| OV-1 | o09, o10 | The option legend repeated the title ("Who do you want to date?" under "Who do you want to meet?") | Legend "Show me" |
| OV-2 | o14 | Location used the interests illustration, which says nothing about location | Illustration removed |
| OV-3 | o14–o16 | The info card's title was the prompt tag ("Demo · stands in for Android's prompt"), and its body repeated "Demo build" | Title "Demo build", body without the repeat |
| OV-4 | o18 | The area row squeezed "Your area" to two lines beside a two-line value | The area is the row's label with "Your area" under it |
| OV-5 | o32 | The caption said "Maybe later" beside the "Maybe later" button | "Optional · you can verify later" |
| OV-6 | o34 | The denial message appeared twice (banner and caption) | Caption "You can change this in Settings" |

## Earlier captures that changed

Each was compared with the previous commit before being accepted.

| Captures | Change | Verdict |
|---|---|---|
| 05–07 (code) | Progress shows the first of five sections (was 2 of 5) | Intended (OD-14) |
| 08 (hub) | Four sections, "0 of 4 done" | Intended |
| 09–15 (old Basics, Interests with prompt, Photos) | Removed: those screens no longer exist; o02–o29 replace them | Intended |
| 16–23, d0xx, f0xx | Different sample member from the new journey (Woman, Jazz/Poetry/Travel, two photos); ages 26–38 set during onboarding | Intended. In particular d024 now reads "2 people are just outside ages 26–38" |
| f01, f38 (Demo Hub) | New Onboarding group | Intended |

## Remaining mismatches and limits

- **Photos:** placeholder tiles; no picker, camera or crop (no plugin; would need a device to verify).
- **Location and notifications:** the prompt is a labelled stand-in for Android's own dialog.
- **Height:** a stepper and slider stand in for a wheel picker (Hinge uses a wheel [O]). This keeps V16's
  controls, but feel needs a device.
- **Review:** the profile card fills the first screen; the checklist and private choices are below it.
- **Large text:** at 130% the tap-target and layout checks pass on every onboarding screen (automated), but
  nobody has looked at 200% captures of these screens.

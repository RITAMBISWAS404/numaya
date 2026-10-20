# Numaya · Onboarding prototype

A browser prototype of the first three onboarding screens of Numaya, a premium dating app:
**Welcome → Phone number → Verification**.

- **Flow and UX:** Bumble iOS onboarding (welcome with *Create an account* / *I have an account*,
  phone number with country picker and privacy reassurance, six-digit code with resend).
- **Layout and components:** Meetup iOS (soft filled fields, floating circular back button,
  segmented progress, glossy ink primary button), re-branded around `#63AFE9`.
- **Typography:** after Tiimo iOS. Headlines, the wordmark and prompt answers use
  [Fraunces](https://fonts.google.com/specimen/Fraunces), a soft serif at regular weight.
  Body, labels, inputs and buttons use [Inter](https://rsms.me/inter/). Both are SIL Open Font
  License and self-hosted through `@fontsource-variable`.

## Brand colour rules

`#63AFE9` (`--accent`) is the brand blue for marks, progress, focus rings and tints, and nothing
sits on top of it. Filled blue surfaces that carry text or icons use `--accent-strong`
(`#1F6FB0`, same hue) with white `--on-accent` foreground (5.3:1). Blue text on light surfaces
uses `--accent-ink`. Dark text only appears on white, neutral or tinted backgrounds.

## Run

```bash
npm install
npm run dev
```

Then open http://localhost:5173. `npm run build` makes a production build in `dist/`.

On a desktop the app renders inside a scaled iPhone 15 Pro frame (393 × 852) with a brief
panel. At phone widths (≤ 520px) it runs full screen with the native keyboard and safe areas.

## Using the prototype

- Type on your keyboard or tap the simulated number pad.
- The demo code arrives as a Messages banner about 1.4 s after the code is sent. Tap the banner or
  the *From Messages* suggestion to fill it. Any other six digits shows the error state.
- *Change number* and the back button return to the previous step, and the number you entered is kept.
- The brief panel can jump to any step or start over.

## Structure

```
src/
  styles/tokens.css        all colors, fonts, type scale, spacing, radii, shadows, motion
  styles/*.css             base, device chrome, components, screens, presentation
  components/              Button, NextButton, Field, TopBar/Progress, Sheet, Pill,
                           Notification, Keypad, Device (frame, status bar), Brief
  screens/                 Welcome, PhoneNumber, VerifyCode
  data/countries.js        dial codes and national number formats
  App.jsx                  step state and push/pop navigation
```

Motion respects `prefers-reduced-motion`: pushes become cross-fades and decorative motion is removed.

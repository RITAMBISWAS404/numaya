# V8 typography: Tiimo research and the Numaya type system

## 1. Screens reviewed

Viewed through the Mobbin connector on 11 November 2026 (iOS). These are 22 Tiimo screens from three searches:

- **Home and planner:** Today ([f6a61b24](https://mobbin.com/screens/f6a61b24-612d-4536-8ca0-375231808968)), Today with tasks, the day menu sheet, My Weekly Insights ([d93486b4](https://mobbin.com/screens/d93486b4-645a-481d-b43f-45efc7e04a59)), the Me menu, the assistant empty state ("What's the plan today?") and Pick tasks.
- **Onboarding:** "Are you neurodivergent?", "What's your biggest need right now?", "Never miss a task!", "Would you like updates from Tiimo?", a course with lessons, and widgets.
- **Settings and sheets:** Settings ([e4d13e43](https://mobbin.com/screens/e4d13e43-8d7a-4445-890c-40db9ccf8b83)), Notifications & Sounds, Fonts with a dialog, a delete-profile confirmation, the tag picker sheet, Edit task, and Choose visuals.

## 2. What we observed

- **The serif is a soft display face at regular weight, used large and sparingly.** It sets one mood-setting line per screen: the day name ("Wednesday"), onboarding questions, "My Weekly Insights", "What's the plan today?", "Planning for every kind of brain".
- **The serif also titles editorial cards and lesson entries.** Examples are "Mood and Daily Reflections", "Start focus", "Introduction" and "Practical techniques…", plus the numbers in a few stat and timer cards.
- **Everything functional is sans:** buttons, rows, settings, toolbar titles ("Edit task"), task names, dates, uppercase micro labels ("ANYTIME (0)", "DAYS IN A ROW"), metadata, tab labels and form values.
- **Utility screens are sans only.** Settings, Notifications and the delete dialog have no serif at all. Sheets with actions are sans.
- **Both families share most screens, but never one component:** a serif heading sits over a sans body, and buttons stay sans even under a serif title.
- **Hierarchy comes from size, not weight, in the serif.** The sans uses weight (Bold for actions and names, Regular for metadata).

## 3. Roles adopted for Numaya

| Role | Token | Family | Size/line | Weight |
|---|---|---|---|---|
| Display (Welcome, celebration) | `display1` | Bree Serif | 34/40 | 400 |
| Tab-root page title | `largeTitle` | Bree Serif | 32/38 | 400 |
| Onboarding and editorial heading | `flowTitle` | Bree Serif | 28/34 | 400 |
| Empty-state and milestone title | `emptyTitle` | Bree Serif | 22/28 | 400 |
| Names on photos, counts | `hero` | Google Sans | 32/40 | 700 |
| Functional page heading, value | `pageTitle` | Google Sans | 24/32 | 700 |
| App-bar title, chat name | `appBarTitle` | Google Sans | 20/28 | 700 |
| Section heading | `section` | Google Sans | 18/24 | 600 |
| Card heading | `card` | Google Sans | 18/24 | 600 |
| Body, rows, input | `body`, `row`, `input` | Google Sans | 15/20 | 500 |
| Button | `button` | Google Sans | 15/20 | 600 |
| Caption, metadata, timestamps | `caption`, `micro` | Google Sans | 12/16 | 500 |

The roles live in `app_typography.dart`, so changing a token changes every screen. Bree Serif has one weight, and `AppTypography.weight` leaves serif roles unchanged, so the face is never synthetically emboldened. The wordmark keeps Figtree because it is the logo.

## 4. Patterns we use

- One serif line sets the tone of a page. Everything you act on is sans.
- Serif goes on tab roots, onboarding questions, empty states and milestones, but not on settings, sheets, dialogs, chat or data cards.
- Serif hierarchy comes from size alone.

## 5. Patterns we do not copy

- **Serif card headings and serif numbers:** Numaya's cards hold data people scan, such as credits and streak days, so they stay sans.
- **Uppercase tracked micro labels:** Numaya chose sentence case earlier (R07).
- **Tiimo's pastel planner colours and character mascot:** Numaya keeps its purple identity and its own mascot.

## Fonts

- **Bree Serif:** `google/fonts` `ofl/breeserif`, SIL OFL 1.1, Regular only.
- **Google Sans:** `google/fonts` `ofl/googlesans` (variable: GRAD, opsz, wght 400–700), SIL OFL 1.1. "Google Sans" is a Google trademark. The unmodified font is bundled under its own name, as `TRADEMARKS.md` permits, and the name is not used for the product.

Licences are in `apps/numaya_mobile/assets/fonts/OFL-*.txt`.

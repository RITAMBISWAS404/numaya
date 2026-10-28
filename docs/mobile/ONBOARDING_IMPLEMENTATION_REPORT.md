# Onboarding implementation report

Branch `experiment/numaya-onboarding-complete`, from `experiment/numaya-android12-compat` @ `e5184e1`. The
app is in `apps/numaya_mobile/`. The web prototype is unchanged.

## What changed

| Area | Before | Now |
|---|---|---|
| Flow | Phone → code → hub → Basics (name, birth **year**, gender, intentions) → Interests + one prompt → Photos → Home | Phone → code → hub → 13 steps in four sections (About you; Looking for; Your profile; Finish) → review → All set → Home. See the [inventory](ONBOARDING_MASTER_INVENTORY.md) for the order |
| Age | Birth year; under 18 disabled Next | Full date of birth with validation (impossible, future, over-100 dates). Confirm card "You're N · Born …". Confirming under 18 locks the session: every route redirects to the explanation until sign-out |
| Identity | Gender | Gender, optional detail, pronouns (up to 4) and what the profile shows; the profile card reads "Woman · she/her" |
| Preferences | — | Who to meet (private; sets the Discovery filter), age range around your own age, intentions |
| Details | — | Height (cm or ft/in, optional); bio (optional, 300 characters) |
| Location | — | Primer, labelled permission stand-in (approximate, precise, deny), denied and blocked states, manual area with search. Only an area name is kept |
| Photos | "+" added a tile | Source sheet (camera or library); camera permission stand-in; tips sheet; Photos now comes before Interests |
| Interests | No search | Search with a no-results state |
| Prompts | One, on the Interests screen | Own step: 1 required, up to 3, no repeated question; leaving without Save keeps nothing |
| Verification | Only in Edit profile | Offered in onboarding (skippable), opening the existing simulated flow |
| Notifications | Switches only | Primer and stand-in prompt; the answer sets the push switches |
| Finish | The Photos button created the profile | Review shows the profile as others see it, missing items with links, and private choices. Create is guarded against double taps and offers retry on a simulated failure. Then All set |
| Edit profile › Basics | Edited the birth year | Birthday read-only (no way round the age check) |
| Demo Hub | — | Onboarding group: start a new sign-up without the code, open any step, reset permission answers |

## Files

**Domain and state** (`lib/features/onboarding/`, `profile/`):
- `profile_draft.dart`: date of birth, pronouns, "open to", the validators (`nameProblem`,
  `parseBirthDate`, `birthDateProblem`, `ageInYears`) and the missing items;
- `onboarding_controller.dart`: steps, sections, age lock, guarded `create`;
- `device_permissions.dart` (new);
- `profile_details.dart`: area and sample areas.

**Screens** (`lib/features/onboarding/presentation/`):
- `step_scaffold.dart`, `about_you_screens.dart`, `looking_for_screens.dart`, `permission_prompt.dart`,
  `profile_steps_screens.dart`, `finish_screens.dart` (new);
- `interests_screen.dart`, `photos_screen.dart`, `setup_hub_screen.dart`, `prompt_editor_screen.dart` and
  `basics_screen.dart` (updated).

**Routing:** `app/routes.dart`, `app/router.dart` (13 setup routes, the age-lock redirect).

**Copy:** `lib/l10n/app_en.arb` (+163 strings).

**Tests:**
- new: `test/widget/onboarding_complete_test.dart` (12) and `test/screenshots/capture_onboarding_test.dart`;
- rewritten: `test/unit/profile_rules_test.dart`, `test/widget/onboarding_edge_cases_test.dart`, the full
  sign-up in `test/widget/onboarding_flow_test.dart`, `test/helpers/journeys.dart`.

## Results

| Check | Result |
|---|---|
| `dart format` | clean |
| `flutter analyze` | No issues found |
| `flutter test` | **152 passed, 4 skipped** (the opt-in capture tests). Was 132 passed, 3 skipped before this branch |
| Captures | 6 passed (`o01`–`o39` new; earlier captures reviewed, see [ONBOARDING_VISUAL_QA.md](ONBOARDING_VISUAL_QA.md)) |
| `npm run tokens:check` | OK |
| APK build, emulator, device | **Not run.** No Android SDK here (`dl.google.com` refused) |

**Test changes:**
- Rewritten tests describe the new screens and assert more than before: the confirm card, the lock,
  boundaries and the review.
- `dating_test` "filters" now expects ages 26–38, which onboarding sets for a 31-year-old, so Inés (24) is
  outside the range too.
- No test was skipped or loosened to pass.

## Honest limits

- **Simulated services:** no SMS is sent (the demo code is shown), and nothing is uploaded. No photo is taken
  or checked, the location is never read, and no notification is sent. Each screen that stands in for one of
  these says so.
- **Not tested on a device:** permission dialogs, camera, picker, keyboard insets, TalkBack.
- **Progress is not persisted:** it is lost if the app is killed (in memory only; ARCHITECTURE: no personal
  data in plain storage, and there is no secure store yet).
- **Age lock:** lasts until sign-out. A real service would record the confirmed date of birth server-side.

## Rebuild and run (Windows)

```powershell
cd <repo>
git fetch origin
git checkout experiment/numaya-onboarding-complete
cd apps\numaya_mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug      # universal APK; build right before copying (see ANDROID_COMPATIBILITY.md)
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

In the app:
- **Create an account:** use any valid number; the code appears in the Demo text banner.
- **Demo build badge** (on Welcome) › Demo hub › **Start a new sign-up** skips the code.

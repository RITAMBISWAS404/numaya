# Master implementation report

A cumulative record of what the Flutter app implements, written for the "complete the product" pass.

- **Branch:** `experiment/numaya-complete-product`.
- **Completion status:** [MASTER_PRODUCT_COMPLETION_MATRIX.md](MASTER_PRODUCT_COMPLETION_MATRIX.md).
- **Evidence:** [MASTER_QA_REPORT.md](MASTER_QA_REPORT.md).

## Starting point (verified)

`experiment/numaya-full-ui-refinement` @ `d92af19` already contained every earlier mobile branch:
- native onboarding and its edge cases;
- Android 12 compatibility;
- the full dating app (Discover, For you, Likes, matches with expiry, chat, safety, Premium, verification,
  settings, help, account lifecycle);
- the motion system;
- Events;
- Profile & visibility;
- the UI refinement.

On that commit, the suite reported 227 passed and 8 skipped. I re-ran it myself before changing anything
and got the same result.

Reconciling the inventories with the code showed that most items listed as remaining were already built:
- the gender detail sheet;
- photo reorder and replace;
- permission prompts (a labelled stand-in for Android's dialog);
- the delete-account subscription warning;
- routing to support after failed verification;
- event hosting;
- the visibility dashboard.

The matrix records each correction. The genuine gaps were documented system states and a few deferred
screens that can be built honestly as a local demo.

## Added in this pass

| Area | What | Where |
|---|---|---|
| Offline (states-and-recovery §3, B-77) | App-wide connection banner under the status bar. Chat messages written offline show "Waiting for a connection" and send in order on reconnect. Event changes (join, leave, publish) fail with the existing retry, because they need the service's answer. Demo Hub switch "Simulate being offline"; reset restores online | `core/connectivity/connectivity.dart`, `app/app.dart`, `ConnectionBanner` (design system), `DatingController.send/retry/_sendWaiting`, `eventsRepositoryProvider` |
| Session expired (states-and-recovery §3) | "Please sign in again" is pushed over the current screen and can't be skipped with back. It asks for a code for the same number (the demo text message fills it); a wrong or expired code is handled. Success pops back to the same screen with nothing lost. "Sign out instead" is offered. Demo Hub row "Expire my session" | `auth/application/session_expiry.dart`, `auth/presentation/reauth_screen.dart`, `/sign-in-again` |
| Recovery email (B-09, U-11) | Settings › Account › Recovery email: add, validate on Save ("name@example.com"), change, remove. Shown as "Not verified: no email service in this build". Saving one enables the Email channel in notification settings; removing it turns email notifications off | `settings/application/account_prefs.dart`, `settings/presentation/recovery_email_sheet.dart` |
| Share Date (B-45) | Chat ⋯ › Share date details: where and when, a preview of exactly what a friend would see, Share. It says nothing is sent. Saved per match; the menu then reads "Date details shared" and reopens the details filled in | `safety_sheets.dart` (`showShareDateSheet`), `DatingState.datePlans` |
| RR-1 | Tab and date rows scroll to the screen edge; the first option stays on the gutter (`ViewTabs.bleed`) | `people.dart`; Events, Likes, Messages |
| RR-2 | Event covers lay out badges first and centre the category mark in the space left, scaling it down when needed; they can't overlap at large text | `event_parts.dart` |

## How the areas connect in the demo

- **Profile → everywhere:**
  - onboarding and Edit profile write one draft (`onboardingProvider`) plus profile details;
  - Profile, Preview, the completion card and hub, and Profile & visibility all read them, so an edit
    changes completeness and suggestions immediately.
- **Discover → Likes → Messages:**
  - a like on someone who liked you creates a match (match screen → chat);
  - the match joins the Messages queue with a countdown;
  - Likes and the tab badges update;
  - unmatch, block and report end the conversation and remove the person everywhere.
- **Messages:**
  - sample histories are fixed and deterministic;
  - your messages stay on the device (labelled), and offline they wait and then send;
  - Share Date and Did you meet? are saved per match.
- **Events:**
  - join, waitlist, leave, save, host, edit and cancel go through one controller, so the details page,
    Explore, My events (Going, Waitlist, Saved, Hosting, Past) and attendee lists always agree;
  - the Demo Hub can open a spot, simulate failures and reset to the fixed dataset.
- **Profile & visibility:** reads snooze, Incognito, filters, verification, notices and activity live;
  every suggestion opens its editor or setting.
- **Settings:**
  - snooze pauses Discover and shows as Paused on the visibility dashboard;
  - the recovery email unlocks email notifications;
  - sign-out clears every account store and any pending session expiry;
  - Demo Hub reset restores the sample data and turns simulated offline off.

## Simulated versus needing a backend

| Simulated here (labelled in the UI) | Needs |
|---|---|
| SMS codes (demo text message banner) | Auth provider |
| Sample people, likes, matches, replies never invented | Profiles and matching service |
| Messages "saved on this device, not sent"; offline queue | Messaging service, real connectivity detection |
| Photo picker placeholders | Photo picker, upload and moderation |
| Photo verification review | Camera and verification service |
| Premium purchase | Play Billing |
| Events: RSVP, capacity, waitlist, hosting, reports | Events service |
| Account notices, restriction, activity counts | Trust and safety, analytics |
| Session expiry trigger | API client returning 401 |
| Recovery email (not verified) | Email service |
| Share Date (not sent) | Platform share sheet |
| Permission prompts (stand-in) | Permission plugin |

## Not built, by decision or dependency

**Out of scope:** BFF mode and mode switching (D-08).

**Deferred:**
- splash;
- verify by call;
- crop;
- causes;
- connected accounts;
- saving-toggle spinner;
- onboarding resume after the app is killed (needs encrypted storage, C-7).

The matrix gives the reason and the next action for each.

## Build

**APK:** no APK was built. The Android SDK repository (`dl.google.com/android/repository`) returns
403 through this environment's proxy. To build on Windows:

```
cd apps\numaya_mobile
flutter pub get
flutter doctor -v
flutter build apk --debug
```

The APK is written to `build\app\outputs\flutter-apk\app-debug.apk`. `flutter run` with a phone connected installs it
directly. The full setup is in [GETTING_STARTED_WINDOWS.md](GETTING_STARTED_WINDOWS.md).

# Production readiness

**Status: not production-ready.** The onboarding UI, the dating screens (on labelled sample data), their rules and the
app architecture are built and tested. Everything that needs a server, a store account or a legal decision is not.

## Ready

| Area | Evidence |
|---|---|
| Native Flutter app, no WebView | `apps/numaya_mobile` |
| Approved visual design reproduced from shared tokens | DESIGN_SYSTEM.md, VISUAL_COMPARISON.md |
| Complete onboarding UI with validation, back navigation and every listed state | ONBOARDING_FLOW.md |
| Dating UI: Discover, filters, Likes, match, Messages, chat, unmatch / block / report, blocked people, snooze, error states | SCREEN_INVENTORY.md (on sample data only) |
| Layered architecture with replaceable repositories | ARCHITECTURE.md |
| Demo auth isolated and compiled out of release builds | `AppConfig.demoAuthAllowed` |
| No personal data on disk; logs redact numbers and codes | ARCHITECTURE.md (Logging, Data at rest) |
| Localisation infrastructure | `lib/l10n/app_en.arb` |
| Accessibility basics: Android 48dp targets and labelled controls (guideline tests), 375 × 667 at 130% text without overflow, live regions, focus rings, reduced motion | `test/widget/accessibility_test.dart` |
| Static analysis clean, 84 automated tests | IMPLEMENTATION_REPORT.md |

## Blocking a real launch

| # | Item | What's needed |
|---|---|---|
| 1 | **Phone authentication** | Choose a provider (e.g. Firebase Auth phone, Twilio Verify behind your API, Supabase). Implement `AuthRepository`; add rate limiting, abuse protection (SMS pumping), app attestation (Play Integrity / App Attest). |
| 2 | **Session storage** | Store refresh tokens with `flutter_secure_storage`; restore the session on launch. |
| 3 | **Backend for profiles** | API + `ProfileRepository` implementation; server-side validation of age, interests, prompt length. |
| 4 | **Photo upload** | `image_picker`, crop, upload, moderation (nudity, face detection), EXIF/location stripping. |
| 5 | **Matching, likes, chat, safety** | The screens exist and run on sample data in memory; there is no matching service, no message delivery, no moderation queue for reports. `DatingController` is the seam to replace. Report/block must reach a real moderation team before launch. |
| 6 | **Age assurance** | Birth year is self-declared. Many markets require stronger checks. Legal decision. |
| 7 | **Legal documents** | Terms and Privacy Policy (the Welcome links open a "not yet published" sheet). |
| 8 | **Account deletion** | Works in the demo; needs a server endpoint and a public deletion URL. |
| 9 | **Release signing and ids** | BUILD_AND_RELEASE.md |
| 10 | **Crash reporting / analytics** | Choose tools; consent where required; keep the redaction rules. |
| 11 | **Push notifications** | Settings switches are session-only today. |
| 12 | **Brand assets** | Final logo file, app icon, splash, welcome hero art (slot reserved). |
| 13 | **Fonts for non-Latin names** | Bundle full Inter/Fraunces or add fallbacks. |
| 14 | **Device QA** | Not yet run on a phone or emulator (no Android SDK in the build environment). Widget tests cover small screens, large text and tap targets; still needed on hardware: keyboard behaviour, swipe feel, TalkBack/VoiceOver. |
| 15 | **Dark mode** | Not defined by the approved design. |
| 16 | **iOS** | Project generated, never built (needs macOS). |

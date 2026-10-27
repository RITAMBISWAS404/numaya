# Production readiness

**Status: not production-ready.** The onboarding UI, its rules and the app architecture are built and tested. Everything
that needs a server, a store account or a legal decision is not.

## Ready

| Area | Evidence |
|---|---|
| Native Flutter app, no WebView | `apps/numaya_mobile` |
| Approved visual design reproduced from shared tokens | DESIGN_SYSTEM.md, VISUAL_COMPARISON.md |
| Complete onboarding UI with validation, back navigation and every listed state | ONBOARDING_FLOW.md |
| Layered architecture with replaceable repositories | ARCHITECTURE.md |
| Demo auth isolated and compiled out of release builds | `AppConfig.demoAuthAllowed` |
| No personal data on disk; logs redact numbers and codes | ARCHITECTURE.md (Logging, Data at rest) |
| Localisation infrastructure | `lib/l10n/app_en.arb` |
| Accessibility basics: 44 pt targets, semantics labels, live regions, keyboard activation, focus rings, reduced motion | widgets in `core/design_system` |
| Static analysis clean, 41 automated tests | IMPLEMENTATION_REPORT.md |

## Blocking a real launch

| # | Item | What's needed |
|---|---|---|
| 1 | **Phone authentication** | Choose a provider (e.g. Firebase Auth phone, Twilio Verify behind your API, Supabase). Implement `AuthRepository`; add rate limiting, abuse protection (SMS pumping), app attestation (Play Integrity / App Attest). |
| 2 | **Session storage** | Store refresh tokens with `flutter_secure_storage`; restore the session on launch. |
| 3 | **Backend for profiles** | API + `ProfileRepository` implementation; server-side validation of age, interests, prompt length. |
| 4 | **Photo upload** | `image_picker`, crop, upload, moderation (nudity, face detection), EXIF/location stripping. |
| 5 | **Matching, likes, chat, safety** | Not built; the tabs show honest empty states. Report/block are mandatory before launch for a dating app. |
| 6 | **Age assurance** | Birth year is self-declared. Many markets require stronger checks. Legal decision. |
| 7 | **Legal documents** | Terms and Privacy Policy (the Welcome links open a "not yet published" sheet). |
| 8 | **Account deletion** | Works in the demo; needs a server endpoint and a public deletion URL. |
| 9 | **Release signing and ids** | BUILD_AND_RELEASE.md |
| 10 | **Crash reporting / analytics** | Choose tools; consent where required; keep the redaction rules. |
| 11 | **Push notifications** | Settings switches are session-only today. |
| 12 | **Brand assets** | Final logo file, app icon, splash, welcome hero art (slot reserved). |
| 13 | **Fonts for non-Latin names** | Bundle full Inter/Fraunces or add fallbacks. |
| 14 | **Device QA** | Not yet run on a physical phone (no Android SDK in the build environment); test small screens, large text, TalkBack/VoiceOver. |
| 15 | **Dark mode** | Not defined by the approved design. |
| 16 | **iOS** | Project generated, never built (needs macOS). |

# Overnight polish: 14/20 body, large-text fixes, glass highlight, mascot

**Status:** local only, uncommitted and unpushed, awaiting the owner's review.

| Item | Value |
|---|---|
| Worktree | `/home/user/numaya-overnight` (cloud container) |
| Branch | `experiment/numaya-overnight-polish` (local; not on GitHub) |
| Base and HEAD | `6b23c85aa7be16b5cfeaebdea06c36a9090243b2` (`wip/frosted-navigation-handoff`, verified live on GitHub) |
| Scope | Flutter app (`apps/numaya_mobile/`) only. The web prototype, tokens JSON and generated Dart tokens are untouched. |

**Evidence source:** all screenshots are **Flutter test renders on Linux** (cloud), with real fonts, at
393×852 @2x unless named otherwise. They are **not** emulator or device captures; this
environment has no Android SDK (see VALIDATION).

## Decisions
| # | Decision | Why | Rejected |
|---|---|---|---|
| OP-01 | **Semantic default body is 14/20** (`AppTypography.body`, Figtree 400). A compile-time token switch (`--dart-define=NUMAYA_TYPE_SCALE=base`) reproduces the old 16/24 for review | The owner's requirement. The controlled comparison (below) shows no new clipping at 320 or 390pt at 100% or 200% text; chat bubbles and bios get denser without losing legibility | Keeping 16/24 (did not meet the requirement) |
| OP-01b | **Compact scale rejected**: 12/16 captions, 20/26 sections, 24/30 tab titles | 24pt tab titles fall below the 26pt profile name, inverting the hierarchy; 12pt captions are too small for metadata; 20/26 vs 21/28 is invisible | — |
| OP-02 | Exception: **option rows** (`OptionCard`: report reasons, gender, snooze length, delete reasons) use the 16/22 `row` role | They are tappable list rows, identical in structure to `ListRow`, which already uses `row`. At 14 they read smaller than the radio beside them | 14/20 body |
| OP-03 | Exception: **typed text is 16** in every field. Multi-line fields (bio, prompts, report notes) had inherited the body role and dropped to 14 | One input size; more comfortable caret and editing. Multi-line keeps its 24pt line | Typing at 14 |
| OP-04 | **Large-text fixes**, found in the comparison at 320pt and 200% text and present under 16/24 too: (a) tab-root titles step down from 32 to 24pt above 160% text (still 48pt rendered; "Profi…" truncation fixed) and the header grows; (b) the Profile hero stacks the avatar above the name (the name had broken as "Alex / , 30" and "Phone verifie / d"); (c) Discover photo badges and the photo count share one row, and stack at large text (the count overlapped "Verified"); (d) `ChipSet` group headings and the interests count wrap instead of overflowing (`/profile/edit/interests`, a 4.1px overflow on a route no test had opened) | Text scaling is never capped; layouts adapt | Capping text scale |
| OP-05 | **Glass top highlight**: a 1pt white line at 70% along the straight top edge of the frosted pill, inset 24pt. Bounded blur (20), tint (white 80%) and hairline (ink 8%) are unchanged; the High Contrast fallback is unchanged and draws no highlight | The brief's "restrained top highlight". It reads only over dark, busy or purple content, where the pane edge needs definition | Gradient sheen (no gradients in this system) |
| OP-06 | **Mascot**: an original purple cat with large ears, waiting with a heart (`assets/illustrations/mobile/mascot-waiting.svg`, drawn for Numaya in the house style). Used on the Likes empty state and "This like has moved on" | An empty state where a character helps; decorative (excluded from semantics) | Hosted generation (not allowed) |
| OP-07 | **Calm direction kept**; the expressive treatment was tried and removed | Expressive (tinted hero, purple names) hid the SuperSwipe button's tint circle against the tinted hero, competed with the purple Like, and weakened Edit profile | Expressive |
| OP-08 | Palette unchanged (`#7262C7` fill, `#5B4BB0` purple text) | All pairs still pass (see Palette). Type size does not change the thresholds: 14pt and 16pt regular are both "normal text" in WCAG | A new purple |

## 14/20 against 16/24: the controlled comparison
**Conditions:**
- the same build, demo data (Quick start), light theme and frosted tab bar;
- 320×693 and 390×844 at @2x, with 100% and 200% text;
- only `NUMAYA_TYPE_SCALE` changes between runs.

**Harness:** `test/screenshots/compare_type_scale_test.dart` (tag `comparison`, opt-in).

**Screens:**
- Discover;
- Discover scrolled to the bio;
- own Profile;
- a long bio (worst-case data, in preview);
- Chat with a long sent message.

| Sheet (rows: 16/24, 14/20, compact) | Path |
|---|---|
| 390pt, 100% | `artifacts/overnight-polish/type-comparison/sheet-390-100.jpg` |
| 320pt, 100% | `artifacts/overnight-polish/type-comparison/sheet-320-100.jpg` |
| 390pt, 200% | `artifacts/overnight-polish/type-comparison/sheet-390-200.jpg` |
| 320pt, 200% | `artifacts/overnight-polish/type-comparison/sheet-320-200.jpg` |
| 320pt, 200%: 14/20 before and after the OP-04 fixes | `artifacts/overnight-polish/type-comparison/sheet-320-200-fixes.jpg` |

The individual renders are under `type-comparison/{base,body14,compact,body14-fixed}/`. **Findings:**
- **Clipping:** 14/20 caused no new clipping or overflow at any of the four sizes. Every 200%
  defect seen was present under 16/24 too, and is fixed in OP-04.
- **Bios:** long bios fit about a third more text per screen (14/16 more characters per line, 24/20 more lines). The worst-case unbreakable link still
  wraps at slashes.
- **Chat:** bubbles hold more words per line and take less height (the comparison's chat column: the same long message is about 20% shorter), in line with Bumble and Hinge (Mobbin, below).
- **Roles kept above body:**

  | Role | Size | Reason |
  |---|---|---|
  | `promptAnswer` | 20/27 | emphasised content |
  | `row` | 16/22 | list rows and option rows |
  | `input` | 16/22 | typed text |
  | `button` | 16/20 | actions |
  | `chip` | 14/18 | facts |

## Direction treatments (OP-07)
Calm (kept) against expressive (removed), at 390pt and 100%, with identical data:
`artifacts/overnight-polish/direction/sheet-direction-390.jpg`.

## Mobbin research matrix (live connector, iOS; links are Mobbin's)
| Component / task | App | Screen | Pattern | Numaya decision | Acceptance check |
|---|---|---|---|---|---|
| Chat list: read a preview, find your turn | [Bumble](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74) | Chats | Bold names, previews about 14pt (visual estimate from the screenshot), "Your move" pill, match rings | Keep the 14/20 previews; "Your move" filter exists | `f07` at 14 reads the same; tests pass |
| Conversation: read long messages | [Bumble](https://mobbin.com/screens/f240ef7c-e408-4a63-ad4f-ad204ce34694) | Chat | Pill composer, compact bubbles | Bubbles at 14/20; composer typing 16 (OP-03) | `q148`; the comparison's chat column |
| Likes: what is waiting for me | [Hinge](https://mobbin.com/screens/fc42007e-a780-4d5e-99ce-3462fb8f3afb) | Likes You | Large bold title, short body, context on cards | Tab title kept at 32/38 (compact 24 rejected) | `18-likes`; OP-04a at large text |
| Text entry in a dialog | [Hinge](https://mobbin.com/screens/db21d93d-fb44-4963-a4e2-5c1b6268e7c2) | Add details | Larger input text than body; counter | Typing stays 16 (OP-03) | unit test: `input` is 16 |
| Note before matching | [Hinge](https://mobbin.com/screens/cdb294c2-01aa-4e53-ad41-7d28d1aac16f) | Match Note | Bold lead sentence, quiet tip card | Opening Moves already follows this; no change | `f22` |
| Profile facts and editing | [Tinder](https://mobbin.com/screens/fb209c16-f0dc-462d-a972-2c2377805c05), [Tinder](https://mobbin.com/screens/f7c19599-07dd-4d6e-ab6b-287fdb68b995) | Edit Info | Rows about 16pt with a value on the right; small captions | `ListRow` 16/22 kept; option rows match it (OP-02) | `22-settings`, `o07`, `d047` |
| Report a person | [Phantom](https://mobbin.com/screens/93ddbe65-1725-438b-b50b-fc7435d851f9), [Doji](https://mobbin.com/screens/5aa62826-e5d5-46e3-89d0-f6e52b8f74c7) | Report sheet | Title, reasons as rows, one submit | The report sheet already matches; reasons at 16 (OP-02) | `d047`, `f41` |
| Profile read (existing evidence) | [Hinge](https://mobbin.com/screens/935ec54d-ecb9-4760-83ff-9d762406f786) | Profile | Prompt cards with large serif answers | `promptAnswer` 20/27 kept above body | comparison column 2 |
| Floating translucent tab bar (carried forward) | Tinder, Coffee Meets Bagel, Hinge | see `docs/design-experiments/frosted-navigation/README.md` | — | OP-05 tunes it | `fn01` |

**Coverage gaps:**
- Feeld and Coffee Meets Bagel chat were not searched again this round (their earlier frosted
  bar references carry forward).
- Mobbin returned iOS only; Android was judged from Flutter renders.

## Palette (unchanged, re-verified)
`docs/design-experiments/monochrome-meetup-premium/evidence/contrast_check.py` computes every
pair; all pass. Relevant here:

| Pair | Ratio | Needs |
|---|---|---|
| ink on white | 17.72 | 4.5 |
| text2 on canvas | 7.98 | 4.5 |
| muted on white | 5.43 | 4.5 |
| white on brand | 4.90 | 4.5 |
| brandText on tint | 6.00 | 4.5 |
| Idle glass icon over black (rendered) | 5.46 | 3.0 |
| Selected glass icon | 6.00 | 3.0 |

The highlight (OP-05) is decorative and carries no information. The app is light-only (no dark
theme exists), so dark mode was not tested.

## Token and component spec (changes only)
| Token / component | Value |
|---|---|
| `MonoType.scale` | `body14` (default) \| `base` \| `compact` |
| `AppTypography.body` | Figtree 400, 14/20 |
| `AppTypography.bodySm` | 14/20; now the same size as body, kept as the secondary-colour role |
| `AppTypography.input` | 16/22; multi-line fields use 16/24 |
| `OptionCard` label | `row` 16/22 medium |
| `TabHeader` | min 64pt tall. Title 32/38, or 24/30 above 160% text |
| Profile hero | avatar beside the name, or stacked above 160% text |
| `PersonHeroCard` photo badges | one row with the count, or stacked above 160% text |
| `ChipSet` heading | `Flexible` |
| `MonoGlass.highlight` | `#B3FFFFFF`, 1pt, inset 24pt |
| `NumayaIllustration.mascotWaiting` | `assets/illustrations/mobile/mascot-waiting.svg`, 4:3 |

## Asset licences
| Asset | Source | Licence |
|---|---|---|
| `mascot-waiting.svg` | Drawn for Numaya in this session (hand-written SVG) | Project-owned |
| Fonts (Figtree, Plus Jakarta Sans) | Unchanged, in repo | OFL |
| Icons | Unchanged (existing set); no new icon family added | as before |

## Route coverage
59 route constants in `lib/app/routes.dart`. The evidence is the test or capture that opens the
route. Every full-app route also passes the 4-width × 3-text-size matrix (`size_matrix`).

| Route | Name | Evidence (tests / captures) | Status |
|---|---|---|---|
| `/` | welcome | system_states | checked |
| `/phone` | phone | onboarding journeys; capture 02–03 | checked |
| `/verify` | verify | onboarding journeys; capture 05–07 | checked |
| `/setup` | setup | capture_onboarding, onboarding_complete, onboarding_edge_cases | checked |
| `/setup/interests` | interests | capture_onboarding, onboarding_complete, onboarding_edge_cases | checked |
| `/setup/photos` | photos | capture_onboarding, onboarding_complete | checked |
| `/setup/prompt` | prompt | capture_onboarding | checked |
| `/setup/name` | setupName | capture_onboarding, onboarding_complete | checked |
| `/setup/underage` | setupUnderage | capture o39 | checked |
| `/setup/gender` | setupGender | onboarding_edge_cases | checked |
| `/setup/meet` | setupMeet | capture_onboarding | checked |
| `/setup/intentions` | setupIntentions | capture_onboarding | checked |
| `/setup/height` | setupHeight | capture_onboarding, onboarding_complete | checked |
| `/setup/location` | setupLocation | capture_onboarding, onboarding_complete | checked |
| `/setup/prompts` | setupPrompts | capture_onboarding, onboarding_complete | checked |
| `/setup/bio` | setupBio | capture_onboarding, onboarding_complete | checked |
| `/setup/verify` | setupVerify | capture_onboarding, onboarding_complete | checked |
| `/setup/notifications` | setupNotifications | capture_onboarding, onboarding_complete | checked |
| `/setup/review` | setupReview | capture_onboarding, onboarding_complete | checked |
| `/setup/done` | setupDone | capture o38 | checked |
| `/home` | home | route_sweep | checked |
| `/likes` | likes | route_sweep | checked |
| `/messages` | messages | route_sweep, accessibility | checked |
| `/profile` | profile | compare_type_scale, capture_overnight_polish, route_sweep | checked |
| `/profile/edit` | editProfile | route_sweep, accessibility | checked |
| `/profile/edit/basics` | editBasics | overnight route-gap sweep (320pt @200%, 390pt @100%) | checked |
| `/profile/edit/interests` | editInterests | overnight route-gap sweep (320pt @200%, 390pt @100%) | checked (fixed ChipSet overflow) |
| `/profile/edit/photos` | editPhotos | overnight route-gap sweep (320pt @200%, 390pt @100%) | checked |
| `/profile/edit/prompt` | editPrompt | overnight route-gap sweep (320pt @200%, 390pt @100%) | checked |
| `/profile/settings` | settings | route_sweep, accessibility | checked |
| `/profile/settings/blocked` | blocked | route_sweep | checked |
| `/profile/settings/notifications` | notifications | route_sweep, accessibility | checked |
| `/profile/settings/privacy` | privacy | route_sweep, accessibility | checked |
| `/profile/settings/delete` | deleteAccount | route_sweep, accessibility | checked |
| `/profile/complete` | completion | route_sweep, accessibility | checked |
| `/profile/preview` | preview | compare_type_scale, route_sweep, accessibility | checked |
| `/profile/opening-moves` | openingMoves | route_sweep, accessibility | checked |
| `/profile/verify` | verifyPhoto | route_sweep, accessibility | checked |
| `/profile/premium` | premium | route_sweep, accessibility | checked |
| `/profile/safety` | safety | route_sweep, accessibility | checked |
| `/for-you` | forYou | route_sweep, accessibility | checked |
| `/events` | events | route_sweep, accessibility | checked |
| `/event` | event | route_sweep, accessibility | checked |
| `/event/new` | eventNew | route_sweep, accessibility | checked |
| `/profile/visibility` | visibility | route_sweep, accessibility | checked |
| `/profile/visibility/about` | visibilityAbout | route_sweep, accessibility | checked |
| `/paywall` | paywall | route_sweep, accessibility | checked |
| `/help` | help | route_sweep, accessibility | checked |
| `/help/contact` | helpContact | route_sweep, accessibility | checked |
| `/restore` | restore | overnight route-gap sweep (320pt @200%, 390pt @100%) | checked |
| `/sign-in-again` | reauth | overnight route-gap sweep (320pt @200%, 390pt @100%); reauth also capture p06 | checked |
| `/account-blocked` | accountBlocked | route_sweep, accessibility | checked |
| `/demo` | demo | route_sweep, accessibility | checked |
| `/design-lab` | designLab | capture_monochrome, design_lab | checked |
| `/like` | like | capture_overnight_polish, route_sweep, overnight_polish | checked |
| `/match` | match | accessibility | checked |
| `/chat` | chat | compare_type_scale, route_sweep, accessibility | checked |
| `/person` | person | route_sweep, accessibility | checked |
| `signin` | intentSignIn | query value, not a screen (welcome sign-in intent) | n/a |

## Evidence index (stable paths, in the worktree)
| Path | Shows |
|---|---|
| `artifacts/overnight-polish/type-comparison/` | The 14/20 / 16/24 / compact renders and sheets |
| `artifacts/overnight-polish/direction/sheet-direction-390.jpg` | Calm against expressive |
| `artifacts/overnight-polish/glass/glass-before-after.png` | The tab bar over black, white, grey, stripes and purple, plus the High Contrast fallback, before and after OP-05 |
| `artifacts/overnight-polish/before-after/1-discover-profile.jpg` … `5-states.jpg` | The 16/24 baseline against the final state (Linux renders of HEAD against the working tree) |
| `artifacts/overnight-polish/op01-like-gone-mascot.png`, `op02-discover-320-200.png`, `op03-profile-320-200.png` | The mascot and the large-text fixes (also goldens) |

## Release readiness
Checked in the source on 2026-11-03 UTC. "Owner" is who acts next.

| Requirement | Status | Evidence | Owner / action |
|---|---|---|---|
| UI tests, analysis, token mirror | **Passed** | 312 passed, 14 skipped; analyze clean; tokens up to date | — |
| Large text to 200%, 320–430pt widths, tap targets, labels | **Passed** (renderer) | `size_matrix`, `accessibility`, `overnight_polish` route-gap sweep | — |
| Contrast (text 4.5:1, marks 3:1) | **Passed** | `contrast_check.py`, foundation tests, rendered glass measurements | — |
| Reduced motion, High Contrast fallback | **Passed** (renderer) | `AppMotion`; frosted fallback and OP-05 tests | — |
| Android build and APK | **Blocked** here | No Android SDK; `dl.google.com` is denied by the network policy | Owner: build on Windows (`flutter build apk --debug`), or allow `dl.google.com` |
| Device: performance, keyboard over the frosted bar, TalkBack, three-button navigation | **Unverified** | Previous emulator checks are historical; none this session | Owner: Windows emulator and Samsung Android 12 |
| iOS build, VoiceOver | **Unverified** | No macOS or Xcode | Needs a Mac |
| Authentication | **Failed for public release** | Demo sign-in and SMS codes are simulated (`docs/agent-handoff/NEXT_STEPS.md`, "Backend dependencies") | Backend owner |
| Real data, matching, messaging, media | **Failed for public release** | No networking package in `pubspec.yaml`; all data is local demo data | Backend owner |
| Report, block, moderation | **Failed for public release** | The UI exists and works locally; there is no moderation backend or review queue (Google Play UGC policy requires it) | Backend and Trust & Safety |
| Account deletion | **Failed for public release** | The UI flow exists; nothing server-side is deleted | Backend owner |
| Age gate, privacy policy | **Partial** | The underage screen (`/setup/underage`) blocks under-18s on the entered birthday; no privacy policy URL or data-safety form | Product and legal |
| Release signing | **Failed** | `android/app/build.gradle.kts` signs `release` with the **debug** key; app id `com.numaya.numaya_mobile`; version `0.1.0+1` | Engineering: create an upload key and Play App Signing |

### Decision
| Target | Decision |
|---|---|
| **Internal demo** | **Go, after one step:** build the debug APK on Windows from this worktree's changes. The UI is complete for the demo, all tests pass, and everything is labelled as demo data |
| **Staging** | **No-go:** there is no backend to stage against. The UI is staging-ready once an API exists |
| **Public release** | **No-go:** authentication, data, moderation, server-side deletion, privacy and release signing are missing, and nothing has been verified on a device |

**First action for tomorrow's deployment** (an internal demo build): the owner authorises a commit
and push of `experiment/numaya-overnight-polish`. Then, on Windows:
```sh
git fetch origin
git switch experiment/numaya-overnight-polish
cd apps/numaya_mobile
flutter pub get
flutter test
flutter build apk --debug
```

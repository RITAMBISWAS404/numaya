# Final design run (2026-11-05)

**Workspace and branch:**
- Worktree `C:\Users\biswa\Downloads\numaya\numaya-final-design`, branch
  `experiment/numaya-final-design-candidate`.
- Base `f2e18e627af9f06e9563db5bf09828995dcde5c4` (`origin/experiment/numaya-overnight-polish`,
  verified with `git ls-remote`).
- **Local and uncommitted:** publication was not authorised. The changes are exported as
  `artifacts/final-design-run/patches/final-design-run.patch`.

**What is new in this run:** the first **device evidence** for the overnight candidate (Pixel 10
emulator, Android 16, API 36, x86_64, software GPU). The earlier passes were golden-harness only.
Every fix below came from something seen on the emulator.

## Assessment of the candidate
The overnight candidate's design language (Bumble-style hierarchy, Meetup-style surfaces, 14/20
body, 12/16 pills) holds up at real phone size. On the device, most screens matched their golden
renders. Six defects appeared that the harness could not show, or that it showed without anyone
judging them; all are fixed below. The 12/16 pill labels, which looked small in contact sheets, are
**sound** at true scale (checked on a 1:1 crop).

## Changes (FD-xx), each with a regression test in `test/widget/final_design_run_test.dart`
| # | Surface | Evidence (device) | Root cause | Change |
|---|---|---|---|---|
| FD-A1 | Safety, Opening Moves, Premium, completion hub, How it works | Each opened with a large dashed box "Illustration: …" above the content | `IllustrationSlot` drew its developer placeholder on product screens | A slot without art renders nothing. The new `IllustrationPlaceholders` shows placeholders only in the Design Lab and in slot-geometry tests |
| FD-A2 | Every switch | The off track was faint on white cards: measured 1.33:1 (`#DDDDE3` on `#FFFFFF`) | CL-01 removed the track outline for looks | The off state gets a 1.5pt `control` edge (3.38:1 on white, 3.07:1 on the page; WCAG 1.4.11). The on state and the thumb are unchanged |
| FD-B1 | Every `NumayaButton` | Welcome at 320dp and 200% text: "Create an accou…" | Fixed height, one line, ellipsis | Minimum height (56 or 40), up to two centred lines. Single-line buttons are unchanged in size (tested), and a button never stretches in a tall parent (caught by the new test) |
| FD-D1 | `NumayaTopBar` with two or more actions (Event detail) | Share and Save touched (0pt) | `...actions` spread with no gap | 8pt between actions, as in the tab headers |
| FD-D2 | Edit profile header | Preview was the only bare header action next to a filled Back | `NavButtonStyle.plain` | The standard floating style |

**Checked and sound (no change):**
- pill and segment labels at 390dp (1:1 crop);
- the Filters sheet against Bumble's
  [Basic filters](https://mobbin.com/screens/f70d7965-5b08-4645-95fb-2e8f59d3f743) (question,
  control, then the related "if I run out" toggle);
- Settings against Bumble's
  [Settings](https://mobbin.com/screens/fad704ee-2d0c-4bc7-af4e-2c7a9192b6b2) (explanations under
  rows; Numaya uses group footnotes);
- Likes, Messages, Chat, Events and Event detail on the device.

## Design contract additions
Appended to [../overnight-polish/DESIGN_CONTRACT.md](../overnight-polish/DESIGN_CONTRACT.md):

| Area | Rule |
|---|---|
| Art | Never show an unfinished illustration on a product screen: a slot without `asset` collapses. Review placeholders in the Design Lab |
| Switch | Off: light track plus a 1.5pt `control` edge (≥ 3:1). On: purple track. The thumb is always white |
| Buttons | Never truncate a button label: up to two centred lines at large text; the height is a minimum, not a fixed value |
| Header actions | 8pt between adjacent header buttons; every header action uses the floating (filled square) style |

## Reference translation (additions this run)
| Numaya task | Bumble evidence | Meetup evidence | Component | Behaviour | Verification |
|---|---|---|---|---|---|
| Filter the deck | [Basic filters](https://mobbin.com/screens/f70d7965-5b08-4645-95fb-2e8f59d3f743): question, control, related fallback toggle | — | Filters sheet (unchanged) | Preserved | Device `04`/`05`, existing BM-02 tests |
| Settings rows | [Settings](https://mobbin.com/screens/fad704ee-2d0c-4bc7-af4e-2c7a9192b6b2): row, then an explanation under it | grouped rounded surfaces | `ListGroup` and footnote; switch edge (FD-A2) | Preserved | Device `17`, FD-A2 test |
| Explainers (Safety, Opening Moves) | — | [Announcement sheet](https://mobbin.com/screens/edeeabc9-6a4e-42c1-90e3-da44f13b74e2): strong heading first | Heading first; no placeholder art (FD-A1) | Content moves above the fold | Device `14`/`16`, FD-A1 tests |

The seed Meetup screens were reused from the overnight translation table and not re-opened. Mobbin
searches this run: "Bumble dating filters screen" and "Bumble profile details section" (iOS).

## Route and state coverage
| Status | Routes |
|---|---|
| **Fixed and verified on device** | `/profile/safety` (FD-A1), `/profile/opening-moves` (FD-A1), `/profile/settings` (FD-A2), `/` Welcome at 320dp/200% (FD-B1), `/event/:id` (FD-D1), `/profile/edit` (FD-D2) |
| **Fixed; harness only** | `/profile/premium`, `/profile/complete`, `/profile/visibility/about` (FD-A1, widget tests) |
| **Reviewed on device, sound** | `/home` Discover (top, detail, end), the Filters sheet, `/likes`, `/likes/:id`, `/messages` (plus the search keyboard), `/chat/:id`, `/events`, `/profile` |
| **Reviewed in renders, sound** | onboarding (name, gender, location, interests, prompts, photos, bio, review), Edit profile (more), new event, phone entry |
| **Device-only items** | Keyboard over the tab bar: verified (the keyboard covers the bar; search filters). Three-button navigation: verified. TalkBack: tree verified ("Show more about Maya / Maya, 29 / Verified / Product designer"); **live speech blocked** by TalkBack's first-run notification-permission prompt, which was dismissed, not granted |
| **Not verified** | iOS (Windows host), physical phone, profile-mode frame times |

## Remaining issues, ranked by user impact
1. **No real photography or illustration art.** Placeholder photos everywhere. With FD-A1 the
   explainers are text-only until the art exists (see the illustration backlog).
2. **Physical-device pass:** TalkBack speech, frame times in profile mode, haptics, real photos
   under the frosted bar.
3. **Goldens are Linux renders** from the cloud session. This run's 101 reviewed changes
   (Windows-to-Windows, `artifacts/final-design-run/golden-review/`) need regenerating on the
   canonical platform before they are accepted as baselines.
4. **Product readiness:** no backend, authentication, moderation, release signing or privacy
   review (unchanged from FINAL_QA.md).

## Readiness
| Target | Decision | Evidence |
|---|---|---|
| Internal demo | **Go** | Debug APK built and run on the emulator through every core journey; 352 tests pass (15 skipped) |
| Staging | **No-go** | No backend, auth or moderation; demo repositories only (`DemoAuthRepository`, in-memory profile) |
| Public release | **No-go** | The above, plus no release signing config (debug keys), no physical-device or TalkBack speech pass, no privacy or policy review |

## Tool-assisted pass (2026-11-05, continued)
### Tools: status and proof of use
| Tool | Upstream / version | Status | Scope | Proof of use |
|---|---|---|---|---|
| Impeccable | pbakaus/impeccable (project skill) | **Usable now** | project `.claude/skills/impeccable` | `impeccable context --target …discover_screen.dart` ran (it loaded PRODUCT.md and the surface brief). Critique Assessment A on device screenshots found the stacked floating row (FD-B2). Assessment B (detector and browser) is web-only, so not run on native Flutter. **Drift reported, not fixed:** PRODUCT.md still describes the web prototype (Fraunces/Inter) |
| Emil Kowalski skills | emilkowalski/skills `c8a7962`, MIT | **Updated** `emil-design-eng` to upstream (the project copy was older); the others are already present (animate, review-animations, improve-animations, break-ui, apple-design and more) | project | Review table below, which produced FD-B3. `mobile-native`, `choreograph` and `remove-animations` were not installed: web-specific or no target |
| accessibility_tools | rebelappstudio, **3.0.0**, MIT; Flutter ≥ 3.47, Dart ≥ 3.13 (compatible) | **Installed as a dev dependency only** (it depends on `flutter_test`, so it must never be imported from `lib/`) | `dev_dependencies` | `test/widget/a11y_tools_audit_test.dart` wraps the real app through the null-by-default `NumayaApp.debugWrapper` seam. Its checkers (semantic labels, tap areas, input labels, image labels) report **0 issues on 14 core routes**; a negative control proves they fire. A release APK builds without it |
| Widgetbook | widgetbook/widgetbook | **Covered by an existing equivalent** | — | The Design Lab (`/design-lab`) already shows every shared component and state, and the golden suite captures them at 320/390 and 100/200% text. A second catalog would duplicate it |
| Alchemist | Betterment/alchemist | **Covered by an existing equivalent** | — | The existing goldens already have bundled fonts, fixed data, sizes and text scales; this run's Windows-to-Windows review covered 191 goldens. No missing capability found |
| Forui | duobaseio/forui 0.27.7 | **Evaluated, not adopted** | — | It would add `forui`, `forui_lucide`, `sugar` and `ffi`, plus a second visual system; no component gap that Numaya's primitives cannot meet |
| Flutter agent plugin and Dart MCP | flutter/agent-plugins 1.0.7 | **Usable** (Dart MCP connected) | user | Analysis through the toolchain; runtime Inspector not attached (the emulator builds are installed APKs, not `flutter run` sessions) |

### Emil review (Flutter translation)
| Before | After | Why |
|---|---|---|
| Floating decision row: enter and exit both 220ms | Enter 220ms ease-out, exit 140ms | Exits quicker than entries; the row responds to scroll |
| Tab press `pressedScale: 0.92` | `0.95` | Subtle press feedback (0.95–0.98) |
| Sheets `sheetIn` slow / `sheetOut` base, drawer curve | Unchanged | Already asymmetric, on the iOS-like drawer curve |
| `Pressable` 0.98, pills 0.96, composer controls | Unchanged | In range; no decorative motion on frequent controls |

### Changes from this pass
| # | Surface | Evidence | Change | Test |
|---|---|---|---|---|
| FD-B2 | Discover while reading a profile | Impeccable critique of device `02`: the full-width labelled Pass/★/Like row stacked on the tab bar (about 190pt of the screen) | The floating variant becomes three 56pt circles, centred and icon-only, with labels in the tooltip and semantics. The inline row on the photo card is unchanged | `final_design_run_test` FD-B2 |
| FD-B3 | Floating row and tab bar motion | Emil review | Asymmetric exit (140ms); tab press 0.95 | covered by `motion_test` and the suite |

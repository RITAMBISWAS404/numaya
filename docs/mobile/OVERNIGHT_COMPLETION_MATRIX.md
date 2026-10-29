# Overnight completion matrix

Status of the Flutter app after the overnight pass. It builds on
[MASTER_PRODUCT_COMPLETION_MATRIX.md](MASTER_PRODUCT_COMPLETION_MATRIX.md), which keeps the full per-flow
table; this file records what changed and what remains.

- **Branch:** `experiment/numaya-overnight-completion`, from `experiment/numaya-complete-product` @ `103daa0`.
- **Restart:** run `git log --oneline -8`, then continue from "Next actions" at the end.

## Counting rules

These are the same as the master matrix:
- A **screen** is a route, a full-screen step or a sheet with its own purpose.
- Loading, empty, error and success are **states** of their screen, never extra screens.
- A **flow** is a journey from entry to exit.

## Totals

| Group | Screens | Complete | Partial | Deferred | Out |
|---|---|---|---|---|---|
| Reference catalogue B-01–B-77 | 69 | 53 | 5 | 6 | 5 |
| Events EV-01–EV-13 | 13 | 13 | — | — | — |
| Profile & visibility | 2 | 2 | — | — | — |
| Numaya-only (13 before, **+3 this pass**) | 16 | 16 | — | — | — |
| **Total** | **100** | **84** | **5** | **6** | **5** |

The three new screens are all complete:
- attachment menu (sheet);
- voice-note recorder (sheet);
- full-screen photo viewer for chat photos.

| Flows | Total | Complete | Partial | Out |
|---|---|---|---|---|
| F1–F29, EF-1–EF-4, AF-1, SF-1–SF-3 | 37 | 30 | 5 (F15, F20, F21, F28, SF-1) | 2 (F6, F24) |

Flow counts are unchanged. F4 (photos) and F15 (chat) gained real functionality within their existing
status. F15 stays Partial because videos can't be played and voice notes carry no sound in this build.

## What changed, by ID

| ID | Before | After this pass | Status |
|---|---|---|---|
| F15 / B-44 Chat | Text only | **Photos and videos from the phone** (Photo Picker) with caption, preview, remove, full-screen photo view; video as a file card; **voice notes from a labelled demo recorder**; attachments queue offline like text; inbox names attachments; failures explained | Partial (video playback, voice audio and delivery need plugins or a backend) |
| F4 / B-15 Photos | Placeholder tiles only | **Real photos from the phone or camera** for sign-up and Edit profile; replace keeps the place; placeholder kept where no picker exists | Complete |
| F8 Edit profile, Profile tab, Preview | Placeholders | The main photo is the Profile avatar; Preview and profile sections show the member's photos | Complete |
| EF-1 / EF-3 Events empty states, AF-1 not enough data | Bare icons or a banner | Illustrated empty states (3 new mobile scenes) | Complete |
| Toast (shared) | Long messages overflowed | Wraps | Fixed |
| Action sheet (shared) | Overflowed with six actions at 150% text | Scrolls; rows grow with text | Fixed |
| Chat composer area | Overflowed on a small phone with large text and the keyboard up | Capped at 55%, scrolls beyond; demo note hides while typing | Fixed |
| Paywall plan card | Title and tag overflowed at 200% | Tag wraps | Fixed |
| Pending attachment (a11y) | Remove merged into the description node | Separate nodes | Fixed |

## Previously recorded QA items, re-checked

| Item | Found | Action |
|---|---|---|
| RR-1 tab and date rows inside the gutter | Fixed in the complete-product pass | Still fixed (captures v01, v12) |
| RR-2 cover badges touching the category mark | Fixed in the complete-product pass | Still fixed (r03) |
| RR-3 Likes grid 3:4 | Intentional (RD-10) | Kept |
| Header control geometry, app-bar backgrounds, toggle thumb shadow | As decided in RD-02, RD-03, RD-06 | No change needed (current captures) |
| Scrim with long names and missing job | Fixed in RQ-1 | Still covered by `refinement_layout_test` |
| Completion card | RD-15 | Unchanged |

## Remaining (not buildable honestly here)

| Item | Needs |
|---|---|
| Video playback in chat | `video_player` (native plugin; build unverifiable here) |
| Recording and playing voice notes | An audio recording plugin, an audio player and microphone permission |
| Delivering messages and media | A messaging service and storage |
| Photo crop (B-16) | A crop plugin, or a crop step from the upload service |
| Everything Deferred or Partial in the master matrix (splash, verify by call, causes, connected accounts, saving toggle, store, camera verification, real network detection) | As listed there |
| APK and device checks | The Android SDK host returns 403 here |

## Next actions

1. **Locally:**
   - `flutter build apk --debug`, the first build that includes `image_picker`;
   - try the Photo Picker and the camera on a phone.
2. **Product decision:** whether to add `video_player` and audio recording, so that video plays and voice
   notes are real.
3. **Visual polish when a designer is available:** see [ILLUSTRATION_BACKLOG.md](ILLUSTRATION_BACKLOG.md).

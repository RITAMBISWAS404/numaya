# V9 implementation report

Branch `version-9`, created from V8 (`47ba247`, tagged `checkpoint/v8-baseline-20261112`). V7 (`checkpoint/v7-selected-baseline-20261111`, `b5e5245`) and V8 (`version-8`) are untouched.

## What changed

### Foundations
- **Type:** back to Plus Jakarta Sans headings and Figtree text (D-01). Welcome uses the hero role; tab titles use the page title role.
- **Radii:** back to the V7 scale (D-02), with pill chips, segments and navigation.
- **Spacing:** card padding is 20 to match the gutter (D-11).
- **Separators:** one `NumayaDivider` replaces seven hand-built hairlines (D-06).

### Components
- **`StatCard`** is the single-column information card: icon and heading, value, one line, visual, art at the side (D-04). It replaces `InfoTile` and `InfoTilePair`, which are removed.
- **`PhotoScrim`** now takes the photo as `sample`, and `PhotoLuma` measures it (D-03). It is wired on Discover, the full profile, Match, the Likes grid and the member's cover.
- **`TabFadeStack`** is the tab container: state is kept and the selected tab fades in (D-09).
- **`InfoCard`** (the callout) has a plain chevron instead of the grey disc (D-07).

### Screens
- **Profile:**
  - Your activity is two stacked `StatCard`s (credits with the heart art; streak with a flame that grows with the streak).
  - The setup card is a `StatCard` with a progress ring and no inner button (D-05).
  - Duplicates are removed (D-12).
- **Messages:** dividers are near full width, and the avatar carries into the conversation header (Hero).

## MVP simplification

| Class | Items |
|---|---|
| Core | Discover, profiles, likes, Compliments as conversations, matches, chat, onboarding, profile editing, safety (report, block, unmatch) |
| Supporting | Premium, Compliment credits, settings, help, verification |
| Secondary | Streaks (kept as one card on Profile), archive, search, voice notes |
| Experimental (behind `NUMAYA_DEV_TOOLS`) | Design Lab, Visual Lab, Experiment Lab, demo controls; Events and Health stay deferred |
| Redundant, now removed | Profile bar's Help button (a row on the same page), the Profile Settings row (the bar's gear), the Profile prompt card (repeated from Edit profile and Preview), `InfoTile`/`InfoTilePair` (replaced), the V8 serif and Google Sans registrations |

Nothing was removed from the router, the data model, or a user journey. Every removed entry point has another on the same screen.

## Messaging and Compliments

- V8's model is unchanged and verified again by the tests:
  - A Compliment is the first message of its conversation.
  - `/request/:id` (the notification link) opens `/chat/:personId`.
  - Replying in place turns the same route into the chat.
  - One conversation per person: a pending Compliment and its later thread share the person's id, and `convertOnMatch` moves the Compliment into the thread.
- V9 adds:
  - The shared avatar.
  - The single divider rule in the list.
- No read or delivery ticks are shown: no backend reports them.

## Motion

- **Added:** the tab fade (200ms ease-out, instant under reduced motion) and the chat avatar hero.
- **Already in place and kept:**
  - Press feedback on touch-down.
  - Route pushes on the emphasized curve, with quicker returns.
  - Sheets that rise and leave quicker.
  - Messages that settle in.
  - The scene art's 600ms state change.
- **Skills used:** `apple-design` was read and applied. No "ML Coval" skill is installed.

## Verification

- **`flutter analyze`:** one older deprecation info in a test file.
- **`flutter test`:** 639 passed, 42 skipped (unchanged from V8), 0 failed. No tests were disabled. Five tests that encoded replaced decisions were updated, and one test was added for the adaptive scrim.
- **Emulator (Pixel 10 AVD):**
  - 210 screens through the full capture harness, 0 skipped. This includes onboarding, Discover, Likes, sending a Compliment, the Compliment conversation and Not now, chat states, Profile, editing, wallet, Premium, Settings, help and account states.
  - 19 key screens at font 1.5, at font 2.0 and at 360 dp, 0 skipped.
- **APK:** `build/v9/namaya-v9.apk`, 63,385,965 bytes, SHA-256 `127c802c…536f`.
  - Release mode, signed with the debug key (no release keystore is configured).
  - Installed and launched to Welcome with no crash.
- **Not run:**
  - Web checks: no web change.
  - Physical phone, iOS, screen reader.
  - Hand-driven journeys on the release build.

## Known limitations

See [REMAINING_WORK.md](../agent-handoff/REMAINING_WORK.md).

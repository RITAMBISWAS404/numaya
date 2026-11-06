# Ente reconstruction: route tracker

This file is the checkpoint for the reconstruction pass ("ER"). It covers every route in `lib/app/routes.dart` (57) and the sheets that open from them.

## Status key

**Structure (S):**
- **R:** the layout was rebuilt on the Bumble structure in this pass.
- **C:** restyled through the shared Ente components (pass 1), with the layout kept because it already follows Bumble or Numaya's own feature.
- **B:** blocked, with the reason given.

**Evidence (E):**
- **D:** inspected on the Pixel 10 emulator, with screenshots in `artifacts/ente-design-system/device/`.
- **H:** rendered in the test harness at 320 to 430pt and 100 to 200% text (`size_matrix_test`, `route_sweep_test`, `overnight_stress_test`).
- **I:** the interaction was exercised (widget tests or device taps).

## Bumble references actually inspected (Mobbin, iOS)

| Flow | Mobbin |
|---|---|
| Discovery card | [Filtering people](https://mobbin.com/flows/5c103e1e-0dec-43ab-9a52-00ea0e904b3a) screens 1, 3 and 4; discovery screens [ee54d57a](https://mobbin.com/screens/ee54d57a-33f7-4f05-ba27-012f9f74eb48) and [83e93b49](https://mobbin.com/screens/83e93b49-e15d-462c-ae89-810a4613cea0) |
| Filters | [Filtering people](https://mobbin.com/flows/539ac528-7029-49e9-8636-3d2b4b12a5c0) (basic, advanced, add-filter sheet) |
| Chats | [Chats](https://mobbin.com/flows/77f54cb8-94a6-4692-8e2e-97f03a11bd8c), [Chats](https://mobbin.com/flows/5bbf1e91-e139-422f-a958-077c246c336f), [Searching a chat](https://mobbin.com/flows/c794b521-8421-4531-b693-9d517ad9658e) |
| Liked You | [ee33fda3](https://mobbin.com/screens/ee33fda3-1add-46fd-8c57-855f48f89c87) |
| Profile editing | [fc35bf13](https://mobbin.com/screens/fc35bf13-823e-4331-a922-4882f5d67e7a); interests [ff63ca32](https://mobbin.com/screens/ff63ca32-0913-418e-876d-120f3481074f) |
| Onboarding | [Completing account setup](https://mobbin.com/flows/795ff2ae-e5a9-4684-a24c-cdd2ea4bce63) (interests, relationship choice) |

**Not inspected:** Bumble's own Profile tab, settings, safety and report flows, and premium. Those routes follow Ente components only, and nothing below claims Bumble fidelity for them.

## Reconstruction decisions

- **ER-01: Discovery** ([Filtering people](https://mobbin.com/flows/5c103e1e-0dec-43ab-9a52-00ea0e904b3a) screens 1, 3 and 4).
  - **Bumble structure:**
    - the photo card fills the screen;
    - the name, age, verified tick and job sit on the photo;
    - "things in common" is a white card inside the photo;
    - a control sits on the photo's top-right corner;
    - the wordmark is on the left, the controls on the right;
    - the details scroll beneath as cards.
  - **Ente parts:**
    - a 24pt-corner card;
    - a circular Icon Button for options;
    - a radius-16 white card with Mini/Body text;
    - Icon Buttons in the header.
  - **Numaya keeps:**
    - visible Pass, SuperSwipe and Like controls, so swiping is never the only way;
    - the For You entry;
    - undo;
    - the photo count and badges;
    - Report or block at the end.
  - **What it replaced:**
    - the white hero container;
    - the inline decision bar;
    - the coach card;
    - the sample note at the end;
    - the centred wordmark.
  - **Adaptation:** the decision row is a permanent floating row under the photo, where Bumble shows only a SuperSwipe button. Without it, Numaya would rely on swipes alone.
- **ER-02: Liked profile and person profile.** Same card as ER-01, and the repeated sample note is removed.
- **ER-03: Chats** ([Chats](https://mobbin.com/flows/77f54cb8-94a6-4692-8e2e-97f03a11bd8c), [Searching a chat](https://mobbin.com/flows/c794b521-8421-4531-b693-9d517ad9658e)).
  - **Search:** it sits behind a header icon and opens with Cancel, replacing the permanent field.
  - **List labels:** "New matches (3)" and "Conversations" are small headings (Large, 16/20), not page sections.
  - **Numaya keeps:** the All, Unread and Your move chips, and the countdown rings.
- **ER-04: Likes.** The lede is removed; the title and counted chips carry it.
- **ER-05: Profile tab.** The 2×2 tile grid becomes Ente Menu Item rows with the status as the subtitle. The caption under the prompt is removed.
- **ER-06: Filters** ([Filtering people](https://mobbin.com/flows/539ac528-7029-49e9-8636-3d2b4b12a5c0)). Each question is a small heading over one outlined card holding its control and its "if I run out" switch.
- **ER-07: Chat.** The demo notice is cut to one line saying replies are scripted and nothing leaves the device. It stays, because it tells you whether a message was actually sent.

## Routes

| Route | Flow | S | E | Notes |
|---|---|---|---|---|
| `/home` Discover | Discovery | R | D H I | ER-01. Swipe, buttons, undo, profile scroll and back-to-top tested |
| filters sheet | Discovery | R | D H I | ER-06. Apply, reset and fallback tested |
| `/for-you` | Discovery | C | H | |
| `/person/:id` | Profile inspect | R | H | ER-02 |
| `/person/:id/photos` | Profile inspect | C | H | |
| `/likes` | Likes | R | D H I | ER-04 |
| `/like/:id` | Likes | R | D H I | ER-02 |
| `/match/:id` | Match | C | H I | Single-photo match, already Bumble-led |
| `/messages` | Chats | R | D H I | ER-03 |
| `/chat/:id` (+ attachments, safety sheets) | Chat | C | D H I | ER-07. Ente bubbles and composer |
| `/profile` | Own profile | R | D H I | ER-05 |
| `/profile/edit`, `/basics`, `/interests`, `/photos`, `/prompt` | Editing | C | H I | Already label-and-value rows and chips (Bumble [fc35bf13](https://mobbin.com/screens/fc35bf13-823e-4331-a922-4882f5d67e7a), [ff63ca32](https://mobbin.com/screens/ff63ca32-0913-418e-876d-120f3481074f)) |
| `/profile/complete`, `/preview` | Own profile | C | H | |
| `/profile/opening-moves` | Own profile | C | D H I | |
| `/profile/verify` | Safety | C | H I | |
| `/profile/premium`, `/paywall` | Premium | C | D H | |
| `/profile/safety` | Safety | C | D H | |
| `/profile/settings` (+ blocked, notifications, privacy, delete) | Settings | C | D H I | Ente Menu Item cards |
| `/profile/visibility`, `/about` | Settings | C | H | |
| `/events`, `/event/:id`, `/event/new` | Events (Numaya) | C | D H I | |
| `/help`, `/help/:id`, `/help/contact` | Support | C | H | |
| `/`, `/phone`, `/verify` | Onboarding | C | D H I | |
| `/setup` and 16 setup steps | Onboarding | C | H I | Bumble's onboarding is one question per page with a round next button; Numaya's steps already match that |
| `/restore`, `/sign-in-again`, `/account-blocked` | Recovery | C | H I | |
| `/demo`, `/design-lab` | Development | C | D H | |

**Counts:** 57 routes inventoried.
- **Rebuilt:** 7 surfaces (Discover, filters, person, likes, like, messages, profile).
- **Restyled through shared components:** all the rest. None is blocked.
- **Seen on device:** 17 screens per journey, plus the 320dp/150% pass.
- **Rendered in the harness:** every route.

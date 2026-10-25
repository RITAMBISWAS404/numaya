# Numaya: full-app refinement with Apple Design + Impeccable

Every implemented Numaya screen was refined with Apple Design + Impeccable, the approach the
[skill-combination matrix](../skill-combination-matrix/README.md) found strongest.

- **Branch:** `design/apple-impeccable-full-app`. It starts from `75b095c`, whose product code is the
  Apple-only `6e4dbd1`.
- **Coverage:** 28 distinct screens, 162 captured states. 106 states changed visibly. The other 56
  were reviewed and needed no change. [Inventory](screen-inventory.md).
- **Validation:** all of it passed:
  - unit tests 117/117 and the production build;
  - smoke e2e 144/144 and product e2e 88/88;
  - axe accessibility, with no serious or critical issues;
  - Impeccable's detector, with 0 findings.

  [Validation report](validation-report.md).
- **What changed:** [design-system-changes.md](design-system-changes.md). Progress log:
  [progress.md](progress.md).

## What changed, in one paragraph

The refinement lives in the shared system, so the whole app moves together. **Purple owns the primary
action:** every primary button and step arrow is flat brand purple, where most were ink before; Pass
and Like stay ink. **The conversation is the signature:** prompt answers become a lavender pull-quote
object, and "You both like" uses the same lavender everywhere. These are the two things matches
actually talk about. **The match moment shows the pair and what you share**, from real data. **No
kicker labels sit above headings.** Scrim contrast, heading order, row alignment and the destructive
style for Unmatch were all fixed. Brand rules held throughout: Fraunces and Inter, plain-ink
headlines, no invented photos or illustrations, and no glass or second accent.

## Before and after

The left image of each pair is the Apple baseline. The right is this branch. Every number is the
capture's gallery number.

| | |
|---|---|
| ![Welcome](screenshots/comparisons/001-welcome.png) | ![Profile setup](screenshots/comparisons/011-verified-intro.png) |
| ![Interests and prompt](screenshots/comparisons/016-interests-prompt.png) | ![Discover card](screenshots/comparisons/019-discover.png) |
| ![You both like](screenshots/comparisons/021-discover-you-both-like.png) | ![Like back](screenshots/comparisons/059-like-profile.png) |
| ![It's a match](screenshots/comparisons/030-match.png) | ![Seen everyone (empty state)](screenshots/comparisons/025-discover-seen-everyone.png) |
| ![Unmatch sheet](screenshots/comparisons/045-chat-unmatch-sheet.png) | ![Activity Explore](screenshots/comparisons/061-activity.png) |
| ![Activity details](screenshots/comparisons/069-activity-detail.png) | ![My profile](screenshots/comparisons/099-profile.png) |
| ![Edit profile](screenshots/comparisons/102-edit-profile.png) | ![Premium](screenshots/comparisons/122-premium.png) |
| ![Connected accounts](screenshots/comparisons/124-connections.png) | ![Service unavailable](screenshots/comparisons/129-maintenance.png) |

## Every screen, final

The contact sheets show the final state of every screen and state. Each links to full-size captures
in [screenshots/final](screenshots/final/README.md). The baseline set is in
[screenshots/baseline](screenshots/baseline/README.md), with the same numbering.

### Onboarding
![Onboarding, final](screenshots/final/contact-sheets/01-onboarding.png)

### Home: profiles and filters
![Home, final](screenshots/final/contact-sheets/02-home-profile-filters.png)

### Likes, matches and messages
![Likes, matches and messages, final](screenshots/final/contact-sheets/03-likes-matches-messaging.png)

### Activity
![Activity, final](screenshots/final/contact-sheets/04-activity.png)

### Profile, readiness, settings and account
![Profile and account, final](screenshots/final/contact-sheets/05-profile-settings.png)

### Small phone (375 × 667)
![Small-phone QA, final](screenshots/final/contact-sheets/07-qa-375.png)

### Desktop context
![Desktop context, final](screenshots/final/contact-sheets/06-desktop.png)

The canonical project gallery, [artifacts/ui-gallery](../ui-gallery/README.md), was regenerated with
`npm run gallery` and matches the final set. Before this run it still showed the original `7954fa3`
design.

## Method

- **Skills:** only **Apple Design** (`.claude/skills/apple-design`) and **Impeccable**
  (`.claude/skills/impeccable`, 4.7.1) were used. Liquid Glass, UI/UX Pro Max and the other installed
  skills were not.
- **Impeccable inputs:**
  - `impeccable context`, with `PRODUCT.md` from the confirmed `init` answers.
  - Its critique of the Apple baseline (26/40 with three P1 findings; see
    [the critique](../skill-combination-matrix/skill-output/impeccable-critique-apple-baseline.md)).
  - The polish and operate playbooks and the craft floor.
  - The `detect` scan.

  Its interview step was replaced by the brief, because the brief asked for no questions.
- **Apple Design** supplied the principles behind each decision: one clear primary action per screen
  (purpose, simplicity), consistent treatment of the same concept everywhere (familiarity), a
  destructive style for irreversible actions, and restraint over decoration.
- **Screenshots:** every capture comes from the running app, using the project's gallery tool. A new
  `GALLERY_OUT` override writes review copies without touching the canonical gallery, and
  `scripts/gallery-compare.mjs` builds the side-by-side sheets.

## Known issues and limitations

- **No real photography or illustration artwork exists.** Photos are honest grey placeholders. The
  Welcome hero is a reserved slot that a smoke test intentionally keeps empty. The match "hands
  forming a heart" artwork is also unsupplied.
  Both limit how premium Discover and Welcome can look, whatever the styling.
- **Only Chromium was available.** WebKit and Firefox were not tested.
- **Some screens are unchanged.** Messages list, Likes grid, Settings, Readiness and Help needed no
  change: no primary actions, no prompts, and nothing the critique flagged. They are listed as
  inherited, not as redesigned.
- **Product decisions that were not taken:** the duplicated interest count on Interests (spec copy),
  and lavender on openers or the "Your move" tag (it would dilute the two conversation hooks). See
  [design-system-changes.md](design-system-changes.md#considered-and-rejected).
- **Decision D-22** in the [decision log](../../docs/research/decision-log.md) supersedes the
  "ink CTAs" part of D-21. Product should confirm it, since it changes a documented decision.

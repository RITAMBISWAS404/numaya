# Next steps

> **2026-11-07 (after MVP PRD v1), queue:**
> 1. Owner review of the MVP APK and gallery; decisions MVP-D07/D08/D18/D24/D25.
> 2. Backend: provision the project, apply and test `backend/migrations`, then wire `NumayaApi`
>    (LIVE_BLOCKERS 1-3).
> 3. Store products and verification Edge Functions only after price validation (LIVE_BLOCKERS 4).
> 4. Localise the sample people for the India pitch demo; coarse device location.
> 5. Environment: `git config core.autocrlf input` (web checks), `npx playwright install chromium`.

> **2026-11-07 (account switch), current queue:**
> 1. Wait for the owner's feature brief; prepare the revised PRD with them (no feature building first).
> 2. Owner decisions: SW-01 off-switch contrast; EXP-001–004; UI-001 artwork; UI-008 phrase; which
>    branch becomes the shipping line.
> 3. Device checks: physical phone; Visibility, Premium, Help, delete-account sheet; font size 2.0;
>    three-button navigation; "The basics" at 320dp; onboarding after Photos.
> 4. Environment: `npx playwright install chromium` for e2e; CRLF-safe `npm run check`; regenerate goldens.
>
> The list below is older and kept for history.


1. **Owner review** of `experiment/numaya-final-ux-polish`:
   - Install the debug APK (VALIDATION.md has the commands).
   - Or read the before/after sheets in
     `docs/design-experiments/numaya-final-ux-polish/evidence/`.
2. **Web checks on this machine:**
   - Either run `git config core.autocrlf input` and re-checkout, or run the checks in WSL or
     CI, so `npm run check` compares LF with LF.
   - Run `npx playwright install chromium`, then `npm run test:e2e`.
3. **Physical Android phone pass** (install `Numaya-final-debug.apk` from the Desktop folder, Samsung Android 12 first): haptics on swipe and match, the tab pill over the gesture bar,
   real fonts.
4. **Long-name Match check:** add a sample person with a 25+ character name, or a test seam for
   `personById`, and render `/match/<id>` at 320pt and 200% text.
5. **Merge decision:** if approved, merge into the shipping line. If the separate Impeccable work
   (`design/apple-impeccable-full-app`, and the uncommitted `experiment/impeccable-visual-refinement`
   files the brief mentions, which are not on this machine) is still wanted, compare it with this
   branch first.

## Later
- **Demo photography** for Discover, Match, Likes and events (FP-05 and the image-first card are
  built for it).
- **The Numaya mascot:** commission it per
  [ILLUSTRATION_ASSET_BACKLOG.md](../design-experiments/numaya-final-ux-polish/ILLUSTRATION_ASSET_BACKLOG.md).
- **Remove `ScallopPortrait`** if nothing adopts it.
- **Backend dependencies.** Everything below is simulated locally today:
  - auth and SMS codes;
  - the profile store and photo upload;
  - matching and the likes queue;
  - messaging and media;
  - push notifications;
  - location;
  - photo verification review;
  - reports and blocks moderation;
  - premium billing;
  - events and RSVPs.
- **Choose a production framework** ([architecture](../engineering/architecture.md)).

# Screen-level specifications (reference)

These are specifications of the reference behaviour, written so a Numaya screen can be built from
them. Each entry lists purpose, regions (top to bottom), inputs and actions, rules, states, and
the Numaya mapping: the components from [`../design-system/components.md`](../design-system/components.md)
and any deliberate deviation recorded in the [decision log](decision-log.md).

Evidence tags as in [README](README.md#evidence-legend). Unless tagged otherwise, a line is [O].

---

## Account and verification

### B-02 Welcome
- **Purpose:** choose between creating an account and signing in. First brand moment.
- **Regions:** brand mark and wordmark (centre) · primary action *Create an account* · secondary
  text action *I have an account* · legal copy with *Terms* and *Privacy Policy* links.
- **Rules:** no form fields. Legal acceptance is implied by continuing.
- **States:** default only. Links open in-app browser [I].
- **Numaya:** implemented. `Button` primary + quiet, legal `Link`, prompt-card hero (original).

### B-04 Phone number
- **Purpose:** collect a phone number to verify the person is real.
- **Regions:** back · title "Can we get your number, please?" · lede (why) · row: *Country*
  selector (ISO code and dial code) + *Phone number* field · footer: lock icon + reassurance
  ("never shared, not on your profile") · circular next.
- **Inputs:** numeric keypad, auto-focused. The country selector opens B-05.
- **Rules:** next is disabled until the number is complete for the selected country. Changing
  the country trims the digits to the new length [I].
- **States:** empty · typing · valid (next enabled) · submitting (floating "Loading" pill, input
  locked) · error (invalid / blocked number) [U].
- **Numaya:** implemented. `PhoneField`, `CountrySheet`, `Fab`, `Reassurance`, `Toast` (busy).

### B-07 Verify code
- **Purpose:** prove possession of the number.
- **Regions:** back · title · lede naming the destination number · *Change number* link · label
  *Code* · 6 cells · footer *Didn't get a code?* + circular next.
- **Variants:** SMS code (B-07a) · call-based "last 6 digits of the number we called you from",
  with a fixed prefix cell (B-07b).
- **Rules:** auto-submits on the 6th digit with a "Loading" pill. *Change number* returns to B-04
  with the number kept. Paste and one-time-code autofill are supported by iOS [I].
- **States:** empty · partial (active cell highlighted with a thicker underline) · checking ·
  error [U] · resend cooldown [I] · success → next step.
- **Numaya:** implemented. `CodeInput`, `Toast`, `Notification` (demo), resend countdown, error
  shake, success sheet.

### B-08 Tracking pre-prompt
- **Purpose:** explain tracking before the system ATT dialog appears [I].
- **Regions:** illustration · title "Let's make this about you" · explanation · *Continue* ·
  footnote with a privacy-policy link.
- **Numaya:** generic `PermissionPrimer` pattern (see design-system patterns). Numaya does not plan
  ad tracking. Whether this screen exists at all is an open product decision
  ([unknowns](unknowns.md#product-decisions)).

### B-03 Sign-in methods (returning)
- **Regions:** back · logo · "You last signed in with a cell phone number" · stacked full-width
  buttons: Quick sign in, Apple, Facebook, phone · legal.
- **Rules:** the last-used method is surfaced first.
- **Numaya:** the prototype routes *I have an account* straight to the phone step with sign-in copy.
  Apple and Google sign-in are an open decision.

---

## Profile creation

### B-10 Intro: name and birthday
- **Regions:** progress bar · title · *Your first name* field · *Your birthday* Month / Day / Year
  fields · helper copy.
- **Rules:** a numeric pad for the date fields, with auto-advance between them [I]. The age gate
  (18+) is enforced here [I].
- **States:** empty · partial · invalid date [U] · underage [U].
- **Numaya:** `TextField`, `DateField` (segmented), `ProgressSegments`, `Fab`.

### B-11 / B-12 / B-13 Gender
- **B-11:** title personalised with the entered name · radio cards (Woman, Man, Nonbinary) · the
  selected card expands *Add more about your gender* · info note with a link.
- **B-12:** sheet with back · list of more specific identities (radio) · *Tell us if we're missing
  something* > · *Save and close*.
- **B-13:** "Want to show your gender on your profile?" · chips choosing which label shows ·
  *Show on profile* switch.
- **Rules:** the specific identity is optional. Visibility is a separate, explicit choice.
- **Numaya:** `OptionCard` (radio), `Sheet`, `Chip` (single select), `Switch`.

### B-14 Mode choice
- Option cards with title and description. A visibility note in the footer explains that people
  only see others in the same mode.
- **Numaya:** dating only at launch, so the step is omitted ([decision D-08](decision-log.md)).

### B-15 / B-16 Photos
- **B-15:** title · requirement copy "Add at least 4 photos" · 3×2 grid: empty slots (+), filled
  slots with remove (×), the first slot labelled *Main* and others numbered · "Hold & drag to
  reorder" hint · *photo tips* link · next (disabled until the minimum is met [I]).
- **B-16:** dark crop screen · crop frame with a rule-of-thirds grid · thumbnails of the photos
  picked in this batch (check on the current one) · *Upload*.
- **States:** empty slot · uploading [U] · uploaded · rejected (policy, face not detected) [U] ·
  reorder drag.
- **Numaya:** `PhotoGrid`, `PhotoSlot`, `Sheet` (source picker), crop as a full-screen pattern.

### B-17 / B-18 Interests and causes
- Title with a quota ("Choose 5…", "up to 3") · search field · suggested chips · chips toggle
  selected · footer: *Skip* + counter "N/5 selected" + next.
- **Rules:** a hard maximum; extra taps are ignored once the quota is reached [I]. Skip is
  allowed.
- **Numaya:** `Chip` (multi), `SearchField`, `SelectionCounter` in the footer.

### B-20 Intentions
- Sheet with progress, icon, question "What do you want from your dates?", "choose 1 or 2",
  checkbox option cards, *Save and close*.
- **Numaya:** `OptionCard` (checkbox) with a max-selection rule.

### B-21 Profile completion hub
- "55% complete" · title · 2×2 tiles: illustration + section name + "N of M added".
- **Rules:** each tile opens its section editor. Percentage completion is also shown on the
  profile avatar ring (B-23).
- **Numaya:** `CompletionTile`, `ProgressRing`.

---

## Profile management

### B-23 Profile tab
- Avatar with completion ring and percentage badge · *Complete profile* / *Edit profile* chip
  button · help (?) and settings (gear) icon buttons · segmented tabs (*Pay plan*, *Photo
  insights*, *Safety and wellbeing*) · content per tab · tab bar.
- **Numaya:** `Avatar` + `ProgressRing`, `IconButton`, `SegmentedControl`, `TabBar`.

### B-24 / B-25 Edit profile
- A long scroll of grouped sections, each with a heading and helper line:
  - Photos and videos (grid) · *Best Photo* (On/Off >) · *Verify my profile* (Verified).
  - Interests card (favourite interest + chips >) · causes · qualities (chips >).
  - Prompts (question + answer, removable).
  - Bio (textarea + tip card).
  - About you rows: icon, label, value or *Add*, chevron (work, education, gender, location,
    hometown).
  - More about you rows (height, exercise, star sign, education level, drinking, smoking,
    looking for, family plans, kids, religion, politics) with "How we use this information".
  - Languages chips · connected accounts.
- **Editing:** text edits happen inline with a keyboard accessory bar (*Cancel* / *Save*).
  Attribute rows open pickers [I]. No global save; changes persist per field [I].
- **Numaya:** `ListRow` (value + chevron), `Section`, `TextArea` with counter, `TipCard`,
  `ChipGroup`, `PromptCard` (editable).

### B-27 Opening Move editor
- Prompt label · large textarea with placeholder question · footer *Cancel*, "160 characters left",
  *Save* (disabled when empty).
- **Numaya:** `TextArea` with `CharacterCounter`, sheet footer actions.

---

## Discovery

### B-30 / B-32 People stack and expanded profile
- **Header:** logo · undo (Backtrack, premium) · filters icon.
- **Card:** full-bleed first photo · photo-progress segments at the top · share button · bottom
  overlay: name and age, verified badge, job and education, chips (New here, Photo verified),
  "We have things in common" chip group · note button (send a message with the like) · ★
  SuperSwipe FAB.
- **Gestures:** swipe right = like · left = pass · tap left/right edges = previous/next photo [I] ·
  vertical scroll = expanded profile.
- **Expanded profile:** sections (location, lives in, prompts, music) · persistent action row:
  pass × · ★ · like ✓ · *Hide and Report* · *Recommend to a friend*.
- **States:** loading next card [U] · coach mark on first use · out of profiles [U] · paywall when
  a premium action is used.
- **Numaya:** `DiscoveryCard`, `PhotoProgress`, `ActionBar` (pass / like / super), `Badge`
  (verified), `ChipGroup`, `CoachMark`.

### B-33 Curated Discover
- Title · countdown pill "See new people in N hours" · rationale line · horizontal carousel of
  portrait cards (photo, name, age, verified, heart) · note "Based on your profile and past
  matches".
- **Numaya:** `Carousel` of `ProfileTile`, `Pill` (countdown).

### B-34 / B-35 Filters
- Full-screen modal: close × · title "Narrow your search" · segmented *Basic* / *Advanced* · scroll
  of filter cards · sticky *Apply*.
- **Filter card anatomy:** question label · current value summary · control (dual range slider,
  single slider, checklist, chips, disclosure row) · optional fallback switch ("Show other people
  if I run out" / "See people 2 years either side").
- **Rules:** the fallback switch is disabled until the filter has a value. Advanced filters start
  collapsed as "Add this filter +" rows that open a sheet. Some advanced filters are premium [I].
- **Numaya:** `FilterCard`, `RangeSlider`, `Slider`, `Checkbox` list, `Switch`, `ListRow`
  (add-filter), `SegmentedControl`, sticky `Button`.

---

## Matching and chat

### B-40 / B-41 Match
- Close × and ⋯ · two overlapping tilted photos with a centre badge · title "What a match!" · timer
  copy · optional "Your Opening Move" card · composer pinned to the bottom · coach tooltip on first
  match.
- **Rules:** typing and sending opens the conversation. Closing returns to the stack and the match
  appears in the queue.
- **Numaya:** `MatchCelebration` pattern, `Composer`, `Tooltip` (coach).

### B-42 / B-43 Inbox
- **B-42:** title + search · "Your matches (N)" horizontal queue: avatars with countdown rings, a
  liked-you stack tile with count · "Chats" list rows: avatar, name, last message preview, "Your
  move" tag, unread or ring indicator.
- **B-43 empty:** liked-you teaser row · Opening Moves help card · illustration · "Connections
  start here" · *Find your person* (returns to discovery).
- **Numaya:** `MatchQueue` + `Avatar` with `CountdownRing`, `ConversationRow`, `Tag`, `EmptyState`,
  `PromoCard`.

### B-44 / B-45 Conversation
- **Header:** back · avatar + name (opens profile [I]) · voice call · video call · ⋯.
- **Messages:** grouped bubbles, mine on the right (brand fill), theirs on the left (neutral) ·
  media (photo, GIF, video, voice note) · system rows (call log, "You called 00:10") · receipt
  ("Delivered") and time under the last outgoing message.
- **Composer:** camera · text field "Aa" · GIF · attachment/video · mic. Send replaces mic when text
  is present [I].
- **⋯ menu:** Share Date · Did you meet? · Unmatch · Report (destructive).
- **States:** sending [U] · delivered · read [U] · failed + retry [U] · other person unmatched [U] ·
  expired [C].
- **Numaya:** `MessageBubble`, `MessageGroup`, `SystemMessage`, `ReceiptLabel`, `Composer`,
  `ActionSheet`.

### B-46 Liked You
- Title + filter · chip tabs with counts · blurred cards (locked) · sticky CTA *See who likes you*
  → paywall.
- **Numaya:** `ChipTabs`, `ProfileTile` (locked/blurred), sticky `Button`. Whether this is
  premium is an open decision.

---

## Safety and verification

### B-50 – B-54 Report, block, unmatch
- **Report reasons (B-50):** sheet with back · title · anonymity reassurance · icon + label rows
  (fake profile, inappropriate content, scam or commercial, identity-based hate, off-app
  behaviour, underage, not interested).
- **Detail (B-51):** which part of the profile (photos or videos, profile text).
- **Confirmation (B-52):** success icon · "You've blocked and reported [name]" · follow-up promise
  (Help Hub) · *Done*.
- **Unmatch (B-53):** consequence list with icons · nudge card "Think they've broken our
  guidelines?" · *Unmatch* (primary) · *Report instead* (destructive text).
- **Rules:** reporting always blocks. Neither action notifies the other person ("they won't know").
- **Numaya:** `ActionSheet`, `Sheet` with `OptionList` (icon rows), `ResultPanel` (success),
  `ConsequenceList`, destructive `Button`.

### B-56 / B-57 Photo verification
- **Prompt sheet:** sample photo with badge · "Show them it's really you" · explanation · *Let's
  get verified*.
- **Capture:** camera with flash and flip · shutter · close · thumbnail of the pose to copy
  (randomised gesture).
- **Review:** automated and human review, result within minutes [C]. Failure is most often a pose
  mismatch; retry or contact support [C].
- **Numaya:** `PermissionPrimer` (camera), `VerificationPrompt`, capture as a full-screen pattern,
  `StatusBanner` (pending / approved / rejected), `VerifiedBadge`.

---

## Premium

### B-60 – B-64 Pay plan, paywall and purchase
- **Paywall (B-61):** close · tier tabs · info · feature carousel (icon or illustration, title,
  one-line benefit, page dots) · plan cards in a horizontal row: duration, total price, per-week
  price, discount tag, "Most popular" ribbon, selected state · auto-renew and legal copy · CTA
  repeating the selected plan and price.
- **Success (B-62):** system alert. **Active (B-63):** "Active until [date]" on the plan card.
- **Comparison (B-64):** feature rows × tier columns with check marks and info buttons.
- **Restore:** *Restore purchases* in settings.
- **Numaya:** `PlanCard`, `FeatureCarousel`, `ComparisonTable`, `LegalText`, `ResultPanel`.

---

## Settings and lifecycle

### B-70 – B-74 Settings
- Modal with *Cancel* / *Done* · grouped rounded rows: navigational (label + value + chevron),
  switch rows with consequence copy below, a premium-locked row (lock icon) · destructive and
  account actions at the bottom (*Restore purchases*, *Log out*, *Delete account*) · version
  footer.
- A switch row shows a spinner while saving (B-73).
- **Snooze (B-71 / B-72):** action sheet to set an away status → the row changes to "Deactivate
  snooze mode" with remaining time. Durations: 24 h, 72 h, a week or indefinitely [C]. Matches
  without active chats can still expire [C]. Subscriptions are not paused [C].
- **Notifications (B-74):** per-category switches by channel (push, in-app, email), with a warning
  line and the email address on file.
- **Delete (B-75) [C]:** Settings → *Delete account* → reason → confirm. Cancel any subscription
  separately. Restorable for 28 days.
- **Numaya:** `SettingsGroup`, `ListRow` (navigation / switch / destructive / locked), `ActionSheet`,
  `ConfirmDialog`, `Switch` with pending state.

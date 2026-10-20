# Flow catalogue and screen inventory

Bumble Dating, iOS. Evidence tags: [O] observed, [C] official, [I] inferred, [U] unverified
(see [README](README.md#evidence-legend)).

Screen IDs (`B-…`) are ours. They are used across the research docs, deduplicate repeated
structures, and map each reference screen to the Numaya pattern that covers it.

## 1. Flow catalogue

| # | Flow | Mobbin flow(s) | Entry point | Exit | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | First-run account creation (phone) | [Onboarding, 11 screens](https://mobbin.com/flows/210aeea2-40d3-40ba-bb1b-49894c6d3122) · [Onboarding, 20 screens](https://mobbin.com/flows/42730eed-79ec-4019-91b2-c65cdef86851) | Cold start → Welcome | Verified number → tracking pre-prompt → profile basics | [O] |
| F2 | Returning sign-in | (screen) [Sign-in methods](https://mobbin.com/screens/88c589c0-5723-4c23-bb4c-08febbc1a87d) | Welcome → *I have an account* | Home (People) | [O] |
| F3 | Profile basics (name, birthday, gender, mode, email) | [Setting up my account, 44 screens](https://mobbin.com/flows/c3ad75ad-09e6-42bf-a66b-c8842c37984d) | After verification | Photos step | [O] |
| F4 | Photos upload, crop, reorder | [Uploading photos](https://mobbin.com/flows/0a8dae86-a4a1-4b18-8840-0f310d804a1d) | Onboarding step or profile edit | Photo grid with ≥ required photos | [O] |
| F5 | Interests, causes, qualities, intentions | Within F3 and the profile builder | Onboarding / profile builder | Next step / Save and close | [O] |
| F6 | BFF mode setup | [Completing an account setup](https://mobbin.com/flows/795ff2ae-e5a9-4684-a24c-cdd2ea4bce63) | Mode = BFF | BFF discovery | [O] (out of Numaya scope) |
| F7 | Profile completion hub | [Completing a profile](https://mobbin.com/flows/3ad96a67-4e1e-4d60-8cdf-893cca19f696) · [55% complete](https://mobbin.com/screens/d742bced-3a20-4e4f-a856-346d76bcf983) | Profile tab → *Complete profile* | Profile tab | [O] |
| F8 | Edit profile | [Editing my profile](https://mobbin.com/flows/906e5dfe-59d4-4387-a6ac-905706431897) | Profile tab → *Edit profile* | Back (autosave) / per-field Save | [O] |
| F9 | Discovery card stack (People) | [Discover](https://mobbin.com/flows/da0e3963-af8a-41e2-9f31-58c7df99b2bb) | Tab: People | Like / pass / SuperSwipe / report | [O] |
| F10 | Curated Discover (daily picks) | Discover flow, screen 5 | Tab: Discover | Like on card | [O] |
| F11 | Filters (basic and advanced) | [Filtering people](https://mobbin.com/flows/539ac528-7029-49e9-8636-3d2b4b12a5c0) · [Filtering people (BFF)](https://mobbin.com/flows/5c103e1e-0dec-43ab-9a52-00ea0e904b3a) | Filter icon on People | Apply → refreshed stack | [O] |
| F12 | Match and first move | [Matching with a user](https://mobbin.com/flows/e693028d-bda9-45a7-8276-2c1c0fb08e33) · [Matching (2 screens)](https://mobbin.com/flows/9fdb4acf-d06f-43fc-b3ff-979145c67725) | Mutual like | Chat or dismiss to stack | [O] |
| F13 | Match queue, expiry, Extend, Rematch | Chats screen (queue) + official docs | Chats tab | Chat / expired | [O] queue · [C] timers |
| F14 | Liked You (Beeline) | [Liked You](https://mobbin.com/screens/ee33fda3-1add-46fd-8c57-855f48f89c87) | Tab: Liked You | Paywall (locked) / match (unlocked, [I]) | [O] |
| F15 | Chat and media | [Sending a chat](https://mobbin.com/flows/6a312979-9402-40e8-b964-f0b771105c4e) | Inbox row / match screen | Back to inbox | [O] |
| F16 | Opening Moves (preset first question) | [Write your own Opening Move](https://mobbin.com/screens/e6c00ac2-8e86-461b-a823-f7d8302bac1d) | Profile / empty inbox card | Saved Opening Move | [O] |
| F17 | Unmatch | [Unmatching a user](https://mobbin.com/flows/c0931f07-f723-4020-abf7-b88287484723) | Chat ⋯ menu | Reason survey → inbox | [O] |
| F18 | Report and block | [Reporting a user](https://mobbin.com/flows/7d560bc0-3903-4a5a-8ae4-88a7475a8fc6) · [Reporting a user](https://mobbin.com/flows/b4044ab8-54b2-4107-924a-7163d86dcc49) | Card *Hide and Report* / chat ⋯ *Report* | Confirmation → Done | [O] |
| F19 | Date feedback ("Did you meet?") | [Did you meet?](https://mobbin.com/screens/f7e245fd-40b4-4058-be8a-d6b2e3994f94) | Chat ⋯ menu / prompt | Dismiss | [O] |
| F20 | Photo verification | [Verifying a photo](https://mobbin.com/flows/6c74489d-ebb8-423d-9964-004637611b19) · [Verifying my profile](https://mobbin.com/flows/eb66bdc5-a349-405a-8c36-a8a9a8158261) | Prompt sheet on stack / edit profile row | Pending review → badge | [O] UI · [C] review |
| F21 | Premium purchase | [Subscribing to Bumble Premium](https://mobbin.com/flows/678596ab-aca0-4d4d-be11-4cc346ca6615) · [Boost and premium plan](https://mobbin.com/flows/4c0e33b6-ce9c-41ba-a71c-5546d4e5e9c0) · [Pay plan](https://mobbin.com/flows/8b21909e-9125-4d52-9160-f319bf5bde63) | Locked feature, Profile → Pay plan | Success alert → active state | [O] |
| F22 | Settings and visibility | [Settings](https://mobbin.com/flows/45909c24-0ae4-4add-b508-c74690d67bbf) | Profile → gear | Done | [O] |
| F23 | Snooze | [Activating snooze mode](https://mobbin.com/flows/06977bc3-faa4-477d-8cca-b77bfa3ee878) | Settings → Snooze | Snoozed state row | [O] · [C] durations |
| F24 | Turn off a mode | [Turning off date mode](https://mobbin.com/flows/daed9d85-dc3c-4c3f-b691-cbd9fbae3ded) | Settings → Date mode toggle | Mode hidden | [O] |
| F25 | Notification settings | [New messages settings](https://mobbin.com/screens/f31b784e-f54a-4c9e-8c6f-bcd5de7d0be9) | Settings → Notification settings | Back | [O] |
| F26 | Delete account | Official help | Settings → *Delete account* | Reason → confirm → signed out | [O] entry · [C] steps |
| F27 | Account recovery / restore | Official help | Sign-in / support | Restored (≤ 28 days) | [C] |
| F28 | Moderation block and appeal | Official help | In-app notification | Appeal form | [C] |
| F29 | Help centre in-app | [Get help article](https://mobbin.com/screens/e9e1dde2-70ac-4848-b906-6480e06cf03f) | Profile → ? / Settings → Contact & FAQ | Article / support chat | [O] |

## 2. Screen inventory

Repeated structures are listed once with every context in which they appear.

### Account, sign-in and verification

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-01 | Splash | Logo on brand fill or white | Onboarding flows, pos. 1 | [O] |
| B-02 | Welcome | Logo, wordmark, *Create an account* (primary), *I have an account* (text), Terms and Privacy links | [screen](https://mobbin.com/screens/ebfe55a2-ef0b-45d8-91f2-0a62cb312b08) | [O] |
| B-03 | Sign-in methods | "You last signed in with…", Quick sign in, Apple, Facebook, phone, back | [screen](https://mobbin.com/screens/88c589c0-5723-4c23-bb4c-08febbc1a87d) | [O] |
| B-04 | Phone number | Back, title, reassurance lede, Country (code + dial) and Phone fields, lock note, circular next (disabled until valid), number pad | [screen](https://mobbin.com/screens/05c421be-e8a8-411f-aec4-c8cdf723da29) | [O] |
| B-05 | Country search | Full-screen search, keyboard, list rows (flag, name, dial code), Cancel | Onboarding (20), mid-flow | [O] |
| B-06 | Phone submit loading | B-04 plus floating "Loading" pill | [screen](https://mobbin.com/screens/7bed261a-9808-4489-8b77-9081bf00a0eb) | [O] |
| B-07a | Verify by SMS | Title, "sent by text to …", *Change number*, 6 code boxes, *Didn't get a code?*, next, pad, Loading pill on 6th digit | Onboarding flows | [O] |
| B-07b | Verify by call | "Enter the last 6 digits of the phone number we called you from", fixed prefix box, 6 boxes, *Didn't get a call?* | Onboarding (20) | [O] |
| B-08 | Tracking pre-prompt | Illustration, "Let's make this about you", explanation, Continue, privacy note (precedes the iOS ATT dialog [I]) | Onboarding flows | [O] |
| B-09 | Email capture | Progress bar, "Can we get your email?", recovery rationale, field, Skip, next | [screen](https://mobbin.com/screens/43b76fd0-0cf7-4672-8f03-bad90d36492f) | [O] |

### Profile creation

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-10 | Intro | Progress bar, "Oh hey! Let's start with an intro", first name, birthday (Month/Day/Year), helper "It's never too early to count down" | [screen](https://mobbin.com/screens/a9b6d46c-1062-4198-8ad2-b78235dff1c3) | [O] |
| B-11 | Gender | "[Name] is a great name", radio cards (Woman, Man, Nonbinary), expandable "Add more about your gender", info note | [screen](https://mobbin.com/screens/689d9400-87d7-4262-ab2e-1ca9e3d7dffe) | [O] |
| B-12 | Gender detail sheet | Back, list of identities (radio), "Tell us if we're missing something" >, *Save and close* | Setting up my account | [O] |
| B-13 | Show gender on profile | Chips (which label to show), *Show on profile* switch | Setting up my account | [O] |
| B-14 | Mode choice | "What brings you to Bumble?", option cards (Date, BFF) with descriptions, visibility note | [screen](https://mobbin.com/screens/4eee7d7b-20aa-420c-96f8-ea7d90343d70) | [O] |
| B-15 | Photos grid | "Time to put a face to the name", "Add at least 4 photos", 3×2 slots, *Main* label, remove ×, "Hold & drag to reorder", photo tips link | Uploading photos | [O] |
| B-16 | Crop photo | Dark full-screen, crop grid, thumbnails of picked photos, *Upload* | Uploading photos | [O] |
| B-17 | Interests | "Choose 5 things you're really into", search, suggested chips, selected chips row, *Skip*, "0/5 selected", next | Onboarding / setup | [O] |
| B-18 | Causes | "Choose up to 3", chips with + / ×, "1/3 selected" | Setup (BFF) | [O] |
| B-19 | Relationship status (BFF) | Radio list | Setup (BFF) | [O] |
| B-20 | Intentions sheet | Progress, icon, "What do you want from your dates? You can choose 1 or 2", checkbox cards, *Save and close* | [screen](https://mobbin.com/screens/e5802a5c-5097-4fdd-b609-f6ff0caf85a1) | [O] |
| B-21 | Profile completion hub | "55% complete", "Start building your profile", tiles: More about you 1/9, Photos 2/4, Prompts 0/3, Interests 0/5 | [screen](https://mobbin.com/screens/d742bced-3a20-4e4f-a856-346d76bcf983) | [O] |
| B-22 | Mode intro (BFF) | Illustration, value statement, *Got it* | Completing an account setup | [O] |

### Profile management

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-23 | Profile tab | Avatar with completion ring and %, *Complete profile* / *Edit profile*, help and settings icons, segmented tabs (Pay plan, Photo insights, Safety and wellbeing), consumable cards, plan card, comparison table, tab bar | Pay plan / Editing | [O] |
| B-24 | Edit profile | Photos and videos grid, *Best Photo* row, *Verify my profile* row, Interests card (favourite), Causes, Qualities I value, Prompts, Bio textarea plus tip card, About you rows, More about you rows, Languages, Connected accounts | Editing my profile | [O] |
| B-25 | Text edit with keyboard | Inline field focused, keyboard accessory bar *Cancel* / *Save* | Editing my profile | [O] |
| B-26 | Attribute picker | Single- or multi-select list in sheet (height, drinking, …) with "Show on profile" | Editing (inferred from rows) | [I] |
| B-27 | Opening Move editor | "Write your own Opening Move", large textarea, "160 characters left", *Cancel* / *Save* (disabled when empty) | [screen](https://mobbin.com/screens/e6c00ac2-8e86-461b-a823-f7d8302bac1d) | [O] |
| B-28 | Connected accounts | Instagram connected (photo strip, check), Spotify connect (empty circles) | Editing my profile | [O] |

### Discovery and filters

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-30 | People stack | Header (logo, undo, filters), photo-progress bar, full-bleed card: name, age, verified badge, job and education lines, "New here" / "Photo verified" chips, "We have things in common", SuperSwipe FAB, note button, share; tab bar | Discover flow | [O] |
| B-31 | Swipe coach mark | Dimmed card, arrows and hand gesture | Discover flow | [O] |
| B-32 | Expanded profile (scroll) | Sections: location, lives in, Spotify artists, prompts; bottom actions: pass ×, SuperSwipe ★, like ✓; *Hide and Report*; *Recommend to a friend* | Reporting flow | [O] |
| B-33 | Curated Discover | "Discover", refresh countdown pill ("See new people in 18 hours"), "Recommended for you" carousel cards with heart, rationale note | Discover flow | [O] |
| B-34 | Filters: basic | Segmented Basic/Advanced, Who you want to date >, age dual slider plus "2 years either side" fallback switch, distance slider plus fallback switch, *Verified profiles only* switch with *What's this?*, *Apply* | Filtering people | [O] |
| B-35 | Filters: advanced | Height range plus fallback, intentions checklist plus fallback (disabled until a choice), "Add this filter +" rows → sheet with checkboxes plus fallback | Filtering people | [O] |
| B-36 | Filters (BFF) | Distance, interests chips, languages | Filtering (BFF) | [O] |
| B-37 | Out of profiles | Not captured | — | [U] |

### Matching, Liked You and chat

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-40 | Match | Close ×, ⋯, two tilted photos plus badge, "What a match!", timer copy ("24 hours to make your move"), composer | Matching flow | [O] |
| B-41 | Match + Opening Move | "Your Opening Move" card, coach tooltip "Or start the conversation however you like… Got it · 2 of 2" | Matching flow | [O] |
| B-42 | Chats inbox | Title, search, "Your matches (10)" queue: avatars with countdown rings, liked-you stack tile "50+"; chat rows (avatar, name, preview, "Your move" tag, ring on unanswered) | [screen](https://mobbin.com/screens/fc68e92a-97b5-48da-be3c-b4feb60efb74) | [O] |
| B-43 | Chats empty | Liked-you teaser, "Need help with the first message? Try Opening Moves" card, illustration, "Connections start here", *Find your person* | [screen](https://mobbin.com/screens/f0fd7cdd-7d03-4035-b4a8-94aaeb6357a2) | [O] |
| B-44 | Conversation | Header (back, avatar, name, voice call, video call, ⋯), bubbles (mine brand-filled right, theirs grey left), photos, GIFs, video, voice note, call log, "Delivered" receipt and timestamps, composer (camera, text "Aa", GIF, video/attachment, mic) | Sending a chat | [O] |
| B-45 | Chat ⋯ menu | Action sheet: Open Share Date, Did you meet?, Unmatch, Report (destructive colour) | Reporting flow | [O] |
| B-46 | Liked You | Title, filter, chip tabs ("Really into you · 12", "Notes · 0", "All · 100+", "Nearby"), blurred cards, *See who likes you* CTA | [screen](https://mobbin.com/screens/ee33fda3-1add-46fd-8c57-855f48f89c87) | [O] |
| B-47 | Expired match / Extend / Rematch | Grey ring in queue; Extend or Rematch actions | Official docs | [C] |

### Safety and verification

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-50 | Report reasons | "Unmatch and report", anonymity reassurance, icon list: Fake profile, Inappropriate content, Scam or commercial, Identity-based hate, Off-app behaviour, Underage, I'm just not interested | Reporting flow | [O] |
| B-51 | Report detail | Back, close, "Report something on their profile", Photos or videos >, Profile text > | Reporting flow | [O] |
| B-52 | Report confirmation | Success icon, "You've blocked and reported [name]", follow-up via Help Hub, *Done* | [screen](https://mobbin.com/screens/d61149b1-b183-400d-8e01-42fcf42dcfde) | [O] |
| B-53 | Unmatch confirm | "Unmatch [name]", consequences list (won't see each other, can't message), report nudge card, *Unmatch*, *Report instead* | Unmatching flow | [O] |
| B-54 | Unmatch reason | Success icon, "You've unmatched [name]", reason rows (moved off the app, different goals, no reply, uncomfortable, something else) | Reporting flow | [O] |
| B-55 | Did you meet? | Sheet, privacy reassurance, *Yes, we met* / *No, we didn't meet* | [screen](https://mobbin.com/screens/f7e245fd-40b4-4058-be8a-d6b2e3994f94) | [O] |
| B-56 | Verification prompt | Sheet over stack, sample photo with badge, "Show them it's really you", explanation, *Let's get verified* | Verifying a photo | [O] |
| B-57 | Pose capture | Full-screen camera, flash, flip, shutter, close, sample-pose thumbnail, randomised gesture | Verifying a photo | [O] |
| B-58 | Verification help | Long-form help article ("How do I Photo Verify?", "Why have I been asked…") | Verifying my profile | [O] |
| B-59 | Moderation block / appeal | In-app notification with appeal form link | Official docs | [C] |

### Premium

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-60 | Pay plan tab | Consumables (Spotlight, SuperSwipe with price or "N left"), plan hero card (*Upgrade from $…* / *Explore*), comparison table with checks and info icons | Pay plan | [O] |
| B-61 | Paywall | Close, tabs (Boost / Premium), info, feature carousel with dots (See who likes you, Backtrack…), plan cards (duration, price, per-week price, SAVE %, MOST POPULAR, selected), auto-renew legal copy, CTA "Get 1 week for $…" | Subscribing | [O] |
| B-62 | Purchase success | System alert "You're all set. Your purchase was successful." OK | Subscribing | [O] |
| B-63 | Active subscription | Plan card "Active until [date]", consumable counts | Subscribing | [O] |
| B-64 | Plan comparison sheet | "Plan comparison", hero, feature-by-tier table | Boost and premium plan | [O] |
| B-65 | Store purchase sheet, failure, cancel | Not captured | — | [U] |

### Settings and lifecycle

| ID | Screen | Key content | Ref | Ev. |
| --- | --- | --- | --- | --- |
| B-70 | Settings | Modal (Cancel / Done): mode, mode toggle (consequence copy), Snooze, Incognito, Auto-Spotlight, location (current, Travel with lock = premium), video autoplay, notifications, security and privacy, contact and FAQ, *Restore purchases*, *Log out*, *Delete account*, version | Settings | [O] |
| B-71 | Snooze status sheet | "Set a status for your existing matches?": travelling, focused on work, digital detox, prioritising myself, *No thanks* | Activating snooze | [O] |
| B-72 | Snoozed state | Row becomes "Deactivate snooze mode", remaining time and status | Activating snooze | [O] |
| B-73 | Saving toggle | Row spinner while a toggle change saves | Turning off date mode | [O] |
| B-74 | Notification category | "Turning these off might mean you miss alerts…", Push / In-app / Email switches, email address and *Change email address?* | [screen](https://mobbin.com/screens/f31b784e-f54a-4c9e-8c6f-bcd5de7d0be9) | [O] |
| B-75 | Delete account | Reason → confirm; cancel subscription first; 28-day restore | Official docs | [C] |
| B-76 | OS permission dialogs (location, notifications, camera, photos) | Not captured | — | [U] |
| B-77 | Offline, error, retry, message failure | Not captured | — | [U] |

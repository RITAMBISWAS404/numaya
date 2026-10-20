# End-to-end journey map

This is the reference journey of Bumble Dating (iOS), reconstructed from Mobbin captures and
official help pages. Node labels use the screen IDs from [flow-catalogue.md](flow-catalogue.md).
Dashed edges are inferred [I] or come from official documentation [C], not from captures.

## 1. Lifecycle overview

```mermaid
flowchart LR
  A[Install / cold start] --> B{Has session?}
  B -- no --> W[B-02 Welcome]
  B -- yes --> H[Home: People stack]
  W -- Create an account --> P[B-04 Phone number]
  W -- I have an account --> S[B-03 Sign-in methods]
  S --> P
  P --> V[B-07 Verify code]
  V -- new account --> T[B-08 Tracking pre-prompt]
  V -- existing account --> H
  T --> PB[Profile basics F3]
  PB --> PH[B-15 Photos]
  PH --> IN[B-17 Interests]
  IN --> H
  H <--> D[B-33 Discover]
  H <--> LY[B-46 Liked You]
  H <--> CH[B-42 Chats]
  H <--> PR[B-23 Profile]
  PR --> ST[B-70 Settings]
  ST --> SN[Snooze F23]
  ST --> DEL[Delete account F26]
  DEL -. within 28 days .-> RS[Restore C]
```

## 2. Account creation and onboarding (F1, F3–F5)

```mermaid
flowchart TD
  W[B-02 Welcome] --> P[B-04 Phone]
  P -- tap country --> CS[B-05 Country search] --> P
  P -- valid number, next --> L1((Loading pill)) --> V{Verification channel}
  V -- SMS --> VS[B-07a Code by text]
  V -- call --> VC[B-07b Last 6 digits of caller]
  VS -- 6th digit --> L2((Loading)) --> OK{Code valid?}
  VC -- 6th digit --> L2
  OK -- no --> ERR[Inline error, retry I] --> VS
  OK -- yes --> T[B-08 Tracking pre-prompt] --> ATT[iOS ATT dialog I]
  VS -- Change number --> P
  VS -- Didn't get a code --> RES[Resend / call fallback I] --> VS
  ATT --> I[B-10 Name + birthday]
  I --> AGE{Age ≥ 18? I}
  AGE -- no --> BLK[Ineligible U]
  AGE -- yes --> G[B-11 Gender] --> GD[B-12 Gender detail sheet] --> G
  G --> GS[B-13 Show gender on profile]
  GS --> M[B-14 Mode: Date / BFF]
  M --> E[B-09 Email, skippable]
  E --> PH[B-15 Photos ≥ 4] --> CR[B-16 Crop] --> PH
  PH --> INT[B-17 Interests, skippable] --> H[People stack]
  H -. incomplete profile .-> HUB[B-21 Completion hub]
```

## 3. Discovery, matching and chat (F9–F17)

```mermaid
flowchart TD
  H[B-30 People stack] -- first visit --> CM[B-31 Coach mark] --> H
  H -- scroll card --> X[B-32 Expanded profile]
  H -- filters --> F[B-34 / B-35 Filters] -- Apply --> H
  H -- swipe left / × --> PASS[Pass] --> H
  H -- undo --> BT{Premium?}
  BT -- no --> PW[B-61 Paywall]
  BT -- yes --> H
  H -- swipe right / ✓ --> LIKE{Mutual?}
  LIKE -- no --> H
  LIKE -- yes --> MT[B-40 Match]
  H -- ★ SuperSwipe --> SS{Credits?}
  SS -- no --> PW
  SS -- yes --> LIKE
  MT -- type message --> CV[B-44 Conversation]
  MT -- close --> H
  MT -. no message in window C .-> EXP[B-47 Expired]
  EXP -- Extend / Rematch --> Q[B-42 Match queue]
  Q -- tap match --> CV
  LY[B-46 Liked You] -- locked --> PW
  LY -. unlocked I .-> LIKE
  H -. stack exhausted U .-> EMPTY[B-37 Out of profiles]
```

## 4. Safety, verification and premium (F17–F21)

```mermaid
flowchart TD
  CV[B-44 Conversation] -- ⋯ --> MENU[B-45 Action sheet]
  MENU -- Unmatch --> UC[B-53 Unmatch confirm]
  UC -- Unmatch --> UR[B-54 Reason survey] --> INBOX[Inbox]
  UC -- Report instead --> RR
  MENU -- Report --> RR[B-50 Report reasons]
  X[B-32 Expanded profile] -- Hide and Report --> RR
  RR -- profile issue --> RD[B-51 What on profile?] --> RC[B-52 Blocked + reported]
  RR -- other reason --> RC
  RC -- Done --> INBOX
  MENU -- Did you meet? --> DM[B-55 Feedback sheet]
  STK[People stack] -- prompt --> VP[B-56 Verify prompt] --> CAP[B-57 Pose capture]
  CAP --> REV[Review: automated + human C] --> RESV{Result}
  RESV -- approved --> BADGE[Verified badge]
  RESV -- rejected --> RETRY[Retry / support C]
  LOCK[Locked feature] --> PW[B-61 Paywall] --> STORE[Store sheet U]
  STORE -- success --> OKA[B-62 Success alert] --> ACT[B-63 Active plan]
  STORE -. cancel or fail U .-> PW
```

## 5. Settings and account lifecycle (F22–F28)

```mermaid
flowchart TD
  PR[B-23 Profile] -- gear --> ST[B-70 Settings]
  ST -- Snooze --> SS[B-71 Status sheet] --> SZ[B-72 Snoozed state]
  SZ -- Deactivate snooze --> ST
  ST -- mode toggle off --> CONF[Consequence copy, saving spinner B-73]
  ST -- Notification settings --> NC[B-74 Category toggles]
  ST -- Restore purchases --> RP[Store restore U]
  ST -- Log out --> W[Welcome]
  ST -- Delete account --> DR[Reason C] --> DC[Confirm C] --> W
  W -. sign in within 28 days C .-> REST[Restore account]
  MOD[Moderation block C] --> APP[Appeal form, 6-month window C]
```

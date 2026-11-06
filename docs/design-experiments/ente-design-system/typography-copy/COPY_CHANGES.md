# UI copy changes

All edits are in `apps/numaya_mobile/lib/l10n/app_en.arb`; the generated files were rebuilt with `flutter gen-l10n`. English is the only locale.
- Placeholders were kept, and a script asserted they were unchanged: `{number}`, `{phone}` and `{date}`.
- No plural or select message was edited.
- Tests were updated only where they find these exact strings.

| Key | Before | After | Reason |
|---|---|---|---|
| `likesSubtitle` | People who liked you. Like them back to match. | Like them back to match. | The Likes title already says who these people are; the subtitle keeps only the next step. |
| `visLede` | What Numaya knows about whether people can see your profile, what you can change, and what it can’t tell you. | Whether people can see your profile, what you can change, and what this page can’t tell you. | Same three promises in fewer words; “what Numaya knows about whether” was indirect. |
| `chatsEmptyBody` | When you like each other, you’ll match. Here’s where you can chat. | When you like each other, you’ll match and can chat here. | One sentence: the outcome and where it happens. |
| `setupVerifiedBody` | {number} is confirmed. Now let’s make a profile people actually want to reply to. | {number} is confirmed. Now let’s set up your profile. | Names the next step plainly; drops the marketing aside. Placeholder kept. |
| `reauthBody` | For your security, this session has ended. Confirm it’s you with a code sent to {phone} and you’ll be back where you were. | Your session ended. Confirm it’s you with a code sent to {phone} to pick up where you left off. | Drops “For your security”, a cause the app cannot know for every ended session. Placeholder kept. |
| `recoveryEmailBody` | If you ever lose access to your number, an email on file lets support help you back into your account. | If you lose access to your number, support can use this email to help you back into your account. | Shorter; says who uses the email and why. |
| `deleteLede` | Before you go, tell us why. It helps us improve. | Your answer helps us improve. | The field label below already asks “Why are you leaving?”; the lede no longer repeats it. |
| `obConfirm` | Confirm | That’s right | Answers the dialog’s question (“You’re {age}”) and pairs with Edit, instead of a generic Confirm. |
| `chatRetry` | Retry | Try again | One term for retrying across the app (“Try again” is used 14 times; “Retry” was the only exception). |
| `settingsSignOut` | Log out | Sign out | One pair of terms: the app says “sign in” everywhere and “Sign out” on two other screens. |
| `logoutTitle` | Log out? | Sign out? | As settingsSignOut. |
| `logoutBody` | Logging out clears your profile from this device. | Signing out clears your profile from this device. | As settingsSignOut; consequence unchanged. |
| `visStatusPaused` | Paused | Snoozed | The feature is called Snooze in Settings, Discover and Delete account; the status now uses the same word. |
| `visPausedBody` | New people can’t see you while you’re paused. Your matches and chats are still here. | New people can’t see you while you’re snoozed. Your matches and chats are still here. | As visStatusPaused. |
| `visPausedUntil` | New people can’t see you while you’re paused. It ends {date}. | New people can’t see you while you’re snoozed. It ends {date}. | As visStatusPaused. Placeholder kept. |
| `visWhyResume` | You’re paused, so new people can’t see you. | You’re snoozed, so new people can’t see you. | As visStatusPaused. |

## Considered and kept
- `deleteContinue` "Continue". Renaming it "Delete account" would repeat the top-bar title on the same screen, and the button opens a confirmation sheet whose own button names the action ("Delete account").
- `completionContinue` "Continue". It appears only in an EXP-004 variant. Changing it would alter one pending option and not the others.
- Every demo and simulation disclosure (`*Demo*`, `paywallLegal`, `reportDoneBody`, `verifyDemoBody`, …). They are true statements about the build and are kept word for word.

## Not changed: these need product or legal review before any edit
- Eligibility and consent: `obUnderageBody`, `obConfirmAgeBody`, `welcome` terms line.
- Costs and renewals: `paywallLegal`, `paywallConfirmBody`, `premiumDemoNote`, `deleteSubscription*`.
- Deletion consequences: `deleteC1`–`deleteC3`, `deleteRestoreNote`, `settingsDeleteBody`, `logoutBody` (wording only, as above).
- Safety: `safetyTip*`, `shareDateBody`, `blockedAccountBody`, `visNotice*`.
- Privacy disclosures: `obNameLede`, `obLocationLede`, `obMeetLede`, `phonePrivacyBody`, `verifyReviewBody`, `visAbout*`.
- Factual claims: `completionLede` ("Profiles with more to talk about get more matches") reads as a promise and should be confirmed by product.
- Events strings (`event*`) are behind the off-by-default gate and were not reviewed.

## Terminology now used once per concept
| Concept | Term |
|---|---|
| Leaving the account on this device | Sign out (pairs with "sign in") |
| Retrying a failed action | Try again |
| The hide-me feature and its state | Snooze, snoozed (Home is "paused" as a consequence) |


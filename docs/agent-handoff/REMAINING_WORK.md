# Remaining work

State on 14 November 2026. Branch `experiment/numaya-v8-review-20261114-0321`, app source `fe44b27`.

## Waiting on the owner
- Review `C:\Users\biswa\OneDrive\Desktop\Numaya V8 Final Review\2026-11-14 73a745f\gallery\index.html` and the APK; export choices (layouts plus typography: display font, UI font, 14 or 15 body). See docs/v8-review/OPEN_DECISIONS.md.
- Supply 3 and 6-month Premium prices, mascot and Premium artwork (docs/v8-review/ARTWORK_SLOTS.csv), and decide UI-034 (Likes tile) and the UI-008 open phrase.

## Partial in this pass (see ISSUE_LEDGER.csv)
UI-041, 048, 049, 051, 053, 055, 056, 070, 074, 077: shared components done; not every screen re-audited.

## External blockers (not frontend work)
A development Supabase project (A1), the phone OTP provider (A3), a billing client and push. Until then real sign-in, Compliment sends, purchases and notifications are unverified.

## Private files
The demo photos are local and git-ignored. They appear in the screenshots, renders, gallery and APK, which therefore stay local. No off-device backup exists.

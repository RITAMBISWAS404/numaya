# Retention schedule and legal policy matrix

This is technical design, not legal advice. Launch countries are assumed to be India-first; the owner must confirm. Durations marked **decision** are not set; dev keeps data until decided.

## Retention
| Data | Purpose | Duration | Access | Deletion |
|---|---|---|---|---|
| Auth record (phone) | Sign-in | Until the account is purged | Supabase Auth; service | Worker deletes the auth user |
| Account (birth date, status) | Eligibility (18+) | Until purge | Member (own), service | Cascade on purge |
| Profile, prompts, preferences | Matching | Until deletion (hidden at once; purged after 28 days or on request) | Member, counterpart | Cascade |
| Photos (objects + rows) | Profile | Same | Owner; approved for viewers | Worker removes objects, then rows cascade |
| Location (rounded) | Distance band | Overwritten on update; purge | Server only | Cascade |
| Messages | Conversation | **decision** (dev: until either member's purge) | Members while visible | Cascade with the sender; the other member's copy goes when the conversation's user is purged |
| Report evidence | Safety | **decision** (e.g. 1–3 years) | Moderators | Manual; kept after a member's deletion |
| Audit log | Accountability | **decision** | Owner | Manual |
| Deletion tombstones | Restore replay | **decision** (at least the backup retention) | Service | Manual |
| Backups | Recovery | **decision** (RPO/RTO and budget) | Owner | Rotation by the owner |

## Policy matrix (to complete with counsel)
| Jurisdiction | Primary source | Effective / status | Applicability | Control in this build | Test | Owner approval |
|---|---|---|---|---|---|---|
| India: DPDP Act 2023 and Rules 2025 | meity.gov.in (Gazette) | Phased commencement: **verify the in-force provisions at launch** | Indian users' personal data | Consent records (versioned), export, deletion, purpose-limited fields, breach-response runbook (to write) | export/delete tests | ☐ |
| India: IT Act / Intermediary Rules | meity.gov.in | In force | User-generated content platform | Reports, moderation queue, audit; grievance officer is an owner task | report test | ☐ |
| Google Play: dating/social UGC and child safety | support.google.com/googleplay/android-developer/answer/14747720 | Current policy | Android distribution | Block/report, published standards, child-safety contact (owner) | — | ☐ |
| Google Play: account deletion | Play policy | Current | Apps with accounts | In-app deletion; a web deletion path is still needed | delete test | ☐ |
| Apple: UGC and account deletion | developer.apple.com guidelines | Current | iOS distribution | Same; iOS not built or verified | — | ☐ |
| Expansion (GDPR/UK, US states) | — | Not assessed | Only if launched there | — | — | ☐ |

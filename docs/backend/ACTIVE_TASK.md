# Active task: waiting for owner setup (deferred by the owner, on purpose)

## Owner
Complete the items you want from [MANUAL_SETUP.md](MANUAL_SETUP.md) Part A:
- **Minimum:** A1 (dev project).
- **For a usable APK:** A3 (phone test numbers) and A5 (staff account).
- **Strongly advised:** A2 (access token), A4 (backup key) and A6 (worker schedule).

Then paste [RESUME_AFTER_SETUP.txt](RESUME_AFTER_SETUP.txt) into a new session, editing its "Done" line first.

## Next backend session
Run [ACTIVATION_RUNBOOK.md](ACTIVATION_RUNBOOK.md):
1. `npm run activate -- --check`.
2. `--plan-only`, then the full run.
3. Fix platform findings.
4. Two-user journey on devices.
5. Backup and restore drill.
6. Record evidence.

## Engineering work that needs no owner input (candidates for the next sessions)
- App-side push token capture (`firebase_messaging`; needs `google-services.json` from A7 to build).
- Billing client (`in_app_purchase`) wired to `verify-purchase`, only when the owner schedules store work.
- Device location → `set_location`; an export entry point if the frontend adds one.
- Frontend states U1–U5 (UI_INTEGRATION).

**Do not:**
- Apply migrations to any non-development project.
- Enable billing or paid add-ons.
- Set `STORE_VERIFICATION_ENABLED` without the owner.
- Publish the APK.

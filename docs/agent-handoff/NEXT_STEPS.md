# Next steps

1. **Confirm the scope** of the final UX polish with the owner, and write it into
   [ACTIVE_TASK.md](ACTIVE_TASK.md).
2. **Establish a local baseline:** in `apps/numaya_mobile/` run `flutter pub get`, then
   `flutter test`. Record the result in [VALIDATION.md](VALIDATION.md); the last run was in a cloud
   container.
3. **First device run:** launch an emulator (`Pixel_9`), then `flutter run`. Check fonts, the tab
   pill over the gesture bar and haptics, the items the QA could not verify.
4. **Implement the polish** in small, reviewed steps, using the project skills: impeccable,
   emil-design-eng, break-ui, accessibility-as-code, design-review-workflow. Use Mobbin for
   references.
5. **Close with one design-review pass** (the design-review-workflow skill), then regenerate the
   goldens and update the QA report.
6. **Install web dependencies** (`npm ci`) before any web change or the `CLAUDE.md` pre-commit
   checks.

## Later
- Demo photography for Discover, Likes and events.
- Commission the two illustration slots ([ILLUSTRATION_BACKLOG.md](../design-experiments/monochrome-meetup-premium/ILLUSTRATION_BACKLOG.md)).
- Choose a production framework ([architecture](../engineering/architecture.md)).

# Tabler MVP pass

This pass covers three changes plus a gate:
- Tabler icons across the app.
- An Ente-style bottom navigation: a filled, near-black selected tab on a light tile, and light grey outlines for the rest.
- Alert icons centred on their full content.
- Events hidden for the MVP.

**Branch:** `experiment/numaya-tabler-mvp-20261106-1725`. Its parent is the V4 baseline `ea86a08d076e5d4964fd7f9f8ecb8a6117b1098e`. The experiment choices remain pending.

| Doc | Contents |
|---|---|
| [DECISIONS.md](DECISIONS.md) | Figma evidence, decisions TB-01–05, what they supersede (UI-010), exceptions |
| [ICON_MAP.md](ICON_MAP.md) | Tabler source and version, the variant rules, and the full role → Lucide → Tabler mapping |
| [EVENTS_GATE.md](EVENTS_GATE.md) | How Events is gated, what is hidden or redirected, and how to re-enable it |
| [QA.md](QA.md) | Checks, test coverage, the visual sweep, accessibility, and device checks still needed |

Before/after boards: [`artifacts/ente-design-system/tabler-mvp/before-after/`](../../../../artifacts/ente-design-system/tabler-mvp/before-after/).

To regenerate the captures (opt-in), run from `apps/numaya_mobile`:
```
flutter test --tags comparison --run-skipped --update-goldens --dart-define=V3_SET=tabler --dart-define=V3_VIEW=phone test/screenshots/capture_v3_test.dart
```
Use `V3_VIEW=narrow` for 320pt at 200% text.

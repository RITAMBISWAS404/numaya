# Design system: Monochrome Meetup premium

**Principles:**
1. **Surfaces, not lines.** Content is separated by a white card on the cool grey page, or by a
   filled control on a white card. Hairlines are reserved for focus and control boundaries.
2. **Purple is decisive, not decorative.** `#7262C7` marks the one primary action, the selected
   state, progress and "yours":
   - Like;
   - Edit profile;
   - Next;
   - your messages;
   - the selected tab.
   Purple text uses `#5B4BB0`. Tints (`#F1EFF9`) carry secondary brand moments. There are no
   gradients anywhere.
3. **Editorial headings, quiet text.** Plus Jakarta Sans 700–800 for titles, names and numbers.
   Figtree for everything you read or touch.
4. **Shape has roles.** 8 for tags, 16–18 for controls and fields, 24 for cards and images, 32 for
   hero cards and sheets, pills for buttons, chips and the tab bar.
5. **Hero first.** The priority screens open on one composed hero card (Discover person, Profile,
   Account Health status), then quieter sections.
6. **Truthful data.** Nothing is invented. Missing data shows "—" and "Not measured". The demo is
   labelled as a demo.

**Where it lives (Flutter only):**

| Layer | File |
|---|---|
| Tokens | `lib/core/design_system/tokens/monochrome_tokens.dart` |
| Semantic roles | `foundations/app_colors.dart`, `app_typography.dart`, `app_layout.dart`, `app_motion.dart` |
| Components | `widgets/*.dart`; screens import `design_system.dart` only |
| Generated web mirror | `numaya_tokens.g.dart` is untouched; `node tool/generate_tokens.mjs --check` passes |

**Live reference:** the debug-only Design Lab (Demo Hub › Design › Design Lab).

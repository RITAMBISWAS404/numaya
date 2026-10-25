# Reference → Numaya decision log

Each decision records the reference input, the Numaya choice and why. Status: **Adopted** (in code
or the spec), **Proposed** (spec only, awaiting product confirmation), **Open** (see
[unknowns](unknowns.md)).

| ID | Area | Reference input | Numaya decision | Rationale | Status |
| --- | --- | --- | --- | --- | --- |
| D-01 | Brand colour | Bumble yellow fill with dark foreground; Meetup purple | Brand is **`#F770E3`** (migrated from `#63AFE9`), used at its exact value for marks, progress, selected states, tints and the verified badge. Never darkened; no second pink | Owner direction | Adopted |
| D-02 | Foreground on brand | Bumble puts black icons on yellow | Foreground on a solid brand fill is **dark ink** (7.15:1). White on `#F770E3` is 2.51:1, so it is not allowed | Legibility | Adopted |
| D-03 | Contrast-sensitive brand text | — | Pink text on white is 2.51:1, so brand-context text (`color.text.brand`) resolves to ink instead of a darker second pink. The blue-era `brand.strong` and `brand.pressed` variants were removed | Accessible text without a second brand colour | Adopted |
| D-04 | Typography | Tiimo serif/sans; Meetup bold grotesk | Fraunces (display, regular weight) + Inter (text) | [Tiimo audit](tiimo-typography-audit.md) | Adopted |
| D-05 | Headline emphasis | Meetup colours one headline word | Emphasis by `color.text.brand-display` (exact `#F770E3`) on one display-size word; no underlines or ornaments. 2.51:1 on white is a documented exception limited to display sizes | Restraint; replaces the hand-drawn underline | Adopted |
| D-06 | Primary action | Bumble near-black pill; Meetup glossy ink pill | Ink pill with a subtle gloss (`button.primary.*`). The brand pink stays an accent, not the CTA fill | Strong CTA contrast; keeps pink for meaning (selected, verified, progress) | Adopted |
| D-07 | Step navigation | Bumble circular next bottom-right; Meetup full-width Next | Circular `Fab` next for data-entry steps (keeps the keyboard area free); full-width `Button` for decisions and summaries | Preserve Bumble's step UX on form steps | Adopted |
| D-08 | Modes | Date / BFF / Bizz | Dating only. No mode chooser at launch | Focus; reduces branching | Proposed |
| D-09 | Who messages first | Bumble: women message first in M/W matches (historically) | **Either person** can send the first message | Broader fit; simpler state model | Proposed |
| D-10 | Match timer | 24 h (screens) / 72 h (current docs) expiry, Extend, Rematch | Timer behaviour open; spec supports a `CountdownRing` | Needs product decision | Open |
| D-11 | Conversation-first profiles | Bumble prompts, Opening Moves | Prompt cards are first-class (welcome hero, profile, discovery); Opening Move kept as a pattern | Matches Numaya positioning: "Profiles built around conversation" | Adopted |
| D-12 | Verification | Phone + photo pose verification | Phone verification at sign-up (built); photo verification as a later trust step with a visible badge | Trust and safety parity | Proposed |
| D-13 | Safety | Report always blocks; anonymous; reasons list | Same rules. Report entry from card, profile and chat; result panel confirms block and follow-up | Industry baseline | Adopted (spec) |
| D-14 | Paywalls | Contextual, plan carousel, legal copy | Contextual paywall naming the trigger; plans as selectable cards; legal copy always visible; no dark patterns (no pre-selected longest plan or countdown pressure) | Ethics and store compliance | Proposed |
| D-15 | Filters | Basic/advanced, fallback toggles | Same structure; fallback toggles kept ("Show people outside this if I run out") | Prevents empty stacks | Proposed |
| D-16 | Country display | Emoji flags | ISO code badge (e.g. `US`) instead of emoji flags | Consistent cross-platform rendering, no emoji decoration | Adopted |
| D-17 | Tracking pre-prompt | ATT pre-prompt during onboarding | Not planned; only functional permissions (location, notifications, camera, photos) get primers | Privacy positioning | Proposed |
| D-18 | Surfaces | Meetup soft fills and white cards | Soft-filled fields, hairline cards, floating circular chrome | Visual audit | Adopted |
| D-19 | Simulated device chrome | — | Keypad, status bar and SMS banner are prototype-only and excluded from product tokens | Keeps the product system clean | Adopted |
| D-20 | Platform | Native iOS apps | Production framework **not established**. The browser prototype does not determine the mobile architecture | See [architecture](../engineering/architecture.md#production-framework) | Open |
| D-21 | Visual system (supersedes D-01, D-02, D-03, D-05 colour and D-06 accent) | Current Meetup iOS (sampled on Mobbin) | **Meetup visual system** with Numaya identity: brand purple `#7262C7` (white on it 4.90:1, purple links), ink CTAs and controls, Meetup greys and lavender surfaces, periwinkle guidance cards, pastel avatar framing, emphasis pink `#C1486A`. The `#F770E3` pink theme and decorative ribbons are retired | Product decision, October 2026; see [UI map](../numaya-meetup-ui-map.md#meetup-visual-system-migration-october-2026) | Adopted |
| D-22 | Primary action and prompt object (supersedes the "ink CTAs" part of D-21) | Apple Design + Impeccable refinement; skill-combination matrix (`artifacts/skill-combination-matrix/`) | **Purple owns the primary action:** primary buttons and the step FAB are flat brand purple with white labels (4.90:1). Ink stays for Pass and Like (`button.ink`) and neutral marks (badges, toasts). **The prompt is the conversation signature:** a lavender pull-quote object (`surface.brand`, deep-purple question, quiet quotation mark), the same on Discover, Profile, Edit profile and onboarding. **No kicker labels above headings** (setup steps, activity categories) | Impeccable critique P1 ("purple never owns a primary action"); conversation-first positioning. The matrix scored this approach highest | Adopted |

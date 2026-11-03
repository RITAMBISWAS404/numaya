# Screen implementation matrix

**How coverage works:**
- **Families:** all screen families of the Flutter app. The shared components move every screen.
  The rows below list the screen-specific work on top of that.
- **Captures:** 187 goldens, regenerated after review, in
  `apps/numaya_mobile/test/screenshots/goldens/`.
- **Evidence:** before/after sheets in [evidence/](evidence/).

| Family | Captures | System-level | Screen-specific | Status |
|---|---|---|---|---|
| Shell and navigation | all tab roots | Icon-only floating pill, tooltips, 48dp; shared top bar | — | Done |
| **Discovery** | `16`, `d019–d027`, `f02–f05`, `x01–x12`, `r01–r03` | Filled Pass, purple Like | **Image-first person card, decision row inside the hero card**; details offset measured; name step-down at large text | Done |
| **Profile** | `20`, `f17–f22`, `w01–w04`, `n10–n12` | Filled secondary, chips | **Hero card** (96pt avatar, name, badge, interests, Edit and Preview); **4-tile grid**; one Safety/Help/Settings group; completion slot | Done |
| **Account Health** | `h01–h10` | — | **Status-and-completeness hero** (52pt number, 10pt bar, status pill, action); parts list; "How this works" slot | Done |
| **Onboarding and auth** | `01–08`, `o01–o39`, `p06–p07` | Jakarta flow titles; **filled fields, code cells, country badge**; purple step segments | — | Done |
| **Messaging** | `19`, `d034–d052`, `f07–f13`, `n01–n06`, `w05–w06` | **Filled composer in a white tray**; chat list without rules; menus without rules | — | Done |
| Likes and match | `18`, `d030–d032`, `d054`, `d059`, `f06`, `f14` | Like back uses the new DecisionBar | — | Done |
| Events | `v01–v13`, `n07–n09` | Filled search; secondary buttons filled | **RSVP bar without hairline** | Done |
| Settings, safety, help, account | `22–23`, `f28–f41`, `d112b–d113`, `p04–p05` | Lists without dividers; sheets without header rules; filled fields | — | Done |
| Premium and verification | `f15–f16`, `f23–f27` | Brand variant on the Premium card | Paywall checked at 320pt and 200% | Done |
| Demo Hub and Design Lab | `f01`, `f38`, `m01` | — | **Navigation variants section** in the Lab | Done |
| Remaining routes and states | `q145–q158`, not-found, offline `p01–p03` | System-level only | — | Done |

## Deliberate exceptions
| Kept | Why |
|---|---|
| Radio, checkbox and switch outlines | Controls need a 3:1 boundary without colour |
| Event cover placeholders and the photo placeholder | No demo photography exists; the glyph marks the gap honestly |
| Verification viewfinder (ink) | A camera surface should be dark |
| Red notification dots, destructive actions, amber warnings | State colours, not brand |

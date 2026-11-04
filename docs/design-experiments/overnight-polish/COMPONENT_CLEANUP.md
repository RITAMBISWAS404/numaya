# Component cleanup

**Run:** 2026-11-04. Cloud worktree `/home/user/numaya-overnight`, branch
`experiment/numaya-overnight-polish`, HEAD `6b23c85`. **Local only, uncommitted.**

**Evidence:**
- golden-harness renders (Linux);
- widget tests;
- the source.

No emulator, device or Inspector: there is no Android SDK, and the Dart MCP server failed to
start.

**Skills:**
- `impeccable`, `apple-hig` and `emil-design-eng` (Emil Kowalski's skill) are present in the repo
  and were read. Applied from Emil's skill: quiet borders, press feedback kept on the row, no new
  motion. The Emil skill folder has no LICENSE file; check its upstream licence before
  redistributing.
- Forui was not needed: there was no gap the existing components couldn't fill.

## Component specification
| ID | Component (owner) | Before | After | Acceptance check |
|---|---|---|---|---|
| CL-01 | `NumayaSwitch` (`widgets/navigation.dart`) | Off: grey fill with a 1.5pt outline and a grey thumb. Disabled had no distinct look | **On:** purple track, white thumb. **Off:** light-grey track `#DDDDE3` (`AppColors.switchOff`), white thumb, **no track outline**; the thumb has an 8% ink edge and a soft shadow. **Disabled:** 45% opacity. **Pressed and focused:** owned by the `ListRow`/`Pressable` around it (press scale, focus ring, full-row hit area, `toggled` semantics) | `component_cleanup_test`: colours, no border, disabled opacity, the whole row toggles, toggled semantics, at least 48pt |
| CL-02 | `ListRow` leading icon | A 40pt `IconTile` in a semantic tint colour | A plain 24pt monochrome glyph (`textSecondary`), red only on destructive rows; label inset = 24 + 12; dividers start at the label | `final_polish_test` (updated): no `IconTile`, colour, size, text and divider insets |
| CL-03 | Tinted cards (`InfoCard`, `StatusBanner` in every tone) | Tint fill, no edge | Tint fill plus a 1pt border in the card's own hue at 15% (`AppColors.tintBorder`) | `component_cleanup_test`: width 1, alpha 0.15 |
| CL-04 | `MetaText` (`widgets/content.dart`) | Parts joined with " · " | Parts joined with an invisible joiner (U+2063) and rendered with a 1pt `borderStrong` vertical bar; the bar is excluded from semantics, and the parts are read as "A, B". User text is never split | `component_cleanup_test`; `v16_screens_test` (updated) |
| CL-06 | `Composer` (`widgets/people.dart`) | A white tray (30 radius, 6pt padding) around a filled field | No tray: attachment action, a filled pill field and send on the page, bottom-aligned, 8pt gaps | `component_cleanup_test`: no surface container. Existing chat tests cover multiline, keyboard, send and empty state |
| CL-07 | Demo copy | Chat had a "Sample conversation" badge, a per-message "Demo · saved on this device, not sent" and a footer. Account hold said "This is a preview of a screen the server would show". Settings carried location and push footnotes | Chat: **one** notice ("Demo chat: {name}'s messages are scripted, and what you send stays on this device.") plus a truthful status ("Not sent: saved on this device"). The account-hold sentence is removed. The Settings footnotes are removed, keeping the single Settings demo note; the Notifications screen keeps its push note | Tests updated to the new status wording; `component_cleanup_test` checks the badge is absent and there is one notice |

**Kept on purpose:**
- **Tinted marks:** verification illustration tiles, the Likes avatar mark and the "Up next" tag
  are marks, not cards, so they have no border.
- **Profile grid tiles** keep `IconTile` tones: they are a grid, not settings rows.
- **Demo notes at consequential moments** stay (paywall, verification, permissions, photo
  upload): they are pricing, consent and consequence information.
- **`ListRow.tone` and `inlineIcon`** remain for API compatibility and are documented as no-ops.

**Contrast:**
- Off-switch track `#DDDDE3` on white is about 1.3:1. Like the iOS switch, the off state is
  identified by the thumb (white with an edge and a shadow), its position, the row label and the
  toggled semantics, not by a 3:1 track. Flagged for a device review.
- The tint borders are decorative. Text contrast is unchanged.

## Mobbin (live; links are Mobbin's)
| Pattern | App and screen | What it supports |
|---|---|---|
| Settings rows and switches | [Cursor, Status](https://mobbin.com/screens/ef2cf22a-e8b3-4139-9b5e-23c0562c4718) | Plain line icons beside labels; a light-grey off track with a white thumb and no outline |
| Settings switches | [Venmo, Push Notifications](https://mobbin.com/screens/c9e32778-c869-4879-8982-878356e69632) | Rows without icon tiles; on/off by track colour and thumb position |
| Composer | [Discord, chat](https://mobbin.com/screens/5590805e-aea0-4148-9973-9bd079e91c2f) | A bare "+" beside one filled pill field; no tray |
| Composer | [ChatGPT, compose](https://mobbin.com/screens/6a78dca4-f9ef-42b4-bd25-2ddaf81c38d5) | Actions aligned to the input's baseline; the conversation dominant |
| Bottom tabs and profile | carried forward: Tinder, Coffee Meets Bagel and Hinge (frosted-navigation README); Hinge and Bumble (overnight matrix) | No new change this pass |

## Routes
| Route | What changed | Status |
|---|---|---|
| Settings, privacy, notifications, safety, account hold, help, delete account | Plain icons, switches, tinted-card borders, copy | Changed and reviewed (`artifacts/component-cleanup/1-settings-safety.jpg`) |
| Chat (all threads), inbox | Composer, one notice, status wording | Changed and reviewed (`2-inbox-chat.jpg`) |
| Profile, Discover, Account Health, sheets with info cards | Summary separator, tinted borders, row icons | Changed and reviewed (`3-profile-discover.jpg`) |
| Tab bar | Reviewed; unchanged (normalised and stress-tested in the overnight pass, `fn01`) | No change |

**Open:**
- the `MetaText` separator on the Likes tile caption, the event venue line and attachment
  details (localized strings, rendered through other tiles);
- Profile and Discover duplicate-information review: no clear duplicate found, so nothing removed;
- device checks of the switch states, the keyboard and navigation modes.

## Tests
| Command | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| `flutter analyze` | No issues found |
| `node tool/generate_tokens.mjs --check` | Dart tokens are up to date |
| `flutter test` | **334 passed, 14 skipped, 0 failed** (+8 in `test/widget/component_cleanup_test.dart`). Updated to the new decisions: `final_polish_test` (2: icons and insets), `v16_screens_test` (summary semantics), and 4 chat tests (status wording) |
| Captures | 20 passed; 93 goldens changed and reviewed per flow; 5 renderer-only restored |

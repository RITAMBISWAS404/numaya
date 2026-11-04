# Design direction and issue map

**Run:** 2026-11-04. Cloud worktree `/home/user/numaya-overnight`, branch
`experiment/numaya-overnight-polish`, HEAD `6b23c85`. **Local only, uncommitted.**

**Evidence:**
- golden renders (Linux);
- widget tests;
- the source.

No emulator, device or Inspector. The checks:

| Check | Result |
|---|---|
| `flutter test` | **334 passed, 14 skipped, 0 failed** |
| Format, analyze, token check | clean |
| Captures | 20 passed; only `f37-safety` changed (reviewed) |

## Design thesis
Calm surfaces, personal content first:
- **Colour:** purple only for the primary action, selection and "yours"; tint only for status.
- **Lists:** one grouped list language: a plain icon, a 16/22 label and a 13pt detail, with
  dividers starting at the text.
- **Type:** 14/20 reading body, 12/16 pills; display type only for names and screen titles.
- **Separators:** a vertical bar for metadata.
- **Depth:** glass only on the tab bar.
- **Illustration:** at orientation and empty moments only (the purple-cat mascot).

**Tasks served:**
- decide on a person (Discover, Profile);
- answer a match (Likes, Inbox, Chat);
- stay safe and in control (Settings, Safety, Account).

## Issue map (ranked by task impact × recurrence × confidence)
| # | Issue | Root cause | Status |
|---|---|---|---|
| 1 | Switch on and off looked like two systems | `NumayaSwitch` off state: outline plus grey thumb | **Fixed** (CL-01) |
| 2 | Coloured icon tiles add noise to settings | `ListRow` drew `IconTile` tones | **Fixed** (CL-02) |
| 3 | Tinted surfaces without edges | `InfoCard` and `StatusBanner` had no border | **Fixed** (CL-03) |
| 4 | Composer competed with the conversation; three demo notices in chat | `Composer` tray; notices in the badge, the status and the footer | **Fixed** (CL-06, CL-07) |
| 5 | Stacked explanation cards crowd guidance screens | Each tip was its own tinted `InfoCard` | **Fixed on Safety** (DX-01 below). Other `InfoCard`s were reviewed and kept: they carry privacy, consequence or demo-truth information (19 sites listed in this pass's audit) |
| 6 | Type, spacing and pill drift between features | literals at call sites | **Fixed** (TR-*, SP-*) |
| 7 | Metadata still uses " · " in the Likes caption, the event venue line and attachments | localized strings rendered by other tiles | **Open:** move these to `MetaText.join` with separate l10n parts |
| 8 | The illustration placeholder dominates the top of Safety (and other slots) | art not commissioned | **Open:** commission the slots or shrink the placeholder ratio |
| 9 | Navigation connection to content | glass tab bar reviewed in the overnight pass | **No change** (`fn01`, highlight) |

## DX-01: Safety tips, comparison
`artifacts/direction-2/safety-A-vs-B.png`, same content and viewport:
- **A:** three stacked tinted cards.
- **B:** one grouped list of plain icon rows, chosen.

**Why B:**
- one surface instead of three;
- the same row language as "Your tools" below it;
- "Your tools" (verify, block) moves up about 90pt.

**Cost:** the tips read like list rows. They have no chevron and no tap action, which separates
them from the tools rows. Nothing here comes from user testing.

## Mobbin used across these passes
| Topic | Screens |
|---|---|
| Settings and switches | [Cursor](https://mobbin.com/screens/ef2cf22a-e8b3-4139-9b5e-23c0562c4718), [Venmo](https://mobbin.com/screens/c9e32778-c869-4879-8982-878356e69632) |
| Composer | [Discord](https://mobbin.com/screens/5590805e-aea0-4148-9973-9bd079e91c2f), [ChatGPT](https://mobbin.com/screens/6a78dca4-f9ef-42b4-bd25-2ddaf81c38d5) |
| Long values | [Family](https://mobbin.com/screens/ea652c12-4d3b-4243-a8bb-842f19f12d1e), [Expedia](https://mobbin.com/screens/6fada74a-65ca-4c4b-9165-3aae27cbf940) |
| Dating patterns | Bumble, Hinge, Tinder, Phantom and Doji (links in README.md) |

The owner's seed references were not reopened this pass:
- Bumble edit-profile and interests;
- Messages;
- Brilliant settings;
- Jomo settings.

## Next highest-impact action
Issue 7: finish the metadata separator migration, then a device pass on Windows covering:
- the off-switch visibility;
- the keyboard over the frosted bar;
- TalkBack.

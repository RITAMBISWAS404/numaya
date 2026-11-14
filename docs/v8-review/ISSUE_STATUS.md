# Issue status (UI-001 to UI-086)

App source `fe44b27`. Full detail: ISSUE_LEDGER.csv.

| Disposition | Count |
|---|---|
| verified-existing | 35 |
| implemented | 34 |
| partial | 10 |
| alternatives-pending-choice | 6 |
| concept-only | 1 |

- **implemented**: changed in this run, with tests or renders as listed.
- **verified-existing**: already correct in the selected build; checked in this run's renders or emulator screens.
- **partial**: shared components done; the ledger says what was not re-audited.
- **alternatives-pending-choice**: built and rendered; the selected baseline stays the default (Premium uses direction A, which carries the approved requirements).
- **concept-only**: not built (UI-034, which conflicts with an earlier selection).

| Issue | Title | Disposition | Limitation |
|---|---|---|---|
| UI-001 | Rework the Get Started layout | implemented | Upper image with the Numaya name: artwork pending (stand-in brand image kept). |
| UI-002 | Give standalone secondary actions a shared button style | implemented |  |
| UI-003 | Separate selectable option rows | implemented |  |
| UI-004 | Contain age-range selectors in a card | verified-existing |  |
| UI-005 | Show the active age value above the slider | verified-existing | Tooltip body radius not re-measured against UI-050 8pt. |
| UI-006 | Make height selection inline | verified-existing |  |
| UI-007 | Make the response primary in prompt cards | implemented |  |
| UI-008 | Browse and answer prompts by category | verified-existing | "three-day-to-time-driven response" unresolved; nothing invented. |
| UI-009 | Stack illustrations above screen headings | verified-existing |  |
| UI-010 | Align alert icons with the top of the content | verified-existing |  |
| UI-011 | Standardize profile photos as portrait | verified-existing |  |
| UI-012 | Apply the typography scale consistently | implemented | 14 vs 15 production size pending owner. |
| UI-013 | Update the Discover header | verified-existing |  |
| UI-014 | Simplify profile photo overlays | verified-existing |  |
| UI-015 | Move shared interests below the photo | verified-existing |  |
| UI-016 | Remove swipe decision buttons | verified-existing |  |
| UI-017 | Keep profile actions in the photo menu | verified-existing |  |
| UI-018 | Separate the bio from profile details | verified-existing |  |
| UI-019 | Use emoji in profile detail pills | verified-existing |  |
| UI-020 | Use a consistent content card hierarchy | verified-existing |  |
| UI-021 | Replace Discover gender chips with a selector list | verified-existing | Cardinality preserved (multi-select, existing contract). |
| UI-022 | Give inactive pill tabs a visible boundary | verified-existing |  |
| UI-023 | Standardize popup and bottom sheet surfaces | verified-existing |  |
| UI-024 | Use the available width for slider tracks | verified-existing |  |
| UI-025 | Correct the off state of shared switches | verified-existing | Off track 1.45:1 on white: below 3:1, owner choice, recorded. |
| UI-026 | Compact the shared bottom navigation | implemented | Radius per UI-050 (20/12), not fully round. |
| UI-027 | Soften the bottom navigation shadow | verified-existing |  |
| UI-028 | Rebuild the match header and photo layout | verified-existing | Six alternatives under UI-082. |
| UI-029 | Put shared interests in a match card | verified-existing |  |
| UI-030 | Replace the match composer with profile and chat actions | verified-existing |  |
| UI-031 | Exclude Opening Moves from the first release | verified-existing |  |
| UI-032 | Exclude Follow from the first release | verified-existing |  |
| UI-033 | Show larger square tiles for new matches | implemented |  |
| UI-034 | Illustrate the Likes tile | concept-only | Conflicts with the owner selection that moved Likes to its own tab; needs a decision and mascot art. |
| UI-035 | Reveal exact chat timestamps on a left swipe | implemented |  |
| UI-036 | Reply to chat messages with a right swipe | verified-existing |  |
| UI-037 | Remove heavy outlines from inactive text fields | verified-existing |  |
| UI-038 | Place chat controls in a full-width white composer | verified-existing |  |
| UI-039 | Use an up arrow for chat Send | verified-existing |  |
| UI-040 | Use white bubbles for received chat messages | verified-existing |  |
| UI-041 | Remove demo-only copy from the app UI | partial | Honest disclosures kept where an action is simulated (purchase confirm, report, support, share date). Welcome demo entry kept by design. |
| UI-042 | Rebuild the profile summary card | alternatives-pending-choice | Selected Profile A remains the default until chosen. |
| UI-043 | Illustrate the profile completion card | alternatives-pending-choice | "If pursued": offered as options. |
| UI-044 | Standardize inner padding in list cards | implemented |  |
| UI-045 | Mute list card metadata and helper text | verified-existing |  |
| UI-046 | Refine the Complete your profile screen | verified-existing | T1-T6 header options via v8-stats. |
| UI-047 | Use pill outlines only when the surface needs a boundary | verified-existing |  |
| UI-048 | Use lighter neutral grays where suitable | partial | Not every grey in every screen re-audited. |
| UI-049 | Review padding consistency across the app | partial | No exhaustive per-screen padding audit this run. |
| UI-050 | Establish the Version 8 corner-radius system | implemented |  |
| UI-051 | Standardize selection-card minimum height and gaps | partial | Minimum height/gap not re-measured against the gender sheet this run. |
| UI-052 | Show calculated age only in the confirmation sheet | implemented |  |
| UI-053 | Organize dense information lists | partial | Onboarding review edit/private rows: icons not added this run. |
| UI-054 | Remove the duplicate Interests summary row | implemented |  |
| UI-055 | Remove redundant UI copy | partial | Full copy audit of every screen not completed. |
| UI-056 | Align paired labels and values consistently | partial | Not re-audited. |
| UI-057 | Use outlined disabled buttons | implemented |  |
| UI-058 | Match the owner preview to the public profile | implemented |  |
| UI-059 | Standardize profile content order | implemented |  |
| UI-060 | Standardize passive callout surfaces | implemented |  |
| UI-061 | Use illustrated cards for promotions and summaries | implemented | Artwork pending: reserved square. |
| UI-062 | Add a compact button for cards and menus | implemented |  |
| UI-063 | Hide suggested profiles for the initial release | implemented |  |
| UI-064 | Use one column for Likes profiles | implemented |  |
| UI-065 | Blur Likes photos for non-Premium users | implemented | Frontend presentation only; the service must not send clear photos to free clients. |
| UI-066 | Darken gradients behind text on photos | implemented |  |
| UI-067 | Standardize inbox previews and unread counts | implemented | Tabler has no filled message-heart: Compliment glyph stays outline. |
| UI-068 | Simplify conversation groups and turn status | implemented |  |
| UI-069 | Simplify the Archive entry | implemented |  |
| UI-070 | Use filled icons at compact sizes | partial | Voice-note play/pause glyph colour not re-checked. |
| UI-071 | Tighten quoted reply insets | implemented |  |
| UI-072 | Outline chat composer icon buttons | implemented | Send is an outlined circle with a purple arrow (literal reading of "same stroke"). |
| UI-073 | Match chat composer and reply preview fills | implemented |  |
| UI-074 | Consolidate shared design tokens across Version 8 | partial | Not a full token consolidation of every one-off value. |
| UI-075 | Exclude Travel from the MVP | implemented |  |
| UI-076 | Rework the Premium paywall | alternatives-pending-choice | 3 and 6 month prices and store products: BLOCKED (owner/store). |
| UI-077 | Plan mascot illustration placements across the app | partial | Placement survey limited to the slots listed; mascot art pending. |
| UI-078 | Standardize statistics summary cards | alternatives-pending-choice |  |
| UI-079 | Size text bubbles to their content | implemented |  |
| UI-080 | Space message groups by sender | verified-existing |  |
| UI-081 | Keep Archive focused on archived conversations | implemented |  |
| UI-082 | Explore six Match screen layouts | alternatives-pending-choice | Default stays the selected match. |
| UI-083 | Send Compliments through the chat composer | implemented | Live send unverified: backend BLOCKED. |
| UI-084 | Explore ten Profile hub layouts | alternatives-pending-choice |  |
| UI-085 | Compare display and UI font pairings | implemented | Production pairing and size pending owner. |
| UI-086 | Show a countdown-only expiry banner | implemented | Instant not offered. |

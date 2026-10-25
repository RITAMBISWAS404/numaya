# Screen inventory

The source of truth for coverage. Screens come from the route definitions, not filenames. There are
three entry-flow screens in `src/prototype/App.jsx`, plus 25 `flows.html?screen=<id>` screens in
`src/flows/Flows.jsx`. The states are those the project gallery (`scripts/gallery.mjs`) reaches by
driving the real UI.

**28 distinct product screens, 162 captured states** (including 9 desktop and 23 small-phone QA
captures). Gallery numbers (`#`) refer to [baseline](screenshots/baseline/README.md) and
[final](screenshots/final/README.md).

Status: **Refined** means changed and re-inspected. **Inherited** means it needed no screen-specific
change and was verified after the shared-system changes reached it.

| # | Screen (route) | Implementation | Key shared components | Baseline issues (audit) | Phase | Status |
|---|---|---|---|---|---|---|
| 001 | Welcome (`index.html`) | `src/prototype/screens/Welcome.jsx` | Button, Wordmark, IllustrationSlot | Ink primary, so purple never owns the first action. The upper half is the reserved hero slot (asset unsupplied). | 2 | <!--s:welcome--> |
| 002–005 | Phone number + country sheet | `src/prototype/screens/PhoneNumber.jsx` | PhoneField, Sheet, InfoCard, FAB | Ink "next" FAB. | 2 | <!--s:phone--> |
| 006–010 | Verify code + success sheet | `src/prototype/screens/VerifyCode.jsx` | CodeInput, Sheet, ResultPanel | Ink FAB and "Start over". | 2 | <!--s:verify--> |
| 011–012 | Verified → profile setup (`intro`) | `screens.jsx` SetupIntro | SetupStep, Button | "Step 1 of 3" kicker above each title (an eyebrow). Ink primary. | 2 | <!--s:intro--> |
| 013–015 | The basics (`basics`) | `screens.jsx` Basics | Field, RadioCard, CheckCard, FAB | Ink FAB. | 2 | <!--s:basics--> |
| 016–017 | Interests and prompt (`interests`) | `screens.jsx` InterestsPrompts | Chip, ProfilePrompt | Generic grey prompt card. | 2 | <!--s:interests--> |
| 018 | Photos (`photos`) | `screens.jsx` Photos | PhotoGrid, InfoCard | Ink FAB. | 2 | <!--s:photos--> |
| 019–029 | Home / Discover (`discovery`) + filters, options, share, empty, paused, undo | `screens.jsx` Discovery | ProfileCard, ProfileSection, ActionBar, Sheet, EmptyState | Name scrim 3.06:1. Prompt is a generic grey card. Ink sheet CTA and empty-state buttons. h1 → h3. | 3 | <!--s:discovery--> |
| 030–033 | It's a match (`match`) + no match yet | `screens.jsx` Match | MatchCelebration, Composer | One monogram: neither the pair nor what you share. | 4 | <!--s:match--> |
| 034–037, 051–052 | Messages (`chats`) + search, filters, alerts off, empty | `screens.jsx` Chats | SearchField, MatchRail, ConversationRow, FilterPills | Ink empty-state button. | 4 | <!--s:chats--> |
| 038–050, 053 | Conversation (`chat`) + options, unmatch/block/report sheets, ended states, openers | `screens.jsx` Chat | Bubble, Composer, Sheet, ResultPanel | Ink primary in sheets and ended states. Opener prompts are plain bordered rows. | 4 | <!--s:chat--> |
| 054–058 | Likes (`likes`) + filters, empty | `likes.jsx` Likes | LikeCard, FilterPills, EmptyState | Ink empty-state button. | 3 | <!--s:likes--> |
| 059–060 | Like back or pass (`like-profile`) | `likes.jsx` LikeProfile | ProfileCard, Button | Ink "Like back" and "Message". | 3 | <!--s:like-profile--> |
| 061–068 | Activity Explore (`activity`) + filters, area, empty, error | `activity.jsx` ActivityExplore | ActivityCard, Sheet, EmptyState | Category kicker above every card title (an eyebrow). Ink sheet CTA. | 5 | <!--s:activity--> |
| 069–084 | Activity details (`activity-detail`), 13 states + report and leave sheets | `activity.jsx` ActivityDetail | ActivityHero, MetaList, Button, Sheet | Category kicker above the title. Ink "Join" and "Request". | 5 | <!--s:activity-detail--> |
| 085–086 | Guests (`activity-people`) | `activity.jsx` ActivityPeople | PersonRow, Button | Ink "Approve". | 5 | <!--s:activity-people--> |
| 087–093 | Create / edit activity (`activity-form`) + errors, category, published | `activity-host.jsx` ActivityForm | Field, Select, Segmented, Switch, ResultPanel | Ink "Publish". | 5 | <!--s:activity-form--> |
| 094–098 | My activities (`my-activities`) | `activity-host.jsx` MyActivities | Tabs, ActivityCard, EmptyState | Category kicker on cards. | 5 | <!--s:my-activities--> |
| 099–101 | My profile (`profile`) | `screens.jsx` MyProfile | Avatar, ReadinessCard, ListGroup | The score leads and the prompt sits below the metric. Ink primary. Grey prompt. | 3 | <!--s:profile--> |
| 102–107, 118 | Edit profile + preview, photo options, name error (`edit`) | `screens.jsx` EditProfile | PhotoGrid, Field, Chip, ProfileCard | Grey prompt in the editor and the preview. | 3 | <!--s:edit--> |
| 108–110 | Edit prompt (`prompt`) | `screens.jsx` PromptEditor | RadioRow, Textarea | Ink save button. | 3 | <!--s:prompt--> |
| 111–113, 119, 130 | Settings + snooze, prototype tools, delete sheet (`settings`) | `screens.jsx` Settings | Slider, Switch, ListGroup, Sheet | Reviewed as calm already. | 5 | <!--s:settings--> |
| 114–117 | Profile readiness (`insights`) | `account.jsx` Insights | ScoreRing, MetricRows, InfoCard | Ink primary. | 5 | <!--s:insights--> |
| 120–121 | Blocked people (`blocked`) | `account.jsx` Blocked | PersonRow, EmptyState | Ink button. | 5 | <!--s:blocked--> |
| 122–123 | Premium (`premium`) + not-on-sale sheet | `account.jsx` Premium | PlanTable, Sheet | Ink "See Plus" and "Got it". | 5 | <!--s:premium--> |
| 124–126 | Connected accounts (`connections`) | `account.jsx` Connections | ConnectionRow, Sheet | Ink "Connect" buttons. | 5 | <!--s:connections--> |
| 127–128 | Help (`help`) + guide sheet | `account.jsx` Help | ListGroup, Sheet | Reviewed as calm already. | 5 | <!--s:help--> |
| 129 | Service unavailable (`maintenance`) | `account.jsx` Maintenance | ResultPanel | Ink "Try again". | 5 | <!--s:maintenance--> |

**Desktop context (131–139).** These are the prototype with its brief, the flow-previews gallery and
the design-system showcase. They are tools around the product, not product screens. They inherit the
shared-system changes and are re-captured, but not redesigned. <!--s:desktop-->

**Small-phone QA (140–162).** These are 375 × 667 captures of the screens above, used to check
overflow, clipping and fold behaviour. <!--s:qa-->

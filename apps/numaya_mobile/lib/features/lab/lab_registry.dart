import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// DEVELOPMENT ONLY. Visual Lab V2 (2026-11-08) variant registry: every card family, priority
/// screen and motion preset that has alternatives, with stable IDs shared by the Design Lab, the
/// offline review gallery (docs/design-experiments/visual-lab-v2/) and its exported JSON.
///
/// - Variant `O` is the current-rules baseline: it keeps every required behaviour (R01–R12), so
///   choosing it never restores reconnection or the old Compliment placement.
/// - [LabGroup.proposed] is what ordinary launches render. Since the Events pass (2026-11-08) it
///   holds the owner's Visual Lab selections (review vl2-8510778-2026-11-08); undecided screen
///   groups stay on O. The Insights groups were removed with Health/Insights.
/// - Alternatives render only after someone picks them in the Design Lab, and only where the Demo
///   Hub exists (demo sign-in available). Release builds always render [LabGroup.proposed]. There
///   is no random assignment, analytics or rollout, and a choice never changes data or navigates.
enum LabKind { component, screen, motion }

/// One alternative. [pass] names the reasoning pass from brief 10 (A structure, B hierarchy,
/// C relationship, D data, E illustration slot, F compact).
class LabVariant {
  const LabVariant(this.id, this.name, this.pass, this.note);
  final String id;
  final String name;
  final String pass;

  /// One line: what changes and the trade-off.
  final String note;
}

class LabGroup {
  const LabGroup({
    required this.id,
    required this.title,
    required this.kind,
    required this.question,
    required this.variants,
    required this.proposed,
    required this.usages,
    this.requires = const {},
  });

  /// Stable gallery ID, e.g. `compliment-card`.
  final String id;
  final String title;
  final LabKind kind;

  /// The experiment question held constant across variants (brief 10).
  final String question;
  final List<LabVariant> variants;

  /// The proposed default variant ID (not an owner decision).
  final String proposed;

  /// Where the family renders (screens and widgets), for the usage map.
  final List<String> usages;

  /// Screen variants that need a particular component variant: {screenVariant: [group:variant]}.
  final Map<String, List<String>> requires;

  List<String> get ids => [for (final v in variants) v.id];

  LabVariant variant(String id) =>
      variants.firstWhere((v) => v.id == id, orElse: () => variants.first);
}

const _o = 'O';

/// Every group, in gallery order: components, then screens, then motion.
/// Layout groups that belong to deferred Events (MVP Focus V5): hidden from the Lab and guarded.
bool isDeferredLabGroup(String id) =>
    id.contains('event') || id == 'ea-met-card';

const List<LabGroup> kLabGroups = [
  LabGroup(
    id: 'match-avatar',
    title: 'New match avatar',
    kind: LabKind.component,
    question: 'Can a member see which new matches are running out without reading a countdown?',
    usages: ['Chats: New matches row'],
    proposed: 'A',
    variants: [
      LabVariant(
        _o,
        'Circle with ring',
        'baseline',
        'Photo circle inside a ring that empties; nothing below.',
      ),
      LabVariant(
        'A',
        'Squircle ring',
        'B hierarchy',
        'Rounded-square photo traced by the ring; larger photo, ring follows the shape.',
      ),
      LabVariant(
        'B',
        'Circle ring and first name',
        'C relationship',
        'Adds the first name under the ring so members don’t rely on faces alone.',
      ),
      LabVariant(
        'C',
        'Compact circles',
        'F compact',
        'Smaller 56pt circles: more matches fit before scrolling; less photo.',
      ),
      LabVariant(
        'D',
        'Portrait with ring corner',
        'E expressive',
        'Tall portrait card; a small ring badge in the corner carries the time.',
      ),
    ],
  ),
  LabGroup(
    id: 'conversation-row',
    title: 'Conversation row',
    kind: LabKind.component,
    question: 'Can a member find whose turn it is and what was said last at a glance?',
    usages: ['Chats list', 'Archive'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Ente list row',
        'baseline',
        'Avatar, name, last message, time and unread count in one plain row.',
      ),
      LabVariant(
        'A',
        'Your turn first',
        'A structure',
        'A “Your turn” label replaces the time when they wrote last; time moves under it.',
      ),
      LabVariant(
        'B',
        'Separated cards',
        'B hierarchy',
        'Each conversation on its own white card; more separation, more height.',
      ),
      LabVariant(
        'C',
        'Large avatar',
        'C relationship',
        '56pt photo and two-line preview; faces lead, fewer rows per screen.',
      ),
      LabVariant(
        'D',
        'Dense single line',
        'F compact',
        'One line per conversation for heavy users; preview truncated sooner.',
      ),
    ],
  ),
  LabGroup(
    id: 'compliment-card',
    title: 'Compliment card',
    kind: LabKind.component,
    question: 'Does the member understand who wrote it, what it was about and how to answer?',
    usages: ['Heart tab: Compliments', 'Compliment detail'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Sender, quote, actions',
        'baseline',
        'Avatar and name, the Compliment, Reply and Not now buttons.',
      ),
      LabVariant(
        'A',
        'Quote-led editorial',
        'A structure',
        'The words lead in a large quote; sender and actions follow.',
      ),
      LabVariant(
        'B',
        'With what they noticed',
        'C relationship',
        'Shows the photo or prompt they complimented beside the words.',
      ),
      LabVariant(
        'C',
        'Compact row',
        'F compact',
        'One row per Compliment; open it to reply.',
      ),
      LabVariant(
        'D',
        'Photo-led',
        'B hierarchy',
        'Their photo as the card’s top half; words on the white half.',
      ),
    ],
  ),
  LabGroup(
    id: 'like-tile',
    title: 'Like tile',
    kind: LabKind.component,
    question: 'Can a Premium member scan who liked them; does free still understand the count?',
    usages: ['Heart tab: Likes (Premium grid, free locked)'],
    proposed: 'A',
    variants: [
      LabVariant(
        _o,
        'Photo tile, name below',
        'baseline',
        'Two columns, photo then name and age underneath.',
      ),
      LabVariant(
        'A',
        'Name on photo',
        'B hierarchy',
        'Full-bleed photo with name on the scrim; tighter grid.',
      ),
      LabVariant(
        'B',
        'List rows',
        'A structure',
        'One row per person with a like-back button; less photo.',
      ),
      LabVariant(
        'C',
        'Three columns',
        'F compact',
        'Smaller tiles, more people per screen.',
      ),
      LabVariant(
        'D',
        'Large cards',
        'C relationship',
        'One column with a prompt preview; slower to scan.',
      ),
    ],
  ),
  LabGroup(
    id: 'profile-header',
    title: 'Own profile header',
    kind: LabKind.component,
    question: 'Is it clear this is my profile, how it looks to others, and how to edit it?',
    usages: ['Profile tab'],
    proposed: 'A',
    variants: [
      LabVariant(
        _o,
        'Round photo and name',
        'baseline',
        'Centred photo, name, then Edit and Preview.',
      ),
      LabVariant(
        'A',
        'Banner and avatar',
        'B hierarchy',
        'Photo banner with the avatar overlapping it; pills for age, place, intention.',
      ),
      LabVariant(
        'B',
        'Compact identity row',
        'F compact',
        'Avatar left, name and pills right; actions in one row.',
      ),
      LabVariant(
        'C',
        'Profile with streak',
        'C relationship',
        'Identity plus the streak and credits in one card; fewer cards below.',
      ),
    ],
  ),
  LabGroup(
    id: 'profile-setup',
    title: 'Profile setup',
    kind: LabKind.component,
    question: 'Does the setup card help finish the profile without looking like a score?',
    usages: ['Profile', 'Insights (supporting)'],
    proposed: 'D',
    variants: [
      LabVariant(
        _o,
        'Title, bar, button',
        'baseline',
        'Setup readiness with a bar and one action.',
      ),
      LabVariant(
        'A',
        'Ente progress banner',
        'B hierarchy',
        'Banner with icon, title, subtitle and round arrow.',
      ),
      LabVariant(
        'B',
        'Next single task',
        'A structure',
        'Only the next missing item, with its action.',
      ),
      LabVariant(
        'C',
        'Checklist',
        'D data',
        'Every item ticked or open, expandable.',
      ),
      LabVariant(
        'D',
        'Slim row',
        'F compact',
        'One list row with a small ring.',
      ),
    ],
  ),
  LabGroup(
    id: 'prompt-card',
    title: 'Prompt answer',
    kind: LabKind.component,
    question: 'Can someone read the answer and find the Compliment action without overlap?',
    usages: ['Discover profile', 'Profile detail', 'Own profile preview'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Card with action footer',
        'baseline',
        'Question, answer, and a footer row reserved for the Compliment button.',
      ),
      LabVariant(
        'A',
        'Open editorial',
        'A structure',
        'No card: question, large answer, divider; footer action kept.',
      ),
      LabVariant(
        'B',
        'Quote',
        'B hierarchy',
        'Answer as a large quote with the question small above.',
      ),
      LabVariant(
        'C',
        'Question chip',
        'C relationship',
        'Question as a purple-tint chip, answer below.',
      ),
      LabVariant(
        'D',
        'Compact',
        'F compact',
        'Smaller answer type; tighter padding.',
      ),
    ],
  ),
  LabGroup(
    id: 'discover-photo',
    title: 'Discover photo',
    kind: LabKind.component,
    question: 'Is the person’s name readable and the Compliment action clearly theirs?',
    usages: ['Discover card', 'Profile detail photos'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Name on scrim',
        'baseline',
        'Name and job on the photo’s scrim; Compliment bottom-right.',
      ),
      LabVariant(
        'A',
        'Name below photo',
        'A structure',
        'Photo clean; identity on white below.',
      ),
      LabVariant(
        'B',
        'Name chip top-left',
        'B hierarchy',
        'Small name chip at the top; bottom left for pills.',
      ),
      LabVariant(
        'C',
        'Pills on photo',
        'C relationship',
        'Name plus distance and intention pills on the scrim.',
      ),
      LabVariant(
        'D',
        'Framed photo',
        'E expressive',
        'Inset photo on a white card with a caption line.',
      ),
    ],
  ),
  LabGroup(
    id: 'streak-card',
    title: 'Streak card',
    kind: LabKind.component,
    question: 'Does it show progress to the next reward without pressure?',
    usages: ['Profile', 'Streak page'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Approved streak card',
        'baseline',
        'The approved card: flame, days and the week row.',
      ),
      LabVariant(
        'A',
        'Week row only',
        'F compact',
        'Seven days, nothing else.',
      ),
      LabVariant(
        'B',
        'Next reward bar',
        'D data',
        'Days to the next credit as a bar.',
      ),
      LabVariant(
        'C',
        'Large number',
        'B hierarchy',
        'Day count large, explanation small.',
      ),
      LabVariant(
        'D',
        'Illustration slot',
        'E expressive',
        'Placeholder for the future cat beside the count.',
      ),
    ],
  ),
  LabGroup(
    id: 'wallet-card',
    title: 'Credit wallet',
    kind: LabKind.component,
    question: 'Can a member tell how many Compliments they can send and which credits go first?',
    usages: ['Wallet', 'Profile'],
    proposed: 'A',
    variants: [
      LabVariant(
        _o,
        'Balance and buckets',
        'baseline',
        'Total, then three bucket rows.',
      ),
      LabVariant(
        'A',
        'Stacked bar',
        'D data',
        'One bar split by bucket, in spend order.',
      ),
      LabVariant(
        'B',
        'Hero balance',
        'B hierarchy',
        'Large total; buckets in a list below.',
      ),
      LabVariant('C', 'Chips', 'F compact', 'Total with three small chips.'),
      LabVariant(
        'D',
        'Recent activity',
        'C relationship',
        'Balance with the last three ledger entries.',
      ),
    ],
  ),
  LabGroup(
    id: 'plan-card',
    title: 'Plan choice',
    kind: LabKind.component,
    question:
        'Is the full price and renewal clear for each plan, with no pressure?',
    usages: ['Paywall', 'Premium'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Plan cards',
        'baseline',
        'One card per plan with price and term.',
      ),
      LabVariant(
        'A',
        'Segmented term',
        'F compact',
        'Pick the term in a segment; one price panel.',
      ),
      LabVariant(
        'B',
        'Radio rows',
        'A structure',
        'One list, a radio per plan, full billed amount on the right.',
      ),
      LabVariant(
        'C',
        'Comparison table',
        'D data',
        'Free and Premium side by side.',
      ),
      LabVariant(
        'D',
        'Featured term',
        'B hierarchy',
        'Monthly large; longer terms as small rows (no savings badge).',
      ),
    ],
  ),
  LabGroup(
    id: 'status-banner',
    title: 'Status banner',
    kind: LabKind.component,
    question:
        'Does the banner say what happened and what to do, without alarm?',
    usages: [
      'Chat time left',
      'Archive',
      'Insights status',
      'Paused',
      'Restricted',
    ],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Tinted banner',
        'baseline',
        'Icon, title, body, optional action.',
      ),
      LabVariant(
        'A',
        'Ente banner with arrow',
        'B hierarchy',
        'White banner, icon tile, round arrow.',
      ),
      LabVariant(
        'B',
        'Inline note',
        'F compact',
        'Icon and one line, no container.',
      ),
      LabVariant('C', 'Outlined', 'A structure', 'Hairline outline, no fill.'),
      LabVariant(
        'D',
        'Full-width strip',
        'C relationship',
        'Edge-to-edge strip under the header.',
      ),
    ],
  ),
  LabGroup(
    id: 'empty-state',
    title: 'Empty state',
    kind: LabKind.component,
    question: 'Does an empty screen explain itself and offer one next step?',
    usages: ['Chats', 'Likes', 'Compliments', 'Archive', 'Insights no data'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Centred illustration slot',
        'baseline',
        'Placeholder box, title, body, one button.',
      ),
      LabVariant(
        'A',
        'Side slot',
        'E expressive',
        'Small placeholder left of the text; less height.',
      ),
      LabVariant('B', 'Text only', 'F compact', 'No art: title, body, button.'),
      LabVariant(
        'C',
        'Card',
        'B hierarchy',
        'Everything inside one white card.',
      ),
      LabVariant(
        'D',
        'Next steps',
        'A structure',
        'Title plus two or three tappable next steps.',
      ),
    ],
  ),
  // Ente alignment V3 (2026-11-08): Events layout questions. O is the current approved layout
  // with the V3 alignment fixes; alternatives wait for the owner's selection.
  LabGroup(
    id: 'ea-event-card',
    title: 'Event card (feed)',
    kind: LabKind.component,
    question: 'Can a member tell what, when and where at a glance, and scan several events?',
    usages: ['Events feed (E01)', 'Full event: other events (E02)'],
    proposed: 'P',
    variants: [
      LabVariant(
        _o,
        'Cover-led card',
        'baseline',
        'Wide cover, title, date line, place line, Free and availability badges.',
      ),
      LabVariant(
        'P',
        'Photo with date pill',
        'V4 default',
        'Photo leads with the date on a glass pill; title, place and one price and availability line.',
      ),
      LabVariant(
        'A',
        'Compact row',
        'F compact',
        'Square category thumbnail; date, title, place; twice as many events per screen.',
      ),
      LabVariant(
        'B',
        'Date-led',
        'B hierarchy',
        'Tinted date tile leads; time and place share one line; no cover.',
      ),
      LabVariant(
        'C',
        'Cover with date chip',
        'A structure',
        'Date chip on the cover; one merged status badge; fewer labels.',
      ),
    ],
  ),
  LabGroup(
    id: 'v4-event-detail',
    title: 'Event detail layout',
    kind: LabKind.screen,
    question:
        'Can a member tell what this is, when and where, and what to do next?',
    usages: ['Event detail (E02)'],
    proposed: 'G',
    variants: [
      LabVariant(
        _o,
        'Single fact list',
        'baseline',
        'The previous order: badges, then About, host, time and place in one long list.',
      ),
      LabVariant(
        'G',
        'Separated groups',
        'V4 default',
        'Wide photo, title; then logistics, about, who and good-to-know as their own white cards.',
      ),
      LabVariant(
        'I',
        'Imagery first',
        'A imagery',
        'A tall photo carries the title on a compact backing; logistics start below the fold.',
      ),
      LabVariant(
        'C',
        'Information first',
        'B density',
        'A small thumbnail beside the title; time and place are in the first view, less picture.',
      ),
    ],
  ),
  LabGroup(
    id: 'v4-photo-label',
    title: 'Name over a photo',
    kind: LabKind.screen,
    question:
        'Is the name readable on any photo without darkening the picture?',
    usages: ['Discover and person profile photo'],
    proposed: 'G',
    variants: [
      LabVariant(
        _o,
        'Dark panel',
        'baseline',
        'The previous solid 55% panel behind the name; over the owner’s 25% gradient cap.',
      ),
      LabVariant(
        'G',
        'Smooth gradient',
        'V5 default',
        'The name sits straight on the photo over an eased gradient under 25%, with a soft text shadow.',
      ),
      LabVariant(
        'P',
        'Compact glass label',
        'V4 default',
        'A hugging black glass label holds the name; the photo keeps a 10% gradient only.',
      ),
      LabVariant(
        'B',
        'Edge-to-edge glass bar',
        'A structure',
        'A full-width glass strip along the foot of the photo; steadier, covers more of it.',
      ),
    ],
  ),
  LabGroup(
    id: 'v4-welcome',
    title: 'Welcome brand area',
    kind: LabKind.component,
    question: 'Does the first screen feel confidently Numaya without a decorative tint?',
    usages: ['Welcome (temporary brand art, UI-001)'],
    proposed: 'S',
    variants: [
      LabVariant(
        _o,
        'Lavender tint',
        'baseline',
        'The previous pale purple panel.',
      ),
      LabVariant(
        'S',
        'Solid purple',
        'V4 default',
        'White mark on the solid brand colour; the strongest first impression.',
      ),
      LabVariant(
        'N',
        'Neutral page',
        'B quiet',
        'Purple mark on the grey page; calmer, less branded.',
      ),
    ],
  ),
  LabGroup(
    id: 'ea-event-filters',
    title: 'Event filters (feed)',
    kind: LabKind.component,
    question:
        'Can a member change city, date and activity without a crowded header?',
    usages: ['Events feed (E01)'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'City field and two pill rows',
        'baseline',
        'Full-width city field, then date pills, then activity pills.',
      ),
      LabVariant(
        'A',
        'One row of dropdown chips',
        'F compact',
        'City, date and activity as three disclosure chips on one row; each opens a sheet.',
      ),
      LabVariant(
        'B',
        'City chip with date pills',
        'B hierarchy',
        'City becomes the first chip of the date row; activity pills stay below.',
      ),
    ],
  ),
  LabGroup(
    id: 'ea-event-action',
    title: 'Event detail action bar',
    kind: LabKind.component,
    question: 'Is the price and availability clear at the moment of reserving?',
    usages: ['Event detail (E02)'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Full-width button',
        'baseline',
        'One full-width primary button pinned at the bottom.',
      ),
      LabVariant(
        'A',
        'Summary and button',
        'B hierarchy',
        'Free and places left on the left, a compact primary button on the right.',
      ),
      LabVariant(
        'B',
        'Availability line above',
        'D data',
        'A one-line availability note above the full-width button.',
      ),
    ],
  ),
  LabGroup(
    id: 'ea-met-card',
    title: 'People I met card',
    kind: LabKind.component,
    question: 'Can a member decide on each person calmly, with the actions clearly paired?',
    usages: ['People I met (E07)'],
    proposed: _o,
    variants: [
      LabVariant(
        _o,
        'Row with paired buttons',
        'baseline',
        'Photo, name and chevron; Pass and Interested as equal buttons below.',
      ),
      LabVariant(
        'A',
        'Photo card',
        'A structure',
        'A large photo leads (4:3), the name under it; Pass and Interested below.',
      ),
      LabVariant(
        'B',
        'Compact row with icon actions',
        'F compact',
        'One row: photo, name, then labelled round Pass and Interested buttons.',
      ),
    ],
  ),
  // Screens: three coherent directions (brief 10) plus the current-rules baseline.
  LabGroup(
    id: 'screen-profile',
    title: 'Profile screen',
    kind: LabKind.screen,
    question: 'Does Profile show identity, setup and activity without a wall of cards?',
    usages: ['/profile'],
    proposed: _o,
    variants: _directions,
    requires: {
      'A': ['profile-setup:D'],
      // profile-header D (the Insights header) was removed with Insights (H-13); C keeps A.
      'C': [
        'profile-header:A',
        'streak-card:B',
        'wallet-card:A',
        'profile-setup:A',
      ],
    },
  ),
  LabGroup(
    id: 'screen-heart',
    title: 'Likes and Compliments',
    kind: LabKind.screen,
    question: 'Are likes and Compliments easy to tell apart and answer?',
    usages: ['/likes'],
    proposed: _o,
    variants: _directions,
    requires: {
      'A': ['like-tile:B', 'compliment-card:C'],
      'B': ['compliment-card:B'],
      'C': ['like-tile:A', 'compliment-card:D'],
    },
  ),
  LabGroup(
    id: 'screen-chats',
    title: 'Chats',
    kind: LabKind.screen,
    question: 'Are new matches, your-turn chats and the archive easy to find?',
    usages: ['/messages'],
    proposed: _o,
    variants: _directions,
    requires: {
      'A': ['match-avatar:B', 'conversation-row:D'],
      'B': ['conversation-row:B'],
      'C': ['match-avatar:D', 'conversation-row:C'],
    },
  ),
  LabGroup(
    id: 'screen-discover',
    title: 'Discover profile',
    kind: LabKind.screen,
    question: 'Does the profile read as a person, with actions that never cover text?',
    usages: ['/home'],
    proposed: _o,
    variants: _directions,
    requires: {
      'A': ['discover-photo:A', 'prompt-card:A'],
      'B': ['discover-photo:O', 'prompt-card:C'],
      'C': ['discover-photo:C', 'prompt-card:B'],
    },
  ),
  LabGroup(
    id: 'motion',
    title: 'Motion preset',
    kind: LabKind.motion,
    question: 'Does motion explain changes without slowing anything down?',
    usages: ['App-wide (MotionTokens)'],
    proposed: 'M1',
    variants: [
      LabVariant(
        'M0',
        'Reduced / static',
        'motion',
        'No movement; short fades only. Same as the system “remove animations”.',
      ),
      LabVariant(
        'M1',
        'Restrained (proposed)',
        'motion',
        'Feedback 120ms, state 200ms, sheets and routes 280ms, decelerating.',
      ),
      LabVariant(
        'M2',
        'Restrained, quicker',
        'motion',
        'Feedback 100ms, state 160ms, sheets and routes 240ms.',
      ),
    ],
  ),
];

const List<LabVariant> _directions = [
  LabVariant(
    _o,
    'Current-rules baseline',
    'baseline',
    'Today’s layout with every required change applied.',
  ),
  LabVariant(
    'A',
    'Quiet editorial',
    'A structure',
    'Generous type hierarchy, few surfaces, dividers instead of cards.',
  ),
  LabVariant(
    'B',
    'Connected cards',
    'C relationship',
    'Separated actionable cards, each with a short summary and one action.',
  ),
  LabVariant(
    'C',
    'Visual insights',
    'D data',
    'Data-led summaries and compact charts where numbers are comparable.',
  ),
];

LabGroup labGroup(String id) => kLabGroups.firstWhere((g) => g.id == id);

/// The Design Lab's choices: group ID → variant ID. Empty means the proposed default everywhere.
class LabChoices extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void choose(String group, String variant) =>
      state = {...state, group: variant};

  /// Every group to [variant] where it exists (the Lab's "show all O" / direction shortcuts).
  void chooseAll(String variant, {LabKind? kind}) => state = {
    ...state,
    for (final g in kLabGroups)
      if ((kind == null || g.kind == kind) && g.ids.contains(variant))
        g.id: variant,
  };

  void reset() => state = const {};
}

final labChoicesProvider = NotifierProvider<LabChoices, Map<String, String>>(
  LabChoices.new,
);

/// The variant a widget renders for [groupId]: the Lab's choice where the Demo Hub exists,
/// otherwise always the proposed default.
final labVariantProvider = Provider.family<String, String>((ref, groupId) {
  final group = labGroup(groupId);
  if (ref.watch(demoAuthProvider) == null) return group.proposed;
  return ref.watch(labChoicesProvider)[groupId] ?? group.proposed;
});

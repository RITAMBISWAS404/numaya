import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// DEVELOPMENT ONLY. Overnight v3 layout experiments (docs/design-experiments/
/// ente-design-system/overnight-v3/EXPERIMENTS.md).
///
/// Each experiment is chosen on its own: EXP-001 B and EXP-002 A can be combined. The refined
/// candidate ([ExpVariant.current]) is the normal experience; an alternative shows only after
/// someone picks it in the Experiment Lab, and only where the Demo Hub exists (demo sign-in is
/// available). Release builds always render [ExpVariant.current]. There is no random assignment,
/// analytics or rollout, and changing a variant never changes data or navigates.
enum ExpVariant {
  current('Current'),
  a('A'),
  b('B'),
  c('C');

  const ExpVariant(this.letter);

  /// "Current", "A", "B" or "C", as the review gallery and USER_CHOICES.csv spell it.
  final String letter;
}

/// One experiment family: its stable ID, what it changes and the descriptive name of each
/// alternative (labels for the lab; the screens never show them).
enum Experiment {
  matchMoment(
    id: 'EXP-001-match-moment',
    title: 'Match moment',
    names: {
      ExpVariant.current: 'Refined candidate: portrait, line, shared interests',
      ExpVariant.a: 'Paired portraits',
      ExpVariant.b: 'Identity-led photo hero',
      ExpVariant.c: 'Restrained cat celebration',
    },
  ),
  profileHeader(
    id: 'EXP-002-own-profile-header',
    title: 'Own-profile upper section',
    names: {
      ExpVariant.current: 'Refined candidate: round photo over the card',
      ExpVariant.a: 'Photo-led cover',
      ExpVariant.b: 'Compact identity row',
      ExpVariant.c: 'Identity with quick actions',
    },
  ),
  emptyChats(
    id: 'EXP-003-empty-conversations',
    title: 'Empty conversations',
    names: {
      ExpVariant.current: 'Refined candidate: illustrated card',
      ExpVariant.a: 'Cat says hello',
      ExpVariant.b: 'Next steps list',
      ExpVariant.c: 'Open page, one action',
    },
  ),
  completionCard(
    id: 'EXP-004-profile-completion-card',
    title: 'Profile completion card',
    names: {
      ExpVariant.current: 'Refined candidate: title, bar, button',
      ExpVariant.a: 'Ente progress banner',
      ExpVariant.b: 'Next single task',
      ExpVariant.c: 'Cat encouragement',
    },
  );

  const Experiment({
    required this.id,
    required this.title,
    required this.names,
  });

  final String id;
  final String title;
  final Map<ExpVariant, String> names;
}

/// The lab's choices. Empty means every experiment shows the refined candidate.
class ExperimentChoices extends Notifier<Map<Experiment, ExpVariant>> {
  @override
  Map<Experiment, ExpVariant> build() => const {};

  void choose(Experiment experiment, ExpVariant variant) =>
      state = {...state, experiment: variant};

  void resetAll() => state = const {};
}

final experimentChoicesProvider =
    NotifierProvider<ExperimentChoices, Map<Experiment, ExpVariant>>(
      ExperimentChoices.new,
    );

/// The variant a screen renders: the lab's choice where the Demo Hub exists, otherwise always
/// the refined candidate.
final experimentVariantProvider = Provider.family<ExpVariant, Experiment>((
  ref,
  experiment,
) {
  if (ref.watch(demoAuthProvider) == null) return ExpVariant.current;
  return ref.watch(experimentChoicesProvider)[experiment] ?? ExpVariant.current;
});

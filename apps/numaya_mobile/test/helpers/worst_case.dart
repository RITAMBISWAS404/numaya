import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';
import 'package:numaya_mobile/features/profile/application/profile_details_controller.dart';
import 'package:numaya_mobile/features/profile/domain/profile_details.dart';

/// Worst-case member data for break-ui checks: every value is plausible or at the app's own
/// limit, entered through the same controllers the screens use.

String atLimit(String sentence, int limit) {
  final b = StringBuffer();
  while (b.length < limit) {
    b.write(b.isEmpty ? sentence : ' $sentence');
  }
  return b.toString().substring(0, limit).trimRight();
}

/// The longest values a person can enter: a long hyphenated first name (the field has no
/// limit), answers at their character limits, an unbreakable link in the bio, the five longest
/// interests and every detail filled.
void applyWorstCase(ProviderContainer c) {
  final onboarding = c.read(onboardingProvider.notifier);
  onboarding.setFirstName('Mary-Elizabeth Anne-Marie');
  for (final i in [...c.read(onboardingProvider).draft.interests]) {
    onboarding.toggleInterest(i);
  }
  final longest = [...kInterestEmoji.keys]
    ..sort((a, b) => b.length.compareTo(a.length));
  longest.take(5).forEach(onboarding.toggleInterest);
  onboarding.setPrompt(
    kPromptQuestions.reduce((a, b) => a.length >= b.length ? a : b),
    atLimit('Honestly a very long walk to nowhere in particular', 150),
  );
  final details = c.read(profileDetailsProvider.notifier);
  details.setBio(
    atLimit(
      'Find me at https://example.com/mary-elizabeth-anne-marie/portfolio/2026 or on the river.',
      DetailRules.bioLength,
    ),
  );
  for (final key in AboutKey.values) {
    details.setAbout(key, atLimit('Senior Product Design Lead, Northwind', 60));
  }
  for (final key in DetailKey.values) {
    final options = key.options;
    details.setDetail(
      key,
      options.reduce((a, b) => a.length >= b.length ? a : b),
    );
  }
  details.setHeight(DetailRules.maxHeight);
  for (final l in kLanguages.take(DetailRules.maxLanguages)) {
    details.toggleLanguage(l);
  }
  for (var i = 0; i < DetailRules.maxOpeningMoves; i++) {
    details.setOpeningMove(
      i,
      atLimit(
        'What is the most unexpectedly brilliant thing you have eaten',
        DetailRules.openingMoveLength,
      ),
    );
  }
}

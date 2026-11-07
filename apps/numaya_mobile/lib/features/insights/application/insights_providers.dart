import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dating/application/dating_controller.dart';
import '../../premium/application/premium_controller.dart';
import '../domain/insights_fixture.dart';

/// Which sample scenario Insights shows (the Design Lab and Demo Hub switch it; ordinary demo
/// launches show [InsightsScenario.typical], or [InsightsScenario.premiumHistory] with Premium).
class InsightsScenarioChoice extends Notifier<InsightsScenario?> {
  @override
  InsightsScenario? build() => null;

  void choose(InsightsScenario? s) => state = s;
}

final insightsScenarioProvider =
    NotifierProvider<InsightsScenarioChoice, InsightsScenario?>(
      InsightsScenarioChoice.new,
    );

/// The scenario in effect.
final effectiveInsightsScenarioProvider = Provider<InsightsScenario>((ref) {
  final chosen = ref.watch(insightsScenarioProvider);
  if (chosen != null) return chosen;
  return ref.watch(premiumProvider).active
      ? InsightsScenario.premiumHistory
      : InsightsScenario.typical;
});

/// Sample insights for a period (7 free; 28 and 90 with Premium).
final insightsSnapshotProvider = Provider.family<InsightsSnapshot, int>((
  ref,
  days,
) {
  return sampleInsights(ref.watch(effectiveInsightsScenarioProvider), days);
});

/// Counts that come from the member's own demo chats (not samples): conversations waiting for
/// the member's reply, and archived conversations.
final chatCountsProvider = Provider<({int yourTurn, int archived})>((ref) {
  ref.watch(datingProvider);
  final dating = ref.read(datingProvider.notifier);
  final convs = dating.conversations();
  return (
    yourTurn: convs.where((p) => dating.yourMove(p.id)).length,
    archived: dating.archivedConversations().length,
  );
});

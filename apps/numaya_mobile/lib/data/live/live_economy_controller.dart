import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logging/app_logger.dart';
import '../../core/time/ist.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/commerce/application/economy_controller.dart';
import '../../features/commerce/domain/credit_ledger.dart';
import '../../features/likes/domain/allowances.dart';
import '../../features/streaks/domain/streak.dart';
import 'live_errors.dart';
import 'live_providers.dart';

/// [EconomyController] on the live backend (backend V1): balances, today's likes and the streak
/// run are the server's (`my_wallet`). Nothing is granted, spent or counted on the device; the
/// server's transactional endpoints do that. Purchases go through the store gateway, which in a
/// live build is the unconfigured one (no billing yet): nothing can be bought or granted.
class LiveEconomyController extends EconomyController {
  static const _log = AppLogger('LiveWallet');

  SupabaseClient get _db => ref.read(supabaseClientProvider);

  @override
  EconomyState build() {
    final session = ref.watch(sessionProvider);
    final p = policy;
    final base = EconomyState(
      ledger: CreditLedger(earnedCap: p.earnedCap),
      streak: StreakState(
        decisionsNeeded: p.streakDecisionsPerDay,
        cycleDays: p.streakCycleDays,
        recoveryWindow: Duration(hours: p.recoveryWindowHours),
      ),
    );
    if (session != null) Future.microtask(refreshWallet);
    return base;
  }

  /// Reloads the wallet from the server. Called after anything that changes it.
  Future<void> refreshWallet() async {
    if (_db.auth.currentUser == null || !ref.mounted) return;
    try {
      final w = (await guardLive(() => _db.rpc<dynamic>('my_wallet')) as Map)
          .cast<String, dynamic>();
      final now = DateTime.now();
      final today = istDay(now);
      LedgerEntry balance(CreditBucket b, int n) => LedgerEntry(
        key: 'server:${b.name}',
        kind: LedgerKind.grant,
        bucket: b,
        amount: n,
        at: now,
        source: 'server balance',
      );
      final streak = (w['streak'] as Map).cast<String, dynamic>();
      final run = streak['run'] as int? ?? 0;
      final todayDone = streak['today_qualified'] == true;
      final limit = policy.likesPerDay(premium: w['premium'] == true);
      final used = (limit - (w['likes_left_today'] as int? ?? limit)).clamp(
        0,
        limit,
      );
      // The server's counts, in the shapes the approved screens already read. The placeholder
      // ids below are counters only; no person is ever derived from them.
      state = state.copyWith(
        ledger: CreditLedger(
          earnedCap: policy.earnedCap,
          entries: [
            for (final b in CreditBucket.values)
              if ((w[b.name] as int? ?? 0) > 0) balance(b, w[b.name] as int),
          ],
        ),
        likes: LikeQuota(
          likesByDay: {
            today: {for (var i = 0; i < used; i++) 'used-$i'},
          },
        ),
        streak: StreakState(
          decisionsNeeded: policy.streakDecisionsPerDay,
          cycleDays: policy.streakCycleDays,
          recoveryWindow: Duration(hours: policy.recoveryWindowHours),
          days: {
            for (var i = todayDone ? 0 : 1; i < run + (todayDone ? 0 : 1); i++)
              today - i: const DayActivity(messages: 1),
          },
        ),
      );
    } on LiveFailure catch (e) {
      _log.warning('Wallet refresh failed: ${e.code}');
    }
  }

  // The server decides all of these inside its transactions; refresh to show the result.
  @override
  bool spendLike(String recipient) => true;

  @override
  void recordDecision(String profileId) => unawaited(refreshWallet());

  @override
  void recordMessage() => unawaited(refreshWallet());

  @override
  GrantOutcome grantWelcome() {
    unawaited(refreshWallet()); // granted by complete_onboarding on the server
    return GrantOutcome(GrantStatus.duplicate, 0, state.ledger);
  }

  @override
  void syncWeekly() => unawaited(refreshWallet());
}

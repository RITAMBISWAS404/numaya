import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/time/ist.dart';
import '../../../data/live/live_config.dart';
import '../../../data/live/live_economy_controller.dart';
import '../../dating/application/dating_controller.dart'
    show DemoWorld, demoWorldProvider;
import '../../likes/domain/allowances.dart';
import '../../premium/application/premium_controller.dart';
import '../../streaks/domain/streak.dart';
import '../data/store_gateway.dart';
import '../domain/catalog.dart';
import '../domain/credit_ledger.dart';

/// A purchase as recorded on this device (`purchases` on the server, unique by store transaction).
@immutable
class PurchaseRecord {
  const PurchaseRecord({
    required this.key,
    required this.product,
    required this.at,
    required this.outcome,
    this.demo = true,
  });

  final String key;
  final Product product;
  final DateTime at;
  final PurchaseOutcome outcome;

  /// Simulated: no money moved.
  final bool demo;
}

/// The latest streak award, for the explanation shown when the earned bank was full.
@immutable
class AwardNotice {
  const AwardNotice(this.result, this.at);
  final AwardResult result;
  final DateTime at;
}

@immutable
class EconomyState {
  const EconomyState({
    this.ledger = const CreditLedger(),
    this.likes = const LikeQuota(),
    this.extensions = const ExtensionAllowance(),
    this.streak = const StreakState(),
    this.purchases = const [],
    this.lastAward,
    this.nextKey = 1,
  });

  final CreditLedger ledger;
  final LikeQuota likes;
  final ExtensionAllowance extensions;
  final StreakState streak;
  final List<PurchaseRecord> purchases;
  final AwardNotice? lastAward;
  final int nextKey;

  EconomyState copyWith({
    CreditLedger? ledger,
    LikeQuota? likes,
    ExtensionAllowance? extensions,
    StreakState? streak,
    List<PurchaseRecord>? purchases,
    AwardNotice? lastAward,
    int? nextKey,
  }) => EconomyState(
    ledger: ledger ?? this.ledger,
    likes: likes ?? this.likes,
    extensions: extensions ?? this.extensions,
    streak: streak ?? this.streak,
    purchases: purchases ?? this.purchases,
    lastAward: lastAward ?? this.lastAward,
    nextKey: nextKey ?? this.nextKey,
  );
}

/// The store checkout for this build: the demo store in demo builds, otherwise one that reports
/// "not available" (never success).
final storeGatewayProvider = Provider<StoreGateway>(
  (ref) => ref.watch(demoAuthProvider) != null
      ? DemoStoreGateway()
      : const UnconfiguredStoreGateway(),
);

/// Credits, like allowance, extensions, streak and purchases: the deterministic demo
/// implementation of the server's transactional rules (PRD 02, 05). Every method is idempotent on
/// its key; nothing here can be called to fake a verified purchase in a live build, because the
/// gateway there never reports success.
class EconomyController extends Notifier<EconomyState> {
  static const _log = AppLogger('Economy');

  DateTime get _now => ref.read(clockProvider)();
  Catalog get catalog => ref.read(catalogProvider);
  AllowancePolicy get policy => catalog.policy;
  bool get _premium => ref.read(premiumProvider).active;

  @override
  EconomyState build() {
    final p = ref.read(catalogProvider).policy;
    // Premium weekly credits follow the subscription.
    ref.listen(premiumProvider, (_, _) => syncWeekly());
    final base = EconomyState(
      ledger: CreditLedger(earnedCap: p.earnedCap),
      streak: StreakState(
        decisionsNeeded: p.streakDecisionsPerDay,
        cycleDays: p.streakCycleDays,
        recoveryWindow: Duration(hours: p.recoveryWindowHours),
      ),
    );
    final now = ref.read(clockProvider)();
    final seeded = ref.watch(demoWorldProvider) == DemoWorld.full
        ? _seedFullWorld(base, now, p)
        : base;
    // Premium may already be active when this is first read.
    return _syncWeekly(seeded, ref.read(premiumProvider), now, p);
  }

  String _key(String prefix) {
    final n = state.nextKey;
    state = state.copyWith(nextKey: n + 1);
    return '$prefix:$n';
  }

  // Likes --------------------------------------------------------------------------------------
  int likesLeft() => state.likes.remaining(_now, policy, premium: _premium);
  int likesLimit() => policy.likesPerDay(premium: _premium);
  DateTime likesReset() => state.likes.nextReset(_now);

  /// Debits the like allowance for [recipient]. False when it is used up. Liking the same person
  /// again never spends twice.
  bool spendLike(String recipient) {
    final next = state.likes.spend(recipient, _now, policy, premium: _premium);
    if (next == null) return false;
    state = state.copyWith(likes: next);
    return true;
  }

  // Extensions ---------------------------------------------------------------------------------
  bool extensionAvailable() =>
      state.extensions.available(_now, premium: _premium);
  DateTime extensionReset() =>
      state.extensions.nextReset(_now, premium: _premium);
  void useExtension() =>
      state = state.copyWith(extensions: state.extensions.use(_now));

  // Credits ------------------------------------------------------------------------------------
  CreditLedger get ledger => state.ledger;

  /// Three welcome credits, once, after eligible profile completion.
  GrantOutcome grantWelcome() {
    final out = state.ledger.grant(
      bucket: CreditBucket.earned,
      amount: policy.welcomeCredits,
      key: 'welcome',
      source: 'welcome',
      at: _now,
    );
    state = state.copyWith(ledger: out.ledger);
    return out;
  }

  /// Spends one credit for [source]; replaying [key] is a no-op.
  SpendOutcome spendCredit({required String key, required String source}) {
    syncWeekly();
    final out = state.ledger.spend(key: key, source: source, at: _now);
    state = state.copyWith(ledger: out.ledger);
    return out;
  }

  /// A technical failure after the spend: the credit comes back.
  void refundSpend(String key) =>
      state = state.copyWith(ledger: state.ledger.reverseSpend(key, at: _now));

  /// Premium weekly credits: three each subscription week from activation, no rollover.
  void syncWeekly() {
    final next = _syncWeekly(state, ref.read(premiumProvider), _now, policy);
    if (!identical(next, state)) state = next;
  }

  /// When the next Premium weekly allowance arrives.
  DateTime? nextWeeklyGrant() {
    final start = ref.read(premiumProvider).activatedAt;
    if (start == null || !_premium) return null;
    final week = _now.difference(start).inDays ~/ 7;
    return start.add(Duration(days: (week + 1) * 7));
  }

  // Streak ------------------------------------------------------------------------------------
  void recordDecision(String profileId) {
    state = state.copyWith(
      streak: state.streak.recordDecision(_now, profileId),
    );
    _settleAwards();
  }

  void recordMessage() {
    state = state.copyWith(streak: state.streak.recordMessage(_now));
    _settleAwards();
  }

  /// Explicit profile-review completion: qualifies only when neither a decision nor a message is
  /// possible (the caller checks that and passes [eligible]).
  bool recordReview({required bool eligible}) {
    if (!eligible) return false;
    state = state.copyWith(streak: state.streak.recordReview(_now));
    _settleAwards();
    return true;
  }

  void _settleAwards() {
    for (final cycle in state.streak.pendingAwards(_now)) {
      final out = state.ledger.grant(
        bucket: CreditBucket.earned,
        amount: policy.streakRewardCredits,
        key: 'streak:$cycle',
        source: 'streak:$cycle',
        at: _now,
      );
      final result = out.status == GrantStatus.skippedAtCap
          ? AwardResult.skippedAtCap
          : AwardResult.granted;
      state = state.copyWith(
        ledger: out.ledger,
        streak: state.streak.copyWith(
          awards: {...state.streak.awards, cycle: result},
        ),
        lastAward: AwardNotice(result, _now),
      );
      _log.info('Streak cycle ${result.name}');
    }
  }

  RecoveryOffer? recoveryOffer() => state.streak.recoveryOffer(_now);

  // Purchases ---------------------------------------------------------------------------------
  /// Buys [kind] through the store. Entitlement is applied only for a verified purchase; in the
  /// demo the verification is local and every record is marked demo. Recovery is rechecked before
  /// the store is called and again before it is applied: if it is no longer allowed, nothing is
  /// charged.
  Future<PurchaseOutcome> purchase(ProductKind kind) async {
    final product = catalog.product(kind);
    final gateway = ref.read(storeGatewayProvider);
    final key = _key('purchase');
    final offer = kind == ProductKind.streakRecovery ? recoveryOffer() : null;
    if (kind == ProductKind.streakRecovery && offer == null) {
      return _record(key, product, PurchaseOutcome.ineligible);
    }
    ref.read(premiumProvider.notifier).setPurchasing(true);
    final result = await gateway.buy(product, idempotencyKey: key);
    if (!ref.mounted) return PurchaseOutcome.cancelled;
    ref.read(premiumProvider.notifier).setPurchasing(false);
    final outcome = switch (result) {
      StoreResult.purchased => PurchaseOutcome.success,
      StoreResult.pending => PurchaseOutcome.pending,
      StoreResult.cancelled => PurchaseOutcome.cancelled,
      StoreResult.failed => PurchaseOutcome.failed,
      StoreResult.unavailable => PurchaseOutcome.unavailable,
    };
    if (outcome != PurchaseOutcome.success) {
      return _record(key, product, outcome);
    }
    switch (kind) {
      case ProductKind.premiumWeekly ||
          ProductKind.premiumMonthly ||
          ProductKind.premiumYearly:
        ref.read(premiumProvider.notifier).activate(product);
        syncWeekly();
      case ProductKind.complimentPack:
        state = state.copyWith(
          ledger: state.ledger
              .grant(
                bucket: CreditBucket.purchased,
                amount: product.credits,
                key: 'grant:$key',
                source: 'purchase:$key',
                at: _now,
              )
              .ledger,
        );
      case ProductKind.streakRecovery:
        final repaired = state.streak.repair(offer!.missedDay, _now);
        // The server would refuse and void the charge; the demo records it as ineligible.
        if (repaired == null) {
          return _record(key, product, PurchaseOutcome.ineligible);
        }
        state = state.copyWith(streak: repaired);
        _settleAwards();
    }
    return _record(key, product, PurchaseOutcome.success);
  }

  PurchaseOutcome _record(String key, Product p, PurchaseOutcome o) {
    state = state.copyWith(
      purchases: [
        ...state.purchases,
        PurchaseRecord(
          key: key,
          product: p,
          at: _now,
          outcome: o,
          demo: !ref.read(storeGatewayProvider).live,
        ),
      ],
    );
    _log.info('Purchase ${p.kind.name}: ${o.name}');
    return o;
  }

  // Demo world --------------------------------------------------------------------------------
  /// Demo Hub: spend the rest of today's likes (on placeholder ids), to show S17.
  void exhaustLikes() {
    var i = 0;
    while (likesLeft() > 0 && i < 100) {
      spendLike('demo-tool-${i++}');
    }
  }

  /// Demo Hub: put the earned bank at its cap, to show the skipped-award explanation.
  void fillEarnedBank() {
    final room = policy.earnedCap - state.ledger.earned;
    if (room <= 0) return;
    state = state.copyWith(
      ledger: state.ledger
          .grant(
            bucket: CreditBucket.earned,
            amount: room,
            key: _key('demo_fill'),
            source: 'demo_tool',
            at: _now,
          )
          .ledger,
    );
  }
}

/// Brings the weekly bucket up to date with the subscription (pure; returns [s] unchanged when
/// nothing is due).
EconomyState _syncWeekly(
  EconomyState s,
  PremiumState premium,
  DateTime now,
  AllowancePolicy policy,
) {
  final start = premium.activatedAt;
  if (!premium.active || start == null) {
    // Lapsed Premium: weekly credits stop with it (earned and purchased are untouched).
    final expired = s.ledger.expireWeekly(
      key: 'expire:lapsed:${s.ledger.entries.length}',
      at: now,
    );
    return identical(expired, s.ledger) ? s : s.copyWith(ledger: expired);
  }
  final week = now.difference(start).inDays ~/ 7;
  final anchor = start.millisecondsSinceEpoch;
  final grantKey = 'premium_week:$anchor:$week';
  if (s.ledger.has(grantKey)) return s;
  var ledger = s.ledger.expireWeekly(key: 'expire:$anchor:$week', at: now);
  ledger = ledger
      .grant(
        bucket: CreditBucket.weekly,
        amount: policy.premiumWeeklyCredits,
        key: grantKey,
        source: 'premium_week:$week',
        at: now,
      )
      .ledger;
  return s.copyWith(ledger: ledger);
}

/// The explorable demo's account history: welcome credits (one already spent on the sent
/// Compliment), four streak days, a missed day the day before yesterday and yesterday kept, so
/// recovery is open.
EconomyState _seedFullWorld(EconomyState s, DateTime now, AllowancePolicy p) {
  final today = istDay(now);
  var ledger = s.ledger
      .grant(
        bucket: CreditBucket.earned,
        amount: p.welcomeCredits,
        key: 'welcome',
        source: 'welcome',
        at: now.subtract(const Duration(days: 9)),
      )
      .ledger;
  ledger = ledger
      .spend(
        key: 'compliment:seed-finn',
        source: 'compliment:seed-finn',
        at: now.subtract(const Duration(days: 1)),
      )
      .ledger;
  final days = <IstDay, DayActivity>{
    for (final d in [today - 6, today - 5, today - 4, today - 3, today - 1])
      d: const DayActivity(messages: 1),
  };
  return s.copyWith(
    ledger: ledger,
    streak: s.streak.copyWith(days: days),
  );
}

final economyProvider = NotifierProvider<EconomyController, EconomyState>(
  // Live backend builds read the server wallet (backend V1); demo builds are unchanged.
  () => LiveConfig.enabled ? LiveEconomyController() : EconomyController(),
);

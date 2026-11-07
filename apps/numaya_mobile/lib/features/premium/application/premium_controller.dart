import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';
import '../../commerce/domain/catalog.dart';

/// What opened the paywall (D-14), so its title can name it.
enum PremiumFeature {
  likes,
  seeLikes,
  advancedFilters,
  extension,
  insights,
  compliments,
  // Retired from the MVP paywall; kept so stale deep links land on the general paywall.
  rematch,
  extendUnlimited,
  incognito,
  travel,
  superSwipes,
  general,
}

/// The catalog (served by the backend in a live build; the provisional demo catalog here).
final catalogProvider = Provider<Catalog>((ref) => kProvisionalCatalog);

enum PurchaseOutcome {
  success,
  pending,
  failed,
  cancelled,
  unavailable,
  ineligible,
}

/// One Premium tier, billed weekly, monthly or yearly (PRD 06). Entitlement:
/// 15 likes a day, 3 weekly Compliments, incoming likes, advanced filters, a daily extension and
/// deeper insights. Cancelling keeps it until [paidThrough]; expiry removes the advanced controls
/// but keeps the saved preferences.
@immutable
class PremiumState {
  const PremiumState({
    this.plan,
    this.activatedAt,
    this.paidThrough,
    this.autoRenew = true,
    this.purchasing = false,
    this.incognito = false,
    this.travelCity,
    this.extraSuperSwipes = 0,
  });

  final Product? plan;

  /// Anchors the weekly Compliment allowance (independent of the billing term).
  final DateTime? activatedAt;
  final DateTime? paidThrough;

  /// False once cancelled: the plan stays active until [paidThrough].
  final bool autoRenew;
  final bool purchasing;

  /// Deferred features (not in the MVP); kept so their dormant code compiles.
  final bool incognito;
  final String? travelCity;
  final int extraSuperSwipes;

  bool get active => plan != null;

  /// Kept for older call sites: the plan's renewal date.
  DateTime? get activeUntil => paidThrough;

  PremiumState copyWith({
    Product? plan,
    bool clearPlan = false,
    DateTime? activatedAt,
    DateTime? paidThrough,
    bool? autoRenew,
    bool? purchasing,
    bool? incognito,
    String? travelCity,
    bool clearTravel = false,
    int? extraSuperSwipes,
  }) => PremiumState(
    plan: clearPlan ? null : (plan ?? this.plan),
    activatedAt: clearPlan ? null : (activatedAt ?? this.activatedAt),
    paidThrough: clearPlan ? null : (paidThrough ?? this.paidThrough),
    autoRenew: clearPlan ? true : (autoRenew ?? this.autoRenew),
    purchasing: purchasing ?? this.purchasing,
    incognito: incognito ?? this.incognito,
    travelCity: clearTravel ? null : (travelCity ?? this.travelCity),
    extraSuperSwipes: extraSuperSwipes ?? this.extraSuperSwipes,
  );
}

/// Premium entitlement as the app sees it. Changed only through [activate] (called by the
/// purchase flow after verification, or the Demo Hub), [cancel] and [expire].
class PremiumController extends Notifier<PremiumState> {
  static const _log = AppLogger('Premium');

  DateTime get _now => ref.read(clockProvider)();

  @override
  PremiumState build() => const PremiumState();

  void setPurchasing(bool value) => state = state.copyWith(purchasing: value);

  /// A verified subscription purchase (or the Demo Hub switch).
  void activate(Product plan) {
    final now = _now;
    state = state.copyWith(
      plan: plan,
      activatedAt: state.activatedAt ?? now,
      paidThrough:
          (state.paidThrough != null && state.paidThrough!.isAfter(now)
                  ? state.paidThrough!
                  : now)
              .add(Duration(days: plan.billingDays ?? 30)),
      autoRenew: true,
      purchasing: false,
    );
    _log.info('Premium active (${plan.kind.name})');
  }

  /// Demo Hub: switch Premium on (monthly) or off without the paywall.
  void setActive(bool active) {
    if (active) {
      activate(ref.read(catalogProvider).product(ProductKind.premiumMonthly));
    } else {
      expire();
    }
  }

  /// Cancels renewal; the benefits continue until the paid-through date.
  void cancel() => state = state.copyWith(autoRenew: false);

  /// The paid-through date passed (or the Demo Hub ended it): advanced controls stop applying;
  /// saved preferences are kept by their owners.
  void expire() => state = state.copyWith(
    clearPlan: true,
    incognito: false,
    clearTravel: true,
  );

  void setIncognito(bool value) {
    if (!state.active) return;
    state = state.copyWith(incognito: value);
  }

  void setTravel(String? city) {
    if (!state.active) return;
    state = city == null
        ? state.copyWith(clearTravel: true)
        : state.copyWith(travelCity: city);
  }

  /// Uses one bought SuperSwipe (dormant feature); false when none are left.
  bool useSuperSwipe() {
    if (state.extraSuperSwipes <= 0) return false;
    state = state.copyWith(extraSuperSwipes: state.extraSuperSwipes - 1);
    return true;
  }
}

final premiumProvider = NotifierProvider<PremiumController, PremiumState>(
  PremiumController.new,
);

/// Cities for Travel mode (dormant feature).
const List<String> kTravelCities = [
  'Mumbai',
  'Delhi',
  'Bengaluru',
  'Hyderabad',
  'Chennai',
];

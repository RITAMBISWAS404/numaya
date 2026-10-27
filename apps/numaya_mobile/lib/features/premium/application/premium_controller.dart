import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/logging/app_logger.dart';

/// Premium features the demo gates (P-05 is open; this is the recommended starting set).
enum PremiumFeature {
  advancedFilters,
  rematch,
  extendUnlimited,
  incognito,
  travel,
  superSwipes,
  general,
}

/// A plan on the paywall (B-61). Prices are illustrative and labelled as such: no store is
/// connected and nothing is charged.
@immutable
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.weeks,
    required this.label,
    required this.price,
    required this.perWeek,
    this.saving,
  });
  final String id;
  final int weeks;
  final String label;
  final String price;
  final String perWeek;
  final String? saving;
}

const List<PremiumPlan> kPremiumPlans = [
  PremiumPlan(
    id: 'week',
    weeks: 1,
    label: '1 week',
    price: '£9.99',
    perWeek: '£9.99/week',
  ),
  PremiumPlan(
    id: 'month',
    weeks: 4,
    label: '1 month',
    price: '£24.99',
    perWeek: '£6.25/week',
    saving: 'Save 37%',
  ),
  PremiumPlan(
    id: 'quarter',
    weeks: 13,
    label: '3 months',
    price: '£49.99',
    perWeek: '£3.85/week',
    saving: 'Save 61%',
  ),
];

enum PurchaseOutcome { success, failed, cancelled }

@immutable
class PremiumState {
  const PremiumState({
    this.activePlan,
    this.activeUntil,
    this.purchasing = false,
    this.incognito = false,
    this.travelCity,
    this.extraSuperSwipes = 0,
  });

  final PremiumPlan? activePlan;
  final DateTime? activeUntil;
  final bool purchasing;
  final bool incognito;
  final String? travelCity;
  final int extraSuperSwipes;

  bool get active => activePlan != null;

  PremiumState copyWith({
    PremiumPlan? activePlan,
    bool clearPlan = false,
    DateTime? activeUntil,
    bool? purchasing,
    bool? incognito,
    String? travelCity,
    bool clearTravel = false,
    int? extraSuperSwipes,
  }) => PremiumState(
    activePlan: clearPlan ? null : (activePlan ?? this.activePlan),
    activeUntil: clearPlan ? null : (activeUntil ?? this.activeUntil),
    purchasing: purchasing ?? this.purchasing,
    incognito: incognito ?? this.incognito,
    travelCity: clearTravel ? null : (travelCity ?? this.travelCity),
    extraSuperSwipes: extraSuperSwipes ?? this.extraSuperSwipes,
  );
}

/// Simulated premium (B-60–B-64). "Buying" a plan only flips local state after a short delay; the
/// UI says that no payment is taken. Restore finds nothing because no store is connected.
class PremiumController extends Notifier<PremiumState> {
  static const _log = AppLogger('Premium');

  @override
  PremiumState build() => const PremiumState();

  Future<PurchaseOutcome> purchase(
    PremiumPlan plan, {
    PurchaseOutcome simulate = PurchaseOutcome.success,
  }) async {
    state = state.copyWith(purchasing: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!ref.mounted) return PurchaseOutcome.cancelled;
    if (simulate != PurchaseOutcome.success) {
      state = state.copyWith(purchasing: false);
      _log.info('Demo purchase ${simulate.name}');
      return simulate;
    }
    final now = ref.read(clockProvider)();
    state = state.copyWith(
      purchasing: false,
      activePlan: plan,
      activeUntil: now.add(Duration(days: plan.weeks * 7)),
      extraSuperSwipes: state.extraSuperSwipes + 5,
    );
    _log.info('Demo plan active');
    return PurchaseOutcome.success;
  }

  /// Demo Hub: switch premium on or off without the paywall.
  void setActive(bool active) {
    if (active) {
      final now = ref.read(clockProvider)();
      state = state.copyWith(
        activePlan: kPremiumPlans[1],
        activeUntil: now.add(const Duration(days: 28)),
      );
    } else {
      state = state.copyWith(
        clearPlan: true,
        incognito: false,
        clearTravel: true,
      );
    }
  }

  void cancel() => state = state.copyWith(
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

  /// Uses one bought SuperSwipe; false when none are left.
  bool useSuperSwipe() {
    if (state.extraSuperSwipes <= 0) return false;
    state = state.copyWith(extraSuperSwipes: state.extraSuperSwipes - 1);
    return true;
  }
}

final premiumProvider = NotifierProvider<PremiumController, PremiumState>(
  PremiumController.new,
);

/// Cities for Travel mode (sample).
const List<String> kTravelCities = [
  'Manchester',
  'Edinburgh',
  'Lisbon',
  'Berlin',
  'New York',
];

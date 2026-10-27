import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/profile_draft.dart';
import '../../profile/domain/profile_details.dart';

/// Discovery filters (B-34 basic, B-35 advanced, Mobbin "Filtering people"). Each group has a
/// fallback switch ("Show other people if I run out", D-15) used only when nobody fits.
@immutable
class DiscoveryFilters {
  const DiscoveryFilters({
    this.genders = const {},
    this.minAge = 24,
    this.maxAge = 38,
    this.ageFallback = false,
    this.maxDistanceKm = 25,
    this.distanceFallback = false,
    this.verifiedOnly = false,
    this.minHeightCm,
    this.intentions = const {},
    this.details = const {},
    this.advancedFallback = true,
  });

  static const int ageFloor = 18;
  static const int ageCeiling = 80;
  static const int distanceCeilingKm = 160;

  /// Fallbacks widen age by 2 years each side and distance by half again.
  static const int ageFallbackYears = 2;
  static const double distanceFallbackFactor = 1.5;

  /// Empty means everyone.
  final Set<Gender> genders;
  final int minAge;
  final int maxAge;
  final bool ageFallback;
  final int maxDistanceKm;
  final bool distanceFallback;
  final bool verifiedOnly;

  /// Advanced (premium in the demo, P-05).
  final int? minHeightCm;
  final Set<String> intentions;
  final Map<DetailKey, Set<String>> details;
  final bool advancedFallback;

  bool get hasAdvanced =>
      minHeightCm != null || intentions.isNotEmpty || details.isNotEmpty;

  DiscoveryFilters copyWith({
    Set<Gender>? genders,
    int? minAge,
    int? maxAge,
    bool? ageFallback,
    int? maxDistanceKm,
    bool? distanceFallback,
    bool? verifiedOnly,
    int? minHeightCm,
    bool clearHeight = false,
    Set<String>? intentions,
    Map<DetailKey, Set<String>>? details,
    bool? advancedFallback,
  }) => DiscoveryFilters(
    genders: genders ?? this.genders,
    minAge: minAge ?? this.minAge,
    maxAge: maxAge ?? this.maxAge,
    ageFallback: ageFallback ?? this.ageFallback,
    maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    distanceFallback: distanceFallback ?? this.distanceFallback,
    verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    minHeightCm: clearHeight ? null : (minHeightCm ?? this.minHeightCm),
    intentions: intentions ?? this.intentions,
    details: details ?? this.details,
    advancedFallback: advancedFallback ?? this.advancedFallback,
  );

  /// Without the advanced filters (when premium isn't active).
  DiscoveryFilters basicOnly() => DiscoveryFilters(
    genders: genders,
    minAge: minAge,
    maxAge: maxAge,
    ageFallback: ageFallback,
    maxDistanceKm: maxDistanceKm,
    distanceFallback: distanceFallback,
    verifiedOnly: verifiedOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is DiscoveryFilters &&
      setEquals(other.genders, genders) &&
      other.minAge == minAge &&
      other.maxAge == maxAge &&
      other.ageFallback == ageFallback &&
      other.maxDistanceKm == maxDistanceKm &&
      other.distanceFallback == distanceFallback &&
      other.verifiedOnly == verifiedOnly &&
      other.minHeightCm == minHeightCm &&
      setEquals(other.intentions, intentions) &&
      mapEquals(other.details, details) &&
      other.advancedFallback == advancedFallback;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(genders),
    minAge,
    maxAge,
    ageFallback,
    maxDistanceKm,
    distanceFallback,
    verifiedOnly,
    minHeightCm,
    Object.hashAllUnordered(intentions),
    details.length,
    advancedFallback,
  );
}

/// Intentions offered by the advanced filter (the same answers as "Looking for").
const List<String> kIntentionFilters = [
  'Long-term',
  'Open to seeing',
  'Something casual',
];

/// Discovery preferences for this session. A backend sends them with discovery requests later.
class DiscoveryFiltersController extends Notifier<DiscoveryFilters> {
  @override
  DiscoveryFilters build() => const DiscoveryFilters();

  /// "Widen age and distance": the full range.
  void broaden() => state = state.copyWith(
    minAge: DiscoveryFilters.ageFloor,
    maxAge: DiscoveryFilters.ageCeiling,
    maxDistanceKm: DiscoveryFilters.distanceCeilingKm,
  );

  void save(DiscoveryFilters filters) {
    final minAge = filters.minAge.clamp(
      DiscoveryFilters.ageFloor,
      DiscoveryFilters.ageCeiling,
    );
    final maxAge = filters.maxAge.clamp(minAge, DiscoveryFilters.ageCeiling);
    state = filters.copyWith(minAge: minAge, maxAge: maxAge);
  }
}

final discoveryFiltersProvider =
    NotifierProvider<DiscoveryFiltersController, DiscoveryFilters>(
      DiscoveryFiltersController.new,
    );

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class DiscoveryFilters {
  const DiscoveryFilters({
    this.minAge = 24,
    this.maxAge = 38,
    this.maxDistanceKm = 25,
  });

  static const int ageFloor = 18;
  static const int ageCeiling = 80;
  static const int distanceCeilingKm = 160;

  final int minAge;
  final int maxAge;
  final int maxDistanceKm;

  DiscoveryFilters copyWith({int? minAge, int? maxAge, int? maxDistanceKm}) =>
      DiscoveryFilters(
        minAge: minAge ?? this.minAge,
        maxAge: maxAge ?? this.maxAge,
        maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      );

  @override
  bool operator ==(Object other) =>
      other is DiscoveryFilters &&
      other.minAge == minAge &&
      other.maxAge == maxAge &&
      other.maxDistanceKm == maxDistanceKm;

  @override
  int get hashCode => Object.hash(minAge, maxAge, maxDistanceKm);
}

/// Discovery preferences for this session. A backend sends them with discovery requests later.
class DiscoveryFiltersController extends Notifier<DiscoveryFilters> {
  @override
  DiscoveryFilters build() => const DiscoveryFilters();

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

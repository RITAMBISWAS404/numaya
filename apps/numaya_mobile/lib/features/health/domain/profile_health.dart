import 'package:flutter/foundation.dart';

/// Profile Health, formula v1 (PRD 04). Subtitle "Profile setup": it measures setup readiness only,
/// never attractiveness, and it never changes ranking and cannot be bought.
///
/// | Factor                                   | Points |
/// |------------------------------------------|--------|
/// | Identity, preferences and intention      | 30     |
/// | Two approved photos                      | 20     |
/// | Bio                                      | 15     |
/// | First prompt                             | 15     |
/// | Third photo (optional)                   | 10     |
/// | Second prompt (optional)                 | 10     |
///
/// A profile with every required part starts at 80.
const String kHealthFormulaVersion = 'v1';

enum HealthFactor { basics, photos, bio, firstPrompt, thirdPhoto, secondPrompt }

extension HealthFactorPoints on HealthFactor {
  int get points => switch (this) {
    HealthFactor.basics => 30,
    HealthFactor.photos => 20,
    HealthFactor.bio => 15,
    HealthFactor.firstPrompt => 15,
    HealthFactor.thirdPhoto => 10,
    HealthFactor.secondPrompt => 10,
  };

  bool get required => switch (this) {
    HealthFactor.thirdPhoto || HealthFactor.secondPrompt => false,
    _ => true,
  };
}

@immutable
class HealthInput {
  const HealthInput({
    required this.basicsComplete,
    required this.approvedPhotos,
    required this.hasBio,
    required this.prompts,
  });

  /// Name, birthday (18+), gender, who to meet, age range and intention.
  final bool basicsComplete;
  final int approvedPhotos;
  final bool hasBio;
  final int prompts;
}

@immutable
class ProfileHealth {
  const ProfileHealth(this.done);

  final Set<HealthFactor> done;

  int get score => done.fold(0, (s, f) => s + f.points);

  bool get requiredComplete =>
      HealthFactor.values.where((f) => f.required).every(done.contains);

  List<HealthFactor> get missing => [
    for (final f in HealthFactor.values)
      if (!done.contains(f)) f,
  ];

  factory ProfileHealth.of(HealthInput i) => ProfileHealth({
    if (i.basicsComplete) HealthFactor.basics,
    if (i.approvedPhotos >= 2) HealthFactor.photos,
    if (i.hasBio) HealthFactor.bio,
    if (i.prompts >= 1) HealthFactor.firstPrompt,
    if (i.approvedPhotos >= 3) HealthFactor.thirdPhoto,
    if (i.prompts >= 2) HealthFactor.secondPrompt,
  });
}

/// Whether others can see the profile in Discover. Separate from the score. A missing service
/// response is [unknown], never [restricted].
enum DiscoveryStatus {
  visible,
  paused,
  incomplete,
  underReview,
  restricted,
  unknown,
}

DiscoveryStatus discoveryStatus({
  required bool? serviceAvailable,
  required bool restricted,
  required bool paused,
  required bool requiredComplete,
  required bool photosPendingReview,
}) {
  if (serviceAvailable != true) return DiscoveryStatus.unknown;
  if (restricted) return DiscoveryStatus.restricted;
  if (paused) return DiscoveryStatus.paused;
  if (!requiredComplete) {
    return photosPendingReview
        ? DiscoveryStatus.underReview
        : DiscoveryStatus.incomplete;
  }
  return DiscoveryStatus.visible;
}

/// An exposure-to-like rate, or why it is not shown (PRD 04: threshold 20 distinct qualified
/// exposures, a product heuristic rather than statistical certainty).
@immutable
class RateReading {
  const RateReading({
    required this.exposures,
    required this.likes,
    required this.threshold,
  });
  final int exposures;
  final int likes;
  final int threshold;

  bool get lowSample => exposures < threshold;

  /// Percentage, or null under the threshold.
  int? get percent =>
      lowSample || exposures == 0 ? null : (likes * 100 / exposures).round();
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';

enum PhotoVerificationStatus { notStarted, pending, verified, rejected }

/// Poses the member is asked to copy (randomised in a real build; deterministic here).
const List<({String emoji, String instruction})> kVerificationPoses = [
  (emoji: '✋', instruction: 'Hold up your open hand next to your face'),
  (emoji: '👍', instruction: 'Give a thumbs up with your right hand'),
  (emoji: '✌️', instruction: 'Show a peace sign under your chin'),
];

@immutable
class PhotoVerificationState {
  const PhotoVerificationState({
    this.status = PhotoVerificationStatus.notStarted,
    this.attempts = 0,
    this.pose = 0,
    this.approveNext = true,
  });

  final PhotoVerificationStatus status;

  /// Rejected attempts so far; after three the flow points to support (states-and-recovery).
  final int attempts;
  final int pose;

  /// Demo Hub: the outcome the next simulated review gives.
  final bool approveNext;

  bool get verified => status == PhotoVerificationStatus.verified;

  PhotoVerificationState copyWith({
    PhotoVerificationStatus? status,
    int? attempts,
    int? pose,
    bool? approveNext,
  }) => PhotoVerificationState(
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    pose: pose ?? this.pose,
    approveNext: approveNext ?? this.approveNext,
  );
}

/// Photo verification (B-56–B-58), simulated: no camera is used and no review happens. The demo
/// "review" resolves after a short wait with the outcome chosen in the Demo Hub (approve by
/// default), and the UI says so.
class PhotoVerificationController extends Notifier<PhotoVerificationState> {
  static const _log = AppLogger('Verification');
  static const maxAttempts = 3;
  static const reviewTime = Duration(seconds: 2);

  @override
  PhotoVerificationState build() => const PhotoVerificationState();

  void nextPose() => state = state.copyWith(
    pose: (state.pose + 1) % kVerificationPoses.length,
  );

  Future<void> submit() async {
    state = state.copyWith(status: PhotoVerificationStatus.pending);
    _log.info('Demo verification submitted');
    await Future<void>.delayed(reviewTime);
    if (!ref.mounted || state.status != PhotoVerificationStatus.pending) {
      return;
    }
    state = state.approveNext
        ? state.copyWith(status: PhotoVerificationStatus.verified)
        : state.copyWith(
            status: PhotoVerificationStatus.rejected,
            attempts: state.attempts + 1,
          );
  }

  void setApproveNext(bool value) => state = state.copyWith(approveNext: value);

  void reset() =>
      state = PhotoVerificationState(approveNext: state.approveNext);
}

final photoVerificationProvider =
    NotifierProvider<PhotoVerificationController, PhotoVerificationState>(
      PhotoVerificationController.new,
    );

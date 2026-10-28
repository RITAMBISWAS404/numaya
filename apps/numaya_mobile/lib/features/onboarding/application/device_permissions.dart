import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Device permissions onboarding asks for. This build has no location, camera or notification
/// plugin, so each is a labelled stand-in for Android's own prompt (ONBOARDING_MASTER_INVENTORY
/// OD-7, OD-13).
enum DevicePermission { location, camera, notifications }

enum PermissionStatus {
  notAsked,

  /// Location: "Approximate" (Android 12+) or any grant for the others.
  granted,

  /// Location: "Precise".
  grantedPrecise,
  denied,

  /// Denied twice: Android stops showing the prompt and only Settings can change it.
  permanentlyDenied,
}

/// The answer given in the stand-in prompt.
enum PermissionAnswer { allowApproximate, allowPrecise, allow, deny }

extension PermissionStatusX on PermissionStatus {
  bool get isGranted =>
      this == PermissionStatus.granted ||
      this == PermissionStatus.grantedPrecise;

  /// Whether asking again shows the prompt (Android stops after a second denial).
  bool get canAsk =>
      this == PermissionStatus.notAsked || this == PermissionStatus.denied;
}

@immutable
class DevicePermissions {
  const DevicePermissions([this.statuses = const {}]);

  final Map<DevicePermission, PermissionStatus> statuses;

  PermissionStatus of(DevicePermission p) =>
      statuses[p] ?? PermissionStatus.notAsked;
}

class DevicePermissionsController extends Notifier<DevicePermissions> {
  @override
  DevicePermissions build() => const DevicePermissions();

  /// Records an answer from the prompt. A second denial is permanent, as on Android.
  PermissionStatus answer(DevicePermission p, PermissionAnswer answer) {
    final before = state.of(p);
    final next = switch (answer) {
      PermissionAnswer.allowApproximate ||
      PermissionAnswer.allow => PermissionStatus.granted,
      PermissionAnswer.allowPrecise => PermissionStatus.grantedPrecise,
      PermissionAnswer.deny =>
        before == PermissionStatus.denied
            ? PermissionStatus.permanentlyDenied
            : PermissionStatus.denied,
    };
    set(p, next);
    return next;
  }

  /// Demo Hub: put a permission in any state.
  void set(DevicePermission p, PermissionStatus status) =>
      state = DevicePermissions({...state.statuses, p: status});

  void reset() => state = const DevicePermissions();
}

final devicePermissionsProvider =
    NotifierProvider<DevicePermissionsController, DevicePermissions>(
      DevicePermissionsController.new,
    );

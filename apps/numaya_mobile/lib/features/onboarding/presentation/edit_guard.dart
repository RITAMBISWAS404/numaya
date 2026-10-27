import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/onboarding_controller.dart';

/// Wraps a setup screen opened from Edit profile: leaving without saving restores the profile as
/// it was. (After a save, [OnboardingController.cancelEdit] has nothing to restore.)
class EditGuard extends ConsumerStatefulWidget {
  const EditGuard({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  ConsumerState<EditGuard> createState() => _EditGuardState();
}

class _EditGuardState extends ConsumerState<EditGuard> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) ref.read(onboardingProvider.notifier).beginEdit();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return PopScope<Object?>(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(onboardingProvider.notifier).cancelEdit();
      },
      child: widget.child,
    );
  }
}

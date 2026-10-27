import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/application/onboarding_controller.dart';

/// B-24 Edit profile: opens the same editors used during setup, each saving on its own.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final age = draft.ageIn(ref.read(onboardingProvider.notifier).currentYear);

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.editTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              ListRow(
                label: l10n.setupBasicsLabel,
                detail: age == null
                    ? draft.firstName
                    : '${draft.firstName}, $age',
                onTap: () => context.push(Routes.editBasics),
              ),
              ListRow(
                label: l10n.setupInterestsLabel,
                detail: draft.interests.join(', '),
                onTap: () => context.push(Routes.editInterests),
              ),
              ListRow(
                label: l10n.setupPhotosLabel,
                detail: '${draft.photos.length}',
                onTap: () => context.push(Routes.editPhotos),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

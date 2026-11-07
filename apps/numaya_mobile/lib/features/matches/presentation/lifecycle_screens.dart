import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/application/economy_controller.dart';
import '../../commerce/presentation/store_screens.dart';
import '../../premium/application/premium_controller.dart';

/// S17: today's likes are used. Shows the reset time and what is still free; offers Premium only
/// to free members, and never implies payment creates new people.
class AllowanceUsedScreen extends ConsumerWidget {
  const AllowanceUsedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(economyProvider);
    final premium = ref.watch(premiumProvider).active;
    final economy = ref.read(economyProvider.notifier);
    final now = ref.read(clockProvider)();
    final left = economy.likesReset().difference(now);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.close,
        closeIcon: true,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumayaButton(
            label: l10n.allowanceToChats,
            onPressed: () {
              context.pop();
              context.go(Routes.messages);
            },
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.allowanceBack,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s6),
          const Center(
            child: MobileIcon(
              NumayaMobileIcons.hourglass,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: l10n.allowanceTitle, lede: l10n.allowanceBody),
          const SizedBox(height: AppSpacing.s4),
          ListGroup(
            children: [
              ListRow(
                key: const ValueKey('allowance-reset'),
                leading: NumayaIcons.clock,
                label: l10n.allowanceResetsIn(compactDuration(left)),
                detail: shortDateTime(economy.likesReset()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (premium)
            Text(l10n.allowancePremiumHas, style: AppTypography.helper)
          else
            StatusBanner(
              tone: BannerTone.info,
              title: l10n.allowancePremiumTitle,
              body: l10n.allowancePremiumBody,
              action: NumayaButton(
                label: l10n.premiumSeePlans,
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => context.push(
                  '${Routes.paywall}?feature=${PremiumFeature.likes.name}',
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.allowanceNoMoreProfiles, style: AppTypography.helper),
        ],
      ),
    );
  }
}

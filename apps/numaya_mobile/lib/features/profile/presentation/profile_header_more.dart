import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import 'profile_variants.dart';

/// The compact identity row shared by the integrated headers: photo, name (with the verified mark
/// after it, R06), the verification pill, and Edit.
class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.data});
  final ProfileHeaderData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stacked = MediaQuery.textScalerOf(context).scale(15) > 21;
    final edit = NumayaButton(
      key: const ValueKey('profile-header-edit'),
      label: l10n.profileEdit,
      small: true,
      expand: stacked,
      variant: NumayaButtonVariant.secondary,
      onPressed: data.onEdit,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: ClipOval(
                child: SizedBox.square(
                  dimension: 64,
                  child: data.picture(initialSize: 26),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: NameWithBadge(
                      name: data.name,
                      verified: data.verified,
                      verifiedLabel: l10n.photoVerifiedLabel,
                      style: AppTypography.section,
                    ),
                  ),
                  if (!data.verified) ...[
                    const SizedBox(height: AppSpacing.s1),
                    data.badge(context),
                  ],
                ],
              ),
            ),
            if (!stacked) ...[const SizedBox(width: AppSpacing.s2), edit],
          ],
        ),
        if (stacked) ...[const SizedBox(height: AppSpacing.s3), edit],
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const NumayaDivider(margin: 0, spacing: AppSpacing.s4);
}

/// A tappable fact inside a header card: icon, value line, chevron.
class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, required this.onTap});
  final NumayaMobileIcons icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: text,
    excludeChildSemantics: true,
    pressedScale: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        children: [
          MobileIcon(icon, size: AppSizes.iconMd, color: AppColors.accent),
          const SizedBox(width: AppSpacing.s3),
          Expanded(child: Text(text, style: AppTypography.body)),
          const NumayaIcon(
            NumayaIcons.chevronRight,
            size: 18,
            color: AppColors.iconSupporting,
          ),
        ],
      ),
    ),
  );
}

/// `profile-header` C: identity plus the streak and credits in the same card, so the two
/// activity cards below are not needed.
class ProfileHeaderWithStreak extends StatelessWidget {
  const ProfileHeaderWithStreak({
    super.key,
    required this.data,
    required this.streakDays,
    required this.credits,
    required this.onStreak,
    required this.onWallet,
  });

  final ProfileHeaderData data;
  final int streakDays;
  final int credits;
  final VoidCallback onStreak;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('profile-header-streak'),
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentityRow(data: data),
          const _Divider(),
          _Fact(
            icon: NumayaMobileIcons.flame,
            text: l10n.streakDays(streakDays),
            onTap: onStreak,
          ),
          _Fact(
            icon: NumayaMobileIcons.wallet,
            text: l10n.walletTotal(credits),
            onTap: onWallet,
          ),
        ],
      ),
    );
  }
}

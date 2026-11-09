import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/media/local_image.dart';
import '../../../l10n/l10n.dart';
import '../../verification/application/verification_controller.dart';
import '../domain/profile_details.dart';

/// EXP-002 (own-profile upper section) and EXP-004 (profile completion card): the alternatives
/// to the refined candidate on the Profile tab. They show the same facts (photo, name and age,
/// verification state, completion percentage) and lead to the same places (Edit profile,
/// verification, the completion hub, Preview); only composition and emphasis change. The
/// completion percentage keeps its meaning (ProfileCompletion.percent).

/// Data every header variant needs.
class ProfileHeaderData {
  const ProfileHeaderData({
    required this.photo,
    required this.initial,
    required this.name,
    required this.verification,
    required this.onEdit,
    required this.onVerify,
    required this.onPreview,
  });

  final String? photo;
  final String initial;
  final String name;
  final PhotoVerificationStatus verification;
  final VoidCallback onEdit;
  final VoidCallback onVerify;
  final VoidCallback onPreview;

  bool get verified => verification == PhotoVerificationStatus.verified;

  String status(AppLocalizations l10n) => switch (verification) {
    PhotoVerificationStatus.verified => l10n.verifyStatusVerified,
    PhotoVerificationStatus.pending => l10n.verifyStatusPending,
    PhotoVerificationStatus.rejected => l10n.verifyStatusRejected,
    PhotoVerificationStatus.notStarted => l10n.verifyStatusNone,
  };

  /// The verification pill; unverified, it opens verification (as in the refined candidate).
  Widget badge(BuildContext context, {BadgeTone? tone}) {
    final l10n = context.l10n;
    final pill = StatusBadge(
      label: status(l10n),
      icon: verified ? NumayaIcons.verified : NumayaIcons.shield,
      tone: tone ?? (verified ? BadgeTone.brand : BadgeTone.neutral),
    );
    return verified
        ? pill
        : Pressable(
            onTap: onVerify,
            semanticLabel: '${status(l10n)}. ${l10n.editVerify}',
            excludeChildSemantics: true,
            borderRadius: AppRadii.all(AppRadii.pill),
            child: pill,
          );
  }

  /// The member's photo, or their initial on the identity grey, filling the space given. A
  /// photo file that has gone also shows the initial (V4-01).
  Widget picture({
    required double initialSize,
    Alignment alignment = Alignment.center,
  }) {
    final glyph = ColoredBox(
      color: AppColors.identity,
      child: Container(
        // At the top, the initial sits below the Edit pill's row.
        padding: alignment == Alignment.topCenter
            ? const EdgeInsets.only(top: 64)
            : EdgeInsets.zero,
        alignment: alignment,
        child: Text(
          initial,
          textScaler: TextScaler.noScaling,
          style: AppTypography.hero.copyWith(
            fontSize: AppTypography.even(initialSize),
            height: 1,
            color: AppColors.onIdentity,
          ),
        ),
      ),
    );
    return photo != null
        ? Image(
            image: localImage(photo!, width: 720),
            fit: BoxFit.cover,
            alignment: localImageFocus(photo!),
            errorBuilder: (_, _, _) => glyph,
          )
        : glyph;
  }
}

/// EXP-002 A — Photo-led cover (Hinge's photo-first identity; Numaya's own Discover card): the
/// member's main photo as a wide cover with their name on it, so the Profile tab opens on how
/// others first see them. Edit sits on the photo as a white pill. Axis: **photo emphasis**.
class ProfileHeaderCover extends StatelessWidget {
  const ProfileHeaderCover({super.key, required this.data});

  final ProfileHeaderData data;

  /// Room above the name for the Edit pill and, without a photo, the initial.
  static const double _topRoom = 150;

  /// How far above the name the fade begins.
  static const double _fade = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // At least 40% of the screen; taller when the name needs it (V4-04: a long name at large text
    // ran into the initial and the Edit pill when the cover had a fixed height).
    final minHeight = (MediaQuery.sizeOf(context).height * 0.4).clamp(
      220.0,
      360.0,
    );
    return ClipRRect(
      key: const ValueKey('profile-header-cover'),
      borderRadius: AppRadii.all(AppRadii.heroCard),
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: data.picture(
                initialSize: 72,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Sizes the cover: the name block at the bottom, with room above it. The fade belongs
          // to the name block, so it always starts just above the name however tall the name is
          // (white on the solid panel is 9.29:1 or more), and the initial above stays on the light photo grey.
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight,
              minWidth: double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: _topRoom - _fade),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TC-07: the fade sits above the name and the solid panel behind it, so a
                  // name that wraps at large text never reaches the faint top of the fade.
                  PhotoScrim(
                    fade: _fade,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s5,
                      0,
                      AppSpacing.s5,
                      AppSpacing.s5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Owner note: the verification pill sits above the name and age.
                        data.badge(context, tone: BadgeTone.onPhoto),
                        const SizedBox(height: AppSpacing.s2),
                        Semantics(
                          header: true,
                          child: NameWithBadge(
                            name: data.name,
                            verified: data.verified,
                            verifiedLabel: context.l10n.photoVerifiedLabel,
                            badgeColor: AppColors.accentForeground,
                            style:
                                AppTypography.weight(
                                  AppTypography.hero,
                                  AppTypography.bold,
                                ).copyWith(
                                  color: AppColors.accentForeground,
                                  shadows: PhotoText.shadows,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.s3,
            right: AppSpacing.s3,
            child: Pressable(
              key: const ValueKey('profile-header-edit'),
              onTap: data.onEdit,
              semanticLabel: l10n.profileEdit,
              excludeChildSemantics: true,
              borderRadius: AppRadii.all(AppRadii.pill),
              child: PhotoGlass(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NumayaIcon(
                      NumayaIcons.edit,
                      size: 18,
                      color: AppColors.inkForeground,
                    ),
                    const SizedBox(width: AppSpacing.s1),
                    Text(
                      l10n.profileEdit,
                      style: AppTypography.buttonSm.copyWith(
                        color: AppColors.inkForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EXP-002 B — Compact identity row (Bumble's and CapCut's profile tabs): a 72pt photo beside
/// the name and verification pill, Edit as a small button on the right, all in one white card.
/// The profile rows move a full screen-third higher. Axis: **density**.
class ProfileHeaderCompact extends StatelessWidget {
  const ProfileHeaderCompact({super.key, required this.data});

  final ProfileHeaderData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const size = 72.0;
    // With large text the name and the Edit button can't share one line: Edit moves under the
    // identity and spans the card (320pt at 200% text overflowed by 11pt otherwise).
    final stacked = MediaQuery.textScalerOf(context).scale(14) > 20;
    final edit = NumayaButton(
      key: const ValueKey('profile-header-edit'),
      label: l10n.profileEdit,
      small: !stacked,
      expand: stacked,
      variant: NumayaButtonVariant.secondary,
      onPressed: data.onEdit,
    );
    return Container(
      key: const ValueKey('profile-header-compact'),
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: ClipOval(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: data.picture(initialSize: 30),
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
                        verifiedLabel: context.l10n.photoVerifiedLabel,
                        style: AppTypography.section,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    data.badge(context),
                  ],
                ),
              ),
              if (!stacked) ...[const SizedBox(width: AppSpacing.s2), edit],
            ],
          ),
          if (stacked) ...[const SizedBox(height: AppSpacing.s4), edit],
        ],
      ),
    );
  }
}

/// EXP-002 C — Identity with quick actions (Hinge's edit badge on the photo; the action row of
/// social profile tabs): the centred photo carries a small edit badge, and three equal actions
/// sit under the name: Edit, Preview and Verify. Preview is already reachable from Edit profile;
/// here it is one tap from the tab. Axis: **action access**.
class ProfileHeaderActions extends StatelessWidget {
  const ProfileHeaderActions({super.key, required this.data});

  final ProfileHeaderData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const size = 104.0;
    // At large text three tiles can't hold their labels without breaking words, so the actions
    // become full-width rows.
    final stacked = MediaQuery.textScalerOf(context).scale(14) > 21;
    Widget action(
      String key,
      NumayaIcons icon,
      String label,
      VoidCallback onTap,
    ) => stacked
        ? Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            child: Pressable(
              key: ValueKey('profile-action-$key'),
              onTap: onTap,
              semanticLabel: label,
              excludeChildSemantics: true,
              borderRadius: AppRadii.all(AppRadii.card),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s3),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: AppRadii.all(AppRadii.card),
                ),
                child: Row(
                  children: [
                    NumayaIcon(
                      icon,
                      size: AppSizes.iconMd,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(child: Text(label, style: AppTypography.bodySm)),
                  ],
                ),
              ),
            ),
          )
        : Expanded(
            child: Pressable(
              key: ValueKey('profile-action-$key'),
              onTap: onTap,
              semanticLabel: label,
              excludeChildSemantics: true,
              borderRadius: AppRadii.all(AppRadii.card),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: AppRadii.all(AppRadii.card),
                ),
                child: Column(
                  children: [
                    NumayaIcon(
                      icon,
                      size: AppSizes.iconMd,
                      color: AppColors.ink,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm,
                    ),
                  ],
                ),
              ),
            ),
          );
    return Container(
      key: const ValueKey('profile-header-actions'),
      padding: const EdgeInsets.all(AppLayout.heroPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.heroCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: size + 8,
              height: size + 8,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: ClipOval(child: data.picture(initialSize: 44)),
                    ),
                  ),
                  // The edit badge: decorative; Edit below is the control.
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ExcludeSemantics(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const NumayaIcon(
                          NumayaIcons.edit,
                          size: AppSizes.iconSm,
                          color: AppColors.accentForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Semantics(
            header: true,
            child: NameWithBadge(
              name: data.name,
              verified: data.verified,
              verifiedLabel: context.l10n.photoVerifiedLabel,
              textAlign: TextAlign.center,
              style: AppTypography.headline,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Center(child: data.badge(context)),
          const SizedBox(height: AppSpacing.s5),
          Flex(
            direction: stacked ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: stacked
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [
              action('edit', NumayaIcons.edit, l10n.profileEdit, data.onEdit),
              const SizedBox(width: AppSpacing.s2),
              action(
                'preview',
                NumayaIcons.user,
                l10n.previewTitle,
                data.onPreview,
              ),
              const SizedBox(width: AppSpacing.s2),
              action(
                'verify',
                NumayaIcons.verified,
                data.verified
                    ? l10n.verifyStatusVerified
                    : l10n.profileQuickVerify,
                data.onVerify,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The bar shared by the completion variants: 8pt, purple on the fill, from its old value.
class _Bar extends StatelessWidget {
  const _Bar({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: AppRadii.all(AppRadii.pill),
      child: SizedBox(
        height: 8,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: (percent / 100).clamp(0, 1)),
          duration: AppMotion.duration(context, AppMotion.progress),
          curve: AppMotion.easeOut,
          builder: (context, f, _) => Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.fill),
              FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: f,
                child: const ColoredBox(color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// EXP-004 A — Ente progress banner (Banners 14590:125245, "Pick up again … 40% reviewed"): a
/// muted label, the percentage as the large metric, a round arrow at the top right and the bar
/// along the foot. The whole card opens the completion hub. Axis: **the number leads**.
class CompletionBanner extends StatelessWidget {
  const CompletionBanner({
    super.key,
    required this.percent,
    required this.onOpen,
  });

  final int percent;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Pressable(
      key: const ValueKey('completion-banner'),
      onTap: onOpen,
      semanticLabel:
          '${l10n.completionYourProfile}, ${l10n.completionPercent(percent)}. ${l10n.profileComplete}',
      excludeChildSemantics: true,
      borderRadius: AppRadii.all(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.completionYourProfile,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$percent%',
                              style: AppTypography.metric,
                            ),
                            TextSpan(
                              text: ' ${l10n.completionUnit}',
                              style: AppTypography.metricUnit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: AppSizes.iconButton,
                  height: AppSizes.iconButton,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const NumayaIcon(
                    NumayaIcons.arrowRight,
                    size: AppSizes.iconSm,
                    color: AppColors.accentForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            _Bar(percent: percent),
          ],
        ),
      ),
    );
  }
}

/// EXP-004 B — Next single task (Bumble's and happn's completion prompts): instead of the total,
/// the card names the one part to do next with its count, and Continue opens that part's
/// editor; See all opens the completion hub. Axis: **specificity of the next step**.
class CompletionNextTask extends StatelessWidget {
  const CompletionNextTask({
    super.key,
    required this.percent,
    required this.next,
    required this.onContinue,
    required this.onSeeAll,
  });

  final int percent;

  /// The next unfinished part: its name and progress. Null when the profile is complete.
  final ({String name, CompletionPart part})? next;
  final VoidCallback onContinue;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final n = next;
    return Container(
      key: const ValueKey('completion-next'),
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.profileCompletionLabel(percent),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TextLink(label: l10n.completionSeeAll, onPressed: onSeeAll),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          _Bar(percent: percent),
          const SizedBox(height: AppSpacing.s4),
          if (n == null)
            Text(l10n.completionDone, style: AppTypography.card)
          else ...[
            Text(l10n.completionNext(n.name), style: AppTypography.card),
            const SizedBox(height: AppSpacing.s1),
            Text(
              l10n.completionProgress(n.part.done, n.part.total),
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.s4),
            // Small: Edit profile above is the screen's one large primary.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: NumayaButton(
                key: const ValueKey('completion-next-continue'),
                label: l10n.completionContinue,
                small: true,
                expand: false,
                onPressed: onContinue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// EXP-004 C — Cat encouragement (optional UI-043 idea; Ente's Ducky beside a banner): the
/// cheering cat on the left of the existing title, bar and action. Small, and only here: never
/// beside safety or account states. Axis: **warmth through illustration**.
class CompletionWithCat extends StatelessWidget {
  const CompletionWithCat({
    super.key,
    required this.percent,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final int percent;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final done = percent >= 100;
    // At large text the cat sits above the title, so the title keeps the card's full width.
    final stacked = MediaQuery.textScalerOf(context).scale(14) > 21;
    const cat = MascotArt(
      MascotPurpose.completionEncouragement,
      maxWidth: 96,
      maxHeightFraction: 0.12,
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.card),
        const SizedBox(height: AppSpacing.s3),
        _Bar(percent: percent),
        const SizedBox(height: AppSpacing.s3),
        if (done)
          Text(
            l10n.completionDone,
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NumayaButton(
              label: actionLabel,
              small: true,
              expand: false,
              onPressed: onAction,
            ),
          ),
      ],
    );
    return Container(
      key: const ValueKey('completion-cat'),
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cat,
                const SizedBox(height: AppSpacing.s3),
                details,
              ],
            )
          : Row(
              children: [
                cat,
                const SizedBox(width: AppSpacing.s3),
                Expanded(child: details),
              ],
            ),
    );
  }
}

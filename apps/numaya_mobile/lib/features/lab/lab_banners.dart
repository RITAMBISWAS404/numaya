import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import 'lab_registry.dart';

/// Card family `status-banner` (Visual Lab V2): what happened and what to do, without alarm.
/// O tinted banner (today's [StatusBanner] geometry), A Ente banner with icon tile and round arrow,
/// B inline note, C outlined, D full-width strip. Every variant is a live region with the same
/// title and body; colour is never the only signal (icon + words).
class LabStatusBanner extends ConsumerWidget {
  const LabStatusBanner({
    super.key,
    required this.title,
    this.body,
    this.tone = BannerTone.info,
    this.icon,
    this.onTap,
    this.action,
    this.variant,
  });

  final String title;
  final String? body;
  final BannerTone tone;

  /// A specific glyph (archive, eye…); otherwise the tone's own.
  final NumayaMobileIcons? icon;

  /// Makes the whole banner tappable (the A variant shows a round arrow).
  final VoidCallback? onTap;
  final Widget? action;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('status-banner'));
    final (Color mark, NumayaIcons toneIcon) = switch (tone) {
      BannerTone.info => (AppColors.accent, NumayaIcons.info),
      BannerTone.pending => (AppColors.warning, NumayaIcons.clock),
      BannerTone.success => (AppColors.positive, NumayaIcons.verified),
      BannerTone.error => (AppColors.negative, NumayaIcons.alert),
    };
    Widget glyph(double size, {Color? color}) => icon == null
        ? NumayaIcon(toneIcon, size: size, color: color ?? mark, filled: true)
        // Owner note: status banners use filled glyphs (Tabler filled where one exists).
        : MobileIcon(icon!, size: size, color: color ?? mark, filled: true);
    final titleText = Text(
      title,
      style: AppTypography.weight(
        AppTypography.body,
        AppTypography.semibold,
      ).copyWith(color: AppColors.ink),
    );
    final bodyText = body == null
        ? null
        : Text(
            body!,
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
          );
    Widget texts() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText,
        if (bodyText != null) ...[const SizedBox(height: 2), bodyText],
        if (action != null) ...[const SizedBox(height: AppSpacing.s3), action!],
      ],
    );

    final Widget banner;
    switch (v) {
      case 'A':
        banner = Container(
          padding: const EdgeInsets.all(AppSpacing.s3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.iconButton,
                height: AppSizes.iconButton,
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: AppRadii.all(AppRadii.iconButton),
                ),
                alignment: Alignment.center,
                child: glyph(AppSizes.iconMd),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: texts()),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.s2),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.fill,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const NumayaIcon(
                    NumayaIcons.chevronRight,
                    size: 18,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ],
          ),
        );
      case 'B':
        banner = Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: glyph(18)),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: AppTypography.weight(
                          AppTypography.bodySm,
                          AppTypography.semibold,
                        ).copyWith(color: AppColors.ink),
                      ),
                      if (body != null)
                        TextSpan(
                          text: ' ${body!}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 'C':
        banner = Container(
          padding: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            borderRadius: AppRadii.all(AppRadii.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              glyph(AppSizes.iconMd),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: texts()),
            ],
          ),
        );
      case 'D':
        banner = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentTint,
            borderRadius: AppRadii.all(AppRadii.tile),
          ),
          child: Row(
            children: [
              glyph(AppSizes.iconMd, color: AppColors.accentOnTint),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: texts()),
            ],
          ),
        );
      default:
        banner = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Row(
            children: [
              glyph(AppSizes.iconMd),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: texts()),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.s2),
                const NumayaIcon(
                  NumayaIcons.chevronRight,
                  size: 18,
                  color: AppColors.iconSupporting,
                ),
              ],
            ],
          ),
        );
    }
    final wrapped = Semantics(
      liveRegion: onTap == null,
      container: true,
      child: banner,
    );
    if (onTap == null) return wrapped;
    return Pressable(
      onTap: onTap,
      semanticLabel: [title, ?body].join('. '),
      excludeChildSemantics: true,
      pressedScale: 1,
      borderRadius: AppRadii.all(AppRadii.card),
      child: banner,
    );
  }
}

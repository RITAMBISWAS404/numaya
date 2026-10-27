import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_layout.dart';
import '../foundations/app_motion.dart';
import '../foundations/app_typography.dart';
import '../icons/numaya_icon_data.g.dart';
import 'buttons.dart';
import 'primitives.dart';

/// The Numaya mark: a purple soft square with a bite out of its corner and a rose dot in the bite.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 26});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _BrandMarkPainter());
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32;
    canvas.scale(s);
    final square = Path()
      ..addRRect(RRect.fromLTRBR(2, 2, 30, 30, const Radius.circular(9)));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: const Offset(27, 5), radius: 7));
    canvas.drawPath(
      Path.combine(PathOperation.difference, square, bite),
      Paint()..color = AppColors.brand,
    );
    canvas.drawCircle(
      const Offset(27, 5),
      3.5,
      Paint()..color = AppColors.accentRose,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mark plus the "numaya" wordmark.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Numaya',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandMark(size: small ? 20 : 26),
          SizedBox(width: small ? 7 : 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text('numaya', style: AppTypography.wordmark(small: small)),
          ),
        ],
      ),
    );
  }
}

/// Spot illustrations shared with the web (exported by tool/export_assets.mjs).
enum NumayaIllustration {
  verified,
  hello,
  interests,
  noChats,
  noMatch,
  seenEveryone,
  paused,
  unmatched,
  blocked;

  String get asset {
    final file = switch (this) {
      noChats => 'no-chats',
      noMatch => 'no-match',
      seenEveryone => 'seen-everyone',
      _ => name,
    };
    return 'assets/illustrations/$file.svg';
  }

  /// Width / height of the drawing's canvas.
  double get aspectRatio => this == hello || this == interests ? 1 : 4 / 3;
}

/// Decorative illustration; the surrounding copy carries the meaning.
class IllustrationView extends StatelessWidget {
  const IllustrationView(this.illustration, {super.key, required this.width});

  final NumayaIllustration illustration;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        illustration.asset,
        width: width,
        height: width / illustration.aspectRatio,
      ),
    );
  }
}

/// Lavender guidance card (`.info-card`): icon and title on one line, body below.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.body,
  });

  final NumayaIcons icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surfaceBrand,
        borderRadius: AppRadii.all(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NumayaIcon(icon, size: AppSizes.iconMd, color: AppColors.brand),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.weight(
                    AppTypography.bodySm,
                    AppTypography.semibold,
                  ),
                ),
              ),
            ],
          ),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.s1),
            Text(
              body!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Prompt card (`.prompt`): question label, serif answer, a large quotation mark behind.
/// Without an answer it becomes the call to write one.
class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.question,
    required this.answer,
    this.onTap,
    this.emptyLabel,
    this.editLabel,
  });

  final String question;
  final String? answer;
  final VoidCallback? onTap;
  final String? emptyLabel;
  final String? editLabel;

  @override
  Widget build(BuildContext context) {
    final hasAnswer = answer != null && answer!.isNotEmpty;
    final card = ClipRRect(
      borderRadius: AppRadii.all(AppRadii.lg),
      child: Container(
        width: double.infinity,
        color: AppColors.surfaceBrand,
        child: Stack(
          children: [
            Positioned(
              right: AppSpacing.s4,
              bottom: -74,
              child: ExcludeSemantics(
                child: Text(
                  '”',
                  style: AppTypography.display.copyWith(
                    fontSize: 112,
                    height: 1,
                    color: AppColors.brandSubtle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s5,
                AppSpacing.s5,
                AppSpacing.s5,
                AppSpacing.s6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: AppTypography.weight(
                            AppTypography.label,
                            AppTypography.semibold,
                          ).copyWith(color: AppColors.textBrandDeep),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          hasAnswer ? answer! : (emptyLabel ?? ''),
                          style: hasAnswer
                              ? AppTypography.title
                              : AppTypography.title.copyWith(
                                  color: AppColors.textMuted,
                                ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Padding(
                      padding: EdgeInsets.only(left: AppSpacing.s2),
                      child: NumayaIcon(
                        NumayaIcons.chevronRight,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) {
      return Semantics(label: '$question. ${answer ?? ''}', child: card);
    }
    return Pressable(
      onTap: onTap,
      semanticLabel: hasAnswer
          ? '${editLabel ?? question}. $answer'
          : '$question. ${emptyLabel ?? ''}',
      excludeChildSemantics: true,
      pressedScale: 0.99,
      borderRadius: AppRadii.all(AppRadii.lg),
      child: card,
    );
  }
}

/// One photo in a grid, by id. [tone] picks the placeholder shade until real images exist.
class GridPhoto {
  const GridPhoto({required this.id, required this.tone});
  final int id;
  final int tone;
}

/// 3 × 2 photo grid (`.photo-grid`): filled slots show their order ("Main", 2, 3...) and a remove
/// button; empty slots show a plus.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    required this.mainLabel,
    required this.addLabel,
    required this.removeLabel,
    this.slots = 6,
  });

  final List<GridPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final String mainLabel;
  final String addLabel;
  final String Function(int position) removeLabel;
  final int slots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final w = (constraints.maxWidth - gap * 2) / 3;
        final h = w * 4 / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < slots; i++)
              SizedBox(
                width: w,
                height: h,
                child: i < photos.length ? _filled(i, photos[i]) : _empty(),
              ),
          ],
        );
      },
    );
  }

  Widget _filled(int i, GridPhoto photo) {
    return Semantics(
      label: i == 0 ? '$mainLabel photo' : 'Photo ${i + 1}',
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfacePhoto,
                borderRadius: AppRadii.all(AppRadii.md),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.pill),
              ),
              child: Text(
                i == 0 ? mainLabel : '${i + 1}',
                style: AppTypography.weight(
                  AppTypography.micro,
                  AppTypography.semibold,
                ).copyWith(fontSize: 11, color: AppColors.textPrimary),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Pressable(
              onTap: () => onRemove(photo.id),
              semanticLabel: removeLabel(i + 1),
              excludeChildSemantics: true,
              borderRadius: AppRadii.all(AppRadii.pill),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceInverse,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const NumayaIcon(
                  NumayaIcons.close,
                  size: 16,
                  color: AppColors.textOnInverse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Any empty slot adds the next photo at the end, so photos stay in order.
  Widget _empty() {
    final tile = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.md),
        border: Border.all(
          color: AppColors.borderStrong,
          width: AppBorders.hairline,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      alignment: Alignment.center,
      child: const NumayaIcon(NumayaIcons.plus, color: AppColors.textPrimary),
    );
    return Pressable(
      onTap: onAdd,
      semanticLabel: addLabel,
      excludeChildSemantics: true,
      pressedScale: 0.97,
      borderRadius: AppRadii.all(AppRadii.md),
      child: SizedBox.expand(child: tile),
    );
  }
}

/// Outcome block (`.result`): illustration, serif title, muted body.
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.title,
    this.body,
    this.illustration,
    this.compact = false,
    this.illustrationWidth = 160,
  });

  final String title;
  final String? body;
  final NumayaIllustration? illustration;
  final bool compact;
  final double illustrationWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4, bottom: AppSpacing.s1),
      child: Column(
        children: [
          if (illustration != null)
            _BadgeIn(
              child: IllustrationView(illustration!, width: illustrationWidth),
            ),
          SizedBox(height: compact ? AppSpacing.s3 : AppSpacing.s5),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headline,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                body!,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeIn extends StatelessWidget {
  const _BadgeIn({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 560),
      curve: AppMotion.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
      child: child,
    );
  }
}

enum SetupStepStatus { done, active, upcoming }

class SetupStepData {
  const SetupStepData({
    required this.label,
    required this.detail,
    required this.icon,
    required this.status,
  });

  final String label;
  final String detail;
  final NumayaIcons icon;
  final SetupStepStatus status;
}

/// Profile setup checklist (`.setup-steps`).
class SetupProgress extends StatelessWidget {
  const SetupProgress({
    super.key,
    required this.title,
    required this.countLabel,
    required this.steps,
    required this.upNextLabel,
    required this.doneLabel,
  });

  final String title;
  final String countLabel;
  final List<SetupStepData> steps;
  final String upNextLabel;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppTypography.titleSm),
              ),
            ),
            Text(countLabel, style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s2),
          _SetupStepTile(
            step: steps[i],
            upNextLabel: upNextLabel,
            doneLabel: doneLabel,
          ),
        ],
      ],
    );
  }
}

class _SetupStepTile extends StatelessWidget {
  const _SetupStepTile({
    required this.step,
    required this.upNextLabel,
    required this.doneLabel,
  });

  final SetupStepData step;
  final String upNextLabel;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    final active = step.status == SetupStepStatus.active;
    final done = step.status == SetupStepStatus.done;
    final labelColor = active
        ? AppColors.textPrimary
        : done
        ? AppColors.textSecondary
        : AppColors.textMuted;
    return Semantics(
      label:
          '${step.label}. ${step.detail}. ${done
              ? doneLabel
              : active
              ? upNextLabel
              : ''}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        decoration: BoxDecoration(
          color: done ? AppColors.surfaceSoft : AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.lg),
          border: done
              ? null
              : Border.all(
                  color: active
                      ? AppColors.controlSelected
                      : AppColors.borderSubtle,
                  width: active ? AppBorders.focus : AppBorders.hairline,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
          boxShadow: active ? AppElevation.sm : const [],
        ),
        child: Row(
          children: [
            NumayaIcon(
              done ? NumayaIcons.check : step.icon,
              color: active
                  ? AppColors.brand
                  : done
                  ? AppColors.textSecondary
                  : AppColors.textSubtle,
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.semibold,
                    ).copyWith(color: labelColor),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    step.detail,
                    style: AppTypography.caption.copyWith(
                      color: active
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (active || done) ...[
              const SizedBox(width: AppSpacing.s3),
              Container(
                padding: active
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                    : EdgeInsets.zero,
                decoration: active
                    ? BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: AppRadii.all(AppRadii.pill),
                      )
                    : null,
                child: Text(
                  active ? upNextLabel : doneLabel,
                  style:
                      AppTypography.weight(
                        AppTypography.caption,
                        AppTypography.semibold,
                      ).copyWith(
                        color: active
                            ? AppColors.textBrandDeep
                            : AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet (`.sheet`): 28 top corners, grabber, serif title and a close button.
Future<T?> showNumayaSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  required String closeLabel,
  bool tall = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (context) {
      final sheet = Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s2,
          AppSpacing.gutter,
          AppSpacing.s4 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: tall ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: AppRadii.all(AppRadii.pill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: AppTypography.titleSm),
                    ),
                  ),
                  NavIconButton(
                    icon: NumayaIcons.close,
                    label: closeLabel,
                    style: NavButtonStyle.flat,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (tall)
              Expanded(child: builder(context))
            else
              Flexible(child: builder(context)),
          ],
        ),
      );
      return tall
          ? FractionallySizedBox(heightFactor: 0.8, child: sheet)
          : sheet;
    },
  );
}

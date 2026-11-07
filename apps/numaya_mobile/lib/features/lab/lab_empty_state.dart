import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import 'lab_registry.dart';

/// R10: a reserved grey box for a future original purple-cat illustration, with a short label
/// saying what it will show. No generated or downloaded art. Restrained size: it never becomes a
/// giant empty header. Decorative (excluded from semantics); the copy beside it carries meaning.
class IllustrationBox extends StatelessWidget {
  const IllustrationBox({
    super.key,
    required this.label,
    this.width = 120,
    this.aspectRatio = 1,
  });

  /// What the illustration will show ("purple cat holding a small note").
  final String label;
  final double width;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          padding: const EdgeInsets.all(AppSpacing.s2),
          alignment: Alignment.center,
          child: Text(
            'Illustration: $label',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.fade,
            textScaler: TextScaler.noScaling,
            style: AppTypography.micro.copyWith(color: AppColors.textMuted),
          ),
        ),
      ),
    ),
  );
}

/// One next step in the D variant.
typedef EmptyStep = ({String label, NumayaIcons icon, VoidCallback onTap});

/// Card family `empty-state` (Visual Lab V2): an empty screen explains itself and offers one next
/// step. O centred illustration box, A side box, B text only, C card, D next steps.
class LabEmptyState extends ConsumerWidget {
  const LabEmptyState({
    super.key,
    required this.slot,
    required this.slotLabel,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.steps = const [],
    this.variant,
  });

  /// Stable slot name for the illustration backlog.
  final String slot;
  final String slotLabel;

  /// Used by the text-only and steps variants as a small leading mark.
  final NumayaMobileIcons icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Extra next steps for variant D (the primary action is always the first step).
  final List<EmptyStep> steps;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('empty-state'));
    final titleText = Semantics(
      header: true,
      child: Text(title, style: AppTypography.section),
    );
    final bodyText = Text(
      body,
      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
    );
    Widget? button({bool expand = false}) =>
        actionLabel == null || onAction == null
        ? null
        : NumayaButton(
            label: actionLabel!,
            small: true,
            expand: expand,
            onPressed: onAction,
          );

    switch (v) {
      case 'A':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IllustrationBox(label: slotLabel, width: 88),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText,
                    const SizedBox(height: AppSpacing.s1),
                    bodyText,
                    if (button() != null) ...[
                      const SizedBox(height: AppSpacing.s3),
                      button(expand: false)!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      case 'B':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText,
              const SizedBox(height: AppSpacing.s2),
              bodyText,
              if (button() != null) ...[
                const SizedBox(height: AppSpacing.s4),
                button(expand: false)!,
              ],
            ],
          ),
        );
      case 'C':
        return Container(
          padding: const EdgeInsets.all(AppLayout.heroPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            children: [
              IllustrationBox(label: slotLabel, width: 104),
              const SizedBox(height: AppSpacing.s4),
              DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                child: Column(
                  children: [
                    titleText,
                    const SizedBox(height: AppSpacing.s2),
                    bodyText,
                  ],
                ),
              ),
              if (button() != null) ...[
                const SizedBox(height: AppSpacing.s4),
                button(expand: true)!,
              ],
            ],
          ),
        );
      case 'D':
        final all = <EmptyStep>[
          if (actionLabel != null && onAction != null)
            (
              label: actionLabel!,
              icon: NumayaIcons.chevronRight,
              onTap: onAction!,
            ),
          ...steps,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s2),
            Row(
              children: [
                MobileIcon(
                  icon,
                  size: AppSizes.iconLg,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(child: titleText),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            bodyText,
            const SizedBox(height: AppSpacing.s4),
            if (all.isNotEmpty)
              ListGroup(
                children: [
                  for (final s in all)
                    ListRow(label: s.label, onTap: s.onTap, showChevron: true),
                ],
              ),
          ],
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          child: Column(
            children: [
              IllustrationBox(label: slotLabel, width: 128),
              const SizedBox(height: AppSpacing.s4),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.section,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                body,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (button() != null) ...[
                const SizedBox(height: AppSpacing.s4),
                button()!,
              ],
            ],
          ),
        );
    }
  }
}

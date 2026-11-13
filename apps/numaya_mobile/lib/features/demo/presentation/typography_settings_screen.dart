import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/type_settings_controller.dart';

/// DEVELOPMENT ONLY (UI-085 and the owner's 14/15 decision, 2026-11-14). Three independent
/// review controls: the display font, the UI font and the base body size, plus Reset. Every
/// screen follows a change at once and the choice is kept on this phone across relaunches.
/// Release builds have no route to it and always use the baseline.
class TypographySettingsScreen extends ConsumerWidget {
  const TypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final type = ref.watch(typeSettingsProvider);
    final controller = ref.read(typeSettingsProvider.notifier);

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.demo),
        backLabel: l10n.back,
        title: l10n.reviewTypeTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const _Specimen(),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.reviewTypeBodySize,
            footnote: l10n.reviewTypeBodySizeNote,
            children: [
              for (final size in TypeSettings.bodySizes)
                ListRow(
                  key: ValueKey('type-body-$size'),
                  label: size == 15
                      ? l10n.reviewTypeBodyDefault(size)
                      : l10n.reviewTypeBodyOption(size),
                  selected: type.bodySize == size,
                  onTap: () => controller.set(type.copyWith(bodySize: size)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.reviewTypeDisplay,
            footnote: l10n.reviewTypeDisplayNote,
            children: [
              for (final face in DisplayFace.values)
                ListRow(
                  key: ValueKey('type-display-${face.id}'),
                  label: face.label,
                  detail: face.singleWeight ? l10n.reviewTypeOneWeight : null,
                  selected: type.display == face,
                  onTap: () => controller.set(type.copyWith(display: face)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.reviewTypeUi,
            footnote: l10n.reviewTypeUiNote,
            children: [
              for (final face in UiFace.values)
                ListRow(
                  key: ValueKey('type-ui-${face.id}'),
                  label: face.label,
                  selected: type.ui == face,
                  onTap: () => controller.set(type.copyWith(ui: face)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          NumayaButton(
            key: const ValueKey('type-reset'),
            label: l10n.reviewTypeReset,
            variant: NumayaButtonVariant.secondary,
            onPressed: type.isBaseline ? null : () => controller.reset(),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.reviewTypeCurrent(
              type.display.label,
              type.ui.label,
              type.bodySize,
            ),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}

/// One sample of each group: a display heading, a UI subheading, body, a field and metadata.
class _Specimen extends StatelessWidget {
  const _Specimen();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reviewTypeSampleTitle, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.reviewTypeSampleSection, style: AppTypography.section),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.reviewTypeSampleBody, style: AppTypography.body),
          const SizedBox(height: AppSpacing.s2),
          Text(l10n.reviewTypeSampleMeta, style: AppTypography.caption),
        ],
      ),
    );
  }
}

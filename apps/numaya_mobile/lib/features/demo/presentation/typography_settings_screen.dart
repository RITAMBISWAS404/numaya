import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/type_settings_controller.dart';

/// DEVELOPMENT ONLY: Dev Mode, the review build's comparisons. UI-085 font pairing (four fixed
/// pairs), the owner's 14/15 body size, UI-095 brand colour (three choices), UI-096 button shape
/// (two), UI-098 secondary surface (two) and UI-097 Reset all. Every screen follows a change at
/// once and the choice is kept on this phone across relaunches. Release builds have no route to
/// it and always use the baseline.
class TypographySettingsScreen extends ConsumerWidget {
  const TypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dev = ref.watch(typeSettingsProvider);
    final controller = ref.read(typeSettingsProvider.notifier);

    Widget group<T>({
      required String key,
      required String title,
      required String note,
      required List<T> values,
      required String Function(T) label,
      required String Function(T) id,
      required T current,
      required TypeSettings Function(T) change,
      String? Function(T)? detail,
    }) => ListGroup(
      title: title,
      footnote: note,
      children: [
        for (final v in values)
          ListRow(
            key: ValueKey('dev-$key-${id(v)}'),
            label: label(v),
            detail: detail?.call(v),
            selected: current == v,
            onTap: () => controller.set(change(v)),
          ),
      ],
    );

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
          group<FontPairing>(
            key: 'font',
            title: l10n.reviewTypeDisplay,
            note: l10n.reviewTypeDisplayNote,
            values: FontPairing.values,
            label: (p) => p.label,
            id: (p) => p.id,
            detail: (p) =>
                p.displaySingleWeight ? l10n.reviewTypeOneWeight : null,
            current: dev.pairing,
            change: (p) => dev.copyWith(pairing: p),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          group<int>(
            key: 'body',
            title: l10n.reviewTypeBodySize,
            note: l10n.reviewTypeBodySizeNote,
            values: TypeSettings.bodySizes,
            label: (size) => size == 15
                ? l10n.reviewTypeBodyDefault(size)
                : l10n.reviewTypeBodyOption(size),
            id: (size) => '$size',
            current: dev.bodySize,
            change: (size) => dev.copyWith(bodySize: size),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          group<BrandOption>(
            key: 'brand',
            title: l10n.reviewDevBrand,
            note: l10n.reviewDevBrandNote,
            values: BrandOption.values,
            label: (b) => b.label,
            id: (b) => b.id,
            current: dev.brand,
            change: (b) => dev.copyWith(brand: b),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          group<ButtonShape>(
            key: 'shape',
            title: l10n.reviewDevShape,
            note: l10n.reviewDevShapeNote,
            values: ButtonShape.values,
            label: (b) => b.label,
            id: (b) => b.id,
            current: dev.shape,
            change: (b) => dev.copyWith(shape: b),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          group<SecondarySurface>(
            key: 'secondary',
            title: l10n.reviewDevSecondary,
            note: l10n.reviewDevSecondaryNote,
            values: SecondarySurface.values,
            label: (b) => b.label,
            id: (b) => b.id,
            current: dev.secondary,
            change: (b) => dev.copyWith(secondary: b),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          NumayaButton(
            key: const ValueKey('type-reset'),
            label: l10n.reviewTypeReset,
            variant: NumayaButtonVariant.secondary,
            onPressed: dev.isBaseline ? null : () => controller.reset(),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.reviewTypeCurrent(
              dev.pairing.label,
              '${dev.brand.label} · ${dev.shape.label} · ${dev.secondary.label}',
              dev.bodySize,
            ),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}

/// One sample of each group (display heading, UI subheading, body, metadata) and the button
/// treatments the shape and surface settings change, so a switch shows at once.
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
          const SizedBox(height: AppSpacing.s4),
          NumayaButtonGroup(
            children: [
              NumayaButton(
                label: l10n.reviewDevSampleCancel,
                variant: NumayaButtonVariant.secondary,
                onPressed: () {},
              ),
              NumayaButton(label: l10n.reviewDevSampleSave, onPressed: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: l10n.reviewDevSampleDisabled,
            variant: NumayaButtonVariant.secondary,
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

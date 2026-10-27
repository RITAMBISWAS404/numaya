import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../application/discovery_filters.dart';

/// A tab root on the stone page: its header, an optional subtitle, then the content column.
class TabPage extends StatelessWidget {
  const TabPage({
    super.key,
    required this.header,
    required this.child,
    this.subtitle,
    this.centered = false,
    this.scrollController,
    this.topGap = true,
    this.gutter = AppSpacing.gutter,
  });

  final Widget header;
  final String? subtitle;
  final Widget child;

  /// Centre the content vertically (empty states on Home).
  final bool centered;
  final ScrollController? scrollController;

  /// A 16pt gap under the header when there is no subtitle.
  final bool topGap;

  /// Side margin: 16pt, or 8pt on Discover.
  final double gutter;

  /// The height of the scrolling area below the header, for content that fills it (Discover's
  /// photo card, V16 `100cqh`).
  static double viewportOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TabViewport>()!.height;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => _TabViewport(
                      height: box.maxHeight,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          0,
                          gutter,
                          AppSpacing.s6,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: centered
                                ? box.maxHeight - AppSpacing.s6
                                : 0,
                          ),
                          child: Column(
                            mainAxisAlignment: centered
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (subtitle != null) ...[
                                Text(
                                  subtitle!,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                              ] else if (!centered && topGap)
                                const SizedBox(height: AppSpacing.s4),
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// B-34 Filters, as V16's filters sheet: 22pt medium questions ("How old are they?"), a label and
/// value row, a blue interval on the fill rail with round white thumbs, an ink save button and an
/// outlined reset.
Future<void> showFiltersSheet(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  return showNumayaSheet<void>(
    context: context,
    title: l10n.filtersTitle,
    closeLabel: l10n.close,
    builder: (context) => const _FiltersForm(),
  );
}

class _FiltersForm extends ConsumerStatefulWidget {
  const _FiltersForm();

  @override
  ConsumerState<_FiltersForm> createState() => _FiltersFormState();
}

class _FiltersFormState extends ConsumerState<_FiltersForm> {
  late DiscoveryFilters _draft = ref.read(discoveryFiltersProvider);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final count = ref.read(datingProvider.notifier).queue(_draft).length;
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.fill,
      thumbColor: AppColors.surface,
      overlayColor: AppColors.focusHalo,
      trackHeight: 4,
      rangeThumbShape: const V16RangeThumb(),
      thumbShape: const V16SliderThumb(),
      showValueIndicator: ShowValueIndicator.never,
    );
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s3),
      child: Semantics(
        header: true,
        child: Text(text, style: AppTypography.section),
      ),
    );
    Widget label(String title, String value) => Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.row)),
        Text(
          value,
          style: AppTypography.weight(AppTypography.row, AppTypography.medium),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading(l10n.filtersAgeHeading),
          label(
            l10n.filtersAge,
            l10n.filtersAgeValue(_draft.minAge, _draft.maxAge),
          ),
          SliderTheme(
            data: sliderTheme,
            child: RangeSlider(
              values: RangeValues(
                _draft.minAge.toDouble(),
                _draft.maxAge.toDouble(),
              ),
              min: DiscoveryFilters.ageFloor.toDouble(),
              max: DiscoveryFilters.ageCeiling.toDouble(),
              divisions:
                  DiscoveryFilters.ageCeiling - DiscoveryFilters.ageFloor,
              semanticFormatterCallback: (v) => '${v.round()}',
              onChanged: (v) => setState(
                () => _draft = _draft.copyWith(
                  minAge: v.start.round(),
                  maxAge: v.end.round(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          heading(l10n.filtersDistanceHeading),
          label(
            l10n.filtersDistanceLabel,
            l10n.filtersDistanceValue(_draft.maxDistanceKm),
          ),
          SliderTheme(
            data: sliderTheme,
            child: Slider(
              value: _draft.maxDistanceKm.toDouble(),
              min: 1,
              max: DiscoveryFilters.distanceCeilingKm.toDouble(),
              divisions: DiscoveryFilters.distanceCeilingKm - 1,
              semanticFormatterCallback: (v) =>
                  l10n.filtersDistanceValue(v.round()),
              onChanged: (v) => setState(
                () => _draft = _draft.copyWith(maxDistanceKm: v.round()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          NumayaButton(
            // Like the web sheet: how many sample profiles the draft lets through.
            label: l10n.filtersShowCount(count),
            onPressed: () {
              ref.read(discoveryFiltersProvider.notifier).save(_draft);
              NumayaToast.show(context, l10n.filtersSaved, aboveFooter: false);
              Navigator.of(context).pop();
            },
          ),
          if (count == 0) ...[
            const SizedBox(height: AppSpacing.s2),
            Text(
              l10n.filtersNoneFit,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.s3),
          // In a sheet, the second action is V16's outlined secondary ("Previous" under "Next").
          NumayaButton(
            label: l10n.filtersReset,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => setState(() => _draft = const DiscoveryFilters()),
          ),
        ],
      ),
    );
  }
}

class _TabViewport extends InheritedWidget {
  const _TabViewport({required this.height, required super.child});

  final double height;

  @override
  bool updateShouldNotify(_TabViewport old) => old.height != height;
}

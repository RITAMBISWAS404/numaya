import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/discovery_filters.dart';
import 'home_shell.dart';

/// Home (B-30 position), V16 header: the wordmark with a round filter button. No matching service
/// exists yet, so instead of sample people a V16 empty-state card says so plainly. Filters work and
/// are kept for the session.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _TabPage(
      header: SizedBox(
        height: AppSizes.topBar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Wordmark(small: true),
              Align(
                alignment: Alignment.centerRight,
                child: NavIconButton(
                  icon: NumayaIcons.filter,
                  label: l10n.discoverFilters,
                  onPressed: () => showFiltersSheet(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
      centered: true,
      child: EmptyState(
        art: const IllustrationView(
          NumayaIllustration.seenEveryone,
          width: 132,
        ),
        title: l10n.discoverEmptyTitle,
        body: l10n.discoverEmptyBody,
      ),
    );
  }
}

/// Likes (B-46): the page title, its subtitle and a V16 empty-state card until a backend delivers
/// likes.
class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TabPage(
      header: TabHeader(title: l10n.tabLikes),
      subtitle: l10n.likesSubtitle,
      child: EmptyState(
        art: const IllustrationView(NumayaIllustration.noMatch, width: 132),
        title: l10n.likesEmptyTitle,
        body: l10n.likesEmptyBody,
        action: NumayaButton(
          label: l10n.goToHome,
          small: true,
          onPressed: () => context.go(Routes.home),
        ),
      ),
    );
  }
}

/// Messages (B-42): the page title and a V16 empty-state card until matching and chat exist.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TabPage(
      header: TabHeader(title: l10n.tabChats),
      child: EmptyState(
        art: const IllustrationView(NumayaIllustration.noChats, width: 132),
        title: l10n.chatsEmptyTitle,
        body: l10n.chatsEmptyBody,
        action: NumayaButton(
          label: l10n.findYourPeople,
          small: true,
          onPressed: () => context.go(Routes.home),
        ),
      ),
    );
  }
}

/// A tab root on the stone page: its header, an optional subtitle, then the content column.
class _TabPage extends StatelessWidget {
  const _TabPage({
    required this.header,
    required this.child,
    this.subtitle,
    this.centered = false,
  });

  final Widget header;
  final String? subtitle;
  final Widget child;

  /// Centre the content vertically (Home's empty state).
  final bool centered;

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
                    builder: (context, box) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        0,
                        AppSpacing.gutter,
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
                            ] else if (!centered)
                              const SizedBox(height: AppSpacing.s4),
                            child,
                          ],
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
            label: l10n.filtersApply,
            onPressed: () {
              ref.read(discoveryFiltersProvider.notifier).save(_draft);
              NumayaToast.show(context, l10n.filtersSaved, aboveFooter: false);
              Navigator.of(context).pop();
            },
          ),
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

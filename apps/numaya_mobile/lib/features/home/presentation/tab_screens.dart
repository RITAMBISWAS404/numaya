import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/discovery_filters.dart';
import 'home_shell.dart';

/// Home (B-30 position). No matching service exists yet, so instead of sample people it says so
/// plainly. Filters work and are kept for the session.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _TabPage(
      header: TabHeader(
        title: l10n.tabDiscover,
        actions: [
          NavIconButton(
            icon: NumayaIcons.filter,
            label: l10n.discoverFilters,
            onPressed: () => showFiltersSheet(context, ref),
          ),
        ],
      ),
      child: EmptyState(
        art: const IllustrationView(
          NumayaIllustration.seenEveryone,
          width: 200,
        ),
        title: l10n.discoverEmptyTitle,
        body: l10n.discoverEmptyBody,
      ),
    );
  }
}

/// Likes (B-46). Empty until a backend delivers likes.
class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TabPage(
      header: TabHeader(title: l10n.tabLikes),
      child: EmptyState(
        art: const IllustrationView(NumayaIllustration.noMatch, width: 200),
        title: l10n.likesEmptyTitle,
        body: l10n.likesEmptyBody,
      ),
    );
  }
}

/// Messages (B-42). Empty until matching and chat exist.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TabPage(
      header: TabHeader(title: l10n.tabChats),
      child: EmptyState(
        art: const IllustrationView(NumayaIllustration.noChats, width: 200),
        title: l10n.chatsEmptyTitle,
        body: l10n.chatsEmptyBody,
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
          child: Column(
            children: [
              header,
              Expanded(
                child: Padding(
                  // Room for the floating tab bar.
                  padding: const EdgeInsets.only(
                    bottom: AppSizes.tabBar + AppSpacing.s4,
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.55,
                      ),
                      child: Center(child: child),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// B-34 Filters: age range and maximum distance.
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
      activeTrackColor: AppColors.controlSelected,
      inactiveTrackColor: AppColors.controlTrackOff,
      thumbColor: AppColors.surface,
      overlayColor: AppColors.focusHalo,
      trackHeight: 4,
      rangeThumbShape: const RoundRangeSliderThumbShape(
        enabledThumbRadius: 13,
        elevation: 2,
      ),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 13,
        elevation: 2,
      ),
      showValueIndicator: ShowValueIndicator.never,
    );
    Widget label(String title, String value) => Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.weight(
              AppTypography.body,
              AppTypography.medium,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: AppSpacing.s3),
          label(
            l10n.filtersDistance,
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
          const SizedBox(height: 6),
          NumayaButton(
            label: l10n.filtersReset,
            variant: NumayaButtonVariant.quiet,
            onPressed: () => setState(() => _draft = const DiscoveryFilters()),
          ),
        ],
      ),
    );
  }
}

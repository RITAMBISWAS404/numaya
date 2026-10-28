import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../dating/application/dating_controller.dart';
import '../../help/domain/help_articles.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../../premium/application/premium_controller.dart';
import '../../profile/domain/profile_details.dart';
import '../application/discovery_filters.dart';

/// Filters (B-34 basic, B-35 advanced; Mobbin "Filtering people"), in V16's filters sheet: 22pt
/// medium questions, the blue slider interval, switch rows for each fallback ("Show other people
/// if I run out", D-15), an ink "Show N people" and an outlined Reset. Advanced filters are part of
/// Premium in the demo (P-05); without it they're shown locked with a way to the paywall.
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
  int _tab = 0;

  void _set(DiscoveryFilters next) => setState(() => _draft = next);

  Future<void> _pickDetail(DetailKey key) async {
    final l10n = context.l10n;
    var selected = {...?_draft.details[key]};
    final saved = await showNumayaSheet<Set<String>>(
      context: context,
      title: key.question,
      closeLabel: l10n.close,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: OptionGroup(
                  legend: key.label,
                  children: [
                    for (final o in key.options)
                      OptionCard(
                        label: o,
                        kind: OptionKind.checkbox,
                        selected: selected.contains(o),
                        onTap: () => setSheet(() {
                          selected = {...selected};
                          selected.contains(o)
                              ? selected.remove(o)
                              : selected.add(o);
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            NumayaButton(
              label: l10n.filtersDone,
              onPressed: () => Navigator.of(context).pop(selected),
            ),
          ],
        ),
      ),
    );
    if (saved == null) return;
    final next = {..._draft.details};
    saved.isEmpty ? next.remove(key) : next[key] = saved;
    _set(_draft.copyWith(details: next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final premium = ref.watch(premiumProvider).active;
    final controller = ref.read(datingProvider.notifier);
    final count = controller.queue(_draft).length;
    final fallback = count > 0 && controller.showingFallback(_draft);
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.fill,
      thumbColor: AppColors.surface,
      overlayColor: AppColors.focusHalo,
      trackHeight: 4,
      rangeThumbShape: const V16RangeThumb(),
      thumbShape: const V16SliderThumb(),
      showValueIndicator: ShowValueIndicator.never,
      disabledActiveTrackColor: AppColors.borderStrong,
      disabledInactiveTrackColor: AppColors.fill,
      disabledThumbColor: AppColors.fill,
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

    final genders = [
      (Gender.woman, l10n.filtersWomen),
      (Gender.man, l10n.filtersMen),
      (Gender.nonbinary, l10n.filtersNonbinary),
    ];

    final basic = <Widget>[
      heading(l10n.filtersWhoHeading),
      Wrap(
        spacing: AppSpacing.s2,
        runSpacing: AppSpacing.s2,
        children: [
          for (final (g, name) in genders)
            NumayaChip(
              label: name,
              onCard: true,
              selected: _draft.genders.contains(g),
              onTap: () {
                final next = {..._draft.genders};
                next.contains(g) ? next.remove(g) : next.add(g);
                _set(_draft.copyWith(genders: next));
              },
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.s2),
      Text(
        _draft.genders.isEmpty ? l10n.filtersEveryone : l10n.filtersWhoHint,
        style: AppTypography.caption,
      ),
      const SizedBox(height: AppSpacing.s6),
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
          divisions: DiscoveryFilters.ageCeiling - DiscoveryFilters.ageFloor,
          semanticFormatterCallback: (v) => '${v.round()}',
          onChanged: (v) => _set(
            _draft.copyWith(minAge: v.start.round(), maxAge: v.end.round()),
          ),
        ),
      ),
      ListGroup(
        children: [
          ListRow(
            label: l10n.filtersAgeFallback,
            switchValue: _draft.ageFallback,
            onSwitch: (v) => _set(_draft.copyWith(ageFallback: v)),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s6),
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
          onChanged: (v) => _set(_draft.copyWith(maxDistanceKm: v.round())),
        ),
      ),
      ListGroup(
        children: [
          ListRow(
            label: l10n.filtersDistanceFallback,
            switchValue: _draft.distanceFallback,
            onSwitch: (v) => _set(_draft.copyWith(distanceFallback: v)),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s6),
      heading(l10n.filtersVerifiedHeading),
      ListGroup(
        footnote: l10n.filtersVerifiedNote,
        children: [
          ListRow(
            leading: NumayaIcons.verified,
            label: l10n.filtersVerifiedOnly,
            switchValue: _draft.verifiedOnly,
            onSwitch: (v) => _set(_draft.copyWith(verifiedOnly: v)),
          ),
        ],
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextLink(
          label: l10n.filtersWhatsThis,
          onPressed: () {
            Navigator.of(context).pop();
            context.push('${Routes.help}/${HelpArticleId.verification.name}');
          },
        ),
      ),
    ];

    final minHeight = _draft.minHeightCm ?? DetailRules.minHeight;
    final advanced = <Widget>[
      if (!premium) ...[
        StatusBanner(
          title: l10n.filtersAdvancedLocked,
          body: l10n.filtersAdvancedLockedBody,
          action: NumayaButton(
            label: l10n.premiumSee,
            small: true,
            expand: false,
            icon: NumayaIcons.lock,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(
                '${Routes.paywall}?feature=${PremiumFeature.advancedFilters.name}',
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
      ],
      heading(l10n.filtersHeightHeading),
      label(
        l10n.filtersHeight,
        _draft.minHeightCm == null
            ? l10n.filtersAny
            : l10n.filtersTallerThan(_draft.minHeightCm!),
      ),
      SliderTheme(
        data: sliderTheme,
        child: Slider(
          value: minHeight.toDouble(),
          min: DetailRules.minHeight.toDouble(),
          max: 200,
          divisions: 200 - DetailRules.minHeight,
          semanticFormatterCallback: (v) => v.round() == DetailRules.minHeight
              ? l10n.filtersAny
              : l10n.filtersTallerThan(v.round()),
          onChanged: premium
              ? (v) => _set(
                  v.round() == DetailRules.minHeight
                      ? _draft.copyWith(clearHeight: true)
                      : _draft.copyWith(minHeightCm: v.round()),
                )
              : null,
        ),
      ),
      const SizedBox(height: AppSpacing.s5),
      OptionGroup(
        legend: l10n.filtersIntentionsHeading,
        children: [
          for (final i in kIntentionFilters)
            OptionCard(
              label: i,
              kind: OptionKind.checkbox,
              enabled: premium,
              selected: _draft.intentions.contains(i),
              onTap: () {
                final next = {..._draft.intentions};
                next.contains(i) ? next.remove(i) : next.add(i);
                _set(_draft.copyWith(intentions: next));
              },
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.s5),
      ListGroup(
        title: l10n.filtersMoreHeading,
        children: [
          for (final key in DetailKey.filterable)
            ListRow(
              label: key.label,
              value: (_draft.details[key]?.isNotEmpty ?? false)
                  ? _draft.details[key]!.join(', ')
                  : l10n.filtersAddFilter,
              onTap: premium ? () => _pickDetail(key) : null,
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.s3),
      ListGroup(
        children: [
          ListRow(
            label: l10n.filtersAdvancedFallback,
            switchValue: _draft.advancedFallback,
            onSwitch: premium
                ? (v) => _set(_draft.copyWith(advancedFallback: v))
                : null,
          ),
        ],
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewTabs(
          label: l10n.filtersTitle,
          selected: _tab,
          onSelect: (i) => setState(() => _tab = i),
          options: [
            (label: l10n.filtersBasic, count: null),
            (label: l10n.filtersAdvanced, count: null),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _tab == 0 ? basic : advanced,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          // Like the web sheet: how many sample profiles the draft lets through.
          label: l10n.filtersShowCount(count),
          onPressed: () {
            ref.read(discoveryFiltersProvider.notifier).save(_draft);
            NumayaToast.show(context, l10n.filtersSaved, belowHeader: true);
            Navigator.of(context).pop();
          },
        ),
        if (count == 0 || fallback) ...[
          const SizedBox(height: AppSpacing.s2),
          Text(
            count == 0 ? l10n.filtersNoneFit : l10n.filtersUsingFallback,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
        const SizedBox(height: AppSpacing.s3),
        // In a sheet, the second action is V16's outlined secondary ("Previous" under "Next").
        NumayaButton(
          label: l10n.filtersReset,
          variant: NumayaButtonVariant.secondary,
          onPressed: () =>
              _set(ref.read(discoveryFiltersProvider.notifier).defaults),
        ),
      ],
    );
  }
}

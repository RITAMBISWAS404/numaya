import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/country.dart';

/// B-05 Country selector: a tall sheet with search. Returns the picked country.
Future<Country?> showCountrySheet(
  BuildContext context, {
  required Country selected,
}) {
  return showNumayaSheet<Country>(
    context: context,
    title: context.l10n.countrySheetTitle,
    closeLabel: context.l10n.close,
    tall: true,
    builder: (context) => _CountryList(selected: selected),
  );
}

class _CountryList extends StatefulWidget {
  const _CountryList({required this.selected});
  final Country selected;

  @override
  State<_CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<_CountryList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final results = kCountries.where((c) => c.matches(_query)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NumayaSearchField(
          placeholder: l10n.countrySearch,
          clearLabel: l10n.close,
          onChanged: (q) => setState(() => _query = q),
        ),
        const SizedBox(height: AppSpacing.s2),
        Expanded(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s6,
                    horizontal: AppSpacing.s3,
                  ),
                  child: Text(
                    l10n.countryNoResults(_query.trim()),
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final country = results[i];
                    final isSelected = country == widget.selected;
                    final fg = isSelected
                        ? AppColors.accentForeground
                        : AppColors.ink;
                    // V6: selection is the solid row itself. High contrast adds a tick, a
                    // cue that does not depend on colour.
                    final tick =
                        isSelected && MediaQuery.highContrastOf(context);
                    return Pressable(
                      key: ValueKey('country-${country.iso}'),
                      onTap: () => Navigator.of(context).pop(country),
                      haptic: HapticMoment.selection,
                      semanticLabel:
                          '${country.name}, plus ${country.dialCode}',
                      selected: isSelected,
                      excludeChildSemantics: true,
                      pressedScale: 1,
                      borderRadius: AppRadii.all(AppRadii.control),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : null,
                          borderRadius: AppRadii.all(AppRadii.control),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppLayout.cardPadding,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              CountryCodeBadge(
                                country.iso,
                                onAccent: isSelected,
                              ),
                              const SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Text(
                                  country.name,
                                  style: AppTypography.weight(
                                    AppTypography.body,
                                    isSelected
                                        ? AppTypography.semibold
                                        : AppTypography.medium,
                                  ).copyWith(color: fg),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s3),
                              Text(
                                '+${country.dialCode}',
                                style: AppTypography.body.copyWith(
                                  color: isSelected
                                      ? AppColors.accentForeground
                                      : AppColors.textMuted,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              if (tick) ...[
                                const SizedBox(width: AppSpacing.s2),
                                const NumayaIcon(
                                  NumayaIcons.check,
                                  size: AppSizes.iconMd,
                                  color: AppColors.accentForeground,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

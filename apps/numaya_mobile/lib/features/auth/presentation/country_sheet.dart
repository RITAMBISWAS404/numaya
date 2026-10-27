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
                    return Pressable(
                      onTap: () => Navigator.of(context).pop(country),
                      semanticLabel:
                          '${country.name}, plus ${country.dialCode}',
                      selected: isSelected,
                      excludeChildSemantics: true,
                      pressedScale: 1,
                      borderRadius: AppRadii.all(AppRadii.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            CountryCodeBadge(country.iso),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                country.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.weight(
                                  AppTypography.body,
                                  isSelected ? AppTypography.semibold : 400,
                                ).copyWith(fontSize: 16, height: 22 / 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '+${country.dialCode}',
                              style: AppTypography.body.copyWith(
                                fontSize: 16,
                                color: AppColors.textMuted,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 20,
                              child: isSelected
                                  ? const NumayaIcon(
                                      NumayaIcons.check,
                                      size: AppSizes.iconMd,
                                      color: AppColors.textBrand,
                                    )
                                  : null,
                            ),
                          ],
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

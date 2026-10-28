import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'edit_guard.dart';
import 'step_scaffold.dart';

/// OB-15: interests, 3 to 5 (B-17; Bumble's search and happn's categories [O]). Taps past the
/// maximum are ignored and the other chips show unavailable. [editing] is Edit profile's version.
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(onboardingProvider.notifier).saveEdits();
    if (!mounted) return;
    NumayaToast.show(context, context.l10n.editSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final count = draft.interests.length;
    final atMax = count >= ProfileRules.maxInterests;
    final valid = draft.interestsComplete;
    final q = _query.trim().toLowerCase();
    final groups = [
      for (final g in kInterestGroups)
        (
          group: g,
          interests: g.interests
              .where((i) => q.isEmpty || i.toLowerCase().contains(q))
              .toList(),
        ),
    ].where((g) => g.interests.isNotEmpty).toList();

    final content = <Widget>[
      NumayaSearchField(
        controller: _search,
        placeholder: l10n.interestsSearch,
        clearLabel: l10n.interestsClearSearch,
        onChanged: (v) => setState(() => _query = v),
      ),
      const SizedBox(height: AppSpacing.s5),
      // V16 chip-group label: small bold capitals, the count in muted tracked capitals.
      Row(
        children: [
          Expanded(child: FieldLabel(l10n.interestsLabel)),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.interestsSelected(count).toUpperCase(),
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
                fontVariations: const [FontVariation('wght', 400)],
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s3),
      if (groups.isEmpty) ...[
        const SizedBox(height: AppSpacing.s4),
        Text(
          l10n.interestsNoResults(_query.trim()),
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.s2),
        Center(
          child: TextLink(
            label: l10n.interestsClearSearch,
            onPressed: () {
              _search.clear();
              setState(() => _query = '');
            },
          ),
        ),
      ],
      for (final g in groups) ...[
        ChipSet(
          label: g.group.label,
          emoji: g.group.emoji,
          tone: MarkTone.byName(g.group.tone),
          children: [
            for (final interest in g.interests)
              NumayaChip(
                label: interest,
                emoji: kInterestEmoji[interest],
                selected: draft.interests.contains(interest),
                available: !atMax,
                onTap: () => controller.toggleInterest(interest),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s5),
      ],
    ];

    if (!widget.editing) {
      return OnboardingStepScaffold(
        step: SetupStep.interests,
        title: l10n.interestsTitle,
        lede: l10n.interestsLede,
        art: const IllustrationView(NumayaIllustration.interests, width: 72),
        caption: count < ProfileRules.minInterests
            ? l10n.interestsPickMore(ProfileRules.minInterests - count)
            : l10n.interestsCount(count),
        canContinue: valid,
        onContinue: () => continueFrom(context, ref, SetupStep.interests),
        children: content,
      );
    }
    return EditGuard(
      enabled: true,
      child: NumayaScreen(
        top: NumayaTopBar(
          onBack: () => context.pop(),
          backLabel: l10n.back,
          title: l10n.setupInterestsLabel,
        ),
        footer: NumayaButton(label: l10n.save, onPressed: valid ? _save : null),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s6),
            ...content,
          ],
        ),
      ),
    );
  }
}

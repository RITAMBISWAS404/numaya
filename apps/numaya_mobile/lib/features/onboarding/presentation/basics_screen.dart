import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/auth_copy.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'edit_guard.dart';

/// B-10 / B-11 in Numaya form: first name, birth year (18+), gender and intentions (up to 2).
/// Also used from Edit profile ([editing]), where the footer saves instead of continuing.
class BasicsScreen extends ConsumerStatefulWidget {
  const BasicsScreen({super.key, this.editing = false});

  final bool editing;

  @override
  ConsumerState<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends ConsumerState<BasicsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _year;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingProvider).draft;
    _name = TextEditingController(text: draft.firstName);
    _year = TextEditingController(text: draft.birthYear);
  }

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final notifier = ref.read(onboardingProvider.notifier);
    if (widget.editing) {
      await notifier.saveEdits();
      if (!mounted) return;
      NumayaToast.show(context, context.l10n.editSaved);
      context.pop();
      return;
    }
    notifier.completeStep(SetupStep.basics);
    unawaited(context.push(Routes.interests));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final year = controller.currentYear;
    final problem = draft.birthYearProblem(year);
    final yearError = switch (problem) {
      BirthYearProblem.underage => l10n.basicsUnderage,
      BirthYearProblem.unrealistic => l10n.basicsInvalidYear,
      _ => null,
    };
    final valid = draft.basicsComplete(year);
    final atMax = draft.lookingFor.length >= ProfileRules.maxLookingFor;

    return EditGuard(
      enabled: widget.editing,
      child: NumayaScreen(
        top: NumayaTopBar(
          onBack: () => context.pop(),
          backLabel: l10n.back,
          step: widget.editing ? null : SignUpProgress.basics,
          steps: widget.editing ? null : SignUpProgress.total,
          title: widget.editing ? l10n.setupBasicsLabel : null,
        ),
        footer: widget.editing
            ? NumayaButton(label: l10n.save, onPressed: valid ? _next : null)
            : StepFooter(
                caption: l10n.basicsFooter,
                action: NumayaFab(
                  semanticLabel: l10n.next,
                  onPressed: valid ? _next : null,
                ),
              ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.editing)
              ScreenHeader(
                title: l10n.basicsTitle,
                art: const IllustrationView(
                  NumayaIllustration.hello,
                  width: 72,
                ),
              ),
            const SizedBox(height: AppSpacing.s6),
            NumayaTextField(
              label: l10n.basicsFirstName,
              controller: _name,
              autofillHints: const [AutofillHints.givenName],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              maxLength: 40,
              onChanged: controller.setFirstName,
            ),
            const SizedBox(height: AppSpacing.fieldGap),
            NumayaTextField(
              label: l10n.basicsBirthYear,
              controller: _year,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              onChanged: controller.setBirthYear,
              error: yearError,
              hint: l10n.basicsBirthYearHint,
            ),
            const SizedBox(height: AppSpacing.fieldGap),
            OptionGroup(
              legend: l10n.basicsGenderLegend,
              children: [
                for (final (gender, label) in [
                  (Gender.woman, l10n.genderWoman),
                  (Gender.man, l10n.genderMan),
                  (Gender.nonbinary, l10n.genderNonbinary),
                ])
                  OptionCard(
                    label: label,
                    selected: draft.gender == gender,
                    onTap: () => controller.setGender(gender),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.fieldGap),
            OptionGroup(
              legend: l10n.basicsLookingLegend,
              children: [
                for (final (value, label) in [
                  (LookingFor.longTerm, l10n.lookingLongTerm),
                  (LookingFor.open, l10n.lookingOpen),
                  (LookingFor.casual, l10n.lookingCasual),
                ])
                  OptionCard(
                    label: label,
                    kind: OptionKind.checkbox,
                    selected: draft.lookingFor.contains(value),
                    enabled: draft.lookingFor.contains(value) || !atMax,
                    onTap: () => controller.toggleLookingFor(value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

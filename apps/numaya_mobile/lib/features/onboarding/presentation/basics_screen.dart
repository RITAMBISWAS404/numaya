import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'edit_guard.dart';

/// Edit profile › Basics: first name, gender and intentions. The birthday is shown but can't be
/// changed after setup (OD-3: no route round the age check). Sign-up uses the split onboarding
/// steps instead (OB-06, OB-08, OB-10).
class BasicsScreen extends ConsumerStatefulWidget {
  const BasicsScreen({super.key});

  @override
  ConsumerState<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends ConsumerState<BasicsScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: ref.read(onboardingProvider).draft.firstName,
    );
  }

  @override
  void dispose() {
    _name.dispose();
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
    final valid =
        nameProblem(draft.firstName) == null &&
        draft.gender != null &&
        draft.lookingFor.isNotEmpty;
    final atMax = draft.lookingFor.length >= ProfileRules.maxLookingFor;
    final birthday = draft.birthDate == null
        ? ''
        : DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag())
              .format(draft.birthDate!);

    return EditGuard(
      enabled: true,
      child: NumayaScreen(
        top: NumayaTopBar(
          onBack: () => context.pop(),
          backLabel: l10n.back,
          title: l10n.setupBasicsLabel,
        ),
        footer: NumayaButton(label: l10n.save, onPressed: valid ? _save : null),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s6),
            NumayaTextField(
              label: l10n.basicsFirstName,
              controller: _name,
              autofillHints: const [AutofillHints.givenName],
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              maxLength: ProfileRules.maxNameLength,
              error: nameProblem(_name.text) == NameProblem.characters
                  ? l10n.obNameCharacters
                  : null,
              onChanged: controller.setFirstName,
            ),
            const SizedBox(height: AppSpacing.fieldGap),
            ListGroup(
              footnote: l10n.editBirthdayLocked,
              children: [ListRow(label: l10n.editBirthday, value: birthday)],
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/session_controller.dart';
import '../../help/domain/help_articles.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/domain/profile_details.dart';
import '../../profile/presentation/profile_editors.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'step_scaffold.dart';

/// OB-06: first name and date of birth (B-10; Hinge's three fields and confirm card [O]). Only the
/// derived age is ever shown. Continuing asks the member to confirm their age; confirming an age
/// under 18 ends setup (OB-07).
class NameBirthdayScreen extends ConsumerStatefulWidget {
  const NameBirthdayScreen({super.key});

  @override
  ConsumerState<NameBirthdayScreen> createState() => _NameBirthdayScreenState();
}

class _NameBirthdayScreenState extends ConsumerState<NameBirthdayScreen> {
  late final TextEditingController _name;
  late final TextEditingController _day;
  late final TextEditingController _month;
  late final TextEditingController _year;
  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingProvider).draft;
    final b = draft.birthDate;
    String two(int v) => v.toString().padLeft(2, '0');
    _name = TextEditingController(text: draft.firstName);
    _day = TextEditingController(text: b == null ? '' : two(b.day));
    _month = TextEditingController(text: b == null ? '' : two(b.month));
    _year = TextEditingController(text: b == null ? '' : '${b.year}');
  }

  @override
  void dispose() {
    for (final c in [_name, _day, _month, _year]) {
      c.dispose();
    }
    for (final f in [_dayFocus, _monthFocus, _yearFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  /// Moves on to the next date field once this one is full, as the reference's boxes do.
  void _advance(String value, int length, FocusNode next) {
    setState(() {});
    if (value.length == length) next.requestFocus();
  }

  Future<void> _continue(DateTime birthDate, int age) async {
    if (_confirming) return;
    final controller = ref.read(onboardingProvider.notifier)
      ..setFirstName(_name.text.trim())
      ..setBirthDate(birthDate);
    FocusScope.of(context).unfocus();
    setState(() => _confirming = true);
    final confirmed = await _confirmAge(context, birthDate, age);
    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirmed != true) return;
    if (age < ProfileRules.minAge) {
      controller.confirmUnderage();
      context.go(Routes.setupUnderage);
      return;
    }
    continueFrom(context, ref, SetupStep.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = ref.read(onboardingProvider.notifier).today;
    final name = nameProblem(_name.text);
    final parsed = parseBirthDate(
      day: _day.text,
      month: _month.text,
      year: _year.text,
      today: today,
    );
    final date = parsed.date;
    final age = date == null ? null : ageInYears(date, today);
    final dateError = switch (parsed.problem) {
      BirthDateProblem.invalid => l10n.obBirthdayInvalid,
      BirthDateProblem.future => l10n.obBirthdayFuture,
      BirthDateProblem.unrealistic => l10n.obBirthdayUnrealistic,
      BirthDateProblem.underage => l10n.obBirthdayUnderage,
      _ => null,
    };
    // Under 18 can still continue: the confirm card decides (a typo can be fixed with Edit).
    final canContinue =
        name == null &&
        date != null &&
        (parsed.problem == null || parsed.problem == BirthDateProblem.underage);

    Widget dateField(
      TextEditingController c,
      FocusNode focus,
      String label,
      String placeholder,
      int length,
      FocusNode? next,
    ) => Expanded(
      flex: length,
      child: NumayaTextField(
        label: label,
        controller: c,
        focusNode: focus,
        placeholder: placeholder,
        keyboardType: TextInputType.number,
        textInputAction: next == null
            ? TextInputAction.done
            : TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(length),
        ],
        autofillHints: const [AutofillHints.birthday],
        onChanged: (v) =>
            next == null ? setState(() {}) : _advance(v, length, next),
        onSubmitted: (_) => next?.requestFocus(),
      ),
    );

    return OnboardingStepScaffold(
      step: SetupStep.name,
      title: l10n.obNameTitle,
      lede: l10n.obNameLede,
      art: const IllustrationView(NumayaIllustration.hello, width: 72),
      caption: canContinue ? l10n.obNameFooter : l10n.obNameFooterMissing,
      canContinue: canContinue && !_confirming,
      onContinue: () => _continue(date!, age!),
      children: [
        NumayaTextField(
          label: l10n.basicsFirstName,
          controller: _name,
          autofillHints: const [AutofillHints.givenName],
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: ProfileRules.maxNameLength,
          error: name == NameProblem.characters ? l10n.obNameCharacters : null,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _dayFocus.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.fieldGap),
        Semantics(header: true, child: FieldLabel(l10n.obBirthdayLegend)),
        const SizedBox(height: AppSpacing.s2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dateField(_day, _dayFocus, l10n.obDay, 'DD', 2, _monthFocus),
            const SizedBox(width: AppSpacing.s3),
            dateField(_month, _monthFocus, l10n.obMonth, 'MM', 2, _yearFocus),
            const SizedBox(width: AppSpacing.s3),
            dateField(_year, _yearFocus, l10n.obYear, 'YYYY', 4, null),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        Semantics(
          liveRegion: true,
          child: Text(
            dateError ?? (age == null ? '' : l10n.obAgeHint(age)),
            style: AppTypography.caption.copyWith(
              color: dateError == null
                  ? AppColors.textMuted
                  : AppColors.negative,
            ),
          ),
        ),
      ],
    );
  }
}

/// The confirm card: "You're N · Born …" with Edit and Confirm (Hinge [O]).
Future<bool?> _confirmAge(BuildContext context, DateTime birthDate, int age) {
  final l10n = context.l10n;
  final born = DateFormat.yMMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(birthDate);
  return showNumayaSheet<bool>(
    context: context,
    title: l10n.obConfirmAgeTitle(age),
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.obConfirmAgeBorn(born),
          style: AppTypography.weight(AppTypography.body, AppTypography.medium),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(l10n.obConfirmAgeBody, style: AppTypography.body),
        const SizedBox(height: AppSpacing.s6),
        NumayaButton(
          label: l10n.obConfirm,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.obConfirmEdit,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    ),
  );
}

/// OB-07: the member confirmed an age under 18. Setup stops here; system back stays; the only
/// ways out are the age rules and signing out (OD-1, OD-3).
class UnderageScreen extends ConsumerWidget {
  const UnderageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: NumayaScreen(
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumayaButton(
              label: l10n.obUnderageSignOut,
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            ),
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.obUnderageHelp,
              variant: NumayaButtonVariant.quiet,
              onPressed: () => context.push(
                '${Routes.help}/${HelpArticleId.gettingStarted.name}',
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s8),
            ResultPanel(
              illustration: NumayaIllustration.blocked,
              title: l10n.obUnderageTitle,
              body: l10n.obUnderageBody,
            ),
          ],
        ),
      ),
    );
  }
}

/// OB-08: gender (required), more detail (B-12), pronouns (optional, up to 4; Hinge [O]) and what
/// the profile shows (B-13).
class GenderScreen extends ConsumerWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final draft = ref.watch(onboardingProvider.select((s) => s.draft));
    final details = ref.watch(profileDetailsProvider);
    final detailsController = ref.read(profileDetailsProvider.notifier);
    final gender = draft.gender;
    final atMax = draft.pronouns.length >= ProfileRules.maxPronouns;

    return OnboardingStepScaffold(
      step: SetupStep.gender,
      title: l10n.obGenderTitle,
      lede: l10n.obGenderLede,
      caption: gender == null
          ? l10n.obGenderFooterMissing
          : l10n.obGenderFooter,
      canContinue: gender != null,
      onContinue: () => continueFrom(context, ref, SetupStep.gender),
      children: [
        OptionGroup(
          legend: l10n.basicsGenderLegend,
          children: [
            for (final (g, label) in [
              (Gender.woman, l10n.genderWoman),
              (Gender.man, l10n.genderMan),
              (Gender.nonbinary, l10n.genderNonbinary),
            ])
              OptionCard(
                label: label,
                selected: gender == g,
                onTap: () {
                  if (gender != g) detailsController.setGenderDetail(null);
                  controller.setGender(g);
                },
              ),
          ],
        ),
        if (gender != null) ...[
          const SizedBox(height: AppSpacing.s3),
          ListGroup(
            children: [
              ListRow(
                label: l10n.obGenderMore,
                value: details.genderDetail,
                onTap: () async {
                  final result = await showGenderDetailSheet(
                    context,
                    options: kGenderDetails[gender]!,
                    detail: details.genderDetail,
                    show: details.showGender,
                  );
                  if (result == null) return;
                  detailsController
                    ..setGenderDetail(result.detail)
                    ..setShowGender(result.show);
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.fieldGap),
        Row(
          children: [
            Expanded(child: FieldLabel(l10n.obPronounsLabel)),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.obPronounsCount(
                  draft.pronouns.length,
                  ProfileRules.maxPronouns,
                ),
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final p in kPronouns)
              NumayaChip(
                label: p,
                selected: draft.pronouns.contains(p),
                available: draft.pronouns.contains(p) || !atMax,
                onTap: () => controller.togglePronoun(p),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.fieldGap),
        ListGroup(
          children: [
            ListRow(
              label: l10n.obShowGender,
              switchValue: details.showGender,
              onSwitch: detailsController.setShowGender,
            ),
            ListRow(
              label: l10n.obShowPronouns,
              switchValue: draft.showPronouns,
              onSwitch: controller.setShowPronouns,
            ),
          ],
        ),
      ],
    );
  }
}

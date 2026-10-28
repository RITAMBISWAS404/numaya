import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/application/discovery_filters.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/domain/profile_details.dart';
import '../application/device_permissions.dart';
import '../application/onboarding_controller.dart';
import '../domain/profile_draft.dart';
import 'permission_prompt.dart';
import 'step_scaffold.dart';

SliderThemeData _sliderTheme(BuildContext context) =>
    SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.fill,
      thumbColor: AppColors.surface,
      overlayColor: AppColors.focusHalo,
      trackHeight: 4,
      rangeThumbShape: const V16RangeThumb(),
      thumbShape: const V16SliderThumb(),
      showValueIndicator: ShowValueIndicator.never,
    );

/// OB-09: who the member wants to meet (Hinge "Who are you open to dating?" [O]) and their age
/// range. Private; sets the Discovery filters.
class MeetScreen extends ConsumerStatefulWidget {
  const MeetScreen({super.key});

  @override
  ConsumerState<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends ConsumerState<MeetScreen> {
  late RangeValues _ages;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    final filters = ref.read(discoveryFiltersProvider);
    final age = state.draft.ageOn(ref.read(onboardingProvider.notifier).today);
    // First visit: a range around the member's own age; later visits keep what they chose.
    _ages = state.completed.contains(SetupStep.meet) || age == null
        ? RangeValues(filters.minAge.toDouble(), filters.maxAge.toDouble())
        : RangeValues(
            math.max(DiscoveryFilters.ageFloor, age - 5).toDouble(),
            math.min(DiscoveryFilters.ageCeiling, age + 7).toDouble(),
          );
  }

  void _continue(Set<Gender> openTo) {
    final filters = ref.read(discoveryFiltersProvider.notifier);
    filters.save(
      ref
          .read(discoveryFiltersProvider)
          .copyWith(
            genders: openTo,
            minAge: _ages.start.round(),
            maxAge: _ages.end.round(),
          ),
    );
    continueFrom(context, ref, SetupStep.meet);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final openTo = ref.watch(onboardingProvider.select((s) => s.draft.openTo));
    final everyone = openTo != null && openTo.isEmpty;

    return OnboardingStepScaffold(
      step: SetupStep.meet,
      title: l10n.obMeetTitle,
      lede: l10n.obMeetLede,
      caption: openTo == null ? l10n.obMeetFooterMissing : l10n.obMeetFooter,
      canContinue: openTo != null,
      onContinue: () => _continue(openTo!),
      children: [
        OptionGroup(
          legend: l10n.filtersWhoHeading,
          children: [
            for (final (g, label) in [
              (Gender.woman, l10n.filtersWomen),
              (Gender.man, l10n.filtersMen),
              (Gender.nonbinary, l10n.filtersNonbinary),
            ])
              OptionCard(
                label: label,
                kind: OptionKind.checkbox,
                selected: openTo?.contains(g) ?? false,
                onTap: () => controller.toggleOpenTo(g),
              ),
            OptionCard(
              label: l10n.obEveryone,
              kind: OptionKind.checkbox,
              selected: everyone,
              onTap: controller.setOpenToEveryone,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.fieldGap),
        Row(
          children: [
            Expanded(child: FieldLabel(l10n.obAgesLabel)),
            Text(
              l10n.filtersAgeValue(_ages.start.round(), _ages.end.round()),
              style: AppTypography.weight(
                AppTypography.row,
                AppTypography.medium,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: _sliderTheme(context),
          child: RangeSlider(
            values: _ages,
            min: DiscoveryFilters.ageFloor.toDouble(),
            max: DiscoveryFilters.ageCeiling.toDouble(),
            divisions: DiscoveryFilters.ageCeiling - DiscoveryFilters.ageFloor,
            semanticFormatterCallback: (v) => '${v.round()}',
            onChanged: (v) {
              // Keep at least two years between the ends.
              if (v.end - v.start < 2) return;
              setState(() => _ages = v);
            },
          ),
        ),
      ],
    );
  }
}

/// OB-10: relationship intentions, one or two (B-20 [O]). Shown on the profile.
class IntentionsScreen extends ConsumerWidget {
  const IntentionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingProvider.notifier);
    final picked = ref.watch(
      onboardingProvider.select((s) => s.draft.lookingFor),
    );
    final atMax = picked.length >= ProfileRules.maxLookingFor;
    return OnboardingStepScaffold(
      step: SetupStep.intentions,
      title: l10n.obIntentTitle,
      lede: l10n.obIntentLede,
      caption: picked.isEmpty
          ? l10n.obIntentFooterMissing
          : l10n.obIntentFooter(picked.length),
      canContinue: picked.isNotEmpty,
      onContinue: () => continueFrom(context, ref, SetupStep.intentions),
      children: [
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
                selected: picked.contains(value),
                enabled: picked.contains(value) || !atMax,
                onTap: () => controller.toggleLookingFor(value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Height in feet and inches, for the ft/in display.
({int feet, int inches}) _feetInches(int cm) {
  final total = (cm / 2.54).round();
  return (feet: total ~/ 12, inches: total % 12);
}

/// OB-11: height, optional (Hinge FT/CM [O]). Stored in centimetres; shown in either unit.
class HeightScreen extends ConsumerStatefulWidget {
  const HeightScreen({super.key});

  @override
  ConsumerState<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends ConsumerState<HeightScreen> {
  bool _feet = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = ref.watch(profileDetailsProvider.select((d) => d.heightCm));
    final details = ref.read(profileDetailsProvider.notifier);
    String label(int cm) {
      if (!_feet) return l10n.heightValue(cm);
      final fi = _feetInches(cm);
      return l10n.obHeightFeet(fi.feet, fi.inches);
    }

    void change(int delta) => details.setHeight(
      (height! + delta).clamp(DetailRules.minHeight, DetailRules.maxHeight),
    );

    return OnboardingStepScaffold(
      step: SetupStep.height,
      title: l10n.obHeightTitle,
      lede: l10n.obHeightLede,
      caption: height == null ? l10n.obHeightFooterNone : l10n.obHeightFooter,
      canContinue: true,
      onContinue: () => continueFrom(context, ref, SetupStep.height),
      onSkip: () {
        details.setHeight(null);
        continueFrom(context, ref, SetupStep.height);
      },
      children: [
        ViewTabs(
          label: l10n.obHeightUnitLegend,
          options: [
            (label: l10n.obHeightCm, count: null),
            (label: l10n.obHeightFtIn, count: null),
          ],
          selected: _feet ? 1 : 0,
          onSelect: (i) => setState(() => _feet = i == 1),
        ),
        const SizedBox(height: AppSpacing.s6),
        if (height == null)
          NumayaButton(
            label: l10n.obHeightAdd,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => details.setHeight(170),
          )
        else ...[
          Row(
            children: [
              NavIconButton(
                icon: NumayaIcons.minus,
                label: l10n.obHeightShorter,
                onPressed: height > DetailRules.minHeight
                    ? () => change(-1)
                    : null,
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    label(height),
                    textAlign: TextAlign.center,
                    style: AppTypography.headline,
                  ),
                ),
              ),
              NavIconButton(
                icon: NumayaIcons.plus,
                label: l10n.obHeightTaller,
                onPressed: height < DetailRules.maxHeight
                    ? () => change(1)
                    : null,
              ),
            ],
          ),
          SliderTheme(
            data: _sliderTheme(context),
            child: Slider(
              value: height.toDouble(),
              min: DetailRules.minHeight.toDouble(),
              max: DetailRules.maxHeight.toDouble(),
              divisions: DetailRules.maxHeight - DetailRules.minHeight,
              semanticFormatterCallback: (v) => label(v.round()),
              onChanged: (v) => details.setHeight(v.round()),
            ),
          ),
          Center(
            child: TextLink(
              label: l10n.obHeightRemove,
              muted: true,
              onPressed: () => details.setHeight(null),
            ),
          ),
        ],
      ],
    );
  }
}

/// OB-12: location, optional (happn primer and city fallback, Hinge "only the neighbourhood" [O]).
/// Explains first, then asks; keeps only an area name. The phone's location is never read in this
/// build: a granted (simulated) prompt sets the sample area and says so.
class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  Future<void> _useLocation(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final status = await requestPermission(
      context,
      ref,
      DevicePermission.location,
    );
    if (status.isGranted) {
      ref
          .read(profileDetailsProvider.notifier)
          .setArea(kSampleDeviceArea, fromDevice: true);
    } else if (status == PermissionStatus.permanentlyDenied &&
        context.mounted) {
      NumayaToast.show(context, l10n.obOpenSettingsDemo);
    }
  }

  Future<void> _chooseArea(BuildContext context, WidgetRef ref) async {
    final current = ref.read(profileDetailsProvider).area;
    final area = await showAreaSheet(context, selected: current);
    if (area != null) ref.read(profileDetailsProvider.notifier).setArea(area);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(
      devicePermissionsProvider.select((p) => p.of(DevicePermission.location)),
    );
    final details = ref.watch(profileDetailsProvider);
    final area = details.area;

    return OnboardingStepScaffold(
      step: SetupStep.location,
      title: l10n.obLocationTitle,
      lede: l10n.obLocationLede,
      art: const IllustrationView(NumayaIllustration.interests, width: 72),
      caption: area == null ? l10n.obLocationFooterNone : l10n.obLocationFooter,
      canContinue: true,
      onContinue: () => continueFrom(context, ref, SetupStep.location),
      onSkip: () => continueFrom(context, ref, SetupStep.location),
      children: [
        if (area != null) ...[
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.location,
                label: l10n.obLocationAreaLabel,
                value: details.areaFromDevice
                    ? l10n.obLocationSetDevice(area)
                    : area,
                onTap: () => _chooseArea(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
        if (status == PermissionStatus.denied && area == null) ...[
          StatusBanner(
            tone: BannerTone.error,
            title: l10n.obLocationDeniedTitle,
            body: l10n.obLocationDeniedBody,
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
        if (status == PermissionStatus.permanentlyDenied && area == null) ...[
          StatusBanner(
            tone: BannerTone.error,
            title: l10n.obLocationBlockedTitle,
            body: l10n.obLocationBlockedBody,
            action: NumayaButton(
              label: l10n.obOpenSettings,
              small: true,
              variant: NumayaButtonVariant.secondary,
              onPressed: () =>
                  NumayaToast.show(context, l10n.obOpenSettingsDemo),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
        ],
        if (!(details.areaFromDevice && area != null) &&
            status != PermissionStatus.permanentlyDenied) ...[
          NumayaButton(
            label: status == PermissionStatus.denied
                ? l10n.obLocationTryAgain
                : l10n.obLocationUse,
            onPressed: () => _useLocation(context, ref),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        NumayaButton(
          label: area == null ? l10n.obLocationChoose : l10n.obLocationChange,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => _chooseArea(context, ref),
        ),
        const SizedBox(height: AppSpacing.s5),
        InfoCard(
          icon: NumayaIcons.info,
          title: l10n.permDemoTag,
          body: l10n.obLocationDemo,
        ),
      ],
    );
  }
}

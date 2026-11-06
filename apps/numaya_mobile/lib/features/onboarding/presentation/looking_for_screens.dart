import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/application/discovery_filters.dart';
import '../../profile/application/profile_details_controller.dart';
import '../../profile/domain/profile_details.dart';
import '../application/device_permissions.dart';
import '../application/onboarding_controller.dart';
import '../domain/height_units.dart';
import '../domain/profile_draft.dart';
import 'permission_prompt.dart';
import 'step_scaffold.dart';

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
      asDefaults: true,
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
          legend: l10n.obMeetLegend,
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
        // UI-004: the label, the range read-out and both thumbs share one dedicated card.
        WhiteCard(
          key: const ValueKey('age-range-card'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s4,
            AppSpacing.s4,
            AppSpacing.s2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: FieldLabel(l10n.obAgesLabel)),
                  Text(
                    l10n.filtersAgeValue(
                      _ages.start.round(),
                      _ages.end.round(),
                    ),
                    style: AppTypography.weight(
                      AppTypography.row,
                      AppTypography.semibold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s2),
              AgeRangeSlider(
                values: _ages,
                min: DiscoveryFilters.ageFloor,
                max: DiscoveryFilters.ageCeiling,
                onChanged: (v) {
                  // Keep at least two years between the ends.
                  if (v.end - v.start < 2) return;
                  setState(() => _ages = v);
                },
              ),
            ],
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

/// OB-11: height, optional (Hinge FT/CM [O]). Stored in centimetres; shown in either unit.
///
/// UI-006: the picker is an inline wheel, usable on arrival ("Add my height" is gone). The wheel
/// rests on the saved height, or on [HeightUnits.defaultCm] when there is none, but nothing is
/// recorded until the member moves it: opening the step and continuing leaves height unset, and
/// Skip clears it.
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
        const SizedBox(height: AppSpacing.s4),
        HeightWheel(
          // A new wheel per unit: the two units have different rows.
          key: ValueKey(_feet),
          feet: _feet,
          heightCm: height,
          label: l10n.obHeightTitle,
          formatCm: l10n.heightValue,
          formatFeet: l10n.obHeightFeet,
          onChanged: details.setHeight,
        ),
        if (height != null) ...[
          const SizedBox(height: AppSpacing.s3),
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

/// The inline height wheel (UI-006): vertically stacked values the member scrolls, with a subtle
/// grey band marking the selected row (the Cal AI / Flo pattern on Mobbin, in Ente's fill colour
/// and 12pt corners). [onChanged] fires only when the member moves the wheel, with whole
/// centimetres; in ft/in mode each row is a whole inch, converted by [HeightUnits].
class HeightWheel extends StatefulWidget {
  const HeightWheel({
    super.key,
    required this.feet,
    required this.heightCm,
    required this.label,
    required this.formatCm,
    required this.formatFeet,
    required this.onChanged,
  });

  final bool feet;
  final int? heightCm;
  final String label;
  final String Function(int cm) formatCm;
  final String Function(int feet, int inches) formatFeet;
  final ValueChanged<int> onChanged;

  static const double rowExtent = 44;
  static const int visibleRows = 5;

  @override
  State<HeightWheel> createState() => _HeightWheelState();
}

class _HeightWheelState extends State<HeightWheel> {
  late final List<int> _rows = widget.feet
      ? HeightUnits.inchOptions
      : HeightUnits.cmOptions;

  /// Rests on the saved height (or the unrecorded default) when the wheel is built.
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: _rowFor(widget.heightCm));

  int _rowFor(int? cm) {
    final shown = cm ?? HeightUnits.defaultCm;
    final value = widget.feet ? HeightUnits.inchesFromCm(shown) : shown;
    return _rows.indexOf(value).clamp(0, _rows.length - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _text(int row) {
    if (!widget.feet) return widget.formatCm(_rows[row]);
    final fi = HeightUnits.feetInches(_rows[row]);
    return widget.formatFeet(fi.feet, fi.inches);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final feet = widget.feet;
    final heightCm = widget.heightCm;
    String text(int row) => _text(row);

    return WhiteCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Semantics(
        label: widget.label,
        value: heightCm == null ? null : text(_rowFor(heightCm)),
        child: SizedBox(
          height: HeightWheel.rowExtent * HeightWheel.visibleRows,
          child: CupertinoPicker.builder(
            scrollController: _controller,
            itemExtent: HeightWheel.rowExtent,
            diameterRatio: 1.6,
            squeeze: 1,
            useMagnifier: false,
            // The band sits on top of the selected row, so it is a translucent grey wash (ink
            // at 6%) that leaves the selected value readable.
            selectionOverlay: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.06),
                borderRadius: AppRadii.all(AppRadii.iconButton),
              ),
            ),
            childCount: rows.length,
            onSelectedItemChanged: (row) => widget.onChanged(
              feet ? HeightUnits.cmFromInches(rows[row]) : rows[row],
            ),
            itemBuilder: (context, row) => Center(
              child: Text(
                text(row),
                style: AppTypography.weight(
                  AppTypography.row,
                  AppTypography.semibold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// OB-12: location, optional (happn primer and city fallback, Hinge "only the neighbourhood" [O]).
/// Explains first, then asks; keeps only an area name. The phone's location is never read in this
/// build: a granted (simulated) prompt sets the sample area and says so.
class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  Future<void> _useLocation(BuildContext context, WidgetRef ref) async {
    final status = await requestPermission(
      context,
      ref,
      DevicePermission.location,
    );
    // A denial shows its banner; a second one shows the blocked banner with Settings.
    if (status.isGranted) {
      ref
          .read(profileDetailsProvider.notifier)
          .setArea(kSampleDeviceArea, fromDevice: true);
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
                tone: AccentTone.info,
                label: details.areaFromDevice
                    ? l10n.obLocationSetDevice(area)
                    : area,
                detail: l10n.obLocationAreaLabel,
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
      ],
    );
  }
}

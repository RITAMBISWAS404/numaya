import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';

/// Report (B-50, V16 047): reasons in one card, optional details, "Also block" (on by default),
/// then an honest result: the report stays on this device. Returns true when a report was saved.
Future<bool> showReportSheet(
  BuildContext context,
  WidgetRef ref,
  SamplePerson person,
) async {
  final l10n = context.l10n;
  final result = await showNumayaSheet<bool>(
    context: context,
    title: l10n.reportTitle(person.name),
    closeLabel: l10n.close,
    builder: (context) => _ReportForm(person: person),
  );
  return result ?? false;
}

class _ReportForm extends ConsumerStatefulWidget {
  const _ReportForm({required this.person});
  final SamplePerson person;

  @override
  ConsumerState<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends ConsumerState<_ReportForm> {
  String? _reason;
  String? _part;
  bool _block = true;
  bool _done = false;
  final _details = TextEditingController();

  @override
  void initState() {
    super.initState();
    _details.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = widget.person.name;
    if (_done) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResultPanel(
              illustration: NumayaIllustration.blocked,
              illustrationWidth: 140,
              compact: true,
              title: l10n.reportDoneTitle,
              body: _block
                  ? '${l10n.reportDoneBody} ${l10n.reportDoneBlocked(name)}'
                  : l10n.reportDoneBody,
            ),
            const SizedBox(height: AppSpacing.s6),
            NumayaButton(
              label: l10n.done,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OptionGroup(
                  legend: l10n.reportWhat,
                  children: [
                    for (final r in kReportReasons)
                      OptionCard(
                        label: r,
                        selected: _reason == r,
                        onTap: () => setState(() => _reason = r),
                      ),
                  ],
                ),
                // B-51: content reasons ask where it was seen.
                if (_reason == kReportReasons[1]) ...[
                  const SizedBox(height: AppSpacing.fieldGap),
                  OptionGroup(
                    legend: l10n.reportWhere,
                    children: [
                      for (final p in kReportParts)
                        OptionCard(
                          label: p,
                          selected: _part == p,
                          onTap: () => setState(() => _part = p),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.fieldGap),
                NumayaTextField(
                  label: l10n.reportDetails,
                  controller: _details,
                  multiline: true,
                  maxLength: 300,
                  trailingNote: l10n.promptCharsLeft(
                    300 - _details.text.length,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                OptionCard(
                  label: l10n.reportAlsoBlock(name),
                  description: l10n.reportAlsoBlockDetail,
                  kind: OptionKind.checkbox,
                  selected: _block,
                  onTap: () => setState(() => _block = !_block),
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
            ),
          ),
        ),
        NumayaButton(
          label: l10n.reportSend,
          onPressed: _reason == null
              ? null
              : () {
                  ref
                      .read(datingProvider.notifier)
                      .report(
                        widget.person.id,
                        _reason!,
                        block: _block,
                        part: _part,
                        details: _details.text,
                      );
                  setState(() => _done = true);
                },
        ),
      ],
    );
  }
}

/// Block confirmation (web Chat "Block {name}?"): consequences, solid red Block, outlined Cancel.
/// Returns true when the person was blocked.
Future<bool> showBlockSheet(
  BuildContext context,
  WidgetRef ref,
  SamplePerson person,
) async {
  final l10n = context.l10n;
  final ok = await showNumayaSheet<bool>(
    context: context,
    title: l10n.blockTitle(person.name),
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConsequenceList(
          items: [
            (NumayaIcons.block, l10n.blockC1(person.name)),
            (NumayaIcons.eyeOff, l10n.blockC2),
            (NumayaIcons.info, l10n.blockC3(person.name)),
          ],
        ),
        const SizedBox(height: AppSpacing.s5),
        NumayaButton(
          label: l10n.optionBlock(person.name),
          variant: NumayaButtonVariant.destructiveSolid,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.cancel,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    ),
  );
  if (ok == true) {
    ref.read(datingProvider.notifier).end(person.id, EndReason.blocked);
  }
  return ok == true;
}

enum UnmatchChoice { unmatch, report }

/// Unmatch confirmation (B-53, V16 045): consequences, a "report instead" note, solid red Unmatch.
Future<UnmatchChoice?> showUnmatchSheet(
  BuildContext context,
  SamplePerson person,
) {
  final l10n = context.l10n;
  return showNumayaSheet<UnmatchChoice>(
    context: context,
    title: l10n.unmatchTitle(person.name),
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConsequenceList(
          items: [
            (NumayaIcons.eyeOff, l10n.unmatchC1),
            (NumayaIcons.message, l10n.unmatchC2),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        Pressable(
          onTap: () => Navigator.of(context).pop(UnmatchChoice.report),
          semanticLabel: '${l10n.unmatchNoteTitle} ${l10n.unmatchNoteBody}',
          excludeChildSemantics: true,
          pressedScale: 0.99,
          borderRadius: AppRadii.all(AppRadii.card),
          child: InfoCard(
            icon: NumayaIcons.flag,
            title: l10n.unmatchNoteTitle,
            body: l10n.unmatchNoteBody,
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
        NumayaButton(
          label: l10n.optionUnmatch,
          variant: NumayaButtonVariant.destructiveSolid,
          onPressed: () => Navigator.of(context).pop(UnmatchChoice.unmatch),
        ),
      ],
    ),
  );
}

/// "Did you meet?" (B-55): kept on this device; the other person never sees it.
Future<void> showDidYouMeetSheet(
  BuildContext context,
  WidgetRef ref,
  SamplePerson person,
) async {
  final l10n = context.l10n;
  final met = await showNumayaSheet<bool>(
    context: context,
    title: l10n.didMeetTitle(person.name),
    closeLabel: l10n.close,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.didMeetBody(person.name),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s5),
        NumayaButton(
          label: l10n.didMeetYes,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.didMeetNo,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    ),
  );
  if (met == null || !context.mounted) return;
  ref.read(datingProvider.notifier).recordMeeting(person.id, met: met);
  NumayaToast.show(context, l10n.didMeetThanks);
}

/// After unmatching (B-54): an optional reason, kept on this device.
Future<void> showUnmatchReasonSheet(
  BuildContext context,
  WidgetRef ref,
  SamplePerson person,
) async {
  final l10n = context.l10n;
  final reason = await showNumayaSheet<String>(
    context: context,
    title: l10n.unmatchedReasonTitle(person.name),
    closeLabel: l10n.unmatchReasonSkip,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.unmatchedReasonBody(person.name),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.s4),
        ListGroup(
          children: [
            for (final r in kUnmatchReasons)
              ListRow(label: r, onTap: () => Navigator.of(context).pop(r)),
          ],
        ),
      ],
    ),
  );
  if (reason == null || !context.mounted) return;
  ref.read(datingProvider.notifier).recordUnmatchReason(person.id, reason);
  NumayaToast.show(context, l10n.unmatchReasonThanks);
}

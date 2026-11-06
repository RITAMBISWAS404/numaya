import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'experiments.dart';

/// DEVELOPMENT ONLY. The Experiment Lab (overnight v3): pick Current, A, B or C for each layout
/// experiment independently, open the screen where it shows, and copy the choices as
/// "EXP-001 B; EXP-002 Current" to paste into a reply. Reached from the Demo Hub; the router
/// refuses it where demo sign-in isn't allowed (release builds), and there the screens always
/// show the refined candidate. Picking a variant only changes how a screen is drawn: it never
/// sends, buys, edits or navigates on its own.
class ExperimentLabScreen extends ConsumerWidget {
  const ExperimentLabScreen({super.key});

  /// Where each experiment can be seen, and which state shows it.
  static String route(Experiment e) => switch (e) {
    Experiment.matchMoment => '${Routes.match}/maya',
    Experiment.profileHeader => Routes.profile,
    Experiment.completionCard => Routes.profile,
    Experiment.emptyChats => Routes.messages,
  };

  static String where(Experiment e) => switch (e) {
    Experiment.matchMoment => 'New match with Maya',
    Experiment.profileHeader => 'Profile tab, top',
    Experiment.completionCard => 'Profile tab, under the header',
    Experiment.emptyChats =>
      'Messages with no matches (Demo Hub › sample world: fresh)',
  };

  /// "EXP-001 B; EXP-002 Current; …" in experiment order.
  static String summary(Map<Experiment, ExpVariant> choices) => [
    for (final e in Experiment.values)
      '${e.id.substring(0, 7)} ${(choices[e] ?? ExpVariant.current).letter}',
  ].join('; ');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final choices = ref.watch(experimentChoicesProvider);
    final notifier = ref.read(experimentChoicesProvider.notifier);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.demo),
        backLabel: l10n.back,
        title: 'Experiment Lab',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const StatusBanner(
            title: 'Layout choices for review',
            body:
                'Each experiment is chosen on its own. Current is the refined candidate; '
                'A, B and C are proposals. Nothing here changes your data.',
          ),
          for (final e in Experiment.values) ...[
            const SizedBox(height: AppLayout.sectionGap),
            NumayaSection(
              title: e.title,
              child: Container(
                key: ValueKey('lab-${e.id}'),
                padding: const EdgeInsets.all(AppLayout.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.all(AppRadii.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      e.id,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s2,
                      children: [
                        for (final v in ExpVariant.values)
                          NumayaChip(
                            key: ValueKey('lab-${e.id}-${v.letter}'),
                            label: v.letter,
                            selected: (choices[e] ?? ExpVariant.current) == v,
                            onTap: () => notifier.choose(e, v),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Text(
                      e.names[choices[e] ?? ExpVariant.current]!,
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      where(e),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: NumayaButton(
                        label: 'Open screen',
                        small: true,
                        expand: false,
                        variant: NumayaButtonVariant.secondary,
                        onPressed: () => context.push(route(e)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppLayout.sectionGap),
          NumayaButton(
            key: const ValueKey('lab-copy'),
            label: 'Copy my choices',
            icon: NumayaIcons.share,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: summary(choices)));
              if (context.mounted) {
                NumayaToast.show(context, summary(choices));
              }
            },
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            key: const ValueKey('lab-reset'),
            label: 'Show the refined candidate everywhere',
            variant: NumayaButtonVariant.secondary,
            onPressed: notifier.resetAll,
          ),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }
}

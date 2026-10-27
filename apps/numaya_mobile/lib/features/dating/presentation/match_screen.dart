import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';

/// Match (B-40 / B-41, V16 030 / 032): close top right, "It's a match!", the scalloped portrait with
/// your avatar, what you both like, and a composer. Sending opens the conversation; closing keeps
/// browsing and the match waits in Messages. No countdown (P-03 is open).
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _close() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final person = personById(widget.personId);
    final me = ref.watch(onboardingProvider.select((s) => s.draft.firstName));
    if (person == null) return const SizedBox.shrink();
    final body = l10n.matchBody(person.name);
    final split = body.indexOf(person.name);
    // V16 `.organic-portrait`: min(264px, 66vw, 32svh), 25svh on phones 700pt tall or less.
    final screen = MediaQuery.sizeOf(context);
    final portrait = [
      264.0,
      screen.width * 0.66,
      screen.height * (screen.height <= 700 ? 0.25 : 0.32),
    ].reduce(math.min);

    return NumayaScreen(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Composer(
            controller: _text,
            placeholder: person.opener ?? l10n.matchSayHello(person.name),
            sendLabel: l10n.chatSend,
            onSend: (text) {
              unawaited(
                ref.read(datingProvider.notifier).send(person.id, text),
              );
              context.pushReplacement('${Routes.chat}/${person.id}');
            },
          ),
          const SizedBox(height: AppSpacing.s2),
          NumayaButton(
            label: l10n.matchKeepBrowsing,
            variant: NumayaButtonVariant.quiet,
            onPressed: _close,
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: NavIconButton(
              icon: NumayaIcons.close,
              label: l10n.matchClose,
              onPressed: _close,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              l10n.matchTitle,
              textAlign: TextAlign.center,
              style:
                  AppTypography.weight(
                    AppTypography.hero,
                    AppTypography.bold,
                  ).copyWith(
                    fontSize: (MediaQuery.sizeOf(context).width * 0.09).clamp(
                      32.0,
                      36.0,
                    ),
                    height: 1.1,
                  ),
            ),
          ),
          SizedBox(height: AppSpacing.s6 + 0.05 * portrait),
          SizedBox.square(
            dimension: portrait,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // V16's backdrop frame is 10% larger than the photo box (inset -5%) and reads as
                // one photo-grey shape.
                Positioned(
                  left: -0.05 * portrait,
                  top: -0.05 * portrait,
                  child: ScallopPortrait(
                    initial: person.initial,
                    size: portrait * 1.1,
                  ),
                ),
                // You overlap the frame's lower left on a white ring (V16 `.match__you`).
                Positioned(
                  left: -0.09 * portrait,
                  bottom: -0.03 * portrait,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: InitialsAvatar(
                      initial: me.trim().isEmpty
                          ? '?'
                          : me.trim()[0].toUpperCase(),
                      size: 60,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s5 + 0.05 * portrait),
          // V16 `.match__body`: 16pt, at most 300pt wide, balanced.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: BalancedText.rich(
              TextSpan(
                children: split < 0
                    ? [TextSpan(text: body)]
                    : [
                        TextSpan(text: body.substring(0, split)),
                        TextSpan(
                          text: person.name,
                          style: AppTypography.weight(
                            AppTypography.input,
                            AppTypography.semibold,
                          ).copyWith(color: AppColors.ink),
                        ),
                        TextSpan(
                          text: body.substring(split + person.name.length),
                        ),
                      ],
              ),
              style: AppTypography.input.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (person.shared.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s5),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: [
                Text(l10n.discoverYouBothLike, style: AppTypography.caption),
                for (final s in person.shared)
                  InfoChip(label: s, emoji: kInterestEmoji[s], onPage: true),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.s5),
          Text(
            l10n.matchSampleNote(person.name),
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

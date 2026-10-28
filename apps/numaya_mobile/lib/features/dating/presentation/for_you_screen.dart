import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';

/// "For you" (B-33, Mobbin "Discover": curated daily picks with a refresh countdown and a
/// rationale line). Up to four undecided people with the most in common, ignoring the filters.
/// Opened from the Home header; a like here is the same as a like on Home.
class ForYouScreen extends ConsumerWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final controller = ref.read(datingProvider.notifier);
    final picks = controller.picks();
    final now = ref.read(clockProvider)();
    final refresh = DateTime(now.year, now.month, now.day + 1).difference(now);
    final hours = refresh.inHours.clamp(1, 24);

    void like(SamplePerson p) {
      final result = controller.decide(p.id, liked: true);
      if (result == DecisionResult.matched) {
        context.push('${Routes.match}/${p.id}');
      } else {
        NumayaToast.show(context, l10n.discoverLiked(p.name));
      }
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.forYouTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(
              label: l10n.forYouRefresh(hours),
              icon: NumayaIcons.clock,
              tone: BadgeTone.brand,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.forYouLede,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s5),
          if (picks.isEmpty)
            EmptyState(
              art: const IllustrationView(
                NumayaIllustration.seenEveryone,
                width: 160,
              ),
              title: l10n.forYouEmptyTitle,
              body: l10n.forYouEmptyBody(hours),
              action: NumayaButton(
                label: l10n.forYouBackHome,
                small: true,
                onPressed: () => context.go(Routes.home),
              ),
            )
          else
            for (final p in picks) ...[
              _PickCard(
                person: p,
                onOpen: () => context.push('${Routes.person}/${p.id}?decide=1'),
                onLike: () => like(p),
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
          const SizedBox(height: AppSpacing.s2),
          Row(
            children: [
              const NumayaIcon(
                NumayaIcons.info,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: Text(l10n.forYouRationale, style: AppTypography.caption),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  const _PickCard({
    required this.person,
    required this.onOpen,
    required this.onLike,
  });

  final SamplePerson person;
  final VoidCallback onOpen;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Pressable(
              onTap: onOpen,
              semanticLabel: l10n.forYouOpenProfile(person.name),
              excludeChildSemantics: true,
              child: PhotoPlaceholder(
                label: l10n.discoverPhotoLabel(person.name, 1),
                aspectRatio: AppMedia.personPhoto,
                radius: AppRadii.control,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Pressable(
              onTap: onOpen,
              semanticLabel: l10n.forYouOpenProfile(person.name),
              excludeChildSemantics: true,
              pressedScale: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          l10n.profileNameAge(person.name, person.age),
                          style: AppTypography.weight(
                            AppTypography.sheetTitle,
                            AppTypography.semibold,
                          ),
                        ),
                      ),
                      if (person.verified) ...[
                        const SizedBox(width: 4),
                        const VerifiedMark(),
                      ],
                    ],
                  ),
                  if (person.job != null)
                    Text(
                      person.job!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    l10n.forYouInCommon(person.shared.length),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ),
          NavIconButton(
            icon: NumayaIcons.heart,
            label: l10n.forYouLike(person.name),
            onPressed: onLike,
          ),
        ],
      ),
    );
  }
}

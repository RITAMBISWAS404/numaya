import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/presentation/home_shell.dart';
import '../../home/presentation/tab_screens.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// Likes (B-46, V16 054 / 058): people who liked you as tiles, with All / New / Nearby view tabs
/// and an empty state per tab.
class LikesScreen extends ConsumerStatefulWidget {
  const LikesScreen({super.key});

  @override
  ConsumerState<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends ConsumerState<LikesScreen> {
  LikeFilter _filter = LikeFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final controller = ref.read(datingProvider.notifier);
    final list = controller.likes(_filter);
    final counts = {
      for (final f in LikeFilter.values) f: controller.likes(f).length,
    };

    final Widget body;
    if (list.isEmpty) {
      body = switch (_filter) {
        LikeFilter.all => EmptyState(
          art: const IllustrationView(NumayaIllustration.noMatch, width: 160),
          title: l10n.likesEmptyTitle,
          body: l10n.likesEmptyBody,
          action: NumayaButton(
            label: l10n.goToHome,
            small: true,
            onPressed: () => context.go(Routes.home),
          ),
        ),
        LikeFilter.newLikes => EmptyState(
          art: const NumayaIcon(
            NumayaIcons.heart,
            size: 36,
            color: AppColors.ink,
          ),
          title: l10n.likesNewEmptyTitle,
          body: l10n.likesNewEmptyBody,
          action: NumayaButton(
            label: l10n.showAll,
            small: true,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => setState(() => _filter = LikeFilter.all),
          ),
        ),
        LikeFilter.nearby => EmptyState(
          art: const NumayaIcon(
            NumayaIcons.nearby,
            size: 36,
            color: AppColors.ink,
          ),
          title: l10n.likesNearbyEmptyTitle,
          body: l10n.likesNearbyEmptyBody(kNearbyKm),
          action: NumayaButton(
            label: l10n.showAll,
            small: true,
            variant: NumayaButtonVariant.secondary,
            onPressed: () => setState(() => _filter = LikeFilter.all),
          ),
        ),
      };
    } else {
      body = LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - AppSpacing.s3) / 2;
          return Wrap(
            spacing: AppSpacing.s3,
            runSpacing: AppSpacing.s5,
            children: [
              for (final like in list)
                SizedBox(
                  width: w,
                  child: PersonTile(
                    title: l10n.profileNameAge(
                      like.person.name,
                      like.person.age,
                    ),
                    caption: l10n.likeTileCaption(like.person.distanceKm),
                    verified: like.person.verified,
                    semanticLabel: l10n.tileLabel(
                      like.person.name,
                      like.person.age,
                      like.matched
                          ? l10n.likeMatched
                          : like.isNew
                          ? l10n.likeNew
                          : l10n.likeTileCaption(like.person.distanceKm),
                    ),
                    badge: like.matched
                        ? StatusBadge(
                            label: l10n.likeMatched,
                            icon: NumayaIcons.check,
                            tone: BadgeTone.onPhoto,
                          )
                        : like.isNew
                        ? StatusBadge(
                            label: l10n.likeNew,
                            icon: NumayaIcons.star,
                            tone: BadgeTone.onPhoto,
                          )
                        : null,
                    onTap: () =>
                        context.push('${Routes.like}/${like.person.id}'),
                  ),
                ),
            ],
          );
        },
      );
    }

    return TabPage(
      header: TabHeader(title: l10n.tabLikes),
      subtitle: l10n.likesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ViewTabs(
            label: l10n.tabLikes,
            bleed: AppLayout.screenGutter,
            selected: _filter.index,
            onSelect: (i) => setState(() => _filter = LikeFilter.values[i]),
            options: [
              (label: l10n.likesFilterAll, count: counts[LikeFilter.all]!),
              (label: l10n.likesFilterNew, count: counts[LikeFilter.newLikes]!),
              (
                label: l10n.likesFilterNearby,
                count: counts[LikeFilter.nearby]!,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          body,
          if (list.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s5),
            Text(
              l10n.likesSampleNote,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// Someone who liked you (V16 059): an info box, their profile, and Pass / Like back. Once matched
/// the footer is "Message {name}".
class LikeProfileScreen extends ConsumerWidget {
  const LikeProfileScreen({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    final person = personById(personId);
    if (person == null || !state.isActive(personId)) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        body: EmptyState(
          title: l10n.likesEmptyTitle,
          body: l10n.likesEmptyBody,
        ),
      );
    }
    final matched = state.matches.contains(personId);
    final passed = state.likesHandled[personId] == false;
    final controller = ref.read(datingProvider.notifier);

    final Widget footer;
    if (matched) {
      footer = NumayaButton(
        label: l10n.messageName(person.name),
        icon: NumayaIcons.message,
        onPressed: () => context.pushReplacement('${Routes.chat}/$personId'),
      );
    } else if (passed) {
      footer = Text(
        l10n.likePassed(person.name),
        textAlign: TextAlign.center,
        style: AppTypography.caption,
      );
    } else {
      footer = Row(
        children: [
          Expanded(
            child: NumayaButton(
              label: l10n.likePass,
              icon: NumayaIcons.close,
              variant: NumayaButtonVariant.secondary,
              onPressed: () {
                controller.likeBack(personId, liked: false);
                NumayaToast.show(context, l10n.likePassed(person.name));
                context.pop();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: NumayaButton(
              label: l10n.likeBack,
              icon: NumayaIcons.heart,
              onPressed: () {
                controller.likeBack(personId, liked: true);
                context.pushReplacement('${Routes.match}/$personId');
              },
            ),
          ),
        ],
      );
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: person.name,
      ),
      footer: footer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s2),
          InfoCard(
            icon: NumayaIcons.heart,
            title: l10n.likeInfoTitle,
            body: matched ? l10n.likeInfoMatched : l10n.likeInfoBody,
          ),
          const SizedBox(height: AppSpacing.s3),
          PersonHeroCard(person: person),
          const SizedBox(height: AppSpacing.s3),
          ...personSections(context, person),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.likesSampleNote,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

/// Another person's profile, opened from a conversation (B-44: the header opens the profile) or
/// from For you ([canDecide]: Pass / Like at the bottom, as the expanded profile's action row).
class PersonProfileScreen extends ConsumerWidget {
  const PersonProfileScreen({
    super.key,
    required this.personId,
    this.canDecide = false,
  });

  final String personId;
  final bool canDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    final person = personById(personId);
    final decided =
        state.seen.contains(personId) || state.matches.contains(personId);
    Widget? footer;
    if (person != null && canDecide && !decided) {
      final controller = ref.read(datingProvider.notifier);
      footer = Row(
        children: [
          Expanded(
            child: NumayaButton(
              label: l10n.likePass,
              icon: NumayaIcons.close,
              variant: NumayaButtonVariant.secondary,
              onPressed: () {
                controller.decide(personId, liked: false);
                context.pop();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: NumayaButton(
              label: l10n.likeAction,
              icon: NumayaIcons.heart,
              onPressed: () {
                final result = controller.decide(personId, liked: true);
                if (result == DecisionResult.matched) {
                  context.pushReplacement('${Routes.match}/$personId');
                } else {
                  NumayaToast.show(context, l10n.discoverLiked(person.name));
                  context.pop();
                }
              },
            ),
          ),
        ],
      );
    }
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: person?.name,
      ),
      footer: footer,
      body: person == null
          ? EmptyState(
              title: l10n.personMissingTitle,
              body: l10n.personMissingBody,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s2),
                PersonHeroCard(person: person),
                const SizedBox(height: AppSpacing.s3),
                ...personSections(context, person),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n.likesSampleNote,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption,
                ),
              ],
            ),
    );
  }
}

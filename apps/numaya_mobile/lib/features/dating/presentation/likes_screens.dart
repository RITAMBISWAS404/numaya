import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../compliments/application/compliments_controller.dart';
import '../../compliments/domain/compliment.dart';
import '../../compliments/presentation/compliment_screens.dart';
import '../../compliments/presentation/compliments_inbox.dart';
import '../../home/presentation/large_title_page.dart';
import '../../lab/lab_registry.dart';
import '../../lab/likes_grid.dart';
import '../../premium/application/premium_controller.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// Likes (B-46, V16 054 / 058): people who liked you as tiles, with All / New / Nearby view tabs
/// and an empty state per tab.
class LikesScreen extends ConsumerStatefulWidget {
  const LikesScreen({super.key, this.initialTab = HeartTab.likes});

  /// `/likes?tab=compliments` opens Compliments (notification deep links, R03).
  final HeartTab initialTab;

  @override
  ConsumerState<LikesScreen> createState() => _LikesScreenState();
}

/// R03: the Heart tab's two parts. No third Matches tab: matches live in Chats.
enum HeartTab { likes, compliments }

class _LikesScreenState extends ConsumerState<LikesScreen> {
  LikeFilter _filter = LikeFilter.all;
  late HeartTab _tab = widget.initialTab;
  String? _likeVariant;

  /// One scroll position per part, kept across switches (MOT02).
  final _offsets = <HeartTab, double>{};
  late ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(LikesScreen old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) _switch(widget.initialTab);
  }

  void _switch(HeartTab tab) {
    if (tab == _tab) return;
    if (_scroll.hasClients) _offsets[_tab] = _scroll.offset;
    final old = _scroll;
    setState(() {
      _tab = tab;
      _scroll = ScrollController(initialScrollOffset: _offsets[tab] ?? 0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(complimentsProvider);
    final requests = ref.read(complimentsProvider.notifier).requests();
    ref.watch(datingProvider);
    final likeCount = ref
        .read(datingProvider.notifier)
        .likes()
        .where((l) => !l.matched)
        .length;
    // Screen group `screen-heart`: directions fix the card variants inside this screen.
    final direction = ref.watch(labVariantProvider('screen-heart'));
    final (String? likeV, String? complimentV) = switch (direction) {
      'A' => ('B', 'C'),
      'B' => (null, 'B'),
      'C' => ('A', 'D'),
      _ => (null, null),
    };
    _likeVariant = likeV;
    return LargeTitlePage(
      title: l10n.heartTitle,
      scrollController: _scroll,
      pinned: NumayaSegmented(
        label: l10n.heartTitle,
        selected: _tab.index,
        onSelect: (i) => _switch(HeartTab.values[i]),
        options: [
          (
            label: l10n.heartTabLikes,
            count: likeCount,
            key: const ValueKey('heart-tab-likes'),
          ),
          (
            label: l10n.heartTabCompliments,
            count: requests.length,
            key: const ValueKey('heart-tab-compliments'),
          ),
        ],
      ),
      child: KeyedSubtree(
        key: ValueKey('heart-${_tab.name}'),
        child: _tab == HeartTab.likes
            ? _likesBody(context)
            : ComplimentsInbox(requests: requests, cardVariant: complimentV),
      ),
    );
  }

  Widget _likesBody(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(datingProvider);
    final controller = ref.read(datingProvider.notifier);
    final list = controller.likes(_filter);
    final counts = {
      for (final f in LikeFilter.values) f: controller.likes(f).length,
    };
    // S18: free members see how many people like them, not who (PRD 06: incoming profiles are a
    // Premium benefit). Matches already made stay in Chats.
    final premium = ref.watch(premiumProvider).active;
    final hidden = controller.likes().where((l) => !l.matched).toList();
    if (!premium && hidden.isNotEmpty) {
      return _LockedLikes(count: hidden.length);
    }

    final Widget body;
    if (list.isEmpty) {
      body = switch (_filter) {
        LikeFilter.all => EmptyState(
          art: const IllustrationView(
            NumayaIllustration.mascotWaiting,
            width: 176,
          ),
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
      // Card family `like-tile` (Visual Lab V2).
      body = LikesGrid(
        variant: _likeVariant,
        items: [
          for (final like in list)
            (
              person: like.person,
              caption: l10n.likeTileCaption(like.person.distanceKm),
              semanticLabel: l10n.tileLabel(
                like.person.name,
                like.person.age,
                like.matched
                    ? l10n.likeMatched
                    : like.isNew
                    ? l10n.likeNew
                    : l10n
                          .likeTileCaption(like.person.distanceKm)
                          .replaceAll(MetaText.joiner, ', '),
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
              onTap: () => context.push('${Routes.like}/${like.person.id}'),
            ),
        ],
      );
    }

    return KeyedSubtree(
      // Bumble's Liked You has no lede: the title and the counted chips say it (ER-04).
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
          if (list.isNotEmpty) ...[],
        ],
      ),
    );
  }
}

/// S18 free state: the count, locked tiles and the Premium offer; Discover stays the free path.
class _LockedLikes extends StatelessWidget {
  const _LockedLikes({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('likes-locked'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final w = (box.maxWidth - AppSpacing.s3) / 2;
            return Wrap(
              spacing: AppSpacing.s3,
              runSpacing: AppSpacing.s3,
              children: [
                for (var i = 0; i < count.clamp(1, 4); i++)
                  SizedBox(
                    width: w,
                    child: PhotoPlaceholder(
                      label: l10n.likesLockedTile,
                      aspectRatio: AppMedia.personPhoto,
                      child: const Center(
                        child: NumayaIcon(
                          NumayaIcons.lock,
                          size: 28,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.s5),
        Semantics(
          header: true,
          child: Text(
            l10n.likesLockedTitle(count),
            style: AppTypography.section,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(l10n.likesLockedBody, style: AppTypography.bodySm),
        const SizedBox(height: AppSpacing.s4),
        NumayaButton(
          label: l10n.likesLockedCta,
          onPressed: () => context.push(
            '${Routes.paywall}?feature=${PremiumFeature.seeLikes.name}',
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        NumayaButton(
          label: l10n.goToHome,
          variant: NumayaButtonVariant.secondary,
          onPressed: () => context.go(Routes.home),
        ),
      ],
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
          art: const IllustrationView(
            NumayaIllustration.mascotWaiting,
            width: 176,
          ),
          title: l10n.likesEmptyTitle,
          body: l10n.likesEmptyBody,
        ),
      );
    }
    final matched = state.matches.contains(personId);
    final passed = state.likesHandled[personId] == false;
    final controller = ref.read(datingProvider.notifier);
    // S19 is a Premium view: a free member reaching it (a stale link) gets the locked state.
    if (!matched && !ref.watch(premiumProvider).active) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s6),
          child: _LockedLikes(count: controller.likes().length),
        ),
      );
    }

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
        style: AppTypography.helper,
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
                final result = controller.likeBack(personId, liked: true);
                if (result == DecisionResult.outOfLikes) {
                  context.push(Routes.allowance);
                  return;
                }
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
          PersonHeroCard(
            person: person,
            // The same Bumble card as Discover (ER-01), identity on the photo.
            photoHeight: (MediaQuery.sizeOf(context).height * 0.6).clamp(
              300.0,
              560.0,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          ...personSections(context, person),
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
                } else if (result == DecisionResult.outOfLikes) {
                  context.push(Routes.allowance);
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
              art: const IllustrationSlot(
                slot: 'person_missing',
                label: 'This profile is no longer here',
                width: 176,
              ),
              title: l10n.personMissingTitle,
              body: l10n.personMissingBody,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s2),
                PersonHeroCard(
                  person: person,
                  // The same Bumble card as Discover (ER-01), identity on the photo.
                  photoHeight: (MediaQuery.sizeOf(context).height * 0.6).clamp(
                    300.0,
                    560.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                ...personSections(
                  context,
                  person,
                  // S12: Compliment anchors while the member can still decide.
                  onCompliment: canDecide && !decided
                      ? (ComplimentTarget t) =>
                            context.push(complimentRoute(person.id, t))
                      : null,
                ),
              ],
            ),
    );
  }
}

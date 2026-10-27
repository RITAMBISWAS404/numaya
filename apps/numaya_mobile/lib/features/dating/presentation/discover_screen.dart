import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/application/discovery_filters.dart';
import '../../home/presentation/tab_screens.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';
import 'safety_sheets.dart';

/// Home (B-30 / B-32, V16 019–024): one sample profile at a time as a scroll (photo card, prompt,
/// about me, shared interests, location, photos) ending in Pass / SuperSwipe / Like. Swipe the first
/// photo right to like, left to pass. Liking someone who already liked you opens the match.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _scroll = ScrollController();
  bool _retrying = false;
  String? _shownId;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _decide(
    SamplePerson person, {
    required bool liked,
    bool superSwipe = false,
  }) {
    final l10n = context.l10n;
    final result = ref
        .read(datingProvider.notifier)
        .decide(person.id, liked: liked);
    if (result == DecisionResult.matched) {
      unawaited(context.push('${Routes.match}/${person.id}'));
    } else if (liked) {
      NumayaToast.show(
        context,
        superSwipe
            ? l10n.discoverSuperSent(person.name)
            : l10n.discoverLiked(person.name),
        aboveFooter: false,
      );
    }
  }

  Future<void> _options(SamplePerson person) async {
    final l10n = context.l10n;
    final choice = await showNumayaActionSheet(
      context: context,
      cancelLabel: l10n.cancel,
      actions: [
        (icon: NumayaIcons.flag, label: l10n.optionReport, destructive: true),
        (
          icon: NumayaIcons.block,
          label: l10n.optionBlock(person.name),
          destructive: true,
        ),
      ],
    );
    if (!mounted || choice == null) return;
    if (choice == 0) {
      await showReportSheet(context, ref, person);
    } else if (await showBlockSheet(context, ref, person) && mounted) {
      NumayaToast.show(
        context,
        l10n.blockedToast(person.name),
        aboveFooter: false,
      );
    }
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(datingProvider);
    final filters = ref.watch(discoveryFiltersProvider);
    final controller = ref.read(datingProvider.notifier);
    final queue = controller.queue(filters);
    final person = queue.isEmpty ? null : queue.first;
    final lastPass = state.lastPass == null
        ? null
        : personById(state.lastPass!);
    final failing = state.simulateErrors && !_retrying;

    // The next person starts at their photo, not mid-scroll.
    if (person?.id != _shownId) {
      _shownId = person?.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      });
    }

    final header = SizedBox(
      height: AppSizes.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Wordmark(small: true),
            if (!state.snoozed && lastPass != null)
              Align(
                alignment: Alignment.centerLeft,
                child: NavIconButton(
                  icon: NumayaIcons.undo,
                  label: l10n.discoverUndo(lastPass.name),
                  onPressed: controller.undo,
                ),
              ),
            if (!state.snoozed)
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NavIconButton(
                      icon: NumayaIcons.filter,
                      label: l10n.discoverFilters,
                      onPressed: () => showFiltersSheet(context, ref),
                    ),
                    if (person != null && !failing) ...[
                      const SizedBox(width: AppSpacing.s2),
                      NavIconButton(
                        icon: NumayaIcons.more,
                        label: l10n.discoverOptions,
                        onPressed: () => _options(person),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    Widget centered(Widget child) =>
        TabPage(header: header, centered: true, child: child);

    if (state.snoozed) {
      return centered(
        EmptyState(
          art: const IllustrationView(NumayaIllustration.paused, width: 132),
          title: l10n.discoverPausedTitle,
          body: l10n.discoverPausedBody,
          action: NumayaButton(
            label: l10n.discoverResume,
            small: true,
            variant: NumayaButtonVariant.primary,
            onPressed: () => controller.setSnoozed(false),
          ),
        ),
      );
    }
    if (_retrying) return centered(const _ProfileSkeleton());
    if (failing) {
      return centered(
        EmptyState(
          art: const NumayaIcon(
            NumayaIcons.wifiOff,
            size: 36,
            color: AppColors.ink,
          ),
          title: l10n.discoverErrorTitle,
          body: l10n.discoverErrorBody,
          action: NumayaButton(
            label: l10n.discoverRetry,
            small: true,
            onPressed: _retry,
          ),
        ),
      );
    }
    if (person == null) {
      final hidden = controller.hiddenByFilters();
      return centered(
        hidden > 0
            ? EmptyState(
                art: const NumayaIcon(
                  NumayaIcons.filter,
                  size: 36,
                  color: AppColors.ink,
                ),
                title: l10n.discoverNoFitTitle,
                body: l10n.discoverNoFitBody(
                  hidden,
                  filters.minAge,
                  filters.maxAge,
                  filters.maxDistanceKm,
                ),
                action: NumayaButton(
                  label: l10n.discoverWiden,
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: ref
                      .read(discoveryFiltersProvider.notifier)
                      .broaden,
                ),
              )
            : EmptyState(
                art: const IllustrationView(
                  NumayaIllustration.seenEveryone,
                  width: 132,
                ),
                title: l10n.discoverSeenAllTitle,
                body: l10n.discoverSeenAllBody,
                action: NumayaButton(
                  label: l10n.discoverShowAgain,
                  small: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: controller.resetDiscovery,
                ),
              ),
      );
    }

    return TabPage(
      header: header,
      scrollController: _scroll,
      topGap: false,
      gutter: AppSpacing.gutterTight,
      child: Column(
        key: ValueKey(person.id),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SwipeCard(
            person: person,
            onDecide: (liked) => _decide(person, liked: liked),
            superAction: RoundAction(
              kind: ActionKind.superSwipe,
              label: l10n.discoverSuperSwipe,
              floating: true,
              onPressed: () => _decide(person, liked: true, superSwipe: true),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          ...personSections(context, person),
          const SizedBox(height: AppSpacing.s6),
          // V16 `.fl-pf .action-bar`: 8pt more inset than the photo cards.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoundAction(
                  kind: ActionKind.pass,
                  label: l10n.discoverPass,
                  onPressed: () => _decide(person, liked: false),
                ),
                RoundAction(
                  kind: ActionKind.superSwipe,
                  label: l10n.discoverSuperSwipe,
                  onPressed: () =>
                      _decide(person, liked: true, superSwipe: true),
                ),
                RoundAction(
                  kind: ActionKind.like,
                  label: l10n.discoverLike,
                  onPressed: () => _decide(person, liked: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.discoverSampleNote,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

/// The first photo card, draggable: past 96pt right likes, left passes (the web's threshold).
class _SwipeCard extends StatefulWidget {
  const _SwipeCard({
    required this.person,
    required this.onDecide,
    required this.superAction,
  });

  final SamplePerson person;
  final ValueChanged<bool> onDecide;
  final Widget superAction;

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard> {
  static const _threshold = 96.0;
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stamp = _dx >= _threshold / 2
        ? l10n.discoverLike
        : _dx <= -_threshold / 2
        ? l10n.discoverPass
        : null;
    return Semantics(
      label: l10n.discoverSwipeHint(widget.person.name),
      child: GestureDetector(
        onHorizontalDragUpdate: (d) => setState(() => _dx += d.delta.dx),
        onHorizontalDragEnd: (_) {
          final dx = _dx;
          setState(() => _dx = 0);
          if (dx.abs() >= _threshold) widget.onDecide(dx > 0);
        },
        onHorizontalDragCancel: () => setState(() => _dx = 0),
        child: AnimatedContainer(
          duration: _dx == 0
              ? AppMotion.duration(context, AppMotion.base)
              : Duration.zero,
          curve: AppMotion.easeOut,
          transform: Matrix4.translationValues(_dx, 0, 0)
            ..rotateZ(_dx / 24 * 3.1415926535 / 180),
          transformAlignment: Alignment.bottomCenter,
          // Fills the screen above the tab bar, as V16 (16pt left under it).
          child: PersonHeroCard(
            person: widget.person,
            action: widget.superAction,
            stamp: stamp,
            height: TabPage.viewportOf(context) - AppSpacing.s4,
          ),
        ),
      ),
    );
  }
}

/// Loading placeholder shaped like the profile (states-and-recovery: skeletons, not spinners).
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: AppRadii.all(AppRadii.tag),
      ),
    );
    return Semantics(
      label: 'Loading',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: AppRadii.all(AppRadii.photo),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          bar(180, 20),
          const SizedBox(height: AppSpacing.s2),
          bar(120, 14),
        ],
      ),
    );
  }
}

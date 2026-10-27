import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../home/application/discovery_filters.dart';
import '../../home/presentation/filters_sheet.dart';
import '../../home/presentation/tab_screens.dart';
import '../../premium/application/premium_controller.dart';
import '../../settings/presentation/settings_screen.dart';
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

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  bool _retrying = false;
  String? _shownId;

  /// The decided profile leaving (MOTION_DESIGN_AUDIT "Decide"): right for a like, left for a
  /// pass, up for a SuperSwipe. The decision itself is applied when it has left.
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: AppMotion.exit,
  );
  Offset _exitDirection = Offset.zero;

  @override
  void dispose() {
    _exit.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _decide(
    SamplePerson person, {
    required bool liked,
    bool superSwipe = false,
  }) async {
    // One decision at a time: taps during the 200 ms exit are ignored.
    if (_exit.isAnimating) return;
    final controller = ref.read(datingProvider.notifier);
    if (superSwipe && controller.superSwipesLeft <= 0) {
      // No SuperSwipes left: the contextual paywall names what triggered it (D-14).
      unawaited(
        context.push(
          '${Routes.paywall}?feature=${PremiumFeature.superSwipes.name}',
        ),
      );
      return;
    }
    AppHaptics.fire(context, HapticMoment.commit);
    if (!AppMotion.reduced(context)) {
      setState(
        () => _exitDirection = superSwipe
            ? const Offset(0, -1)
            : Offset(liked ? 1 : -1, 0),
      );
      try {
        await _exit.forward(from: 0).orCancel;
      } on TickerCanceled {
        return;
      }
      if (!mounted) return;
    }
    _commit(person, liked: liked, superSwipe: superSwipe);
    _exit.value = 0;
  }

  void _commit(
    SamplePerson person, {
    required bool liked,
    required bool superSwipe,
  }) {
    final l10n = context.l10n;
    final controller = ref.read(datingProvider.notifier);
    final result = superSwipe
        ? controller.superSwipe(person.id)
        : controller.decide(person.id, liked: liked);
    if (result == null) {
      // No SuperSwipes left: the contextual paywall names what triggered it (D-14).
      unawaited(
        context.push(
          '${Routes.paywall}?feature=${PremiumFeature.superSwipes.name}',
        ),
      );
      return;
    }
    if (result == DecisionResult.matched) {
      unawaited(context.push('${Routes.match}/${person.id}'));
    } else if (liked) {
      NumayaToast.show(
        context,
        superSwipe
            ? l10n.discoverSuperSentLeft(
                controller.superSwipesLeft,
                person.name,
              )
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
            if (!state.snoozed)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // B-33 curated picks, a sub-view of Home (P-08: both formats).
                    NavIconButton(
                      icon: NumayaIcons.sparkle,
                      label: l10n.forYouOpen,
                      onPressed: () => context.push(Routes.forYou),
                    ),
                    if (lastPass != null) ...[
                      const SizedBox(width: AppSpacing.s2),
                      NavIconButton(
                        icon: NumayaIcons.undo,
                        label: l10n.discoverUndo(lastPass.name),
                        onPressed: controller.undo,
                      ),
                    ],
                  ],
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
            onPressed: () => SettingsScreen.endSnooze(context, ref),
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
      child: _DecisionMotion(
        key: ValueKey(person.id),
        exit: _exit,
        direction: _exitDirection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.showingFallback(filters)) ...[
              StatusBanner(
                title: l10n.discoverFallbackTitle,
                body: l10n.discoverFallbackBody,
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
            _SwipeCard(
              person: person,
              onDecide: (liked) => unawaited(_decide(person, liked: liked)),
              superAction: RoundAction(
                kind: ActionKind.superSwipe,
                label: l10n.discoverSuperSwipe,
                floating: true,
                onPressed: () =>
                    unawaited(_decide(person, liked: true, superSwipe: true)),
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
                    onPressed: () => unawaited(_decide(person, liked: false)),
                  ),
                  RoundAction(
                    kind: ActionKind.superSwipe,
                    label: l10n.discoverSuperSwipe,
                    onPressed: () => unawaited(
                      _decide(person, liked: true, superSwipe: true),
                    ),
                  ),
                  RoundAction(
                    kind: ActionKind.like,
                    label: l10n.discoverLike,
                    onPressed: () => unawaited(_decide(person, liked: true)),
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
      ),
    );
  }
}

/// A profile settling in when it becomes the current one, and leaving in [direction] while [exit]
/// runs. Under reduced motion the profile is simply replaced.
class _DecisionMotion extends StatelessWidget {
  const _DecisionMotion({
    super.key,
    required this.exit,
    required this.direction,
    required this.child,
  });

  final Animation<double> exit;
  final Offset direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    final width = MediaQuery.sizeOf(context).width;
    // Entering: a small settle (opacity and 97% → 100%), quick because it happens on every
    // decision.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.state,
      curve: AppMotion.easeOut,
      builder: (context, enter, child) => AnimatedBuilder(
        animation: exit,
        builder: (context, child) {
          final t = AppMotion.easeOut.transform(exit.value);
          return Opacity(
            opacity: (enter * (1 - t)).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(
                direction.dx * width * 0.5 * t,
                direction.dy * 160 * t,
              ),
              child: Transform.scale(scale: 0.97 + 0.03 * enter, child: child),
            ),
          );
        },
        child: child,
      ),
      child: child,
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

  /// A flick this fast decides even short of the threshold (logical pixels per second).
  static const _flingVelocity = 800.0;
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
        onHorizontalDragUpdate: (d) {
          final wasPast = _dx.abs() >= _threshold;
          setState(() => _dx += d.delta.dx);
          // One tick each time the card crosses the line, so the stamp is felt as well as seen.
          if (wasPast != _dx.abs() >= _threshold) {
            AppHaptics.fire(context, HapticMoment.selection);
          }
        },
        onHorizontalDragEnd: (d) {
          final v = d.velocity.pixelsPerSecond.dx;
          // Past the line, or flung firmly the way it already leans.
          final decided =
              _dx.abs() >= _threshold ||
              (v.abs() >= _flingVelocity &&
                  _dx.abs() >= 24 &&
                  v.sign == _dx.sign);
          if (decided) {
            // The card stays where the finger left it and leaves from there.
            widget.onDecide(_dx > 0);
          } else {
            setState(() => _dx = 0);
          }
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

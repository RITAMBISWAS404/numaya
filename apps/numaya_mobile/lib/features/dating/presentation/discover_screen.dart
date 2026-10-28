import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

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
///
/// Reading a profile (docs/mobile/DISCOVERY_SCREEN_INVENTORY.md): a bar under the header shows how
/// far through it you are (Bumble); once the photo card has scrolled away, Pass / SuperSwipe / Like
/// float over the profile (Hinge, happn) until the inline row comes into view; Android back
/// returns to the top before it leaves Home. Any photo opens the photo viewer.
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

  /// Retries that failed again (the error then says so).
  int _failedRetries = 0;

  /// Scrolled past most of the photo card: the floating actions show and back returns to the top.
  final _reading = ValueNotifier(false);

  /// The inline action row at the end is close enough to use instead of the floating one.
  final _nearEnd = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    // Past the photo card and its decision row: the floating row takes over (RD-12).
    _reading.value = p.pixels > _detailsOffset() - AppSpacing.s4;
  }

  /// Where the profile below the card and its decision row starts.
  double _detailsOffset() {
    final width =
        math.min(MediaQuery.sizeOf(context).width, AppSpacing.contentMax) -
        2 * AppLayout.screenGutter;
    return width / AppMedia.personPhoto +
        AppLayout.itemGap +
        DecisionBar.height;
  }

  void _toTop() {
    if (!_scroll.hasClients) return;
    if (AppMotion.reduced(context)) {
      _scroll.jumpTo(0);
    } else {
      unawaited(
        _scroll.animateTo(
          0,
          duration: AppMotion.push,
          curve: AppMotion.emphasized,
        ),
      );
    }
  }

  /// "Show more about …": the profile below the photo card.
  void _toDetails() {
    if (!_scroll.hasClients) return;
    final target = math.min(
      _detailsOffset() + AppLayout.itemGap,
      _scroll.position.maxScrollExtent,
    );
    if (AppMotion.reduced(context)) {
      _scroll.jumpTo(target);
    } else {
      unawaited(
        _scroll.animateTo(
          target,
          duration: AppMotion.push,
          curve: AppMotion.emphasized,
        ),
      );
    }
  }

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
    _reading.dispose();
    _nearEnd.dispose();
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
        belowHeader: true,
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
        belowHeader: true,
      );
    }
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _retrying = false;
      if (ref.read(datingProvider).simulateErrors) _failedRetries++;
    });
  }

  void _undo() {
    final back = ref.read(datingProvider.notifier).undo();
    if (back == null) return;
    AppHaptics.fire(context, HapticMoment.selection);
    NumayaToast.show(
      context,
      context.l10n.discoverUndone(back.name),
      belowHeader: true,
    );
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
    if (!state.simulateErrors) _failedRetries = 0;
    final narrowed = ref.read(discoveryFiltersProvider.notifier).narrowed;

    // The next person starts at their photo, not mid-scroll.
    if (person?.id != _shownId) {
      _shownId = person?.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
        _reading.value = false;
      });
    }

    final header = SizedBox(
      height: AppSizes.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenGutter),
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
                        onPressed: _undo,
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
                    _FiltersButton(
                      label: narrowed
                          ? l10n.discoverFiltersChanged
                          : l10n.discoverFilters,
                      changed: narrowed,
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
            if (person != null && !failing && !_retrying && !state.snoozed)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ReadProgress(scroll: _scroll),
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
          title: _failedRetries > 0
              ? l10n.discoverErrorStillTitle
              : l10n.discoverErrorTitle,
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
            : controller.passedCount() > 0
            ? EmptyState(
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
              )
            // Everyone seen was liked: nothing can come back round, and the demo adds nobody new.
            : EmptyState(
                art: const IllustrationView(
                  NumayaIllustration.seenEveryone,
                  width: 132,
                ),
                title: l10n.discoverSeenAllTitle,
                body: l10n.discoverSeenAllLikedBody,
                action: controller.unansweredLikes() > 0
                    ? NumayaButton(
                        label: l10n.discoverSeeLikes,
                        small: true,
                        variant: NumayaButtonVariant.secondary,
                        onPressed: () => context.go(Routes.likes),
                      )
                    : null,
              ),
      );
    }

    void decide({required bool liked, bool superSwipe = false}) =>
        unawaited(_decide(person, liked: liked, superSwipe: superSwipe));
    void openPhotos(int start) =>
        unawaited(context.push(Routes.personPhotos(person.id, start: start)));

    final page = TabPage(
      header: header,
      scrollController: _scroll,
      topGap: false,
      gutter: AppLayout.screenGutter,
      overlay: _FloatingActions(
        visible: _reading,
        nearEnd: _nearEnd,
        onPass: () => decide(liked: false),
        onSuper: () => decide(liked: true, superSwipe: true),
        onLike: () => decide(liked: true),
      ),
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
              onOpenPhotos: () => openPhotos(1),
              onMore: _toDetails,
              onDecide: (liked) => unawaited(_decide(person, liked: liked)),
            ),
            const SizedBox(height: AppLayout.itemGap),
            // One decision row right under the card (RD-12); it floats once scrolled past.
            DecisionBar(
              passLabel: l10n.discoverPass,
              superLabel: l10n.discoverSuperSwipe,
              likeLabel: l10n.discoverLike,
              onPass: () => decide(liked: false),
              onSuper: () => decide(liked: true, superSwipe: true),
              onLike: () => decide(liked: true),
            ),
            if (!state.coachDone) ...[
              const SizedBox(height: AppLayout.itemGap),
              _CoachHint(onDismiss: controller.dismissCoach),
            ],
            const SizedBox(height: AppLayout.itemGap),
            ...personSections(context, person, onPhoto: openPhotos),
            const SizedBox(height: AppLayout.sectionGap),
            // happn's "Report & block" and Bumble's "Hide and Report" close the profile.
            Center(
              child: TextLink(
                label: l10n.discoverReportBlock(person.name),
                muted: true,
                onPressed: () => _options(person),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.discoverSampleNote,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            // Room for the floating decision row over the end of the profile.
            const SizedBox(height: DecisionBar.height + AppSpacing.s4),
          ],
        ),
      ),
    );

    // Deep in a profile, Android back returns to its photo first; at the top it leaves Home.
    return ValueListenableBuilder<bool>(
      valueListenable: _reading,
      builder: (context, reading, child) => PopScope(
        canPop: !reading,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _toTop();
        },
        child: child!,
      ),
      child: page,
    );
  }
}

/// The filters header button, with a small purple mark when the filters differ from the member's
/// preferences (the label says so too).
class _FiltersButton extends StatelessWidget {
  const _FiltersButton({
    required this.label,
    required this.changed,
    required this.onPressed,
  });

  final String label;
  final bool changed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        NavIconButton(
          icon: NumayaIcons.filter,
          label: label,
          onPressed: onPressed,
        ),
        if (changed)
          Positioned(
            top: 2,
            right: 2,
            child: IgnorePointer(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: AppBorders.selected,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// How far through the current profile the member has read (Bumble's bar under the header).
/// Decorative: the profile itself is the content.
class _ReadProgress extends StatelessWidget {
  const _ReadProgress({required this.scroll});

  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: scroll,
        builder: (context, _) {
          var t = 0.0;
          if (scroll.hasClients && scroll.position.hasContentDimensions) {
            final max = scroll.position.maxScrollExtent;
            t = max <= 0 ? 0 : (scroll.position.pixels / max).clamp(0.0, 1.0);
          }
          return Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: AppRadii.all(AppRadii.pill),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: t,
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Pass / SuperSwipe / Like floating over a profile being read, so a decision never needs a
/// scroll back (Hinge's floating ×, happn's action bar). Hidden over the photo card, which has
/// its own, and near the end, where the inline row takes over.
class _FloatingActions extends StatefulWidget {
  const _FloatingActions({
    required this.visible,
    required this.nearEnd,
    required this.onPass,
    required this.onSuper,
    required this.onLike,
  });

  final ValueListenable<bool> visible;
  final ValueListenable<bool> nearEnd;
  final VoidCallback onPass;
  final VoidCallback onSuper;
  final VoidCallback onLike;

  @override
  State<_FloatingActions> createState() => _FloatingActionsState();
}

class _FloatingActionsState extends State<_FloatingActions> {
  late final Listenable _changes = Listenable.merge([
    widget.visible,
    widget.nearEnd,
  ]);

  /// In the tree: showing, or still fading out. Once gone it is removed entirely, so nothing
  /// hidden lingers for screen readers or hit tests.
  bool _mounted = false;

  bool get _show => widget.visible.value && !widget.nearEnd.value;

  @override
  void initState() {
    super.initState();
    _changes.addListener(_changed);
  }

  @override
  void dispose() {
    _changes.removeListener(_changed);
    super.dispose();
  }

  /// False for the first frame after mounting, so the bar rises in from its hidden position.
  bool _entered = false;

  void _changed() {
    if (_show && !_mounted) {
      _entered = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _entered = true);
      });
    }
    setState(() {
      if (_show) _mounted = true;
    });
    // Under reduced motion there is no fade to wait for.
    if (!_show && AppMotion.reduced(context)) setState(() => _mounted = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final show = _show && (_entered || AppMotion.reduced(context));
    if (!_mounted) return const SizedBox.shrink();
    final duration = AppMotion.duration(context, AppMotion.state);
    return Builder(
      builder: (context) {
        return IgnorePointer(
          ignoring: !show,
          child: ExcludeSemantics(
            excluding: !show,
            child: AnimatedSlide(
              offset: show ? Offset.zero : const Offset(0, 0.6),
              duration: duration,
              curve: AppMotion.easeOut,
              child: AnimatedOpacity(
                opacity: show ? 1 : 0,
                duration: duration,
                curve: AppMotion.easeOut,
                onEnd: () {
                  if (!_show && mounted) setState(() => _mounted = false);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenGutter,
                    0,
                    AppLayout.screenGutter,
                    AppSpacing.s4,
                  ),
                  child: DecisionBar(
                    passLabel: l10n.discoverPass,
                    superLabel: l10n.discoverSuperSwipe,
                    likeLabel: l10n.discoverLike,
                    floating: true,
                    onPass: widget.onPass,
                    onSuper: widget.onSuper,
                    onLike: widget.onLike,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// First-visit tip on the photo card (B-31, as a small card rather than a dimmed overlay, so the
/// profile stays visible). Gone after the first decision or when hidden.
class _CoachHint extends StatelessWidget {
  const _CoachHint({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s2,
        AppSpacing.s1,
        AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.all(AppRadii.card),
      ),
      child: Row(
        children: [
          const NumayaIcon(
            NumayaIcons.cards,
            size: AppSizes.iconMd,
            color: AppColors.ink,
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(l10n.discoverCoach, style: AppTypography.bodySm),
          ),
          NavIconButton(
            icon: NumayaIcons.close,
            label: l10n.discoverCoachDismiss,
            style: NavButtonStyle.plain,
            onPressed: onDismiss,
          ),
        ],
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
    required this.onOpenPhotos,
    required this.onMore,
  });

  final SamplePerson person;
  final VoidCallback onOpenPhotos;
  final VoidCallback onMore;
  final ValueChanged<bool> onDecide;

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
          child: PersonHeroCard(
            person: widget.person,
            stamp: stamp,
            onOpenPhotos: widget.onOpenPhotos,
            onMore: widget.onMore,
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
            aspectRatio: AppMedia.personPhoto,
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

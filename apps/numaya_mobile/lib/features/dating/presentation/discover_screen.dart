import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/application/economy_controller.dart';
import '../../compliments/domain/compliment.dart';
import '../../compliments/presentation/compliment_screens.dart';
import '../../home/application/discovery_filters.dart';
import '../../home/presentation/filters_sheet.dart';
import '../../home/presentation/tab_screens.dart';
import '../../lab/lab_registry.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/dating_controller.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';
import 'safety_sheets.dart';

/// Home (B-30 / B-32): one sample profile at a time as a scroll (photo card, prompt, about me,
/// shared interests, photos, location). Decisions are swipes only (UI-016): swipe the photo right
/// to like, left to pass; screen readers get Like and Pass actions on the photo, and keyboards the
/// left and right arrows. Liking someone who already liked you opens the match.
///
/// Header (UI-013): the wordmark on the left; Backtrack, then Filter on the right. Backtrack brings
/// back the last person passed (one step, as Bumble's). Android back returns to the top of a long
/// profile before it leaves Home. Any photo opens the photo viewer.
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

  /// Scrolled past the photo card: Android back returns to the top first.
  final _reading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    _reading.value = p.pixels > _detailsOffset() - AppSpacing.s4;
  }

  /// The hero card (the photo and its identity), measured for where the profile starts.
  final _heroKey = GlobalKey();

  /// Where the profile below the hero card starts: the card's bottom edge in scroll offset,
  /// measured from the laid-out card (so text size and banners above it are accounted for).
  double _detailsOffset() {
    final box = _heroKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport != null) {
        return viewport.getOffsetToReveal(box, 0).offset + box.size.height;
      }
    }
    final width =
        math.min(MediaQuery.sizeOf(context).width, AppSpacing.contentMax) -
        2 * AppLayout.screenGutter;
    return width / AppMedia.personPhoto;
  }

  /// Only switches the hero card to its overlay layout now: the frame itself is the 3:4 portrait
  /// (UI-011).
  double _photoHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    final h =
        mq.size.height -
        mq.padding.top -
        AppSizes.topBar -
        mq.padding.bottom -
        AppSpacing.s4 * 2;
    return h.clamp(300.0, 620.0);
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
  /// pass. The decision itself is applied when it has left.
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: AppMotion.exit,
  );
  Offset _exitDirection = Offset.zero;

  /// The person whose decision is in flight. A second action on them (a double swipe, a drag that
  /// ends during the exit, an accessibility action from the previous frame) is ignored, so nobody
  /// is liked or passed twice.
  String? _deciding;

  @override
  void dispose() {
    _exit.dispose();
    _scroll.dispose();
    _reading.dispose();
    super.dispose();
  }

  Future<void> _decide(SamplePerson person, {required bool liked}) async {
    // One decision at a time: input during the 200 ms exit is ignored, and so is any action on
    // someone already decided.
    if (_exit.isAnimating || _deciding != null) return;
    if (ref.read(datingProvider).seen.contains(person.id)) return;
    // S17: no likes left today. The card stays; passing is still free.
    if (liked && ref.read(economyProvider.notifier).likesLeft() <= 0) {
      AppHaptics.fire(context, HapticMoment.reject);
      unawaited(context.push(Routes.allowance));
      return;
    }
    AppHaptics.fire(context, HapticMoment.commit);
    _deciding = person.id;
    try {
      if (!AppMotion.reduced(context)) {
        setState(() => _exitDirection = Offset(liked ? 1 : -1, 0));
        try {
          await _exit.forward(from: 0).orCancel;
        } on TickerCanceled {
          return;
        }
        if (!mounted) return;
      }
      _commit(person, liked: liked);
      _exit.value = 0;
    } finally {
      _deciding = null;
    }
  }

  void _commit(SamplePerson person, {required bool liked}) {
    final l10n = context.l10n;
    final result = ref
        .read(datingProvider.notifier)
        .decide(person.id, liked: liked);
    if (result == DecisionResult.matched) {
      unawaited(context.push('${Routes.match}/${person.id}'));
    } else if (result == DecisionResult.outOfLikes) {
      unawaited(context.push(Routes.allowance));
    } else if (liked) {
      NumayaToast.show(
        context,
        l10n.discoverLiked(person.name),
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
    ref.watch(economyProvider);
    final economy = ref.read(economyProvider.notifier);
    final likesLeft = economy.likesLeft();

    // The next person starts at their photo, not mid-scroll.
    if (person?.id != _shownId) {
      _shownId = person?.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
        _reading.value = false;
      });
    }

    // UI-013: the wordmark on the left and exactly two controls on the right, Backtrack then
    // Filter; no strip under the header. The wordmark gets the room the buttons leave, so on a
    // 320pt phone it shows the mark alone.
    final buttons = state.snoozed ? 0 : 2;
    final wordmarkRoom =
        math.min(MediaQuery.sizeOf(context).width, AppSpacing.contentMax) -
        2 * AppLayout.screenGutter -
        (buttons == 0
            ? 0
            : AppSpacing.s2 +
                  buttons * AppSizes.iconButtonSlot +
                  (buttons - 1) * AppLayout.headerActionLayoutGap);

    // UC-04: the tab-root header height, shared with Likes, Messages and Profile.
    final header = SizedBox(
      height: AppSizes.tabHeader,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenGutter),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wordmark(small: true, maxWidth: wordmarkRoom),
              ),
            ),
            if (!state.snoozed) ...[
              const SizedBox(width: AppSpacing.s2),
              // UC-02: the shared header action group (8pt between tiles).
              HeaderActions(
                actions: [
                  // Backtrack: one step, only for a pass (a like has been sent). Disabled, and
                  // announced as such, until there is someone to bring back.
                  NavIconButton(
                    key: const ValueKey('discover-backtrack'),
                    icon: NumayaIcons.undo,
                    label: lastPass == null
                        ? l10n.discoverBacktrackNone
                        : l10n.discoverUndo(lastPass.name),
                    onPressed: lastPass == null ? null : _undo,
                  ),
                  _FiltersButton(
                    label: narrowed
                        ? l10n.discoverFiltersChanged
                        : l10n.discoverFilters,
                    changed: narrowed,
                    onPressed: () => showFiltersSheet(context, ref),
                  ),
                ],
              ),
            ],
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

    void openPhotos(int start) =>
        unawaited(context.push(Routes.personPhotos(person.id, start: start)));
    void compliment(ComplimentTarget target) =>
        unawaited(openCompliment(context, ref, person.id, target));

    // Screen group `screen-discover`: directions fix the photo and prompt variants here.
    final direction = ref.watch(labVariantProvider('screen-discover'));
    final (String? photoV, String? promptV) = switch (direction) {
      'A' => ('A', 'A'),
      'B' => ('O', 'C'),
      'C' => ('C', 'B'),
      _ => (null, null),
    };
    final discoverPhotoV =
        photoV ?? ref.watch(labVariantProvider('discover-photo'));
    final v7 = ref.watch(labVariantProvider('v7-discover'));
    final page = TabPage(
      header: header,
      scrollController: _scroll,
      topGap: false,
      gutter: ref.watch(labVariantProvider('v6-discover-margin')) == 'A'
          ? AppSpacing.gutterTight
          : AppLayout.screenGutter,
      child: _DecisionMotion(
        key: ValueKey(person.id),
        exit: _exit,
        direction: _exitDirection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // R04: no persistent "likes left" line. The allowance is still enforced by the
            // controller; once it is used, this explains it and links to the reset time (S17).
            if (likesLeft <= 0) ...[
              _QuotaLine(
                left: likesLeft,
                limit: economy.likesLimit(),
                onOut: () => context.push(Routes.allowance),
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
            if (controller.showingFallback(filters)) ...[
              StatusBanner(
                title: l10n.discoverFallbackTitle,
                body: l10n.discoverFallbackBody,
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
            // Bumble's discovery card (ER-01): the 3:4 photo (UI-011) with the identity group laid
            // over its foot (UI-014); the profile follows as cards when scrolled.
            if (v7 == 'C' && person.shared.isNotEmpty) ...[
              _CommonGround(name: person.name, shared: person.shared),
              const SizedBox(height: AppSpacing.s3),
            ],
            if (v7 == 'B') ...[
              _CalmIdentity(person: person),
              const SizedBox(height: AppSpacing.s4),
            ],
            EdgeBleed(
              inset: v7 == 'A' ? AppLayout.screenGutter : 0,
              child: KeyedSubtree(
                key: _heroKey,
                // Keyed by person: the measured hero keeps its state across people, the swipe card
                // (and its drag offset) must not.
                child: _SwipeCard(
                  key: ValueKey('swipe-${person.id}'),
                  person: person,
                  photoHeight: _photoHeight(context),
                  // R05: the overflow stays top-right; the Compliment squircle sits bottom-right,
                  // the same size and target as the overflow.
                  photoAction: SquircleIconButton(
                    icon: NumayaIcons.more,
                    label: l10n.discoverOptions,
                    onPressed: () => _options(person),
                  ),
                  complimentAction: ComplimentAnchor(
                    key: const ValueKey('compliment-photo-0'),
                    name: person.name,
                    onPressed: () =>
                        compliment(const ComplimentTarget.photo(0)),
                  ),
                  layout: switch (v7) {
                    'A' => 'F',
                    'B' => 'N',
                    _ => discoverPhotoV,
                  },
                  onOpenPhotos: () => openPhotos(1),
                  onMore: _toDetails,
                  onDecide: (liked) => unawaited(_decide(person, liked: liked)),
                ),
              ),
            ),
            // UI-016: no decision buttons; the photo is swiped.
            const SizedBox(height: AppLayout.itemGap),
            ...personSections(
              context,
              person,
              onPhoto: openPhotos,
              onCompliment: compliment,
              promptVariant: promptV,
            ),
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

/// The used-up like allowance under the header (R04: shown only once today's likes are used).
class _QuotaLine extends StatelessWidget {
  const _QuotaLine({
    required this.left,
    required this.limit,
    required this.onOut,
  });

  final int left;
  final int limit;
  final VoidCallback onOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: Row(
        key: const ValueKey('discover-quota'),
        children: [
          NumayaIcon(
            NumayaIcons.heart,
            size: 16,
            color: left > 0 ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              left > 0 ? l10n.quotaLeft(left, limit) : l10n.quotaOut,
              style: AppTypography.helper,
            ),
          ),
          if (left <= 0) TextLink(label: l10n.quotaOutAction, onPressed: onOut),
        ],
      ),
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

/// The first photo card, draggable: past 96pt right likes, left passes (the web's threshold). The
/// card follows the finger and tilts; the decision it is heading for shows on the photo. Letting go
/// short of the line, or flinging it back, springs it home. Taps on the photo and the name still
/// work: a tap never enters the horizontal-drag arena.
class _SwipeCard extends StatefulWidget {
  const _SwipeCard({
    super.key,
    required this.person,
    required this.onDecide,
    required this.onOpenPhotos,
    required this.onMore,
    this.photoHeight,
    this.photoAction,
    this.complimentAction,
    this.layout,
  });

  final SamplePerson person;
  final double? photoHeight;
  final Widget? photoAction;
  final Widget? complimentAction;
  final String? layout;
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

  /// The system took the pointer away mid-drag (a call, the notification shade). The drag
  /// recogniser still reports an end, with no velocity; that must never count as a decision.
  bool _pointerCancelled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // UI-016: with no buttons, the swipe has non-gesture equivalents: Like and Pass as screen
    // reader actions on the photo, and the right and left arrow keys once it has focus.
    return Semantics(
      label: l10n.discoverSwipeHint(widget.person.name),
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.discoverLike): () =>
            widget.onDecide(true),
        CustomSemanticsAction(label: l10n.discoverPass): () =>
            widget.onDecide(false),
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              widget.onDecide(true),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              widget.onDecide(false),
        },
        child: Focus(
          // A Listener sees the cancel before the gesture recognisers do.
          child: Listener(
            onPointerDown: (_) => _pointerCancelled = false,
            onPointerCancel: (_) => _pointerCancelled = true,
            child: _gestures(context),
          ),
        ),
      ),
    );
  }

  Widget _gestures(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        final wasPast = _dx.abs() >= _threshold;
        setState(() => _dx += d.delta.dx);
        // One tick each time the card crosses the line, so the stamp is felt as well as seen.
        if (wasPast != _dx.abs() >= _threshold) {
          AppHaptics.fire(context, HapticMoment.selection);
        }
      },
      onHorizontalDragEnd: (d) {
        if (_pointerCancelled) {
          setState(() => _dx = 0);
          return;
        }
        final v = d.velocity.pixelsPerSecond.dx;
        // Flung firmly back toward the centre: the member changed their mind, even past the
        // line.
        final pulledBack = v.abs() >= _flingVelocity && v.sign != _dx.sign;
        // Past the line, or flung firmly the way it already leans.
        final decided =
            !pulledBack &&
            (_dx.abs() >= _threshold ||
                (v.abs() >= _flingVelocity &&
                    _dx.abs() >= 24 &&
                    v.sign == _dx.sign));
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
          swipe: (_dx / _threshold).clamp(-1.0, 1.0),
          onOpenPhotos: widget.onOpenPhotos,
          onMore: widget.onMore,
          photoHeight: widget.photoHeight,
          photoAction: widget.photoAction,
          complimentAction: widget.complimentAction,
          layout: widget.layout,
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

/// Direction C: what you share leads the card.
class _CommonGround extends StatelessWidget {
  const _CommonGround({required this.name, required this.shared});

  final String name;
  final List<String> shared;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppLayout.cardPadding),
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: AppRadii.all(AppRadii.card),
    ),
    child: Text(
      context.l10n.v7CommonGround(name, shared.join(', ')),
      style: AppTypography.weight(
        AppTypography.body,
        AppTypography.semibold,
      ).copyWith(color: AppColors.accentForeground),
    ),
  );
}

/// Direction B: identity on the page, before the photo.
class _CalmIdentity extends StatelessWidget {
  const _CalmIdentity({required this.person});

  final SamplePerson person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NameWithBadge(
          name: l10n.profileNameAge(person.name, person.age),
          verified: person.verified,
          verifiedLabel: l10n.photoVerifiedLabel,
          style: AppTypography.pageTitle,
        ),
        if (person.job != null) ...[
          const SizedBox(height: AppSpacing.s1),
          Text(
            person.job!,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

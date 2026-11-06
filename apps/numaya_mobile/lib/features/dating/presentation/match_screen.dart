import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// New Match (B-40, review UI-028 to UI-031).
///
/// - **Header (UI-028):** the shared app bar with "It's a match!" and a Close control that returns
///   to browsing; the matched person's photo below it, in the profile photo's 3:4 portrait frame
///   (UI-011), with no decorative heart badge.
/// - **Shared interests (UI-029):** a separate "You both like" content card, only when there are
///   some.
/// - **Actions (UI-030):** no composer and no Send. Open chat opens the ordinary conversation with
///   this person (it replaces the match screen, so back from the chat returns to browsing; the
///   conversation is only created when a message is sent, so nothing is duplicated). View profile
///   opens their profile, and back returns here.
/// - **First release (UI-031):** no Opening Move anywhere on this screen.
///
/// The match stays in Messages whichever way the member leaves. No countdown (P-03 is open).
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen>
    with SingleTickerProviderStateMixin {
  /// The match celebration (MOTION_DESIGN_AUDIT "Match"): plays once, never loops, and any touch
  /// finishes it.
  late final AnimationController _celebrate = AnimationController(
    vsync: this,
    duration: AppMotion.celebrate,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // One success haptic on arrival; it stays even when motion is reduced.
    AppHaptics.fire(context, HapticMoment.success);
    if (AppMotion.reduced(context)) {
      _celebrate.value = 1;
    } else {
      unawaited(_celebrate.forward());
    }
  }

  @override
  void dispose() {
    _celebrate.dispose();
    super.dispose();
  }

  Widget _enter(Widget child, {required double from, double rise = 12}) =>
      _Enter(
        animation: CurvedAnimation(
          parent: _celebrate,
          curve: Interval(
            from,
            (from + 0.6).clamp(0, 1),
            curve: AppMotion.easeOut,
          ),
        ),
        rise: rise,
        child: child,
      );

  /// Back to browsing: the match waits in Messages.
  void _close() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final person = personById(widget.personId);
    if (person == null) return const SizedBox.shrink();
    final body = l10n.matchBody(person.name);
    final split = body.indexOf(person.name);
    // The 3:4 photo spans the content column, but never takes more than 42% of the screen height,
    // so the shared-interests card and the two actions stay in view (the body scrolls above them).
    final screen = MediaQuery.sizeOf(context);
    final column =
        math.min(screen.width, AppSpacing.contentMax) -
        2 * AppLayout.screenGutter;
    final photoWidth = math.min(
      column,
      screen.height * 0.42 * AppMedia.personPhoto,
    );

    // Any touch finishes the celebration; nothing waits for it.
    return Listener(
      onPointerDown: (_) {
        if (_celebrate.isAnimating) _celebrate.value = 1;
      },
      child: NumayaScreen(
        top: Semantics(
          liveRegion: true,
          child: NumayaTopBar(
            onBack: _close,
            backLabel: l10n.matchClose,
            closeIcon: true,
            title: l10n.matchTitle,
          ),
        ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumayaButton(
              key: const ValueKey('match-open-chat'),
              label: l10n.matchOpenChat,
              icon: NumayaIcons.message,
              onPressed: () =>
                  context.pushReplacement('${Routes.chat}/${person.id}'),
            ),
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              key: const ValueKey('match-view-profile'),
              label: l10n.matchViewProfile,
              variant: NumayaButtonVariant.secondary,
              onPressed: () => context.push('${Routes.person}/${person.id}'),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s2),
            _enter(
              Center(
                child: SizedBox(
                  width: photoWidth,
                  child: _MatchPhoto(person: person),
                ),
              ),
              from: 0.05,
              rise: 0,
            ),
            const SizedBox(height: AppSpacing.s4),
            _enter(
              Text.rich(
                TextSpan(
                  children: split < 0
                      ? [TextSpan(text: body)]
                      : [
                          TextSpan(text: body.substring(0, split)),
                          TextSpan(
                            text: person.name,
                            style: AppTypography.weight(
                              AppTypography.body,
                              AppTypography.semibold,
                            ).copyWith(color: AppColors.ink),
                          ),
                          TextSpan(
                            text: body.substring(split + person.name.length),
                          ),
                        ],
                ),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              from: 0.2,
            ),
            if (person.shared.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s4),
              _enter(
                ProfileSectionCard(
                  key: const ValueKey('match-shared-interests'),
                  title: l10n.discoverYouBothLike,
                  child: Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      for (final s in person.shared)
                        InfoChip(label: s, emoji: kInterestEmoji[s]),
                    ],
                  ),
                ),
                from: 0.3,
              ),
            ],
            const SizedBox(height: AppSpacing.s2),
          ],
        ),
      ),
    );
  }
}

/// The matched person: their first photo in the profile photo's 3:4 frame, or, with no photo,
/// their initial on the photo grey (more personal than a generic image glyph). No badge.
class _MatchPhoto extends StatelessWidget {
  const _MatchPhoto({required this.person});

  final SamplePerson person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final image = personPhotoImage(person, 1);
    return LayoutBuilder(
      builder: (context, box) => PhotoPlaceholder(
        key: const ValueKey('match-photo'),
        label: l10n.discoverPhotoLabel(person.name, 1),
        aspectRatio: AppMedia.personPhoto,
        radius: AppRadii.heroCard,
        child:
            image ??
            ColoredBox(
              color: AppColors.photo,
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    person.initial,
                    textScaler: TextScaler.noScaling,
                    style:
                        AppTypography.weight(
                          AppTypography.hero,
                          AppTypography.bold,
                        ).copyWith(
                          fontSize: box.maxWidth * 0.32,
                          height: 1,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

/// Fades [child] in, rising [rise] points, as [animation] runs 0 → 1.
class _Enter extends StatelessWidget {
  const _Enter({
    required this.animation,
    required this.rise,
    required this.child,
  });

  final Animation<double> animation;
  final double rise;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final v = animation.value;
      return Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, rise * (1 - v)),
          child: child,
        ),
      );
    },
    child: child,
  );
}

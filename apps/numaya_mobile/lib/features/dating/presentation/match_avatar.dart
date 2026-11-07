import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../lab/lab_registry.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// One new match in the Chats row (R02): the photo inside a progress ring showing the fraction of
/// the original or extended first-message window that is left. No number below; the exact time
/// and the extension are inside the chat. [semanticLabel] includes the time left. The ring is
/// static: it updates when the list rebuilds, never pulses.
///
/// Card family `match-avatar` (Visual Lab V2): O circle, A squircle, B circle + name, C compact,
/// D portrait with ring badge.
class MatchAvatarTile extends ConsumerWidget {
  const MatchAvatarTile({
    super.key,
    required this.person,
    required this.fraction,
    required this.semanticLabel,
    required this.onTap,
    this.variant,
  });

  final SamplePerson person;

  /// Time left as a fraction of the window, 0–1.
  final double fraction;
  final String semanticLabel;
  final VoidCallback onTap;

  /// Forces a variant (the Design Lab's side-by-side views); otherwise the registry decides.
  final String? variant;

  /// Under a sixth of the window left: the ring turns to the warning colour (still static).
  bool get _urgent => fraction < 1 / 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('match-avatar'));
    final image = personAvatarImage(person);
    final focus = personAvatarFocus(person);
    final ringColor = _urgent ? AppColors.negative : AppColors.accent;
    Widget tile;
    switch (v) {
      case 'A':
        tile = _SquircleRing(
          size: 88,
          fraction: fraction,
          color: ringColor,
          child: _photo(personPhotoImage(person, 1), person, focus),
        );
      case 'B':
        tile = SizedBox(
          width: 76,
          child: Column(
            children: [
              CountdownAvatar(
                initial: person.initial,
                fraction: fraction,
                urgent: _urgent,
                size: 76,
                image: image,
                imageAlignment: focus,
              ),
              const SizedBox(height: AppSpacing.s1),
              Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      case 'C':
        tile = CountdownAvatar(
          initial: person.initial,
          fraction: fraction,
          urgent: _urgent,
          size: 60,
          image: image,
          imageAlignment: focus,
        );
      case 'D':
        tile = SizedBox(
          width: 84,
          height: 112,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: AppRadii.all(AppRadii.card),
                  child: _photo(personPhotoImage(person, 1), person, focus),
                ),
              ),
              Positioned(
                right: AppSpacing.s1,
                bottom: AppSpacing.s1,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CustomPaint(
                    painter: _PiePainter(fraction: fraction, color: ringColor),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        tile = CountdownAvatar(
          initial: person.initial,
          fraction: fraction,
          urgent: _urgent,
          size: 76,
          image: image,
          imageAlignment: focus,
        );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.s3),
      child: Pressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        excludeChildSemantics: true,
        borderRadius: AppRadii.all(AppRadii.card),
        child: tile,
      ),
    );
  }

  static Widget _photo(Widget? image, SamplePerson p, Alignment focus) =>
      image ??
      ColoredBox(
        color: AppColors.photo,
        child: Center(
          child: Text(
            p.initial,
            style: AppTypography.headline.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
}

/// A rounded square photo with the progress drawn along its edge, starting top centre.
class _SquircleRing extends StatelessWidget {
  const _SquircleRing({
    required this.size,
    required this.fraction,
    required this.color,
    required this.child,
  });

  final double size;
  final double fraction;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      foregroundPainter: _RRectRingPainter(fraction: fraction, color: color),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: AppRadii.all(AppRadii.card - 4),
          child: SizedBox.expand(child: child),
        ),
      ),
    ),
  );
}

class _RRectRingPainter extends CustomPainter {
  _RRectRingPainter({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(stroke / 2),
      const Radius.circular(AppRadii.card),
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.fill;
    canvas.drawRRect(rrect, track);
    // Path starting at top centre, clockwise.
    final full = Path()..addRRect(rrect);
    final metric = full.computeMetrics().first;
    final len = metric.length;
    // addRRect starts at the top-left arc's end; shift so progress begins at top centre.
    final start = (rrect.width / 2 - rrect.tlRadiusX).clamp(0.0, len);
    final want = len * fraction.clamp(0.0, 1.0);
    final p = Path();
    final end = start + want;
    if (end <= len) {
      p.addPath(metric.extractPath(start, end), Offset.zero);
    } else {
      p
        ..addPath(metric.extractPath(start, len), Offset.zero)
        ..addPath(metric.extractPath(0, end - len), Offset.zero);
    }
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RRectRingPainter old) =>
      old.fraction != fraction || old.color != color;
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawOval(r, Paint()..color = AppColors.fill);
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0, 1),
      true,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.fraction != fraction || old.color != color;
}

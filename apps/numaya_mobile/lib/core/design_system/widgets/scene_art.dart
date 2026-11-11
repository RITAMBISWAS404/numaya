import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundations/app_motion.dart';
import '../tokens/monochrome_tokens.dart';

/// V8 illustration scenes: soft, lit, rounded objects drawn in code (no raster assets, no
/// generated art). Each scene belongs to one context and can follow real state through
/// [progress] (0..1) and [level], so a half-finished profile and a finished one look different.
enum ArtScene {
  /// Two speech bubbles: an empty inbox or a fresh conversation.
  conversation,

  /// A sealed note with a small clock: a Compliment waiting for a reply.
  waiting,

  /// A compass: discovery, nobody left to see.
  discover,

  /// A star medal with confetti: a finished step or milestone.
  celebrate,

  /// A faceted gem: Premium.
  premium,

  /// A flame that grows with [level] (streak days).
  flame,

  /// A heart: likes.
  heart,

  /// A profile card whose ring fills with [progress].
  profile,
}

/// Draws one [ArtScene]. Decorative: excluded from semantics unless [semanticLabel] is given.
class SceneArt extends StatelessWidget {
  const SceneArt(
    this.scene, {
    super.key,
    this.width = 160,
    this.progress = 1,
    this.level = 0,
    this.semanticLabel,
  });

  final ArtScene scene;
  final double width;
  final double progress;
  final int level;
  final String? semanticLabel;

  static const double _aspect = 1.25;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox(
      width: width,
      height: width / _aspect,
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress.clamp(0, 1)),
          duration: AppMotion.duration(
            context,
            const Duration(milliseconds: 600),
          ),
          curve: AppMotion.easeOut,
          builder: (_, p, _) =>
              CustomPaint(painter: _ScenePainter(scene, p, level)),
        ),
      ),
    );
    if (semanticLabel == null || semanticLabel!.isEmpty) {
      return ExcludeSemantics(child: art);
    }
    return Semantics(image: true, label: semanticLabel, child: art);
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.progress, this.level);

  final ArtScene scene;
  final double progress;
  final int level;

  static const _w = 200.0;
  static const _h = 160.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _w, size.height / _h);
    switch (scene) {
      case ArtScene.conversation:
        _conversation(canvas);
      case ArtScene.waiting:
        _waiting(canvas);
      case ArtScene.discover:
        _discover(canvas);
      case ArtScene.celebrate:
        _celebrate(canvas);
      case ArtScene.premium:
        _premium(canvas);
      case ArtScene.flame:
        _flame(canvas);
      case ArtScene.heart:
        _heart(canvas);
      case ArtScene.profile:
        _profile(canvas);
    }
    canvas.restore();
  }

  // Primitives -------------------------------------------------------------------------------

  /// A soft contact shadow under an object.
  void _shadow(Canvas c, Offset centre, double w, {double h = 10}) {
    c.drawOval(
      Rect.fromCenter(center: centre, width: w, height: h),
      Paint()
        ..color = MonoArt.shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  /// Fills [path] as a lit solid: light from the top left, a darker rim, a glossy highlight.
  void _solid(Canvas c, Path path, Color base, {bool gloss = true}) {
    final b = path.getBounds();
    final light = Color.lerp(base, MonoArt.white, 0.45)!;
    final dark = Color.lerp(base, MonoArt.ink, 0.28)!;
    c.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.55),
          radius: 1.15,
          colors: [light, base, dark],
          stops: const [0, 0.55, 1],
        ).createShader(b),
    );
    if (!gloss) return;
    c.save();
    c.clipPath(path);
    c.drawOval(
      Rect.fromLTWH(
        b.left + b.width * 0.14,
        b.top + b.height * 0.08,
        b.width * 0.42,
        b.height * 0.26,
      ),
      Paint()
        ..color = MonoArt.white.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    c.restore();
  }

  void _sphere(Canvas c, Offset o, double r, Color base) =>
      _solid(c, Path()..addOval(Rect.fromCircle(center: o, radius: r)), base);

  Path _bubble(Rect r, {required bool tailLeft}) {
    final p = Path()
      ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.height * 0.42)));
    final tx = tailLeft ? r.left + r.width * 0.22 : r.right - r.width * 0.22;
    final dir = tailLeft ? -1.0 : 1.0;
    p.addPath(
      Path()
        ..moveTo(tx - 9 * dir, r.bottom - 6)
        ..quadraticBezierTo(
          tx + 4 * dir,
          r.bottom + 14,
          tx + 14 * dir,
          r.bottom + 12,
        )
        ..quadraticBezierTo(
          tx + 6 * dir,
          r.bottom + 4,
          tx + 8 * dir,
          r.bottom - 6,
        )
        ..close(),
      Offset.zero,
    );
    return p;
  }

  Path _heartPath(Offset o, double s) {
    final p = Path();
    p.moveTo(o.dx, o.dy + s * 0.32);
    p.cubicTo(
      o.dx - s * 1.05,
      o.dy - s * 0.35,
      o.dx - s * 0.45,
      o.dy - s * 1.05,
      o.dx,
      o.dy - s * 0.48,
    );
    p.cubicTo(
      o.dx + s * 0.45,
      o.dy - s * 1.05,
      o.dx + s * 1.05,
      o.dy - s * 0.35,
      o.dx,
      o.dy + s * 0.32,
    );
    p.close();
    return p;
  }

  Path _star(Offset o, double r, double inner) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? r : inner;
      final pt = o + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  void _dots(Canvas c, Rect r, Color colour) {
    for (var i = -1; i <= 1; i++) {
      c.drawCircle(
        r.center + Offset(i * 12.0, 0),
        4.2,
        Paint()..color = colour,
      );
    }
  }

  // Scenes -----------------------------------------------------------------------------------

  void _conversation(Canvas c) {
    _shadow(c, const Offset(100, 146), 120);
    final back = const Rect.fromLTWH(78, 30, 96, 58);
    _solid(c, _bubble(back, tailLeft: false), MonoArt.lilac);
    _dots(c, back, MonoArt.white.withValues(alpha: 0.9));
    final front = const Rect.fromLTWH(26, 66, 104, 62);
    _solid(c, _bubble(front, tailLeft: true), MonoArt.brand);
    _solid(c, _heartPath(front.center + const Offset(0, 6), 17), MonoArt.coral);
    _sphere(c, const Offset(170, 112), 9, MonoArt.sun);
    _sphere(c, const Offset(30, 40), 6, MonoArt.mint);
  }

  void _waiting(Canvas c) {
    _shadow(c, const Offset(96, 146), 120);
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 46, 124, 84),
      const Radius.circular(18),
    );
    _solid(c, Path()..addRRect(card), MonoArt.cream);
    final flap = Path()
      ..moveTo(40, 54)
      ..quadraticBezierTo(96, 108, 152, 54)
      ..lineTo(152, 60)
      ..quadraticBezierTo(96, 116, 40, 60)
      ..close();
    c.drawPath(flap, Paint()..color = MonoArt.lilac.withValues(alpha: 0.7));
    _solid(c, _heartPath(const Offset(96, 92), 14), MonoArt.brand);
    // A clock on the corner: the reply is on its way.
    const clock = Offset(154, 44);
    _sphere(c, clock, 22, MonoArt.sun);
    final hand = Paint()
      ..color = MonoArt.ink.withValues(alpha: 0.75)
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    c.drawLine(clock, clock + const Offset(0, -11), hand);
    c.drawLine(clock, clock + const Offset(8, 4), hand);
  }

  void _discover(Canvas c) {
    _shadow(c, const Offset(100, 148), 130);
    const o = Offset(100, 82);
    _sphere(c, o, 58, MonoArt.sky);
    _solid(
      c,
      Path()..addOval(Rect.fromCircle(center: o, radius: 44)),
      MonoArt.white,
      gloss: false,
    );
    final needle = Path()
      ..moveTo(o.dx, o.dy - 36)
      ..lineTo(o.dx + 9, o.dy)
      ..lineTo(o.dx, o.dy + 36)
      ..lineTo(o.dx - 9, o.dy)
      ..close();
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(0.5);
    c.translate(-o.dx, -o.dy);
    c.save();
    c.clipRect(Rect.fromLTRB(0, 0, _w, o.dy));
    _solid(c, needle, MonoArt.coral);
    c.restore();
    c.save();
    c.clipRect(Rect.fromLTRB(0, o.dy, _w, _h));
    _solid(c, needle, MonoArt.brand);
    c.restore();
    c.restore();
    _sphere(c, o, 6, MonoArt.sun);
    _sphere(c, const Offset(172, 36), 8, MonoArt.mint);
    _sphere(c, const Offset(28, 118), 6, MonoArt.coral);
  }

  void _celebrate(Canvas c) {
    _shadow(c, const Offset(100, 150), 110);
    final ribbon = Paint()..color = MonoArt.brand;
    c.drawPath(
      Path()
        ..moveTo(82, 100)
        ..lineTo(70, 146)
        ..lineTo(86, 138)
        ..lineTo(96, 150)
        ..lineTo(100, 104)
        ..close(),
      ribbon,
    );
    c.drawPath(
      Path()
        ..moveTo(118, 100)
        ..lineTo(130, 146)
        ..lineTo(114, 138)
        ..lineTo(104, 150)
        ..lineTo(100, 104)
        ..close(),
      Paint()..color = MonoArt.lilac,
    );
    _sphere(c, const Offset(100, 74), 44, MonoArt.sun);
    _solid(c, _star(const Offset(100, 74), 26, 12), MonoArt.white);
    final confetti = [
      (const Offset(36, 40), MonoArt.coral),
      (const Offset(164, 34), MonoArt.mint),
      (const Offset(176, 96), MonoArt.brand),
      (const Offset(26, 104), MonoArt.sky),
    ];
    for (final (o, col) in confetti) {
      _sphere(c, o, 6 + progress * 2, col);
    }
  }

  void _premium(Canvas c) {
    _shadow(c, const Offset(100, 148), 120);
    final gem = Path()
      ..moveTo(58, 58)
      ..lineTo(80, 34)
      ..lineTo(120, 34)
      ..lineTo(142, 58)
      ..lineTo(100, 128)
      ..close();
    _solid(c, gem, MonoArt.brand);
    final facet = Paint()..color = MonoArt.white.withValues(alpha: 0.22);
    c.drawPath(
      Path()
        ..moveTo(58, 58)
        ..lineTo(142, 58)
        ..lineTo(100, 128)
        ..close(),
      Paint()..color = MonoArt.ink.withValues(alpha: 0.10),
    );
    c.drawPath(
      Path()
        ..moveTo(80, 34)
        ..lineTo(100, 58)
        ..lineTo(120, 34)
        ..close(),
      facet,
    );
    _sphere(c, const Offset(158, 40), 9, MonoArt.sun);
    _sphere(c, const Offset(42, 108), 7, MonoArt.lilac);
  }

  void _flame(Canvas c) {
    // Grows from a small flame (day one) to a full one (a week or more).
    final grow = 0.72 + 0.28 * (level.clamp(0, 7) / 7);
    _shadow(c, const Offset(100, 148), 90 * grow);
    c.save();
    c.translate(100, 146);
    c.scale(grow);
    c.translate(-100, -146);
    final outer = Path()
      ..moveTo(100, 140)
      ..cubicTo(52, 138, 48, 96, 70, 70)
      ..cubicTo(78, 92, 86, 94, 88, 90)
      ..cubicTo(80, 62, 96, 36, 112, 22)
      ..cubicTo(112, 52, 152, 74, 146, 110)
      ..cubicTo(142, 132, 124, 140, 100, 140)
      ..close();
    _solid(c, outer, MonoArt.coral);
    final inner = Path()
      ..moveTo(102, 136)
      ..cubicTo(80, 134, 78, 112, 92, 96)
      ..cubicTo(96, 108, 104, 106, 104, 100)
      ..cubicTo(102, 86, 110, 76, 118, 70)
      ..cubicTo(118, 92, 132, 102, 128, 118)
      ..cubicTo(126, 130, 116, 136, 102, 136)
      ..close();
    _solid(c, inner, MonoArt.sun);
    c.restore();
  }

  void _heart(Canvas c) {
    _shadow(c, const Offset(100, 148), 110);
    _solid(c, _heartPath(const Offset(100, 96), 62), MonoArt.brand);
    _sphere(c, const Offset(160, 38), 10, MonoArt.coral);
    _sphere(c, const Offset(40, 44), 7, MonoArt.sun);
  }

  void _profile(Canvas c) {
    _shadow(c, const Offset(100, 150), 120);
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(48, 26, 104, 116),
      const Radius.circular(20),
    );
    _solid(c, Path()..addRRect(card), MonoArt.cream, gloss: false);
    _sphere(c, const Offset(100, 66), 22, MonoArt.lilac);
    final line = Paint()
      ..color = MonoArt.ink.withValues(alpha: 0.12)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(76, 104), const Offset(124, 104), line);
    c.drawLine(const Offset(84, 120), const Offset(116, 120), line);
    // The ring fills with real profile completeness; a full ring earns the tick.
    const badge = Offset(146, 36);
    c.drawCircle(
      badge,
      20,
      Paint()
        ..color = MonoArt.ink.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    c.drawArc(
      Rect.fromCircle(center: badge, radius: 20),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = MonoArt.brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    if (progress >= 0.999) {
      _sphere(c, badge, 14, MonoArt.mint);
      final tick = Paint()
        ..color = MonoArt.white
        ..strokeWidth = 3.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      c.drawPath(
        Path()
          ..moveTo(badge.dx - 6, badge.dy)
          ..lineTo(badge.dx - 1, badge.dy + 5)
          ..lineTo(badge.dx + 7, badge.dy - 5),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.scene != scene || old.progress != progress || old.level != level;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A cute, code-drawn corgi that breathes, wags its tail, and blinks —
/// used as the pet's face on the home screen instead of a static emoji SVG.
///
/// Deliberately vector/shape-based rather than an image asset: no raster
/// art pipeline is available, so "alive" is achieved through motion instead
/// of illustration fidelity. See docs/ISSUES.md (デザイン・ペット) for the
/// longer-term plan to replace this with real illustration/animation.
class AnimatedCorgiFace extends StatefulWidget {
  const AnimatedCorgiFace({super.key, required this.size, this.sparkle = false});

  final double size;

  /// Adds a small sparkle accent for the highest pet growth stage.
  final bool sparkle;

  @override
  State<AnimatedCorgiFace> createState() => _AnimatedCorgiFaceState();
}

class _AnimatedCorgiFaceState extends State<AnimatedCorgiFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 6s cycle chosen so every sub-animation's period divides it evenly —
    // avoids a visible jump when the controller wraps back to 0.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 6.0; // elapsed seconds within cycle
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _CorgiPainter(t: t, sparkle: widget.sparkle),
        );
      },
    );
  }
}

class _CorgiPainter extends CustomPainter {
  _CorgiPainter({required this.t, required this.sparkle});

  final double t;
  final bool sparkle;

  static const _fur = Color(0xFFF6C878);
  static const _furShade = Color(0xFFE3A94F);
  static const _innerEar = Color(0xFFFFDFAE);
  static const _cream = Color(0xFFFFF8EC);
  static const _ink = Color(0xFF4A3826);
  static const _blush = Color(0xFFF3A6A0);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final breath = 1 + 0.025 * math.sin(2 * math.pi * t / 2.4);
    final tailAngle = 0.3 * math.sin(2 * math.pi * t / 0.5);
    final earFlop = 0.08 * math.sin(2 * math.pi * t / 2.4 + 1.0);
    final blinkPhase = t % 3.0;
    final blinking = blinkPhase > 2.85;
    final eyeScaleY = blinking ? 0.1 : 1.0;

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale(breath);

    _drawTail(canvas, w, h, tailAngle);
    _drawEars(canvas, w, h, earFlop);
    _drawHead(canvas, w, h);
    _drawFace(canvas, w, h, eyeScaleY);
    if (sparkle) _drawSparkle(canvas, w, h, t);

    canvas.restore();
  }

  /// A small peek of tail behind the head, low and to one side — the head
  /// fills almost the whole frame at this size, so the body itself is
  /// implied rather than drawn.
  void _drawTail(Canvas canvas, double w, double h, double angle) {
    canvas.save();
    canvas.translate(w * 0.3, h * 0.32);
    canvas.rotate(angle);
    final paint = Paint()..color = _furShade;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.14, height: h * 0.2),
      paint,
    );
    canvas.restore();
  }

  void _drawEars(Canvas canvas, double w, double h, double flop) {
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(side * w * 0.22, -h * 0.28);
      canvas.rotate(side * (0.22 + flop));

      final outer = Paint()..color = _furShade;
      final earPath = Path()
        ..moveTo(-w * 0.1, h * 0.08)
        ..quadraticBezierTo(-w * 0.14, -h * 0.14, 0, -h * 0.22)
        ..quadraticBezierTo(w * 0.12, -h * 0.12, w * 0.08, h * 0.08)
        ..close();
      canvas.drawPath(earPath, outer);

      final inner = Paint()..color = _innerEar;
      final innerPath = Path()
        ..moveTo(-w * 0.05, h * 0.04)
        ..quadraticBezierTo(-w * 0.07, -h * 0.08, 0, -h * 0.13)
        ..quadraticBezierTo(w * 0.06, -h * 0.07, w * 0.04, h * 0.04)
        ..close();
      canvas.drawPath(innerPath, inner);
      canvas.restore();
    }
  }

  void _drawHead(Canvas canvas, double w, double h) {
    final headCenter = Offset(0, 0.0);
    final headRadius = w * 0.4;

    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.1,
        colors: [_fur, _furShade],
      ).createShader(Rect.fromCircle(center: headCenter, radius: headRadius));
    canvas.drawCircle(headCenter, headRadius, headPaint);

    // Muzzle patch — kept low on the head so it doesn't crowd the eyes.
    final muzzlePaint = Paint()..color = _cream;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, h * 0.16),
        width: w * 0.4,
        height: h * 0.26,
      ),
      muzzlePaint,
    );
  }

  void _drawFace(Canvas canvas, double w, double h, double eyeScaleY) {
    // Blush.
    final blushPaint = Paint()..color = _blush.withValues(alpha: 0.55);
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(side * w * 0.26, h * 0.1),
          width: w * 0.1,
          height: h * 0.06,
        ),
        blushPaint,
      );
    }

    // Eyes: glossy dark ovals with a small highlight so they read as cute
    // rather than flat dots.
    final eyePaint = Paint()..color = _ink;
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (final side in [-1.0, 1.0]) {
      final center = Offset(side * w * 0.14, -h * 0.03);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(1, eyeScaleY);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.09, height: h * 0.11),
        eyePaint,
      );
      canvas.drawCircle(Offset(-w * 0.02, -h * 0.02), w * 0.018, highlightPaint);
      canvas.restore();
    }

    // Nose.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, h * 0.12),
        width: w * 0.075,
        height: h * 0.05,
      ),
      eyePaint,
    );

    // Smile.
    final smilePaint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(0, h * 0.145)
      ..quadraticBezierTo(-w * 0.07, h * 0.24, -w * 0.12, h * 0.18);
    final smilePath2 = Path()
      ..moveTo(0, h * 0.145)
      ..quadraticBezierTo(w * 0.07, h * 0.24, w * 0.12, h * 0.18);
    canvas.drawPath(smilePath, smilePaint);
    canvas.drawPath(smilePath2, smilePaint);
  }

  void _drawSparkle(Canvas canvas, double w, double h, double t) {
    final twinkle = 0.5 + 0.5 * math.sin(2 * math.pi * t / 1.2);
    final paint = Paint()..color = Colors.amber.withValues(alpha: twinkle);
    canvas.drawCircle(Offset(w * 0.36, -h * 0.38), w * 0.035, paint);
  }

  @override
  bool shouldRepaint(covariant _CorgiPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.sparkle != sparkle;
}

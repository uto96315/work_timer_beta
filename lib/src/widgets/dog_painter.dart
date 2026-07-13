import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a small cartoon shiba-ish dog entirely with shapes — no external
/// assets, so it doesn't depend on sourcing/licensing a third-party
/// animation file. [t] (0..1, looping) drives the running gait; when
/// [sleeping] is true a curled-up resting pose is drawn instead and [t]
/// only drives a slow breathing bounce.
class DogPainter extends CustomPainter {
  DogPainter({required this.t, required this.sleeping});

  final double t;
  final bool sleeping;

  static const _body = Color(0xFFE0A458);
  static const _bodyDark = Color(0xFFC07C33);
  static const _outline = Color(0xFF6B4423);
  static const _belly = Color(0xFFFFF3E0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    if (sleeping) {
      _paintSleeping(canvas, size);
    } else {
      _paintRunning(canvas, size);
    }
    canvas.restore();
  }

  void _paintRunning(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final phase = t * 2 * math.pi;
    final bounce = -s * 0.06 * math.sin(phase).abs();
    canvas.translate(0, bounce);

    final outline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    final bodyPaint = Paint()..color = _body;
    final darkPaint = Paint()..color = _bodyDark;

    // Legs: front/back pairs swing in opposite phase.
    void leg(double dx, double swingPhase) {
      final swing = math.sin(phase + swingPhase) * s * 0.14;
      final top = Offset(dx, s * 0.08);
      final bottom = Offset(dx + swing, s * 0.32);
      canvas.drawLine(top, bottom, outline..color = _bodyDark);
    }

    leg(-s * 0.22, 0);
    leg(s * 0.2, math.pi);
    outline.color = _outline;

    // Tail, wagging.
    final tailAngle = -0.5 + math.sin(phase * 2) * 0.35;
    canvas.save();
    canvas.translate(-s * 0.32, -s * 0.05);
    canvas.rotate(tailAngle);
    canvas.drawLine(Offset.zero, Offset(-s * 0.22, -s * 0.05), outline
      ..strokeWidth = s * 0.05);
    canvas.restore();

    // Body.
    final bodyRect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: s * 0.62,
      height: s * 0.32,
    );
    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(bodyRect, outline..strokeWidth = s * 0.035);

    // Head.
    const headCenter = Offset(0.24, -0.12);
    final headOffset = headCenter.scale(s, s);
    canvas.drawCircle(headOffset, s * 0.19, bodyPaint);
    canvas.drawCircle(headOffset, s * 0.19, outline);

    // Ear (floppy, flops with the bounce).
    canvas.save();
    canvas.translate(headOffset.dx + s * 0.06, headOffset.dy - s * 0.14);
    canvas.rotate(0.6 + math.sin(phase) * 0.2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: s * 0.1, height: s * 0.2),
      darkPaint,
    );
    canvas.restore();

    // Snout.
    final snout = Offset(headOffset.dx + s * 0.17, headOffset.dy + s * 0.04);
    canvas.drawOval(
      Rect.fromCenter(center: snout, width: s * 0.14, height: s * 0.1),
      Paint()..color = _belly,
    );
    canvas.drawCircle(
      Offset(snout.dx + s * 0.05, snout.dy),
      s * 0.025,
      Paint()..color = _outline,
    );

    // Eye.
    canvas.drawCircle(
      Offset(headOffset.dx + s * 0.05, headOffset.dy - s * 0.03),
      s * 0.03,
      Paint()..color = _outline,
    );
  }

  void _paintSleeping(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final breath = math.sin(t * 2 * math.pi) * s * 0.02;

    final outline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    final bodyPaint = Paint()..color = _body;

    // Curled-up body.
    final bodyRect = Rect.fromCenter(
      center: const Offset(0, 0.02),
      width: s * 0.6,
      height: s * (0.34 + breath / s),
    );
    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(bodyRect, outline);

    // Head resting on the body.
    final headOffset = Offset(-s * 0.18, -s * 0.1);
    canvas.drawCircle(headOffset, s * 0.16, bodyPaint);
    canvas.drawCircle(headOffset, s * 0.16, outline);

    // Closed eye.
    canvas.drawLine(
      Offset(headOffset.dx - s * 0.04, headOffset.dy),
      Offset(headOffset.dx + s * 0.04, headOffset.dy),
      outline..strokeWidth = s * 0.02,
    );

    // "Zzz".
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          color: _outline,
          fontSize: s * 0.22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(headOffset.dx + s * 0.1, headOffset.dy - s * 0.5 - breath),
    );
  }

  @override
  bool shouldRepaint(covariant DogPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.sleeping != sleeping;
}

/// Animated wrapper around [DogPainter] — bounces/runs in place while
/// [sleeping] is false, breathes slowly while true.
class AnimatedDog extends StatefulWidget {
  const AnimatedDog({super.key, this.size = 30, this.sleeping = false});

  final double size;
  final bool sleeping;

  @override
  State<AnimatedDog> createState() => _AnimatedDogState();
}

class _AnimatedDogState extends State<AnimatedDog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.sleeping
        ? const Duration(seconds: 3)
        : const Duration(milliseconds: 500),
  )..repeat();

  @override
  void didUpdateWidget(covariant AnimatedDog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sleeping != widget.sleeping) {
      _controller.duration =
          widget.sleeping ? const Duration(seconds: 3) : const Duration(milliseconds: 500);
    }
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
        return CustomPaint(
          size: Size.square(widget.size),
          painter: DogPainter(t: _controller.value, sleeping: widget.sleeping),
        );
      },
    );
  }
}

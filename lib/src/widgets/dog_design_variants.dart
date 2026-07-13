import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draft dog designs for the home track, leaning into a kawaii/Tamagotchi
/// look instead of the plainer shiba silhouette in [DogPainter]. Each is
/// self-contained (no external assets) so they can be flipped through and
/// picked from before committing one to the real UI.
abstract class DogVariantPainter extends CustomPainter {
  const DogVariantPainter(this.t);

  /// 0..1, looping.
  final double t;
}

Path _oval(Offset center, double rx, double ry) =>
    Path()..addOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2));

/// An oval rotated by [angleRad], built from raw points instead of a
/// transform matrix — always smoothly round regardless of rotation, unlike
/// a hand-tuned bezier shape which can come to a sharp point.
Path _rotatedOval(Offset center, double rx, double ry, double angleRad, {int segments = 24}) {
  final path = Path();
  final cosA = math.cos(angleRad), sinA = math.sin(angleRad);
  for (var i = 0; i <= segments; i++) {
    final theta = 2 * math.pi * i / segments;
    final x0 = rx * math.cos(theta);
    final y0 = ry * math.sin(theta);
    final x = x0 * cosA - y0 * sinA + center.dx;
    final y = x0 * sinA + y0 * cosA + center.dy;
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

/// Unions every part into one seamless silhouette — the fix for the
/// previous drafts, which stacked separately-outlined ovals and read as
/// disconnected floating parts instead of a single plush character.
Path _union(List<Path> parts) =>
    parts.reduce((a, b) => Path.combine(PathOperation.union, a, b));

/// Shared "goofy pup" build (the design settled on): a big head with an
/// elongated snout jutting to one side, a single ear, and a big open grin —
/// the asymmetry is what reads as "a little dopey" rather than a generic
/// round mascot. Head, snout, ear, body and legs are all unioned into one
/// silhouette so the outline is a single continuous line. Subclasses pick a
/// breed by varying ear shape, snout/body proportions, color and coat spots
/// — the skeleton itself doesn't change.
abstract class _GoofyDogPainter extends DogVariantPainter {
  const _GoofyDogPainter(super.t);

  Color get fillColor;
  Color get outlineColor;
  Color get tongueColor;

  /// Pointed and upright (shiba/corgi-type) instead of the default droopy
  /// floppy ear (retriever/dachshund/dalmatian-type).
  bool get erectEar => false;

  /// Scales the ear proportionally from its base/attach point — 1.0 is the
  /// original size; >1 for breeds with notably large ears (retriever,
  /// corgi, dachshund).
  double get earScale => 1.0;

  /// >1 lengthens the snout (dachshund), <1 shortens it.
  double get snoutScale => 1.0;

  /// >1 stretches the body horizontally (dachshund's long torso).
  double get bodyLengthScale => 1.0;

  /// <1 flattens the body vertically — paired with [bodyLengthScale] for
  /// breeds whose body reads as long-and-low rather than just wide
  /// (dachshund), instead of a stretched but still round torso.
  double get bodyHeightScale => 1.0;

  /// <1 shortens the legs, moving them up closer to the body — the defining
  /// trait of short-legged breeds (dachshund, corgi) rather than just a
  /// stretched or colored version of the same silhouette.
  double get legScale => 1.0;

  /// Extra coat markings (dalmatian spots, corgi's cream belly/muzzle
  /// patch) as (center in fractions of [s], radius in fractions of [s],
  /// color) — drawn on top of the base fill, clipped to the silhouette.
  List<(Offset, double, Color)> get markings => const [];

  /// Only worth it for coats with their own dark markings near the face
  /// (dalmatian) — everywhere else it reads as a big white "googly eye".
  bool get useEyeHalo => false;

  Path _floppyEar(double s) {
    // A single rounded oval, tilted to hang down-and-back — real floppy
    // ears (see reference) are wide ovals, not long thin shapes. [earScale]
    // grows the oval itself rather than stretching it further away, so it
    // stays round instead of turning into a thin worm.
    const center = Offset(-0.24, -0.28);
    final rx = s * 0.15 * earScale;
    final ry = s * 0.105 * earScale;
    return _rotatedOval(Offset(center.dx * s, center.dy * s), rx, ry, 0.55);
  }

  Path _erectEar(double s) {
    const attach = Offset(-0.2, -0.22);
    const relC1 = Offset(-0.08, -0.18);
    const relTip = Offset(0.06, -0.26);
    const relC2 = Offset(0.12, -0.12);
    const relEnd2 = Offset(0.18, -0.02);
    Offset abs(Offset rel) =>
        Offset((attach.dx + rel.dx * earScale) * s, (attach.dy + rel.dy * earScale) * s);
    final a = Offset(attach.dx * s, attach.dy * s);
    final c1 = abs(relC1), tip = abs(relTip), c2 = abs(relC2), end2 = abs(relEnd2);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(c1.dx, c1.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(c2.dx, c2.dy, end2.dx, end2.dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    final phase = t * 2 * math.pi;
    canvas.translate(0, -s * 0.05 * math.sin(phase).abs());

    final legSwing = math.sin(phase) * s * 0.04 * legScale;
    final bodyRx = s * 0.24 * bodyLengthScale;
    // Short-legged breeds sit lower/closer to the ground — legs shrink AND
    // move up toward the body instead of just scaling down in place, which
    // would otherwise leave a floating gap under the belly.
    final legY = s * 0.36 - s * 0.14 * (1 - legScale);
    final backLegY = s * 0.3 - s * 0.14 * (1 - legScale);

    final bodyRy = s * 0.22 * bodyHeightScale;
    final silhouette = _union([
      erectEar ? _erectEar(s) : _floppyEar(s),
      _oval(Offset(-s * 0.05, -s * 0.22), s * 0.26, s * 0.24), // head
      _oval(Offset(s * 0.26, -s * 0.06), s * 0.22 * snoutScale, s * 0.15), // snout
      _oval(Offset(0, s * 0.18), bodyRx, bodyRy), // body
      _oval(Offset(-s * 0.14 - (bodyRx - s * 0.24), backLegY), s * 0.05 * legScale, s * 0.045 * legScale), // back leg
      _oval(Offset(-s * 0.02 + legSwing, legY), s * 0.06 * legScale, s * 0.05 * legScale), // front leg
      _oval(Offset(s * 0.14 - legSwing, legY), s * 0.06 * legScale, s * 0.05 * legScale), // front leg
    ]);

    canvas.drawPath(silhouette, Paint()..color = fillColor);
    if (markings.isNotEmpty) {
      canvas.save();
      canvas.clipPath(silhouette);
      for (final (center, radius, color) in markings) {
        canvas.drawCircle(Offset(center.dx * s, center.dy * s), s * radius, Paint()..color = color);
      }
      canvas.restore();
    }
    canvas.drawPath(
      silhouette,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Face — small plain dot eyes at different heights along the
    // head-to-snout ridge (not mirrored) is what sells the tilted, slightly
    // dopey look, not eye size.
    final dark = Paint()..color = outlineColor;
    const eyeA = Offset(-0.08, -0.32);
    const eyeB = Offset(0.14, -0.22);
    if (useEyeHalo) {
      final halo = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(eyeA.dx * s, eyeA.dy * s), s * 0.042, halo);
      canvas.drawCircle(Offset(eyeB.dx * s, eyeB.dy * s), s * 0.042, halo);
    }
    canvas.drawCircle(Offset(eyeA.dx * s, eyeA.dy * s), s * 0.028, dark);
    canvas.drawCircle(Offset(eyeB.dx * s, eyeB.dy * s), s * 0.028, dark);
    canvas.drawCircle(Offset(s * 0.26 + s * 0.16 * snoutScale, -s * 0.06), s * 0.045, dark); // nose
    canvas.drawCircle(Offset(s * 0.05, s * 0.02), s * 0.035, Paint()..color = const Color(0x40FF8FA3)); // blush

    // Big open grin along the underside of the snout.
    final mouthStart = s * 0.1;
    final mouthEnd = s * 0.26 + s * 0.16 * snoutScale;
    final mouth = Path()
      ..moveTo(mouthStart, -s * 0.02)
      ..quadraticBezierTo((mouthStart + mouthEnd) / 2, s * 0.1, mouthEnd, -s * 0.02);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..strokeCap = StrokeCap.round,
    );
    final tongueDrop = (math.sin(phase) * 0.5 + 0.5) * s * 0.02;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset((mouthStart + mouthEnd) / 2, s * 0.1 + tongueDrop),
        width: s * 0.06,
        height: s * 0.09,
      ),
      Paint()..color = tongueColor,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoofyDogPainter oldDelegate) => oldDelegate.t != t;
}

/// 柴犬 — warm tan, erect pointed ears, medium snout. The design the
/// direction was settled on, now with breed-accurate upright ears instead
/// of the floppy placeholder ear used while the silhouette was being tuned.
class ShibaDogPainter extends _GoofyDogPainter {
  const ShibaDogPainter(super.t);

  @override
  Color get fillColor => const Color(0xFFFFC978);
  @override
  Color get outlineColor => const Color(0xFF3B2E22);
  @override
  Color get tongueColor => const Color(0xFFFF8FA3);
  @override
  bool get erectEar => true;
}

/// ゴールデンレトリバー — golden coat, big pendant ear, longer/broader snout.
class GoldenRetrieverDogPainter extends _GoofyDogPainter {
  const GoldenRetrieverDogPainter(super.t);

  @override
  Color get fillColor => const Color(0xFFFFE066);
  @override
  Color get outlineColor => const Color(0xFF8A6A1E);
  @override
  Color get tongueColor => const Color(0xFFFF8FA3);
  @override
  double get snoutScale => 1.15;
  @override
  double get earScale => 1.35;
}

/// ダックスフンド — the defining trait is short legs on a long, visibly
/// *low* body (not just wide), plus a very long floppy ear.
class DachshundDogPainter extends _GoofyDogPainter {
  const DachshundDogPainter(super.t);

  @override
  Color get fillColor => const Color(0xFFB5651D);
  @override
  Color get outlineColor => const Color(0xFF3B2412);
  @override
  Color get tongueColor => const Color(0xFFFF8FA3);
  @override
  double get snoutScale => 1.4;
  @override
  double get bodyLengthScale => 1.7;
  @override
  double get bodyHeightScale => 0.85;
  @override
  double get legScale => 0.45;
  @override
  double get earScale => 1.2;
}

/// ダルメシアン — white coat with black spots kept clear of the face (eyes
/// on this coat need a white halo — see [_GoofyDogPainter.paint] — and
/// spots too close to them read as extra eyes/confusion), floppy ear.
class DalmatianDogPainter extends _GoofyDogPainter {
  const DalmatianDogPainter(super.t);

  @override
  Color get fillColor => const Color(0xFFF7F5F0);
  @override
  Color get outlineColor => const Color(0xFF2B2B2B);
  @override
  Color get tongueColor => const Color(0xFFFF8FA3);
  @override
  bool get useEyeHalo => true;
  @override
  List<(Offset, double, Color)> get markings => const [
        (Offset(-0.24, -0.42), 0.03, Colors.black),
        (Offset(0.02, -0.44), 0.032, Colors.black),
        (Offset(-0.28, 0.02), 0.03, Colors.black),
        (Offset(-0.1, 0.14), 0.034, Colors.black),
        (Offset(0.14, 0.3), 0.03, Colors.black),
        (Offset(-0.2, 0.32), 0.028, Colors.black),
      ];
}

/// コーギー — big erect ears and famously short legs on a longish stocky
/// body; a shorter fox-like muzzle than the shiba's, plus the cream
/// muzzle/chest/belly patch real corgis have instead of one flat color.
class CorgiDogPainter extends _GoofyDogPainter {
  const CorgiDogPainter(super.t);

  @override
  Color get fillColor => const Color(0xFFE8935A);
  @override
  Color get outlineColor => const Color(0xFF5A3A22);
  @override
  Color get tongueColor => const Color(0xFFFF8FA3);
  @override
  List<(Offset, double, Color)> get markings => const [
        (Offset(0.34, 0.02), 0.13, Color(0xFFFFF6E8)), // muzzle
        (Offset(-0.02, 0.3), 0.16, Color(0xFFFFF6E8)), // chest/belly
      ];
  @override
  bool get erectEar => true;
  @override
  double get earScale => 1.25;
  @override
  double get snoutScale => 0.85;
  @override
  double get bodyLengthScale => 1.3;
  @override
  double get legScale => 0.45;
}

/// A direct reproduction of a pasted reference: a sitting golden retriever
/// in profile, chin raised, one rounded ear, a raised-nose snout continuous
/// with the head (no stepped jaw), a tall sitting-body silhouette, and two
/// separate front legs with a chest divider line — a calmer sitting pose
/// instead of the running "goofy pup" skeleton every other breed uses here.
class SittingGoldenRetrieverPainter extends DogVariantPainter {
  const SittingGoldenRetrieverPainter(super.t);

  static const _fill = Color(0xFFF3DFA3);
  static const _earFill = Color(0xFFDCB670);
  static const _outline = Color(0xFF4A3323);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    // A gentle idle breathing bob instead of the running bounce the other
    // breeds use — this pose is sitting still, not mid-stride.
    canvas.translate(0, -s * 0.015 * math.sin(t * 2 * math.pi));

    const headCenter = Offset(-0.16, -0.32);
    const headR = 0.16;
    const snoutCenter = Offset(-0.32, -0.24);
    const snoutRx = 0.15;
    const snoutRy = 0.095;
    const noseCenter = Offset(-0.45, -0.26);

    // A single oval body read as a plain balloon — a real sitting dog's
    // torso is narrower at the chest and fuller at the haunches. Building
    // it from two differently-sized circles (chest, rump) instead gives it
    // that asymmetric taper without hand-drawn bezier curves.
    final chest = _oval(Offset(-0.03 * s, -0.02 * s), s * 0.19, s * 0.19);
    final rump = _oval(Offset(0.12 * s, 0.22 * s), s * 0.27, s * 0.27);
    final body = Path.combine(PathOperation.union, chest, rump);
    final ear = _rotatedOval(Offset(-0.06 * s, -0.24 * s), s * 0.1, s * 0.155, 0.35);
    final tail = _oval(Offset(0.42 * s, 0.3 * s), s * 0.08, s * 0.065);
    final legL = _oval(Offset(-0.09 * s, 0.42 * s), s * 0.065, s * 0.14);
    final legR = _oval(Offset(0.07 * s, 0.42 * s), s * 0.065, s * 0.14);

    final silhouette = _union([
      ear,
      _oval(Offset(headCenter.dx * s, headCenter.dy * s), s * headR, s * headR),
      _oval(Offset(snoutCenter.dx * s, snoutCenter.dy * s), s * snoutRx, s * snoutRy),
      body,
      tail,
      legL,
      legR,
    ]);

    canvas.drawPath(silhouette, Paint()..color = _fill);
    // The ear reads as its own flap (rather than fused into the head) with
    // a slightly darker fill of its own, like the reference.
    canvas.save();
    canvas.clipPath(ear);
    canvas.drawPath(_oval(Offset(-0.06 * s, -0.24 * s), s * 0.14, s * 0.2), Paint()..color = _earFill);
    canvas.restore();

    canvas.drawPath(
      silhouette,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.018
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final line = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.016
      ..strokeCap = StrokeCap.round;

    // Chest divider between the two front legs, and a haunch fold on the
    // body — decorative interior lines, not silhouette edges, matching the
    // reference's linework.
    canvas.drawLine(Offset(-0.01 * s, 0.28 * s), Offset(-0.01 * s, 0.5 * s), line);
    final haunch = Path()
      ..moveTo(0.18 * s, 0.0)
      ..quadraticBezierTo(0.14 * s, 0.18 * s, 0.1 * s, 0.32 * s);
    canvas.drawPath(haunch, line);

    canvas.drawCircle(Offset(noseCenter.dx * s, noseCenter.dy * s), s * 0.035, Paint()..color = _outline);
    canvas.drawCircle(Offset(-0.24 * s, -0.36 * s), s * 0.02, Paint()..color = _outline); // eye

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SittingGoldenRetrieverPainter oldDelegate) => oldDelegate.t != t;
}


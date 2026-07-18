import 'package:flutter/material.dart';

/// Shared pixel-art design tokens and building blocks. Everything here draws
/// hard, un-antialiased edges (square corners, flat drop shadows offset by
/// whole pixels) instead of Material's rounded/blurred defaults, to match
/// the pixel-sprite pet introduced alongside this theme.
class PixelColors {
  PixelColors._();

  static const ink = Color(0xFF2E2A26);
  static const cream = Color(0xFFFBF3DE);
  static const panel = Color(0xFFFFFDF6);
  static const border = Color(0xFF2E2A26);
  static const mint = Color(0xFF5FBE99);
  static const mintDark = Color(0xFF2E8F6D);
  static const orange = Color(0xFFF2A559);
  static const orangeDark = Color(0xFFCC7A2E);
  static const rose = Color(0xFFEE7C74);
  static const roseDark = Color(0xFFC44A45);
  static const sand = Color(0xFFEDE0BE);
}

/// A flat-color panel with a hard pixel border and a solid offset "shadow"
/// block behind it — the classic pixel-UI stand-in for elevation, drawn with
/// two stacked rectangles instead of a blurred [BoxShadow].
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = PixelColors.panel,
    this.borderColor = PixelColors.border,
    this.shadowColor,
    this.borderWidth = 3,
    this.shadowOffset = 4,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.only(right: shadowOffset, bottom: shadowOffset),
      decoration: BoxDecoration(color: shadowColor ?? borderColor),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: child,
      ),
    );
  }
}

/// A square, hard-shadowed button — press feedback is the shadow block
/// disappearing and the face nudging down/right, instead of a ripple.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = PixelColors.mint,
    this.borderColor = PixelColors.border,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final shadowOffset = _pressed ? 0.0 : 4.0;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(
          left: 4 - shadowOffset,
          top: 4 - shadowOffset,
          right: shadowOffset,
          bottom: shadowOffset,
        ),
        padding: EdgeInsets.only(right: shadowOffset, bottom: shadowOffset),
        color: widget.borderColor.withValues(alpha: disabled ? 0.3 : 1),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: disabled
                ? widget.color.withValues(alpha: 0.45)
                : widget.color,
            border: Border.all(color: widget.borderColor, width: 3),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: widget.textColor,
              fontWeight: FontWeight.w700,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: widget.textColor, size: 18),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A blocky, stepped meter (a strip of solid pips) instead of a smooth
/// gradient bar — matches an 8-bit HP/EXP gauge.
class PixelMeter extends StatelessWidget {
  const PixelMeter({
    super.key,
    required this.value,
    this.color = PixelColors.mint,
    this.trackColor = PixelColors.sand,
    this.segments = 12,
    this.height = 12,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final int segments;
  final double height;

  @override
  Widget build(BuildContext context) {
    final filled = (value.clamp(0.0, 1.0) * segments).round();
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        border: Border.all(color: PixelColors.border, width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          for (var i = 0; i < segments; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: Container(color: i < filled ? color : Colors.transparent),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small square-bordered label chip (e.g. "休憩", "残業").
class PixelTag extends StatelessWidget {
  const PixelTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

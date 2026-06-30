import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Dönen gradient kenarlık animasyonu widget'ı.
/// QR kod, üyelik kartı gibi önemli alanları vurgulamak için kullanılır.
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? colors;
  final Duration duration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.borderWidth = 2,
    this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          AppColors.primary,
          AppColors.secondary,
          AppColors.accent,
          AppColors.primary,
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            progress: _controller.value,
            borderRadius: widget.borderRadius,
            borderWidth: widget.borderWidth,
            colors: colors,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Gradient kenarlık çizici.
class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;
  final List<Color> colors;

  _GradientBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: colors,
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

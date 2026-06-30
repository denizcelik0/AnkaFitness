import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Nabız (pulse) efektli glow animasyonu widget'ı.
/// QR kod aktif gösterimi ve durum ikonları için kullanılır.
class PulseGlowWidget extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double maxGlowRadius;
  final Duration duration;

  const PulseGlowWidget({
    super.key,
    required this.child,
    this.glowColor,
    this.maxGlowRadius = 20,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<PulseGlowWidget> createState() => _PulseGlowWidgetState();
}

class _PulseGlowWidgetState extends State<PulseGlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.glowColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25 * _animation.value),
                blurRadius: widget.maxGlowRadius * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Glassmorphism efektli kart widget'ı.
/// Bulanık arka plan, yarı saydam yüzey ve ince kenarlık.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blur;
  final Color? borderColor;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 12,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppConstants.borderRadiusLarge;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            gradient: AppColors.glassGradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ??
                  Colors.white.withValues(alpha: 0.08),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

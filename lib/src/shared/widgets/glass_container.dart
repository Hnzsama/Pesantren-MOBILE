import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color color;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 15.0, // Increased blur for smoother depth
    this.opacity = 0.85, // Increased opacity for "thick" glass
    this.color = Colors.white,
    this.borderColor,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow:
            shadows ??
            [
              // Stronger Depth Shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
              // Subtle Glow/Outline Shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: effectiveBorderRadius,
              // Stronger Border for "Light Source" effect
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(opacity),
                      color.withOpacity(opacity * 0.9),
                    ],
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

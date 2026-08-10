import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class GymSurface extends StatelessWidget {
  const GymSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 18,
    this.elevation = GymSurfaceElevation.soft,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final GymSurfaceElevation elevation;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: switch (elevation) {
          GymSurfaceElevation.none => const [],
          GymSurfaceElevation.soft => const [
            BoxShadow(
              color: Color(0x0A1A1B4B),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        },
      ),
      child: Padding(padding: padding, child: child),
    );
    if (width == null && height == null) return surface;
    return SizedBox(width: width, height: height, child: surface);
  }
}

enum GymSurfaceElevation { none, soft }

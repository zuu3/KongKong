import 'dart:ui';

import 'package:flutter/material.dart';

/// 재사용 가능한 리퀴드 글래스(유리) 컨테이너
/// - 배경 블러 + 반투명 그라데이션 + 얇은 외곽선
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? tint;
  final Gradient? gradient;

  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blur = 18,
    this.tint,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final baseTint = tint ?? Colors.white.withValues(alpha: 0.25);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    baseTint.withValues(alpha: 0.35),
                    baseTint.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(padding: padding, child: child),
        ),
      ),
    );
  }
}

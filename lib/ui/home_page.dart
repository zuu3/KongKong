import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'widgets/liquid_glass.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LiquidGlass(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) => Transform.scale(scale: value, child: child),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.gavel, size: 72, color: Color(0xFF0A84FF)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText('공매의 정석', speed: const Duration(milliseconds: 90)),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '공매를 쉽고 세련되게 경험하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/assets'),
                      icon: const Icon(Icons.play_circle_fill, size: 24),
                      label: const Text(
                        '시작하기',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0A84FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassButton(
                          icon: Icons.receipt_long,
                          label: '내 입찰 내역',
                          onTap: () => Navigator.of(context).pushNamed('/history'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassButton(
                          icon: Icons.bar_chart,
                          label: '나의 통계',
                          onTap: () => Navigator.of(context).pushNamed('/stats'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurBall extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBall({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

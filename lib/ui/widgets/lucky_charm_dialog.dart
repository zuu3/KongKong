import 'dart:math';
import 'package:flutter/material.dart';

class LuckyCharmDialog extends StatefulWidget {
  const LuckyCharmDialog({super.key});

  @override
  State<LuckyCharmDialog> createState() => _LuckyCharmDialogState();
}

class _LuckyCharmDialogState extends State<LuckyCharmDialog> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 메인 애니메이션 컨트롤러
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // 회전 애니메이션 컨트롤러
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    // 파티클 애니메이션 컨트롤러
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(_rotateController);

    _glowAnimation = Tween<double>(
      begin: 20.0,
      end: 40.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOut));

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _rotateController, _particleController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 배경 파티클 효과
              ..._buildParticles(),

              // 외곽 회전 링
              Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withOpacity(0.3), width: 3),
                  ),
                ),
              ),

              // 반대 방향 회전 링
              Transform.rotate(
                angle: -_rotateAnimation.value * 0.7,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.withOpacity(0.3), width: 3),
                  ),
                ),
              ),

              // 메인 카드
              Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF8BC34A),
                          Colors.amber.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: _glowAnimation.value * 1.5,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 클로버 아이콘 (펄스 효과)
                        Transform.scale(
                          scale: 1.0 + (sin(_mainController.value * 2 * pi) * 0.1),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Text('🍀', style: TextStyle(fontSize: 72)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 타이틀 (반짝임 효과)
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [Colors.white, Colors.yellow.shade200, Colors.white],
                              stops: [
                                (_particleController.value - 0.3).clamp(0.0, 1.0),
                                _particleController.value,
                                (_particleController.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            '✨ 행운의 참 발동! ✨',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 효과 설명
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '낙찰 확률 +10%',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final random = Random(42); // 고정된 시드로 일관된 위치

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final distance = 150 + (sin(_particleController.value * 2 * pi + i) * 30);
      final x = cos(angle) * distance;
      final y = sin(angle) * distance;
      final opacity = (sin(_particleController.value * 2 * pi + i) * 0.3 + 0.4).clamp(0.0, 1.0);

      particles.add(
        Positioned(
          left: MediaQuery.of(context).size.width / 2 + x,
          top: MediaQuery.of(context).size.height / 2 + y,
          child: Opacity(
            opacity: opacity,
            child: Text(['✨', '⭐', '🌟', '💫'][i % 4], style: const TextStyle(fontSize: 20)),
          ),
        ),
      );
    }

    return particles;
  }
}

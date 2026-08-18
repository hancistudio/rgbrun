import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';

/// The signature RGB → WHITE convergence explosion.
class WhiteExplosionEffect extends PositionComponent {
  final math.Random _rng = math.Random();
  double _timer = 0;
  bool _burst = false;

  static const double _convergeTime = 0.3;

  WhiteExplosionEffect({required Vector2 position})
      : super(position: position);

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= _convergeTime && !_burst) {
      _burst = true;
      _spawnBurst();
      Future.delayed(const Duration(milliseconds: 900), removeFromParent);
    }
  }

  void _spawnBurst() {
    final colors = [
      const Color(GameConfig.redColorHex),
      const Color(GameConfig.blueColorHex),
      const Color(GameConfig.greenColorHex),
      Colors.white,
      Colors.white,
    ];

    final particle = Particle.generate(
      count: GameConfig.whiteExplosionParticleCount,
      lifespan: 0.9,
      generator: (i) {
        final angle = (i / GameConfig.whiteExplosionParticleCount) * math.pi * 2;
        final speed = 80 + _rng.nextDouble() * 150;
        final c = colors[_rng.nextInt(colors.length)];
        return AcceleratedParticle(
          speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
          acceleration: Vector2.zero(),
          child: CircleParticle(
            radius: 2 + _rng.nextDouble() * 3,
            paint: Paint()..color = c,
          ),
        );
      },
    );
    parent?.add(ParticleSystemComponent(
      position: position.clone(),
      particle: particle,
    ));
  }

  @override
  void render(Canvas canvas) {
    if (_burst) return;
    // Converging RGB energy rings shrinking toward center
    double t = (_timer / _convergeTime).clamp(0, 1);
    final colors = [
      const Color(GameConfig.redColorHex),
      const Color(GameConfig.blueColorHex),
      const Color(GameConfig.greenColorHex),
    ];
    for (int i = 0; i < 3; i++) {
      double angle = (i / 3) * math.pi * 2 + _timer * 6;
      double dist = 60 * (1 - t);
      final pos = Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      final paint = Paint()
        ..color = colors[i].withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(pos, 8 * (1 - t * 0.5), paint);
    }

    // Central flash building up
    final flashPaint = Paint()
      ..color = Colors.white.withOpacity(t)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * t);
    canvas.drawCircle(Offset.zero, 30 * t, flashPaint);
  }
}

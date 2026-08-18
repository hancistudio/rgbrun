import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';

/// Green's HEART SHIELD ability visual.
class ShieldEffect extends PositionComponent {
  double _timer = 0;
  bool _broken = false;
  final math.Random _rng = math.Random();

  static const double _duration = 4.0;

  ShieldEffect({required Vector2 position})
      : super(position: position, size: Vector2.all(90));

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= _duration && !_broken) {
      _broken = true;
      _spawnBreakShockwave();
      Future.delayed(const Duration(milliseconds: 500), removeFromParent);
    }
  }

  void _spawnBreakShockwave() {
    final color = const Color(GameConfig.greenColorHex);
    final particle = Particle.generate(
      count: 30,
      lifespan: 0.6,
      generator: (i) {
        final angle = (i / 30) * math.pi * 2;
        return AcceleratedParticle(
          speed: Vector2(math.cos(angle), math.sin(angle)) * 100,
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = color,
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
    if (_broken) return;
    final color = const Color(GameConfig.greenColorHex);
    double pulse = math.sin(_timer * 4) * 0.1 + 0.9;

    // Heart-ish shield shape via two overlapping circles + glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset.zero, size.x / 2 * pulse, glowPaint);

    final ringPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, size.x / 2 * pulse, ringPaint);
  }
}

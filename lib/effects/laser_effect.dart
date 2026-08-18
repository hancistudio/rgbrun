import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';
import '../entities/obstacle.dart';

/// Reusable laser beam effect — charge → beam → impact.
class LaserEffect extends PositionComponent {
  final Color color;
  final Vector2 startPosition;
  final Vector2 direction;
  double _timer = 0;
  double _beamLength = 0;
  bool _impacted = false;

  static const double _chargeTime = 0.15;
  static const double _beamTime = 0.25;
  static const double _maxLength = 500;

  LaserEffect({
    required this.color,
    required this.startPosition,
    required this.direction,
  }) : super(position: startPosition.clone());

  @override
  void update(double dt) {
    _timer += dt;

    if (_timer < _chargeTime) {
      // Charging phase — handled in render via scale pulse
      return;
    }

    double beamT = ((_timer - _chargeTime) / _beamTime).clamp(0, 1);
    _beamLength = _maxLength * Curves.easeOut.transform(beamT);

    if (beamT >= 1.0 && !_impacted) {
      _impacted = true;
      _spawnImpactParticles();
      Future.delayed(const Duration(milliseconds: 300), removeFromParent);
    }
  }

  void _spawnImpactParticles() {
    final impactPos = startPosition + direction * _beamLength;
    final particle = Particle.generate(
      count: GameConfig.laserImpactParticleCount,
      lifespan: 0.4,
      generator: (i) {
        final angle = math.Random().nextDouble() * math.pi * 2;
        final speed = 30 + math.Random().nextDouble() * 60;
        return AcceleratedParticle(
          position: impactPos.clone(),
          speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = color,
          ),
        );
      },
    );
    parent?.add(ParticleSystemComponent(particle: particle));
  }

  @override
  void render(Canvas canvas) {
    if (_timer < _chargeTime) {
      // Charge glow
      double t = _timer / _chargeTime;
      final chargePaint = Paint()
        ..color = color.withOpacity(t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset.zero, 10 * t, chargePaint);
      return;
    }

    // Beam
    final beamPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final end = Offset(direction.x * _beamLength, direction.y * _beamLength);
    canvas.drawLine(Offset.zero, end, glowPaint);
    canvas.drawLine(Offset.zero, end, beamPaint);
  }
}

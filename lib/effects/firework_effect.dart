import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';

/// Reusable firework mini-show: rocket → suspense → burst → rain.
class FireworkEffect extends PositionComponent {
  final Color redColor;
  final Color blueColor;
  final Color greenColor;
  final math.Random _rng = math.Random();

  double _timer = 0;
  bool _exploded = false;
  Vector2 _rocketPos;

  static const double _riseTime = 0.7;
  static const double _pauseTime = 0.2;

  FireworkEffect({
    required Vector2 startPosition,
    required this.redColor,
    required this.blueColor,
    required this.greenColor,
  })  : _rocketPos = startPosition.clone(),
        super(position: startPosition.clone());

  @override
  void update(double dt) {
    _timer += dt;

    if (_timer < _riseTime) {
      double t = _timer / _riseTime;
      _rocketPos.y = position.y - 250 * Curves.easeOut.transform(t);
    } else if (_timer < _riseTime + _pauseTime) {
      // Suspense pause at apex
    } else if (!_exploded) {
      _exploded = true;
      _explode();
    } else if (_timer > _riseTime + _pauseTime + 2.5) {
      removeFromParent();
    }
  }

  void _explode() {
    final colors = [redColor, blueColor, greenColor, Colors.white];

    // Primary burst
    final particle = Particle.generate(
      count: GameConfig.fireworkParticleCount,
      lifespan: 1.8,
      generator: (i) {
        final angle = _rng.nextDouble() * math.pi * 2;
        final speed = 60 + _rng.nextDouble() * 120;
        final c = colors[_rng.nextInt(colors.length)];
        return AcceleratedParticle(
          position: _rocketPos.clone(),
          speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
          acceleration: Vector2(0, 140), // gravity fall
          child: CircleParticle(
            radius: 2 + _rng.nextDouble() * 2.5,
            paint: Paint()..color = c,
          ),
        );
      },
    );
    parent?.add(ParticleSystemComponent(particle: particle));

    // Secondary delayed bursts
    for (int burst = 1; burst <= 2; burst++) {
      Future.delayed(Duration(milliseconds: 150 * burst), () {
        if (parent == null) return;
        final secondary = Particle.generate(
          count: 30,
          lifespan: 1.2,
          generator: (i) {
            final angle = _rng.nextDouble() * math.pi * 2;
            final speed = 40 + _rng.nextDouble() * 60;
            final c = colors[_rng.nextInt(colors.length)];
            final offset = Vector2(
              (_rng.nextDouble() - 0.5) * 60,
              (_rng.nextDouble() - 0.5) * 60,
            );
            return AcceleratedParticle(
              position: _rocketPos + offset,
              speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
              acceleration: Vector2(0, 100),
              child: CircleParticle(
                radius: 1.5 + _rng.nextDouble() * 2,
                paint: Paint()..color = c,
              ),
            );
          },
        );
        parent?.add(ParticleSystemComponent(particle: secondary));
      });
    }
  }

  @override
  void render(Canvas canvas) {
    if (_exploded) return;
    // Rocket trail
    final trailPaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final localY = _rocketPos.y - position.y;
    canvas.drawCircle(Offset(0, localY), 4, trailPaint);
  }
}

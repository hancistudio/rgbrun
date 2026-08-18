import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';

/// Reusable pickup burst — orb collect feedback.
class RgbPickupEffect extends PositionComponent {
  final Color color;
  final math.Random _rng = math.Random();

  RgbPickupEffect({
    required Vector2 position,
    required this.color,
  }) : super(position: position, size: Vector2.zero());

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Score popup text
    final popup = TextComponent(
      text: '+10',
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    add(popup);
    popup.add(
      MoveByEffect(
        Vector2(0, -40),
        EffectController(duration: 0.6, curve: Curves.easeOut),
      ),
    );
    popup.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.6),
      ),
    );

    // Particle burst
    final particle = Particle.generate(
      count: GameConfig.orbPickupParticleCount,
      lifespan: 0.5,
      generator: (i) {
        final angle = (i / GameConfig.orbPickupParticleCount) * math.pi * 2;
        final speed = 40 + _rng.nextDouble() * 40;
        return AcceleratedParticle(
          speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
          acceleration: Vector2(0, 100),
          child: CircleParticle(
            radius: 2 + _rng.nextDouble() * 2,
            paint: Paint()..color = color,
          ),
        );
      },
    );

    add(ParticleSystemComponent(particle: particle));

    // Flash ring
    final ring = _RingComponent(color: color);
    add(ring);

    // Self destruct
    Future.delayed(const Duration(milliseconds: 650), removeFromParent);
  }
}

class _RingComponent extends PositionComponent {
  final Color color;
  double _radius = 4;
  double _opacity = 0.8;

  _RingComponent({required this.color});

  @override
  void update(double dt) {
    _radius += dt * 120;
    _opacity -= dt * 2.5;
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0) return;
    final paint = Paint()
      ..color = color.withOpacity(_opacity.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, _radius, paint);
  }
}

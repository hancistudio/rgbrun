import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';
import '../game/game_state.dart';
import '../characters/character.dart';
import '../effects/rgb_pickup_effect.dart';

class ColorOrb extends PositionComponent with CollisionCallbacks {
  final OrbColor orbColor;
  final GameState gameState;
  final VoidCallback? onCollected;

  double _bobTimer = 0;
  double _rotationAngle = 0;
  bool _collected = false;
  double _baseY = 0;

  ColorOrb({
    required this.orbColor,
    required this.gameState,
    required Vector2 position,
    this.onCollected,
  }) : super(
          position: position,
          size: Vector2.all(GameConfig.orbSize),
          anchor: Anchor.center,
        );

  Color get color => switch (orbColor) {
        OrbColor.red => const Color(GameConfig.redColorHex),
        OrbColor.blue => const Color(GameConfig.blueColorHex),
        OrbColor.green => const Color(GameConfig.greenColorHex),
      };

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _baseY = position.y;
    add(CircleHitbox(radius: GameConfig.orbSize * 0.4));
  }

  void collect() {
    if (_collected) return;
    _collected = true;

    // Energy & score
    double laserAmt = GameConfig.laserEnergyPerOrb;
    double fireworkAmt = GameConfig.fireworkEnergyPerOrb;

    gameState.addRgbEnergy(orbColor, 20);
    gameState.addLaserEnergy(laserAmt);
    gameState.addFireworkEnergy(fireworkAmt);
    gameState.incrementCombo();
    gameState.checkRgbChain(orbColor);
    gameState.addScore(GameConfig.scorePerOrb);

    switch (orbColor) {
      case OrbColor.red:
        gameState.orbsCollectedRed++;
        break;
      case OrbColor.blue:
        gameState.orbsCollectedBlue++;
        break;
      case OrbColor.green:
        gameState.orbsCollectedGreen++;
        break;
    }

    // Visual pickup effect
    parent?.add(RgbPickupEffect(
      position: position.clone(),
      color: color,
    ));

    onCollected?.call();
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collected) return;

    _bobTimer += dt;
    position.y = _baseY + math.sin(_bobTimer * 2.5) * 6;
    _rotationAngle += dt * 2;
  }

  @override
  void render(Canvas canvas) {
    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.7,
      glowPaint,
    );

    // Core orb — rotating diamond shape
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotationAngle);

    final corePaint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, -size.y / 2)
      ..lineTo(size.x / 2, 0)
      ..lineTo(0, size.y / 2)
      ..lineTo(-size.x / 2, 0)
      ..close();
    canvas.drawPath(path, corePaint);

    // Inner highlight
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset.zero, size.x * 0.15, highlightPaint);

    canvas.restore();
  }
}

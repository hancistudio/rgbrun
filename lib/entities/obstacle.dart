import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../characters/character.dart';

enum ObstacleType { wall, lowBar, spike }

class ObstacleEntity extends PositionComponent with CollisionCallbacks {
  final ObstacleType obstacleType;
  final int lane;
  bool _hit = false;

  ObstacleEntity({
    required this.obstacleType,
    required this.lane,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(
            GameConfig.obstacleWidth,
            GameConfig.obstacleHeight,
          ),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Hitbox is fair — smaller than visual, matches actual danger zone
    double hbW = size.x * 0.7;
    double hbH = switch (obstacleType) {
      ObstacleType.wall => size.y * 0.8,
      ObstacleType.lowBar => size.y * 0.35,
      ObstacleType.spike => size.y * 0.6,
    };

    add(RectangleHitbox(
      size: Vector2(hbW, hbH),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    ));
  }

  bool canBeJumpedOver() => obstacleType == ObstacleType.lowBar;
  bool canBeSlidUnder() => obstacleType == ObstacleType.wall;

  void onDestroyed() {
    _hit = true;
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF3A3A5A);
    final borderPaint = Paint()
      ..color = const Color(0xFF6A6A8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (obstacleType) {
      case ObstacleType.wall:
        final rect = Rect.fromLTWH(0, size.y * 0.2, size.x, size.y * 0.8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          borderPaint,
        );
        break;
      case ObstacleType.lowBar:
        final rect = Rect.fromLTWH(0, 0, size.x, size.y * 0.35);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          borderPaint,
        );
        break;
      case ObstacleType.spike:
        final path = Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x, size.y)
          ..lineTo(0, size.y)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;
    }
  }
}

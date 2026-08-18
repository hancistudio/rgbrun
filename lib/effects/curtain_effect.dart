import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Physical stage-curtain closing/opening — the game's "breath" moment.
class CurtainEffect extends PositionComponent {
  final VoidCallback onComplete;
  double _timer = 0;
  bool _opening = false;

  static const double _closeTime = 0.6;
  static const double _holdTime = 1.2;
  static const double _openTime = 0.6;

  CurtainEffect({required this.onComplete});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = 1000; // render on top
  }

  @override
  void update(double dt) {
    _timer += dt;
    if (!_opening && _timer >= _closeTime + _holdTime) {
      _opening = true;
    }
    if (_opening && _timer >= _closeTime + _holdTime + _openTime) {
      onComplete();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final screenSize = Vector2(400, 800); // logical fallback size
    double coverage;

    if (_timer < _closeTime) {
      coverage = (_timer / _closeTime).clamp(0, 1);
    } else if (_timer < _closeTime + _holdTime) {
      coverage = 1.0;
    } else {
      double openT =
          ((_timer - _closeTime - _holdTime) / _openTime).clamp(0, 1);
      coverage = 1.0 - openT;
    }

    final paint = Paint()..color = const Color(0xFF0A0A0A);
    final halfWidth = (screenSize.x / 2) * coverage;

    // Left curtain panel
    canvas.drawRect(
      Rect.fromLTWH(0, 0, halfWidth, screenSize.y),
      paint,
    );
    // Right curtain panel
    canvas.drawRect(
      Rect.fromLTWH(screenSize.x - halfWidth, 0, halfWidth, screenSize.y),
      paint,
    );

    // Curtain fold texture (subtle vertical lines)
    final foldPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 2;
    for (double x = 0; x < halfWidth; x += 15) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, screenSize.y),
        foldPaint,
      );
      canvas.drawLine(
        Offset(screenSize.x - x, 0),
        Offset(screenSize.x - x, screenSize.y),
        foldPaint,
      );
    }
  }
}

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';
import '../game/rgb_run_game.dart';

/// The cinematic opening: Darkness → Light → Prism → RGB Split → Formation.
class IntroSequence extends PositionComponent {
  final RgbRunGame game;
  final VoidCallback onComplete;

  double _timer = 0;
  final math.Random _rng = math.Random();

  IntroSequence({required this.game, required this.onComplete});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = 2000;
    size = game.size.clone();
  }

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= GameConfig.introDuration) {
      onComplete();
      removeFromParent();
    }
  }

  double get _shot1End => GameConfig.introShot1Duration;
  double get _shot2End => _shot1End + GameConfig.introShot2Duration;
  double get _shot3End => _shot2End + GameConfig.introShot3Duration;
  double get _shot4End => _shot3End + GameConfig.introShot4Duration;
  double get _shot5End => _shot4End + GameConfig.introShot5Duration;

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final center = Offset(w / 2, h / 2);

    // Base darkness
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Colors.black);

    if (_timer < _shot1End) {
      _renderShot1Darkness(canvas, center);
    } else if (_timer < _shot2End) {
      _renderShot2Light(canvas, center, w);
    } else if (_timer < _shot3End) {
      _renderShot3Prism(canvas, center);
    } else if (_timer < _shot4End) {
      _renderShot4RgbSplit(canvas, center, w);
    } else {
      _renderShot5Formation(canvas, center);
    }
  }

  // SHOT 01 — flickering light point in darkness
  void _renderShot1Darkness(Canvas canvas, Offset center) {
    double t = _timer / _shot1End;
    double flicker = 0.5 + 0.5 * math.sin(_timer * 15);
    double radius = 3 + t * 5;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6 + 0.4 * flicker)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, paint);
  }

  // SHOT 02 — light expands into horizontal beam
  void _renderShot2Light(Canvas canvas, Offset center, double w) {
    double t = (_timer - _shot1End) / GameConfig.introShot2Duration;
    double beamLength = w * Curves.easeOut.transform(t);

    final beamPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: beamLength,
        height: 4 + t * 2,
      ),
      beamPaint,
    );

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRect(
      Rect.fromCenter(center: center, width: beamLength, height: 20),
      glowPaint,
    );
  }

  // SHOT 03 — crystal prism forms, light enters
  void _renderShot3Prism(Canvas canvas, Offset center) {
    double t = (_timer - _shot2End) / GameConfig.introShot3Duration;

    // Incoming beam (from left)
    final beamPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(
      Rect.fromLTWH(0, center.dy - 2, center.dx, 4),
      beamPaint,
    );

    // Prism triangle
    double prismSize = 50 * Curves.easeOut.transform(t.clamp(0, 1));
    final prismPath = Path()
      ..moveTo(center.dx, center.dy - prismSize)
      ..lineTo(center.dx + prismSize * 0.87, center.dy + prismSize * 0.5)
      ..lineTo(center.dx - prismSize * 0.87, center.dy + prismSize * 0.5)
      ..close();

    final prismPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final prismBorder = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(prismPath, prismPaint);
    canvas.drawPath(prismPath, prismBorder);
  }

  // SHOT 04 — RGB split emerges from prism, three colored beams diverge
  void _renderShot4RgbSplit(Canvas canvas, Offset center, double w) {
    double t = (_timer - _shot3End) / GameConfig.introShot4Duration;
    double spread = 80 * Curves.easeOut.transform(t.clamp(0, 1));
    double length = (w / 2 - 40) * Curves.easeOut.transform(t.clamp(0, 1));

    final colors = [
      const Color(GameConfig.redColorHex),
      const Color(GameConfig.blueColorHex),
      const Color(GameConfig.greenColorHex),
    ];
    final angles = [-0.35, 0.0, 0.35]; // radians spread from horizontal

    // Prism still visible
    final prismPath = Path()
      ..moveTo(center.dx, center.dy - 50)
      ..lineTo(center.dx + 43, center.dy + 25)
      ..lineTo(center.dx - 43, center.dy + 25)
      ..close();
    canvas.drawPath(
      prismPath,
      Paint()..color = Colors.white.withOpacity(0.15),
    );

    for (int i = 0; i < 3; i++) {
      final angle = angles[i];
      final endX = center.dx + math.cos(angle) * length;
      final endY = center.dy + math.sin(angle) * length + spread * (i - 1) * 0.3;

      final paint = Paint()
        ..color = colors[i].withOpacity(0.9)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawLine(center, Offset(endX, endY), paint);

      // Particle sparkle at beam end
      final sparklePaint = Paint()
        ..color = colors[i]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(endX, endY), 6, sparklePaint);
    }
  }

  // SHOT 05 — three beams converge into character silhouettes
  void _renderShot5Formation(Canvas canvas, Offset center) {
    double t = ((_timer - _shot4End) / GameConfig.introShot5Duration)
        .clamp(0, 1);

    final colors = [
      const Color(GameConfig.redColorHex),
      const Color(GameConfig.blueColorHex),
      const Color(GameConfig.greenColorHex),
    ];
    final labels = ['RED', 'BLUE', 'GREEN'];

    double spacing = 100;
    for (int i = 0; i < 3; i++) {
      double x = center.dx + (i - 1) * spacing;
      double y = center.dy;

      // Energy coalescing into humanoid silhouette
      double formT = Curves.easeOut.transform(t);
      double h = 20 + formT * 60;
      double w = 10 + formT * 25;

      final bodyPaint = Paint()..color = colors[i].withOpacity(0.5 + 0.5 * formT);
      final glowPaint = Paint()
        ..color = colors[i].withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: w + 10, height: h + 10),
          const Radius.circular(10),
        ),
        glowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: w, height: h),
          const Radius.circular(8),
        ),
        bodyPaint,
      );

           if (t > 0.6) {
        double labelOpacity = ((t - 0.6) / 0.4).clamp(0, 1);
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              color: colors[i].withOpacity(labelOpacity),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y + h / 2 + 12),
        );
      }
    }

    // "CHOOSE YOUR LIGHT" title fades in near the end
    if (t > 0.75) {
      double titleOpacity = ((t - 0.75) / 0.25).clamp(0, 1);
      final titlePainter = TextPainter(
        text: TextSpan(
          text: 'CHOOSE YOUR LIGHT',
          style: TextStyle(
            color: Colors.white.withOpacity(titleOpacity),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      titlePainter.paint(
        canvas,
        Offset(center.dx - titlePainter.width / 2, center.dy - 140),
      );
    }
  }
}

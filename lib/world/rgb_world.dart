import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../game/game_config.dart';
import '../game/game_state.dart';
import '../entities/color_orb.dart';
import '../entities/obstacle.dart';
import '../effects/curtain_effect.dart';
import '../effects/shield_effect.dart';

class RgbWorld extends World {
  final GameState gameState;

  // ── Parallax layers ───────────────────────────────────────
  late final _ParallaxLayer _farBg;
  late final _ParallaxLayer _midBg;
  late final _ParallaxLayer _nearBg;
  late final _GroundLayer _ground;
  late final _ParticleLayer _particles;

  // ── World scroll ──────────────────────────────────────────
  double _scrollX = 0;
  bool _running = false;
  bool _curtainActive = false;
  bool _blueShiftActive = false;

  // ── World color (changes per biome) ──────────────────────
  Color _worldColor = const Color(0xFF050510);
  Color get worldColor => _worldColor;

  RgbWorld({required this.gameState});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _farBg = _ParallaxLayer(
      speed: 0.1,
      color: const Color(0xFF0A0A1A),
      layerType: _LayerType.farBackground,
    );
    _midBg = _ParallaxLayer(
      speed: 0.3,
      color: const Color(0xFF0D0D20),
      layerType: _LayerType.midBackground,
    );
    _nearBg = _ParallaxLayer(
      speed: 0.6,
      color: const Color(0xFF101025),
      layerType: _LayerType.nearBackground,
    );
    _ground = _GroundLayer();
    _particles = _ParticleLayer(gameState: gameState);

    await addAll([_farBg, _midBg, _nearBg, _ground, _particles]);
  }

  void startRun() {
    _running = true;
    _scrollX = 0;
  }

  void reset() {
    _running = false;
    _scrollX = 0;
    _curtainActive = false;
    // Remove all entities
    children.whereType<ColorOrb>().forEach((e) => e.removeFromParent());
    children.whereType<ObstacleEntity>().forEach((e) => e.removeFromParent());
  }

  void triggerCurtain() {
    _curtainActive = true;
    final effect = CurtainEffect(
      onComplete: () {
        _curtainActive = false;
      },
    );
    add(effect);
  }

  void exitCurtain() {
    _curtainActive = false;
  }

  void triggerStage() {
    // Stage sequence handled by game
  }

  void triggerBlueShift() {
    _blueShiftActive = true;
    Future.delayed(
      Duration(milliseconds: (GameConfig.abilityDuration * 1000).round()),
      () => _blueShiftActive = false,
    );
  }

  void triggerHeartShield(Vector2 position) {
    final shield = ShieldEffect(position: position.clone());
    add(shield);
  }

  void onWhiteModeStart() {
    _particles.intensify();
  }

  void onWhiteModeEnd() {
    _particles.normalize();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running) return;

    double speed = gameState.currentSpeed;
    if (_curtainActive) speed *= GameConfig.curtainSpeedMultiplier;
    if (gameState.whiteModeActive) speed *= GameConfig.whiteSpeedMultiplier;

    _scrollX += speed * dt;

    // Update parallax
    _farBg.scroll(_scrollX * 0.1);
    _midBg.scroll(_scrollX * 0.3);
    _nearBg.scroll(_scrollX * 0.6);
    _ground.scroll(_scrollX);
  }

  @override
  void render(Canvas canvas) {
    // Background fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 10000, 10000),
      Paint()..color = _worldColor,
    );
    super.render(canvas);
  }
}

// ── Parallax Layer ────────────────────────────────────────────
enum _LayerType { farBackground, midBackground, nearBackground }

class _ParallaxLayer extends Component {
  final double speed;
  final Color color;
  final _LayerType layerType;
  double _offset = 0;

  _ParallaxLayer({
    required this.speed,
    required this.color,
    required this.layerType,
  });

  void scroll(double x) {
    _offset = x;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    // Draw repeating geometric shapes for each layer
    double tileSize = switch (layerType) {
      _LayerType.farBackground => 200,
      _LayerType.midBackground => 150,
      _LayerType.nearBackground => 100,
    };

    double startX = -(_offset % tileSize);
    for (double x = startX; x < 500; x += tileSize) {
      double y = switch (layerType) {
        _LayerType.farBackground => 100,
        _LayerType.midBackground => 200,
        _LayerType.nearBackground => 300,
      };
      // Subtle geometric shapes
      canvas.drawRect(
        Rect.fromLTWH(x, y, tileSize * 0.8, 2),
        paint,
      );
    }
  }
}

// ── Ground Layer ──────────────────────────────────────────────
class _GroundLayer extends Component {
  double _offset = 0;

  void scroll(double x) {
    _offset = x;
  }

  @override
  void render(Canvas canvas) {
    // Lane lines
    final linePaint = Paint()
      ..color = const Color(0xFF1A1A3A)
      ..strokeWidth = 1;

    // Ground fill
    final groundPaint = Paint()..color = const Color(0xFF0C0C1E);

    // Will be positioned by camera
  }
}

// ── Particle Layer ────────────────────────────────────────────
class _ParticleLayer extends Component {
  final GameState gameState;
  final math.Random _rng = math.Random();
  final List<_FloatingParticle> _particles = [];
  bool _intense = false;

  _ParticleLayer({required this.gameState});

  @override
  Future<void> onLoad() async {
    // Spawn initial ambient particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_FloatingParticle(
        x: _rng.nextDouble() * 400,
        y: _rng.nextDouble() * 800,
        color: _randomRgbColor(),
        rng: _rng,
      ));
    }
  }

  Color _randomRgbColor() {
    final colors = [
      const Color(GameConfig.redColorHex),
      const Color(GameConfig.blueColorHex),
      const Color(GameConfig.greenColorHex),
    ];
    return colors[_rng.nextInt(3)].withOpacity(0.3 + _rng.nextDouble() * 0.4);
  }

  void intensify() => _intense = true;
  void normalize() => _intense = false;

  @override
  void update(double dt) {
    for (final p in _particles) {
      p.update(dt, _intense);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      p.render(canvas);
    }
  }
}

class _FloatingParticle {
  double x, y;
  Color color;
  final math.Random rng;
  double _vy = 0;
  double _vx = 0;
  double _size = 0;
  double _life = 0;
  double _maxLife = 0;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.rng,
  }) {
    _reset();
  }

  void _reset() {
    _vy = -(0.5 + rng.nextDouble() * 1.5);
    _vx = (rng.nextDouble() - 0.5) * 0.5;
    _size = 1 + rng.nextDouble() * 3;
    _maxLife = 3 + rng.nextDouble() * 5;
    _life = rng.nextDouble() * _maxLife;
  }

  void update(double dt, bool intense) {
    _life += dt;
    x += _vx * (intense ? 2 : 1);
    y += _vy * (intense ? 2 : 1);
    if (_life >= _maxLife || y < -50) {
      y = 900;
      x = rng.nextDouble() * 400;
      _reset();
    }
  }

   void render(Canvas canvas) {
    double alpha = math.sin(_life / _maxLife * math.pi) * 0.6;
    final paint = Paint()
      ..color = color.withOpacity(alpha.clamp(0, 1))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(x, y), _size, paint);
  }
}

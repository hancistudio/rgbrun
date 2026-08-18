import 'package:flame/components.dart';
import 'dart:math' as math;

import '../game/game_config.dart';
import '../game/game_state.dart';
import '../world/rgb_world.dart';
import '../entities/color_orb.dart';
import '../entities/obstacle.dart';
import '../characters/character.dart';

enum SegmentType {
  straight,
  orbLine,
  obstacle,
  colorGate,
  mixed,
}

class SpawnSystem {
  final RgbWorld world;
  final GameState state;
  final math.Random _rng = math.Random();

  double _distanceSinceLastSpawn = 0;
  double _nextSpawnDistance = 0;
  double _traveledDistance = 0;
  bool _active = false;

  static const double _screenWidth = 400;
  static const double _spawnY = 500; // ahead in world space

  SpawnSystem({required this.world, required this.state});

  void start() {
    _active = true;
    _distanceSinceLastSpawn = 0;
    _traveledDistance = 0;
    _nextSpawnDistance = GameConfig.minSegmentGap;
  }

  void stop() {
    _active = false;
  }

  void update(double dt) {
    if (!_active) return;

    double moveAmount = state.currentSpeed * dt;
    _traveledDistance += moveAmount;
    _distanceSinceLastSpawn += moveAmount;

    if (_distanceSinceLastSpawn >= _nextSpawnDistance) {
      _spawnSegment();
      _distanceSinceLastSpawn = 0;
      _nextSpawnDistance = GameConfig.minSegmentGap +
          _rng.nextDouble() * 150;
    }
  }

  void _spawnSegment() {
    final type = _weightedSegmentType();
    final worldY = world.children
            .whereType<PositionComponent>()
            .isEmpty
        ? 0.0
        : 0.0; // placeholder for world-space Y tracking

    switch (type) {
      case SegmentType.straight:
        _spawnOrbLine(count: 1);
        break;
      case SegmentType.orbLine:
        _spawnOrbLine(count: 3 + _rng.nextInt(3));
        break;
      case SegmentType.obstacle:
        _spawnObstacleWithSafeLane();
        break;
      case SegmentType.colorGate:
        _spawnOrbLine(count: 3, forceAllColors: true);
        break;
      case SegmentType.mixed:
        _spawnObstacleWithSafeLane();
        _spawnOrbLine(count: 2, offsetAhead: 150);
        break;
    }
  }

  SegmentType _weightedSegmentType() {
    // Weighted random — obstacles never impossible
    final weights = <SegmentType, double>{
      SegmentType.straight: 0.15,
      SegmentType.orbLine: 0.35,
      SegmentType.obstacle: 0.25,
      SegmentType.colorGate: 0.10,
      SegmentType.mixed: 0.15,
    };
    double total = weights.values.reduce((a, b) => a + b);
    double roll = _rng.nextDouble() * total;
    double cumulative = 0;
    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) return entry.key;
    }
    return SegmentType.straight;
  }

  void _spawnOrbLine({
    int count = 3,
    bool forceAllColors = false,
    double offsetAhead = 0,
  }) {
    final lane = _rng.nextInt(3);
    for (int i = 0; i < count; i++) {
      final orbColor = forceAllColors
          ? OrbColor.values[i % 3]
          : OrbColor.values[_rng.nextInt(3)];

      final pos = _worldPositionFor(
        lane: lane,
        aheadDistance: offsetAhead + i * GameConfig.orbLineSpacing,
      );

      world.add(ColorOrb(
        orbColor: orbColor,
        gameState: state,
        position: pos,
      ));
    }
  }

  void _spawnObstacleWithSafeLane() {
    final blockedLane = _rng.nextInt(3);
    final types = ObstacleType.values;
    final obstacleType = types[_rng.nextInt(types.length)];

    final pos = _worldPositionFor(lane: blockedLane, aheadDistance: 0);

    world.add(ObstacleEntity(
      obstacleType: obstacleType,
      lane: blockedLane,
      position: pos,
    ));

    // Always ensure at least one clear lane + reward orb there
    final safeLane = (blockedLane + 1 + _rng.nextInt(2)) % 3;
    world.add(ColorOrb(
      orbColor: OrbColor.values[_rng.nextInt(3)],
      gameState: state,
      position: _worldPositionFor(lane: safeLane, aheadDistance: 0),
    ));
  }

  Vector2 _worldPositionFor({required int lane, required double aheadDistance}) {
    final totalW = GameConfig.laneWidth * 3 + GameConfig.laneSpacing * 2;
    final startX = (_screenWidth - totalW) / 2 + GameConfig.laneWidth / 2;
    final x = startX + lane * (GameConfig.laneWidth + GameConfig.laneSpacing);
    final y = _traveledDistance + GameConfig.spawnDistance + aheadDistance;
    return Vector2(x, -y); // negative Y = ahead in scrolling world
  }
}

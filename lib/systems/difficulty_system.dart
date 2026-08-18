import '../game/game_config.dart';
import '../game/game_state.dart';

class DifficultySystem {
  final GameState state;
  double _elapsed = 0;

  DifficultySystem(this.state);

  void start() {
    _elapsed = 0;
    state.setSpeed(GameConfig.playerBaseSpeed);
  }

  void update(double dt) {
    _elapsed += dt;
    double newSpeed = GameConfig.playerBaseSpeed +
        _elapsed * GameConfig.speedIncreasePerSecond;
    state.setSpeed(newSpeed);
  }

  DifficultyTier get currentTier {
    if (_elapsed < GameConfig.easyDuration) return DifficultyTier.easy;
    if (_elapsed < GameConfig.mediumDuration) return DifficultyTier.medium;
    if (_elapsed < GameConfig.hardDuration) return DifficultyTier.hard;
    return DifficultyTier.intense;
  }
}

enum DifficultyTier { easy, medium, hard, intense }

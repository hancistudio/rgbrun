import '../game/game_config.dart';
import '../game/game_state.dart';

class ScoreSystem {
  final GameState state;

  ScoreSystem(this.state);

  void update(double dt) {
    state.addDistance(state.currentSpeed * dt / 100);
    state.addScore(GameConfig.scorePerMeter * dt);
  }
}

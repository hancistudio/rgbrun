import 'package:flutter/services.dart';
import '../game/game_state.dart';
import '../game/game_config.dart';

class HapticSystem {
  final GameState state;
  bool enabled = GameConfig.hapticsDefault;

  HapticSystem(this.state);

  void light() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  void medium() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  void strong() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  void strongPattern() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
  }
}

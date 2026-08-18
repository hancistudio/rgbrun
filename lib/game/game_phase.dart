/// All possible game phases — single source of truth.
enum GamePhase {
  boot,
  intro,
  characterSelect,
  home,
  ready,
  running,
  curtain,
  boss,
  whiteMode,
  stage,
  gameOver,
  reward,
  upgrade,
  paused,
}

extension GamePhaseX on GamePhase {
  bool get isPlaying =>
      this == GamePhase.running ||
      this == GamePhase.whiteMode ||
      this == GamePhase.curtain ||
      this == GamePhase.boss;

  bool get showsHud => isPlaying;

  bool get acceptsInput =>
      this == GamePhase.running ||
      this == GamePhase.whiteMode ||
      this == GamePhase.boss;
}

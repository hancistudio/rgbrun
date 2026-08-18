/// Central configuration — NO magic numbers anywhere else.
class GameConfig {
  GameConfig._();

  // ── Screen & Layout ──────────────────────────────────────
  static const double laneWidth = 120.0;
  static const double laneSpacing = 10.0;
  static const int laneCount = 3;
  static const double groundY = 0.75; // fraction of screen height
  static const double characterSize = 64.0;
  static const double orbSize = 32.0;
  static const double obstacleWidth = 80.0;
  static const double obstacleHeight = 80.0;

  // ── Speed ────────────────────────────────────────────────
  static const double playerBaseSpeed = 300.0;
  static const double speedIncreasePerSecond = 2.0;
  static const double maxSpeed = 900.0;
  static const double curtainSpeedMultiplier = 0.3;
  static const double whiteSpeedMultiplier = 1.8;

  // ── Lane Movement ────────────────────────────────────────
  static const double laneChangeDuration = 0.18; // seconds
  static const double jumpHeight = 160.0;
  static const double jumpDuration = 0.45;
  static const double slideDuration = 0.4;

  // ── Abilities ────────────────────────────────────────────
  static const double laserDuration = 0.8;
  static const double laserCooldown = 0.0; // energy-gated
  static const double fireworkChargeRequired = 100.0;
  static const double fireworkScoreBonus = 1000.0;
  static const double whiteModeDuration = 7.0;
  static const double whiteModeSlowDuration = 0.3;
  static const double abilityDuration = 4.0;
  static const double abilityCooldown = 8.0;

  // ── Energy ───────────────────────────────────────────────
  static const double laserEnergyPerOrb = 8.0;
  static const double fireworkEnergyPerOrb = 5.0;
  static const double whiteEnergyPerOrb = 6.0;
  static const double whiteEnergyBalanceBonus = 1.5; // multiplier
  static const double whiteEnergyMax = 100.0;
  static const double laserEnergyMax = 100.0;
  static const double fireworkEnergyMax = 100.0;

  // ── Combo ────────────────────────────────────────────────
  static const double comboTimeout = 3.0; // seconds without pickup
  static const List<int> comboThresholds = [1, 2, 5, 10, 20, 50];
  static const List<double> comboMultipliers = [1, 1.5, 2, 3, 5, 10];

  // ── Score ────────────────────────────────────────────────
  static const double scorePerOrb = 10.0;
  static const double scorePerMeter = 1.0;
  static const double scorePerObstacleDodge = 25.0;

  // ── Spawn ────────────────────────────────────────────────
  static const double spawnDistance = 800.0; // ahead of camera
  static const double despawnDistance = -200.0; // behind camera
  static const double minSegmentGap = 200.0;
  static const double orbLineSpacing = 60.0;

  // ── Difficulty ───────────────────────────────────────────
  static const double easyDuration = 60.0;
  static const double mediumDuration = 120.0;
  static const double hardDuration = 180.0;

  // ── Intro ────────────────────────────────────────────────
  static const double introDuration = 12.0;
  static const double introShot1Duration = 2.0;
  static const double introShot2Duration = 2.5;
  static const double introShot3Duration = 2.5;
  static const double introShot4Duration = 2.5;
  static const double introShot5Duration = 2.5;

  // ── Particles ────────────────────────────────────────────
  static const int maxParticles = 200;
  static const int orbPickupParticleCount = 12;
  static const int laserImpactParticleCount = 20;
  static const int fireworkParticleCount = 80;
  static const int whiteExplosionParticleCount = 120;

  // ── Colors ───────────────────────────────────────────────
  static const int redColorHex = 0xFFFF1E3C;
  static const int blueColorHex = 0xFF1677FF;
  static const int greenColorHex = 0xFF20D98A;
  static const int whiteColorHex = 0xFFFFFFFF;
  static const int blackColorHex = 0xFF0A0A0A;
  static const int bgColorHex = 0xFF050510;

  // ── White Mode Multipliers ───────────────────────────────
  static const List<double> whiteModeMultipliers = [2.0, 4.0, 8.0];
  static const double whiteModeMultiplierInterval = 2.0;

  // ── Haptics ──────────────────────────────────────────────
  static const bool hapticsDefault = true;

  // ── Debug ────────────────────────────────────────────────
  static const bool debugMode = false; // set true during dev
}

import 'package:flutter/foundation.dart';
import '../characters/character.dart';
import 'game_phase.dart';
import 'game_config.dart';

/// Central observable game state.
class GameState extends ChangeNotifier {
  // ── Phase ────────────────────────────────────────────────
  GamePhase _phase = GamePhase.boot;
  GamePhase get phase => _phase;

  void setPhase(GamePhase p) {
    if (_phase == p) return;
    _phase = p;
    notifyListeners();
  }

  // ── Character ────────────────────────────────────────────
  CharacterType _selectedCharacter = CharacterType.red;
  CharacterType get selectedCharacter => _selectedCharacter;

  void selectCharacter(CharacterType t) {
    _selectedCharacter = t;
    notifyListeners();
  }

  // ── Score & Distance ─────────────────────────────────────
  double _score = 0;
  double _distance = 0;
  double _bestScore = 0;
  double _bestDistance = 0;

  double get score => _score;
  double get distance => _distance;
  double get bestScore => _bestScore;
  double get bestDistance => _bestDistance;

  void addScore(double amount) {
    _score += amount * comboMultiplier * (_whiteModeActive ? _whiteModeMultiplier : 1.0);
    notifyListeners();
  }

  void addDistance(double d) {
    _distance += d;
    notifyListeners();
  }

  // ── RGB Energy ───────────────────────────────────────────
  double _redEnergy = 0;
  double _blueEnergy = 0;
  double _greenEnergy = 0;

  double get redEnergy => _redEnergy;
  double get blueEnergy => _blueEnergy;
  double get greenEnergy => _greenEnergy;

  void addRgbEnergy(OrbColor color, double amount) {
    switch (color) {
      case OrbColor.red:
        _redEnergy += amount;
        break;
      case OrbColor.blue:
        _blueEnergy += amount;
        break;
      case OrbColor.green:
        _greenEnergy += amount;
        break;
    }
    _updateWhiteEnergy(color);
    notifyListeners();
  }

  // ── White Energy ─────────────────────────────────────────
  double _whiteEnergy = 0;
  double get whiteEnergy => _whiteEnergy;
  bool get whiteReady => _whiteEnergy >= GameConfig.whiteEnergyMax;

  void _updateWhiteEnergy(OrbColor lastColor) {
    double base = GameConfig.whiteEnergyPerOrb;
    // Balance bonus: if all three energies are within 20% of each other
    double maxE = [_redEnergy, _blueEnergy, _greenEnergy]
        .reduce((a, b) => a > b ? a : b);
    double minE = [_redEnergy, _blueEnergy, _greenEnergy]
        .reduce((a, b) => a < b ? a : b);
    bool balanced = maxE > 0 && (maxE - minE) / maxE < 0.2;
    double bonus = balanced ? GameConfig.whiteEnergyBalanceBonus : 1.0;
    _whiteEnergy = (_whiteEnergy + base * bonus)
        .clamp(0, GameConfig.whiteEnergyMax);
  }

  void consumeWhiteEnergy() {
    _whiteEnergy = 0;
    notifyListeners();
  }

  // ── Laser Energy ─────────────────────────────────────────
  double _laserEnergy = 0;
  double get laserEnergy => _laserEnergy;
  bool get laserReady => _laserEnergy >= GameConfig.laserEnergyMax;

  void addLaserEnergy(double amount) {
    _laserEnergy = (_laserEnergy + amount).clamp(0, GameConfig.laserEnergyMax);
    notifyListeners();
  }

  void consumeLaserEnergy() {
    _laserEnergy = 0;
    notifyListeners();
  }

  // ── Firework Energy ──────────────────────────────────────
  double _fireworkEnergy = 0;
  double get fireworkEnergy => _fireworkEnergy;
  bool get fireworkReady =>
      _fireworkEnergy >= GameConfig.fireworkChargeRequired;

  void addFireworkEnergy(double amount) {
    _fireworkEnergy =
        (_fireworkEnergy + amount).clamp(0, GameConfig.fireworkEnergyMax);
    notifyListeners();
  }

  void consumeFireworkEnergy() {
    _fireworkEnergy = 0;
    notifyListeners();
  }

  // ── Combo ────────────────────────────────────────────────
  int _combo = 0;
  double _comboTimer = 0;
  int get combo => _combo;

  double get comboMultiplier {
    for (int i = GameConfig.comboThresholds.length - 1; i >= 0; i--) {
      if (_combo >= GameConfig.comboThresholds[i]) {
        return GameConfig.comboMultipliers[i];
      }
    }
    return 1.0;
  }

  void incrementCombo() {
    _combo++;
    _comboTimer = GameConfig.comboTimeout;
    notifyListeners();
  }

  void resetCombo() {
    _combo = 0;
    notifyListeners();
  }

  void tickCombo(double dt) {
    if (_combo > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        resetCombo();
      }
    }
  }

  // ── White Mode ───────────────────────────────────────────
  bool _whiteModeActive = false;
  double _whiteModeTimer = 0;
  double _whiteModeMultiplier = 2.0;
  int _whiteModeMultiplierIndex = 0;

  bool get whiteModeActive => _whiteModeActive;
  double get whiteModeMultiplier => _whiteModeMultiplier;
  double get whiteModeTimer => _whiteModeTimer;

  void activateWhiteMode() {
    _whiteModeActive = true;
    _whiteModeTimer = GameConfig.whiteModeDuration;
    _whiteModeMultiplierIndex = 0;
    _whiteModeMultiplier = GameConfig.whiteModeMultipliers[0];
    consumeWhiteEnergy();
    notifyListeners();
  }

  void tickWhiteMode(double dt) {
    if (!_whiteModeActive) return;
    _whiteModeTimer -= dt;

    // Escalate multiplier
    double elapsed = GameConfig.whiteModeDuration - _whiteModeTimer;
    int newIndex = (elapsed / GameConfig.whiteModeMultiplierInterval)
        .floor()
        .clamp(0, GameConfig.whiteModeMultipliers.length - 1);
    if (newIndex != _whiteModeMultiplierIndex) {
      _whiteModeMultiplierIndex = newIndex;
      _whiteModeMultiplier = GameConfig.whiteModeMultipliers[newIndex];
      notifyListeners();
    }

    if (_whiteModeTimer <= 0) {
      _whiteModeActive = false;
      notifyListeners();
    }
  }

  // ── Run Stats (for result screen) ────────────────────────
  int orbsCollectedRed = 0;
  int orbsCollectedBlue = 0;
  int orbsCollectedGreen = 0;
  int lasersUsed = 0;
  int fireworksUsed = 0;
  int whiteModesUsed = 0;
  int maxCombo = 0;
  int xpEarned = 0;
  int coinsEarned = 0;

  // ── Speed ────────────────────────────────────────────────
  double _currentSpeed = GameConfig.playerBaseSpeed;
  double get currentSpeed => _currentSpeed;

  void setSpeed(double s) {
    _currentSpeed = s.clamp(0, GameConfig.maxSpeed);
  }

  // ── Ability ──────────────────────────────────────────────
  bool _abilityActive = false;
  double _abilityCooldownTimer = 0;
  bool get abilityActive => _abilityActive;
  bool get abilityReady => _abilityCooldownTimer <= 0;

  void activateAbility() {
    _abilityActive = true;
    _abilityCooldownTimer = GameConfig.abilityCooldown;
    notifyListeners();
  }

  void deactivateAbility() {
    _abilityActive = false;
    notifyListeners();
  }

  void tickAbility(double dt) {
    if (_abilityCooldownTimer > 0) {
      _abilityCooldownTimer -= dt;
      if (_abilityCooldownTimer < 0) _abilityCooldownTimer = 0;
      notifyListeners();
    }
  }

  double get abilityCooldownFraction =>
      1.0 - (_abilityCooldownTimer / GameConfig.abilityCooldown).clamp(0, 1);

  // ── Shield (Green's HEART GUARD ability) ──────────────────
  /// True while Green's protective shield is active. While true,
  /// the next hit is absorbed instead of causing damage — see
  /// [takeDamage].
  bool shieldActive = false;

  // ── Health ───────────────────────────────────────────────
  int _health = 3;
  int get health => _health;
  bool get isAlive => _health > 0;

  void takeDamage() {
    if (_whiteModeActive) return; // invincible during White Mode
    if (shieldActive) {
      // Shield absorbs exactly one hit, then breaks.
      shieldActive = false;
      notifyListeners();
      return;
    }
    _health--;
    notifyListeners();
  }

  void heal(int amount) {
    _health = (_health + amount).clamp(0, 3);
    notifyListeners();
  }

  // ── RGB Chain ────────────────────────────────────────────
  int _rgbChainStep = 0; // 0=none, 1=R, 2=R+B, 3=R+B+G
  int _rgbChainCount = 0;
  int get rgbChainCount => _rgbChainCount;

  void checkRgbChain(OrbColor color) {
    const sequence = [OrbColor.red, OrbColor.blue, OrbColor.green];
    if (color == sequence[_rgbChainStep]) {
      _rgbChainStep++;
      if (_rgbChainStep >= 3) {
        _rgbChainStep = 0;
        _rgbChainCount++;
        // Bonus white energy
        _whiteEnergy = (_whiteEnergy + 15).clamp(0, GameConfig.whiteEnergyMax);
        notifyListeners();
      }
    } else {
      _rgbChainStep = color == OrbColor.red ? 1 : 0;
    }
  }

  // ── Reset for new run ────────────────────────────────────
  void resetForNewRun() {
    _score = 0;
    _distance = 0;
    _redEnergy = 0;
    _blueEnergy = 0;
    _greenEnergy = 0;
    _whiteEnergy = 0;
    _laserEnergy = 0;
    _fireworkEnergy = 0;
    _combo = 0;
    _comboTimer = 0;
    _whiteModeActive = false;
    _whiteModeTimer = 0;
    _whiteModeMultiplierIndex = 0;
    _whiteModeMultiplier = 2.0;
    _health = 3;
    _abilityActive = false;
    _abilityCooldownTimer = 0;
    shieldActive = false;
    _rgbChainStep = 0;
    _rgbChainCount = 0;
    _currentSpeed = GameConfig.playerBaseSpeed;
    orbsCollectedRed = 0;
    orbsCollectedBlue = 0;
    orbsCollectedGreen = 0;
    lasersUsed = 0;
    fireworksUsed = 0;
    whiteModesUsed = 0;
    maxCombo = 0;
    xpEarned = 0;
    coinsEarned = 0;
    notifyListeners();
  }

  void endRun() {
    if (_score > _bestScore) _bestScore = _score;
    if (_distance > _bestDistance) _bestDistance = _distance;
    xpEarned = (_distance / 10).round() + (_score / 100).round();
    coinsEarned = (_score / 50).round();
    notifyListeners();
  }
}

enum OrbColor { red, blue, green }

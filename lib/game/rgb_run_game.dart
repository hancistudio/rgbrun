import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'game_config.dart';
import 'game_phase.dart';
import 'game_state.dart';
import '../world/rgb_world.dart';
import '../characters/character.dart';
import '../characters/red_character.dart';
import '../characters/blue_character.dart';
import '../characters/green_character.dart';
import '../systems/spawn_system.dart';
import '../systems/score_system.dart';
import '../systems/difficulty_system.dart';
import '../systems/haptic_system.dart';
import '../ui/hud.dart';
import '../ui/character_select.dart';
import '../ui/result_screen.dart';
import '../ui/reward_screen.dart';
import '../intro/intro_sequence.dart';

class RgbRunGame extends FlameGame
    with PanDetector, TapDetector, HasCollisionDetection {
  // ── State ─────────────────────────────────────────────────
  final GameState state = GameState();

  double _elapsedTime = 0;
  double currentTime() => _elapsedTime;

  /// Custom time scale for slow-motion effects (White Mode intro,
  /// Red's LOGIC BREAK, death sequence). 1.0 = normal, <1.0 = slow-mo.
  /// Applied manually in update() since Flame's FlameGame has no
  /// built-in `timescale` property.
  double timescale = 1.0;

  // ── Systems ───────────────────────────────────────────────
  late final ScoreSystem scoreSystem;
  late final DifficultySystem difficultySystem;
  late final SpawnSystem spawnSystem;
  late final HapticSystem hapticSystem;

  // ── World & Camera ────────────────────────────────────────
  late final RgbWorld rgbWorld;
  late final CameraComponent cam;

  // ── Active Character ──────────────────────────────────────
  PlayerCharacter? activeCharacter;

  // ── Intro ─────────────────────────────────────────────────
  IntroSequence? introSequence;

  // ── Swipe tracking ────────────────────────────────────────
  Vector2? _panStart;
  Vector2? _panCurrent;
  static const double _swipeThreshold = 30.0;

  // ── Overlay widgets (passed to GameWidget) ────────────────
  late Widget hudWidget;
  late Widget characterSelectWidget;
  late Widget resultScreenWidget;
  late Widget rewardScreenWidget;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Systems
    hapticSystem = HapticSystem(state);
    scoreSystem = ScoreSystem(state);
    difficultySystem = DifficultySystem(state);

    // World
    rgbWorld = RgbWorld(gameState: state);
    spawnSystem = SpawnSystem(world: rgbWorld, state: state);

    // Camera
    cam = CameraComponent(world: rgbWorld);
    cam.viewfinder.anchor = Anchor.topLeft;
    await addAll([rgbWorld, cam]);

    // Build overlay widgets
    hudWidget = HudWidget(game: this);
    characterSelectWidget = CharacterSelectWidget(game: this);
    resultScreenWidget = ResultScreenWidget(game: this);
    rewardScreenWidget = RewardScreenWidget(game: this);

    // Start boot → intro
    _startBoot();
  }

  void _startBoot() {
    state.setPhase(GamePhase.boot);
    // Short boot delay then intro
    Future.delayed(const Duration(milliseconds: 300), _startIntro);
  }

  void _startIntro() {
    state.setPhase(GamePhase.intro);
    introSequence = IntroSequence(
      game: this,
      onComplete: _showCharacterSelect,
    );
    cam.viewport.add(introSequence!);
  }

  void _showCharacterSelect() {
    state.setPhase(GamePhase.characterSelect);
    overlays.add('CharacterSelect');
  }

  void startGame(CharacterType type) {
    state.selectCharacter(type);
    state.resetForNewRun();
    overlays.remove('CharacterSelect');

    // Spawn character
    _spawnCharacter(type);

    // Start world
    rgbWorld.startRun();
    spawnSystem.start();
    difficultySystem.start();

    state.setPhase(GamePhase.running);
    overlays.add('HUD');
  }

  void _spawnCharacter(CharacterType type) {
    activeCharacter?.removeFromParent();
    activeCharacter = switch (type) {
      CharacterType.red => RedCharacter(state: state, game: this),
      CharacterType.blue => BlueCharacter(state: state, game: this),
      CharacterType.green => GreenCharacter(state: state, game: this),
    };
    rgbWorld.add(activeCharacter!);
  }

  void triggerGameOver() {
    if (!state.phase.isPlaying) return;
    state.endRun();
    state.setPhase(GamePhase.gameOver);
    hapticSystem.medium();

    // Slow motion death
    timescale = 0.3;
    Future.delayed(const Duration(milliseconds: 800), () {
      timescale = 1.0;
      overlays.remove('HUD');
      state.setPhase(GamePhase.reward);
      overlays.add('ResultScreen');
    });
  }

  void triggerReward() {
    overlays.remove('ResultScreen');
    state.setPhase(GamePhase.reward);
    overlays.add('RewardScreen');
  }

  void triggerReplay() {
    overlays.remove('RewardScreen');
    overlays.remove('ResultScreen');
    rgbWorld.reset();
    startGame(state.selectedCharacter);
  }

  void triggerCurtain() {
    if (state.phase != GamePhase.running) return;
    state.setPhase(GamePhase.curtain);
    rgbWorld.triggerCurtain();
  }

  void exitCurtain() {
    state.setPhase(GamePhase.running);
    rgbWorld.exitCurtain();
  }

  void triggerStage() {
    state.setPhase(GamePhase.stage);
    rgbWorld.triggerStage();
  }

  void triggerWhiteMode() {
    if (!state.whiteReady || state.whiteModeActive) return;
    state.activateWhiteMode();
    state.setPhase(GamePhase.whiteMode);
    hapticSystem.strongPattern();
    rgbWorld.onWhiteModeStart();
    activeCharacter?.onWhiteModeStart();

    Future.delayed(
      Duration(milliseconds: (GameConfig.whiteModeDuration * 1000).round()),
      () {
        state.setPhase(GamePhase.running);
        rgbWorld.onWhiteModeEnd();
        activeCharacter?.onWhiteModeEnd();
      },
    );
  }

  void triggerLaser() {
    if (!state.laserReady) return;
    state.consumeLaserEnergy();
    state.lasersUsed++;
    hapticSystem.medium();
    activeCharacter?.fireLaser();
  }

  void triggerFirework() {
    if (!state.fireworkReady) return;
    state.consumeFireworkEnergy();
    state.fireworksUsed++;
    hapticSystem.strong();
    activeCharacter?.fireFirework();
  }

  void triggerAbility() {
    if (!state.abilityReady || state.abilityActive) return;
    state.activateAbility();
    hapticSystem.light();
    activeCharacter?.activateAbility();
  }

  // ── Input ─────────────────────────────────────────────────
  @override
  void onPanStart(DragStartInfo info) {
    _panStart = info.eventPosition.global.clone();
    _panCurrent = _panStart?.clone();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _panCurrent = info.eventPosition.global.clone();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _resolveSwipe();
  }

  @override
  void onPanCancel() {
    _panStart = null;
    _panCurrent = null;
  }

  void _resolveSwipe() {
    if (_panStart == null ||
        _panCurrent == null ||
        !state.phase.acceptsInput) {
      _panStart = null;
      _panCurrent = null;
      return;
    }

    final delta = _panCurrent! - _panStart!;
    _panStart = null;
    _panCurrent = null;

    final dx = delta.x;
    final dy = delta.y;

    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx.abs() > _swipeThreshold) {
        if (dx > 0) {
          activeCharacter?.moveRight();
        } else {
          activeCharacter?.moveLeft();
        }
      }
    } else {
      // Vertical swipe
      if (dy.abs() > _swipeThreshold) {
        if (dy < 0) {
          activeCharacter?.jump();
        } else {
          activeCharacter?.slide();
        }
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    // Taps handled by HUD buttons
  }

  // ── Update ────────────────────────────────────────────────
  @override
  void update(double dt) {
    // Apply custom timescale manually — Flame's FlameGame has no
    // built-in slow-motion property, so we scale dt ourselves and
    // propagate it through super.update(), which cascades to every
    // child component (player, world, orbs, obstacles, VFX).
    final scaledDt = dt * timescale;

    super.update(scaledDt);
    _elapsedTime += scaledDt;

    if (!state.phase.isPlaying) return;

    // Tick systems
    state.tickCombo(scaledDt);
    state.tickWhiteMode(scaledDt);
    state.tickAbility(scaledDt);
    scoreSystem.update(scaledDt);
    difficultySystem.update(scaledDt);
    spawnSystem.update(scaledDt);

    // Update max combo
    if (state.combo > state.maxCombo) {
      state.maxCombo = state.combo;
    }
  }
}

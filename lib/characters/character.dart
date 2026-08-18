import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../game/rgb_run_game.dart';
import '../game/game_state.dart';

/// The three playable character types.
enum CharacterType { red, blue, green }

/// Visual/behavioral state used to pick which sprite (or vector
/// fallback) is rendered each frame.
enum CharacterAnimState { idle, running, jumping, sliding, ability, hit, dead }

/// Base class for all playable characters (Red / Blue / Green).
///
/// Handles:
/// - Lane-based movement (moveLeft / moveRight)
/// - Jump / slide state machine
/// - Sprite loading with automatic fallback to vector drawing
///   (game works perfectly even before real art exists)
/// - Collision hitbox
abstract class PlayerCharacter extends PositionComponent
    with HasGameRef<RgbRunGame>, CollisionCallbacks {
  PlayerCharacter({required this.state, required this.game});

  final GameState state;
  final RgbRunGame game;

  // ── Lane geometry ─────────────────────────────────────────
  static const int laneCount = 3;
  static const double laneWidth = 120.0;
  static const double baseY = 420.0;

  int currentLane = 1; // 0 = left, 1 = middle, 2 = right

  // ── Jump / slide state ────────────────────────────────────
  bool isJumping = false;
  bool isSliding = false;
  static const double jumpHeight = 140.0;
  static const double jumpDuration = 0.55;
  static const double slideDuration = 0.5;

  // ── Animation state ───────────────────────────────────────
  CharacterAnimState animState = CharacterAnimState.running;

  // ── Color identity (used by vector fallback) ──────────────
  Color get primaryColor;
  Color get glowColor;
  String get displayLetter;

  // ── Sprite support ────────────────────────────────────────
  /// Maps animation state → asset file name inside assets/images/.
  /// Subclasses only need to override the ones they actually have;
  /// missing entries automatically fall back to vector drawing.
  Map<CharacterAnimState, String> get spriteAssets => {};

  final Map<CharacterAnimState, Sprite> _loadedSprites = {};
  bool _spritesReady = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2(72, 72);
    anchor = Anchor.center;
    position = Vector2(_laneX(currentLane), baseY);

    add(RectangleHitbox(
      size: Vector2(56, 56),
      position: Vector2(8, 8),
    ));

    await _loadSprites();
  }

  Future<void> _loadSprites() async {
    for (final entry in spriteAssets.entries) {
      try {
        final image = await Flame.images.load(entry.value);
        _loadedSprites[entry.key] = Sprite(image);
      } catch (e) {
        // Asset missing or invalid → silently skip, vector fallback used.
        debugPrint('⚠️ Sprite yüklenemedi (${entry.value}): $e');
      }
    }
    _spritesReady = true;
  }

  double _laneX(int lane) {
    final offset = (lane - 1) * laneWidth;
    return gameRef.size.x / 2 + offset;
  }

  // ── Movement ──────────────────────────────────────────────
  void moveLeft() {
    if (currentLane == 0) return;
    currentLane--;
    _tweenToLane();
  }

  void moveRight() {
    if (currentLane == laneCount - 1) return;
    currentLane++;
    _tweenToLane();
  }

  void _tweenToLane() {
    children.whereType<MoveToEffect>().toList().forEach(remove);
    add(
      MoveToEffect(
        Vector2(_laneX(currentLane), y),
        EffectController(duration: 0.18, curve: Curves.easeOutCubic),
      ),
    );
  }

  void jump() {
    if (isJumping || isSliding) return;
    isJumping = true;
    animState = CharacterAnimState.jumping;

    add(
      MoveToEffect(
        Vector2(x, baseY - jumpHeight),
        EffectController(
          duration: jumpDuration / 2,
          curve: Curves.easeOut,
          reverseDuration: jumpDuration / 2,
          reverseCurve: Curves.easeIn,
        ),
        onComplete: () {
          isJumping = false;
          animState = CharacterAnimState.running;
        },
      ),
    );
  }

  void slide() {
    if (isSliding || isJumping) return;
    isSliding = true;
    animState = CharacterAnimState.sliding;

    final originalHeight = size.y;
    size.y = originalHeight * 0.55;
    position.y += originalHeight * 0.225;

    Future.delayed(
      Duration(milliseconds: (slideDuration * 1000).round()),
      () {
        size.y = originalHeight;
        position.y -= originalHeight * 0.225;
        isSliding = false;
        animState = CharacterAnimState.running;
      },
    );
  }

  // ── Abilities (implemented per character) ─────────────────
  void activateAbility();

  void fireLaser() {
    animState = CharacterAnimState.ability;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (animState == CharacterAnimState.ability) {
        animState = CharacterAnimState.running;
      }
    });
  }

  void fireFirework() {
    animState = CharacterAnimState.ability;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (animState == CharacterAnimState.ability) {
        animState = CharacterAnimState.running;
      }
    });
  }

  void onWhiteModeStart() => animState = CharacterAnimState.ability;
  void onWhiteModeEnd() => animState = CharacterAnimState.running;

  void onHit() {
    animState = CharacterAnimState.hit;
    add(
      ColorEffect(
        Colors.white,
        EffectController(duration: 0.1, alternate: true, repeatCount: 3),
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (animState == CharacterAnimState.hit) {
        animState = CharacterAnimState.running;
      }
    });
  }

  void onDeath() => animState = CharacterAnimState.dead;

  // ── Render ──────────────────────────────────────────────────
  @override
  void render(Canvas canvas) {
    final sprite = _spritesReady ? _resolveSprite() : null;

    if (sprite != null) {
      sprite.render(canvas, size: size, anchor: Anchor.topLeft);
    } else {
      _renderVectorFallback(canvas);
    }
  }

  /// Picks the best available sprite for the current state,
  /// falling back through: current state → running → idle → null.
  Sprite? _resolveSprite() {
    return _loadedSprites[animState] ??
        _loadedSprites[CharacterAnimState.running] ??
        _loadedSprites[CharacterAnimState.idle];
  }

  /// Vector-drawn placeholder, used automatically whenever a sprite
  /// for the current state hasn't been provided yet.
  void _renderVectorFallback(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(rrect, glowPaint);

    canvas.drawRRect(rrect, Paint()..color = primaryColor);

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}

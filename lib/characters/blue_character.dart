import 'package:flutter/material.dart';
import 'character.dart';
import '../game/game_state.dart';
import '../game/rgb_run_game.dart';

class BlueCharacter extends PlayerCharacter {
  BlueCharacter({required GameState state, required RgbRunGame game})
      : super(state: state, game: game);

  @override
  Color get primaryColor => const Color(0xFF1677FF);

  @override
  Color get glowColor => const Color(0xFF6FB8FF);

  @override
  String get displayLetter => 'B';

  @override
  Map<CharacterAnimState, String> get spriteAssets => {
        CharacterAnimState.idle: 'blue_idle.png',
        CharacterAnimState.running: 'blue_run.png',
        CharacterAnimState.jumping: 'blue_jump.png',
        CharacterAnimState.sliding: 'blue_slide.png',
        CharacterAnimState.ability: 'blue_ability.png',
        CharacterAnimState.hit: 'blue_hit.png',
        CharacterAnimState.dead: 'blue_death.png',
      };

  /// SHIFT — instantly teleports Blue to a phased position,
  /// granting brief invulnerability.
  @override
  void activateAbility() {
    animState = CharacterAnimState.ability;

    Future.delayed(const Duration(milliseconds: 900), () {
      state.deactivateAbility();
      animState = CharacterAnimState.running;
    });
  }
}

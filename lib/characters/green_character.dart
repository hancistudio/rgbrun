import 'package:flutter/material.dart';
import 'character.dart';
import '../game/game_state.dart';
import '../game/rgb_run_game.dart';

class GreenCharacter extends PlayerCharacter {
  GreenCharacter({required GameState state, required RgbRunGame game})
      : super(state: state, game: game);

  @override
  Color get primaryColor => const Color(0xFF20D98A);

  @override
  Color get glowColor => const Color(0xFF8FF0C6);

  @override
  String get displayLetter => 'G';

  @override
  Map<CharacterAnimState, String> get spriteAssets => {
        CharacterAnimState.idle: 'green_idle.png',
        CharacterAnimState.running: 'green_run.png',
        CharacterAnimState.jumping: 'green_jump.png',
        CharacterAnimState.sliding: 'green_slide.png',
        CharacterAnimState.ability: 'green_ability.png',
        CharacterAnimState.hit: 'green_hit.png',
        CharacterAnimState.dead: 'green_death.png',
      };

  /// HEART GUARD — brief protective shield that absorbs one hit.
  @override
  void activateAbility() {
    animState = CharacterAnimState.ability;
    state.shieldActive = true;

    Future.delayed(const Duration(milliseconds: 2000), () {
      state.shieldActive = false;
      state.deactivateAbility();
      animState = CharacterAnimState.running;
    });
  }
}

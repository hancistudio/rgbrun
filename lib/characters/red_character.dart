import 'package:flutter/material.dart';
import 'character.dart';
import '../game/game_state.dart';
import '../game/rgb_run_game.dart';

class RedCharacter extends PlayerCharacter {
  RedCharacter({required GameState state, required RgbRunGame game})
      : super(state: state, game: game);

  @override
  Color get primaryColor => const Color(0xFFFF1E3C);

  @override
  Color get glowColor => const Color(0xFFFF6B81);

  @override
  String get displayLetter => 'R';

  @override
  Map<CharacterAnimState, String> get spriteAssets => {
        CharacterAnimState.idle: 'red_idle.png',
        CharacterAnimState.running: 'red_run.png',
        CharacterAnimState.jumping: 'red_jump.png',
        CharacterAnimState.sliding: 'red_slide.png',
        CharacterAnimState.ability: 'red_ability.png',
        CharacterAnimState.hit: 'red_hit.png',
        CharacterAnimState.dead: 'red_death.png',
      };

  /// LOGIC BREAK — brief slow-motion window where Red reacts faster
  /// than everything else on screen.
  @override
  void activateAbility() {
    animState = CharacterAnimState.ability;
    game.timescale = 0.5;

    Future.delayed(const Duration(milliseconds: 1500), () {
      game.timescale = 1.0;
      state.deactivateAbility();
      animState = CharacterAnimState.running;
    });
  }
}

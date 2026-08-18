import 'package:flutter/material.dart';
import '../game/rgb_run_game.dart';
import '../game/game_config.dart';

/// Live HUD — RGB meters, White Energy, combo, ability buttons.
class HudWidget extends StatefulWidget {
  final RgbRunGame game;
  const HudWidget({super.key, required this.game});

  @override
  State<HudWidget> createState() => _HudWidgetState();
}

class _HudWidgetState extends State<HudWidget> {
  @override
  void initState() {
    super.initState();
    widget.game.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.game.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.game.state;

    return SafeArea(
      child: Stack(
        children: [
          // ── Top: RGB + White energy bars ──────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _EnergyPip(
                  color: const Color(GameConfig.redColorHex),
                  value: state.redEnergy,
                  label: 'R',
                ),
                const SizedBox(width: 6),
                _EnergyPip(
                  color: const Color(GameConfig.blueColorHex),
                  value: state.blueEnergy,
                  label: 'B',
                ),
                const SizedBox(width: 6),
                _EnergyPip(
                  color: const Color(GameConfig.greenColorHex),
                  value: state.greenEnergy,
                  label: 'G',
                ),
                const Spacer(),
                _ScoreDisplay(score: state.score.round()),
              ],
            ),
          ),

          // ── White Energy bar ───────────────────────────────
          Positioned(
            top: 44,
            left: 16,
            right: 16,
            child: _WhiteEnergyBar(
              value: state.whiteEnergy / GameConfig.whiteEnergyMax,
              ready: state.whiteReady,
            ),
          ),

          // ── Combo display ──────────────────────────────────
          if (state.combo > 1)
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                child: _ComboDisplay(
                  combo: state.combo,
                  multiplier: state.comboMultiplier,
                ),
              ),
            ),

          // ── Health hearts ───────────────────────────────────
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Icon(
                    i < state.health ? Icons.favorite : Icons.favorite_border,
                    color: const Color(GameConfig.greenColorHex),
                    size: 16,
                  );
                }),
              ),
            ),
          ),

          // ── Bottom action buttons ──────────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AbilityButton(
                  label: 'ABILITY',
                  ready: state.abilityReady,
                  progress: state.abilityCooldownFraction,
                  color: _characterColor(state),
                  onTap: widget.game.triggerAbility,
                ),
                _AbilityButton(
                  label: 'LASER',
                  ready: state.laserReady,
                  progress: state.laserEnergy / GameConfig.laserEnergyMax,
                  color: Colors.cyanAccent,
                  onTap: widget.game.triggerLaser,
                ),
                _AbilityButton(
                  label: 'FIREWORK',
                  ready: state.fireworkReady,
                  progress: state.fireworkEnergy / GameConfig.fireworkEnergyMax,
                  color: Colors.orangeAccent,
                  breathe: state.fireworkReady,
                  onTap: widget.game.triggerFirework,
                ),
                _AbilityButton(
                  label: 'WHITE',
                  ready: state.whiteReady,
                  progress: state.whiteEnergy / GameConfig.whiteEnergyMax,
                  color: Colors.white,
                  breathe: state.whiteReady,
                  onTap: widget.game.triggerWhiteMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _characterColor(dynamic state) {
    return switch (widget.game.state.selectedCharacter.toString()) {
      'CharacterType.red' => const Color(GameConfig.redColorHex),
      'CharacterType.blue' => const Color(GameConfig.blueColorHex),
      _ => const Color(GameConfig.greenColorHex),
    };
  }
}

class _EnergyPip extends StatelessWidget {
  final Color color;
  final double value;
  final String label;

  const _EnergyPip({
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$label ${value.round()}',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final int score;
  const _ScoreDisplay({required this.score});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$score',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _WhiteEnergyBar extends StatelessWidget {
  final double value;
  final bool ready;

  const _WhiteEnergyBar({required this.value, required this.ready});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 8,
            color: Colors.white12,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: ready
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (ready)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'WHITE READY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _ComboDisplay extends StatelessWidget {
  final int combo;
  final double multiplier;

  const _ComboDisplay({required this.combo, required this.multiplier});

  @override
  Widget build(BuildContext context) {
    double scale = 1.0 + (multiplier - 1) * 0.08;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: scale),
      duration: const Duration(milliseconds: 200),
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Text(
        'x$combo COMBO',
        style: TextStyle(
          color: Colors.yellowAccent,
          fontSize: 14 + multiplier,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.orange, blurRadius: 8),
          ],
        ),
      ),
    );
  }
}

class _AbilityButton extends StatelessWidget {
  final String label;
  final bool ready;
  final double progress;
  final Color color;
  final bool breathe;
  final VoidCallback onTap;

  const _AbilityButton({
    required this.label,
    required this.ready,
    required this.progress,
    required this.color,
    required this.onTap,
    this.breathe = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ready ? onTap : null,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: breathe ? 1.12 : 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black54,
            border: Border.all(
              color: ready ? color : color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: ready
                ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 14)]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress.clamp(0, 1),
                  strokeWidth: 3,
                  color: color,
                  backgroundColor: Colors.white10,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ready ? Colors.white : Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

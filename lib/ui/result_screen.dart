import 'package:flutter/material.dart';
import '../game/rgb_run_game.dart';
import '../game/game_config.dart';

class ResultScreenWidget extends StatelessWidget {
  final RgbRunGame game;
  const ResultScreenWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final state = game.state;

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RUN OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            _StatRow(label: 'SCORE', value: state.score.round().toString()),
            _StatRow(label: 'BEST', value: state.bestScore.round().toString()),
            _StatRow(
                label: 'DISTANCE',
                value: '${state.distance.round()}m'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniStat(
                  color: const Color(GameConfig.redColorHex),
                  value: state.orbsCollectedRed,
                ),
                const SizedBox(width: 16),
                _MiniStat(
                  color: const Color(GameConfig.blueColorHex),
                  value: state.orbsCollectedBlue,
                ),
                const SizedBox(width: 16),
                _MiniStat(
                  color: const Color(GameConfig.greenColorHex),
                  value: state.orbsCollectedGreen,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StatRow(label: 'COMBO', value: 'x${state.maxCombo}'),
            _StatRow(label: 'LASERS', value: '${state.lasersUsed}'),
            _StatRow(label: 'FIREWORKS', value: '${state.fireworksUsed}'),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: game.triggerReward,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final Color color;
  final int value;
  const _MiniStat({required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$value', style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

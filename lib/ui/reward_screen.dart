import 'package:flutter/material.dart';
import '../game/rgb_run_game.dart';

class RewardScreenWidget extends StatefulWidget {
  final RgbRunGame game;
  const RewardScreenWidget({super.key, required this.game});

  @override
  State<RewardScreenWidget> createState() => _RewardScreenWidgetState();
}

class _RewardScreenWidgetState extends State<RewardScreenWidget> {
  @override
  Widget build(BuildContext context) {
    final state = widget.game.state;

    return Container(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'REWARDS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            _AnimatedCounter(label: 'COINS', value: state.coinsEarned),
            const SizedBox(height: 8),
            _AnimatedCounter(label: 'XP', value: state.xpEarned),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: widget.game.triggerReplay,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Colors.redAccent,
                    Colors.blueAccent,
                    Colors.greenAccent,
                  ]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    color: Colors.white,
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

class _AnimatedCounter extends StatelessWidget {
  final String label;
  final int value;

  const _AnimatedCounter({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, v, child) {
        return Text(
          '$label  +$v',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

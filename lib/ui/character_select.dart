import 'package:flutter/material.dart';
import '../game/rgb_run_game.dart';
import '../game/game_config.dart';
import '../characters/character.dart';

class CharacterSelectWidget extends StatefulWidget {
  final RgbRunGame game;
  const CharacterSelectWidget({super.key, required this.game});

  @override
  State<CharacterSelectWidget> createState() => _CharacterSelectWidgetState();
}

class _CharacterSelectWidgetState extends State<CharacterSelectWidget> {
  CharacterType? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'CHOOSE YOUR LIGHT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CharacterCard(
                  type: CharacterType.red,
                  color: const Color(GameConfig.redColorHex),
                  name: 'RED',
                  tagline: 'LOGIC',
                  selected: _selected == CharacterType.red,
                  onTap: () => _select(CharacterType.red),
                ),
                _CharacterCard(
                  type: CharacterType.blue,
                  color: const Color(GameConfig.blueColorHex),
                  name: 'BLUE',
                  tagline: 'CREATIVITY',
                  selected: _selected == CharacterType.blue,
                  onTap: () => _select(CharacterType.blue),
                ),
                _CharacterCard(
                  type: CharacterType.green,
                  color: const Color(GameConfig.greenColorHex),
                  name: 'GREEN',
                  tagline: 'HEART',
                  selected: _selected == CharacterType.green,
                  onTap: () => _select(CharacterType.green),
                ),
              ],
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _selected != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: _selected != null
                    ? () => widget.game.startGame(_selected!)
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'RUN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(CharacterType type) {
    setState(() => _selected = type);
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterType type;
  final Color color;
  final String name;
  final String tagline;
  final bool selected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.type,
    required this.color,
    required this.name,
    required this.tagline,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(selected ? 0.9 : 0.4),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [BoxShadow(color: color, blurRadius: 24, spreadRadius: 2)]
                    : null,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              tagline,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

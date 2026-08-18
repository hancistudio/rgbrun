import 'package:flutter/material.dart';
import '../game/rgb_run_game.dart';
import 'package:flame/game.dart';

class RgbApp extends StatelessWidget {
  const RgbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RGB RUN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'RgbFont',
      ),
      home: const RgbGameWrapper(),
    );
  }
}

class RgbGameWrapper extends StatefulWidget {
  const RgbGameWrapper({super.key});

  @override
  State<RgbGameWrapper> createState() => _RgbGameWrapperState();
}

class _RgbGameWrapperState extends State<RgbGameWrapper> {
  late final RgbRunGame _game;

  @override
  void initState() {
    super.initState();
    _game = RgbRunGame();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      overlayBuilderMap: {
        'HUD': (context, game) => HudOverlay(game: game as RgbRunGame),
        'CharacterSelect': (context, game) =>
            CharacterSelectOverlay(game: game as RgbRunGame),
        'ResultScreen': (context, game) =>
            ResultScreenOverlay(game: game as RgbRunGame),
        'RewardScreen': (context, game) =>
            RewardScreenOverlay(game: game as RgbRunGame),
      },
      loadingBuilder: (context) => const _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// Forward declarations for overlays (defined in ui/ files)
// These are imported here for GameWidget registration
class HudOverlay extends StatelessWidget {
  final RgbRunGame game;
  const HudOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) => game.hudWidget;
}

class CharacterSelectOverlay extends StatelessWidget {
  final RgbRunGame game;
  const CharacterSelectOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) => game.characterSelectWidget;
}

class ResultScreenOverlay extends StatelessWidget {
  final RgbRunGame game;
  const ResultScreenOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) => game.resultScreenWidget;
}

class RewardScreenOverlay extends StatelessWidget {
  final RgbRunGame game;
  const RewardScreenOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) => game.rewardScreenWidget;
}

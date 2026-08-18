import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/rgb_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only — mobile UX priority
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Full immersive mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const RgbApp());
}

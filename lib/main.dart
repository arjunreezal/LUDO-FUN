import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _lockPhonesToPortrait();
  runApp(const LudoApp());
}

/// Gameplay is designed for portrait on phones. Tablets may rotate.
Future<void> _lockPhonesToPortrait() async {
  var shortestSide = 0.0;
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isNotEmpty) {
    final view = views.first;
    if (view.devicePixelRatio > 0) {
      shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
    }
  }
  if (shortestSide >= 600) {
    return;
  }
  try {
    await SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp]);
  } on Exception {
    // Some platforms (for example desktop browsers) ignore orientation locks.
  }
}

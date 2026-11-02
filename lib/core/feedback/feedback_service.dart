import 'dart:async';

import 'package:flutter/services.dart';

import '../../features/settings/settings_controller.dart';

/// Sound and haptic feedback that respects the player's settings.
///
/// This release uses the platform's built-in click sound and haptics only;
/// a custom sound pack is planned. No game information depends on sound.
class FeedbackService {
  FeedbackService(this._settings);

  final SettingsController _settings;

  void button() => _emit(HapticFeedback.selectionClick, sound: false);
  void diceRoll() => _emit(HapticFeedback.lightImpact);
  void tokenMove() => _emit(HapticFeedback.selectionClick);
  void capture() => _emit(HapticFeedback.mediumImpact);
  void tokenHome() => _emit(HapticFeedback.mediumImpact);
  void win() => _emit(HapticFeedback.heavyImpact);

  void _emit(Future<void> Function() haptic, {bool sound = true}) {
    if (sound && _settings.soundEffects) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
    if (_settings.vibration) {
      unawaited(haptic());
    }
  }
}

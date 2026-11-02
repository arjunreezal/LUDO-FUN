import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/storage/key_value_store.dart';

enum AppThemePreference {
  dark,
  light,
  system;

  ThemeMode get themeMode => switch (this) {
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.system => ThemeMode.system,
      };

  static AppThemePreference fromName(String? name) {
    for (final value in AppThemePreference.values) {
      if (value.name == name) {
        return value;
      }
    }
    return AppThemePreference.dark;
  }
}

enum GameSpeed {
  relaxed,
  normal,
  fast;

  static GameSpeed fromName(String? name) {
    for (final value in GameSpeed.values) {
      if (value.name == name) {
        return value;
      }
    }
    return GameSpeed.normal;
  }
}

/// User preferences, persisted locally.
class SettingsController extends ChangeNotifier {
  static const _kSound = 'settings.sound';
  static const _kVibration = 'settings.vibration';
  static const _kReduceMotion = 'settings.reduceMotion';
  static const _kTheme = 'settings.theme';
  static const _kLanguage = 'settings.language';
  static const _kSpeed = 'settings.speed';
  static const _kAutoMove = 'settings.autoMove';
  static const _kOnboarding = 'onboarding.done';

  KeyValueStore _store = MemoryStore();

  bool _soundEffects = true;
  bool _vibration = true;
  bool _reduceMotion = false;
  AppThemePreference _theme = AppThemePreference.dark;
  AppLanguage _language = AppLanguage.en;
  GameSpeed _speed = GameSpeed.normal;
  bool _autoMove = true;
  bool _onboardingComplete = false;

  bool get soundEffects => _soundEffects;
  bool get vibration => _vibration;
  bool get reduceMotion => _reduceMotion;
  AppThemePreference get theme => _theme;
  ThemeMode get themeMode => _theme.themeMode;
  AppLanguage get language => _language;
  AppStrings get strings => AppStrings(_language);
  GameSpeed get speed => _speed;
  bool get autoMoveSingleOption => _autoMove;
  bool get onboardingComplete => _onboardingComplete;

  void attach(KeyValueStore store) {
    _store = store;
    _soundEffects = store.getBool(_kSound) ?? true;
    _vibration = store.getBool(_kVibration) ?? true;
    _reduceMotion = store.getBool(_kReduceMotion) ?? false;
    _theme = AppThemePreference.fromName(store.getString(_kTheme));
    _language = AppLanguage.fromName(store.getString(_kLanguage));
    _speed = GameSpeed.fromName(store.getString(_kSpeed));
    _autoMove = store.getBool(_kAutoMove) ?? true;
    _onboardingComplete = store.getBool(_kOnboarding) ?? false;
    notifyListeners();
  }

  void setSoundEffects(bool value) {
    if (_soundEffects == value) {
      return;
    }
    _soundEffects = value;
    _changed(_store.setBool(_kSound, value));
  }

  void setVibration(bool value) {
    if (_vibration == value) {
      return;
    }
    _vibration = value;
    _changed(_store.setBool(_kVibration, value));
  }

  void setReduceMotion(bool value) {
    if (_reduceMotion == value) {
      return;
    }
    _reduceMotion = value;
    _changed(_store.setBool(_kReduceMotion, value));
  }

  void setTheme(AppThemePreference value) {
    if (_theme == value) {
      return;
    }
    _theme = value;
    _changed(_store.setString(_kTheme, value.name));
  }

  void setLanguage(AppLanguage value) {
    if (_language == value) {
      return;
    }
    _language = value;
    _changed(_store.setString(_kLanguage, value.name));
  }

  void setSpeed(GameSpeed value) {
    if (_speed == value) {
      return;
    }
    _speed = value;
    _changed(_store.setString(_kSpeed, value.name));
  }

  void setAutoMoveSingleOption(bool value) {
    if (_autoMove == value) {
      return;
    }
    _autoMove = value;
    _changed(_store.setBool(_kAutoMove, value));
  }

  void completeOnboarding() {
    if (_onboardingComplete) {
      return;
    }
    _onboardingComplete = true;
    _changed(_store.setBool(_kOnboarding, true));
  }

  void _changed(Future<void> write) {
    notifyListeners();
    unawaited(write);
  }
}

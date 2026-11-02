import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value persistence used for settings, the local profile and
/// offline statistics. Kept behind an interface so tests and a failed
/// platform store can fall back to memory.
abstract class KeyValueStore {
  bool? getBool(String key);
  int? getInt(String key);
  String? getString(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);

  /// False when values will be lost once the app closes.
  bool get isPersistent;
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsStore> open() async =>
      SharedPrefsStore(await SharedPreferences.getInstance());

  @override
  bool get isPersistent => true;

  @override
  bool? getBool(String key) {
    final value = _prefs.get(key);
    return value is bool ? value : null;
  }

  @override
  int? getInt(String key) {
    final value = _prefs.get(key);
    return value is int ? value : null;
  }

  @override
  String? getString(String key) {
    final value = _prefs.get(key);
    return value is String ? value : null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, Object>? initial])
      : _values = <String, Object>{...?initial};

  final Map<String, Object> _values;

  @override
  bool get isPersistent => false;

  @override
  bool? getBool(String key) {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  int? getInt(String key) {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  String? getString(String key) {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}

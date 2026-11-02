import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/storage/key_value_store.dart';
import '../games/ludo/models/match_setup.dart';
import '../games/ludo/models/match_summary.dart';
import '../games/ludo/models/player_seat.dart';
import 'profile_models.dart';

/// The local (offline) profile: name, avatar colour, a device player ID,
/// Classic Ludo statistics and recent match history.
class ProfileController extends ChangeNotifier {
  static const _kName = 'profile.name';
  static const _kAvatar = 'profile.avatar';
  static const _kId = 'profile.id';
  static const _kStats = 'stats.ludo';
  static const _kHistory = 'history.ludo';

  static const int maxNameLength = 20;
  static const int maxHistory = 30;
  static const int avatarCount = 8;

  KeyValueStore _store = MemoryStore();
  String _name = '';
  int _avatar = 0;
  String _playerId = '';
  LudoStats _stats = const LudoStats();
  List<MatchRecord> _history = const <MatchRecord>[];

  String get displayName => _name;
  int get avatarIndex => _avatar;
  String get playerId => _playerId;
  LudoStats get stats => _stats;
  List<MatchRecord> get history => _history;

  void attach(KeyValueStore store, {required String defaultName}) {
    _store = store;
    _name = _cleanName(store.getString(_kName) ?? '') ?? defaultName;
    final avatar = store.getInt(_kAvatar) ?? 0;
    _avatar = avatar >= 0 && avatar < avatarCount ? avatar : 0;
    _playerId = store.getString(_kId) ?? '';
    if (_playerId.isEmpty) {
      _playerId = _generateId();
      unawaited(store.setString(_kId, _playerId));
    }
    _stats = LudoStats.fromJson(_decode(store.getString(_kStats)));
    final rawHistory = _decode(store.getString(_kHistory));
    final records = <MatchRecord>[];
    if (rawHistory is List) {
      for (final raw in rawHistory) {
        final record = MatchRecord.fromJson(raw);
        if (record != null) {
          records.add(record);
        }
      }
    }
    _history = List<MatchRecord>.unmodifiable(records);
    notifyListeners();
  }

  /// Returns false when [name] is empty after trimming.
  bool setDisplayName(String name) {
    final cleaned = _cleanName(name);
    if (cleaned == null) {
      return false;
    }
    _name = cleaned;
    notifyListeners();
    unawaited(_store.setString(_kName, cleaned));
    return true;
  }

  void setAvatar(int index) {
    if (index < 0 || index >= avatarCount || index == _avatar) {
      return;
    }
    _avatar = index;
    notifyListeners();
    unawaited(_store.setInt(_kAvatar, index));
  }

  /// Adds a finished match to the statistics of this device's seat. Matches
  /// without a local seat are ignored.
  void recordMatch(MatchSummary summary) {
    final seat = summary.localSeat;
    if (seat == null) {
      return;
    }
    final setup = summary.setup;
    final record = MatchRecord(
      endedAtMs: summary.endedAt.millisecondsSinceEpoch,
      durationSeconds: summary.duration.inSeconds,
      mode: setup.mode.name,
      playerCount: summary.players.length,
      computerCount: setup.computerCount,
      difficulty: setup.difficulty?.name,
      placement: summary.placementOf(seat),
      captures: summary.captures[seat],
      tokensLost: summary.tokensLost[seat],
      tokensHome: summary.finishedTokens[seat],
      color: summary.players[seat].color.name,
    );
    final againstHard = setup.mode == MatchMode.computer &&
        summary.players.any((player) =>
            player.isComputer && player.difficulty == BotDifficulty.hard);
    _stats = _stats.withMatch(record, againstHard: againstHard);
    _history = List<MatchRecord>.unmodifiable(
        <MatchRecord>[record, ..._history].take(maxHistory));
    notifyListeners();
    unawaited(_persistStats());
  }

  void resetStats() {
    _stats = const LudoStats();
    _history = const <MatchRecord>[];
    notifyListeners();
    unawaited(_persistStats());
  }

  Future<void> _persistStats() async {
    await _store.setString(_kStats, jsonEncode(_stats.toJson()));
    await _store.setString(_kHistory,
        jsonEncode(<Object>[for (final record in _history) record.toJson()]));
  }

  static String? _cleanName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.length > maxNameLength
        ? trimmed.substring(0, maxNameLength)
        : trimmed;
  }

  static Object? _decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static String _generateId() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    Random random;
    try {
      random = Random.secure();
    } on UnsupportedError {
      random = Random();
    }
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      if (i == 4) {
        buffer.write('-');
      }
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }
}

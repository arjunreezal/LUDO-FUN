import '../models/ludo_color.dart';
import '../models/ludo_constants.dart';

/// Rules-level geometry of the shared track: which absolute square a token
/// occupies and which squares are safe. Pure Dart; no Flutter imports.
abstract final class LudoTrack {
  /// Absolute track index (0..51) of [color]'s start square.
  static int startIndex(LudoColor color) =>
      color.index * LudoConstants.seatOffset;

  /// Absolute track index for a token of [color] at [progress], or null when
  /// the token is in its base, its home column, or finished.
  static int? absoluteIndex(LudoColor color, int progress) {
    if (progress < LudoConstants.startProgress ||
        progress > LudoConstants.lastTrackProgress) {
      return null;
    }
    return (startIndex(color) + progress) % LudoConstants.trackLength;
  }

  /// Start squares and star squares.
  static bool isSafeIndex(int index) {
    final offset = index % LudoConstants.seatOffset;
    return offset == 0 || offset == LudoConstants.starOffset;
  }

  static bool isStartIndex(int index) =>
      index % LudoConstants.seatOffset == 0;

  /// The colour whose start square is at [index], if any.
  static LudoColor? startOwner(int index) => isStartIndex(index)
      ? LudoColor.values[index ~/ LudoConstants.seatOffset]
      : null;

  static bool isOnHomeColumn(int progress) =>
      progress > LudoConstants.lastTrackProgress &&
      progress < LudoConstants.finishedProgress;
}

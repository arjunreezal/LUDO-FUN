import '../../../settings/settings_controller.dart';

/// Pacing for a local match. Computer delays keep the game readable; all
/// values can be zero (tests use [MatchTiming.instant]).
class MatchTiming {
  const MatchTiming({
    required this.roll,
    required this.hop,
    required this.captureReturn,
    required this.botRoll,
    required this.botMove,
    required this.autoMove,
    this.collapsePaths = false,
  });

  /// How long the dice tumbles before the result is applied.
  final Duration roll;

  /// Time per square while a token travels.
  final Duration hop;

  /// Time for a captured token to slide back to its base.
  final Duration captureReturn;

  /// Pause before a computer seat rolls.
  final Duration botRoll;

  /// Pause before a computer seat moves.
  final Duration botMove;

  /// Pause before an automatic move when only one choice exists.
  final Duration autoMove;

  /// Move tokens straight to their destination instead of square by square.
  final bool collapsePaths;

  static const MatchTiming instant = MatchTiming(
    roll: Duration.zero,
    hop: Duration.zero,
    captureReturn: Duration.zero,
    botRoll: Duration.zero,
    botMove: Duration.zero,
    autoMove: Duration.zero,
  );

  static MatchTiming forSettings(GameSpeed speed, {required bool reduceMotion}) {
    final base = switch (speed) {
      GameSpeed.relaxed => const MatchTiming(
          roll: Duration(milliseconds: 750),
          hop: Duration(milliseconds: 190),
          captureReturn: Duration(milliseconds: 420),
          botRoll: Duration(milliseconds: 850),
          botMove: Duration(milliseconds: 700),
          autoMove: Duration(milliseconds: 320),
        ),
      GameSpeed.normal => const MatchTiming(
          roll: Duration(milliseconds: 600),
          hop: Duration(milliseconds: 150),
          captureReturn: Duration(milliseconds: 360),
          botRoll: Duration(milliseconds: 520),
          botMove: Duration(milliseconds: 440),
          autoMove: Duration(milliseconds: 240),
        ),
      GameSpeed.fast => const MatchTiming(
          roll: Duration(milliseconds: 360),
          hop: Duration(milliseconds: 90),
          captureReturn: Duration(milliseconds: 220),
          botRoll: Duration(milliseconds: 260),
          botMove: Duration(milliseconds: 220),
          autoMove: Duration(milliseconds: 140),
        ),
    };
    if (!reduceMotion) {
      return base;
    }
    return MatchTiming(
      roll: const Duration(milliseconds: 160),
      hop: const Duration(milliseconds: 180),
      captureReturn: const Duration(milliseconds: 160),
      botRoll: base.botRoll,
      botMove: base.botMove,
      autoMove: base.autoMove,
      collapsePaths: true,
    );
  }
}

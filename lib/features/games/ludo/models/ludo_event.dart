/// Things that happened while the engine applied an action. The UI uses these
/// for the move log, sound and haptics; it never derives rules from them.
enum LudoEventType {
  rolled,
  noLegalMoves,
  sixLimitReached,
  tokenEntered,
  tokenMoved,
  tokenCaptured,
  tokenFinished,
  playerFinished,
  extraTurn,
  turnPassed,
  matchFinished,
}

class LudoEvent {
  const LudoEvent(
    this.type, {
    required this.player,
    this.token,
    this.value,
    this.otherPlayer,
    this.otherToken,
  });

  final LudoEventType type;

  /// The acting seat. For [LudoEventType.turnPassed] this is the seat that
  /// plays next; for [LudoEventType.matchFinished] it is the winner.
  final int player;

  final int? token;

  /// Dice value for rolls, steps for moves, placement (1-based) for
  /// [LudoEventType.playerFinished].
  final int? value;

  /// The captured seat for [LudoEventType.tokenCaptured].
  final int? otherPlayer;
  final int? otherToken;

  @override
  String toString() =>
      'LudoEvent(${type.name}, player: $player, token: $token, value: $value)';
}

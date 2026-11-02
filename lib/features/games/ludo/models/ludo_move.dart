import 'ludo_constants.dart';

/// Identifies one token: the seat index and the token index within the seat.
class TokenRef {
  const TokenRef(this.player, this.token);

  final int player;
  final int token;

  @override
  bool operator ==(Object other) =>
      other is TokenRef && other.player == player && other.token == token;

  @override
  int get hashCode => Object.hash(player, token);

  @override
  String toString() => 'TokenRef($player, $token)';
}

/// A legal move produced by the rules engine.
class LudoMove {
  const LudoMove({
    required this.player,
    required this.token,
    required this.from,
    required this.to,
    this.captures = const <TokenRef>[],
  });

  final int player;
  final int token;

  /// Progress before the move (`-1` for a token in its base).
  final int from;

  /// Progress after the move.
  final int to;

  /// Opponent tokens that will be sent back to their bases.
  final List<TokenRef> captures;

  bool get entersBoard => from == LudoConstants.inBase;
  bool get finishesToken => to == LudoConstants.finishedProgress;
  bool get isCapture => captures.isNotEmpty;
  bool get entersHomeColumn =>
      from <= LudoConstants.lastTrackProgress &&
      to > LudoConstants.lastTrackProgress;

  @override
  String toString() =>
      'LudoMove(p$player t$token $from->$to${isCapture ? ' captures ${captures.length}' : ''})';
}

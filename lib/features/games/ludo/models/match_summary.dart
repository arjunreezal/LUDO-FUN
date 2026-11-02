import 'match_setup.dart';
import 'player_seat.dart';

/// The outcome of a finished local match, as shown on the results screen and
/// written to local statistics.
class MatchSummary {
  const MatchSummary({
    required this.setup,
    required this.players,
    required this.placements,
    required this.finishedTokens,
    required this.captures,
    required this.tokensLost,
    required this.duration,
    required this.turns,
    required this.endedAt,
  });

  final MatchSetup setup;

  /// Seats in engine order (clockwise by colour).
  final List<PlayerSeat> players;

  /// Seat indices in finishing order.
  final List<int> placements;
  final List<int> finishedTokens;
  final List<int> captures;
  final List<int> tokensLost;
  final Duration duration;
  final int turns;
  final DateTime endedAt;

  /// Index of the seat owned by this device's profile, if any.
  int? get localSeat {
    for (var i = 0; i < players.length; i++) {
      if (players[i].isLocalProfile) {
        return i;
      }
    }
    return null;
  }

  /// 1-based placement of [seat].
  int placementOf(int seat) => placements.indexOf(seat) + 1;

  PlayerSeat get winner => players[placements.first];
}

/// Fixed geometry of a standard four-seat Ludo board.
///
/// Token positions are stored as *progress* relative to the owner's start
/// square:
///
/// * `-1` — waiting in the home base
/// * `0..50` — on the shared 52-square track (0 is the owner's start square)
/// * `51..55` — on the owner's private home column
/// * `56` — finished (reached the centre)
abstract final class LudoConstants {
  static const int tokensPerPlayer = 4;
  static const int trackLength = 52;
  static const int seatOffset = 13;
  static const int inBase = -1;
  static const int startProgress = 0;
  static const int lastTrackProgress = 50;
  static const int homeColumnLength = 5;
  static const int finishedProgress = 56;

  /// Star (safe) squares sit this many steps after each start square.
  static const int starOffset = 8;

  static const int minPlayers = 2;
  static const int maxPlayers = 4;
}

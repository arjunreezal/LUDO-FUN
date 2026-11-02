/// The four seat colours of a standard Ludo board.
///
/// The enum order is also the clockwise turn order and the board quadrant:
/// red = top-left, green = top-right, yellow = bottom-right,
/// blue = bottom-left.
enum LudoColor {
  red,
  green,
  yellow,
  blue;

  /// The colour sitting directly across the board.
  LudoColor get opposite =>
      LudoColor.values[(index + 2) % LudoColor.values.length];

  static LudoColor fromName(String? name, LudoColor fallback) {
    for (final color in LudoColor.values) {
      if (color.name == name) {
        return color;
      }
    }
    return fallback;
  }
}

import 'dart:math';

/// Produces dice values for offline play. Online matches must use
/// server-generated rolls instead.
class DiceRoller {
  DiceRoller([Random? random]) : _random = random ?? _defaultRandom();

  final Random _random;

  static Random _defaultRandom() {
    try {
      return Random.secure();
    } on UnsupportedError {
      return Random();
    }
  }

  /// A uniformly distributed value from 1 to 6.
  int roll() => _random.nextInt(6) + 1;
}

/// Returns pre-set values in order, then repeats the last one. Used by tests
/// and by tutorials that need predictable rolls.
class ScriptedDiceRoller extends DiceRoller {
  ScriptedDiceRoller(List<int> values)
      : assert(values.isNotEmpty),
        _values = List<int>.of(values),
        super(Random(0));

  final List<int> _values;
  int _next = 0;

  @override
  int roll() {
    final value = _values[_next < _values.length ? _next : _values.length - 1];
    _next++;
    return value;
  }
}

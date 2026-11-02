import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/features/games/ludo/engine/dice.dart';

void main() {
  test('rolls are always between 1 and 6 and every face appears', () {
    final dice = DiceRoller();
    final counts = List<int>.filled(7, 0);
    for (var i = 0; i < 6000; i++) {
      final value = dice.roll();
      expect(value, inInclusiveRange(1, 6));
      counts[value]++;
    }
    for (var face = 1; face <= 6; face++) {
      // Expected 1000 per face; a fair die lands far inside this band.
      expect(counts[face], inInclusiveRange(800, 1200),
          reason: 'face $face appeared ${counts[face]} times');
    }
  });

  test('a seeded roller is reproducible', () {
    final first = DiceRoller(Random(3));
    final second = DiceRoller(Random(3));
    final a = <int>[for (var i = 0; i < 20; i++) first.roll()];
    final b = <int>[for (var i = 0; i < 20; i++) second.roll()];
    expect(a, b);
  });

  test('scripted rolls come out in order and then repeat the last value', () {
    final dice = ScriptedDiceRoller(<int>[6, 2, 5]);
    expect(<int>[for (var i = 0; i < 5; i++) dice.roll()], <int>[6, 2, 5, 5, 5]);
  });
}

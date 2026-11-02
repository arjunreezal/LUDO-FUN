import 'package:flutter_test/flutter_test.dart';
import 'package:ludo/features/games/ludo/engine/board_geometry.dart';
import 'package:ludo/features/games/ludo/models/ludo_color.dart';
import 'package:ludo/features/games/ludo/models/ludo_constants.dart';

void main() {
  final geometry = LudoBoardGeometry.track;

  test('the shared track has 52 distinct squares inside the grid', () {
    expect(geometry, hasLength(LudoConstants.trackLength));
    expect(geometry.toSet(), hasLength(LudoConstants.trackLength));
    for (final point in geometry) {
      expect(point.x, inExclusiveRange(0, LudoBoardGeometry.gridSize));
      expect(point.y, inExclusiveRange(0, LudoBoardGeometry.gridSize));
    }
  });

  test('consecutive track squares touch, including the loop back', () {
    for (var i = 0; i < geometry.length; i++) {
      final a = geometry[i];
      final b = geometry[(i + 1) % geometry.length];
      final dx = (a.x - b.x).abs();
      final dy = (a.y - b.y).abs();
      expect(dx <= 1.0 && dy <= 1.0 && dx + dy > 0, isTrue,
          reason: 'squares $i and ${i + 1} are not adjacent');
    }
  });

  test('start squares sit where each colour leaves its base', () {
    expect(LudoBoardGeometry.tokenPoint(LudoColor.red, 0, 0),
        LudoBoardGeometry.cellCenter(6, 1));
    expect(LudoBoardGeometry.tokenPoint(LudoColor.green, 0, 0),
        LudoBoardGeometry.cellCenter(1, 8));
    expect(LudoBoardGeometry.tokenPoint(LudoColor.yellow, 0, 0),
        LudoBoardGeometry.cellCenter(8, 13));
    expect(LudoBoardGeometry.tokenPoint(LudoColor.blue, 0, 0),
        LudoBoardGeometry.cellCenter(13, 6));
  });

  test('the last track square leads straight into the home column', () {
    for (final color in LudoColor.values) {
      final last = LudoBoardGeometry.tokenPoint(
          color, 0, LudoConstants.lastTrackProgress);
      final firstHome = LudoBoardGeometry.tokenPoint(
          color, 0, LudoConstants.lastTrackProgress + 1);
      final distance = (last.x - firstHome.x).abs() + (last.y - firstHome.y).abs();
      expect(distance, closeTo(1, 1e-9), reason: color.name);
    }
  });

  test('home columns run toward the centre', () {
    const centre = BoardPoint(7.5, 7.5);
    for (final color in LudoColor.values) {
      double distanceToCentre(int step) {
        final point = LudoBoardGeometry.homeColumn(color, step);
        return (point.x - centre.x).abs() + (point.y - centre.y).abs();
      }

      for (var step = 1; step < LudoConstants.homeColumnLength; step++) {
        expect(distanceToCentre(step), lessThan(distanceToCentre(step - 1)));
      }
    }
  });

  test('base slots sit inside their own quadrant', () {
    for (final color in LudoColor.values) {
      final centre = LudoBoardGeometry.baseCenter(color);
      for (var token = 0; token < LudoConstants.tokensPerPlayer; token++) {
        final slot = LudoBoardGeometry.baseSlot(color, token);
        expect((slot.x - centre.x).abs(), lessThan(3));
        expect((slot.y - centre.y).abs(), lessThan(3));
      }
    }
  });

  test('move paths step through every square', () {
    final path = LudoBoardGeometry.movePath(LudoColor.red, 0, 10, 14);
    expect(path, hasLength(5));
    expect(path.first, LudoBoardGeometry.track[10]);
    expect(path.last, LudoBoardGeometry.track[14]);
    final entry = LudoBoardGeometry.movePath(
        LudoColor.green, 2, LudoConstants.inBase, 0);
    expect(entry, hasLength(2));
    expect(entry.first, LudoBoardGeometry.baseSlot(LudoColor.green, 2));
  });
}

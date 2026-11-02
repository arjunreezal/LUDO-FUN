import 'ludo_color.dart';

/// Who decides the moves for a seat.
enum SeatController { human, computer }

/// Strength of a computer opponent.
enum BotDifficulty {
  easy,
  medium,
  hard;

  static BotDifficulty fromName(String? name) {
    for (final value in BotDifficulty.values) {
      if (value.name == name) {
        return value;
      }
    }
    return BotDifficulty.medium;
  }
}

/// One occupied seat at the board.
class PlayerSeat {
  const PlayerSeat({
    required this.id,
    required this.name,
    required this.color,
    this.controller = SeatController.human,
    this.difficulty = BotDifficulty.medium,
    this.isLocalProfile = false,
  });

  final String id;
  final String name;
  final LudoColor color;
  final SeatController controller;
  final BotDifficulty difficulty;

  /// True for the seat that belongs to the person who owns this device.
  /// Only that seat's results are written to local statistics.
  final bool isLocalProfile;

  bool get isComputer => controller == SeatController.computer;
  bool get isHuman => controller == SeatController.human;

  PlayerSeat copyWith({
    String? id,
    String? name,
    LudoColor? color,
    SeatController? controller,
    BotDifficulty? difficulty,
    bool? isLocalProfile,
  }) {
    return PlayerSeat(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      controller: controller ?? this.controller,
      difficulty: difficulty ?? this.difficulty,
      isLocalProfile: isLocalProfile ?? this.isLocalProfile,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
        'id': id,
        'name': name,
        'color': color.name,
        'controller': controller.name,
        'difficulty': difficulty.name,
        'isLocalProfile': isLocalProfile,
      };

  static PlayerSeat? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String) {
      return null;
    }
    final controllerName = json['controller'];
    final isLocal = json['isLocalProfile'];
    final colorName = json['color'];
    final difficultyName = json['difficulty'];
    return PlayerSeat(
      id: id,
      name: name,
      color: LudoColor.fromName(
          colorName is String ? colorName : null, LudoColor.red),
      controller: controllerName == SeatController.computer.name
          ? SeatController.computer
          : SeatController.human,
      difficulty: BotDifficulty.fromName(
          difficultyName is String ? difficultyName : null),
      isLocalProfile: isLocal is bool && isLocal,
    );
  }
}
